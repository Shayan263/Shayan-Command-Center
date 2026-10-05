// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// import SwiftUI
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// import Foundation
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// import Security
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// private enum OpenAIKeyStore {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private static let service = "com.shayan.commandcentre.openai"
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private static let account = "api-key"
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     static func load() -> String {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let query: [String: Any] = [
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             kSecClass as String: kSecClassGenericPassword,
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             kSecAttrService as String: service,
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             kSecAttrAccount as String: account,
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             kSecReturnData as String: true,
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             kSecMatchLimit as String: kSecMatchLimitOne
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         ]
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         var result: AnyObject?
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//               let data = result as? Data else { return "" }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         return String(data: data, encoding: .utf8) ?? ""
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     static func save(_ key: String) throws {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let data = Data(key.utf8)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let query: [String: Any] = [
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             kSecClass as String: kSecClassGenericPassword,
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             kSecAttrService as String: service,
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             kSecAttrAccount as String: account
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         ]
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let attributes: [String: Any] = [
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             kSecValueData as String: data,
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         ]
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         if status == errSecItemNotFound {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             var addQuery = query
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             addQuery.merge(attributes) { _, new in new }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             guard addStatus == errSecSuccess else { throw OpenAIKeyError.keychain(addStatus) }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         } else if status != errSecSuccess {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             throw OpenAIKeyError.keychain(status)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     static func delete() throws {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let query: [String: Any] = [
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             kSecClass as String: kSecClassGenericPassword,
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             kSecAttrService as String: service,
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             kSecAttrAccount as String: account
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         ]
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let status = SecItemDelete(query as CFDictionary)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         guard status == errSecSuccess || status == errSecItemNotFound else {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             throw OpenAIKeyError.keychain(status)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// private enum OpenAIKeyError: Error {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     case keychain(OSStatus)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// private struct OpenAIResponse: Decodable {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     let output: [OutputItem]
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     struct OutputItem: Decodable {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let type: String
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let content: [ContentItem]?
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     struct ContentItem: Decodable {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let type: String
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let text: String?
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     var text: String {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         output
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             .filter { $0.type == "message" }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             .flatMap { $0.content ?? [] }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             .filter { $0.type == "output_text" }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             .compactMap(\.text)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             .joined(separator: "\n")
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// @MainActor
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// private final class ChatGPTService: ObservableObject {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     @Published private(set) var isSending = false
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     @Published private(set) var statusMessage: String?
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private let endpoint = URL(string: "https://api.openai.com/v1/responses")!
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     // Keep the model configurable in one place. Current API model used by Workspace.
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private let model = "gpt-6-luna"
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private var lastResponseID: String?
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private let session: URLSession = {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let configuration = URLSessionConfiguration.ephemeral
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         configuration.waitsForConnectivity = false
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         configuration.timeoutIntervalForRequest = 45
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         configuration.timeoutIntervalForResource = 60
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         configuration.httpMaximumConnectionsPerHost = 6
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         configuration.requestCachePolicy = .reloadRevalidatingCacheData
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         return URLSession(configuration: configuration)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }()
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private struct OutputItem: Decodable {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let type: String
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let content: [ContentItem]?
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let name: String?
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let call_id: String?
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let arguments: String?
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private struct ContentItem: Decodable {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let type: String
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let text: String?
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private struct ResponseEnvelope: Decodable {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let id: String
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let output: [OutputItem]
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private struct ToolCall {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let name: String
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let callID: String
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let arguments: [String: Any]
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     func send(_ message: String, apiKey: String) async throws -> String {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         guard !apiKey.isEmpty else {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             throw ChatGPTServiceError.missingAPIKey
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         isSending = true
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         statusMessage = "Thinking…"
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         defer {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             isSending = false
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             statusMessage = nil
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         var body = initialRequestBody(message)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         var response = try await performRequest(body: body, apiKey: apiKey)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         var toolRound = 0
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         while true {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             var calls: [ToolCall] = []
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             calls.reserveCapacity(response.output.count)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             for item in response.output {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 if let call = self.parseToolCall(item) {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     calls.append(call)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             if calls.isEmpty {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 var answerParts: [String] = []
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 for item in response.output {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     guard item.type == "message", let content = item.content else {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                         continue
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     for part in content {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                         if part.type == "output_text", let text = part.text {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                             answerParts.append(text)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                         }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 let answer = answerParts.joined(separator: "\n")
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 guard !answer.isEmpty else {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     throw ChatGPTServiceError.emptyResponse
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 lastResponseID = response.id
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 return answer
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             toolRound += 1
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             if toolRound > 3 {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 throw ChatGPTServiceError.toolLimit
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             statusMessage = calls.count == 1
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 ? toolStatus(calls[0].name)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 : "Inspecting project…"
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             // Execute independent read-only tools concurrently for low latency.
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             let outputs = await withTaskGroup(of: ToolOutput.self, returning: [ToolOutput].self) { group in
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 for call in calls {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     group.addTask {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                         await Self.executeTool(call)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 var collected: [ToolOutput] = []
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 for await output in group {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     collected.append(output)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 return collected
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             let toolInputs: [[String: Any]] = outputs.map {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 [
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     "type": "function_call_output",
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     "call_id": $0.callID,
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     "output": $0.output
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 ]
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             body = continuationRequestBody(responseID: response.id, toolInputs: toolInputs)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             response = try await performRequest(body: body, apiKey: apiKey)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     func resetConversation() {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         lastResponseID = nil
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         statusMessage = nil
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private func initialRequestBody(_ message: String) -> [String: Any] {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         [
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             "model": model,
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             "input": [["role": "user", "content": message]],
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             "instructions": agentInstructions,
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             "parallel_tool_calls": true,
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             "tools": Self.toolDefinitions
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         ]
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private func continuationRequestBody(responseID: String, toolInputs: [[String: Any]]) -> [String: Any] {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         [
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             "model": model,
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             "previous_response_id": responseID,
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             "input": toolInputs,
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             "instructions": "Continue the task using the tool evidence. Use the smallest number of additional read-only inspections possible, then produce the result with concrete findings and performance observations.",
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             "parallel_tool_calls": true,
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             "tools": Self.toolDefinitions
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         ]
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private let agentInstructions = """
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     You are the brain of Shayan Workspace. Act like a practical senior software engineer and agent.
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     Inspect and perform read-only work through tools instead of giving generic instructions.
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     For website sanity checks, inspect the live website and repository source when available.
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     Always include performance: response time, page/assets size, obvious bottlenecks, unnecessary requests, duplicated markup/assets, and likely mobile/iOS UX issues.
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     Be concise and action-oriented. Prefer tool evidence over guesses.
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     Do not use web search unless the user explicitly needs fresh external information.
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     Never claim that a file was changed, committed, deployed, or merged unless a write tool actually reports success.
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     """
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private func performRequest(body: [String: Any], apiKey: String) async throws -> ResponseEnvelope {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         var request = URLRequest(url: endpoint)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         request.httpMethod = "POST"
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         request.timeoutInterval = 45
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         request.setValue("application/json", forHTTPHeaderField: "Content-Type")
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         // Keep requests compact. Streaming can be added later without changing the tool protocol.
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         request.httpBody = try JSONSerialization.data(withJSONObject: body)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let (data, response) = try await session.data(for: request)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         guard let http = response as? HTTPURLResponse else {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             throw ChatGPTServiceError.invalidResponse
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         guard (200...299).contains(http.statusCode) else {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             let serverMessage = (try? JSONSerialization.jsonObject(with: data) as? [String: Any])
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 .flatMap { ($0["error"] as? [String: Any])?["message"] as? String }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             throw ChatGPTServiceError.server(serverMessage ?? "OpenAI returned HTTP \(http.statusCode).")
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         return try JSONDecoder().decode(ResponseEnvelope.self, from: data)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private func parseToolCall(_ item: OutputItem) -> ToolCall? {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         guard item.type == "function_call",
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//               let name = item.name,
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//               let callID = item.call_id,
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//               let arguments = item.arguments,
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//               let data = arguments.data(using: .utf8),
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//               let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             return nil
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         return ToolCall(name: name, callID: callID, arguments: object)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private func toolStatus(_ name: String) -> String {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         switch name {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         case "run_portfolio_sanity_check":
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             return "Checking website + performance…"
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         case "fetch_github_file":
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             return "Reading source…"
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         case "list_github_directory":
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             return "Inspecting project structure…"
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         default:
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             return "Working…"
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private struct ToolOutput {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let callID: String
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let output: String
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private static func executeTool(_ call: ToolCall) async -> ToolOutput {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         do {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             switch call.name {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             case "run_portfolio_sanity_check":
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 return ToolOutput(
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     callID: call.callID,
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     output: try await WebsiteSanityTool.run(arguments: call.arguments)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 )
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             case "fetch_github_file":
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 return ToolOutput(
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     callID: call.callID,
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     output: try await GitHubReadTool.fetchFile(arguments: call.arguments)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 )
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             case "list_github_directory":
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 return ToolOutput(
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     callID: call.callID,
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     output: try await GitHubReadTool.listDirectory(arguments: call.arguments)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 )
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             default:
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 return ToolOutput(callID: call.callID, output: "Unknown tool: \(call.name)")
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         } catch {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             return ToolOutput(callID: call.callID, output: "Tool failed: \(error.localizedDescription)")
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private static let toolDefinitions: [[String: Any]] = [
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         [
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             "type": "function",
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             "name": "run_portfolio_sanity_check",
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             "description": "Run a fast read-only sanity check of the Shayan portfolio website. Checks live HTTP availability and response time, downloads the homepage, inspects the repository index.html and linked local assets, detects duplicate references, missing/failed assets, oversized assets, and basic mobile/performance risks. Use this when the user asks to sanity check, audit, validate, review, or performance-check the website.",
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             "parameters": [
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 "type": "object",
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 "properties": [
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     "website_url": ["type": "string", "description": "Live website URL"],
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     "repository": ["type": "string", "description": "GitHub repository in owner/name form"],
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     "branch": ["type": "string", "description": "Branch to inspect"],
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     "path": ["type": "string", "description": "Homepage source path, normally index.html"]
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 ],
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 "required": ["website_url", "repository", "branch", "path"],
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 "additionalProperties": false
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             ],
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             "strict": true
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         ],
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         [
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             "type": "function",
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             "name": "fetch_github_file",
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             "description": "Read a text file from a public GitHub repository. Use this for deeper source-code inspection after the sanity check or whenever the user asks to inspect specific website code.",
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             "parameters": [
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 "type": "object",
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 "properties": [
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     "repository": ["type": "string"],
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     "branch": ["type": "string"],
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     "path": ["type": "string"]
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 ],
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 "required": ["repository", "branch", "path"],
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 "additionalProperties": false
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             ],
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             "strict": true
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         ],
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         [
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             "type": "function",
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             "name": "list_github_directory",
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             "description": "List a public GitHub repository directory so the agent can discover relevant source files without guessing paths.",
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             "parameters": [
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 "type": "object",
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 "properties": [
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     "repository": ["type": "string"],
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     "branch": ["type": "string"],
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     "path": ["type": "string"]
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 ],
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 "required": ["repository", "branch", "path"],
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 "additionalProperties": false
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             ],
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             "strict": true
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         ]
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     ]
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// private enum GitHubReadTool {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     static func fetchFile(arguments: [String: Any]) async throws -> String {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         guard let repository = arguments["repository"] as? String,
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//               let branch = arguments["branch"] as? String,
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//               let path = arguments["path"] as? String else {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             throw ToolError.invalidArguments
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let encodedPath = path.split(separator: "/").map {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             $0.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? String($0)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         }.joined(separator: "/")
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         guard let url = URL(string: "https://raw.githubusercontent.com/\(repository)/\(branch)/\(encodedPath)") else {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             throw ToolError.invalidArguments
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         var request = URLRequest(url: url)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         request.timeoutInterval = 12
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let (data, response) = try await URLSession.shared.data(for: request)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         guard let http = response as? HTTPURLResponse else { throw ToolError.invalidResponse }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         guard (200...299).contains(http.statusCode) else {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             return "GitHub file HTTP \(http.statusCode): \(repository)/\(path)"
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let text = String(data: data, encoding: .utf8) ?? ""
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         return String(text.prefix(60_000))
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     static func listDirectory(arguments: [String: Any]) async throws -> String {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         guard let repository = arguments["repository"] as? String,
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//               let branch = arguments["branch"] as? String,
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//               let path = arguments["path"] as? String else {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             throw ToolError.invalidArguments
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let encodedPath = path.split(separator: "/").map {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             $0.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? String($0)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         }.joined(separator: "/")
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         guard var components = URLComponents(string: "https://api.github.com/repos/\(repository)/contents/\(encodedPath)") else {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             throw ToolError.invalidArguments
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         components.queryItems = [URLQueryItem(name: "ref", value: branch)]
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         guard let url = components.url else { throw ToolError.invalidArguments }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         var request = URLRequest(url: url)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         request.timeoutInterval = 12
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let (data, response) = try await URLSession.shared.data(for: request)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         guard let http = response as? HTTPURLResponse else { throw ToolError.invalidResponse }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         guard (200...299).contains(http.statusCode) else {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             return "GitHub directory HTTP \(http.statusCode): \(repository)/\(path)"
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let object = try JSONSerialization.jsonObject(with: data)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         guard let items = object as? [[String: Any]] else { return "No directory listing available." }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         return items.compactMap { item in
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             guard let name = item["name"] as? String,
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                   let type = item["type"] as? String else { return nil }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             return "\(type): \(name)"
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         }.joined(separator: "\n")
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// private enum WebsiteSanityTool {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private struct FetchResult {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let url: URL
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let status: Int
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let bytes: Int
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let durationMS: Int
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let text: String
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     static func run(arguments: [String: Any]) async throws -> String {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         guard let websiteString = arguments["website_url"] as? String,
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//               let repository = arguments["repository"] as? String,
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//               let branch = arguments["branch"] as? String,
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//               let path = arguments["path"] as? String,
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//               let websiteURL = URL(string: websiteString) else {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             throw ToolError.invalidArguments
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let start = Date()
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         async let home = fetch(websiteURL)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         async let source = GitHubReadTool.fetchFile(arguments: [
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             "repository": repository,
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             "branch": branch,
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             "path": path
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         ])
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let (homeResult, sourceText) = try await (home, source)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let localAssets = assetURLs(from: sourceText, base: websiteURL)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let limitedAssets = Array(localAssets.prefix(12))
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let assetResults = await withTaskGroup(of: FetchResult?.self, returning: [FetchResult].self) { group in
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             for url in limitedAssets {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 group.addTask {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     try? await fetch(url)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             var results: [FetchResult] = []
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             for await result in group {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 if let result { results.append(result) }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             return results
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let duplicateReferences = duplicateAssetReferences(in: sourceText)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let failedAssets = assetResults.filter { $0.status < 200 || $0.status >= 300 }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let oversizedAssets = assetResults.filter { $0.bytes > 500_000 }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let scriptCount = countTag("script", in: sourceText)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let styleCount = countTag("link", in: sourceText) + countTag("style", in: sourceText)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let imageCount = countTag("img", in: sourceText)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let totalAssetBytes = assetResults.reduce(0) { $0 + $1.bytes }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let elapsed = Int(Date().timeIntervalSince(start) * 1000)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         return """
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         WEBSITE_SANITY_CHECK
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         URL: \(websiteURL.absoluteString)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         HTTP: \(homeResult.status)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         HOMEPAGE_RESPONSE_MS: \(homeResult.durationMS)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         HOMEPAGE_BYTES: \(homeResult.bytes)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         TOTAL_CHECK_MS: \(elapsed)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         SOURCE_BYTES: \(sourceText.utf8.count)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         SCRIPTS: \(scriptCount)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         STYLE_LINKS_OR_TAGS: \(styleCount)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         IMAGES: \(imageCount)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         LOCAL_ASSETS_DISCOVERED: \(localAssets.count)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         LOCAL_ASSETS_CHECKED: \(assetResults.count)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         CHECKED_ASSET_BYTES: \(totalAssetBytes)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         FAILED_ASSETS: \(failedAssets.map { $0.url.absoluteString }.joined(separator: ", "))
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         OVERSIZED_ASSETS_GT_500KB: \(oversizedAssets.map { "\($0.url.lastPathComponent) (\($0.bytes) bytes)" }.joined(separator: ", "))
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         DUPLICATE_REFERENCES: \(duplicateReferences.joined(separator: ", "))
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         NOTES: This is a fast static/runtime smoke test, not a full Lighthouse replacement. Use source inspection for deeper code-level findings.
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         """
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private static func fetch(_ url: URL) async throws -> FetchResult {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let start = Date()
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         var request = URLRequest(url: url)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         request.timeoutInterval = 12
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         request.setValue("Shayan-Core-SanityCheck/1.0", forHTTPHeaderField: "User-Agent")
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let (data, response) = try await URLSession.shared.data(for: request)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let http = response as? HTTPURLResponse
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         return FetchResult(
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             url: url,
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             status: http?.statusCode ?? -1,
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             bytes: data.count,
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             durationMS: Int(Date().timeIntervalSince(start) * 1000),
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             text: String(data: data, encoding: .utf8) ?? ""
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         )
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private static func assetURLs(from html: String, base: URL) -> [URL] {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let pattern = #"(?:src|href)\s*=\s*[\"']([^\"'#]+)[\"']"#
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return [] }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let range = NSRange(html.startIndex..., in: html)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         var urls: [URL] = []
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         for match in regex.matches(in: html, range: range) {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             guard let r = Range(match.range(at: 1), in: html) else { continue }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             let raw = String(html[r])
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             guard !raw.hasPrefix("http://"),
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                   !raw.hasPrefix("https://"),
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                   !raw.hasPrefix("mailto:"),
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                   !raw.hasPrefix("javascript:"),
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                   let url = URL(string: raw, relativeTo: base)?.absoluteURL else { continue }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             if !urls.contains(url) { urls.append(url) }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         return urls
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private static func duplicateAssetReferences(in html: String) -> [String] {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let pattern = #"(?:src|href)\s*=\s*[\"']([^\"'#]+)[\"']"#
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return [] }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let range = NSRange(html.startIndex..., in: html)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         var counts: [String: Int] = [:]
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         for match in regex.matches(in: html, range: range) {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             guard let r = Range(match.range(at: 1), in: html) else { continue }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             let value = String(html[r])
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             counts[value, default: 0] += 1
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         return counts.filter { $0.value > 1 }.map { "\($0.key) x\($0.value)" }.sorted()
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private static func countTag(_ tag: String, in html: String) -> Int {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let pattern = "<\(tag)\\b"
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         return (try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]))?
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             .numberOfMatches(in: html, range: NSRange(html.startIndex..., in: html)) ?? 0
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// private enum ToolError: LocalizedError {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     case invalidArguments
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     case invalidResponse
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     var errorDescription: String? {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         switch self {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         case .invalidArguments: return "Invalid tool arguments."
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         case .invalidResponse: return "Invalid network response."
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// private enum ChatGPTServiceError: LocalizedError {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     case missingAPIKey
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     case invalidResponse
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     case server(String)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     case emptyResponse
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     case toolLimit
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     var errorDescription: String? {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         switch self {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         case .missingAPIKey:
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             return "Add your OpenAI API key to start ChatGPT."
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         case .invalidResponse:
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             return "The AI service returned an invalid response."
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         case .server(let message):
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             return message
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         case .emptyResponse:
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             return "The AI returned no text response."
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         case .toolLimit:
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             return "The agent reached its inspection limit. Try a narrower request."
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// private struct WorkspaceMessage: Identifiable {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     let id = UUID()
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     let role: Role
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     let text: String
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     enum Role {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         case user
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         case assistant
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// struct WorkspaceView: View {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     @StateObject private var service = ChatGPTService()
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     @State private var apiKey = OpenAIKeyStore.load()
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     @State private var draft = ""
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     @State private var messages: [WorkspaceMessage] = []
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     @State private var showKeyField = false
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     var body: some View {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         VStack(spacing: 0) {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             if apiKey.isEmpty {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 setupCard
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             } else {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 chatView
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         .navigationTitle("Workspace")
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         .navigationBarTitleDisplayMode(.inline)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         .toolbar {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             ToolbarItem(placement: .topBarTrailing) {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 Menu {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     Button {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                         showKeyField = true
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     } label: {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                         Label("OpenAI API Key", systemImage: "key")
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     Button {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                         messages.removeAll()
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                         service.resetConversation()
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     } label: {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                         Label("New conversation", systemImage: "plus.bubble")
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 } label: {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     Image(systemName: "ellipsis.circle")
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         .sheet(isPresented: $showKeyField) {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             APIKeySheet(apiKey: $apiKey)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         .onAppear {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             if messages.isEmpty && !apiKey.isEmpty {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 messages.append(
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     WorkspaceMessage(
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                         role: .assistant,
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                         text: "I'm ready. Ask me anything, search the web, or give me a coding task."
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     )
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 )
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private var setupCard: some View {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         ScrollView {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             VStack(alignment: .leading, spacing: 18) {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 WorkspaceHero()
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 VStack(alignment: .leading, spacing: 10) {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     Label("ChatGPT capability", systemImage: "sparkles")
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                         .font(.headline)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     Text("This workspace is the starting point for your AI coding environment. It uses the OpenAI Responses API and can use web search when needed.")
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                         .font(.body)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                         .foregroundStyle(.secondary)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 .padding(17)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 .background(Color.primary.opacity(0.045))
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 .clipShape(RoundedRectangle(cornerRadius: 18))
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 Button {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     showKeyField = true
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 } label: {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     Label("Connect OpenAI", systemImage: "link")
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                         .font(.headline)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                         .frame(maxWidth: .infinity)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                         .padding(.vertical, 14)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 .buttonStyle(.borderedProminent)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 Text("For this first personal build, the key is stored in the iPhone Keychain and is never written into the repository. For a distributed/public release, move the OpenAI call behind your own authenticated backend.")
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     .font(.caption)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     .foregroundStyle(.tertiary)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             .padding(20)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private var chatView: some View {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         VStack(spacing: 0) {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             ScrollViewReader { proxy in
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 ScrollView {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     LazyVStack(alignment: .leading, spacing: 12) {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                         ForEach(messages) { message in
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                             WorkspaceBubble(message: message)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                                 .id(message.id)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                         }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                         if service.isSending {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                             HStack(spacing: 8) {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                                 ProgressView()
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                                 Text(service.statusMessage ?? "Working…")
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                                     .font(.caption)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                                     .foregroundStyle(.secondary)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                             }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                             .padding(.horizontal, 14)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                         }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     .padding(16)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 .onChange(of: messages.count) {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     if let id = messages.last?.id {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                         withAnimation(.easeOut(duration: 0.2)) {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                             proxy.scrollTo(id, anchor: .bottom)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                         }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             Divider()
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             HStack(alignment: .bottom, spacing: 10) {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 TextField("Ask ChatGPT anything…", text: $draft, axis: .vertical)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     .textFieldStyle(.roundedBorder)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     .lineLimit(1...5)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     .onSubmit {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                         Task { await send() }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 Button {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     Task { await send() }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 } label: {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     Image(systemName: service.isSending ? "hourglass" : "arrow.up.circle.fill")
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                         .font(.system(size: 30))
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 .disabled(service.isSending || draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             .padding(12)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             .background(.bar)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             HStack(spacing: 8) {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 Image(systemName: "sparkles")
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 Text("OpenAI • Agent tools • Performance aware")
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 Spacer()
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 Button("New") {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     messages.removeAll()
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     service.resetConversation()
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             .font(.caption2)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             .foregroundStyle(.secondary)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             .padding(.horizontal, 14)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             .padding(.bottom, 8)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private func send() async {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let prompt = draft.trimmingCharacters(in: .whitespacesAndNewlines)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         guard !prompt.isEmpty else { return }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         draft = ""
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         messages.append(WorkspaceMessage(role: .user, text: prompt))
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         do {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             let answer = try await service.send(prompt, apiKey: apiKey)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             messages.append(WorkspaceMessage(role: .assistant, text: answer))
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         } catch {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             messages.append(
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 WorkspaceMessage(
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     role: .assistant,
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     text: "I couldn't complete that request. \(error.localizedDescription)"
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 )
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             )
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// private struct WorkspaceHero: View {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     var body: some View {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         VStack(alignment: .leading, spacing: 10) {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             ZStack {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 Circle()
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     .fill(
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                         LinearGradient(
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                             colors: [.blue, .cyan],
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                             startPoint: .topLeading,
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                             endPoint: .bottomTrailing
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                         )
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     )
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     .frame(width: 66, height: 66)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 Image(systemName: "terminal.fill")
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     .font(.system(size: 28, weight: .semibold))
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     .foregroundStyle(.white)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             Text("Shayan Workspace")
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 .font(.largeTitle.bold())
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             Text("Your dedicated place for ChatGPT-powered coding, research and agent workflows.")
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 .font(.body)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 .foregroundStyle(.secondary)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// private struct WorkspaceBubble: View {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     let message: WorkspaceMessage
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     var body: some View {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         HStack {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             if message.role == .assistant {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 bubble
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 Spacer(minLength: 28)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             } else {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 Spacer(minLength: 28)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 bubble
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private var bubble: some View {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         VStack(alignment: .leading, spacing: 5) {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             Text(message.role == .assistant ? "SHAYAN CORE" : "YOU")
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 .font(.system(size: 9, weight: .bold))
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 .tracking(1)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 .foregroundStyle(message.role == .assistant ? .blue : .secondary)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             Text(message.text)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 .font(.body)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 .textSelection(.enabled)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         .padding(13)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         .background(message.role == .assistant ? Color.blue.opacity(0.08) : Color.primary.opacity(0.06))
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         .clipShape(RoundedRectangle(cornerRadius: 17))
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// private struct APIKeySheet: View {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     @Binding var apiKey: String
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     @Environment(\.dismiss) private var dismiss
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     @State private var draft = ""
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     var body: some View {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         NavigationStack {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             Form {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 Section("OpenAI API key") {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     SecureField("sk-…", text: $draft)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                         .textInputAutocapitalization(.never)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                         .autocorrectionDisabled()
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 Section {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     Text("The key is stored locally in the iPhone Keychain. Do not commit it to GitHub.")
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                         .font(.caption)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                         .foregroundStyle(.secondary)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 Button("Save") {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     let value = draft.trimmingCharacters(in: .whitespacesAndNewlines)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     guard !value.isEmpty else { return }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     do {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                         try OpenAIKeyStore.save(value)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                         apiKey = value
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                         dismiss()
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     } catch {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                         // Keep the sheet open; the key remains unchanged.
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             .navigationTitle("AI Connection")
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             .navigationBarTitleDisplayMode(.inline)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             .toolbar {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 ToolbarItem(placement: .topBarLeading) {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     Button("Cancel") { dismiss() }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             .onAppear {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 draft = apiKey
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 