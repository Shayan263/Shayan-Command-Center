import Foundation
import LocalAuthentication

enum AppSecurity {
    static func authenticate() async throws {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            throw error ?? AppSecurityError.unavailable
        }

        let success = try await context.evaluatePolicy(
            .deviceOwnerAuthentication,
            localizedReason: "Unlock your Command Centre"
        )

        guard success else {
            throw AppSecurityError.failed
        }
    }
}

enum AppSecurityError: Error {
    case unavailable
    case failed
}
