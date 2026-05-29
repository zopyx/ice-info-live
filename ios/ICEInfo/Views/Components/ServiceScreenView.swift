import SwiftUI
import Combine

struct ServiceScreenView: View {
    let trainStatus: TrainStatus
    let serviceStation: StationInfo?
    let searchResults: [StationSearchResult]
    let onSearchQueryChange: (String) -> Void
    let onStationSelect: (StationSearchResult) -> Void
    let onLoadTrainStation: (String, String) -> Void

    @State private var searchText = ""
    @State private var searchTask: Task<Void, Never>? = nil

    var body: some View {
        VStack(spacing: 0) {
            searchBar

            if !searchText.isEmpty && !searchResults.isEmpty {
                searchResultsList
            } else if searchText.isEmpty, let station = serviceStation {
                stationInfoView(station)
            } else if !searchText.isEmpty && searchResults.isEmpty {
                noResultsView
            } else {
                emptyPromptView
            }
        }
        .onAppear {
            let eva = trainStatus.nextStopEva
            let name = trainStatus.nextStop
            if !eva.isEmpty, !name.isEmpty {
                onLoadTrainStation(eva, name)
            }
        }
        .onChange(of: searchText) { _, newValue in
            searchTask?.cancel()
            searchTask = Task {
                try? await Task.sleep(nanoseconds: 300_000_000)
                if !Task.isCancelled {
                    onSearchQueryChange(newValue)
                }
            }
        }
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Bahnhof suchen\u{2026}", text: $searchText)
                .autocorrectionDisabled()
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                    onSearchQueryChange("")
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(16)
    }

    private var searchResultsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(searchResults) { result in
                    Button {
                        onStationSelect(result)
                        searchText = ""
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(result.name)
                                    .font(.body.weight(.medium))
                                    .foregroundStyle(.primary)
                                Text("EVA-Nr. \(result.evaNr)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .contentShape(Rectangle())
                    }
                    if result.id != searchResults.last?.id {
                        Divider().padding(.leading, 16)
                    }
                }
            }
        }
    }

    private var noResultsView: some View {
        VStack(spacing: 8) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.title2)
                .foregroundStyle(.tertiary)
            Text("Keine Bahnh\u{00F6}fe gefunden")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    private var emptyPromptView: some View {
        VStack(spacing: 8) {
            Spacer()
            Image(systemName: "building.2")
                .font(.title2)
                .foregroundStyle(.tertiary)
            Text("Bahnhof ausw\u{00E4}hlen")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    private func stationInfoView(_ station: StationInfo) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                headerCard(station)
                if !station.staticFacilities.isEmpty {
                    staticFacilitiesCard(station)
                }
                liveFacilitiesCard(station)
            }
            .padding(16)
        }
    }

    private func headerCard(_ station: StationInfo) -> some View {
        AppCard {
            VStack(alignment: .leading, spacing: 4) {
                Text(station.name)
                    .font(.title3.weight(.bold))
                Text("EVA-Nr. \(station.evaNr)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func staticFacilitiesCard(_ station: StationInfo) -> some View {
        AppCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Ausstattung")
                    .font(.subheadline.weight(.bold))

                FlowLayout(spacing: 8) {
                    ForEach(station.staticFacilities, id: \.rawValue) { facility in
                        FacilityChip(type: facility)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private func liveFacilitiesCard(_ station: StationInfo) -> some View {
        if station.isLoading {
            AppCard {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .padding(16)
            }
        } else if let error = station.error {
            AppCard {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                    Text(error)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(16)
            }
        } else if !station.liveFacilities.isEmpty {
            AppCard {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Aktuelle Betriebsdaten")
                        .font(.subheadline.weight(.bold))

                    VStack(spacing: 0) {
                        ForEach(Array(station.liveFacilities.enumerated()), id: \.element.id) { index, facility in
                            liveFacilityRow(facility)
                            if index < station.liveFacilities.count - 1 {
                                Divider()
                            }
                        }
                    }
                }
                .padding(16)
            }
        }
    }

    private func liveFacilityRow(_ facility: StationFacility) -> some View {
        HStack(spacing: 12) {
            statusIcon(facility.status)
                .font(.title3)

            VStack(alignment: .leading, spacing: 2) {
                Text(facility.label)
                    .font(.subheadline.weight(.medium))
                if !facility.description.isEmpty {
                    Text(facility.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 10)
    }

    private func statusIcon(_ status: FacilityStatus) -> some View {
        switch status {
        case .active:
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
        case .inactive:
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(.red)
        case .unknown:
            Image(systemName: "questionmark.circle.fill")
                .foregroundStyle(.gray)
        }
    }
}

private struct FacilityChip: View {
    let type: FacilityType

    var body: some View {
        Label(facilityLabel, systemImage: facilityIcon)
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var facilityLabel: String {
        switch type {
        case .elevator: return "Aufzug"
        case .escalator: return "Rolltreppe"
        case .toilet: return "WC"
        case .wifi: return "WLAN"
        case .infoDesk: return "Information"
        case .departureMonitor: return "Abfahrtsmonitor"
        case .ramp: return "Rampe"
        case .parking: return "Parkplatz"
        case .bikeParking: return "Fahrradparken"
        case .waitingRoom: return "Warteraum"
        }
    }

    private var facilityIcon: String {
        switch type {
        case .elevator: return "arrow.up.and.down"
        case .escalator: return "stairs"
        case .toilet: return "toilet"
        case .wifi: return "wifi"
        case .infoDesk: return "info.circle"
        case .departureMonitor: return "tv"
        case .ramp: return "figure.roll"
        case .parking: return "parkingsign"
        case .bikeParking: return "bicycle"
        case .waitingRoom: return "sofa"
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        var width: CGFloat = 0
        var height: CGFloat = 0
        var lineX: CGFloat = 0
        var lineY: CGFloat = 0
        var lineHeight: CGFloat = 0

        for size in sizes {
            if lineX + size.width > (proposal.width ?? .infinity) {
                lineX = 0
                lineY += lineHeight + spacing
                lineHeight = 0
            }
            lineX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
            width = max(width, lineX)
            height = lineY + lineHeight
        }
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        var lineX = bounds.minX
        var lineY = bounds.minY
        var lineHeight: CGFloat = 0

        for (index, subview) in subviews.enumerated() {
            let size = sizes[index]
            if lineX + size.width > bounds.maxX {
                lineX = bounds.minX
                lineY += lineHeight + spacing
                lineHeight = 0
            }
            subview.place(at: CGPoint(x: lineX, y: lineY), proposal: ProposedViewSize(size))
            lineX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}

#Preview {
    ServiceScreenView(
        trainStatus: sampleTrainStatus,
        serviceStation: StationInfo(
            evaNr: "8000261",
            name: "M\u{00FC}nchen Hbf",
            liveFacilities: [
                StationFacility(id: "1", type: .elevator, label: "Aufzug Gleis 1-8", status: .active, description: "Zugang zu Gleis 1-8"),
                StationFacility(id: "2", type: .toilet, label: "WC Gleis 3", status: .inactive, description: "Sanierung bis 30.06."),
                StationFacility(id: "3", type: .wifi, label: "WLAN Hotspot", status: .active),
            ],
            staticFacilities: [.elevator, .toilet, .wifi, .infoDesk, .departureMonitor, .waitingRoom]
        ),
        searchResults: [
            StationSearchResult(evaNr: "8000261", name: "M\u{00FC}nchen Hbf"),
            StationSearchResult(evaNr: "8000260", name: "W\u{00FC}rzburg Hbf"),
        ],
        onSearchQueryChange: { _ in },
        onStationSelect: { _ in },
        onLoadTrainStation: { _, _ in }
    )
}
