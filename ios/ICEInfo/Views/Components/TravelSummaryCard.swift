import SwiftUI

struct TravelSummaryCard: View {
    let status: TrainStatus

    var body: some View {
        let targetStop = status.stops.first { $0.evaNr == status.targetStopEva && !$0.passed }
        let displayDestination = targetStop?.name ?? status.destination
        let displayEta = targetStop?.actualArrival.nilIfEmpty ?? targetStop?.scheduledArrival ?? status.destinationEta
        let displayDelay = targetStop?.delayMinutes ?? status.destinationDelay

        let stopsToTarget = if let t = targetStop {
            status.stops.filter { !$0.passed && $0.distanceFromStart <= t.distanceFromStart }
        } else {
            status.stops.filter { !$0.passed }
        }
        let totalStops = status.stops.count
        let passedStops = status.stops.filter(\.passed).count
        let targetDist = targetStop?.distanceFromStart ?? status.stops.last?.distanceFromStart ?? 0
        let remainingDist = max(0, targetDist - status.actualPosition)
        let progress = targetDist > 0 ? min(1, max(0, Float(status.actualPosition) / Float(targetDist))) : 0

        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("\u{2192} \(displayDestination)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(.systemBackground))

                Spacer().frame(height: 7)

                HStack {
                    Text("\(remainingDist / 1000) km verbleibend")
                        .font(.body)
                    Spacer()
                    if let t = targetStop {
                        Text("\(stopsToTarget.count) Halte")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("\(passedStops)/\(totalStops)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                if status.speed > 0 {
                    WavyProgressView(progress: progress, speed: status.speed)
                        .frame(height: 8)
                } else {
                    ProgressView(value: Double(progress))
                        .tint(Color(.systemBackground))
                }

                Spacer().frame(height: 7)

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Ankunft \(displayEta)")
                            .font(.body.weight(.semibold))
                        Text(formatRemainingTimeUntil(scheduledArrival: targetStop?.scheduledArrival ?? status.destinationEta, delayMinutes: displayDelay))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if displayDelay > 0 {
                        DelayBadge(delayMinutes: displayDelay)
                    } else {
                        Text("P\u{00FC}nktlich")
                            .font(.caption.bold())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(.systemBackground).opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
            .padding(16)
            .background(Color(red: 0.925, green: 0, blue: 0.086))
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

struct WavyProgressView: View {
    let progress: Float
    let speed: Int

    @State private var phase: CGFloat = 0

    var body: some View {
        TimelineView(.animation) { timeline in
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let waveSpeed = min(CGFloat(speed) / 15, 20)
                let p = CGFloat(progress)

                Canvas { context, size in
                    let waveHeight: CGFloat = 3
                    let path = Path { path in
                        path.move(to: CGPoint(x: 0, y: h))
                        for x in stride(from: 0, through: w, by: 1) {
                            let y = h - waveHeight * sin((x / w + phase) * .pi * 4)
                            if x <= w * p {
                                path.addLine(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: h))
                            }
                        }
                        path.addLine(to: CGPoint(x: w, y: h))
                        path.closeSubpath()
                    }
                    context.fill(path, with: .color(.white.opacity(0.3)))
                }
                .onChange(of: timeline.date.timeIntervalSince1970) { _, _ in
                    phase += 0.02 * waveSpeed
                }
            }
        }
    }
}

extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
