import Foundation
import LocalAuthentication
import Security

enum AppSecurity {
    static func authenticate() async throws {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            throw error ?? AppSecurityError.unavailable
        }

        let success = try await context.evaluatePolicy(
            .deviceOwnerAuthentication,
            localizedReason: "Unlock your Shayan Core"
        )

        guard success else {
            throw AppSecurityError.failed
        }
    }
}

enum SecureNotesStore {
    private static let service = "com.shayan.commandcentre.secure-notes"
    private static let account = "plain-text-notes"

    static func load() -> String {
        var query: [String: Any] = [
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
    case unavailable
    case failed
    case keychain(OSStatus)
}
