// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// import Foundation
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// import AuthenticationServices
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// import Security
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// import UIKit
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// import CryptoKit
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// struct GmailMessageSummary: Identifiable, Sendable {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     let id: String
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     let threadID: String
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     let sender: String
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     let subject: String
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     let snippet: String
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     let isUnread: Bool
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     let date: Date?
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// enum GmailToolError: LocalizedError {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     case notConfigured, cancelled, authorizationFailed, invalidResponse, tokenMissing
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     case api(String)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     var errorDescription: String? {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         switch self {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         case .notConfigured: return "Gmail is not configured. Add your Google OAuth iOS client ID."
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         case .cancelled: return "Google authorization was cancelled."
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         case .authorizationFailed: return "Google authorization failed."
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         case .invalidResponse: return "Gmail returned an invalid response."
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         case .tokenMissing: return "Gmail authorization expired. Connect Gmail again."
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         case .api(let message): return message
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// @MainActor
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// final class GmailTool: NSObject, ObservableObject {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     static let shared = GmailTool()
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     @Published private(set) var isConnected = false
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     @Published private(set) var accountEmail: String?
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private let clientIDKey = "shayan.gmail.oauth.clientID"
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private let keychainService = "com.shayan.commandcentre.gmail"
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private let accessTokenAccount = "access-token"
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private let refreshTokenAccount = "refresh-token"
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private let redirectURI = "com.shayan.commandcentre:/oauth2redirect/google"
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private let scope = "https://www.googleapis.com/auth/gmail.readonly"
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private var session: ASWebAuthenticationSession?
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     override init() {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         super.init()
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         isConnected = keychainValue(for: accessTokenAccount) != nil ||
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             keychainValue(for: refreshTokenAccount) != nil
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     func configure(clientID: String) {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         UserDefaults.standard.set(clientID.trimmingCharacters(in: .whitespacesAndNewlines), forKey: clientIDKey)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     func configuredClientID() -> String? {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let stored = UserDefaults.standard.string(forKey: clientIDKey)?.trimmingCharacters(in: .whitespacesAndNewlines)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         if let stored, !stored.isEmpty {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             return stored
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         return Self.defaultClientID
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private static let defaultClientID = "745552657840-d8crrrb8ip7li95uvcc0i90mld9ettqf.apps.googleusercontent.com"
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     func connect() async throws {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         guard let clientID = configuredClientID() else { throw GmailToolError.notConfigured }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let verifier = Self.randomString(length: 64)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let challenge = Self.base64URL(Self.sha256(Data(verifier.utf8)))
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         var components = URLComponents(string: "https://accounts.google.com/o/oauth2/v2/auth")!
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         components.queryItems = [
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             URLQueryItem(name: "client_id", value: clientID),
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             URLQueryItem(name: "redirect_uri", value: redirectURI),
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             URLQueryItem(name: "response_type", value: "code"),
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             URLQueryItem(name: "scope", value: scope),
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             URLQueryItem(name: "access_type", value: "offline"),
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             URLQueryItem(name: "prompt", value: "consent"),
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             URLQueryItem(name: "code_challenge", value: challenge),
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             URLQueryItem(name: "code_challenge_method", value: "S256")
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         ]
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let callback = try await authenticate(url: components.url!)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         guard let code = URLComponents(url: callback, resolvingAgainstBaseURL: false)?
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             .queryItems?.first(where: { $0.name == "code" })?.value else {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             throw GmailToolError.authorizationFailed
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         try await exchangeCode(code, verifier: verifier, clientID: clientID)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         _ = try await fetchProfile()
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         isConnected = true
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     func disconnect() {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         deleteKeychainValue(for: accessTokenAccount)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         deleteKeychainValue(for: refreshTokenAccount)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         isConnected = false
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         accountEmail = nil
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     func inboxCount(query: String = "in:inbox") async throws -> Int {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let data = try await request(path: "/gmail/v1/users/me/messages", queryItems: [
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             URLQueryItem(name: "q", value: query),
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             URLQueryItem(name: "maxResults", value: "1")
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         ])
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let json = try jsonObject(data)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         return json["resultSizeEstimate"] as? Int ?? 0
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     func unreadCount() async throws -> Int {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         try await inboxCount(query: "in:inbox is:unread")
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     func recentMessages(query: String = "in:inbox", maxResults: Int = 10) async throws -> [GmailMessageSummary] {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let data = try await request(path: "/gmail/v1/users/me/messages", queryItems: [
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             URLQueryItem(name: "q", value: query),
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             URLQueryItem(name: "maxResults", value: String(min(maxResults, 25)))
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         ])
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let json = try jsonObject(data)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         guard let messages = json["messages"] as? [[String: Any]] else { return [] }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         return try await withThrowingTaskGroup(of: GmailMessageSummary?.self) { group in
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             for message in messages {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 if let id = message["id"] as? String {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     group.addTask { try await self.messageSummary(id: id) }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             var output: [GmailMessageSummary] = []
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             for try await item in group {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 if let item { output.append(item) }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             return output.sorted { ($0.date ?? .distantPast) > ($1.date ?? .distantPast) }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     func unreadMessages(maxResults: Int = 10) async throws -> [GmailMessageSummary] {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         try await recentMessages(query: "in:inbox is:unread", maxResults: maxResults)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private func messageSummary(id: String) async throws -> GmailMessageSummary? {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let data = try await request(path: "/gmail/v1/users/me/messages/\(id)", queryItems: [
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             URLQueryItem(name: "format", value: "metadata"),
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             URLQueryItem(name: "metadataHeaders", value: "From"),
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             URLQueryItem(name: "metadataHeaders", value: "Subject"),
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             URLQueryItem(name: "metadataHeaders", value: "Date")
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         ])
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let json = try jsonObject(data)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let payload = json["payload"] as? [String: Any]
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let headers = payload?["headers"] as? [[String: Any]] ?? []
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         func header(_ name: String) -> String {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             headers.first(where: { ($0["name"] as? String)?.caseInsensitiveCompare(name) == .orderedSame })?["value"] as? String ?? ""
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let labels = json["labelIds"] as? [String] ?? []
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         return GmailMessageSummary(
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             id: id,
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             threadID: json["threadId"] as? String ?? id,
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             sender: header("From"),
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             subject: header("Subject").isEmpty ? "(No subject)" : header("Subject"),
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             snippet: json["snippet"] as? String ?? "",
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             isUnread: labels.contains("UNREAD"),
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             date: Self.date(header("Date"))
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         )
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private func fetchProfile() async throws -> String {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let data = try await request(path: "/gmail/v1/users/me/profile")
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let json = try jsonObject(data)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let email = json["emailAddress"] as? String ?? ""
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         accountEmail = email.isEmpty ? nil : email
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         return email
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private func exchangeCode(_ code: String, verifier: String, clientID: String) async throws {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         var request = URLRequest(url: URL(string: "https://oauth2.googleapis.com/token")!)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         request.httpMethod = "POST"
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         var body = URLComponents()
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         body.queryItems = [
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             URLQueryItem(name: "client_id", value: clientID),
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             URLQueryItem(name: "code", value: code),
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             URLQueryItem(name: "code_verifier", value: verifier),
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             URLQueryItem(name: "grant_type", value: "authorization_code"),
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             URLQueryItem(name: "redirect_uri", value: redirectURI)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         ]
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         request.httpBody = body.percentEncodedQuery?.data(using: .utf8)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let (data, response) = try await URLSession.shared.data(for: request)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             throw GmailToolError.api("Google token exchange failed.")
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//               let token = json["access_token"] as? String else { throw GmailToolError.invalidResponse }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         saveKeychainValue(token, account: accessTokenAccount)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         if let refresh = json["refresh_token"] as? String {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             saveKeychainValue(refresh, account: refreshTokenAccount)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private func authenticate(url: URL) async throws -> URL {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         try await withCheckedThrowingContinuation { continuation in
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             let auth = ASWebAuthenticationSession(url: url, callbackURLScheme: "com.shayan.commandcentre") { callback, error in
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 if let error {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     let code = (error as NSError).code
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     continuation.resume(throwing: code == ASWebAuthenticationSessionError.canceledLogin.rawValue ? GmailToolError.cancelled : GmailToolError.authorizationFailed)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     return
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 guard let callback else {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     continuation.resume(throwing: GmailToolError.authorizationFailed)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                     return
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 continuation.resume(returning: callback)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             auth.presentationContextProvider = self
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             auth.prefersEphemeralWebBrowserSession = false
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             self.session = auth
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             guard auth.start() else {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 continuation.resume(throwing: GmailToolError.authorizationFailed)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 self.session = nil
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//                 return
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private func request(path: String, queryItems: [URLQueryItem] = []) async throws -> Data {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         guard let token = keychainValue(for: accessTokenAccount) else {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             guard let refresh = keychainValue(for: refreshTokenAccount) else { throw GmailToolError.tokenMissing }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             try await refreshAccessToken(refresh)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             guard let refreshed = keychainValue(for: accessTokenAccount) else { throw GmailToolError.tokenMissing }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             return try await requestWithToken(refreshed, path: path, queryItems: queryItems)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         return try await requestWithToken(token, path: path, queryItems: queryItems)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private func requestWithToken(_ token: String, path: String, queryItems: [URLQueryItem]) async throws -> Data {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         var components = URLComponents(string: "https://gmail.googleapis.com\(path)")!
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         components.queryItems = queryItems.isEmpty ? nil : queryItems
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         var request = URLRequest(url: components.url!)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         request.timeoutInterval = 20
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let (data, response) = try await URLSession.shared.data(for: request)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         guard let http = response as? HTTPURLResponse else { throw GmailToolError.invalidResponse }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         guard (200..<300).contains(http.statusCode) else {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             let message = (try? JSONSerialization.jsonObject(with: data) as? [String: Any])?["error"].flatMap { ($0 as? [String: Any])?["message"] as? String }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             throw GmailToolError.api(message ?? "Gmail API error (HTTP \(http.statusCode)).")
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         return data
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private func refreshAccessToken(_ refreshToken: String) async throws {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         guard let clientID = configuredClientID() else { throw GmailToolError.notConfigured }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         var request = URLRequest(url: URL(string: "https://oauth2.googleapis.com/token")!)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         request.httpMethod = "POST"
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         var body = URLComponents()
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         body.queryItems = [
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             URLQueryItem(name: "client_id", value: clientID),
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             URLQueryItem(name: "refresh_token", value: refreshToken),
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             URLQueryItem(name: "grant_type", value: "refresh_token")
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         ]
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         request.httpBody = body.percentEncodedQuery?.data(using: .utf8)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let (data, response) = try await URLSession.shared.data(for: request)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else { throw GmailToolError.tokenMissing }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//               let token = json["access_token"] as? String else { throw GmailToolError.invalidResponse }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         saveKeychainValue(token, account: accessTokenAccount)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private func jsonObject(_ data: Data) throws -> [String: Any] {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else { throw GmailToolError.invalidResponse }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         return json
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private static func date(_ value: String) -> Date? {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         guard !value.isEmpty else { return nil }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let formatter = DateFormatter()
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         formatter.locale = Locale(identifier: "en_US_POSIX")
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         return formatter.date(from: value)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private static func randomString(length: Int) -> String {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let chars = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         return String((0..<length).compactMap { _ in chars.randomElement() })
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private static func sha256(_ data: Data) -> Data { Data(SHA256.hash(data: data)) }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private static func base64URL(_ data: Data) -> String {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         data.base64EncodedString().replacingOccurrences(of: "+", with: "-").replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: "=", with: "")
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private func saveKeychainValue(_ value: String, account: String) {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let data = Data(value.utf8)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: keychainService, kSecAttrAccount as String: account]
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         SecItemDelete(query as CFDictionary)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let attributes: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: keychainService, kSecAttrAccount as String: account, kSecValueData as String: data, kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly]
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         SecItemAdd(attributes as CFDictionary, nil)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private func keychainValue(for account: String) -> String? {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: keychainService, kSecAttrAccount as String: account, kSecReturnData as String: true, kSecMatchLimit as String: kSecMatchLimitOne]
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         var item: CFTypeRef?
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess, let data = item as? Data else { return nil }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         return String(data: data, encoding: .utf8)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     private func deleteKeychainValue(for account: String) {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: keychainService, kSecAttrAccount as String: account]
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         SecItemDelete(query as CFDictionary)
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// extension GmailTool: ASWebAuthenticationPresentationContextProviding {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     nonisolated func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         DispatchQueue.main.sync {
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//             UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.flatMap { $0.windows }.first(where: { $0.isKeyWindow }) ?? ASPresentationAnchor()
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//         }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
//     }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// }
// DISABLED FOR NOW — AI/automation functionality paused. Original code retained for future reactivation.
// 