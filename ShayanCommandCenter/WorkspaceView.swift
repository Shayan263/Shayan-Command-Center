import SwiftUI
import Foundation
import Security

private enum OpenAIKeyStore {
    private static let service = "com.shayan.commandcentre.openai"
    private static let account = "api-key"

    static func load() -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return "" }
        return String(data: data, encoding: .utf8) ?? ""
    }

    static func save(_ key: String) throws {
        let data = Data(key.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if status == errSecItemNotFound {
            var addQuery = query
            addQuery.merge(attributes) { _, new in new }
            let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
            guard addStatus == errSecSuccess else { throw OpenAIKeyError.keychain(addStatus) }
        } else if status != errSecSuccess {
            throw OpenAIKeyError.keychain(status)
        }
    }

    static func delete() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw OpenAIKeyError.keychain(status)
        }
    }
}

private enum OpenAIKeyError: Error {
    case keychain(OSStatus)
}

private struct OpenAIResponse: Decodable {
    let output: [OutputItem]

    struct OutputItem: Decodable {
        let type: String
        let content: [ContentItem]?
    }

    struct ContentItem: Decodable {
        let type: String
        let text: String?
    }

    var text: String {
        output
            .filter { $0.type == "message" }
            .flatMap { $0.content ?? [] }
            .filter { $0.type == "output_text" }
            .compactMap(\.text)
            .joined(separator: "\n")
    }
}

@MainActor
private final class ChatGPTService: ObservableObject {
    @Published private(set) var isSending = false
    @Published private(set) var statusMessage: String?
    
    private let endpoint = URL(string: "https://api.openai.com/v1/responses")!
    // Keep the model configurable in one place. Current API model used by Workspace.
    private let model = "gpt-6-luna"
    private var lastResponseID: String?
    private let session: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.waitsForConnectivity = false
        configuration.timeoutIntervalForRequest = 45
        configuration.timeoutIntervalForResource = 60
        configuration.httpMaximumConnectionsPerHost = 6
        configuration.requestCachePolicy = .reloadRevalidatingCacheData
        return URLSession(configuration: configuration)
    }()
    
    private struct OutputItem: Decodable {
        let type: String
        let content: [ContentItem]?
        let name: String?
        let call_id: String?
        let arguments: String?
    }
    
    private struct ContentItem: Decodable {
        let type: String
        let text: String?
    }
    
    private struct ResponseEnvelope: Decodable {
        let id: String
        let output: [OutputItem]
    }
    
    private struct ToolCall {
        let name: String
        let callID: String
        let arguments: [String: Any]
    }
    
    func send(_ message: String, apiKey: String) async throws -> String {
        guard !apiKey.isEmpty else {
            throw ChatGPTServiceError.missingAPIKey
        }
        
        isSending = true
        statusMessage = "Thinking…"
        defer {
            isSending = false
            statusMessage = nil
        }
        
        var body = initialRequestBody(message)
        
        var response = try await performRequest(body: body, apiKey: apiKey)
        var toolRound = 0
        
        while true {
            let calls: [ToolCall] = response.output.compactMap { item in\n                self.parseToolCall(item)\n            }
            if calls.isEmpty {
                let answer = response.output
                    .filter { $0.type == "message" }
                    .flatMap { $0.content ?? [] }
                    .filter { $0.type == "output_text" }
                    .compactMap(\.text)
                    .joined(separator: "\n")
                
                guard !answer.isEmpty else {
                    throw ChatGPTServiceError.emptyResponse
                }
                
                lastResponseID = response.id
                return answer
            }
            
            toolRound += 1
            if toolRound > 3 {
                throw ChatGPTServiceError.toolLimit
            }
            
            statusMessage = calls.count == 1
                ? toolStatus(calls[0].name)
                : "Inspecting project…"
            
            // Execute independent read-only tools concurrently for low latency.
            let outputs = await withTaskGroup(of: ToolOutput.self, returning: [ToolOutput].self) { group in
                for call in calls {
                    group.addTask {
                        await Self.executeTool(call)
                    }
                }
                
                var collected: [ToolOutput] = []
                for await output in group {
                    collected.append(output)
                }
                return collected
            }
            
            let toolInputs: [[String: Any]] = outputs.map {
                [
                    "type": "function_call_output",
                    "call_id": $0.callID,
                    "output": $0.output
                ]
            }
            
            body = continuationRequestBody(responseID: response.id, toolInputs: toolInputs)
            
            response = try await performRequest(body: body, apiKey: apiKey)
        }
    }
    
    func resetConversation() {
        lastResponseID = nil
        statusMessage = nil
    }
    
    private func initialRequestBody(_ message: String) -> [String: Any] {
        [
            "model": model,
            "input": [["role": "user", "content": message]],
            "instructions": agentInstructions,
            "parallel_tool_calls": true,
            "tools": Self.toolDefinitions
        ]
    }

    private func continuationRequestBody(responseID: String, toolInputs: [[String: Any]]) -> [String: Any] {
        [
            "model": model,
            "previous_response_id": responseID,
            "input": toolInputs,
            "instructions": "Continue the task using the tool evidence. Use the smallest number of additional read-only inspections possible, then produce the result with concrete findings and performance observations.",
            "parallel_tool_calls": true,
            "tools": Self.toolDefinitions
        ]
    }

    private let agentInstructions = """
    You are the brain of Shayan Workspace. Act like a practical senior software engineer and agent.
    Inspect and perform read-only work through tools instead of giving generic instructions.
    For website sanity checks, inspect the live website and repository source when available.
    Always include performance: response time, page/assets size, obvious bottlenecks, unnecessary requests, duplicated markup/assets, and likely mobile/iOS UX issues.
    Be concise and action-oriented. Prefer tool evidence over guesses.
    Do not use web search unless the user explicitly needs fresh external information.
    Never claim that a file was changed, committed, deployed, or merged unless a write tool actually reports success.
    """

    private func performRequest(body: [String: Any], apiKey: String) async throws -> ResponseEnvelope {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.timeoutInterval = 45
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Keep requests compact. Streaming can be added later without changing the tool protocol.
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw ChatGPTServiceError.invalidResponse
        }
        
        guard (200...299).contains(http.statusCode) else {
            let serverMessage = (try? JSONSerialization.jsonObject(with: data) as? [String: Any])
                .flatMap { ($0["error"] as? [String: Any])?["message"] as? String }
            throw ChatGPTServiceError.server(serverMessage ?? "OpenAI returned HTTP \(http.statusCode).")
        }
        
        return try JSONDecoder().decode(ResponseEnvelope.self, from: data)
    }
    
    private func parseToolCall(_ item: OutputItem) -> ToolCall? {
        guard item.type == "function_call",
              let name = item.name,
              let callID = item.call_id,
              let arguments = item.arguments,
              let data = arguments.data(using: .utf8),
              let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        
        return ToolCall(name: name, callID: callID, arguments: object)
    }
    
    private func toolStatus(_ name: String) -> String {
        switch name {
        case "run_portfolio_sanity_check":
            return "Checking website + performance…"
        case "fetch_github_file":
            return "Reading source…"
        case "list_github_directory":
            return "Inspecting project structure…"
        default:
            return "Working…"
        }
    }
    
    private struct ToolOutput {
        let callID: String
        let output: String
    }
    
    private static func executeTool(_ call: ToolCall) async -> ToolOutput {
        do {
            switch call.name {
            case "run_portfolio_sanity_check":
                return ToolOutput(
                    callID: call.callID,
                    output: try await WebsiteSanityTool.run(arguments: call.arguments)
                )
            case "fetch_github_file":
                return ToolOutput(
                    callID: call.callID,
                    output: try await GitHubReadTool.fetchFile(arguments: call.arguments)
                )
            case "list_github_directory":
                return ToolOutput(
                    callID: call.callID,
                    output: try await GitHubReadTool.listDirectory(arguments: call.arguments)
                )
            default:
                return ToolOutput(callID: call.callID, output: "Unknown tool: \(call.name)")
            }
        } catch {
            return ToolOutput(callID: call.callID, output: "Tool failed: \(error.localizedDescription)")
        }
    }
    
    private static let toolDefinitions: [[String: Any]] = [
        [
            "type": "function",
            "name": "run_portfolio_sanity_check",
            "description": "Run a fast read-only sanity check of the Shayan portfolio website. Checks live HTTP availability and response time, downloads the homepage, inspects the repository index.html and linked local assets, detects duplicate references, missing/failed assets, oversized assets, and basic mobile/performance risks. Use this when the user asks to sanity check, audit, validate, review, or performance-check the website.",
            "parameters": [
                "type": "object",
                "properties": [
                    "website_url": ["type": "string", "description": "Live website URL"],
                    "repository": ["type": "string", "description": "GitHub repository in owner/name form"],
                    "branch": ["type": "string", "description": "Branch to inspect"],
                    "path": ["type": "string", "description": "Homepage source path, normally index.html"]
                ],
                "required": ["website_url", "repository", "branch", "path"],
                "additionalProperties": false
            ],
            "strict": true
        ],
        [
            "type": "function",
            "name": "fetch_github_file",
            "description": "Read a text file from a public GitHub repository. Use this for deeper source-code inspection after the sanity check or whenever the user asks to inspect specific website code.",
            "parameters": [
                "type": "object",
                "properties": [
                    "repository": ["type": "string"],
                    "branch": ["type": "string"],
                    "path": ["type": "string"]
                ],
                "required": ["repository", "branch", "path"],
                "additionalProperties": false
            ],
            "strict": true
        ],
        [
            "type": "function",
            "name": "list_github_directory",
            "description": "List a public GitHub repository directory so the agent can discover relevant source files without guessing paths.",
            "parameters": [
                "type": "object",
                "properties": [
                    "repository": ["type": "string"],
                    "branch": ["type": "string"],
                    "path": ["type": "string"]
                ],
                "required": ["repository", "branch", "path"],
                "additionalProperties": false
            ],
            "strict": true
        ]
    ]
}

private enum GitHubReadTool {
    static func fetchFile(arguments: [String: Any]) async throws -> String {
        guard let repository = arguments["repository"] as? String,
              let branch = arguments["branch"] as? String,
              let path = arguments["path"] as? String else {
            throw ToolError.invalidArguments
        }
        
        let encodedPath = path.split(separator: "/").map {
            $0.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? String($0)
        }.joined(separator: "/")
        
        guard let url = URL(string: "https://raw.githubusercontent.com/\(repository)/\(branch)/\(encodedPath)") else {
            throw ToolError.invalidArguments
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 12
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse else { throw ToolError.invalidResponse }
        guard (200...299).contains(http.statusCode) else {
            return "GitHub file HTTP \(http.statusCode): \(repository)/\(path)"
        }
        
        let text = String(data: data, encoding: .utf8) ?? ""
        return String(text.prefix(60_000))
    }
    
    static func listDirectory(arguments: [String: Any]) async throws -> String {
        guard let repository = arguments["repository"] as? String,
              let branch = arguments["branch"] as? String,
              let path = arguments["path"] as? String else {
            throw ToolError.invalidArguments
        }
        
        let encodedPath = path.split(separator: "/").map {
            $0.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? String($0)
        }.joined(separator: "/")
        
        guard var components = URLComponents(string: "https://api.github.com/repos/\(repository)/contents/\(encodedPath)") else {
            throw ToolError.invalidArguments
        }
        components.queryItems = [URLQueryItem(name: "ref", value: branch)]
        
        guard let url = components.url else { throw ToolError.invalidArguments }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 12
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse else { throw ToolError.invalidResponse }
        guard (200...299).contains(http.statusCode) else {
            return "GitHub directory HTTP \(http.statusCode): \(repository)/\(path)"
        }
        
        let object = try JSONSerialization.jsonObject(with: data)
        guard let items = object as? [[String: Any]] else { return "No directory listing available." }
        
        return items.compactMap { item in
            guard let name = item["name"] as? String,
                  let type = item["type"] as? String else { return nil }
            return "\(type): \(name)"
        }.joined(separator: "\n")
    }
}

private enum WebsiteSanityTool {
    private struct FetchResult {
        let url: URL
        let status: Int
        let bytes: Int
        let durationMS: Int
        let text: String
    }
    
    static func run(arguments: [String: Any]) async throws -> String {
        guard let websiteString = arguments["website_url"] as? String,
              let repository = arguments["repository"] as? String,
              let branch = arguments["branch"] as? String,
              let path = arguments["path"] as? String,
              let websiteURL = URL(string: websiteString) else {
            throw ToolError.invalidArguments
        }
        
        let start = Date()
        
        async let home = fetch(websiteURL)
        async let source = GitHubReadTool.fetchFile(arguments: [
            "repository": repository,
            "branch": branch,
            "path": path
        ])
        
        let (homeResult, sourceText) = try await (home, source)
        let localAssets = assetURLs(from: sourceText, base: websiteURL)
        let limitedAssets = Array(localAssets.prefix(12))
        
        let assetResults = await withTaskGroup(of: FetchResult?.self, returning: [FetchResult].self) { group in
            for url in limitedAssets {
                group.addTask {
                    try? await fetch(url)
                }
            }
            
            var results: [FetchResult] = []
            for await result in group {
                if let result { results.append(result) }
            }
            return results
        }
        
        let duplicateReferences = duplicateAssetReferences(in: sourceText)
        let failedAssets = assetResults.filter { $0.status < 200 || $0.status >= 300 }
        let oversizedAssets = assetResults.filter { $0.bytes > 500_000 }
        let scriptCount = countTag("script", in: sourceText)
        let styleCount = countTag("link", in: sourceText) + countTag("style", in: sourceText)
        let imageCount = countTag("img", in: sourceText)
        let totalAssetBytes = assetResults.reduce(0) { $0 + $1.bytes }
        let elapsed = Int(Date().timeIntervalSince(start) * 1000)
        
        return """
        WEBSITE_SANITY_CHECK
        URL: \(websiteURL.absoluteString)
        HTTP: \(homeResult.status)
        HOMEPAGE_RESPONSE_MS: \(homeResult.durationMS)
        HOMEPAGE_BYTES: \(homeResult.bytes)
        TOTAL_CHECK_MS: \(elapsed)
        SOURCE_BYTES: \(sourceText.utf8.count)
        SCRIPTS: \(scriptCount)
        STYLE_LINKS_OR_TAGS: \(styleCount)
        IMAGES: \(imageCount)
        LOCAL_ASSETS_DISCOVERED: \(localAssets.count)
        LOCAL_ASSETS_CHECKED: \(assetResults.count)
        CHECKED_ASSET_BYTES: \(totalAssetBytes)
        FAILED_ASSETS: \(failedAssets.map { $0.url.absoluteString }.joined(separator: ", "))
        OVERSIZED_ASSETS_GT_500KB: \(oversizedAssets.map { "\($0.url.lastPathComponent) (\($0.bytes) bytes)" }.joined(separator: ", "))
        DUPLICATE_REFERENCES: \(duplicateReferences.joined(separator: ", "))
        NOTES: This is a fast static/runtime smoke test, not a full Lighthouse replacement. Use source inspection for deeper code-level findings.
        """
    }
    
    private static func fetch(_ url: URL) async throws -> FetchResult {
        let start = Date()
        var request = URLRequest(url: url)
        request.timeoutInterval = 12
        request.setValue("Shayan-Core-SanityCheck/1.0", forHTTPHeaderField: "User-Agent")
        let (data, response) = try await URLSession.shared.data(for: request)
        let http = response as? HTTPURLResponse
        return FetchResult(
            url: url,
            status: http?.statusCode ?? -1,
            bytes: data.count,
            durationMS: Int(Date().timeIntervalSince(start) * 1000),
            text: String(data: data, encoding: .utf8) ?? ""
        )
    }
    
    private static func assetURLs(from html: String, base: URL) -> [URL] {
        let pattern = #"(?:src|href)\s*=\s*[\"']([^\"'#]+)[\"']"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return [] }
        
        let range = NSRange(html.startIndex..., in: html)
        var urls: [URL] = []
        for match in regex.matches(in: html, range: range) {
            guard let r = Range(match.range(at: 1), in: html) else { continue }
            let raw = String(html[r])
            guard !raw.hasPrefix("http://"),
                  !raw.hasPrefix("https://"),
                  !raw.hasPrefix("mailto:"),
                  !raw.hasPrefix("javascript:"),
                  let url = URL(string: raw, relativeTo: base)?.absoluteURL else { continue }
            if !urls.contains(url) { urls.append(url) }
        }
        return urls
    }
    
    private static func duplicateAssetReferences(in html: String) -> [String] {
        let pattern = #"(?:src|href)\s*=\s*[\"']([^\"'#]+)[\"']"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return [] }
        let range = NSRange(html.startIndex..., in: html)
        var counts: [String: Int] = [:]
        for match in regex.matches(in: html, range: range) {
            guard let r = Range(match.range(at: 1), in: html) else { continue }
            let value = String(html[r])
            counts[value, default: 0] += 1
        }
        return counts.filter { $0.value > 1 }.map { "\($0.key) x\($0.value)" }.sorted()
    }
    
    private static func countTag(_ tag: String, in html: String) -> Int {
        let pattern = "<\(tag)\\b"
        return (try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]))?
            .numberOfMatches(in: html, range: NSRange(html.startIndex..., in: html)) ?? 0
    }
}

private enum ToolError: LocalizedError {
    case invalidArguments
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .invalidArguments: return "Invalid tool arguments."
        case .invalidResponse: return "Invalid network response."
        }
    }
}

private enum ChatGPTServiceError: LocalizedError {
    case missingAPIKey
    case invalidResponse
    case server(String)
    case emptyResponse
    case toolLimit
    
    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Add your OpenAI API key to start ChatGPT."
        case .invalidResponse:
            return "The AI service returned an invalid response."
        case .server(let message):
            return message
        case .emptyResponse:
            return "The AI returned no text response."
        case .toolLimit:
            return "The agent reached its inspection limit. Try a narrower request."
        }
    }
}

private struct WorkspaceMessage: Identifiable {
    let id = UUID()
    let role: Role
    let text: String

    enum Role {
        case user
        case assistant
    }
}

struct WorkspaceView: View {
    @StateObject private var service = ChatGPTService()
    @State private var apiKey = OpenAIKeyStore.load()
    @State private var draft = ""
    @State private var messages: [WorkspaceMessage] = []
    @State private var showKeyField = false

    var body: some View {
        VStack(spacing: 0) {
            if apiKey.isEmpty {
                setupCard
            } else {
                chatView
            }
        }
        .navigationTitle("Workspace")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showKeyField = true
                    } label: {
                        Label("OpenAI API Key", systemImage: "key")
                    }

                    Button {
                        messages.removeAll()
                        service.resetConversation()
                    } label: {
                        Label("New conversation", systemImage: "plus.bubble")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showKeyField) {
            APIKeySheet(apiKey: $apiKey)
        }
        .onAppear {
            if messages.isEmpty && !apiKey.isEmpty {
                messages.append(
                    WorkspaceMessage(
                        role: .assistant,
                        text: "I'm ready. Ask me anything, search the web, or give me a coding task."
                    )
                )
            }
        }
    }

    private var setupCard: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                WorkspaceHero()

                VStack(alignment: .leading, spacing: 10) {
                    Label("ChatGPT capability", systemImage: "sparkles")
                        .font(.headline)
                    Text("This workspace is the starting point for your AI coding environment. It uses the OpenAI Responses API and can use web search when needed.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .padding(17)
                .background(Color.primary.opacity(0.045))
                .clipShape(RoundedRectangle(cornerRadius: 18))

                Button {
                    showKeyField = true
                } label: {
                    Label("Connect OpenAI", systemImage: "link")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)

                Text("For this first personal build, the key is stored in the iPhone Keychain and is never written into the repository. For a distributed/public release, move the OpenAI call behind your own authenticated backend.")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(20)
        }
    }

    private var chatView: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(messages) { message in
                            WorkspaceBubble(message: message)
                                .id(message.id)
                        }

                        if service.isSending {
                            HStack(spacing: 8) {
                                ProgressView()
                                Text(service.statusMessage ?? "Working…")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 14)
                        }
                    }
                    .padding(16)
                }
                .onChange(of: messages.count) {
                    if let id = messages.last?.id {
                        withAnimation(.easeOut(duration: 0.2)) {
                            proxy.scrollTo(id, anchor: .bottom)
                        }
                    }
                }
            }

            Divider()

            HStack(alignment: .bottom, spacing: 10) {
                TextField("Ask ChatGPT anything…", text: $draft, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...5)
                    .onSubmit {
                        Task { await send() }
                    }

                Button {
                    Task { await send() }
                } label: {
                    Image(systemName: service.isSending ? "hourglass" : "arrow.up.circle.fill")
                        .font(.system(size: 30))
                }
                .disabled(service.isSending || draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(12)
            .background(.bar)

            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                Text("OpenAI • Agent tools • Performance aware")
                Spacer()
                Button("New") {
                    messages.removeAll()
                    service.resetConversation()
                }
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 14)
            .padding(.bottom, 8)
        }
    }

    private func send() async {
        let prompt = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty else { return }

        draft = ""
        messages.append(WorkspaceMessage(role: .user, text: prompt))

        do {
            let answer = try await service.send(prompt, apiKey: apiKey)
            messages.append(WorkspaceMessage(role: .assistant, text: answer))
        } catch {
            messages.append(
                WorkspaceMessage(
                    role: .assistant,
                    text: "I couldn't complete that request. \(error.localizedDescription)"
                )
            )
        }
    }
}

private struct WorkspaceHero: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 66, height: 66)
                Image(systemName: "terminal.fill")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.white)
            }

            Text("Shayan Workspace")
                .font(.largeTitle.bold())

            Text("Your dedicated place for ChatGPT-powered coding, research and agent workflows.")
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }
}

private struct WorkspaceBubble: View {
    let message: WorkspaceMessage

    var body: some View {
        HStack {
            if message.role == .assistant {
                bubble
                Spacer(minLength: 28)
            } else {
                Spacer(minLength: 28)
                bubble
            }
        }
    }

    private var bubble: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(message.role == .assistant ? "SHAYAN CORE" : "YOU")
                .font(.system(size: 9, weight: .bold))
                .tracking(1)
                .foregroundStyle(message.role == .assistant ? .blue : .secondary)

            Text(message.text)
                .font(.body)
                .textSelection(.enabled)
        }
        .padding(13)
        .background(message.role == .assistant ? Color.blue.opacity(0.08) : Color.primary.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 17))
    }
}

private struct APIKeySheet: View {
    @Binding var apiKey: String
    @Environment(\.dismiss) private var dismiss
    @State private var draft = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("OpenAI API key") {
                    SecureField("sk-…", text: $draft)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                Section {
                    Text("The key is stored locally in the iPhone Keychain. Do not commit it to GitHub.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Button("Save") {
                    let value = draft.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !value.isEmpty else { return }
                    do {
                        try OpenAIKeyStore.save(value)
                        apiKey = value
                        dismiss()
                    } catch {
                        // Keep the sheet open; the key remains unchanged.
                    }
                }
            }
            .navigationTitle("AI Connection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                draft = apiKey
            }
        }
    }
}
