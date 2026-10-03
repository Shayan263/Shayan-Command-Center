import SwiftUI

@main
struct ShayanCommandCenterApp: App {
    @AppStorage("appLockEnabled") private var appLockEnabled = false
    @Environment(\.scenePhase) private var scenePhase
    @State private var isUnlocked = false
    @State private var showLaunchScreen = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                Group {
                    if appLockEnabled && !isUnlocked {
                        AppLockView { isUnlocked = true }
                    } else {
                        HomeView()
                    }
                }
                .preferredColorScheme(.dark)

                if showLaunchScreen {
                    LaunchView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .onAppear {
                if !appLockEnabled { isUnlocked = true }
            }
            .onChange(of: appLockEnabled) { _, enabled in
                isUnlocked = !enabled
            }
            .onChange(of: scenePhase) { _, phase in
                if phase == .background && appLockEnabled {
                    isUnlocked = false
                }
            }
            .task {
                try? await Task.sleep(for: .milliseconds(650))
                withAnimation(.easeOut(duration: 0.3)) {
                    showLaunchScreen = false
                }
            }
        }
    }
}

private struct LaunchView: View {
    var body: some View {
        ZStack {
            Color(red: 0.025, green: 0.035, blue: 0.07).ignoresSafeArea()
            VStack(spacing: 12) {
                Image(systemName: "circle.hexagongrid.fill")
                    .font(.system(size: 58))
                    .foregroundStyle(.blue)
                Text("SHAYAN CORE")
                    .font(.title2.bold())
                    .tracking(2)
                Text("Your personal digital core")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
