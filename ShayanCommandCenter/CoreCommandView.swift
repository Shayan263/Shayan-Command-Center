import SwiftUI
import UIKit

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
    @State private var command = ""
    @State private var plan: AICommandPlan?
    @State private var activity: [String] = []
    @State private var showMailUnavailable = false

    private let engine = AICommandEngine()

    private var suggestions: [String] {
        [
            "Draft an email to someone@example.com saying I will follow up tomorrow",
            "Check my portfolio status"
        ]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 8) {
                    Label("AI COMMAND CENTRE", systemImage: "sparkles")
                        .font(.caption.weight(.bold))
                        .tracking(1.3)
                        .foregroundStyle(.blue)
                    Text("What do you want me to do?")
                        .font(.title2.bold())
                    Text("Describe the outcome. Shayan Core plans the action first, then executes only what is safe or approved.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 12) {
                    TextField("e.g. Draft an email to...", text: $command, axis: .vertical)
                        .textFieldStyle(.plain)
                        .padding(14)
                        .background(Color.primary.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                    Button {
                        plan = engine.plan(command)
                    } label: {
                        Label("Plan Command", systemImage: "arrow.right.circle.fill")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(command.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("TRY A COMMAND")
                        .font(.caption.weight(.bold))
                        .tracking(1)
                        .foregroundStyle(.secondary)
                    ForEach(suggestions, id: \.self) { suggestion in
                        Button(suggestion) {
                            command = suggestion
                            plan = engine.plan(suggestion)
                        }
                        .font(.caption)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(Color.primary.opacity(0.045))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }

                if let plan {
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
                                Label("Review & Open in Mail", systemImage: "envelope.badge")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                        } else if case .portfolioStatus = plan.kind {
                            Label("Live status check is already available on Home.", systemImage: "checkmark.circle")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(16)
                    .background(Color.blue.opacity(0.07))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.blue.opacity(0.15), lineWidth: 1))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                }

                if !activity.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("ACTIVITY")
                            .font(.caption.weight(.bold))
                            .tracking(1)
                            .foregroundStyle(.secondary)
                        ForEach(activity, id: \.self) { item in
                            Label(item, systemImage: "checkmark.circle.fill")
                                .font(.footnote)
                        }
                    }
                }

                Text("Execution is approval-first. More actions can plug into the same command engine without changing the Home screen.")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(18)
        }
        .navigationTitle("AI Command Centre")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Mail is not available", isPresented: $showMailUnavailable) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("The command was planned, but the iPhone could not open a mail composer.")
        }
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
