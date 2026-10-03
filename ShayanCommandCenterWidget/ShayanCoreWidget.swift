import SwiftUI
import WidgetKit

struct ShayanCoreWidgetEntry: TimelineEntry {
    let date: Date
}

struct ShayanCoreWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> ShayanCoreWidgetEntry {
        ShayanCoreWidgetEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (ShayanCoreWidgetEntry) -> Void) {
        completion(ShayanCoreWidgetEntry(date: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ShayanCoreWidgetEntry>) -> Void) {
        let entry = ShayanCoreWidgetEntry(date: Date())
        completion(Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(1800))))
    }
}

struct ShayanCoreWidgetView: View {
    let entry: ShayanCoreWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "circle.hexagongrid.fill")
                    .foregroundStyle(.blue)
                Text("SHAYAN CORE")
                    .font(.caption.weight(.bold))
                    .tracking(1)
            }

            Spacer(minLength: 2)

            Text("Your personal")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("digital core")
                .font(.title3.bold())

            Spacer(minLength: 2)

            HStack(spacing: 8) {
                Link(destination: URL(string: "shayan-core://command")!) {
                    Label("Command", systemImage: "magnifyingglass")
                        .font(.caption2.weight(.semibold))
                }
                Link(destination: URL(string: "shayan-core://reminders")!) {
                    Image(systemName: "bell")
                        .font(.caption.weight(.semibold))
                }
            }
        }
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
        .description("Quick access to Core Command and Smart Reminders.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
