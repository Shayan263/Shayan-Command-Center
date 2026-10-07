import SwiftUI

@main
struct ShayanCommandCenterApp: App {
    @AppStorage("darkModeEnabled") private var darkModeEnabled = true

    var body: some Scene {
        WindowGroup {
            CoreHomeView()
                .preferredColorScheme(darkModeEnabled ? .dark : .light)
        }
    }
}
