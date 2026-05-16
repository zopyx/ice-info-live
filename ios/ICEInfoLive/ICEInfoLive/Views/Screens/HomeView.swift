import SwiftUI

struct HomeView: View {
    @Environment(\.dbTheme) var theme
    @Bindable var viewModel: AppViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let status = viewModel.trainStatus {
                    TrainHeader(
                        trainStatus: status,
                        reducedMotion: viewModel.settings.reducedMotion
                    )

                    TargetStopSelector(viewModel: viewModel, status: status)

                    TravelSummaryCard(
                        trainStatus: status,
                        targetStop: status.stops.first { $0.station.evaNr == status.targetStopEva }
                    )

                    ConnectivityRow(
                        connectivity: status.connectivity,
                        wagonClass: status.wagonClass
                    )

                    if !status.delayReasons.isEmpty {
                        DelayReasonCard(reasons: status.delayReasons)
                    }

                    if viewModel.settings.isMockMode {
                        DemoSpeedSlider(viewModel: viewModel)
                    }
                } else {
                    ContentUnavailableView(
                        String(localized: "no_data"),
                        systemImage: "train.side.front.car",
                        description: Text(String(localized: "waiting_for_data"))
                    )
                }
            }
            .padding()
        }
        .background(theme.background.ignoresSafeArea())
    }
}

// MARK: - Target Stop Selector

struct TargetStopSelector: View {
    @Environment(\.dbTheme) var theme
    @Bindable var viewModel: AppViewModel
    let status: TrainStatus
    @State private var isExpanded = false

    var upcomingStops: [TrainStop] {
        status.stops.filter { !$0.passed }
    }

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 8) {
                Text(String(localized: "target_stop"))
                    .font(.caption)
                    .foregroundColor(theme.textSecondary)

                Menu {
                    Button {
                        viewModel.setTargetStop(evaNr: nil)
                    } label: {
                        Label(String(localized: "destination_default"), systemImage: "flag.checkered")
                    }

                    ForEach(upcomingStops) { stop in
                        Button {
                            viewModel.setTargetStop(evaNr: stop.station.evaNr)
                        } label: {
                            HStack {
                                Text(stop.station.name)
                                if stop.station.evaNr == status.targetStopEva {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(theme.primary)
                        Text(selectedStopName)
                            .font(.subheadline.bold())
                            .foregroundColor(theme.textPrimary)
                        Spacer()
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.caption)
                            .foregroundColor(theme.textSecondary)
                    }
                }
            }
        }
    }

    private var selectedStopName: String {
        if let eva = status.targetStopEva,
           let stop = status.stops.first(where: { $0.station.evaNr == eva }) {
            return stop.station.name
        }
        return status.destination.name
    }
}

// MARK: - Demo Speed Slider

struct DemoSpeedSlider: View {
    @Environment(\.dbTheme) var theme
    @Bindable var viewModel: AppViewModel

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 8) {
                Text(String(localized: "demo_speed"))
                    .font(.caption)
                    .foregroundColor(theme.textSecondary)

                HStack {
                    Slider(
                        value: Binding(
                            get: { Double(viewModel.settings.demoSpeed) },
                            set: { viewModel.settings.demoSpeed = Int($0) }
                        ),
                        in: 0...300,
                        step: 1
                    )
                    .tint(theme.primary)

                    Text("\(viewModel.settings.demoSpeed) km/h")
                        .font(.subheadline.monospacedDigit())
                        .foregroundColor(theme.textPrimary)
                        .frame(width: 80, alignment: .trailing)
                }
            }
        }
    }
}
