import SwiftUI
import WidgetKit

struct ShayanCoreWidgetEntry: TimelineEntry {
    let date: Date
    let nextReminder: SharedReminderRecord?
    let todayCount: Int
}

struct ShayanCoreWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> ShayanCoreWidgetEntry {
        ShayanCoreWidgetEntry(
            date: Date(),
            nextReminder: SharedReminderRecord(
                id: UUID(),
                title: "Review your priorities",
                date: Date().addingTimeInterval(3600),
                isCompleted: false
            ),
            todayCount: 1
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (ShayanCoreWidgetEntry) -> Void) {
        completion(makeEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ShayanCoreWidgetEntry>) -> Void) {
        let entry = makeEntry()
        completion(Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(900))))
    }

    private func makeEntry() -> ShayanCoreWidgetEntry {
        let reminders = CoreReminderStorage.load([SharedReminderRecord].self) ?? []
        let upcoming = reminders
            .filter { !$0.isCompleted && $0.date >= Date() }
            .sorted { $0.date < $1.date }

        let calendar = Calendar.current
        let todayCount = upcoming.filter { calendar.isDateInToday($0.date) }.count

        return ShayanCoreWidgetEntry(
            date: Date(),
            nextReminder: upcoming.first,
            todayCount: todayCount
        )
    }
}

struct ShayanCoreWidgetView: View {
    let entry: ShayanCoreWidgetEntry
    @Environment(.widgetFamily) private var family

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "circle.hexagongrid.fill")
                    .foregroundStyle(.cyan)
                Text("SHAYAN CORE")
                    .font(.caption.weight(.bold))
                    .tracking(1)
                Spacer()
            }

            if let reminder = entry.nextReminder {
                Text("NEXT REMINDER")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)

                Text(reminder.title)
                    .font(.headline)
                    .lineLimit(family == .systemSmall ? 2 : 1)

                Text(reminder.date.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day().hour().minute()))
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    Button(intent: CompleteNextReminderAction()) {
                        Label("Done", systemImage: "checkmark")
                            .font(.caption2.weight(.bold))
                    }
                    .buttonStyle(.borderedProminent)

                    Link(destination: URL(string: "shayan-core://reminders")!) {
                        Image(systemName: "bell")
                            .font(.caption.weight(.semibold))
                    }
                }
            } else {
                Text("All clear")
                    .font(.title3.bold())

                Text("No upcoming reminders")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Link(destination: URL(string: "shayan-core://reminders")!) {
                    Label("Add reminder", systemImage: "plus")
                        .font(.caption.weight(.semibold))
                }
            }

            if family == .systemMedium {
                HStack {
                    Text("(entry.todayCount) today")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Link(destination: URL(string: "shayan-core://command")!) {
                        Label("Core Command", systemImage: "command")
                            .font(.caption2.weight(.semibold))
                    }
                }
            }
        }
        .invalidatableContent()
        .containerBackground(for: .widget) {
            Color(red: 0.025, green: 0.035, blue: 0.07)
        }
    }
}

struct ShayanCoreWidget: Widget {
    let kind = "ShayanCoreWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ShayanCoreWidgetProvider()) { entry in
            ShayanCoreWidgetView(entry: entry)
        }
        .configurationDisplayName("Shayan Core")
        .description("Your reminders and Core Command, right on the Home Screen.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
