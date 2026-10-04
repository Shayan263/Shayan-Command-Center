import SwiftUI
import Combine
import Network


private struct BrowserDestination: Identifiable {
    let id = UUID()
    let url: URL
}

@MainActor
private final class WebsiteStatus: ObservableObject {
    @Published private(set) var isOnline = false
    @Published private(set) var lastChecked: Date?
    @Published private(set) var responseTimeMs: Int?
    @Published private(set) var isChecking = false

    let url: URL

    init(url: URL) { self.url = url }

    var lastCheckedText: String {
        guard let lastChecked else { return "Checking…" }
        return lastChecked.formatted(.dateTime.hour().minute().second())
    }

    func check() async {
        guard !isChecking else { return }
        isChecking = true
        defer { isChecking = false }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.cachePolicy = .reloadIgnoringLocalCacheData
        let started = Date()
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            responseTimeMs = max(1, Int(Date().timeIntervalSince(started) * 1000))
            if let http = response as? HTTPURLResponse {
                isOnline = (200...399).contains(http.statusCode)
            } else {
                isOnline = false
            }
        } catch {
            isOnline = false
            responseTimeMs = nil
        }
        lastChecked = Date()
    }
}

struct HomeView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var lastSyncDate: Date?
    @StateObject private var networkMonitor = NetworkMonitor()
    @StateObject private var dashboardStatus = DashboardStatus()
    @StateObject private var websiteStatus = WebsiteStatus(url: URL(string: "https://shayan263.github.io/Shayan_Profile/")!)
    @State private var showSideMenu = false
    @State private var navigationPath: [CoreDestination] = []
    @State private var browserDestination: BrowserDestination?

    private let dashboardURL = URL(string: "https://shayan263.github.io/Shayan_Profile/admin.html")!
    private let websiteURL = URL(string: "https://shayan263.github.io/Shayan_Profile/")!

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning, Shayan 👋"
        case 12..<17: return "Good afternoon, Shayan 👋"
        case 17..<22: return "Good evening, Shayan 👋"
        default: return "Good night, Shayan 👋"
        }
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack(alignment: .leading) {
                Color(.systemBackground).ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 12) {
                            ShayanCoreMark(size: 42)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("SHAYAN CORE")
                                    .font(.caption.weight(.bold))
                                    .tracking(1.4)
                                    .foregroundStyle(.blue)
                                Text(greeting)
                                    .font(.title2.bold())
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(networkMonitor.isConnected ? "ONLINE" : "OFFLINE")
                                    .font(.system(size: 9, weight: .bold))
                                    .tracking(0.8)
                                    .foregroundStyle(networkMonitor.isConnected ? .green : .red)
                                Text(lastSyncText)
                                    .font(.system(size: 9))
                                    .foregroundStyle(.tertiary)
                            }
                        }

                        NavigationLink(value: CoreDestination.aiCommandCenter) {
                            HStack(spacing: 13) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [.blue, .cyan],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                    Image(systemName: "waveform")
                                        .font(.system(size: 25, weight: .semibold))
                                        .foregroundStyle(.white)
                                }
                                .frame(width: 64, height: 64)
                                .shadow(color: .blue.opacity(0.22), radius: 12)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("AI COMMAND CENTRE")
                                        .font(.headline.weight(.bold))
                                        .tracking(0.7)
                                    Text("Tap once. Talk naturally. Shayan Core listens, thinks and replies.")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(12)
                            .background(Color.blue.opacity(0.075))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.blue.opacity(0.16), lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                        .buttonStyle(.plain)

                        if isOffline {
                            HStack(spacing: 9) {
                                Image(systemName: "wifi.slash")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(.red)
                                Text("You are offline. Live data will refresh automatically when the connection returns.")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)
                                Spacer(minLength: 0)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Color.red.opacity(0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: 13)
                                    .stroke(Color.red.opacity(0.16), lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 13))
                        }

                        CommandPulse(status: dashboardStatus)

                        LazyVGrid(
                            columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)],
                            spacing: 10
                        ) {
                            NavigationLink {
                                DashboardDetailView(
                                    status: dashboardStatus,
                                    openExternal: { browserDestination = BrowserDestination(url: $0) }
                                )
                            } label: {
                                CompactLiveCard(
                                    title: "Dashboard",
                                    subtitle: "Portfolio analytics",
                                    icon: "chart.xyaxis.line",
                                    isOnline: dashboardStatus.isOnline,
                                    isChecking: dashboardStatus.isChecking,
                                    response: dashboardStatus.responseTimeMs
                                )
                            }
                            .buttonStyle(.plain)

                            NavigationLink {
                                WebsiteDetailView(
                                    status: websiteStatus,
                                    openExternal: { browserDestination = BrowserDestination(url: $0) }
                                )
                            } label: {
                                CompactLiveCard(
                                    title: "Website",
                                    subtitle: "Public portfolio",
                                    icon: "globe",
                                    isOnline: websiteStatus.isOnline,
                                    isChecking: websiteStatus.isChecking,
                                    response: websiteStatus.responseTimeMs
                                )
                            }
                            .buttonStyle(.plain)

                            NavigationLink { LearningHubPreviewView() } label: {
                                CompactAppCard(
                                    title: "Learning Hub",
                                    subtitle: "AI Automations",
                                    icon: "graduationcap.fill",
                                    badge: "LIVE"
                                )
                            }
                            .buttonStyle(.plain)

                            NavigationLink(value: CoreDestination.sentinel) {
                                CompactAppCard(
                                    title: "Core Sentinel",
                                    subtitle: "Security intelligence",
                                    icon: "shield.checkered",
                                    badge: "SECURE"
                                )
                            }
                            .buttonStyle(.plain)
                        }

                        NavigationLink { ResumeBuilderPreviewView() } label: {
                            ModuleRow(
                                title: "Shayan Resume Builder",
                                subtitle: "Build & tailor professional resumes",
                                icon: "doc.text.magnifyingglass",
                                badge: "SOON"
                            )
                        }
                        .buttonStyle(.plain)

                        Text("© 2026 Shayan Core. All rights reserved.")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .padding(.top, 2)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 92)
                }

                VStack {
                    Spacer()
                    NavigationLink {
                        QRScannerScreen()
                    } label: {
                        Image(systemName: "qrcode.viewfinder")
                            .font(.system(size: 27, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 62, height: 62)
                            .background(
                                Circle().fill(
                                    LinearGradient(
                                        colors: [.blue, .cyan],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            )
                            .overlay(Circle().stroke(.white.opacity(0.28), lineWidth: 1))
                            .shadow(color: .black.opacity(0.28), radius: 14, y: 7)
                    }
                    .accessibilityLabel("Scan QR code")
                    .padding(.bottom, 18)
                }
                .frame(maxWidth: .infinity)
                .zIndex(1)

                if showSideMenu {
                    Color.black.opacity(0.48)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.22)) { showSideMenu = false }
                        }

                    CommandSidebar(
                        isPresented: $showSideMenu,
                        openExternal: { url in
                            browserDestination = BrowserDestination(url: url)
                        }
                    )
                    .frame(width: 292)
                    .transition(.move(edge: .leading))
                    .zIndex(2)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.22)) { showSideMenu.toggle() }
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
            .navigationDestination(for: CoreDestination.self) {
                CoreDestinationView(
                    destination: $0,
                    openExternal: { browserDestination = BrowserDestination(url: $0) }
                )
            }
            .onOpenURL { url in
                guard url.scheme == "shayan-core" else { return }
                if url.host == "command" { navigationPath = [.coreCommand] }
            }
            .task {
                networkMonitor.start()
                try? await Task.sleep(for: .milliseconds(1600))
                await refreshStatuses()
            }
            .onChange(of: scenePhase) { _, phase in
                guard phase == .active else { return }
                Task { await refreshStatuses() }
            }
            .onChange(of: networkMonitor.isConnected) { _, connected in
                guard connected else { return }
                Task { await refreshStatuses() }
            }
            .refreshable {
                await refreshStatuses()
            }
        }
        .sheet(item: $browserDestination) { destination in
            InAppBrowserView(url: destination.url).ignoresSafeArea(edges: .bottom)
        }
    }

    private var isOffline: Bool {
        !networkMonitor.isConnected
    }

    private var lastSyncText: String {
        guard let lastSyncDate else { return "Not synced yet" }
        return lastSyncDate.formatted(date: .omitted, time: .shortened)
    }

    private func refreshStatuses() async {
        guard networkMonitor.isConnected else { return }
        async let dashboard: Void = dashboardStatus.check()
        async let website: Void = websiteStatus.check()
        _ = await (dashboard, website)
        lastSyncDate = Date()
    }
}


@MainActor
final class NetworkMonitor: ObservableObject {
    @Published private(set) var isConnected = true

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.shayan.commandcentre.network")
    private var started = false

    func start() {
        guard !started else { return }
        started = true
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}

private struct CompactLiveCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let isOnline: Bool
    let isChecking: Bool
    let response: Int?

    private var statusText: String { isChecking ? "CHECKING" : (isOnline ? "LIVE" : "OFFLINE") }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon).font(.headline).foregroundStyle(.blue)
                    .frame(width: 34, height: 34).background(.blue.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                Spacer()
                LiveStatusIndicator(isOnline: isOnline, isChecking: isChecking)
            }
            Text(title).font(.headline)
            Text(subtitle).font(.caption).foregroundStyle(.secondary)
            HStack(spacing: 5) {
                Circle().fill(isChecking ? Color.orange : (isOnline ? Color.green : Color.red)).frame(width: 6, height: 6)
                Text(statusText).font(.caption2.bold())
                if let response { Text("•").foregroundStyle(.secondary); Text("\(response) ms").font(.caption2).foregroundStyle(.secondary) }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 124, alignment: .leading)
        .padding(14)
        .background(Color.primary.opacity(0.055))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.primary.opacity(0.08), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

private struct CompactAppCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let badge: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundStyle(.blue)
                    .frame(width: 34, height: 34)
                    .background(.blue.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                Spacer()
                Text(badge)
                    .font(.system(size: 8, weight: .bold))
                    .tracking(0.7)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 4)
                    .background(.green.opacity(0.12))
                    .foregroundStyle(.green)
                    .clipShape(Capsule())
            }
            Text(title).font(.headline)
            Text(subtitle).font(.caption).foregroundStyle(.secondary)
            HStack(spacing: 5) {
                Circle().fill(.green).frame(width: 6, height: 6)
                Text("READY").font(.caption2.bold())
            }
        }
        .frame(maxWidth: .infinity, minHeight: 124, alignment: .leading)
        .padding(14)
        .background(Color.primary.opacity(0.045))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.primary.opacity(0.08), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

private struct LiveStatusIndicator: View {
    let isOnline: Bool
    let isChecking: Bool
    @State private var pulse = false

    var body: some View {
        Circle()
            .fill(isChecking ? Color.orange : (isOnline ? Color.green : Color.red))
            .frame(width: 8, height: 8)
            .scaleEffect((isChecking || isOnline) && pulse ? 1.55 : 1)
            .opacity((isChecking || isOnline) && pulse ? 0.45 : 1)
            .animation((isChecking || isOnline) ? .easeInOut(duration: 1.05).repeatForever(autoreverses: true) : .default, value: pulse)
            .onAppear { pulse = true }
            .accessibilityLabel(isChecking ? "Checking" : (isOnline ? "Live" : "Offline"))
    }
}

private struct ModuleRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let badge: String

    var body: some View {
        HStack(spacing: 13) {
            Image(systemName: icon).font(.headline).foregroundStyle(.blue)
                .frame(width: 40, height: 40).background(.blue.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 11))
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.subheadline.weight(.semibold))
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Text(badge).font(.system(size: 8, weight: .bold)).tracking(0.7)
                .padding(.horizontal, 7).padding(.vertical, 4)
                .background(badge == "LIVE" ? .green.opacity(0.12) : .blue.opacity(0.12))
                .foregroundStyle(badge == "LIVE" ? .green : .blue)
                .clipShape(Capsule())
            Image(systemName: "chevron.right").font(.caption.weight(.semibold)).foregroundStyle(.tertiary)
        }
        .padding(13)
        .background(Color.primary.opacity(0.045))
        .overlay(RoundedRectangle(cornerRadius: 17).stroke(Color.primary.opacity(0.07), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 17))
    }
}

struct DashboardDetailView: View {
    @ObservedObject var status: DashboardStatus
    let openExternal: (URL) -> Void
    private let url = URL(string: "https://shayan263.github.io/Shayan_Profile/admin.html")!

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                DetailHeader(icon: "chart.xyaxis.line", title: "Portfolio Dashboard", subtitle: "Private analytics and portfolio controls")
                LiveDetailCard(isOnline: status.isOnline, isChecking: status.isChecking, response: status.responseTimeMs, lastChecked: status.lastCheckedText)
                DetailInfo(title: "What this does", text: "The dashboard is the deeper view behind the compact Home card. Home stays lightweight; this screen gives you the complete status and access point.")
                Button { openExternal(url) } label: {
                    Label("Open Dashboard", systemImage: "arrow.up.right")
                        .font(.headline).frame(maxWidth: .infinity).padding(.vertical, 14)
                }.buttonStyle(.borderedProminent)
            }.padding(20)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Dashboard").navigationBarTitleDisplayMode(.inline)
        .task { await status.check() }
        .refreshable { await status.check() }
    }
}

private struct WebsiteDetailView: View {
    @ObservedObject var status: WebsiteStatus
    let openExternal: (URL) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                DetailHeader(icon: "globe", title: "My Website", subtitle: "Public portfolio and professional profile")
                LiveDetailCard(isOnline: status.isOnline, isChecking: status.isChecking, response: status.responseTimeMs, lastChecked: status.lastCheckedText)
                DetailInfo(title: "What this does", text: "This screen shows the live state of the public portfolio and gives you a direct way to open it.")
                Button { openExternal(status.url) } label: {
                    Label("Visit Website", systemImage: "arrow.up.right")
                        .font(.headline).frame(maxWidth: .infinity).padding(.vertical, 14)
                }.buttonStyle(.borderedProminent)
            }.padding(20)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Website").navigationBarTitleDisplayMode(.inline)
        .task { await status.check() }
        .refreshable { await status.check() }
    }
}

private struct DetailHeader: View {
    let icon: String
    let title: String
    let subtitle: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon).font(.system(size: 30, weight: .semibold)).foregroundStyle(.blue)
                .frame(width: 62, height: 62).background(.blue.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 18))
            Text(title).font(.largeTitle.bold())
            Text(subtitle).font(.body).foregroundStyle(.secondary)
        }
    }
}

private struct LiveDetailCard: View {
    let isOnline: Bool
    let isChecking: Bool
    let response: Int?
    let lastChecked: String
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(isChecking ? "CHECKING" : (isOnline ? "LIVE" : "OFFLINE")).font(.caption.bold()).tracking(1)
                    .foregroundStyle(isChecking ? .orange : (isOnline ? .green : .red))
                Spacer()
                LiveStatusIndicator(isOnline: isOnline, isChecking: isChecking)
            }
            HStack {
                Label("Status", systemImage: "waveform.path.ecg")
                Spacer(); Text(isChecking ? "Checking…" : (isOnline ? "Online" : "Unavailable")).foregroundStyle(.secondary)
            }
            HStack {
                Label("Response", systemImage: "speedometer")
                Spacer(); Text(response.map { value in "\(value) ms" } ?? "—").foregroundStyle(.secondary)
            }
            HStack {
                Label("Last checked", systemImage: "clock")
                Spacer(); Text(lastChecked).foregroundStyle(.secondary)
            }
        }
        .padding(17).background(Color.primary.opacity(0.05))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.primary.opacity(0.08), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

private struct DetailInfo: View {
    let title: String
    let text: String
    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title).font(.headline)
            Text(text).font(.body).foregroundStyle(.secondary)
        }
        .padding(17).background(Color.primary.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

struct CommandSidebar: View {
    @Binding var isPresented: Bool
    let openExternal: (URL) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("SHAYAN CORE").font(.caption.weight(.bold)).tracking(1.4).foregroundStyle(.blue)
                    Text("Command Center").font(.title2.bold())
                }
                Spacer()
                Button { withAnimation(.easeInOut(duration: 0.22)) { isPresented = false } } label: {
                    Image(systemName: "xmark").font(.caption.weight(.bold))
                        .frame(width: 32, height: 32).background(Color.primary.opacity(0.07)).clipShape(Circle())
                }
            }
            .padding(20)
            Divider().opacity(0.25)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 6) {
                    SidebarSectionTitle("PROFILE")
                    NavigationLink(value: CoreDestination.profile) { SidebarLabel(title: "My Profile", subtitle: "Professional identity & skills", icon: "person.crop.circle.fill") }.buttonStyle(.plain)
                    SidebarSectionTitle("COMMAND")
                    NavigationLink(value: CoreDestination.coreCommand) { SidebarLabel(title: "Core Command", subtitle: "Search your Core actions", icon: "magnifyingglass") }.buttonStyle(.plain)
                    NavigationLink(value: CoreDestination.quickActions) { SidebarLabel(title: "Quick Actions", subtitle: "Open, copy & share", icon: "bolt.fill") }.buttonStyle(.plain)
                    NavigationLink(value: CoreDestination.insights) { SidebarLabel(title: "Insights", subtitle: "System & portfolio status", icon: "chart.bar.xaxis") }.buttonStyle(.plain)
                    SidebarSectionTitle("SECURITY")
                    NavigationLink(value: CoreDestination.sentinel) { SidebarLabel(title: "Core Sentinel", subtitle: "AI Security Intelligence", icon: "shield.checkered") }.buttonStyle(.plain)
                    SidebarSectionTitle("MODULES")
                    NavigationLink(value: CoreDestination.resume) { SidebarLabel(title: "Shayan Resume Builder", subtitle: "Build & tailor resumes", icon: "doc.text.magnifyingglass") }.buttonStyle(.plain)
                    NavigationLink(value: CoreDestination.learning) { SidebarLabel(title: "Shayan Learning Hub", subtitle: "AI Automations documentation", icon: "graduationcap.fill") }.buttonStyle(.plain)
                    SidebarSectionTitle("PERSONAL")
                    NavigationLink(value: CoreDestination.protectedNotes) { SidebarLabel(title: "Protected Notes", subtitle: "Secure Keychain notes", icon: "lock.text") }.buttonStyle(.plain)
                    SidebarSectionTitle("APP")
                    NavigationLink(value: CoreDestination.settings) { SidebarLabel(title: "Settings", subtitle: "Security & preferences", icon: "gearshape") }.buttonStyle(.plain)
                }
                .padding(.horizontal, 14).padding(.vertical, 18)
            }
            Spacer(minLength: 0)
            VStack(alignment: .leading, spacing: 4) {
                Text("SHAYAN CORE").font(.caption2.weight(.bold)).tracking(1.1).foregroundStyle(.secondary)
                Text("Your personal digital core").font(.caption2).foregroundStyle(.tertiary)
            }.padding(20)
        }
        .frame(maxHeight: .infinity)
        .background(Color(.secondarySystemBackground))
        .overlay(alignment: .trailing) { Rectangle().fill(Color.primary.opacity(0.08)).frame(width: 1) }
        .ignoresSafeArea(edges: .vertical)
        .shadow(color: .black.opacity(0.35), radius: 24, x: 10, y: 0)
    }
}

private struct SidebarSectionTitle: View {
    let title: String
    init(_ title: String) { self.title = title }
    var body: some View {
        Text(title).font(.caption2.weight(.bold)).tracking(1.2).foregroundStyle(.secondary)
            .padding(.horizontal, 12).padding(.top, 14).padding(.bottom, 5)
    }
}

private struct SidebarLabel: View {
    let title: String
    let subtitle: String
    let icon: String
    var body: some View {
        HStack(spacing: 13) {
            Image(systemName: icon).font(.body.weight(.semibold)).foregroundStyle(.blue)
                .frame(width: 38, height: 38).background(.blue.opacity(0.12)).clipShape(RoundedRectangle(cornerRadius: 11))
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.body.weight(.semibold))
                Text(subtitle).font(.caption2).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right").font(.caption.weight(.semibold)).foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 10).padding(.vertical, 9).contentShape(Rectangle())
    }
}

private struct CommandPulse: View {
    @ObservedObject var status: DashboardStatus
    var body: some View {
        HStack(spacing: 11) {
            LiveStatusIndicator(isOnline: status.isOnline, isChecking: status.isChecking)
            VStack(alignment: .leading, spacing: 2) {
                Text(status.isOnline ? "Everything looks good" : "Attention required").font(.subheadline.weight(.semibold))
                Text(status.isOnline ? "Portfolio systems are online" : "Portfolio dashboard is unavailable").font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Text(status.isOnline ? "1/1 ONLINE" : "0/1 ONLINE").font(.caption2.bold())
                .foregroundStyle(status.isOnline ? .green : .red)
        }
        .padding(.horizontal, 14).padding(.vertical, 12)
        .background(Color.primary.opacity(0.045))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.primary.opacity(0.07), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct ShayanCoreMark: View {
    let size: CGFloat
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.23, style: .continuous)
                .fill(LinearGradient(colors: [Color(red: 0.02, green: 0.07, blue: 0.18), Color(red: 0.01, green: 0.025, blue: 0.08)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .overlay { RoundedRectangle(cornerRadius: size * 0.23, style: .continuous).stroke(.blue.opacity(0.7), lineWidth: max(1, size * 0.018)) }
            Path { path in
                path.move(to: CGPoint(x: size * 0.31, y: size * 0.34))
                path.addCurve(to: CGPoint(x: size * 0.68, y: size * 0.48), control1: CGPoint(x: size * 0.42, y: size * 0.26), control2: CGPoint(x: size * 0.58, y: size * 0.38))
                path.addCurve(to: CGPoint(x: size * 0.36, y: size * 0.66), control1: CGPoint(x: size * 0.78, y: size * 0.58), control2: CGPoint(x: size * 0.47, y: size * 0.72))
            }
            .stroke(LinearGradient(colors: [.cyan, .blue], startPoint: .leading, endPoint: .trailing), style: StrokeStyle(lineWidth: size * 0.12, lineCap: .round))
            Circle().fill(.cyan).frame(width: size * 0.11, height: size * 0.11).offset(x: -size * 0.33, y: size * 0.04)
            Circle().fill(.cyan).frame(width: size * 0.11, height: size * 0.11).offset(x: size * 0.33, y: size * 0.15)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}
