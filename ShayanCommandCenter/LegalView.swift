import SwiftUI

struct LegalView: View {
    var body: some View {
        List {
            Section("Legal") {
                NavigationLink("Privacy Policy") { LegalDocumentView(title: "Privacy Policy", text: LegalContent.privacyPolicy) }
                NavigationLink("Terms and Conditions") { LegalDocumentView(title: "Terms and Conditions", text: LegalContent.terms) }
                NavigationLink("Cookie Policy") { LegalDocumentView(title: "Cookie Policy", text: LegalContent.cookies) }
            }
            Section("Consent") {
                NavigationLink("Privacy Consent") { PrivacyConsentView() }
                Text("Shayan Core currently does not collect personal data through a native form or use advertising/tracking pixels. Consent is required before a future feature collects or uses personal data.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Section("Review") {
                Text("These policies are app implementation templates and should be reviewed and finalized for the jurisdictions and services used by the app before production use.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Legal & Privacy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct LegalDocumentView: View {
    let title: String
    let text: String
    var body: some View {
        ScrollView {
            Text(text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

enum PrivacyConsentStore {
    private static let key = "privacyConsentGranted"
    static var isGranted: Bool { UserDefaults.standard.bool(forKey: key) }
    static func grant() { UserDefaults.standard.set(true, forKey: key) }
    static func revoke() { UserDefaults.standard.set(false, forKey: key) }
}

struct PrivacyConsentView: View {
    @State private var granted = PrivacyConsentStore.isGranted
    var body: some View {
        Form {
            Section("Personal Data Consent") {
                Text("When Shayan Core introduces a feature that collects or uses your personal data, it must explain what is collected, why it is needed, and how it is used before collection begins.")
                Toggle("I consent to the collection and use described by the applicable form and Privacy Policy", isOn: Binding(
                    get: { granted },
                    set: { newValue in
                        granted = newValue
                        if newValue { PrivacyConsentStore.grant() } else { PrivacyConsentStore.revoke() }
                    }
                ))
            }
            Section("Current Status") {
                Label(granted ? "Consent recorded" : "No consent recorded", systemImage: granted ? "checkmark.shield.fill" : "shield.slash")
            }
        }
        .navigationTitle("Privacy Consent")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// Use this gate before any future form collects personal data.
struct PersonalDataConsentGate<Content: View>: View {
    let content: Content
    @State private var consentGranted = PrivacyConsentStore.isGranted
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        if consentGranted {
            content
        } else {
            PrivacyConsentView()
        }
    }
}

enum LegalContent {
    static let privacyPolicy = """
    PRIVACY POLICY

    Shayan Core should collect only the personal information necessary to provide a requested feature. The app should explain the purpose of collection before collection begins and use information only for that stated purpose.

    Sensitive local information is protected using platform security controls such as the iOS Keychain. Personal data should not be placed in logs, analytics, or tracking systems unless explicitly disclosed and required.

    If a future feature sends information to a server or third party, the app must disclose the recipient, purpose, retention, and applicable user choices before collection.

    Users should be provided with appropriate access, correction, deletion, and consent-withdrawal mechanisms where applicable.
    """

    static let terms = """
    TERMS AND CONDITIONS

    Shayan Core is a personal productivity and command-center application. You agree to use the app lawfully and not to misuse, reverse engineer, attack, or attempt unauthorized access to the app or its connected services.

    External websites and services are governed by their own terms. Shayan Core does not guarantee the availability or accuracy of third-party services.

    Features may change, be suspended, or be removed as the application evolves.

    These terms are an implementation template and require legal review before being treated as final legal terms.
    """

    static let cookies = """
    COOKIE POLICY

    The native Shayan Core iOS app does not currently set or use browser cookies for advertising or tracking.

    If a future web feature introduces non-essential cookies, advertising technology, or tracking pixels, the feature must assess whether consent is required in the applicable jurisdiction and obtain consent before activating non-essential tracking where required.

    Essential technical storage may be used where necessary for a requested service and permitted by applicable law.
    """
}
