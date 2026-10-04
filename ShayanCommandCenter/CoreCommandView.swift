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
        .init(id: .aiCommandCenter, title: "AI Manager", subtitle: "Talk, type and automate tasks", icon: "sparkles"),
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
    case connectGmail
    case emailSummary(query: String)
    case portfolioStatus
    case navigate(CoreDestination, String)
    case navigateHome
    case openURL(URL, String)
    case unsupported

    var title: String {
        switch self {
        case .emailDraft: return "Email draft"
        case .connectGmail: return "Connect Gmail"
        case .emailSummary: return "Email summary"
        case .portfolioStatus: return "Portfolio status"
        case .navigate: return "Opening Shayan Core"
        case .navigateHome: return "Going Home"
        case .openURL: return "Opening"
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
    private let dashboardURL = URL(string: "https://shayan263.github.io/Shayan_Profile/admin.html")!
    private let websiteURL = URL(string: "https://shayan263.github.io/Shayan_Profile/")!
    private let githubURL = URL(string: "https://github.com/Shayan263")!
    private let linkedInURL = URL(string: "https://www.linkedin.com/")!

    func plan(_ input: String) -> AICommandPlan {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        let lower = text.lowercased()
        AIManagerContext.shared.observe(text)

        if let action = routeAction(lower) { return action }

        if lower.contains("connect gmail") || lower.contains("connect my gmail") {
            return AICommandPlan(kind: .connectGmail, summary: "I'll connect your Gmail with read-only access.", requiresApproval: false)
        }

        if lower.contains("email") || lower.contains("mail") {
            let readWords = ["check my email", "check my emails", "read my email", "read my emails", "unread", "latest emails", "recent emails", "summarize my email", "summarize my emails", "what are my emails about", "what's in my email", "inbox", "what did i get"]
            if readWords.contains(where: { lower.contains($0) }) {
                let query = lower.contains("unread") ? "in:inbox is:unread" : "in:inbox"
                return AICommandPlan(kind: .emailSummary(query: query), summary: "I'll read the latest Gmail messages and give you the important points.", requiresApproval: false)
            }

            let recipient = extractEmail(from: text) ?? ""
            let subject = extractSubject(from: text)
            let body = extractBody(from: text) ?? text
            guard !recipient.isEmpty else {
                return AICommandPlan(kind: .unsupported, summary: "Tell me the email address and what you want me to say.", requiresApproval: false)
            }
            return AICommandPlan(kind: .emailDraft(recipient: recipient, subject: subject, body: body),
                                 summary: "I prepared an email to \(recipient). I'll wait for your approval before opening Mail.",
                                 requiresApproval: true)
        }

        if lower.contains("portfolio status") || lower.contains("website status") ||
            lower.contains("dashboard status") || lower.contains("is my portfolio") ||
            lower.contains("is the dashboard") || lower.contains("is the website") ||
            lower.hasPrefix("check ") {
            return AICommandPlan(kind: .portfolioStatus, summary: "I'll check the live portfolio systems.", requiresApproval: false)
        }

        return AICommandPlan(
            kind: .unsupported,
            summary: "I don't have an action mapped for that yet. Try: open dashboard, open website, open learning hub, open settings, open security, scan QR, or open notes.",
            requiresApproval: false
        )
    }

    private func routeAction(_ lower: String) -> AICommandPlan? {
        let openVerbs = ["open ", "launch ", "show ", "go to ", "take me to ", "visit "]
        let isOpenRequest = openVerbs.contains(where: { lower.hasPrefix($0) })

        if lower == "dashboard" || (isOpenRequest && containsAny(lower, ["dashboard", "admin dashboard", "portfolio dashboard"])) {
            return AICommandPlan(kind: .openURL(dashboardURL, "Opening your private portfolio dashboard."), summary: "Opening your private portfolio dashboard.", requiresApproval: false)
        }
        if lower == "website" || lower == "my website" || (isOpenRequest && containsAny(lower, ["website", "portfolio website", "my portfolio"])) {
            return AICommandPlan(kind: .openURL(websiteURL, "Opening your portfolio website."), summary: "Opening your portfolio website.", requiresApproval: false)
        }
        if isOpenRequest && containsAny(lower, ["github", "git hub", "repositories"]) {
            return AICommandPlan(kind: .openURL(githubURL, "Opening your GitHub profile."), summary: "Opening your GitHub profile.", requiresApproval: false)
        }
        if isOpenRequest && containsAny(lower, ["linkedin", "linked in"]) {
            return AICommandPlan(kind: .openURL(linkedInURL, "Opening LinkedIn."), summary: "Opening LinkedIn.", requiresApproval: false)
        }
        if isOpenRequest && containsAny(lower, ["home", "home screen"]) {
            return AICommandPlan(kind: .navigateHome, summary: "Returning to Home.", requiresApproval: false)
        }
        if isOpenRequest && containsAny(lower, ["ai manager", "ai command", "command centre", "command center", "voice agent"]) {
            return AICommandPlan(kind: .navigate(.aiCommandCenter, "Opening AI Manager."), summary: "Opening AI Manager.", requiresApproval: false)
        }
        if isOpenRequest && containsAny(lower, ["quick actions", "quick action"]) {
            return AICommandPlan(kind: .navigate(.quickActions, "Opening Quick Actions."), summary: "Opening Quick Actions.", requiresApproval: false)
        }
        if isOpenRequest && containsAny(lower, ["insights", "insight"]) {
            return AICommandPlan(kind: .navigate(.insights, "Opening Insights."), summary: "Opening Insights.", requiresApproval: false)
        }
        if isOpenRequest && containsAny(lower, ["security", "sentinel", "security centre", "security center"]) {
            return AICommandPlan(kind: .navigate(.sentinel, "Opening Core Sentinel."), summary: "Opening Core Sentinel.", requiresApproval: false)
        }
        if isOpenRequest && containsAny(lower, ["resume", "resume builder"]) {
            return AICommandPlan(kind: .navigate(.resume, "Opening Resume Builder."), summary: "Opening Resume Builder.", requiresApproval: false)
        }
        if isOpenRequest && containsAny(lower, ["learning hub", "learning", "ai automations"]) {
            return AICommandPlan(kind: .navigate(.learning, "Opening Learning Hub."), summary: "Opening Learning Hub.", requiresApproval: false)
        }
        if isOpenRequest && containsAny(lower, ["protected notes", "notes", "secure notes"]) {
            return AICommandPlan(kind: .navigate(.protectedNotes, "Opening Protected Notes."), summary: "Opening Protected Notes.", requiresApproval: false)
        }
        if isOpenRequest && containsAny(lower, ["settings", "preferences"]) {
            return AICommandPlan(kind: .navigate(.settings, "Opening Settings."), summary: "Opening Settings.", requiresApproval: false)
        }
        if isOpenRequest && containsAny(lower, ["profile", "my profile"]) {
            return AICommandPlan(kind: .navigate(.profile, "Opening your profile."), summary: "Opening your profile.", requiresApproval: false)
        }
        if containsAny(lower, ["scan qr", "scan a qr", "qr code", "qr scanner"]) {
            return AICommandPlan(kind: .navigate(.qrScanner, "Opening QR Scanner."), summary: "Opening QR Scanner.", requiresApproval: false)
        }
        return nil
    }

    private func containsAny(_ text: String, _ values: [String]) -> Bool {
        values.contains(where: { text.contains($0) })
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
        let remainder = text[subjectRange.upperBound...].trimmingCharacters(in: .whitespacesAndNewlines)
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
@MainActor
private final class GmailAISummaryService {
    static let shared = GmailAISummaryService()

    private let endpoint = URL(string: "https://api.openai.com/v1/responses")!
    private let model = "gpt-6-luna"
    private let session: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.waitsForConnectivity = false
        configuration.timeoutIntervalForRequest = 18
        configuration.timeoutIntervalForResource = 22
        configuration.httpMaximumConnectionsPerHost = 4
        return URLSession(configuration: configuration)
    }()

    private struct ResponseItem: Decodable {
        let type: String
        let content: [ContentItem]?
    }

    private struct ContentItem: Decodable {
        let type: String
        let text: String?
    }

    private struct ResponseEnvelope: Decodable {
        let output: [ResponseItem]
        var text: String {
            var parts: [String] = []
            for item in output {
                guard item.type == "message", let content = item.content else { continue }
                for part in content {
                    if part.type == "output_text", let text = part.text { parts.append(text) }
                }
            }
            return parts.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    func summarize(emails: [GmailMessageSummary], question: String?) async throws -> String {
        let apiKey = Self.loadAPIKey()
        guard !apiKey.isEmpty else {
            throw GmailToolError.api("OpenAI is not connected. Add your OpenAI API key in Workspace first.")
        }

        var lines: [String] = []
        for (index, email) in emails.prefix(6).enumerated() {
            lines.append("\(index + 1). From: \(email.sender) | Subject: \(email.subject) | Preview: \(email.snippet)")
        }

        let followUp = question.map { "\nFollow-up question: \($0)" } ?? ""
        let prompt = """
        You are AI Manager's email manager.
        Summarize the user's Gmail clearly for voice playback.
        Be concise: maximum 5 short sentences.
        Start with the overall situation, then mention the most important messages and what each is about.
        Mention urgency or action needed when it is obvious from the subject/preview.
        Do not invent details that are not present.
        Do not read long email text verbatim.
        Email messages:
        \(lines.joined(separator: "\n"))
        \(followUp)
        """

        let body: [String: Any] = [
            "model": model,
            "input": [["role": "user", "content": prompt]],
            "instructions": "You are a fast, concise voice assistant. Answer directly and naturally; no markdown unless needed.",
            "max_output_tokens": 300
        ]

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.timeoutInterval = 18
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw GmailToolError.invalidResponse }
        guard (200...299).contains(http.statusCode) else {
            let message = (try? JSONSerialization.jsonObject(with: data) as? [String: Any])
                .flatMap { ($0["error"] as? [String: Any])?["message"] as? String }
            throw GmailToolError.api(message ?? "OpenAI returned HTTP \(http.statusCode).")
        }

        let result = try JSONDecoder().decode(ResponseEnvelope.self, from: data)
        guard !result.text.isEmpty else { throw GmailToolError.invalidResponse }
        return result.text
    }

    private static func loadAPIKey() -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.shayan.commandcentre.openai",
            kSecAttrAccount as String: "api-key",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return "" }
        return String(data: data, encoding: .utf8) ?? ""
    }
}

@MainActor
private final class AIManagerContext {
    static let shared = AIManagerContext()
    private var recentTurns: [String] = []
    private(set) var learnedPreferences: [String] = []

    func observe(_ text: String) {
        recentTurns.append(text)
        recentTurns = Array(recentTurns.suffix(8))
        let lower = text.lowercased()
        let signals: [(String, String)] = [
            ("short", "Prefer concise responses."),
            ("brief", "Prefer concise responses."),
            ("quick", "Prefer concise responses."),
            ("explain more", "Provide more detail when explicitly requested."),
            ("more detail", "Provide more detail when explicitly requested."),
            ("deep dive", "Provide more detail when explicitly requested."),
            ("just do it", "When an authorized action is clear, avoid unnecessary confirmation questions."),
            ("go ahead", "When an authorized action is clear, avoid unnecessary confirmation questions.")
        ]
        for (trigger, preference) in signals where lower.contains(trigger) && !learnedPreferences.contains(preference) {
            learnedPreferences.append(preference)
        }
        learnedPreferences = Array(learnedPreferences.suffix(8))
    }

    func previousRequest() -> String? {
        recentTurns.dropLast().last
    }

    func resetConversation() {
        recentTurns.removeAll(keepingCapacity: true)
    }
}

private enum AIManagerBehavior {
    static let taskAreas = [
        "professional and career tasks",
        "SAP ABAP and S/4HANA",
        "portfolio, recruiter, resume and LinkedIn work",
        "learning and productivity",
        "research and general questions"
    ]

    static let principles = [
        "Facts before assumptions.",
        "Never fabricate skills, projects, clients, metrics, certifications, dates or responsibilities.",
        "Prefer small incremental improvements over unnecessary redesigns.",
        "For consequential professional changes: Finding → Impact → Recommendation → Approval.",
        "GitHub is read/analyze/recommend only for the AI Manager; never mutate GitHub.",
        "Use conversation context for references such as 'the second one' or 'tell me more'.",
        "Clarify only when ambiguity could cause the wrong action.",
        "Keep voice responses concise and natural.",
        "Prioritize safety, accuracy, user control and performance."
    ]
}

private enum InteractionMode: String, CaseIterable {
    case voice = "Voice"
    case chat = "Chat"
}

struct AICommandCenterView: View {
    @StateObject private var voice = VoiceConversationController()
    @State private var command = ""
    @State private var plan: AICommandPlan?
    @State private var activity: [String] = []
    @State private var showMailUnavailable = false
    @State private var lastEmails: [GmailMessageSummary] = []
    @State private var emailTaskInFlight = false
    @State private var route: CoreDestination?
    @State private var interactionMode: InteractionMode = .voice
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    private let engine = AICommandEngine()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("AI MANAGER").font(.caption.weight(.bold)).tracking(1.5).foregroundStyle(.blue)
                    Text(voice.statusText).font(.subheadline).foregroundStyle(.secondary)
                }

                Picker("Interaction", selection: $interactionMode) {
                    ForEach(InteractionMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)

                VoiceOrb(voice: voice) { Task { await toggleVoice() } }
                    .frame(height: 280)
                    .opacity(interactionMode == .voice ? 1 : 0.72)

                if !voice.transcript.isEmpty {
                    conversationBubble(title: "YOU", text: voice.transcript, alignment: .trailing)
                }
                if !voice.reply.isEmpty {
                    conversationBubble(title: "AI MANAGER", text: voice.reply, alignment: .leading)
                }
                if let plan, plan.requiresApproval {
                    planCard(plan)
                }

                HStack(alignment: .bottom, spacing: 8) {
                    TextField("Type to chat with AI Manager…", text: $command, axis: .vertical)
                        .textFieldStyle(.plain)
                        .padding(13)
                        .onSubmit { submitTypedCommand() }

                    Button {
                        submitTypedCommand()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 28))
                    }
                    .disabled(command.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .padding(.bottom, 8)
                }
                .padding(.horizontal, 5)
                .background(Color.primary.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 15))

                if !activity.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ACTIVITY").font(.caption.weight(.bold)).tracking(1).foregroundStyle(.secondary)
                        ForEach(activity.prefix(4), id: \.self) { item in
                            Label(item, systemImage: "checkmark.circle.fill").font(.footnote)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                Text("Talk naturally • interrupt anytime • type whenever you want • AI Manager listens again after every reply")
                    .font(.caption).foregroundStyle(.tertiary).multilineTextAlignment(.center)
            }
            .padding(.horizontal, 18)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .background(Color(.systemBackground))
        .navigationTitle("AI Manager")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $route) { destination in
            CoreDestinationView(destination: destination, openExternal: { url in openURL(url) })
        }
        .task {
            voice.onFinalTranscript = { text in handleCommand(text) }
            voice.onError = { message in activity.insert(message, at: 0) }
            if interactionMode == .voice {
                await voice.startListening()
            }
        }
        .onChange(of: interactionMode) { mode in
            if mode == .voice {
                Task { await voice.startListening() }
            } else {
                voice.stopListening()
            }
        }
        .onDisappear {
            voice.shutdown()
            AIManagerContext.shared.resetConversation()
        }
        .alert("Mail is not available", isPresented: $showMailUnavailable) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("The command was planned, but the iPhone could not open a mail composer.")
        }
    }

    @ViewBuilder
    private func conversationBubble(title: String, text: String, alignment: HorizontalAlignment) -> some View {
        VStack(alignment: alignment, spacing: 4) {
            Text(title).font(.caption2.weight(.bold)).tracking(1).foregroundStyle(.secondary)
            Text(text)
                .font(.body)
                .frame(maxWidth: .infinity, alignment: alignment == .trailing ? .trailing : .leading)
                .padding(12)
                .background(Color.primary.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 15))
        }
        .frame(maxWidth: .infinity, alignment: alignment == .trailing ? .trailing : .leading)
    }

    @ViewBuilder
    private func planCard(_ plan: AICommandPlan) -> some View {
        VStack(alignment: .leading, spacing: 11) {
            Label(plan.kind.title, systemImage: "wand.and.stars").font(.headline)
            Text(plan.summary).font(.subheadline).foregroundStyle(.secondary)
            if case let .emailDraft(recipient, subject, body) = plan.kind {
                VStack(alignment: .leading, spacing: 7) {
                    Text("TO  \(recipient)").font(.caption.weight(.bold))
                    Text("SUBJECT  \(subject)").font(.caption.weight(.semibold))
                    Text(body).font(.footnote).foregroundStyle(.secondary).lineLimit(4)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.primary.opacity(0.045))
                .clipShape(RoundedRectangle(cornerRadius: 13))
                Button {
                    openEmail(recipient: recipient, subject: subject, body: body)
                } label: {
                    Label("Approve & Open in Mail", systemImage: "checkmark.circle.fill").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(15)
        .background(Color.blue.opacity(0.07))
        .overlay(RoundedRectangle(cornerRadius: 17).stroke(Color.blue.opacity(0.15), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 17))
    }

    private func toggleVoice() async {
        if voice.isSpeaking {
            voice.interrupt()
            return
        }
        if !voice.isListening {
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

        if let contextualReply = contextualResponse(for: lower) {
            voice.reply = contextualReply
            voice.speak(contextualReply)
            return
        }

        if isGreeting(lower) {
            voice.reply = greetingReply()
            voice.speak(voice.reply)
            return
        }

        if isBasicAssistantCommand(lower) {
            voice.reply = basicAssistantReply(for: lower)
            voice.speak(voice.reply)
            return
        }

        let followUpWords = ["tell me more", "more about", "explain that", "what about the second", "what about the first", "which one is important", "is anything urgent"]
        if !lastEmails.isEmpty && followUpWords.contains(where: { lower.contains($0) }) {
            voice.phaseTitle = "THINKING"
            voice.phaseSubtitle = "Using the email context…"
            voice.statusText = "Thinking…"
            Task { await summarizeEmails(query: "in:inbox", followUp: text) }
            return
        }

        let newPlan = engine.plan(text)
        plan = newPlan
        execute(newPlan)
    }

    private func execute(_ newPlan: AICommandPlan) {
        switch newPlan.kind {
        case .emailDraft(let recipient, _, _):
            voice.reply = "I prepared an email to \(recipient). Say yes when you want me to open Mail."
            voice.speak(voice.reply)
        case .connectGmail:
            voice.reply = "Opening Google now. Give Gmail read-only access and I'll handle the rest."
            voice.speak(voice.reply)
            Task { await connectGmail() }
        case .emailSummary(let query):
            Task { await summarizeEmails(query: query, followUp: nil) }
        case .portfolioStatus:
            voice.reply = "I'm checking the live portfolio systems. The latest status is on your Home dashboard."
            voice.speak(voice.reply)
        case .navigate(let destination, let message):
            voice.reply = message
            voice.speak(message)
            route = destination
        case .navigateHome:
            voice.reply = "Going home."
            voice.speak(voice.reply)
            dismiss()
        case .openURL(let url, let message):
            voice.reply = message
            voice.speak(message)
            openURL(url)
        case .unsupported:
            voice.reply = localTaskResponse(for: text)
            voice.speak(voice.reply)
        }
    }


    private func contextualResponse(for lower: String) -> String? {
        let references = [
            "tell me more", "more about that", "explain that",
            "what about the second one", "what about the first one",
            "what about it", "do that", "open it"
        ]
        guard references.contains(lower) else { return nil }

        if let previous = AIManagerContext.shared.previousRequest() {
            return "I have your previous request in context: (previous). Tell me which part you want me to continue with."
        }
        return "I need a little more context to know what you mean."
    }

    private func localTaskResponse(for text: String) -> String {
        let lower = text.lowercased()

        if lower.contains("portfolio") || lower.contains("resume") || lower.contains("linkedin") || lower.contains("recruiter") {
            return "I can help with recruiter readability, ATS, technical clarity, accuracy, SEO, mobile usability, performance and security. I'll keep improvements incremental and factual."
        }

        if lower.contains("sap") || lower.contains("abap") || lower.contains("s4hana") || lower.contains("s/4") {
            return "I can help with SAP ABAP and S/4HANA questions, debugging, interfaces, enhancements, OData, CDS, RAP, CPI and related work, while keeping recommendations grounded in what you've actually confirmed."
        }

        if lower.contains("learn") || lower.contains("study") || lower.contains("course") {
            return "I can help structure your learning, explain concepts, compare approaches and turn a goal into practical next steps."
        }

        if lower.contains("research") || lower.contains("compare") || lower.contains("recommend") || lower.contains("opinion") {
            return "I'll compare the options, separate facts from my recommendation, and give you the practical trade-off."
        }

        if lower.contains("github") && (lower.contains("change") || lower.contains("modify") || lower.contains("push") || lower.contains("commit") || lower.contains("merge") || lower.contains("deploy")) {
            return "AI Manager can inspect GitHub and recommend or draft changes, but it will not modify GitHub."
        }

        if lower.contains("what do you know about me") || lower.contains("what do you know about my work") {
            return "I use the context you've explicitly given me about your work, projects and preferences. I won't invent missing details."
        }

        return "I understand the request, but I don't have a local action mapped for it yet. I can help with your portfolio, SAP work, career tasks, learning, productivity, research, Gmail and general questions."
    }

    private func connectGmail() async {
        do {
            try await GmailTool.shared.connect()
            let account = GmailTool.shared.accountEmail.map { " as \($0)" } ?? ""
            activity.insert("Gmail connected\(account)", at: 0)
            voice.reply = "Gmail is connected. What would you like to know?"
            voice.speak(voice.reply)
        } catch {
            activity.insert("Gmail connection failed", at: 0)
            voice.reply = error.localizedDescription
            voice.speak(voice.reply)
        }
    }

    private func summarizeEmails(query: String, followUp: String?) async {
        guard !emailTaskInFlight else { return }
        emailTaskInFlight = true
        defer { emailTaskInFlight = false }

        guard GmailTool.shared.isConnected else {
            voice.reply = "Your Gmail isn't connected yet. Say, connect my Gmail."
            voice.speak(voice.reply)
            return
        }

        voice.phaseTitle = "READING"
        voice.phaseSubtitle = "Checking your Gmail…"
        voice.statusText = "Reading email…"
        do {
            let emails: [GmailMessageSummary]
            if followUp != nil && !lastEmails.isEmpty {
                emails = lastEmails
            } else {
                emails = try await GmailTool.shared.recentMessages(query: query, maxResults: 6)
                lastEmails = emails
            }

            guard !emails.isEmpty else {
                voice.reply = "You don't have any matching messages right now."
                voice.speak(voice.reply)
                return
            }

            let answer = try await GmailAISummaryService.shared.summarize(emails: emails, question: followUp)
            activity.insert("Reviewed \(emails.count) Gmail messages", at: 0)
            voice.reply = answer
            voice.speak(answer)
        } catch {
            activity.insert("Gmail read failed", at: 0)
            voice.reply = "I couldn't read Gmail right now. \(error.localizedDescription)"
            voice.speak(voice.reply)
        }
    }
    private func submitTypedCommand() {
        let text = command.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        command = ""
        handleCommand(text)
    }

    private func isGreeting(_ text: String) -> Bool {
        let greetings = [
            "hi", "hello", "hey", "hi ai manager", "hello ai manager",
            "hey ai manager", "good morning", "good afternoon", "good evening"
        ]
        return greetings.contains(text) || greetings.contains(where: { text.hasPrefix($0 + " ") })
    }

    private func greetingReply() -> String {
        "Hello! I'm your AI Manager. I'm listening. You can ask me to check email, open parts of Shayan Core, review your portfolio, or just chat with me."
    }

    private func isBasicAssistantCommand(_ text: String) -> Bool {
        let values = ["what can you do", "help", "who are you", "what are you", "thank you", "thanks", "repeat that", "say that again", "cancel"]
        return values.contains(where: { text == $0 || text.contains($0) })
    }

    private func basicAssistantReply(for text: String) -> String {
        if text.contains("what can you do") || text == "help" {
            return "I'm your AI Manager. I can chat with you, read and summarize Gmail, open Shayan Core destinations, check portfolio status, prepare email drafts with approval, and guide you through tasks. More tools can be added without changing the conversation layer."
        }
        if text.contains("who are you") || text.contains("what are you") {
            return "I'm Shayan Core's AI Manager. My job is to understand what you want, keep the conversation natural, use the right app capability, and clearly tell you what I did."
        }
        if text.contains("thank") {
            return "You're welcome. I'm ready for the next task."
        }
        if text.contains("repeat") || text.contains("say that again") {
            return voice.reply.isEmpty ? "I haven't said anything yet." : voice.reply
        }
        return "Okay. I've cancelled that."
    }

    private func openEmail(recipient: String, subject: String, body: String) {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = recipient
        components.queryItems = [
            URLQueryItem(name: "subject", value: subject),
            URLQueryItem(name: "body", value: body)
        ]
        guard let url = components.url else { showMailUnavailable = true; return }
        openURL(url)
        activity.insert("Email prepared for \(recipient)", at: 0)
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
            .accessibilityLabel("AI Manager voice control")
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

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.08)) { context in
            HStack(spacing: 4) {
                ForEach(0..<9, id: \.self) { index in
                    let time = context.date.timeIntervalSinceReferenceDate
                    let primary = sin(time * (active ? 5.0 : 1.6) + Double(index) * 0.72)
                    let secondary = sin(time * (active ? 2.4 : 0.8) + Double(index) * 1.15)
                    let height = active ? 8 + abs(primary) * 14 + abs(secondary) * 4 : 7
                    Capsule()
                        .fill(.white.opacity(active ? 0.92 : 0.38))
                        .frame(width: 4, height: CGFloat(height))
                }
            }
            .frame(width: 82, height: 28)
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
    @Published var phaseSubtitle = "Voice mode listens automatically"
    @Published var iconName = "mic.fill"

    var onFinalTranscript: ((String) -> Void)?
    var onError: ((String) -> Void)?

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-IN"))
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
            phaseSubtitle = "Speak naturally — I'll know when you're done"
            iconName = "waveform"
            isListening = true

            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest else { return }
            recognitionRequest.shouldReportPartialResults = true
            recognitionRequest.taskHint = .dictation
            recognitionRequest.contextualStrings = [
                "AI Manager", "Shayan Core", "Gmail", "email", "email ID", "email address",
                "GitHub", "LinkedIn", "portfolio", "dashboard", "website", "Learning Hub",
                "Core Sentinel", "Resume Builder", "Protected Notes", "QR scanner",
                "Quick Actions", "Insights", "Settings", "Workspace"
            ]

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
        phaseSubtitle = "AI Manager is replying"
        iconName = "speaker.wave.2.fill"
        statusText = "Speaking…"

        do {
            try configureSpeechOutputSession()
        } catch {
            onError?("Audio output could not be configured.")
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.48
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
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
        let delay: Duration = initial ? .seconds(3.5) : .seconds(1.35)
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
        phaseSubtitle = "Voice mode listens automatically"
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
        try session.setActive(true)
    }

    private func configureSpeechOutputSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(
            .playAndRecord,
            mode: .spokenAudio,
            options: [.defaultToSpeaker, .allowBluetooth, .allowBluetoothA2DP, .mixWithOthers]
        )
        try session.setActive(true)
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
