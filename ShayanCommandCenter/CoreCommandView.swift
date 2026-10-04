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
    @State private var pulse = false

    private let engine = AICommandEngine()

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                VStack(spacing: 7) {
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

                ZStack {
                    Circle()
                        .fill(.blue.opacity(0.06))
                        .frame(width: 280, height: 280)
                        .scaleEffect(voice.isListening ? (pulse ? 1.08 : 0.94) : 1)
                        .animation(
                            voice.isListening
                                ? .easeInOut(duration: 1.05).repeatForever(autoreverses: true)
                                : .easeOut(duration: 0.25),
                            value: pulse
                        )

                    Circle()
                        .stroke(.blue.opacity(voice.isListening ? 0.35 : 0.12), lineWidth: 2)
                        .frame(width: 222, height: 222)
                        .scaleEffect(voice.isListening ? (pulse ? 1.06 : 0.96) : 1)
                        .animation(
                            voice.isListening
                                ? .easeInOut(duration: 0.85).repeatForever(autoreverses: true)
                                : .easeOut(duration: 0.25),
                            value: pulse
                        )

                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .cyan],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: .blue.opacity(0.28), radius: 28)

                        Circle()
                            .stroke(.white.opacity(0.3), lineWidth: 1)

                        VStack(spacing: 10) {
                            Image(systemName: voice.iconName)
                                .font(.system(size: 42, weight: .semibold))
                                .foregroundStyle(.white)
                                .symbolEffect(.pulse, isActive: voice.isListening || voice.isSpeaking)

                            Text(voice.phaseTitle)
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(.white)

                            Text(voice.phaseSubtitle)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.82))
                        }
                    }
                    .frame(width: 170, height: 170)
                }
                .frame(maxWidth: .infinity)
                .contentShape(Circle())
                .onTapGesture {
                    Task { await toggleListening() }
                }

                Button {
                    Task { await toggleListening() }
                } label: {
                    Label(voice.isListening ? "Stop Listening" : "Tap to Talk", systemImage: voice.isListening ? "stop.fill" : "mic.fill")
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

                TextField("Or type a command…", text: $command, axis: .vertical)
                    .textFieldStyle(.plain)
                    .padding(14)
                    .background(Color.primary.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .onSubmit {
                        submitTypedCommand()
                    }

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

                Text("Voice is handled on-device. Actions remain approval-first.")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(20)
        }
        .navigationTitle("AI Command Centre")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            pulse = true
            voice.onFinalTranscript = { text in
                handleCommand(text)
            }
            voice.onError = { message in
                activity.insert(message, at: 0)
            }
        }
        .onDisappear {
            voice.stopListening()
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

    private func toggleListening() async {
        if voice.isListening {
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

@MainActor
private final class VoiceConversationController: NSObject, ObservableObject {
    @Published var isListening = false
    @Published var isSpeaking = false
    @Published var transcript = ""
    @Published var reply = ""
    @Published var statusText = "Tap the circle and start talking"
    @Published var phaseTitle = "READY"
    @Published var phaseSubtitle = "I'm listening when you are"
    @Published var iconName = "mic.fill"

    var onFinalTranscript: ((String) -> Void)?
    var onError: ((String) -> Void)?

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let audioEngine = AVAudioEngine()
    private let synthesizer = AVSpeechSynthesizer()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    func startListening() async {
        guard !isListening else { return }

        let speechStatus = await requestSpeechAuthorization()
        guard speechStatus == .authorized else {
            fail("Speech recognition permission is required.")
            return
        }

        let microphoneGranted = await requestMicrophonePermission()
        guard microphoneGranted else {
            fail("Microphone permission is required.")
            return
        }

        do {
            try configureAudioSession()

            transcript = ""
            statusText = "Listening…"
            phaseTitle = "LISTENING"
            phaseSubtitle = "Tell me what you need"
            iconName = "waveform"
            isListening = true

            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest else { return }
            recognitionRequest.shouldReportPartialResults = true

            recognitionTask?.cancel()
            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
                Task { @MainActor in
                    guard let self else { return }

                    if let result {
                        self.transcript = result.bestTranscription.formattedString

                        if result.isFinal {
                            let finalText = result.bestTranscription.formattedString
                            self.stopListening()
                            self.phaseTitle = "THINKING"
                            self.phaseSubtitle = "Working on that…"
                            self.iconName = "sparkles"
                            self.statusText = "Thinking…"
                            self.onFinalTranscript?(finalText)
                        }
                    }

                    if let error, self.isListening {
                        self.stopListening()
                        self.fail("I couldn't hear that clearly. Please try again.")
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
        } catch {
            stopListening()
            fail("I couldn't start the microphone.")
        }
    }

    func stopListening() {
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        isListening = false

        if !isSpeaking {
            phaseTitle = "READY"
            phaseSubtitle = "Tap the circle and talk again"
            iconName = "mic.fill"
            statusText = "Ready for your next command"
        }
    }

    func speak(_ text: String) {
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = true
        phaseTitle = "SPEAKING"
        phaseSubtitle = "Shayan Core is replying"
        iconName = "speaker.wave.2.fill"
        statusText = "Speaking…"

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        synthesizer.delegate = self
        synthesizer.speak(utterance)
    }

    private func configureAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .voiceChat, options: [.defaultToSpeaker, .duckOthers])
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
        phaseSubtitle = "Tap the circle to try again"
        iconName = "mic.fill"
        onError?(message)
    }
}

extension VoiceConversationController: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
            self.phaseTitle = "READY"
            self.phaseSubtitle = "Tap the circle and talk again"
            self.iconName = "mic.fill"
            self.statusText = "Ready for your next command"
        }
    }
}
