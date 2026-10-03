import SwiftUI

struct HomeView: View {
    @Environment(\.openURL) private var openURL
    @StateObject private var status = DashboardStatus()
    private let dashboardURL = URL(string: "https://shayan263.github.io/Shayan_Profile/admin.html")!

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.025, green: 0.035, blue: 0.07).ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("SHAYAN CORE")
                                .font(.caption).fontWeight(.bold).tracking(1.5)
                                .foregroundStyle(.blue)
                            Text("Good evening, Shayan 👋")
                                .font(.largeTitle.bold())
                            Text("Your personal digital core")
                                .foregroundStyle(.secondary)
                        }

                        CommandPulse(status: status)

                        DashboardCard(status: status) {
                            openURL(dashboardURL)
                        }

                        WebsiteCard {
                            openURL(URL(string: "https://shayan263.github.io/Shayan_Profile/")!)
                        }

                        Text("Use ••• for links, actions, insights, notes and settings.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                    }
                    .padding(20)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        NavigationLink {
                            ImportantLinksView(openExternal: { url in openURL(url) })
                        } label: {
                            Label("Important Links", systemImage: "link")
                        }
                        NavigationLink { QuickActionsView() } label: {
                            Label("Quick Actions", systemImage: "bolt.fill")
                        }
                        NavigationLink { InsightsView() } label: {
                            Label("Insights", systemImage: "chart.bar.xaxis")
                        }
                        NavigationLink { PlainTextView() } label: {
                            Label("Protected Notes", systemImage: "lock.text")
                        }
                        Divider()
                        NavigationLink { SettingsView() } label: {
                            Label("Settings", systemImage: "gearshape")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.title3.weight(.semibold))
                            .frame(minWidth: 36, minHeight: 36)
                    }
                    .accessibilityLabel("More options")
                }
            }
            .task { await status.check() }
            .refreshable { await status.check() }
        }
    }
}

struct CommandPulse: View {
    @ObservedObject var status: DashboardStatus

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(status.isOnline ? Color.green : Color.red)
                .frame(width: 10, height: 10)
                .shadow(color: (status.isOnline ? Color.green : Color.red).opacity(0.7), radius: 5)

            VStack(alignment: .leading, spacing: 2) {
                Text(status.isOnline ? "Everything looks good" : "Attention required")
                    .font(.subheadline.weight(.semibold))
                Text(status.isOnline ? "Portfolio systems are online" : "Portfolio dashboard is unavailable")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(status.isOnline ? "1/1 ONLINE" : "0/1 ONLINE")
                .font(.caption2.bold())
                .foregroundStyle(status.isOnline ? .green : .red)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 13)
        .background(.white.opacity(0.045))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.07), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct DashboardCard: View {
    @ObservedObject var status: DashboardStatus
    let onDetails: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Image(systemName: "chart.xyaxis.line")
                    .font(.title2).foregroundStyle(.blue)
                    .frame(width: 44, height: 44)
                    .background(.blue.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: 13))
                VStack(alignment: .leading, spacing: 3) {
                    Text("Portfolio Dashboard").font(.headline)
                    Text("Private analytics").font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                StatusPill(isOnline: status.isOnline)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(status.isOnline ? "Dashboard is live" : "Dashboard unavailable")
                    .font(.title3.bold())
                HStack(spacing: 8) {
                    Circle().fill(status.isOnline ? Color.green : Color.red).frame(width: 8, height: 8)
                    Text(status.isOnline ? "Online" : "Offline").font(.subheadline.weight(.semibold))
                    Text("•").foregroundStyle(.secondary)
                    Text(status.lastCheckedText).font(.caption).foregroundStyle(.secondary)
                }
            }

            Button(action: onDetails) {
                HStack {
                    Text("View Details").fontWeight(.semibold)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                }
                .padding(.horizontal, 16).padding(.vertical, 13)
                .background(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 13))
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .background(.white.opacity(0.055))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(.white.opacity(0.09), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

struct WebsiteCard: View {
    let onOpen: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Image(systemName: "globe")
                    .font(.title2).foregroundStyle(.blue)
                    .frame(width: 44, height: 44)
                    .background(.blue.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: 13))
                VStack(alignment: .leading, spacing: 3) {
                    Text("My Website").font(.headline)
                    Text("Public portfolio & profile").font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
            }
            Text("Open your public website and portfolio.").font(.title3.bold())
            Button(action: onOpen) {
                HStack {
                    Text("Visit Website").fontWeight(.semibold)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                }
                .padding(.horizontal, 16).padding(.vertical, 13)
                .background(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 13))
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .background(.white.opacity(0.055))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(.white.opacity(0.09), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

struct StatusPill: View {
    let isOnline: Bool

    var body: some View {
        HStack(spacing: 6) {
            Circle().fill(isOnline ? Color.green : Color.red).frame(width: 7, height: 7)
            Text(isOnline ? "LIVE" : "OFFLINE").font(.caption2.bold()).tracking(0.8)
        }
        .padding(.horizontal, 10).padding(.vertical, 7)
        .background((isOnline ? Color.green : Color.red).opacity(0.10))
        .foregroundStyle(isOnline ? .green : .red)
        .clipShape(Capsule())
    }
}
