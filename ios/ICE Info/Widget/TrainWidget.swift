import WidgetKit
import SwiftUI

struct TrainWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> TrainWidgetEntry {
        TrainWidgetEntry(date: Date(), status: sampleTrainStatus, targetStopName: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (TrainWidgetEntry) -> Void) {
        let entry = TrainWidgetEntry(date: Date(), status: sampleTrainStatus, targetStopName: "Göttingen")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TrainWidgetEntry>) -> Void) {
        let defaults = UserDefaults(suiteName: SettingsKeys.appGroupID)
        var status = TrainStatus.disconnected
        var targetStopName: String? = nil

        if let data = defaults?.data(forKey: "widgetTrainStatus"),
           let decoded = try? JSONDecoder().decode(TrainStatus.self, from: data) {
            status = decoded
        }
        if let name = defaults?.string(forKey: "widgetTargetStopName") {
            targetStopName = name
        }

        let entry = TrainWidgetEntry(date: Date(), status: status, targetStopName: targetStopName)
        let refresh = Calendar.current.date(byAdding: .minute, value: 1, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(refresh))
        completion(timeline)
    }
}

struct TrainWidgetEntry: TimelineEntry {
    let date: Date
    let status: TrainStatus
    let targetStopName: String?
}

struct TrainWidgetEntryView: View {
    var entry: TrainWidgetEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidget
        case .systemMedium:
            mediumWidget
        case .accessoryInline, .accessoryCircular, .accessoryRectangular:
            smallWidget
        default:
            smallWidget
        }
    }

    private var smallWidget: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("\(entry.status.trainType) \(entry.status.trainNumber)")
                    .font(.caption.weight(.semibold))
                Spacer()
                Text("\(entry.status.speed) km/h")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color(red: 0.925, green: 0, blue: 0.086))
            }

            Spacer()

            let displayStop = entry.targetStopName ?? entry.status.nextStop
            Text(displayStop)
                .font(.body.weight(.bold))
                .lineLimit(1)

            if let targetName = entry.targetStopName, entry.status.stops.first(where: { $0.name == targetName })?.passed ?? false {
                Text("Jetzt aussteigen!")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.red)
            } else {
                Text("Ankunft \(entry.status.eta)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if entry.status.delayMinutes > 0 {
                    Text("+\(entry.status.delayMinutes)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.red)
                }
            }
        }
        .padding(12)
        .containerBackground(.background, for: .widget)
    }

    private var mediumWidget: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("\(entry.status.trainType) \(entry.status.trainNumber)")
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Text("\(entry.status.speed) km/h")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color(red: 0.925, green: 0, blue: 0.086))
                }

                let displayStop = entry.targetStopName ?? entry.status.nextStop
                Text(displayStop)
                    .font(.title3.weight(.bold))
                    .lineLimit(1)

                HStack {
                    Text("Ankunft \(entry.status.eta)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if entry.status.delayMinutes > 0 {
                        Text("+\(entry.status.delayMinutes)")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.red)
                    }
                }

                if !entry.status.destinationTrack.isEmpty {
                    Text("Gl. \(entry.status.destinationTrack)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if let targetName = entry.targetStopName,
               entry.status.stops.first(where: { $0.name == targetName })?.passed ?? false {
                Text("Aussteigen!")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.red)
                    .padding(8)
                    .background(.red.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(16)
        .containerBackground(.background, for: .widget)
    }
}

struct TrainWidget: Widget {
    let kind: String = "TrainWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TrainWidgetProvider()) { entry in
            TrainWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("ICE Info")
        .description("Zeigt aktuelle ICE-Informationen an.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
