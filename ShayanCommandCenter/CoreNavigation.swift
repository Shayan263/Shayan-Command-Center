import SwiftUI

enum CoreDestination: Hashable {
    case coreCommand
    case profile
    case importantLinks
    case quickActions
    case insights
    case sentinel
    case resume
    case learning
    case protectedNotes
    case settings
}

struct CoreDestinationView: View {
    let destination: CoreDestination
    let openExternal: (URL) -> Void

    @ViewBuilder
    var body: some View {
        switch destination {
        case .coreCommand:
            CoreCommandView()
        case .profile:
            ProfileView()
        case .importantLinks:
            ImportantLinksView(openExternal: openExternal)
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
        }
    }
}
