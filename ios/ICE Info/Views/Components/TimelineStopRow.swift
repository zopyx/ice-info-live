import SwiftUI

struct TimelineStopRow: View {
    let stop: TrainStop
    let isFirst: Bool
    let isLast: Bool

    private var isPassed: Bool { stop.passed }
    private var isNext: Bool { stop.isNext }

    var body: some View {
        HStack(spacing: 0) {
            timeColumn
            timelineColumn
            stationColumn
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private var timeColumn: some View {
        VStack(alignment: .trailing, spacing: 2) {
            if !stop.scheduledArrival.isEmpty {
                StopTimePair(
                    scheduled: stop.scheduledArrival,
                    actual: stop.actualArrival,
                    delay: stop.delayMinutes,
                    isPassed: isPassed,
                    isNext: isNext,
                    isCancelled: stop.isCancelled
                )
            }
            if !stop.scheduledDeparture.isEmpty {
                StopTimePair(
                    scheduled: stop.scheduledDeparture,
                    actual: stop.actualDeparture,
                    delay: stop.departureDelayMinutes,
                    isPassed: isPassed,
                    isNext: isNext,
                    isCancelled: stop.isCancelled
                )
            }
        }
        .frame(width: 88)
        .padding(.trailing, 6)
        .padding(.vertical, isNext ? 12 : 8)
    }

    private var timelineColumn: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(isFirst ? .clear : (isPassed || isNext ? .primary : Color(.systemGray4)))
                .frame(width: 2)
                .frame(maxHeight: .infinity)

            Group {
                if stop.isCancelled {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.red.opacity(0.7))
                } else if isNext {
                    ZStack {
                        Circle().fill(.primary).frame(width: 20, height: 20)
                        Image(systemName: "tram.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(Color(.systemBackground))
                    }
                } else if isPassed {
                    Circle().fill(.primary).frame(width: 8, height: 8)
                } else {
                    Circle()
                        .stroke(Color(.systemGray3), lineWidth: 2)
                        .frame(width: 12, height: 12)
                        .background(Color(.systemBackground).clipShape(Circle()))
                }
            }

            Rectangle()
                .fill(isLast ? .clear : (isPassed ? .primary : Color(.systemGray4)))
                .frame(width: 2)
                .frame(maxHeight: .infinity)
        }
        .frame(width: 24)
    }

    private var stationColumn: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(stop.name)
                .font(isNext ? .title3 : .body)
                .fontWeight(isNext ? .bold : (isPassed ? .regular : .medium))
                .foregroundStyle {
                    if stop.isCancelled { return .red.opacity(0.7) as! Color }
                    if isPassed { return .primary.opacity(0.45) as! Color }
                    if isNext { return Color(.systemBackground) as! Color }
                    return .primary
                }
                .strikethrough(stop.isCancelled)

            if stop.isCancelled {
                HStack(spacing: 3) {
                    Image(systemName: "xmark.circle.fill").font(.system(size: 11))
                    Text("Ausgefallen").font(.caption2)
                }
                .foregroundStyle(.red.opacity(0.7))
            }

            if !stop.isCancelled && !stop.track.isEmpty {
                Text("Gl. \(stop.track)")
                    .font(.caption2)
                    .foregroundStyle(.secondary.opacity(isPassed ? 0.5 : 1))
            }

            if stop.isAdditional {
                HStack(spacing: 3) {
                    Image(systemName: "plus.circle.fill").font(.system(size: 11))
                    Text("Zusatzhalt").font(.caption2)
                }
                .foregroundStyle(Color(red: 0, green: 0.463, blue: 0.714))
            }
        }
        .padding(.vertical, isNext ? 12 : 8)
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            if isNext {
                Color.primary.opacity(0.08)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}
