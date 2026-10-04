import Foundation
import AuthenticationServices
import Security
import UIKit
import CryptoKit

struct GmailMessageSummary: Identifiable, Sendable {
    let id: String
    let threadID: String
    let sender: String
    let subject: String
    let snippet: String
    let isUnread: Bool
    let date: Date?
}

enum GmailToolError: LocalizedError {
    case notConfigured, cancelled, authorizationFailed, invalidResponse, tokenMissing
    case api(String)

    var errorDescription: String? {
        switch self {
        case .notConfigured: return "Gmail is not configured. Add your Google OAuth iOS client ID."
        case .cancelled: return "Google authorization was cancelled."
        case .authorizationFailed: return "Google authorization failed."
        case .invalidResponse: return "Gmail returned an invalid response."
        case .tokenMissing: return "Gmail authorization expired. Connect Gmail again."
        case .api(let message): return message
        }
    }
}

@MainActor
final class GmailTool: NSObject, ObservableObject {
    static let shared = GmailTool()

    @Published private(set) var isConnected = false
    @Published private(set) var accountEmail: String?

    private let clientIDKey = "shayan.gmail.oauth.clientID"
    private let keychainService = "com.shayan.commandcentre.gmail"
    private let accessTokenAccount = "access-token"
    private let refreshTokenAccount = "refresh-token"
    private let redirectURI = "com.shayan.commandcentre:/oauth2redirect/google"
    private let scope = "https://www.googleapis.com/auth/gmail.readonly"
    private var session: ASWebAuthenticationSession?

    override init() {
        super.init()
        isConnected = keychainValue(for: accessTokenAccount) != nil ||
            keychainValue(for: refreshTokenAccount) != nil
    }

    func configure(clientID: String) {
        UserDefaults.standard.set(clientID.trimmingCharacters(in: .whitespacesAndNewlines), forKey: clientIDKey)
    }

    func configuredClientID() -> String? {
        let stored = UserDefaults.standard.string(forKey: clientIDKey)?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let stored, !stored.isEmpty {
            return stored
        }
        return Self.defaultClientID
    }

    private static let defaultClientID = "745552657840-d8crrrb8ip7li95uvcc0i90mld9ettqf.apps.googleusercontent.com"

    func connect() async throws {
        guard let clientID = configuredClientID() else { throw GmailToolError.notConfigured }

        let verifier = Self.randomString(length: 64)
        let challenge = Self.base64URL(Self.sha256(Data(verifier.utf8)))
        var components = URLComponents(string: "https://accounts.google.com/o/oauth2/v2/auth")!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: scope),
            URLQueryItem(name: "access_type", value: "offline"),
            URLQueryItem(name: "prompt", value: "consent"),
            URLQueryItem(name: "code_challenge", value: challenge),
            URLQueryItem(name: "code_challenge_method", value: "S256")
        ]

        let callback = try await authenticate(url: components.url!)
        guard let code = URLComponents(url: callback, resolvingAgainstBaseURL: false)?
            .queryItems?.first(where: { $0.name == "code" })?.value else {
            throw GmailToolError.authorizationFailed
        }

        try await exchangeCode(code, verifier: verifier, clientID: clientID)
        _ = try await fetchProfile()
        isConnected = true
    }

    func disconnect() {
        deleteKeychainValue(for: accessTokenAccount)
        deleteKeychainValue(for: refreshTokenAccount)
        isConnected = false
        accountEmail = nil
    }

    func inboxCount(query: String = "in:inbox") async throws -> Int {
        let data = try await request(path: "/gmail/v1/users/me/messages", queryItems: [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "maxResults", value: "1")
        ])
        let json = try jsonObject(data)
        return json["resultSizeEstimate"] as? Int ?? 0
    }

    func unreadCount() async throws -> Int {
        try await inboxCount(query: "in:inbox is:unread")
    }

    func recentMessages(query: String = "in:inbox", maxResults: Int = 10) async throws -> [GmailMessageSummary] {
        let data = try await request(path: "/gmail/v1/users/me/messages", queryItems: [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "maxResults", value: String(min(maxResults, 25)))
        ])
        let json = try jsonObject(data)
        guard let messages = json["messages"] as? [[String: Any]] else { return [] }

        return try await withThrowingTaskGroup(of: GmailMessageSummary?.self) { group in
            for message in messages {
                if let id = message["id"] as? String {
                    group.addTask { try await self.messageSummary(id: id) }
                }
            }
            var output: [GmailMessageSummary] = []
            for try await item in group {
                if let item { output.append(item) }
            }
            return output.sorted { ($0.date ?? .distantPast) > ($1.date ?? .distantPast) }
        }
    }

    func unreadMessages(maxResults: Int = 10) async throws -> [GmailMessageSummary] {
        try await recentMessages(query: "in:inbox is:unread", maxResults: maxResults)
    }

    private func messageSummary(id: String) async throws -> GmailMessageSummary? {
        let data = try await request(path: "/gmail/v1/users/me/messages/\(id)", queryItems: [
            URLQueryItem(name: "format", value: "metadata"),
            URLQueryItem(name: "metadataHeaders", value: "From"),
            URLQueryItem(name: "metadataHeaders", value: "Subject"),
            URLQueryItem(name: "metadataHeaders", value: "Date")
        ])
        let json = try jsonObject(data)
        let payload = json["payload"] as? [String: Any]
        let headers = payload?["headers"] as? [[String: Any]] ?? []
        func header(_ name: String) -> String {
            headers.first(where: { ($0["name"] as? String)?.caseInsensitiveCompare(name) == .orderedSame })?["value"] as? String ?? ""
        }
        let labels = json["labelIds"] as? [String] ?? []
        return GmailMessageSummary(
            id: id,
            threadID: json["threadId"] as? String ?? id,
            sender: header("From"),
            subject: header("Subject").isEmpty ? "(No subject)" : header("Subject"),
            snippet: json["snippet"] as? String ?? "",
            isUnread: labels.contains("UNREAD"),
            date: Self.date(header("Date"))
        )
    }

    private func fetchProfile() async throws -> String {
        let data = try await request(path: "/gmail/v1/users/me/profile")
        let json = try jsonObject(data)
        let email = json["emailAddress"] as? String ?? ""
        accountEmail = email.isEmpty ? nil : email
        return email
    }

    private func exchangeCode(_ code: String, verifier: String, clientID: String) async throws {
        var request = URLRequest(url: URL(string: "https://oauth2.googleapis.com/token")!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        var body = URLComponents()
        body.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "code_verifier", value: verifier),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "redirect_uri", value: redirectURI)
        ]
        request.httpBody = body.percentEncodedQuery?.data(using: .utf8)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw GmailToolError.api("Google token exchange failed.")
        }
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let token = json["access_token"] as? String else { throw GmailToolError.invalidResponse }
        saveKeychainValue(token, account: accessTokenAccount)
        if let refresh = json["refresh_token"] as? String {
            saveKeychainValue(refresh, account: refreshTokenAccount)
        }
    }

    private func authenticate(url: URL) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            let auth = ASWebAuthenticationSession(url: url, callbackURLScheme: "com.shayan.commandcentre") { callback, error in
                if let error {
                    let code = (error as NSError).code
                    continuation.resume(throwing: code == ASWebAuthenticationSessionError.canceledLogin.rawValue ? GmailToolError.cancelled : GmailToolError.authorizationFailed)
                    return
                }
                guard let callback else {
                    continuation.resume(throwing: GmailToolError.authorizationFailed)
                    return
                }
                continuation.resume(returning: callback)
            }
            auth.presentationContextProvider = self
            auth.prefersEphemeralWebBrowserSession = false
            self.session = auth
            guard auth.start() else {
                continuation.resume(throwing: GmailToolError.authorizationFailed)
                self.session = nil
                return
            }
        }
    }

    private func request(path: String, queryItems: [URLQueryItem] = []) async throws -> Data {
        guard let token = keychainValue(for: accessTokenAccount) else {
            guard let refresh = keychainValue(for: refreshTokenAccount) else { throw GmailToolError.tokenMissing }
            try await refreshAccessToken(refresh)
            guard let refreshed = keychainValue(for: accessTokenAccount) else { throw GmailToolError.tokenMissing }
            return try await requestWithToken(refreshed, path: path, queryItems: queryItems)
        }
        return try await requestWithToken(token, path: path, queryItems: queryItems)
    }

    private func requestWithToken(_ token: String, path: String, queryItems: [URLQueryItem]) async throws -> Data {
        var components = URLComponents(string: "https://gmail.googleapis.com\(path)")!
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        var request = URLRequest(url: components.url!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 20
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw GmailToolError.invalidResponse }
        guard (200..<300).contains(http.statusCode) else {
            let message = (try? JSONSerialization.jsonObject(with: data) as? [String: Any])?["error"].flatMap { ($0 as? [String: Any])?["message"] as? String }
            throw GmailToolError.api(message ?? "Gmail API error (HTTP \(http.statusCode)).")
        }
        return data
    }

    private func refreshAccessToken(_ refreshToken: String) async throws {
        guard let clientID = configuredClientID() else { throw GmailToolError.notConfigured }
        var request = URLRequest(url: URL(string: "https://oauth2.googleapis.com/token")!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        var body = URLComponents()
        body.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "refresh_token", value: refreshToken),
            URLQueryItem(name: "grant_type", value: "refresh_token")
        ]
        request.httpBody = body.percentEncodedQuery?.data(using: .utf8)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else { throw GmailToolError.tokenMissing }
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let token = json["access_token"] as? String else { throw GmailToolError.invalidResponse }
        saveKeychainValue(token, account: accessTokenAccount)
    }

    private func jsonObject(_ data: Data) throws -> [String: Any] {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else { throw GmailToolError.invalidResponse }
        return json
    }

    private static func date(_ value: String) -> Date? {
        guard !value.isEmpty else { return nil }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        return formatter.date(from: value)
    }

    private static func randomString(length: Int) -> String {
        let chars = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        return String((0..<length).compactMap { _ in chars.randomElement() })
    }

    private static func sha256(_ data: Data) -> Data { Data(SHA256.hash(data: data)) }

    private static func base64URL(_ data: Data) -> String {
        data.base64EncodedString().replacingOccurrences(of: "+", with: "-").replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: "=", with: "")
    }

    private func saveKeychainValue(_ value: String, account: String) {
        let data = Data(value.utf8)
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: keychainService, kSecAttrAccount as String: account]
        SecItemDelete(query as CFDictionary)
        let attributes: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: keychainService, kSecAttrAccount as String: account, kSecValueData as String: data, kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly]
        SecItemAdd(attributes as CFDictionary, nil)
    }

    private func keychainValue(for account: String) -> String? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: keychainService, kSecAttrAccount as String: account, kSecReturnData as String: true, kSecMatchLimit as String: kSecMatchLimitOne]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess, let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func deleteKeychainValue(for account: String) {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: keychainService, kSecAttrAccount as String: account]
        SecItemDelete(query as CFDictionary)
    }
}

extension GmailTool: ASWebAuthenticationPresentationContextProviding {
    nonisolated func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        DispatchQueue.main.sync {
            UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.flatMap { $0.windows }.first(where: { $0.isKeyWindow }) ?? ASPresentationAnchor()
        }
    }
}
