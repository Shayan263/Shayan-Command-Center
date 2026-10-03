import Foundation
import Combine

@MainActor
final class DashboardStatus: ObservableObject {
    @Published private(set) var isOnline = false
    @Published private(set) var lastChecked: Date?
    @Published private(set) var responseTimeMs: Int?
    @Published private(set) var errorMessage: String?
    @Published private(set) var isChecking = false

    private let url = URL(string: "https://shayan263.github.io/Shayan_Profile/admin.html")!

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
                errorMessage = isOnline ? nil : "HTTP \(http.statusCode)"
            } else {
                isOnline = false
                errorMessage = "Invalid response"
            }
        } catch is CancellationError {
            return
        } catch {
            isOnline = false
            responseTimeMs = nil
            errorMessage = error.localizedDescription
        }

        lastChecked = Date()
    }
}
