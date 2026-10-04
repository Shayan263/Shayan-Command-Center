import SwiftUI
import UIKit
import AVFoundation
import Speech

struct CoreCommandItem: Identifiable {
    let id: CoreDestination
    let title: String
    let subtitle: String
    let icon: String

    static let all: [CoreCommandItem] = [
        .init(id: .aiCommandCenter, title: "AI Command Centre", subtitle: "Command and automate tasks", icon: "sparkles"),
        .init(id: .quickActions, title: "Quick Actions", subtitle: "Open, copy and share", icon: "bolt.fill"),
        .init(id: .insights, title: "Insights", subtitle: "System and portfolio status", icon: "chart.bar.xaxis"),
        .init(id: .sentinel, title: "Core Sentinel", subtitle: "AI Security Intelligence", icon: "shield.checkered"),
        .init(id: .resume, title: "Shayan Resume Builder", subtitle: "Build and tailor resumes", icon: "doc.text.magnifyingglass"),
        .init(id: .learning, title: "Shayan Learning Hub", subtitle: "Learn, track and grow", icon: "graduationcap.fill"),
        .init(id: .protectedNotes, title: "Protected Notes", subtitle: "Secure Keychain notes", icon: "lock.text"),
        .init(id: .settings, title: "Settings", subtitle: "Security and preferences", icon: "gearshape")
    ]
}

struct CoreCommandView: View {
    @State private var query = ""

    private var results: [CoreCommandItem] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return CoreCommandItem.all }
        return CoreCommandItem.all.filter {
            $0.title.localizedCaseInsensitiveContains(trimmed) ||
            $0.subtitle.localizedCaseInsensitiveContains(trimmed)
        }
    }

    var body: some View {
        List {
            Section {
                ForEach(results) { item in
                    NavigationLink(value: item.id) {
                        Label {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(item.title).font(.body.weight(.semibold))
                                Text(item.subtitle).font(.caption).foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: item.icon).frame(width: 24)
                        }
                    }
                }
            } header: {
                Text(query.isEmpty ? "COMMANDS" : "\(results.count) RESULTS")
            } footer: {
                Text("Search is local and lightweight. Shayan Core only filters the available command catalog; it does not scan your private data.")
            }
        }
        .navigationTitle("Core Command")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $query, prompt: "What do you need?")
    }
}

private enum AICommandKind {
    case emailDraft(recipient: String, subject: String, body: String)
    case portfolioStatus
    case unsupported

    var title: String {
        switch self {
        case .emailDraft: return "Email draft"
        case .portfolioStatus: return "Portfolio status"
        case .unsupported: return "Command not recognized"
        }
    }
}

private struct AICommandPlan {
    let kind: AICommandKind
    let summary: String
    let requiresApproval: Bool
}

private struct AICommandEngine {
    func plan(_ input: String) -> AICommandPlan {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        let lower = text.lowercased()

        if lower.contains("email") || lower.contains("mail") {
            let recipient = extractEmail(from: text) ?? ""
            let subject = extractSubject(from: text)
            let body = extractBody(from: text) ?? text
            guard !recipient.isEmpty else {
                return AICommandPlan(kind: .unsupported, summary: "I need an email address to prepare the email.", requiresApproval: false)
            }
            return AICommandPlan(
                kind: .emailDraft(recipient: recipient, subject: subject, body: body),
                summary: "Prepare an email to \(recipient) for your review.",
                requiresApproval: true
            )
        }

        if lower.contains("portfolio") || lower.contains("website status") || lower.contains("dashboard status") {
            return AICommandPlan(kind: .portfolioStatus, summary: "Check the live portfolio dashboard and website status.", requiresApproval: false)
        }

        return AICommandPlan(kind: .unsupported, summary: "This command is not connected yet. The command engine is ready for more actions.", requiresApproval: false)
    }

    private func extractEmail(from text: String) -> String? {
        let pattern = "[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return nil }
        let range = NSRange(text.startIndex..., in: text)
        return regex.firstMatch(in: text, range: range).flatMap {
            Range($0.range, in: text).map { String(text[$0]) }
        }
    }

    private func extractSubject(from text: String) -> String {
        let lower = text.lowercased()
        guard let subjectRange = lower.range(of: "subject:") else { return "Message from Shayan Core" }
        let remainder = text[subjectRange.upperBound...]
        return remainder.split(separator: " ", maxSplits: 1).first.map(String.init) ?? "Message from Shayan Core"
    }

    private func extractBody(from text: String) -> String? {
        let lower = text.lowercased()
        for marker in ["saying ", "says ", "body:"] {
            if let range = lower.range(of: marker) {
                let body = text[range.upperBound...].trimmingCharacters(in: .whitespacesAndNewlines)
                if !body.isEmpty { return body }
            }
        }
        return nil
    }
}

struct AICommandCenterView: View {
    @StateObject private var voice = VoiceConversationController()
    @State private var command = ""
    @State private var plan: AICommandPlan?
    @State private var activity: [String] = []
    @State private var showMailUnavailable = false

    private let engine = AICommandEngine()

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                VStack(spacing: 6) {
                    Text("AI COMMAND CENTRE")
                        .font(.caption.weight(.bold))
                        .tracking(1.5)
                        .foregroundStyle(.blue)
                    Text("Talk to Shayan Core")
                        .font(.title.bold())
                    Text(voice.statusText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                VoiceOrb(voice: voice) {
                    Task { await toggleVoice() }
                }
                .frame(height: 310)

                Button {
                    Task { await toggleVoice() }
                } label: {
                    Label(
                        voice.isListening ? "Listening — tap to stop" : (voice.isSpeaking ? "Tap to interrupt" : "Tap to talk"),
                        systemImage: voice.isListening ? "waveform" : (voice.isSpeaking ? "hand.raised.fill" : "mic.fill")
                    )
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)

                if !voice.transcript.isEmpty {
                    conversationBubble(title: "YOU", text: voice.transcript, alignment: .trailing)
                }

                if !voice.reply.isEmpty {
                    conversationBubble(title: "SHAYAN CORE", text: voice.reply, alignment: .leading)
                }

                if let plan {
                    planCard(plan)
                }

                TextField("Type a command if you prefer…", text: $command, axis: .vertical)
                    .textFieldStyle(.plain)
                    .padding(14)
                    .background(Color.primary.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .onSubmit { submitTypedCommand() }

                if !activity.isEmpty {
                    VStack(alignment: .leading, spacing: 9) {
                        Text("ACTIVITY")
                            .font(.caption.weight(.bold))
                            .tracking(1)
                            .foregroundStyle(.secondary)
                        ForEach(activity, id: \.self) { item in
                            Label(item, systemImage: "checkmark.circle.fill")
                                .font(.footnote)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                Text("Hands-free conversation • voice interruption • automatic turn-taking • approval-first actions")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
            }
            .padding(20)
        }
        .navigationTitle("AI Command Centre")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            voice.onFinalTranscript = { text in
                handleCommand(text)
            }
            voice.onError = { message in
                activity.insert(message, at: 0)
            }
        }
        .onDisappear {
            voice.shutdown()
        }
        .alert("Mail is not available", isPresented: $showMailUnavailable) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("The command was planned, but the iPhone could not open a mail composer.")
        }
    }

    @ViewBuilder
    private func conversationBubble(title: String, text: String, alignment: HorizontalAlignment) -> some View {
        VStack(alignment: alignment, spacing: 5) {
            Text(title)
                .font(.caption2.weight(.bold))
                .tracking(1)
                .foregroundStyle(.secondary)
            Text(text)
                .font(.body)
                .frame(maxWidth: .infinity, alignment: alignment == .trailing ? .trailing : .leading)
                .padding(13)
                .background(Color.primary.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .frame(maxWidth: .infinity, alignment: alignment == .trailing ? .trailing : .leading)
    }

    @ViewBuilder
    private func planCard(_ plan: AICommandPlan) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(plan.kind.title, systemImage: "wand.and.stars")
                .font(.headline)

            Text(plan.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if case let .emailDraft(recipient, subject, body) = plan.kind {
                VStack(alignment: .leading, spacing: 7) {
                    Text("TO  \(recipient)").font(.caption.weight(.bold))
                    Text("SUBJECT  \(subject)").font(.caption.weight(.semibold))
                    Text(body).font(.footnote).foregroundStyle(.secondary).lineLimit(5)
                }
                .padding(13)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.primary.opacity(0.045))
                .clipShape(RoundedRectangle(cornerRadius: 14))

                Button {
                    openEmail(recipient: recipient, subject: subject, body: body)
                } label: {
                    Label("Approve & Open in Mail", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(16)
        .background(Color.blue.opacity(0.07))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.blue.opacity(0.15), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func toggleVoice() async {
        if voice.isSpeaking {
            voice.interrupt()
            await voice.startListening()
        } else if voice.isListening {
            voice.stopListening()
        } else {
            await voice.startListening()
        }
    }

    private func handleCommand(_ text: String) {
        let lower = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        if let existing = plan,
           case let .emailDraft(recipient, subject, body) = existing.kind,
           ["yes", "yeah", "yep", "send it", "open it", "do it", "approve", "approved"].contains(where: { lower.contains($0) }) {
            openEmail(recipient: recipient, subject: subject, body: body)
            voice.reply = "Done. I opened the email for \(recipient) so you can review it."
            voice.speak(voice.reply)
            return
        }

        command = text
        let newPlan = engine.plan(text)
        plan = newPlan

        switch newPlan.kind {
        case .emailDraft(let recipient, _, _):
            voice.reply = "I prepared an email to \(recipient). Review it, then say yes when you want me to open it."
        case .portfolioStatus:
            voice.reply = "Your portfolio status command is ready. The live status is available on the Home dashboard."
        case .unsupported:
            voice.reply = newPlan.summary
        }

        voice.speak(voice.reply)
    }

    private func submitTypedCommand() {
        guard !command.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        handleCommand(command)
    }

    private func openEmail(recipient: String, subject: String, body: String) {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = recipient
        components.queryItems = [
            URLQueryItem(name: "subject", value: subject),
            URLQueryItem(name: "body", value: body)
        ]

        guard let url = components.url else {
            showMailUnavailable = true
            return
        }

        UIApplication.shared.open(url) { success in
            if success {
                activity.insert("Email prepared for \(recipient)", at: 0)
            } else {
                showMailUnavailable = true
            }
        }
    }
}

private struct VoiceOrb: View {
    @ObservedObject var voice: VoiceConversationController
    let onTap: () -> Void
    @State private var ringRotation = 0.0
    @State private var pulse = false

    private var active: Bool { voice.isListening || voice.isSpeaking }

    var body: some View {
        ZStack {
            Circle()
                .fill(.blue.opacity(active ? 0.08 : 0.045))
                .frame(width: 292, height: 292)
                .scaleEffect(active ? (pulse ? 1.04 : 0.94) : 1)

            Circle()
                .stroke(
                    LinearGradient(colors: [.cyan.opacity(0.7), .blue.opacity(0.12), .cyan.opacity(0.7)],
                                   startPoint: .leading,
                                   endPoint: .trailing),
                    lineWidth: 3
                )
                .frame(width: 248, height: 248)
                .rotationEffect(.degrees(ringRotation))

            Circle()
                .stroke(.blue.opacity(active ? 0.35 : 0.12), lineWidth: 2)
                .frame(width: 216, height: 216)
                .scaleEffect(active ? (pulse ? 1.05 : 0.96) : 1)

            Button(action: onTap) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .blue.opacity(active ? 0.42 : 0.24), radius: active ? 30 : 18)

                    VStack(spacing: 10) {
                        Image(systemName: voice.iconName)
                            .font(.system(size: 40, weight: .semibold))
                            .foregroundStyle(.white)

                        VoiceWave(active: active)
                            .frame(width: 82, height: 25)

                        Text(voice.phaseTitle)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.white)

                        Text(voice.phaseSubtitle)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.84))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .frame(maxWidth: 145)
                    }
                }
                .frame(width: 176, height: 176)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("AI Command Centre voice control")
        }
        .contentShape(Circle())
        .onAppear {
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                ringRotation = 360
            }
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
        .animation(.easeInOut(duration: 0.8), value: active)
    }
}

private struct VoiceWave: View {
    let active: Bool
    @State private var phase = false

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<9, id: \.self) { index in
                VoiceWaveBar(index: index, active: active, phase: phase)
            }
        }
        .frame(width: 82, height: 25)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.55).repeatForever(autoreverses: true)) {
                phase = true
            }
        }
    }
}

private struct VoiceWaveBar: View {
    let index: Int
    let active: Bool
    let phase: Bool

    private var height: CGFloat {
        guard active else { return 7 }
        let forward = [8, 12, 17, 13, 20, 14, 18, 11, 8]
        let reverse = [12, 17, 10, 20, 13, 18, 11, 16, 12]
        return phase ? CGFloat(forward[index]) : CGFloat(reverse[index])
    }

    var body: some View {
        Capsule()
            .fill(.white.opacity(active ? 0.9 : 0.42))
            .frame(width: 4, height: height)
    }
}

@MainActor
private final class VoiceConversationController: NSObject, ObservableObject {
    @Published var isListening = false
    @Published var isSpeaking = false
    @Published var transcript = ""
    @Published var reply = ""
    @Published var statusText = "Tap the circle and start talking"
    @Published var phaseTitle = "READY"
    @Published var phaseSubtitle = "Tap once and speak naturally"
    @Published var iconName = "mic.fill"

    var onFinalTranscript: ((String) -> Void)?
    var onError: ((String) -> Void)?

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let audioEngine = AVAudioEngine()
    private let synthesizer = AVSpeechSynthesizer()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var silenceTask: Task<Void, Never>?
    private var turnCommitted = false
    private var hasAuthorized = false
    private var shouldContinueConversation = true

    func startListening() async {
        if isSpeaking {
            interrupt()
        }
        guard !isListening else { return }

        let authorized = await ensurePermissions()
        guard authorized else { return }

        guard speechRecognizer?.isAvailable != false else {
            fail("Speech recognition is temporarily unavailable.")
            return
        }

        do {
            try configureAudioSession()

            transcript = ""
            turnCommitted = false
            shouldContinueConversation = true
            statusText = "Listening…"
            phaseTitle = "LISTENING"
            phaseSubtitle = "Speak naturally — no stop button needed"
            iconName = "waveform"
            isListening = true

            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest else { return }
            recognitionRequest.shouldReportPartialResults = true
            recognitionRequest.taskHint = .dictation

            recognitionTask?.cancel()
            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
                Task { @MainActor in
                    guard let self else { return }

                    if let result {
                        self.transcript = result.bestTranscription.formattedString
                        self.armSilenceTimeout()

                        if result.isFinal {
                            self.commitTurn()
                        }
                    }

                    if error != nil, self.isListening, !self.turnCommitted {
                        self.commitTurn()
                    }
                }
            }

            let inputNode = audioEngine.inputNode
            let format = inputNode.outputFormat(forBus: 0)
            inputNode.removeTap(onBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
                self?.recognitionRequest?.append(buffer)
            }

            audioEngine.prepare()
            try audioEngine.start()
            armSilenceTimeout(initial: true)
        } catch {
            stopListening()
            fail("I couldn't start the microphone.")
        }
    }

    func stopListening() {
        shouldContinueConversation = false
        silenceTask?.cancel()
        silenceTask = nil
        endRecognition()
        setReady()
    }

    func interrupt() {
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
        shouldContinueConversation = false
        phaseTitle = "LISTENING"
        phaseSubtitle = "Go ahead"
        iconName = "waveform"
        statusText = "Listening…"
    }

    func speak(_ text: String) {
        silenceTask?.cancel()
        endRecognition()
        shouldContinueConversation = true

        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = true
        isListening = false
        phaseTitle = "SPEAKING"
        phaseSubtitle = "Shayan Core is replying"
        iconName = "speaker.wave.2.fill"
        statusText = "Speaking…"

        do {
            try configureAudioSession()
        } catch {
            onError?("Audio output could not be configured.")
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.48
        utterance.pitchMultiplier = 1.0
        synthesizer.delegate = self
        synthesizer.speak(utterance)
    }

    func shutdown() {
        shouldContinueConversation = false
        silenceTask?.cancel()
        silenceTask = nil
        synthesizer.stopSpeaking(at: .immediate)
        endRecognition()
    }

    private func ensurePermissions() async -> Bool {
        if !hasAuthorized {
            let speechStatus: SFSpeechRecognizerAuthorizationStatus
            switch SFSpeechRecognizer.authorizationStatus() {
            case .authorized:
                speechStatus = .authorized
            case .notDetermined:
                speechStatus = await requestSpeechAuthorization()
            default:
                speechStatus = SFSpeechRecognizer.authorizationStatus()
            }

            guard speechStatus == .authorized else {
                fail("Speech recognition permission is required.")
                return false
            }

            let recordPermission = AVAudioSession.sharedInstance().recordPermission
            let microphoneGranted: Bool
            if recordPermission == .undetermined {
                microphoneGranted = await requestMicrophonePermission()
            } else {
                microphoneGranted = recordPermission == .granted
            }

            guard microphoneGranted else {
                fail("Microphone permission is required.")
                return false
            }

            hasAuthorized = true
        }
        return true
    }

    private func commitTurn() {
        guard !turnCommitted else { return }
        turnCommitted = true
        silenceTask?.cancel()
        silenceTask = nil

        let finalText = transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        endRecognition()

        guard !finalText.isEmpty else {
            setReady()
            return
        }

        phaseTitle = "THINKING"
        phaseSubtitle = "Working on that…"
        iconName = "sparkles"
        statusText = "Thinking…"
        onFinalTranscript?(finalText)
    }

    private func armSilenceTimeout(initial: Bool = false) {
        silenceTask?.cancel()
        let delay: Duration = initial ? .seconds(4.5) : .seconds(2.0)
        silenceTask = Task { [weak self] in
            try? await Task.sleep(for: delay)
            guard !Task.isCancelled else { return }
            await MainActor.run {
                self?.commitTurn()
            }
        }
    }

    private func endRecognition() {
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        isListening = false
    }

    private func setReady() {
        guard !isSpeaking else { return }
        phaseTitle = "READY"
        phaseSubtitle = "Tap once and speak naturally"
        iconName = "mic.fill"
        statusText = "Ready"
    }

    private func configureAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(
            .playAndRecord,
            mode: .voiceChat,
            options: [.defaultToSpeaker, .allowBluetooth, .allowBluetoothA2DP, .duckOthers]
        )
        try session.setActive(true, options: .notifyOthersOnDeactivation)
    }

    private func requestSpeechAuthorization() async -> SFSpeechRecognizerAuthorizationStatus {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
    }

    private func requestMicrophonePermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    private func fail(_ message: String) {
        statusText = message
        phaseTitle = "READY"
        phaseSubtitle = "Tap once to try again"
        iconName = "mic.fill"
        onError?(message)
    }
}

extension VoiceConversationController: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
            self.phaseTitle = "READY"
            self.phaseSubtitle = "Listening for your next request…"
            self.iconName = "mic.fill"
            self.statusText = "Listening automatically…"

            guard self.shouldContinueConversation else { return }
            try? await Task.sleep(for: .milliseconds(250))
            guard self.shouldContinueConversation else { return }
            await self.startListening()
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
        }
    }
}

