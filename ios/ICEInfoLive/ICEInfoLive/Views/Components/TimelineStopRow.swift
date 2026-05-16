import SwiftUI

struct TimelineStopRow: View {
    @Environment(\.dbTheme) var theme
    let stop: TrainStop
    let isLast: Bool

    var body: some View {
        HStack(spacing: 16) {
            // Timeline
            ZStack {
                VStack(spacing: 0) {
                    if !isFirst {
                        Rectangle()
                            .fill(lineColor)
                            .frame(width: 2)
                            .frame(maxHeight: .infinity)
                    }
                    if !isLast {
                        Rectangle()
                            .fill(lineColor)
                            .frame(width: 2)
                            .frame(maxHeight: .infinity)
                    }
                }

                Circle()
                    .fill(dotColor)
                    .frame(width: 12, height: 12)
                    .overlay(
                        Circle()
                            .stroke(theme.background, lineWidth: 2)
                    )
            }
            .frame(width: 20)

            // Content
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(stop.station.name)
                        .font(.subheadline.bold())
                        .foregroundColor(textColor)

                    if stop.cancelled {
                        Text(String(localized: "cancelled"))
                            .font(.caption2)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .cornerRadius(4)
                    }

                    if stop.additionalStop {
                        Text(String(localized: "additional_stop"))
                            .font(.caption2)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange)
                            .cornerRadius(4)
                    }

                    Spacer()

                    if let track = stop.track {
                        Text("Gl. \(track)")
                            .font(.caption)
                            .foregroundColor(theme.textSecondary)
                    }
                }

                HStack(spacing: 12) {
                    if let arrival = stop.timetable.actualArrival ?? stop.timetable.scheduledArrival {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.down")
                                .font(.caption2)
                            Text(arrival, style: .time)
                                .font(.caption)
                        }
                        .foregroundColor(theme.textSecondary)
                    }

                    if let departure = stop.timetable.actualDeparture ?? stop.timetable.scheduledDeparture {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up")
                                .font(.caption2)
                            Text(departure, style: .time)
                                .font(.caption)
                        }
                        .foregroundColor(theme.textSecondary)
                    }

                    if stop.delayMinutes > 0 {
                        DelayBadge(minutes: stop.delayMinutes, size: .small)
                    }
                }
            }
            .padding(.vertical, 8)
            .opacity(stop.passed ? 0.5 : 1.0)
        }
    }

    private var isFirst: Bool { false } // Would need index from parent

    private var lineColor: Color {
        if stop.passed || stop.isCurrentStop {
            return theme.primary
        }
        return theme.divider
    }

    private var dotColor: Color {
        if stop.isCurrentStop {
            return theme.primary
        }
        if stop.passed {
            return theme.primary.opacity(0.5)
        }
        return theme.divider
    }

    private var textColor: Color {
        if stop.isCurrentStop {
            return theme.primary
        }
        return theme.textPrimary
    }
}
