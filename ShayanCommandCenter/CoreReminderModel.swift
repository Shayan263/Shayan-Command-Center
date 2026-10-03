import Foundation

struct SharedReminderRecord: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var date: Date
    var isCompleted: Bool
}

enum CoreReminderStorage {
    static let suiteName = "group.com.shayan.commandcentre"
    static let storageKey = "core.reminders.v1"

    static var defaults: UserDefaults {
        UserDefaults(suiteName: suiteName) ?? .standard
    }

    static func load<T: Decodable>(_ type: T.Type = T.self) -> T? {
        guard let data = defaults.data(forKey: storageKey) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    static func save<T: Encodable>(_ value: T) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        defaults.set(data, forKey: storageKey)
    }
}
