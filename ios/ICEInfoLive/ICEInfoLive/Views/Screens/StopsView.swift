import SwiftUI

struct StopsView: View {
    @Environment(\.dbTheme) var theme
    @Bindable var viewModel: AppViewModel

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if let stops = viewModel.trainStatus?.stops, !stops.isEmpty {
                    ForEach(Array(stops.enumerated()), id: \.element.id) { index, stop in
                        TimelineStopRow(
                            stop: stop,
                            isLast: index == stops.count - 1
                        )
                        .padding(.horizontal)
                    }

                    if !viewModel.pois.isEmpty {
                        PoiSection(pois: viewModel.pois)
                            .padding(.top)
                    }
                } else {
                    ContentUnavailableView(
                        String(localized: "no_stops"),
                        systemImage: "list.bullet",
                        description: Text(String(localized: "waiting_for_data"))
                    )
                    .padding(.top, 100)
                }
            }
        }
        .background(theme.background.ignoresSafeArea())
    }
}

struct PoiSection: View {
    @Environment(\.dbTheme) var theme
    let pois: [PoiItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "nearby"))
                .font(.headline)
                .foregroundColor(theme.textPrimary)
                .padding(.horizontal)

            ForEach(pois) { poi in
                AppCard {
                    HStack(spacing: 12) {
                        Image(systemName: iconForType(poi.type))
                            .font(.title2)
                            .foregroundColor(theme.secondary)
                            .frame(width: 40)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(poi.name)
                                .font(.subheadline.bold())
                                .foregroundColor(theme.textPrimary)
                            if let desc = poi.description {
                                Text(desc)
                                    .font(.caption)
                                    .foregroundColor(theme.textSecondary)
                            }
                        }

                        Spacer()

                        Text("\(poi.distance) m")
                            .font(.caption)
                            .foregroundColor(theme.textSecondary)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private func iconForType(_ type: String) -> String {
        switch type.lowercased() {
        case "city": return "building.2"
        case "river", "lake": return "water.waves"
        case "mountain": return "mountain.2"
        case "monument": return "building.columns"
        default: return "mappin"
        }
    }
}
