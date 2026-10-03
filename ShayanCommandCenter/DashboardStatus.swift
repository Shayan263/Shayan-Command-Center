import Foundation
import Combine

@MainActor
final class DashboardStatus: ObservableObject {
    @Published private(set) var isOnline = false
    @Published private(set) var lastChecked: Date?

    private let url = URL(string: "https://shayan263.github.io/Shayan_Profile/admin.html")!

    var lastCheckedText: String {
        guard let lastChecked else { return "Checking…" }
        return lastChecked.formatted(.dateTime.hour().minute().second())
    }

    func check() async {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.cachePolicy = .reloadIgnoringLocalCacheData

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse {
                isOnline = (200...399).contains(http.statusCode)
            } else {
                isOnline = false
            }
        } catch {
            isOnline = false
        }
        lastChecked = Date()
    }
}
