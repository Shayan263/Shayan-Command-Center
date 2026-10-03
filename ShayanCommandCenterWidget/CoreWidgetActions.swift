import AppIntents
import Foundation
import WidgetKit

struct CompleteNextReminderAction: AppIntent {
    static var title: LocalizedStringResource = "Complete Next Reminder"
    static var description = IntentDescription("Marks the next Shayan Core reminder as completed.")

    func perform() async throws -> some IntentResult {
        var reminders = CoreReminderStorage.load()
        guard let index = reminders.firstIndex(where: { !$0.isCompleted && $0.date >= Date() }) else {
            return .result()
        }
        reminders[index].isCompleted = true
        CoreReminderStorage.save(reminders)
        WidgetCenter.shared.reloadTimelines(ofKind: "ShayanCoreWidget")
        return .result()
    }
}
