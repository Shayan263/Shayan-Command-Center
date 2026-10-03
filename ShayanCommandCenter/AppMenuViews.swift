import SwiftUI
import UIKit

struct ImportantLinksView: View {
    let openExternal: (URL) -> Void
    private let links: [(String, String, String, String)] = [
        ("My Website", "Public portfolio & profile", "globe", "https://shayan263.github.io/Shayan_Profile/"),
        ("Admin Dashboard", "Private portfolio analytics", "chart.xyaxis.line", "https://shayan263.github.io/Shayan_Profile/admin.html"),
        ("LinkedIn", "Professional profile", "person.crop.circle", "https://www.linkedin.com/"),
        ("GitHub", "Code and projects", "chevron.left.forwardslash.chevron.right", "https://github.com/Shayan263")
    ]

    var body: some View {
        List {
            Section("Important Links") {
                ForEach(links, id: \.0) { link in
                    Button {
                        guard let url = URL(string: link.3), url.scheme == "https" else { return }
                        openExternal(url)
                    } label: {
                        Label {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(link.0).font(.body.weight(.semibold))
                                Text(link.1).font(.caption).foregroundStyle(.secondary)
                            }
                        } icon: { Image(systemName: link.2).frame(width: 24) }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationTitle("Important Links")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct QuickActionsView: View {
    @State private var copied = false
    private let portfolioURL = URL(string: "https://shayan263.github.io/Shayan_Profile/")!

    var body: some View {
        List {
            Section("Open") {
                QuickActionRow(title: "My Website", subtitle: "Open your public portfolio", icon: "globe", url: portfolioURL)
                QuickActionRow(title: "Admin Dashboard", subtitle: "Open private portfolio analytics", icon: "chart.xyaxis.line", url: URL(string: "https://shayan263.github.io/Shayan_Profile/admin.html")!)
                QuickActionRow(title: "GitHub", subtitle: "Open your repositories", icon: "chevron.left.forwardslash.chevron.right", url: URL(string: "https://github.com/Shayan263")!)
                QuickActionRow(title: "LinkedIn", subtitle: "Open your professional profile", icon: "person.crop.circle", url: URL(string: "https://www.linkedin.com/")!)
            }
            Section("Share & Copy") {
                Button {
                    UIPasteboard.general.string = portfolioURL.absoluteString
                    copied = true
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    Label(copied ? "Portfolio URL Copied" : "Copy Portfolio URL", systemImage: copied ? "checkmark" : "doc.on.doc")
                }
                ShareLink(item: portfolioURL) {
                    Label("Share Portfolio", systemImage: "square.and.arrow.up")
                }
            }
        }
        .navigationTitle("Quick Actions")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct QuickActionRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let url: URL
    @Environment(\.openURL) private var openURL

    var body: some View {
        Button {
            guard url.scheme == "https" else { return }
            openURL(url)
        } label: {
            Label {
                VStack(alignment: .leading, spacing: 3) {
                    Text(title).font(.body.weight(.semibold))
                    Text(subtitle).font(.caption).foregroundStyle(.secondary)
                }
            } icon: { Image(systemName: icon).frame(width: 24) }
        }
        .buttonStyle(.plain)
    }
}

struct InsightsView: View {
    @StateObject private var status = DashboardStatus()

    var body: some View {
        List {
            Section("System Status") {
                HStack {
                    Label("Portfolio Dashboard", systemImage: "chart.xyaxis.line")
                    Spacer()
                    StatusPill(isOnline: status.isOnline)
                }
                HStack {
                    Text("Last checked")
                    Spacer()
                    Text(status.lastCheckedText).foregroundStyle(.secondary)
                }
            }
            Section("Portfolio") {
                InsightRow(title: "Public website", value: "Available", icon: "globe")
                InsightRow(title: "Professional profile", value: "LinkedIn", icon: "person.crop.circle")
                InsightRow(title: "Code & projects", value: "GitHub", icon: "chevron.left.forwardslash.chevron.right")
            }
            Section("Next") {
                Text("GitHub activity, project metrics and deeper portfolio insights can be added here without changing Home.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Insights")
        .navigationBarTitleDisplayMode(.inline)
        .task { await status.check() }
        .refreshable { await status.check() }
    }
}

private struct InsightRow: View {
    let title: String
    let value: String
    let icon: String
    var body: some View {
        HStack {
            Label(title, systemImage: icon)
            Spacer()
            Text(value).foregroundStyle(.secondary)
        }
    }
}

struct SettingsView: View {
    @AppStorage("darkModeEnabled") private var darkModeEnabled = true
    @AppStorage("appLockEnabled") private var appLockEnabled = false

    var body: some View {
        Form {
            Section("Appearance") {
                Toggle(isOn: $darkModeEnabled) {
                    Label("Dark interface", systemImage: "moon.fill")
                }.disabled(true)
                Text("Shayan Core currently uses its dark visual system. Theme selection can be expanded later.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            Section("Security") {
                Toggle(isOn: $appLockEnabled) {
                    Label("Require Face ID / passcode", systemImage: "faceid")
                }
                Label("Secure notes use Keychain storage", systemImage: "lock.shield")
                    .foregroundStyle(.secondary)
                Text("App authentication uses iOS Local Authentication. Sensitive notes are stored in the Keychain rather than UserDefaults.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            Section("Privacy & Network") {
                Label("HTTPS-only external links", systemImage: "lock.shield")
                Label("No passwords, tokens or credentials hard-coded", systemImage: "checkmark.shield")
            }
            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Build")
                    Spacer()
                    Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1")
                        .foregroundStyle(.secondary)
                }
                Text("Shayan Core").foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PlainTextView: View {
    @State private var text = ""
    @State private var showClearConfirmation = false
    @State private var showSaveError = false

    var body: some View {
        TextEditor(text: $text)
            .font(.body.monospaced())
            .padding(.horizontal, 8)
            .navigationTitle("Protected Notes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    ShareLink(item: text) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .accessibilityLabel("Share note")
                    Button("Clear") { showClearConfirmation = true }
                        .disabled(text.isEmpty)
                }
            }
            .task {
                text = SecureNotesStore.load()
            }
            .onChange(of: text) { _, newValue in
                do {
                    try SecureNotesStore.save(newValue)
                } catch {
                    showSaveError = true
                }
            }
            .alert("Could not save note", isPresented: $showSaveError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("The secure note could not be written to the iPhone Keychain.")
            }
            .confirmationDialog("Clear this note?", isPresented: $showClearConfirmation) {
                Button("Clear", role: .destructive) {
                    text = ""
                    try? SecureNotesStore.delete()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will remove the protected note from this device.")
            }
    }
}

struct AppLockView: View {
    let onUnlock: () -> Void
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            Color(red: 0.025, green: 0.035, blue: 0.07).ignoresSafeArea()
            VStack(spacing: 22) {
                Image(systemName: "lock.shield.fill").font(.system(size: 54)).foregroundStyle(.blue)
                Text("Shayan Core Locked").font(.title.bold())
                Text("Authenticate to continue.").foregroundStyle(.secondary)
                Button { Task { await authenticate() } } label: {
                    Label("Unlock", systemImage: "faceid")
                        .font(.headline).frame(maxWidth: .infinity).padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal, 30)
                if let errorMessage {
                    Text(errorMessage).font(.footnote).foregroundStyle(.secondary)
                        .multilineTextAlignment(.center).padding(.horizontal, 24)
                }
            }
            .padding(24)
        }
        .task { await authenticate() }
    }

    private func authenticate() async {
        do {
            try await AppSecurity.authenticate()
            onUnlock()
        } catch {
            errorMessage = "Authentication was not completed. You can try again."
        }
    }
}

    
struct ResumeBuilderPreviewView: View {
    var body: some View {
        UpcomingFeatureView(icon: "doc.text.magnifyingglass", eyebrow: "UPCOMING MODULE", title: "Shayan Resume Builder",
            description: "A native resume workspace for building, tailoring and managing role-specific resumes.",
            roadmap: ["Profile & experience library", "ATS-friendly resume builder", "Role-specific tailoring", "Resume versions & history", "Export-ready resume documents"])
    }
}

struct LearningHubPreviewView: View {
    var body: some View {
        UpcomingFeatureView(icon: "graduationcap.fill", eyebrow: "UPCOMING MODULE", title: "Shayan Learning Hub",
            description: "A personal learning system for structured study, SAP growth and long-term skill development.",
            roadmap: ["Learning paths & goals", "SAP ABAP / S4HANA tracks", "BTP, CAP & cloud learning", "Progress & completion tracking", "Notes, resources & revision"])
    }
}

private struct UpcomingFeatureView: View {
    let icon: String
    let eyebrow: String
    let title: String
    let description: String
    let roadmap: [String]
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    Image(systemName: icon).font(.system(size: 34, weight: .semibold)).foregroundStyle(.blue)
                        .frame(width: 68, height: 68).background(.blue.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    Text(eyebrow).font(.caption.weight(.bold)).tracking(1.4).foregroundStyle(.blue)
                    Text(title).font(.largeTitle.bold())
                    Text(description).font(.body).foregroundStyle(.secondary)
                }
                VStack(alignment: .leading, spacing: 14) {
                    Text("PLANNED CAPABILITIES").font(.caption.weight(.bold)).tracking(1.2).foregroundStyle(.secondary)
                    ForEach(roadmap, id: \.self) { item in
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle").foregroundStyle(.blue)
                            Text(item).font(.subheadline)
                            Spacer()
                        }.padding(.vertical, 4)
                    }
                }
                .padding(18).background(.white.opacity(0.045))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(.white.opacity(0.07), lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                Text("This is a preview. The module will be built into Shayan Core as the platform expands.")
                    .font(.footnote).foregroundStyle(.secondary)
            }.padding(20)
        }
        .background(Color(red: 0.025, green: 0.035, blue: 0.07))
        .navigationTitle(title).navigationBarTitleDisplayMode(.inline)
    }
}
