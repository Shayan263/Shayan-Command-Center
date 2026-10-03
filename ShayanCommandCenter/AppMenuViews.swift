import SwiftUI

struct ImportantLinksView: View {
    let openExternal: (URL) -> Void

    private let links: [(String, String, String, String)] = [
        ("My Website", "Public portfolio & profile", "globe", "https://shayan263.github.io/Shayan_Profile/"),
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
                                Text(link.0)
                                    .font(.body.weight(.semibold))
                                Text(link.1)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: link.2)
                                .frame(width: 24)
                        }
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
    var body: some View {
        List {
            Section("Quick Actions") {
                Text("Quick actions will live here as they are added.")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Quick Actions")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InsightsView: View {
    var body: some View {
        List {
            Section("Insights") {
                Label("Portfolio insights", systemImage: "chart.xyaxis.line")
                Label("Project activity", systemImage: "square.stack.3d.up")
                Label("Career insights", systemImage: "briefcase")
            }

            Section {
                Text("Insight modules will be added here without cluttering Home.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Insights")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SettingsView: View {
    var body: some View {
        Form {
            Section("Appearance") {
                Label("Dark interface", systemImage: "moon.fill")
            }

            Section("Security") {
                Label("HTTPS-only external links", systemImage: "lock.shield")
                    .foregroundStyle(.secondary)
            }

            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0")
                        .foregroundStyle(.secondary)
                }

                Text("Shayan Command Centre")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}
