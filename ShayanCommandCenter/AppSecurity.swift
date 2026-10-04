import Foundation
import Security

enum SecureNotesStore {
    static func loadAsync() async -> String {
        await Task.detached(priority: .utility) {
            load()
        }.value
    }

    static func saveAsync(_ text: String) async throws {
        try await Task.detached(priority: .utility) {
            try save(text)
        }.value
    }

    static func deleteAsync() async throws {
        try await Task.detached(priority: .utility) {
            try delete()
        }.value
    }

    private static let service = "com.shayan.commandcentre.secure-notes"
    private static let account = "plain-text-notes"

    static func load() -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else { return "" }
        return String(data: data, encoding: .utf8) ?? ""
    }

    static func save(_ text: String) throws {
        let data = Data(text.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if updateStatus == errSecItemNotFound {
            var addQuery = query
            addQuery.merge(attributes) { _, new in new }
            let status = SecItemAdd(addQuery as CFDictionary, nil)
            guard status == errSecSuccess else { throw AppSecurityError.keychain(status) }
        } else if updateStatus != errSecSuccess {
            throw AppSecurityError.keychain(updateStatus)
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
            throw AppSecurityError.keychain(status)
        }
    }
}

enum AppSecurityError: Error {
    case keychain(OSStatus)
}
