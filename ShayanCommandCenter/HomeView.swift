import SwiftUI

struct HomeView: View {
    @Environment(\.openURL) private var openURL
    @StateObject private var status = DashboardStatus()
    @StateObject private var reminderStore = ReminderStore()
    @State private var showSideMenu = false
    @State private var navigationPath: [CoreDestination] = []
    private let dashboardURL = URL(string: "https://shayan263.github.io/Shayan_Profile/admin.html")!

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack(alignment: .leading) {
                Color(red: 0.025, green: 0.035, blue: 0.07).ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        HStack(spacing: 14) {
                            ShayanCoreMark(size: 54)

                            VStack(alignment: .leading, spacing: 5) {
                                Text("SHAYAN CORE")
                                    .font(.caption).fontWeight(.bold).tracking(1.5)
                                    .foregroundStyle(.blue)
                                Text("Good evening, Shayan 👋")
                                    .font(.largeTitle.bold())
                                    .minimumScaleFactor(0.8)
                                Text("Your personal digital core")
                                    .foregroundStyle(.secondary)
                            }
                        }

                        CommandPulse(status: status)

                        CoreOverviewCard(reminderStore: reminderStore, navigationPath: $navigationPath)

                        DashboardCard(status: status) {
                            openURL(dashboardURL)
                        }

                        WebsiteCard {
                            openURL(URL(string: "https://shayan263.github.io/Shayan_Profile/")!)
                        }

                        UpcomingModulesSection()

                        Text("Tap ••• for the sidebar or 🔍 for Core Command.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                    }
                    .padding(20)
                }

                if showSideMenu {
                    Color.black.opacity(0.48)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.22)) {
                                showSideMenu = false
                            }
                        }

                    CommandSidebar(isPresented: $showSideMenu, openExternal: { url in
                        openURL(url)
                    })
                    .frame(width: 292)
                    .transition(.move(edge: .leading))
                    .zIndex(2)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.22)) {
                            showSideMenu.toggle()
                        }
                    } label: {
                        Image(systemName: showSideMenu ? "xmark" : "ellipsis")
                            .font(.title3.weight(.semibold))
                            .frame(minWidth: 36, minHeight: 36)
                    }
                    .accessibilityLabel(showSideMenu ? "Close command sidebar" : "Open command sidebar")
                }

                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(value: CoreDestination.coreCommand) {
                        Image(systemName: "magnifyingglass")
                            .font(.body.weight(.semibold))
                            .frame(minWidth: 36, minHeight: 36)
                    }
                    .accessibilityLabel("Open Core Command")
                }
            }
            .navigationDestination(for: CoreDestination.self) { destination in
                CoreDestinationView(destination: destination, openExternal: { openURL($0) })
            }
            .onOpenURL { url in
                guard url.scheme == "shayan-core" else { return }
                switch url.host {
                case "command":
                    navigationPath = [.coreCommand]
                case "reminders":
                    navigationPath = [.reminders]
                default:
                    break
                }
            }
            .onAppear {
                reminderStore.reload()
            }
            .task { await status.check() }
            .refreshable { await status.check() }
        }
    }
}

private struct CommandSidebar: View {
    @Binding var isPresented: Bool
    let openExternal: (URL) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("SHAYAN CORE")
                            .font(.caption.weight(.bold))
                            .tracking(1.4)
                            .foregroundStyle(.blue)
                        Text("Command Center")
                            .font(.title2.bold())
                    }

                    Spacer()

                    Button {
                        withAnimation(.easeInOut(duration: 0.22)) {
                            isPresented = false
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.caption.weight(.bold))
                            .frame(width: 32, height: 32)
                            .background(.white.opacity(0.07))
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Close sidebar")
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 18)

            Divider().opacity(0.25)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 6) {
                    SidebarSectionTitle("COMMAND")

                    NavigationLink(value: CoreDestination.coreCommand) {
                        SidebarLabel(title: "Core Command", subtitle: "Search your Core actions", icon: "magnifyingglass")
                    }
                    .buttonStyle(.plain)

                    NavigationLink(value: CoreDestination.importantLinks) {
                        SidebarLabel(title: "Important Links", subtitle: "Website, LinkedIn & GitHub", icon: "link")
                    }
                    .buttonStyle(.plain)

                    NavigationLink(value: CoreDestination.quickActions) {
                        SidebarLabel(title: "Quick Actions", subtitle: "Open, copy & share", icon: "bolt.fill")
                    }
                    .buttonStyle(.plain)

                    NavigationLink(value: CoreDestination.insights) {
                        SidebarLabel(title: "Insights", subtitle: "System & portfolio status", icon: "chart.bar.xaxis")
                    }
                    .buttonStyle(.plain)

                    SidebarSectionTitle("UPCOMING")

                    NavigationLink(value: CoreDestination.resume) {
                        SidebarLabel(title: "Shayan Resume Builder", subtitle: "Build & tailor resumes", icon: "doc.text.magnifyingglass")
                    }
                    .buttonStyle(.plain)

                    NavigationLink(value: CoreDestination.learning) {
                        SidebarLabel(title: "Shayan Learning Hub", subtitle: "Learn, track & grow", icon: "graduationcap.fill")
                    }
                    .buttonStyle(.plain)

                    SidebarSectionTitle("PERSONAL")

                    NavigationLink(value: CoreDestination.reminders) {
                        SidebarLabel(title: "Smart Reminders", subtitle: "Schedule & manage reminders", icon: "bell.badge")
                    }
                    .buttonStyle(.plain)

                    NavigationLink(value: CoreDestination.protectedNotes) {
                        SidebarLabel(title: "Protected Notes", subtitle: "Secure Keychain notes", icon: "lock.text")
                    }
                    .buttonStyle(.plain)

                    SidebarSectionTitle("APP")

                    NavigationLink(value: CoreDestination.settings) {
                        SidebarLabel(title: "Settings", subtitle: "Security & preferences", icon: "gearshape")
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 18)
            }

            Spacer(minLength: 0)

            VStack(alignment: .leading, spacing: 4) {
                Text("SHAYAN CORE")
                    .font(.caption2.weight(.bold))
                    .tracking(1.1)
                    .foregroundStyle(.secondary)
                Text("Your personal digital core")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .padding(20)
        }
        .frame(maxHeight: .infinity)
        .background(Color(red: 0.035, green: 0.045, blue: 0.085))
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(.white.opacity(0.08))
                .frame(width: 1)
        }
        .ignoresSafeArea(edges: .vertical)
        .shadow(color: .black.opacity(0.35), radius: 24, x: 10, y: 0)
    }
}

private struct SidebarSectionTitle: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title)
            .font(.caption2.weight(.bold))
            .tracking(1.2)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 12)
            .padding(.top, 14)
            .padding(.bottom, 5)
    }
}

private struct SidebarLabel: View {
    let title: String
    let subtitle: String
    let icon: String

    var body: some View {
        HStack(spacing: 13) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(.blue)
                .frame(width: 38, height: 38)
                .background(.blue.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 11))

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 9)
        .contentShape(Rectangle())
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
                    if let responseTimeMs = status.responseTimeMs {
                        Text("\(responseTimeMs) ms").font(.caption).foregroundStyle(.secondary)
                        Text("•").foregroundStyle(.secondary)
                    }
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

    

private struct ShayanCoreMark: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.23, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.02, green: 0.07, blue: 0.18),
                            Color(red: 0.01, green: 0.025, blue: 0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: size * 0.23, style: .continuous)
                        .stroke(.blue.opacity(0.7), lineWidth: max(1, size * 0.018))
                }

            Path { path in
                path.move(to: CGPoint(x: size * 0.31, y: size * 0.34))
                path.addCurve(
                    to: CGPoint(x: size * 0.68, y: size * 0.48),
                    control1: CGPoint(x: size * 0.42, y: size * 0.26),
                    control2: CGPoint(x: size * 0.58, y: size * 0.38)
                )
                path.addCurve(
                    to: CGPoint(x: size * 0.36, y: size * 0.66),
                    control1: CGPoint(x: size * 0.78, y: size * 0.58),
                    control2: CGPoint(x: size * 0.47, y: size * 0.72)
                )
            }
            .stroke(
                LinearGradient(colors: [.cyan, .blue], startPoint: .leading, endPoint: .trailing),
                style: StrokeStyle(lineWidth: size * 0.12, lineCap: .round)
            )

            Circle()
                .fill(.cyan)
                .frame(width: size * 0.11, height: size * 0.11)
                .offset(x: -size * 0.33, y: size * 0.04)
                .shadow(color: .cyan.opacity(0.8), radius: size * 0.08)

            Circle()
                .fill(.cyan)
                .frame(width: size * 0.11, height: size * 0.11)
                .offset(x: size * 0.33, y: size * 0.15)
                .shadow(color: .cyan.opacity(0.8), radius: size * 0.08)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

private struct CoreOverviewCard: View {
    @ObservedObject var reminderStore: ReminderStore
    @Binding var navigationPath: [CoreDestination]

    private var upcoming: [CoreReminder] {
        reminderStore.reminders
            .filter { !$0.isCompleted && $0.date >= Date() }
            .sorted { $0.date < $1.date }
    }

    private var todayCount: Int {
        reminderStore.reminders.filter {
            Calendar.current.isDateInToday($0.date) && !$0.isCompleted
        }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("CORE OVERVIEW")
                        .font(.caption.weight(.bold))
                        .tracking(1.1)
                        .foregroundStyle(.secondary)
                    Text(upcoming.first?.title ?? "You're all caught up")
                        .font(.title3.bold())
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: upcoming.isEmpty ? "checkmark.circle.fill" : "bell.badge.fill")
                    .font(.title2)
                    .foregroundStyle(upcoming.isEmpty ? .green : .blue)
            }

            if let next = upcoming.first {
                HStack(spacing: 10) {
                    Image(systemName: "clock")
                        .foregroundStyle(.blue)
                    Text(next.date.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day().hour().minute()))
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Text("\(todayCount) today")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("No pending reminders. Add one from Smart Reminders.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 10) {
                Button {
                    navigationPath.append(.reminders)
                } label: {
                    Label("Reminders", systemImage: "bell.badge")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(CoreActionButtonStyle())

                Button {
                    navigationPath.append(.coreCommand)
                } label: {
                    Label("Core Command", systemImage: "command")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(CoreActionButtonStyle())
            }
        }
        .padding(18)
        .background(.white.opacity(0.055))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(.white.opacity(0.09), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }
}

private struct CoreActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption.weight(.semibold))
            .foregroundStyle(.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 11)
            .background(.white.opacity(configuration.isPressed ? 0.13 : 0.07))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

private struct UpcomingModulesSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("COMING TO SHAYAN CORE").font(.caption.weight(.bold)).tracking(1.2).foregroundStyle(.secondary)
                Spacer()
                Text("2 MODULES").font(.caption2.weight(.bold)).foregroundStyle(.blue)
            }
            NavigationLink { ResumeBuilderPreviewView() } label: {
                UpcomingModuleCard(title: "Shayan Resume Builder", subtitle: "Build, tailor & manage your professional resume", icon: "doc.text.magnifyingglass")
            }.buttonStyle(.plain)
            NavigationLink { LearningHubPreviewView() } label: {
                UpcomingModuleCard(title: "Shayan Learning Hub", subtitle: "Your space for SAP, cloud & continuous learning", icon: "graduationcap.fill")
            }.buttonStyle(.plain)
        }
    }
}

private struct UpcomingModuleCard: View {
    let title: String
    let subtitle: String
    let icon: String
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon).font(.title3.weight(.semibold)).foregroundStyle(.blue)
                .frame(width: 48, height: 48).background(.blue.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 7) {
                    Text(title).font(.headline)
                    Text("SOON").font(.system(size: 8, weight: .bold)).tracking(0.7)
                        .padding(.horizontal, 7).padding(.vertical, 4)
                        .background(.blue.opacity(0.12)).foregroundStyle(.blue).clipShape(Capsule())
                }
                Text(subtitle).font(.caption).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            Image(systemName: "chevron.right").font(.caption.weight(.semibold)).foregroundStyle(.tertiary)
        }
        .padding(16).background(.white.opacity(0.045))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(.white.opacity(0.07), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}
