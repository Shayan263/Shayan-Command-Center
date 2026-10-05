import SwiftUI

private struct SAPKnowledgeItem: Codable, Identifiable {
    let title: String
    let category: String
    let priority: String
    let whyItMatters: String
    let shayanRelevance: String
    let recommendedAction: String
    let sourceName: String
    let sourceURL: String
    let publishedOrUpdatedAt: String?

    var id: String { title + sourceURL }

    enum CodingKeys: String, CodingKey {
        case title, category, priority
        case whyItMatters = "why_it_matters"
        case shayanRelevance = "shayan_relevance"
        case recommendedAction = "recommended_action"
        case sourceName = "source_name"
        case sourceURL = "source_url"
        case publishedOrUpdatedAt = "published_or_updated_at"
    }
}

private struct SAPKnowledgePayload: Codable {
    let generatedAt: String
    let summary: String
    let items: [SAPKnowledgeItem]

    enum CodingKeys: String, CodingKey {
        case generatedAt = "generated_at"
        case summary, items
    }
}

@MainActor
private final class SAPKnowledgeFeed: ObservableObject {
    @Published private(set) var payload: SAPKnowledgePayload?
    @Published private(set) var isLoading = false
    @Published private(set) var lastUpdated: Date?
    @Published private(set) var errorMessage: String?

    private let feedURL = URL(string: "https://raw.githubusercontent.com/Shayan263/Shayan-Command-Center/main/data/sap-knowledge.json")!

    func refresh() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            var request = URLRequest(url: feedURL)
            request.cachePolicy = .reloadIgnoringLocalCacheData
            request.timeoutInterval = 15
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                throw URLError(.badServerResponse)
            }
            payload = try JSONDecoder().decode(SAPKnowledgePayload.self, from: data)
            lastUpdated = Date()
        } catch {
            errorMessage = "Knowledge feed could not be refreshed. Try again when you're online."
        }
    }
}

struct SAPKnowledgeAgentView: View {
    @StateObject private var feed = SAPKnowledgeFeed()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    Image(systemName: "brain.head.profile")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.blue)
                        .frame(width: 46, height: 46)
                        .background(.blue.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 13))

                    VStack(alignment: .leading, spacing: 3) {
                        Text("SAP KNOWLEDGE AGENT")
                            .font(.caption.weight(.bold))
                            .tracking(1.1)
                            .foregroundStyle(.blue)
                        Text("SAP intelligence for your career")
                            .font(.headline)
                    }
                    Spacer()
                    if feed.isLoading {
                        ProgressView()
                    }
                }

                if let payload = feed.payload {
                    VStack(alignment: .leading, spacing: 9) {
                        Label("Latest briefing", systemImage: "sparkles")
                            .font(.subheadline.weight(.semibold))
                        Text(payload.summary)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(15)
                    .background(Color.primary.opacity(0.045))
                    .overlay(RoundedRectangle(cornerRadius: 17).stroke(Color.primary.opacity(0.07), lineWidth: 1))
                    .clipShape(RoundedRectangle(cornerRadius: 17))

                    ForEach(payload.items) { item in
                        SAPKnowledgeItemCard(item: item)
                    }

                    if let lastUpdated = feed.lastUpdated {
                        Text("Feed refreshed (lastUpdated.formatted(.dateTime.hour().minute()))")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                } else if let errorMessage = feed.errorMessage {
                    VStack(alignment: .leading, spacing: 8) {
                        Image(systemName: "wifi.exclamationmark")
                            .foregroundStyle(.orange)
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.orange.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 17))
                } else {
                    ProgressView("Loading SAP knowledge…")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 50)
                }
            }
            .padding(20)
        }
        .background(Color(.systemBackground))
        .navigationTitle("SAP Knowledge")
        .navigationBarTitleDisplayMode(.inline)
        .task { await feed.refresh() }
        .refreshable { await feed.refresh() }
    }
}

private struct SAPKnowledgeItemCard: View {
    let item: SAPKnowledgeItem

    private var priorityColor: Color {
        switch item.priority {
        case "NOW": return .red
        case "NEXT": return .orange
        default: return .blue
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.headline)
                    Text(item.category.uppercased())
                        .font(.caption2.weight(.bold))
                        .tracking(0.7)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(item.priority)
                    .font(.system(size: 9, weight: .bold))
                    .tracking(0.6)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(priorityColor.opacity(0.12))
                    .foregroundStyle(priorityColor)
                    .clipShape(Capsule())
            }

            Text(item.whyItMatters)
                .font(.subheadline)
            Text(item.shayanRelevance)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 5) {
                Text("Recommended action")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.blue)
                Text(item.recommendedAction)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if let url = URL(string: item.sourceURL) {
                Link(destination: url) {
                    Label("Source: (item.sourceName)", systemImage: "arrow.up.right")
                        .font(.caption.weight(.semibold))
                }
            }
        }
        .padding(16)
        .background(Color.primary.opacity(0.045))
        .overlay(RoundedRectangle(cornerRadius: 17).stroke(Color.primary.opacity(0.07), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 17))
    }
}
