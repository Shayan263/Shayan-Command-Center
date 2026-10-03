import SwiftUI
import WebKit

@main
struct ShayanCommandCentreApp: App {
    var body: some Scene {
        WindowGroup {
            CommandCentreView()
                .preferredColorScheme(.dark)
        }
    }
}

struct CommandCentreView: View {
    var body: some View {
        CommandCentreWebView(url: AppConfig.dashboardURL)
            .ignoresSafeArea()
            .background(Color.black)
    }
}

struct CommandCentreWebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.allowsBackForwardNavigationGestures = true
        webView.backgroundColor = .black
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        guard webView.url == nil else { return }
        webView.load(URLRequest(url: url))
    }
}

enum AppConfig {
    // Replace this with the live Command Centre URL.
    static let dashboardURL = URL(string: "https://example.com")!
}
