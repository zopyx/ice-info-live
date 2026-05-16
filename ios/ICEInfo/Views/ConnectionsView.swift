import SwiftUI

struct ConnectionsView: View {
    let status: TrainStatus
    let connections: [ConnectingTrain]
    let departures: [Departure]

    private var targetStop: TrainStop? {
        status.targetStopEva.flatMap { eva in
            status.stops.first { $0.evaNr == eva && !$0.passed }
        }
    }

    private var stationName: String {
        targetStop?.name ?? status.nextStop
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                connectionsCard
                if !departures.isEmpty {
                    departuresCard
                }
                Spacer().frame(height: 96)
            }
            .padding(16)
        }
        .background(Color(.systemBackground))
    }

    private var connectionsCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Anschl\u{00FC}sse in \(stationName)")
                        .font(.subheadline.weight(.bold))

                    let stop = targetStop ?? status.stops.first(where: { !$0.passed })
                    if let stop, !stop.scheduledArrival.isEmpty {
                        let isDelayed = stop.delayMinutes > 0
                        let displayTime = stop.actualArrival.isEmpty ? stop.scheduledArrival : stop.actualArrival
                        HStack(spacing: 4) {
                            Text("Ankunft \(stop.scheduledArrival)")
                                .font(.caption)
                                .foregroundStyle(isDelayed ? Color.secondary.opacity(0.5) : Color.secondary)
                                .strikethrough(isDelayed)
                            if isDelayed {
                                Text(displayTime)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(stop.delayMinutes >= 5 ? .red : .green)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 12)

                if connections.isEmpty {
                    Text("Keine Anschl\u{00FC}sse")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                } else {
                    VStack(spacing: 0) {
                        ForEach(Array(connections.enumerated()), id: \.element.id) { index, conn in
                            ConnectionRow(conn: conn)
                                .padding(.horizontal, 16)
                            if index < connections.count - 1 {
                                Divider()
                                    .padding(.horizontal, 16)
                            }
                        }
                    }
                    .padding(.bottom, 16)
                }
            }
        }
    }

    private var departuresCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 0) {
                Text("Weitere Abfahrten \(stationName)")
                    .font(.subheadline.weight(.bold))
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 12)

                VStack(spacing: 0) {
                    ForEach(Array(departures.enumerated()), id: \.element.id) { index, dep in
                        DepartureRow(dep: dep)
                            .padding(.horizontal, 16)
                        if index < departures.count - 1 {
                            Divider()
                                .padding(.horizontal, 16)
                        }
                    }
                }
                .padding(.bottom, 16)
            }
        }
    }
}
