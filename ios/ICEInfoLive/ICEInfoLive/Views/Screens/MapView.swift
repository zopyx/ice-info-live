import SwiftUI

struct MapView: View {
    @Environment(\.dbTheme) var theme
    @Bindable var viewModel: AppViewModel

    var body: some View {
        VStack {
            if let status = viewModel.trainStatus {
                MapCard(
                    coordinate: status.coordinate,
                    trainName: "\(status.trainType) \(status.trainNumber)"
                )
                .padding()
            } else {
                ContentUnavailableView(
                    String(localized: "no_position"),
                    systemImage: "map",
                    description: Text(String(localized: "waiting_for_data"))
                )
            }
        }
        .background(theme.background.ignoresSafeArea())
    }
}
