import SwiftUI

struct StatusView: View {
    let status: TrainStatus
    let isDarkTheme: Bool
    let isMockMode: Bool
    let demoSpeed: Int
    let showDemoSpeed: Bool
    let reducedMotion: Bool
    let onDemoSpeedChange: (Int) -> Void
    let onTargetStopChange: (String?) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                TrainHeader(status: status, reducedMotion: reducedMotion)

                StopSelectionCard(
                    status: status,
                    onTargetStopChange: onTargetStopChange
                )

                TravelSummaryCard(status: status)

                ConnectivityRow(status: status, isDarkTheme: isDarkTheme)

                if !status.delayReason.isEmpty {
                    DelayReasonCard(reason: status.delayReason)
                }

                if isMockMode && showDemoSpeed {
                    DemoSpeedCard(speed: demoSpeed, onSpeedChange: onDemoSpeedChange)
                }

                Spacer().frame(height: 96)
            }
            .padding(.horizontal, 16)
        }
        .background(Color(.systemBackground))
    }
}

struct StopSelectionCard: View {
    let status: TrainStatus
    let onTargetStopChange: (String?) -> Void

    @State private var expanded = false

    private var upcomingStops: [TrainStop] {
        status.stops.filter { !$0.passed }
    }

    private var currentTarget: TrainStop? {
        status.targetStopEva.flatMap { eva in upcomingStops.first { $0.evaNr == eva } }
    }

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Zielhalt")
                    .font(.subheadline.weight(.bold))

                Menu {
                    Button {
                        onTargetStopChange(nil)
                    } label: {
                        HStack {
                            Text("Kein Ziel")
                            if currentTarget == nil {
                                Image(systemName: "checkmark")
                            }
                        }
                    }

                    ForEach(upcomingStops) { stop in
                        Button {
                            onTargetStopChange(stop.evaNr)
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(stop.name)
                                    Text(stop.scheduledArrival)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if stop.evaNr == status.targetStopEva {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "tram.fill")
                            .font(.body)
                        Text(currentTarget?.name ?? "Kein Ziel")
                            .font(.body)
                        Spacer()
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.caption)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(16)
        }
    }
}

struct DemoSpeedCard: View {
    let speed: Int
    let onSpeedChange: (Int) -> Void

    @State private var isExpanded = true

    var body: some View {
        AppCard {
            VStack(spacing: 8) {
                Button {
                    withAnimation { isExpanded.toggle() }
                } label: {
                    HStack {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        Text("Demo-Geschwindigkeit")
                            .font(.subheadline.weight(.bold))
                        Spacer()
                        Text("\(speed) km/h")
                            .font(.subheadline.weight(.bold))
                    }
                }
                .buttonStyle(.plain)

                if isExpanded {
                    Slider(
                        value: Binding(
                            get: { Double(speed) },
                            set: { onSpeedChange(Int($0)) }
                        ),
                        in: 0...300,
                        step: 5
                    )
                    .tint(.primary)

                    HStack {
                        Text("0 km/h").font(.caption2)
                        Spacer()
                        Text("150 km/h").font(.caption2)
                        Spacer()
                        Text("300 km/h").font(.caption2)
                    }
                    .foregroundStyle(.secondary.opacity(0.7))
                }
            }
            .padding(16)
            .background(Color.primary.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}
