import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), trainName: "ICE 123", speed: 250, nextStop: "Frankfurt Hbf", targetStop: "Berlin Hbf", delay: 2, isApproaching: false, isMockMode: false)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = readWidgetState()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = readWidgetState()
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }

    private func readWidgetState() -> SimpleEntry {
        let defaults = UserDefaults(suiteName: "group.com.nruge.iceinfo")
        return SimpleEntry(
            date: Date(),
            trainName: defaults?.string(forKey: "widget_trainName") ?? "--",
            speed: defaults?.integer(forKey: "widget_speed") ?? 0,
            nextStop: defaults?.string(forKey: "widget_nextStop") ?? "--",
            targetStop: defaults?.string(forKey: "widget_targetStop") ?? "--",
            delay: defaults?.integer(forKey: "widget_delay") ?? 0,
            isApproaching: defaults?.bool(forKey: "widget_isApproaching") ?? false,
            isMockMode: defaults?.bool(forKey: "widget_isMockMode") ?? false
        )
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let trainName: String
    let speed: Int
    let nextStop: String
    let targetStop: String
    let delay: Int
    let isApproaching: Bool
    let isMockMode: Bool
}

struct ICEInfoLiveWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

struct SmallWidgetView: View {
    let entry: SimpleEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "train.side.front.car")
                    .foregroundColor(Color(red: 0.925, green: 0, blue: 0.086))
                Text(entry.trainName)
                    .font(.caption.bold())
                Spacer()
            }

            Text("\(entry.speed) km/h")
                .font(.title2.bold())

            Spacer()

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.nextStop)
                    .font(.caption2)
                    .lineLimit(1)
                if entry.delay > 0 {
                    Text("+\(entry.delay) min")
                        .font(.caption2)
                        .foregroundColor(.red)
                }
            }

            if entry.isApproaching {
                Text("Exit Now!")
                    .font(.caption2.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.red)
                    .cornerRadius(4)
            }
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct MediumWidgetView: View {
    let entry: SimpleEntry

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "train.side.front.car")
                        .foregroundColor(Color(red: 0.925, green: 0, blue: 0.086))
                    Text(entry.trainName)
                        .font(.subheadline.bold())
                }

                Text("\(entry.speed) km/h")
                    .font(.title.bold())

                if entry.isMockMode {
                    Text("Demo")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.2))
                        .cornerRadius(4)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Next")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(entry.nextStop)
                        .font(.caption.bold())
                        .lineLimit(1)
                }

                VStack(alignment: .trailing, spacing: 2) {
                    Text("Target")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(entry.targetStop)
                        .font(.caption.bold())
                        .lineLimit(1)
                }

                if entry.delay > 0 {
                    Text("+\(entry.delay) min")
                        .font(.caption2)
                        .foregroundColor(.red)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.red.opacity(0.15))
                        .cornerRadius(8)
                }

                if entry.isApproaching {
                    Text("Exit Now!")
                        .font(.caption2.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.red)
                        .cornerRadius(6)
                }
            }
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct ICEInfoLiveWidget: Widget {
    let kind: String = "ICEInfoLiveWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ICEInfoLiveWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("ICE Info Live")
        .description("Shows current train status and next stops.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
