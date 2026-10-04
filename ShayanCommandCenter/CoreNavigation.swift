import SwiftUI

enum CoreDestination: Hashable {
    case coreCommand
    case aiCommandCenter
    case workspace
    case profile
    case quickActions
    case insights
    case sentinel
    case resume
    case learning
    case protectedNotes
    case settings
    case qrScanner
}

struct CoreDestinationView: View {
    let destination: CoreDestination
    let openExternal: (URL) -> Void

    @ViewBuilder
    var body: some View {
        switch destination {
        case .coreCommand:
            CoreCommandView()
        case .aiCommandCenter:
            AICommandCenterView()
        case .workspace:
            WorkspaceView()
        case .profile:
            ProfileView()
        case .quickActions:
            QuickActionsView()
        case .insights:
            InsightsView()
        case .sentinel:
            CoreSentinelView()
        case .resume:
            ResumeBuilderPreviewView()
        case .learning:
            LearningHubPreviewView()
        case .protectedNotes:
            PlainTextView()
        case .settings:
            SettingsView()
        case .qrScanner:
            QRScannerScreen()
        }
    }
}
