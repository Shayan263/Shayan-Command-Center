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
                    .foregroundStyle(.cyan)
                Text("SHAYAN CORE")
                    .font(.caption.weight(.bold))
                    .tracking(1)
                Spacer()
            }

            Text("Command Center")
                .font(.title3.bold())

            Text("Your personal digital core")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            Link(destination: URL(string: "shayan-core://command")!) {
                Label("Open Core Command", systemImage: "command")
                    .font(.caption.weight(.semibold))
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
        .description("Quick access to your Shayan Core Command Center.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
