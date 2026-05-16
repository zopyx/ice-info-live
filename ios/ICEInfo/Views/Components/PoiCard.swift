import SwiftUI

struct PoiCard: View {
    let pois: [PoiItem]

    var body: some View {
        if pois.isEmpty { EmptyView() }

        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Points of Interest")
                    .font(.subheadline.weight(.bold))

                VStack(spacing: 0) {
                    ForEach(Array(pois.enumerated()), id: \.element.id) { index, poi in
                        PoiRow(poi: poi)
                        if index < pois.count - 1 {
                            Divider().padding(.horizontal, 16)
                        }
                    }
                }
            }
            .padding(16)
        }
    }
}

private struct PoiRow: View {
    let poi: PoiItem

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: iconName(for: poi.type))
                .font(.title3)
                .foregroundStyle(.primary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(poi.type.lowercased().capitalized)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(poi.name)
                    .font(.body.weight(.medium))
                if !poi.description.isEmpty {
                    Text(poi.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(distanceText)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            let query = poi.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            if let url = URL(string: "https://www.google.com/search?q=\(query)") {
                UIApplication.shared.open(url)
            }
        }
    }

    private var distanceText: String {
        if poi.distance < 1000 {
            return "\(poi.distance) m"
        }
        return String(format: "%.1f km", Double(poi.distance) / 1000.0)
    }

    private func iconName(for type: String) -> String {
        switch type {
        case "CITY": return "building.2.fill"
        case "RIVER": return "drop.fill"
        case "MOUNTAIN": return "mountain.2.fill"
        case "LAKE": return "drop.fill"
        case "MONUMENT": return "building.columns.fill"
        case "FOREST": return "tree.fill"
        default: return "mappin"
        }
    }
}
