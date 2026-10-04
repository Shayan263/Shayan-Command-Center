import SwiftUI

@main
struct ShayanCommandCenterApp: App {
    @AppStorage("darkModeEnabled") private var darkModeEnabled = true
    @State private var showLaunchScreen = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                HomeView()
                    .preferredColorScheme(darkModeEnabled ? .dark : .light)

                if showLaunchScreen {
                    LaunchView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .task {
                try? await Task.sleep(for: .milliseconds(1800))
                withAnimation(.easeInOut(duration: 0.42)) {
                    showLaunchScreen = false
                }
            }
        }
    }
}

private struct LaunchView: View {
    @State private var appeared = false

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 14) {
                Image(systemName: "circle.hexagongrid.fill")
                    .font(.system(size: 62, weight: .semibold))
                    .foregroundStyle(.blue)
                    .scaleEffect(appeared ? 1.0 : 0.72)
                    .opacity(appeared ? 1 : 0)

                Text("SHAYAN CORE")
                    .font(.title2.bold())
                    .tracking(2)
                    .opacity(appeared ? 1 : 0)

                Text("Initializing your digital workspace…")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 8)
            }
            .animation(.easeOut(duration: 0.55), value: appeared)
        }
        .task {
            appeared = true
        }
    }
}
