import SwiftUI

struct TravelSummaryCard: View {
    @Environment(\.dbTheme) var theme
    let trainStatus: TrainStatus
    let targetStop: TrainStop?

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(targetStop?.station.name ?? trainStatus.destination.name)
                            .font(.headline)
                            .foregroundColor(theme.textPrimary)
                        if let eta = targetStop?.timetable.actualArrival ?? targetStop?.timetable.scheduledArrival {
                            HStack(spacing: 6) {
                                Text(eta, style: .time)
                                    .font(.subheadline)
                                    .foregroundColor(theme.textSecondary)
                                DelayBadge(minutes: targetStop?.delayMinutes ?? 0)
                            }
                        }
                    }
                    Spacer()
                }

                // Progress
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(theme.divider)
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(theme.primary)
                            .frame(width: max(0, min(CGFloat(progress) * geo.size.width, geo.size.width)), height: 8)
                    }
                }
                .frame(height: 8)

                HStack {
                    Text(remainingDistance)
                        .font(.caption)
                        .foregroundColor(theme.textSecondary)
                    Spacer()
                    Text(remainingTime)
                        .font(.caption)
                        .foregroundColor(theme.textSecondary)
                }
            }
        }
    }

    private var progress: Double {
        guard trainStatus.totalDistance > 0 else { return 0 }
        let targetDistance = targetStop?.distanceFromStart ?? trainStatus.totalDistance
        guard targetDistance > 0 else { return 0 }
        let current = min(Double(trainStatus.distanceFromStart), Double(targetDistance))
        return current / Double(targetDistance)
    }

    private var remainingDistance: String {
        let targetDistance = targetStop?.distanceFromStart ?? trainStatus.totalDistance
        let remaining = max(0, targetDistance - trainStatus.distanceFromStart)
        if remaining >= 1000 {
            return String(format: "%.1f km", Double(remaining) / 1000)
        } else {
            return "\(remaining) m"
        }
    }

    private var remainingTime: String {
        guard trainStatus.speed > 0 else { return "-- min" }
        let targetDistance = targetStop?.distanceFromStart ?? trainStatus.totalDistance
        let remaining = max(0, targetDistance - trainStatus.distanceFromStart)
        let minutes = remaining / (trainStatus.speed * 1000 / 60)
        return "~\(minutes) min"
    }
}
