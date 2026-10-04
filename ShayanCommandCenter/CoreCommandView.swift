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
    case contextSummary(String)
    case portfolioStatus
    case conversationReply(String)
    case navigate(CoreDestination, String)
    case navigateHome
    case openURL(URL, String)
    case unsupported

    var title: String {
        switch self {
        case .emailDraft: return "Email draft"
        case .connectGmail: return "Connect Gmail"
        case .emailSummary: return "Email summary"
        case .contextSummary: return "Context summary"
        case .portfolioStatus: return "Portfolio status"
        case .conversationReply: return "Conversation"
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

    // AI Manager responsibilities, not a scripted sequence:
    // understand the whole request, use conversation context, choose a capability,
    // ask only for genuinely missing information, and never require a greeting.
    func plan(_ input: String, history: [AIChatMessage]) -> AICommandPlan {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        let lower = text.lowercased()
        guard !text.isEmpty else {
            return AICommandPlan(kind: .unsupported, summary: "Tell me what you need.", requiresApproval: false)
        }

        // Always inspect the complete request before deciding what it means.
        if let action = routeAction(lower) { return action }

        if containsAny(lower, ["connect gmail", "connect my gmail", "connect email", "connect my email", "link gmail", "link my email"]) {
            return AICommandPlan(kind: .connectGmail, summary: "I'll connect Gmail with read-only access.", requiresApproval: false)
        }

        if isSummaryRequest(lower) {
            return AICommandPlan(
                kind: .contextSummary(extractSummaryContext(from: text)),
                summary: "I'll summarize the context you provided.",
                requiresApproval: false
            )
        }

        if lower.contains("email") || lower.contains("mail") {
            let readWords = [
                "check my email", "check my emails", "read my email", "read my emails",
                "unread", "latest emails", "recent emails", "summarize my email",
                "summarize my emails", "what are my emails about", "what's in my email",
                "inbox", "what did i get", "show my email"
            ]
            if readWords.contains(where: { lower.contains($0) }) {
                let query = lower.contains("unread") ? "in:inbox is:unread" : "in:inbox"
                return AICommandPlan(
                    kind: .emailSummary(query: query),
                    summary: "I'll read the relevant Gmail messages and summarize what matters.",
                    requiresApproval: false
                )
            }

            let recipient = extractEmail(from: text) ?? ""
            guard !recipient.isEmpty else {
                return AICommandPlan(kind: .unsupported, summary: "I can draft that. I just need the recipient's email address.", requiresApproval: false)
            }

            let body = extractBody(from: text) ?? ""
            guard !body.isEmpty else {
                return AICommandPlan(kind: .unsupported, summary: "I have the recipient. Tell me what you want the email to say.", requiresApproval: false)
            }

            let subject = extractSubject(from: text, body: body)
            return AICommandPlan(
                kind: .emailDraft(recipient: recipient, subject: subject, body: body),
                summary: "I prepared the email from the context you gave me. I'll wait for your approval before opening Mail.",
                requiresApproval: true
            )
        }

        if lower.contains("portfolio status") || lower.contains("website status") ||
            lower.contains("dashboard status") || lower.contains("is my portfolio") ||
            lower.contains("is the dashboard") || lower.contains("is the website") ||
            lower.hasPrefix("check ") {
            return AICommandPlan(kind: .portfolioStatus, summary: "I'll check the live portfolio systems.", requiresApproval: false)
        }

        if isGreeting(lower) {
            return AICommandPlan(kind: .conversationReply("Hey. What do you want to do?"), summary: "Greeting", requiresApproval: false)
        }

        if isBasicAssistantCommand(lower) {
            return AICommandPlan(kind: .conversationReply(basicAssistantReply(for: lower)), summary: "Conversation", requiresApproval: false)
        }

        if !history.isEmpty && (lower.contains("what did we") || lower.contains("continue") || lower.contains("remember")) {
            let recent = history.suffix(6)
                .map { "\($0.role == .user ? "You" : "AI Manager"): \($0.text)" }
                .joined(separator: " ")
            return AICommandPlan(kind: .conversationReply("I still have this conversation. \(recent.prefix(500))"), summary: "Using conversation history.", requiresApproval: false)
        }

        return AICommandPlan(
            kind: .unsupported,
            summary: "I understand the request, but I don't have a local capability mapped to it yet. Give me the task in your own words; I won't require a fixed sequence.",
            requiresApproval: false
        )
    }

    private func routeAction(_ lower: String) -> AICommandPlan? {
        let openVerbs = ["open ", "launch ", "show ", "go to ", "take me to ", "visit "]
        let isOpenRequest = openVerbs.contains(where: { lower.hasPrefix($0) })

        if lower == "dashboard" || (isOpenRequest && containsAny(lower, ["dashboard", "admin dashboard", "portfolio dashboard"])) {
            return AICommandPlan(kind: .openURL(dashboardURL, "Opening your private portfolio dashboard."), summary: "Opening dashboard.", requiresApproval: false)
        }
        if lower == "website" || lower == "my website" || (isOpenRequest && containsAny(lower, ["website", "portfolio website", "my portfolio"])) {
            return AICommandPlan(kind: .openURL(websiteURL, "Opening your portfolio website."), summary: "Opening website.", requiresApproval: false)
        }
        if isOpenRequest && containsAny(lower, ["github", "git hub", "repositories"]) {
            return AICommandPlan(kind: .openURL(githubURL, "Opening your GitHub profile."), summary: "Opening GitHub.", requiresApproval: false)
        }
        if isOpenRequest && containsAny(lower, ["linkedin", "linked in"]) {
            return AICommandPlan(kind: .openURL(linkedInURL, "Opening LinkedIn."), summary: "Opening LinkedIn.", requiresApproval: false)
        }
        if isOpenRequest && containsAny(lower, ["home", "home screen"]) {
            return AICommandPlan(kind: .navigateHome, summary: "Returning home.", requiresApproval: false)
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
            return AICommandPlan(kind: .navigate(.profile, "Opening your profile."), summary: "Opening profile.", requiresApproval: false)
        }
        if containsAny(lower, ["scan qr", "scan a qr", "qr code", "qr scanner"]) {
            return AICommandPlan(kind: .navigate(.qrScanner, "Opening QR Scanner."), summary: "Opening QR Scanner.", requiresApproval: false)
        }
        return nil
    }

    private func containsAny(_ text: String, _ values: [String]) -> Bool {
        values.contains(where: { text.contains($0) })
    }

    private func isGreeting(_ text: String) -> Bool {
        ["hi", "hello", "hey", "good morning", "good afternoon", "good evening"].contains(text)
    }

    private func isBasicAssistantCommand(_ text: String) -> Bool {
        ["what can you do", "help", "who are you", "what are you", "thank you", "thanks", "repeat that", "say that again", "cancel"]
            .contains(where: { text == $0 || text.contains($0) })
    }

    private func basicAssistantReply(for text: String) -> String {
        if text.contains("what can you do") || text == "help" {
            return "I'm Shayan Core's AI Manager. I handle the tasks and capabilities you give me, using the conversation as context instead of a fixed sequence."
        }
        if text.contains("who are you") || text.contains("what are you") {
            return "I'm Shayan Core's AI Manager. Give me the task in your own words."
        }
        if text.contains("thank") { return "Anytime. What's next?" }
        if text.contains("repeat") || text.contains("say that again") { return "I can repeat the last response from this conversation." }
        return "Okay. I've cancelled that."
    }

    private func isSummaryRequest(_ text: String) -> Bool {
        containsAny(text, ["summarize this", "summarise this", "summarize the following", "summarise the following", "give me a summary of", "summarize:", "summarise:"])
    }

    private func extractSummaryContext(from text: String) -> String {
        let markers = ["summarize this:", "summarise this:", "summarize the following:", "summarise the following:", "summarize:", "summarise:", "summary:"]
        for marker in markers {
            if let range = text.range(of: marker, options: .caseInsensitive) {
                let value = text[range.upperBound...].trimmingCharacters(in: .whitespacesAndNewlines)
                if !value.isEmpty { return String(value) }
            }
        }
        return text
    }

    private func extractEmail(from text: String) -> String? {
        let pattern = "[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return nil }
        let range = NSRange(text.startIndex..., in: text)
        return regex.firstMatch(in: text, range: range).flatMap { Range($0.range, in: text).map { String(text[$0]) } }
    }

    private func extractSubject(from text: String, body: String) -> String {
        let lower = text.lowercased()
        for marker in ["subject:", "subject -", "subject "] {
            if let range = lower.range(of: marker) {
                var value = String(text[range.upperBound...])
                for boundary in [" body:", " saying ", " message:"] {
                    if let boundaryRange = value.range(of: boundary, options: .caseInsensitive) {
                        value = String(value[..<boundaryRange.lowerBound])
                    }
                }
                let cleaned = value.trimmingCharacters(in: .whitespacesAndNewlines.union(.punctuationCharacters))
                if !cleaned.isEmpty { return cleaned }
            }
        }

        let words = body.replacingOccurrences(of: "\n", with: " ")
            .split(whereSeparator: { $0.isWhitespace })
            .prefix(8)
            .map(String.init)
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines.union(.punctuationCharacters))

        guard !words.isEmpty else { return "" }
        return words.prefix(1).uppercased() + words.dropFirst()
    }

    private func extractBody(from text: String) -> String? {
        let lower = text.lowercased()
        for marker in ["saying ", "says ", "body:", "message:"] {
            if let range = lower.range(of: marker) {
                let body = text[range.upperBound...].trimmingCharacters(in: .whitespacesAndNewlines)
                if !body.isEmpty { return String(body) }
            }
        }

        guard let email = extractEmail(from: text) else { return nil }
        var cleaned = text.replacingOccurrences(of: email, with: "")
        let prefixes = ["send an email", "send email", "draft an email", "draft email", "compose an email", "compose email"]
        for prefix in prefixes {
            cleaned = cleaned.replacingOccurrences(of: prefix, with: "", options: .caseInsensitive)
        }
        if let subjectRange = cleaned.range(of: "subject:", options: .caseInsensitive) {
            cleaned = String(cleaned[..<subjectRange.lowerBound])
        }
        cleaned = cleaned.replacingOccurrences(of: " to ", with: " ", options: .caseInsensitive)
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines.union(.punctuationCharacters))
        return cleaned.isEmpty ? nil : cleaned
    }
}


struct AICommandCenterView: View {
    @StateObject private var voice = VoiceConversationController()
    @StateObject private var history = AIChatHistory.shared
    @State private var command = ""
    @State private var plan: AICommandPlan?
    @State private var showMailUnavailable = false
    @State private var lastEmails: [GmailMessageSummary] = []
    @State private var emailTaskInFlight = false
    @State private var route: CoreDestination?
    @State private var showChats = false
    @State private var lastHandledInput = ""
    @State private var lastHandledAt = Date.distantPast
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    private let engine = AICommandEngine()

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 16) {
                    Text("AI MANAGER")
                        .font(.caption.weight(.bold))
                        .tracking(1.5)
                        .foregroundStyle(.blue)

                    VoiceOrb(voice: voice) { Task { await toggleVoice() } }
                        .frame(height: 280)

                    if history.currentMessages.isEmpty {
                        Text("Start with the task. No greeting or fixed sequence is required.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.horizontal)
                    }

                    ForEach(history.currentMessages) { message in
                        conversationBubble(
                            title: message.role == .user ? "YOU" : "AI MANAGER",
                            text: message.text,
                            isUser: message.role == .user
                        )
                        .id(message.id)
                    }

                    if let plan, plan.requiresApproval {
                        planCard(plan)
                    }

                    HStack(alignment: .bottom, spacing: 8) {
                        TextField("Message AI Manager…", text: $command, axis: .vertical)
                            .textFieldStyle(.plain)
                            .padding(13)
                            .onSubmit { submitTypedCommand() }

                        Button {
                            submitTypedCommand()
                        } label: {
                            Image(systemName: "arrow.up.circle.fill").font(.system(size: 28))
                        }
                        .disabled(command.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .padding(.bottom, 8)
                    }
                    .padding(.horizontal, 5)
                    .background(Color.primary.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
            .onChange(of: history.currentMessages.count) {
                if let last = history.currentMessages.last {
                    withAnimation(.easeOut(duration: 0.2)) {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
        .background(Color(.systemBackground))
        .navigationTitle("AI Manager")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showChats = true } label: {
                    Image(systemName: "bubble.left.and.bubble.right")
                }
                .accessibilityLabel("Conversation history")
            }
        }
        .navigationDestination(item: $route) { destination in
            CoreDestinationView(destination: destination, openExternal: { url in openURL(url) })
        }
        .sheet(isPresented: $showChats) {
            AIConversationListView(history: history)
        }
        .task {
            voice.onFinalTranscript = { text in handleCommand(text) }
            voice.onError = { _ in }
            await voice.startListening()
        }
        .onDisappear { voice.shutdown() }
        .alert("Mail is not available", isPresented: $showMailUnavailable) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("The command was planned, but the iPhone could not open a mail composer.")
        }
    }

    @ViewBuilder
    private func conversationBubble(title: String, text: String, isUser: Bool) -> some View {
        HStack {
            if !isUser { Spacer(minLength: 24) }
            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                Text(title).font(.caption2.weight(.bold)).tracking(1).foregroundStyle(.secondary)
                Text(text)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: isUser ? .trailing : .leading)
                    .padding(12)
                    .background(isUser ? Color.blue.opacity(0.16) : Color.primary.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            .frame(maxWidth: .infinity, alignment: isUser ? .trailing : .leading)
            if isUser { Spacer(minLength: 24) }
        }
    }

    @ViewBuilder
    private func planCard(_ plan: AICommandPlan) -> some View {
        VStack(alignment: .leading, spacing: 11) {
            Label(plan.kind.title, systemImage: "wand.and.stars").font(.headline)
            Text(plan.summary).font(.subheadline).foregroundStyle(.secondary)
            if case let .emailDraft(recipient, subject, body) = plan.kind {
                VStack(alignment: .leading, spacing: 7) {
                    Text("TO  \(recipient)").font(.caption.weight(.bold))
                    Text(subject.isEmpty ? "SUBJECT  (not provided)" : "SUBJECT  \(subject)")
                        .font(.caption.weight(.semibold))
                    Text(body).font(.footnote).foregroundStyle(.secondary).lineLimit(6)
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
        if voice.isSpeaking { voice.interrupt(); return }
        if !voice.isListening { await voice.startListening() }
    }

    private func handleCommand(_ text: String) {
        let value = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return }

        let now = Date()
        if value.caseInsensitiveCompare(lastHandledInput) == .orderedSame && now.timeIntervalSince(lastHandledAt) < 3.0 {
            return
        }
        lastHandledInput = value
        lastHandledAt = now

        history.append(.user, text: value)

        if let existing = plan,
           case let .emailDraft(recipient, subject, body) = existing.kind,
           isApproval(value) {
            openEmail(recipient: recipient, subject: subject, body: body)
            let response = "Done. I opened the email for \(recipient) so you can review it."
            history.append(.manager, text: response)
            voice.reply = response
            voice.speak(response)
            plan = nil
            return
        }

        let newPlan = engine.plan(value, history: history.currentMessages)
        plan = newPlan
        execute(newPlan)
    }

    private func execute(_ newPlan: AICommandPlan) {
        switch newPlan.kind {
        case .emailDraft(let recipient, _, _):
            let response = "I prepared the email to \(recipient). Say yes when you want me to open Mail."
            history.append(.manager, text: response)
            voice.reply = response
            voice.speak(response)

        case .connectGmail:
            let response = "Opening Google now. Give Gmail read-only access and I'll handle the rest."
            history.append(.manager, text: response)
            voice.reply = response
            voice.speak(response)
            Task { await connectGmail() }

        case .emailSummary(let query):
            Task { await summarizeEmails(query: query, followUp: nil) }

        case .contextSummary(let context):
            let answer = summarizeProvidedContext(context)
            history.append(.manager, text: answer)
            voice.reply = answer
            voice.speak(answer)

        case .portfolioStatus:
            let response = "I'm checking the live portfolio systems. The latest status is on your Home dashboard."
            history.append(.manager, text: response)
            voice.reply = response
            voice.speak(response)

        case .conversationReply(let response):
            history.append(.manager, text: response)
            voice.reply = response
            voice.speak(response)

        case .navigate(let destination, let message):
            history.append(.manager, text: message)
            voice.reply = message
            voice.speak(message)
            route = destination

        case .navigateHome:
            let response = "Going home."
            history.append(.manager, text: response)
            voice.reply = response
            voice.speak(response)
            dismiss()

        case .openURL(let url, let message):
            history.append(.manager, text: message)
            voice.reply = message
            voice.speak(message)
            openURL(url)

        case .unsupported:
            history.append(.manager, text: newPlan.summary)
            voice.reply = newPlan.summary
            voice.speak(newPlan.summary)
        }
    }

    private func connectGmail() async {
        do {
            try await GmailTool.shared.connect()
            let account = GmailTool.shared.accountEmail.map { " as \($0)" } ?? ""
            let response = "Gmail is connected\(account). What would you like to do?"
            history.append(.manager, text: response)
            voice.reply = response
            voice.speak(response)
        } catch {
            let response = error.localizedDescription
            history.append(.manager, text: response)
            voice.reply = response
            voice.speak(response)
        }
    }

    private func summarizeEmails(query: String, followUp: String?) async {
        guard !emailTaskInFlight else { return }
        emailTaskInFlight = true
        defer { emailTaskInFlight = false }

        guard GmailTool.shared.isConnected else {
            let response = "Your Gmail isn't connected yet. You can connect it whenever you're ready."
            history.append(.manager, text: response)
            voice.reply = response
            voice.speak(response)
            return
        }

        do {
            let emails: [GmailMessageSummary]
            if followUp != nil && !lastEmails.isEmpty {
                emails = lastEmails
            } else {
                emails = try await GmailTool.shared.recentMessages(query: query, maxResults: 6)
                lastEmails = emails
            }

            guard !emails.isEmpty else {
                let response = "You don't have any matching messages right now."
                history.append(.manager, text: response)
                voice.reply = response
                voice.speak(response)
                return
            }

            let answer = localEmailSummary(emails: emails, followUp: followUp)
            history.append(.manager, text: answer)
            voice.reply = answer
            voice.speak(answer)
        } catch {
            let response = "I couldn't read Gmail right now. \(error.localizedDescription)"
            history.append(.manager, text: response)
            voice.reply = response
            voice.speak(response)
        }
    }

    private func localEmailSummary(emails: [GmailMessageSummary], followUp: String?) -> String {
        let unread = emails.filter(\.isUnread).count
        let lead = unread > 0 ? "\(emails.count) recent messages, including \(unread) unread." : "\(emails.count) recent messages and nothing is marked unread."
        let highlights = emails.prefix(3).map { email -> String in
            let subject = email.subject.trimmingCharacters(in: .whitespacesAndNewlines)
            let sender = email.sender.split(separator: "<").first.map(String.init)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? email.sender
            return "\(sender) sent \(subject)."
        }.joined(separator: " ")
        if let followUp, !followUp.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "\(lead) \(highlights) I'm using the same messages for your follow-up."
        }
        return "\(lead) \(highlights)"
    }

    private func summarizeProvidedContext(_ context: String) -> String {
        let cleaned = context
            .replacingOccurrences(of: "\n+", with: " ", options: .regularExpression)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleaned.isEmpty else { return "I need the context you want summarized." }

        let sentences = cleaned
            .split(whereSeparator: { ".!?".contains($0) })
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        if sentences.count <= 2 {
            return cleaned.count > 420 ? String(cleaned.prefix(420)) + "…" : cleaned
        }

        let selected = sentences.prefix(3).map(String.init).joined(separator: ". ")
        let summary = selected + (selected.hasSuffix(".") ? "" : ".")
        return summary.count > 420 ? String(summary.prefix(420)) + "…" : summary
    }

    private func submitTypedCommand() {
        let text = command.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        command = ""
        handleCommand(text)
    }

    private func isApproval(_ text: String) -> Bool {
        let lower = text.lowercased()
        return ["yes", "yeah", "yep", "send it", "open it", "do it", "approve", "approved"].contains(where: { lower == $0 || lower.contains($0) })
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
    }
}

private struct AIConversationListView: View {
    @ObservedObject var history: AIChatHistory
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Button {
                    history.newChat()
                    dismiss()
                } label: {
                    Label("New conversation", systemImage: "plus.bubble")
                }

                ForEach(history.sessions) { session in
                    Button {
                        history.select(session)
                        dismiss()
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(session.title)
                                .font(.body.weight(.semibold))
                                .foregroundStyle(.primary)
                            Text(session.messages.last?.text ?? "No messages yet")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                    .swipeActions {
                        if history.sessions.count > 1 {
                            Button(role: .destructive) { history.delete(session) } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Conversations")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
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

                    VoiceWave(active: active)
                        .frame(width: 88, height: 30)
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
        if active {
            TimelineView(.animation(minimumInterval: 0.08)) { context in
                HStack(spacing: 4) {
                    ForEach(0..<7, id: \.self) { index in
                        let time = context.date.timeIntervalSinceReferenceDate
                        let primary = sin(time * 5.0 + Double(index) * 0.72)
                        let secondary = sin(time * 2.4 + Double(index) * 1.15)
                        let height = 8 + abs(primary) * 14 + abs(secondary) * 4
                        Capsule().fill(.white.opacity(0.92)).frame(width: 4, height: CGFloat(height))
                    }
                }
                .frame(width: 70, height: 28)
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
    @Published var statusText = ""
    @Published var phaseTitle = ""
    @Published var phaseSubtitle = ""
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
    private var lastDeliveredTranscript = ""
    private var lastDeliveredAt = Date.distantPast

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
            statusText = ""
            phaseTitle = ""
            phaseSubtitle = ""
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
        phaseSubtitle = ""
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
        phaseTitle = ""
        phaseSubtitle = ""
        iconName = "speaker.wave.2.fill"
        statusText = ""

        do {
            try configureSpeechOutputSession()
        } catch {
            onError?("Audio output could not be configured.")
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.53
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

        let now = Date()
        if finalText.caseInsensitiveCompare(lastDeliveredTranscript) == .orderedSame &&
            now.timeIntervalSince(lastDeliveredAt) < 3.0 {
            return
        }
        lastDeliveredTranscript = finalText
        lastDeliveredAt = now
        phaseTitle = ""
        phaseSubtitle = ""
        iconName = "sparkles"
        statusText = ""
        onFinalTranscript?(finalText)
    }

    private func armSilenceTimeout(initial: Bool = false) {
        silenceTask?.cancel()
        let delay: Duration = initial ? .seconds(1.5) : .seconds(0.78)
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
        phaseTitle = ""
        phaseSubtitle = "Voice mode listens automatically"
        iconName = "mic.fill"
        statusText = ""
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
        statusText = ""
        phaseTitle = "READY"
        phaseSubtitle = ""
        iconName = "mic.fill"
        onError?(message)
    }
}

extension VoiceConversationController: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
            self.phaseTitle = "READY"
            self.phaseSubtitle = ""
            self.iconName = "mic.fill"
            self.statusText = ""

            guard self.shouldContinueConversation else { return }
            try? await Task.sleep(for: .milliseconds(60))
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
