import Foundation

struct CoreReminder: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var date: Date
    var isCompleted: Bool

    init(id: UUID = UUID(), title: String, date: Date, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.date = date
        self.isCompleted = isCompleted
    }
}

enum CoreReminderStorage {
    static let suiteName = "group.com.shayan.commandcentre"
    static let storageKey = "core.reminders.v1"

    static var defaults: UserDefaults {
        UserDefaults(suiteName: suiteName) ?? .standard
    }

    static func load() -> [CoreReminder] {
        guard let data = defaults.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([CoreReminder].self, from: data) else {
            return []
        }
        return decoded.sorted { $0.date < $1.date }
    }

    static func save(_ reminders: [CoreReminder]) {
        guard let data = try? JSONEncoder().encode(reminders) else { return }
        defaults.set(data, forKey: storageKey)
    }
}
