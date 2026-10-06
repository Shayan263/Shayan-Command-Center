import Foundation

/// Runtime security rules used by Shayan Core for sensitive data and external links.
enum SecurityPolicy {
    static let protectedNotesUseBiometrics = true
    static let allowHTTPExternalLinks = false
    static let logSensitiveData = false

    static func isAllowedExternalURL(_ url: URL) -> Bool {
        url.scheme?.lowercased() == "https"
    }

    static func sanitizedUserInput(_ value: String, maxLength: Int = 10_000) -> String {
        String(value.trimmingCharacters(in: .whitespacesAndNewlines).prefix(maxLength))
    }
}
