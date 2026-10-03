import Foundation
import UserNotifications
import SwiftUI

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

@MainActor
final class ReminderStore: ObservableObject {
    @Published private(set) var reminders: [CoreReminder] = []

    private let storageKey = "core.reminders.v1"

    init() {
        load()
    }

    func add(title: String, date: Date) async throws {
        try await ReminderNotificationService.requestAuthorizationIfNeeded()
        let reminder = CoreReminder(title: title, date: date)
        reminders.append(reminder)
        reminders.sort { $0.date < $1.date }
        persist()
        try await ReminderNotificationService.schedule(reminder)
    }

    func toggle(_ reminder: CoreReminder) async {
        guard let index = reminders.firstIndex(of: reminder) else { return }
        reminders[index].isCompleted.toggle()
        persist()

        if reminders[index].isCompleted {
            await ReminderNotificationService.cancel(reminder)
        } else if reminders[index].date > Date() {
            try? await ReminderNotificationService.schedule(reminders[index])
        }
    }

    func delete(_ reminder: CoreReminder) async {
        reminders.removeAll { $0.id == reminder.id }
        persist()
        await ReminderNotificationService.cancel(reminder)
    }

    func reload() {
        load()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([CoreReminder].self, from: data) else { return }
        reminders = decoded.sorted { $0.date < $1.date }
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(reminders) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}

enum ReminderNotificationService {
    static func requestAuthorizationIfNeeded() async throws {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .notDetermined else {
            if settings.authorizationStatus == .denied {
                throw ReminderError.notificationsDenied
            }
            return
        }

        let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
        guard granted else { throw ReminderError.notificationsDenied }
    }

    static func schedule(_ reminder: CoreReminder) async throws {
        guard reminder.date > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Shayan Core"
        content.body = reminder.title
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: reminder.date
            ),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: reminder.id.uuidString,
            content: content,
            trigger: trigger
        )
        try await UNUserNotificationCenter.current().add(request)
    }

    static func cancel(_ reminder: CoreReminder) async {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [reminder.id.uuidString])
    }
}

enum ReminderError: LocalizedError {
    case notificationsDenied

    var errorDescription: String? {
        "Notifications are disabled for Shayan Core. Enable them in iPhone Settings to receive reminders."
    }
}

struct RemindersView: View {
    @StateObject private var store = ReminderStore()
    @State private var title = ""
    @State private var date = Date().addingTimeInterval(3600)
    @State private var showAdd = false
    @State private var errorMessage: String?

    private var upcoming: [CoreReminder] {
        store.reminders.filter { !$0.isCompleted && $0.date >= Date() }
    }

    var body: some View {
        List {
            if upcoming.isEmpty {
                ContentUnavailableView(
                    "No Upcoming Reminders",
                    systemImage: "bell",
                    description: Text("Add a reminder and Shayan Core will schedule it with iOS.")
                )
            } else {
                Section("Upcoming") {
                    ForEach(upcoming) { reminder in
                        reminderRow(reminder)
                    }
                    .onDelete { offsets in
                        Task {
                            for index in offsets {
                                await store.delete(upcoming[index])
                            }
                        }
                    }
                }
            }

            let completed = store.reminders.filter { $0.isCompleted }
            if !completed.isEmpty {
                Section("Completed") {
                    ForEach(completed) { reminder in
                        reminderRow(reminder)
                    }
                }
            }
        }
        .navigationTitle("Smart Reminders")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    title = ""
                    date = Date().addingTimeInterval(3600)
                    showAdd = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add reminder")
            }
        }
        .sheet(isPresented: $showAdd) {
            NavigationStack {
                Form {
                    Section("Reminder") {
                        TextField("What do you need to remember?", text: $title)
                            .textInputAutocapitalization(.sentences)
                        DatePicker("When", selection: $date, in: Date()...)
                    }
                    Section {
                        Button("Schedule Reminder") {
                            let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !trimmed.isEmpty else { return }
                            Task {
                                do {
                                    try await store.add(title: trimmed, date: date)
                                    showAdd = false
                                } catch {
                                    errorMessage = error.localizedDescription
                                }
                            }
                        }
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                .navigationTitle("New Reminder")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showAdd = false }
                    }
                }
            }
            .presentationDetents([.medium])
        }
        .alert("Reminder Not Scheduled", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
    }

    @ViewBuilder
    private func reminderRow(_ reminder: CoreReminder) -> some View {
        HStack(spacing: 12) {
            Button {
                Task { await store.toggle(reminder) }
            } label: {
                Image(systemName: reminder.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(reminder.isCompleted ? .green : .blue)
                    .font(.title3)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.title)
                    .font(.body.weight(.semibold))
                    .strikethrough(reminder.isCompleted)
                Text(reminder.date.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day().hour().minute()))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 3)
    }
}
