import SwiftUI
import ElevenLabs
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

struct CoreHomeView: View {
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

                        }

                        NavigationLink(value: CoreDestination.sapKnowledge) {
                            ModuleRow(
                                title: "SAP Knowledge Agent",
                                subtitle: "Live SAP intelligence for your career",
                                icon: "brain.head.profile",
                                badge: "LIVE"
                            )
                        }
                        .buttonStyle(.plain)

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
            }
            .navigationDestination(for: CoreDestination.self) {
                CoreDestinationView(
                    destination: $0,
                    openExternal: { browserDestination = BrowserDestination(url: $0) }
                )
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
                    SidebarSectionTitle("TOOLS")
                    NavigationLink(value: CoreDestination.quickActions) { SidebarLabel(title: "Quick Actions", subtitle: "Open, copy & share", icon: "bolt.fill") }.buttonStyle(.plain)
                    NavigationLink(value: CoreDestination.insights) { SidebarLabel(title: "Insights", subtitle: "System & portfolio status", icon: "chart.bar.xaxis") }.buttonStyle(.plain)
                    SidebarSectionTitle("MODULES")
                    NavigationLink(value: CoreDestination.resume) { SidebarLabel(title: "Shayan Resume Builder", subtitle: "Build & tailor resumes", icon: "doc.text.magnifyingglass") }.buttonStyle(.plain)
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


// MARK: - JARVIS Cinematic Home

struct HomeView: View {
    @State private var showCoreHome = false
    @State private var interfaceState: JarvisInterfaceState = .idle
    @StateObject private var jarvisVoice = JarvisVoiceManager()
    @State private var pulse = false
    @State private var rotation: Double = 0
    @State private var innerRotation: Double = 0
    @GestureState private var dragX: CGFloat = 0

    private let cyan = Color(red: 0.18, green: 0.92, blue: 1.0)
    private let deepCyan = Color(red: 0.02, green: 0.28, blue: 0.42)

    var body: some View {
        ZStack {
            if showCoreHome {
                CoreHomeView()
                    .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
            } else {
                jarvisInterface
                    .transition(.asymmetric(insertion: .move(edge: .leading).combined(with: .opacity), removal: .move(edge: .trailing).combined(with: .opacity)))
            }
        }
        .animation(.easeInOut(duration: 0.48), value: showCoreHome)
        .gesture(
            DragGesture(minimumDistance: 18)
                .updating($dragX) { value, state, _ in state = value.translation.width }
                .onEnded { value in
                    let threshold: CGFloat = 82
                    if !showCoreHome && value.translation.width < -threshold {
                        openCore()
                    } else if showCoreHome && value.translation.width > threshold {
                        closeCore()
                    }
                }
        )
        .preferredColorScheme(.dark)
    }

    private var jarvisInterface: some View {
        GeometryReader { proxy in
            ZStack {
                Color.black.ignoresSafeArea()
                RadialGradient(
                    colors: [cyan.opacity(0.085), Color(red: 0.01, green: 0.055, blue: 0.075).opacity(0.92), .black],
                    center: .center,
                    startRadius: 20,
                    endRadius: max(proxy.size.width, proxy.size.height) * 0.72
                )
                .ignoresSafeArea()
                grid
                peripheralHUD
                orbitalSystem(size: min(proxy.size.width, proxy.size.height) * 0.64)
                core(size: min(proxy.size.width, proxy.size.height) * 0.32)
                statusHUD
                bottomControls
                swipeHint
            }
            .contentShape(Rectangle())
            .onTapGesture { cycleInteraction() }
            .onAppear {
                pulse = true
                startAnimations()
            }
            .onReceive(jarvisVoice.$state) { state in
                withAnimation(.easeInOut(duration: 0.25)) {
                    interfaceState = state
                }
            }
        }
    }

    private var grid: some View {
        Canvas { context, size in
            let step: CGFloat = 28
            var path = Path()
            var x: CGFloat = 0
            while x <= size.width {
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                x += step
            }
            var y: CGFloat = 0
            while y <= size.height {
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                y += step
            }
            context.stroke(path, with: .color(cyan.opacity(0.035)), lineWidth: 0.5)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private var peripheralHUD: some View {
        VStack {
            HStack(alignment: .top) {
                hudLabel("JARVIS", subtitle: "SHAYAN CORE", alignment: .leading)
                Spacer()
                hudLabel(interfaceState.rawValue, subtitle: "SYSTEM ONLINE", alignment: .trailing)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            Spacer()
            HStack(alignment: .bottom) {
                telemetry(title: "CORE", value: "ONLINE", icon: "circle.fill")
                Spacer()
                telemetry(title: "NEURAL", value: "READY", icon: "waveform")
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 88)
        }
        .allowsHitTesting(false)
    }

    private func hudLabel(_ title: String, subtitle: String, alignment: HorizontalAlignment) -> some View {
        VStack(alignment: alignment, spacing: 3) {
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .tracking(2.4)
                .foregroundStyle(cyan)
            Text(subtitle)
                .font(.system(size: 7, weight: .medium, design: .monospaced))
                .tracking(1.6)
                .foregroundStyle(cyan.opacity(0.46))
        }
    }

    private func telemetry(title: String, value: String, icon: String) -> some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
                .font(.system(size: 7, weight: .bold))
                .foregroundStyle(cyan)
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 7, weight: .bold, design: .monospaced))
                    .tracking(1.3)
                    .foregroundStyle(cyan.opacity(0.42))
                Text(value)
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .tracking(1)
                    .foregroundStyle(cyan)
            }
        }
    }

    private func orbitalSystem(size: CGFloat) -> some View {
        ZStack {
            Circle().stroke(cyan.opacity(0.12), lineWidth: 1)
            Circle().stroke(cyan.opacity(0.22), style: StrokeStyle(lineWidth: 1, dash: [2, 9]))
                .rotationEffect(.degrees(rotation))
            Circle().inset(by: size * 0.09)
                .stroke(cyan.opacity(0.2), style: StrokeStyle(lineWidth: 1.1, dash: [18, 8, 3, 11]))
                .rotationEffect(.degrees(-innerRotation))
            Circle().inset(by: size * 0.18).stroke(cyan.opacity(0.15), lineWidth: 1)
            AngularArc().trim(from: 0.03, to: 0.31)
                .stroke(cyan.opacity(0.82), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .frame(width: size, height: size)
                .rotationEffect(.degrees(rotation * 1.4))
            AngularArc().trim(from: 0.54, to: 0.72)
                .stroke(cyan.opacity(0.55), style: StrokeStyle(lineWidth: 1.4, lineCap: .round))
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-rotation * 0.9))
        }
        .frame(width: size, height: size)
        .allowsHitTesting(false)
    }

    private func core(size: CGFloat) -> some View {
        ZStack {
            Circle()
                .fill(cyan.opacity(interfaceState == .speaking ? 0.11 : 0.065))
                .frame(width: size * 1.22, height: size * 1.22)
                .blur(radius: interfaceState == .speaking ? 22 : 14)
                .scaleEffect(interfaceState == .speaking && pulse ? 1.12 : 0.94)

            Circle().stroke(cyan.opacity(0.28), lineWidth: 1).frame(width: size, height: size)
            Circle()
                .stroke(cyan.opacity(0.7), style: StrokeStyle(lineWidth: 2.2, dash: [1, 8]))
                .frame(width: size * 0.86, height: size * 0.86)
                .rotationEffect(.degrees(-rotation * 1.8))

            ZStack {
                Circle()
                    .fill(RadialGradient(
                        colors: [cyan.opacity(0.7), deepCyan.opacity(0.4), Color.black.opacity(0.94)],
                        center: .center, startRadius: 2, endRadius: size * 0.34
                    ))
                Circle().stroke(cyan.opacity(0.9), lineWidth: 1.2).padding(size * 0.07)

                if interfaceState == .speaking || interfaceState == .listening {
                    waveform.padding(size * 0.19).transition(.opacity)
                } else {
                    Image(systemName: "waveform")
                        .font(.system(size: size * 0.17, weight: .light))
                        .foregroundStyle(cyan.opacity(0.85))
                }
            }
            .frame(width: size * 0.7, height: size * 0.7)

            Text(interfaceState == .speaking ? "SPEAKING" : interfaceState == .listening ? "LISTENING" : interfaceState == .thinking ? "THINKING" : "JARVIS")
                .font(.system(size: max(8, size * 0.052), weight: .bold, design: .monospaced))
                .tracking(2)
                .foregroundStyle(cyan)
                .offset(y: size * 0.55)
        }
        .frame(width: size * 1.35, height: size * 1.35)
        .animation(.easeInOut(duration: 0.38), value: interfaceState)
        .allowsHitTesting(false)
    }

    private var waveform: some View {
        HStack(spacing: 3) {
            ForEach(0..<17, id: \.self) { index in
                Capsule()
                    .fill(cyan.opacity(0.78))
                    .frame(width: 2.2, height: CGFloat(8 + ((index * 17) % 29)))
                    .scaleEffect(y: pulse ? 1.0 + CGFloat(index % 3) * 0.18 : 0.62)
                    .animation(
                        .easeInOut(duration: 0.28 + Double(index % 4) * 0.07)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.018),
                        value: pulse
                    )
            }
        }
    }

    private var statusHUD: some View {
        VStack {
            Spacer()
            HStack(spacing: 12) {
                statusChip("VOICE", active: interfaceState == .speaking || interfaceState == .listening)
                statusChip("MEMORY", active: true)
                statusChip("RAG", active: true)
                statusChip("WEB", active: false)
            }
            .padding(.bottom, 22)
        }
        .allowsHitTesting(false)
    }

    private func statusChip(_ title: String, active: Bool) -> some View {
        HStack(spacing: 5) {
            Circle().fill(active ? cyan : cyan.opacity(0.18)).frame(width: 4, height: 4)
            Text(title)
                .font(.system(size: 7, weight: .bold, design: .monospaced))
                .tracking(0.9)
                .foregroundStyle(active ? cyan.opacity(0.9) : cyan.opacity(0.28))
        }
    }

    private var bottomControls: some View {
        VStack {
            Spacer()
            HStack(spacing: 18) {
                controlButton(systemName: "message", title: "CHAT") {
                    interfaceState = .thinking
                }
                controlButton(systemName: jarvisVoice.isConnected ? "phone.down.fill" : "mic", title: jarvisVoice.isConnected ? "END" : "VOICE") {
                    if jarvisVoice.isConnected {
                        jarvisVoice.end()
                    } else {
                        Task { await jarvisVoice.start() }
                    }
                }
                controlButton(systemName: "square.grid.2x2", title: "CORE") {
                    openCore()
                }
            }
            .padding(.bottom, 10)
        }
    }

    private func controlButton(systemName: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: systemName)
                    .font(.system(size: 16, weight: .light))
                    .frame(width: 48, height: 48)
                    .background(cyan.opacity(0.045))
                    .overlay(Circle().stroke(cyan.opacity(0.22), lineWidth: 1))
                    .clipShape(Circle())
                Text(title)
                    .font(.system(size: 7, weight: .bold, design: .monospaced))
                    .tracking(1)
                    .foregroundStyle(cyan.opacity(0.48))
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title.capitalized)
    }

    private var swipeHint: some View {
        VStack {
            Spacer()
            Text("SWIPE LEFT  •  SHAYAN CORE")
                .font(.system(size: 7, weight: .bold, design: .monospaced))
                .tracking(1.6)
                .foregroundStyle(cyan.opacity(0.28))
                .padding(.bottom, 1)
        }
        .allowsHitTesting(false)
    }

    private func cycleInteraction() {
        withAnimation(.easeInOut(duration: 0.3)) {
            switch interfaceState {
            case .idle: interfaceState = .listening
            case .listening: interfaceState = .thinking
            case .thinking: interfaceState = .speaking
            case .speaking: interfaceState = .idle
            }
        }
    }

    private func openCore() {
        withAnimation(.spring(response: 0.52, dampingFraction: 0.88)) {
            showCoreHome = true
        }
    }

    private func closeCore() {
        withAnimation(.spring(response: 0.52, dampingFraction: 0.88)) {
            showCoreHome = false
        }
    }

    private func startAnimations() {
        withAnimation(.linear(duration: 18).repeatForever(autoreverses: false)) { rotation = 360 }
        withAnimation(.linear(duration: 11).repeatForever(autoreverses: false)) { innerRotation = 360 }
    }
}


@MainActor
private final class JarvisVoiceManager: ObservableObject {
    @Published var state: JarvisInterfaceState = .idle
    @Published var isConnected = false
    @Published var errorMessage: String?

    private var conversation: Conversation?

    func start() async {
        errorMessage = nil
        state = .listening

        do {
            let config = ConversationConfig(
                conversationOverrides: ConversationOverrides(textOnly: false)
            )
            let session = try await ElevenLabs.startConversation(
                agentId: "agent_2101m4976e28f6dvdxxar2cvwemg",
                config: config
            )
            conversation = session
            isConnected = true
            state = .listening
        } catch {
            isConnected = false
            state = .idle
            errorMessage = error.localizedDescription
        }
    }

    func end() {
        Task {
            await conversation?.endConversation()
            conversation = nil
            isConnected = false
            state = .idle
        }
    }
}

private enum JarvisInterfaceState: String {
    case idle = "STANDBY"
    case listening = "LISTENING"
    case thinking = "THINKING"
    case speaking = "RESPONDING"
}

private struct AngularArc: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.midY),
            radius: min(rect.width, rect.height) / 2,
            startAngle: .degrees(0),
            endAngle: .degrees(360),
            clockwise: false
        )
        return path
    }
}
