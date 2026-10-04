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
            .compactMap(.text)
            .joined(separator: "\n")
    }
}

@MainActor
private final class ChatGPTService: ObservableObject {
    @Published private(set) var isSending = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var lastResponseID: String?

    private let endpoint = URL(string: "https://api.openai.com/v1/responses")!
    private let model = "gpt-5.6-luna"

    func send(_ message: String, apiKey: String) async throws -> String {
        guard !apiKey.isEmpty else {
            throw ChatGPTServiceError.missingAPIKey
        }

        isSending = true
        errorMessage = nil
        defer { isSending = false }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.timeoutInterval = 90
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var body: [String: Any] = [
            "model": model,
            "input": message,
            "tools": [["type": "web_search"]]
        ]
        if let lastResponseID {
            body["previous_response_id"] = lastResponseID
        }

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw ChatGPTServiceError.invalidResponse
        }

        guard (200...299).contains(http.statusCode) else {
            let serverMessage = (try? JSONSerialization.jsonObject(with: data) as? [String: Any])
                .flatMap { ($0["error"] as? [String: Any])?["message"] as? String }
            throw ChatGPTServiceError.server(serverMessage ?? "OpenAI returned HTTP \(http.statusCode).")
        }

        let decoded = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        guard !decoded.text.isEmpty else {
            throw ChatGPTServiceError.emptyResponse
        }

        if let responseID = (try? JSONSerialization.jsonObject(with: data) as? [String: Any])?["id"] as? String {
            lastResponseID = responseID
        }

        return decoded.text
    }

    func resetConversation() {
        lastResponseID = nil
        errorMessage = nil
    }
}

private enum ChatGPTServiceError: LocalizedError {
    case missingAPIKey
    case invalidResponse
    case server(String)
    case emptyResponse

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
                                Text("Thinking…")
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
                Text("ChatGPT • Web search enabled")
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
