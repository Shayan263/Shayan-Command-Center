import SwiftUI

enum CoreDestination: Hashable {
    case profile
    case quickActions
    case insights
    case resume
    case protectedNotes
    case settings
    case qrScanner
    case sapKnowledge
}

struct CoreDestinationView: View {
    let destination: CoreDestination
    let openExternal: (URL) -> Void

    @ViewBuilder
    var body: some View {
        switch destination {
        case .profile:
            ProfileView()
        case .quickActions:
            QuickActionsView()
        case .insights:
            InsightsView()
        case .resume:
            ResumeBuilderPreviewView()
        case .protectedNotes:
            PlainTextView()
        case .settings:
            SettingsView()
        case .qrScanner:
            QRScannerScreen()
        case .sapKnowledge:
            SAPKnowledgeAgentView()
        }
    }
}
