import SwiftUI

@main
struct ShayanCommandCenterApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
                .preferredColorScheme(.dark)
        }
    }
}
