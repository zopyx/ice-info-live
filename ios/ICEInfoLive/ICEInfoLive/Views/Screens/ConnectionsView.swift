import SwiftUI

struct ConnectionsView: View {
    @Environment(\.dbTheme) var theme
    @Bindable var viewModel: AppViewModel

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if let target = viewModel.trainStatus?.stops.first(where: { $0.station.evaNr == viewModel.trainStatus?.targetStopEva }) {
                    TargetArrivalCard(stop: target)
                        .padding(.horizontal)
                }

                if !viewModel.connections.isEmpty {
                    SectionHeader(title: String(localized: "connections"))
                        .padding(.horizontal)

                    ForEach(viewModel.connections) { connection in
                        ConnectionRow(connection: connection)
                            .padding(.horizontal)
                    }
                }

                if !viewModel.departures.isEmpty {
                    SectionHeader(title: String(localized: "departures"))
                        .padding(.horizontal)

                    ForEach(viewModel.departures) { departure in
                        DepartureRow(departure: departure)
                            .padding(.horizontal)
                    }
                }

                if viewModel.connections.isEmpty && viewModel.departures.isEmpty {
                    ContentUnavailableView(
                        String(localized: "no_connections"),
                        systemImage: "arrow.triangle.2.circlepath",
                        description: Text(String(localized: "waiting_for_data"))
                    )
                    .padding(.top, 100)
                }
            }
            .padding(.vertical)
        }
        .background(theme.background.ignoresSafeArea())
    }
}

struct TargetArrivalCard: View {
    @Environment(\.dbTheme) var theme
    let stop: TrainStop

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 8) {
                Text(String(localized: "arrival_at"))
                    .font(.caption)
                    .foregroundColor(theme.textSecondary)
                Text(stop.station.name)
                    .font(.headline)
                    .foregroundColor(theme.textPrimary)
                HStack(spacing: 8) {
                    if let arrival = stop.timetable.actualArrival ?? stop.timetable.scheduledArrival {
                        Text(arrival, style: .time)
                            .font(.title3)
                    }
                    DelayBadge(minutes: stop.delayMinutes)
                    if let track = stop.track {
                        Text("Gl. \(track)")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(theme.surfaceVariant)
                            .cornerRadius(4)
                    }
                }
            }
        }
    }
}

struct ConnectionRow: View {
    @Environment(\.dbTheme) var theme
    let connection: ConnectingTrain

    var body: some View {
        AppCard {
            HStack(spacing: 12) {
                // Reachability indicator
                Circle()
                    .fill(reachabilityColor)
                    .frame(width: 10, height: 10)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("\(connection.type) \(connection.number)")
                            .font(.subheadline.bold())
                            .foregroundColor(theme.textPrimary)
                        Spacer()
                        Text(connection.departureTime, style: .time)
                            .font(.subheadline)
                    }

                    Text("→ \(connection.destination)")
                        .font(.caption)
                        .foregroundColor(theme.textSecondary)

                    HStack(spacing: 8) {
                        if connection.delayMinutes > 0 {
                            DelayBadge(minutes: connection.delayMinutes, size: .small)
                        }
                        if let track = connection.track {
                            Text("Gl. \(track)")
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(theme.surfaceVariant)
                                .cornerRadius(4)
                        }
                        Text(reachabilityText)
                            .font(.caption2)
                            .foregroundColor(reachabilityColor)
                    }
                }
            }
        }
    }

    private var reachabilityColor: Color {
        if connection.reachable { return .green }
        if connection.transferMinutes <= 3 { return .orange }
        return .red
    }

    private var reachabilityText: String {
        if connection.reachable { return String(localized: "reachable") }
        if connection.transferMinutes <= 3 { return String(localized: "tight") }
        return String(localized: "missed")
    }
}

struct DepartureRow: View {
    @Environment(\.dbTheme) var theme
    let departure: Departure

    var body: some View {
        AppCard {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(departure.lineName)
                            .font(.subheadline.bold())
                            .foregroundColor(theme.textPrimary)
                        Spacer()
                        Text(departure.scheduledTime, style: .time)
                            .font(.subheadline)
                    }
                    Text("→ \(departure.destination)")
                        .font(.caption)
                        .foregroundColor(theme.textSecondary)

                    HStack(spacing: 8) {
                        if departure.delayMinutes > 0 {
                            DelayBadge(minutes: departure.delayMinutes, size: .small)
                        }
                        if let platform = departure.platform {
                            Text("Gl. \(platform)")
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(theme.surfaceVariant)
                                .cornerRadius(4)
                        }
                        if departure.cancelled {
                            Text(String(localized: "cancelled"))
                                .font(.caption2)
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
    }
}

struct SectionHeader: View {
    @Environment(\.dbTheme) var theme
    let title: String

    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(theme.textPrimary)
    }
}
