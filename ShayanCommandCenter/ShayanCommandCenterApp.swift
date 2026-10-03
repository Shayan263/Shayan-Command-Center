import SwiftUI

@main
struct ShayanCommandCenterApp: App {
    @AppStorage("appLockEnabled") private var appLockEnabled = false
    @Environment(\.scenePhase) private var scenePhase
    @State private var isUnlocked = false

    var body: some Scene {
        WindowGroup {
            Group {
                if appLockEnabled && !isUnlocked {
                    AppLockView {
                        isUnlocked = true
                    }
                } else {
                    HomeView()
                }
            }
            .preferredColorScheme(.dark)
            .onAppear {
                if !appLockEnabled {
                    isUnlocked = true
                }
            }
            .onChange(of: appLockEnabled) { _, enabled in
                isUnlocked = !enabled
            }
            .onChange(of: scenePhase) { _, phase in
                if phase == .background && appLockEnabled {
                    isUnlocked = false
                }
            }
        }
    }
}
