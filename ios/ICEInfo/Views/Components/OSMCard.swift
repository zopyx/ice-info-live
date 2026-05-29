import SwiftUI

struct OSMCard: View {
    let osmData: OsmTrackData

    var body: some View {
        if osmData.isLoading {
            loadingView
        } else if let error = osmData.error {
            errorView(error)
        } else {
            contentView
        }
    }

    private var loadingView: some View {
        AppCard {
            HStack {
                Spacer()
                ProgressView()
                Spacer()
            }
            .padding(16)
        }
    }

    private func errorView(_ error: String) -> some View {
        AppCard {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                    .font(.subheadline)
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
        }
    }

    private var contentView: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                trackInfoSection
                if !osmData.features.isEmpty {
                    featuresSection
                }
            }
            .padding(16)
        }
    }

    private var trackInfoSection: some View {
        let info = osmData.trackInfo
        return VStack(alignment: .leading, spacing: 8) {
            Text("Streckendaten")
                .font(.subheadline.weight(.bold))

            LazyVGrid(columns: [
                GridItem(.flexible()), GridItem(.flexible())
            ], spacing: 6) {
                if let speed = info.maxSpeed {
                    trackInfoItem("\(speed) km/h", "H\u{00F6}chstgeschwindigkeit", "tachometer")
                }
                if let elec = info.electrified {
                    trackInfoItem(electrificationLabel(elec), "Elektrifizierung", "bolt.fill")
                }
                if let voltage = info.voltage {
                    trackInfoItem("\(voltage) V", "Spannung", "bolt")
                }
                if let tracks = info.tracks {
                    trackInfoItem("\(tracks) Gleise", "Anzahl Gleise", "tram.fill")
                }
            }
        }
    }

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Bauwerke entlang der Strecke")
                .font(.subheadline.weight(.bold))

            VStack(spacing: 0) {
                ForEach(Array(osmData.features.enumerated()), id: \.element.id) { index, feature in
                    featureRow(feature)
                    if index < osmData.features.count - 1 {
                        Divider()
                    }
                }
            }
        }
    }

    private func featureRow(_ feature: RailFeature) -> some View {
        HStack(spacing: 12) {
            Image(systemName: featureIcon(feature.type))
                .font(.title3)
                .foregroundStyle(.primary)
                .frame(width: 24)

            Text(feature.name)
                .font(.subheadline)

            Spacer()

            Text(distanceText(feature.distanceKm))
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(.vertical, 8)
    }

    private func trackInfoItem(_ value: String, _ label: String, _ icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 16)
            VStack(alignment: .leading, spacing: 0) {
                Text(value)
                    .font(.subheadline.weight(.medium))
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func featureIcon(_ type: RailFeatureType) -> String {
        switch type {
        case .tunnel: return "mountain.2.fill"
        case .bridge: return "building.columns.fill"
        case .station: return "tram.fill"
        case .halt: return "tram"
        }
    }

    private func distanceText(_ km: Double) -> String {
        if km < 1 {
            return "\(Int(km * 1000)) m"
        }
        return String(format: "%.1f km", km)
    }

    private func electrificationLabel(_ elec: String) -> String {
        switch elec {
        case "contact_line": return "Oberleitung"
        case "third_rail": return "Stromschiene"
        case "no": return "Nicht elektrifiziert"
        default: return elec
        }
    }
}

#Preview {
    OSMCard(osmData: sampleOsmTrackData)
        .padding()
}
