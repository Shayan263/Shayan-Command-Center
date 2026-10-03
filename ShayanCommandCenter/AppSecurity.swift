import Foundation
import LocalAuthentication
import Security

enum AppSecurity {
    static func authenticate() async throws {
        let context = LAContext()
        context.localizedCancelTitle = "Cancel"

        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            throw map(error)
        }

        let success = try await context.evaluatePolicy(
            .deviceOwnerAuthentication,
            localizedReason: "Unlock access to your protected Shayan Core data."
        )

        guard success else {
            throw AppSecurityError.failed
        }
    }

    static func biometricType() -> LABiometryType {
        let context = LAContext()
        var error: NSError?
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        return context.biometryType
    }

    private static func map(_ error: NSError?) -> AppSecurityError {
        guard let error else { return .unavailable }
        switch LAError.Code(rawValue: error.code) {
        case .biometryNotEnrolled:
            return .biometryNotEnrolled
        case .biometryNotAvailable:
            return .biometryUnavailable
        case .biometryLockout:
            return .biometryLockedOut
        case .passcodeNotSet:
            return .passcodeNotSet
        default:
            return .authentication(error.localizedDescription)
        }
    }
}

enum SecureNotesStore {
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
    case unavailable
    case failed
    case biometryNotEnrolled
    case biometryUnavailable
    case biometryLockedOut
    case passcodeNotSet
    case authentication(String)
    case keychain(OSStatus)
}
