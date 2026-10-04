import SwiftUI
import UIKit
import AVFoundation
import PDFKit

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

    var body: some View {
        Form {
            Section("Appearance") {
                Toggle(isOn: $darkModeEnabled) {
                    Label("Dark interface", systemImage: darkModeEnabled ? "moon.fill" : "sun.max.fill")
                }
                Text("Choose dark or light appearance for Shayan Core.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            Section("Security") {
                Label("iOS device security", systemImage: "lock.shield")
                Text("Shayan Core does not add a separate Face ID lock. Your iPhone's existing device security protects the app and its Keychain data.")
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
    @State private var saveTask: Task<Void, Never>?

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
                text = await SecureNotesStore.loadAsync()
            }
            .onChange(of: text) { _, newValue in
                saveTask?.cancel()
                saveTask = Task {
                    do {
                        try await Task.sleep(for: .milliseconds(350))
                        try await SecureNotesStore.saveAsync(newValue)
                    } catch is CancellationError {
                        return
                    } catch {
                        showSaveError = true
                    }
                }
            }
            .onDisappear {
                saveTask?.cancel()
                let finalText = text
                Task {
                    try? await SecureNotesStore.saveAsync(finalText)
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
                    saveTask?.cancel()
                    Task { try? await SecureNotesStore.deleteAsync() }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will remove the protected note from this device.")
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
        LearningHubPDFView()
    }
}

struct LearningHubPDFView: View {
    var body: some View {
        PDFDocumentView(resourceName: "AI Automations", resourceExtension: "pdf")
            .background(Color(.systemBackground))
            .navigationTitle("AI Automations")
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct PDFDocumentView: UIViewRepresentable {
    let resourceName: String
    let resourceExtension: String

    func makeUIView(context: Context) -> PDFView {
        let view = PDFView()
        view.autoScales = true
        view.displayMode = .singlePageContinuous
        view.displayDirection = .vertical
        view.backgroundColor = .systemBackground
        if let url = Bundle.main.url(forResource: resourceName, withExtension: resourceExtension),
           let document = PDFDocument(url: url) {
            view.document = document
            view.usePageViewController(true, withViewOptions: nil)
        }
        return view
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}
}

struct QRScannerScreen: View {
    @State private var result: String?
    @State private var cameraDenied = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if cameraDenied {
                VStack(spacing: 14) {
                    Image(systemName: "camera.fill").font(.system(size: 42)).foregroundStyle(.blue)
                    Text("Camera Access Needed").font(.title2.bold())
                    Text("Enable camera access in Settings to scan QR codes.")
                        .multilineTextAlignment(.center).foregroundStyle(.secondary)
                    Button("Open Settings") {
                        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                        UIApplication.shared.open(url)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(24)
            } else if let result {
                QRResultView(value: result) {
                    self.result = nil
                }
            } else {
                QRScannerCameraView { value in
                    self.result = value
                }
                .ignoresSafeArea()
                VStack {
                    Spacer()
                    Text("Point the camera at a QR code")
                        .font(.headline)
                        .padding(.horizontal, 18).padding(.vertical, 11)
                        .background(.black.opacity(0.65))
                        .clipShape(Capsule())
                        .padding(.bottom, 28)
                }
            }
        }
        .navigationTitle("QR Scanner")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            if !granted { cameraDenied = true }
        }
    }
}

private struct QRResultView: View {
    let value: String
    let scanAgain: () -> Void
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "qrcode").font(.system(size: 52)).foregroundStyle(.blue)
            Text("QR Result").font(.title2.bold())
            Text(value).font(.body.monospaced()).multilineTextAlignment(.center).textSelection(.enabled)
                .padding(16).frame(maxWidth: .infinity)
                .background(Color.primary.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 16))

            HStack {
                Button("Copy") {
                    UIPasteboard.general.string = value
                }.buttonStyle(.bordered)
                ShareLink(item: value) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }.buttonStyle(.bordered)
            }

            if let url = URL(string: value), url.scheme == "https" {
                Button {
                    openURL(url)
                } label: {
                    Label("Open Secure Link", systemImage: "arrow.up.right")
                        .frame(maxWidth: .infinity).padding(.vertical, 13)
                }
                .buttonStyle(.borderedProminent)
            }

            Button("Scan Again", action: scanAgain)
                .padding(.top, 4)
        }
        .padding(22)
    }
}

private struct QRScannerCameraView: UIViewControllerRepresentable {
    let onCode: (String) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onCode: onCode)
    }

    func makeUIViewController(context: Context) -> ScannerViewController {
        let controller = ScannerViewController()
        controller.onCode = context.coordinator.handle
        return controller
    }

    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {}

    final class Coordinator {
        let onCode: (String) -> Void
        init(onCode: @escaping (String) -> Void) { self.onCode = onCode }
        func handle(_ value: String) { onCode(value) }
    }
}

private final class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    var onCode: ((String) -> Void)?
    private var hasScanned = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        configure()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    private func configure() {
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else { return }
        session.addInput(input)

        let output = AVCaptureMetadataOutput()
        guard session.canAddOutput(output) else { return }
        session.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: .main)
        output.metadataObjectTypes = [.qr]

        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(layer, at: 0)
        previewLayer = layer
        session.startRunning()
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard !hasScanned,
              let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let value = object.stringValue,
              !value.isEmpty else { return }
        hasScanned = true
        session.stopRunning()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        onCode?(value)
    }

    deinit {
        if session.isRunning { session.stopRunning() }
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
                .padding(18).background(Color.primary.opacity(0.045))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.primary.opacity(0.07), lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                Text("This is a preview. The module will be built into Shayan Core as the platform expands.")
                    .font(.footnote).foregroundStyle(.secondary)
            }.padding(20)
        }
        .background(Color(.systemBackground))
        .navigationTitle(title).navigationBarTitleDisplayMode(.inline)
    }
}


private struct StatusPill: View {
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
