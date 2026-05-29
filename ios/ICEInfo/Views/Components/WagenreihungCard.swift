import SwiftUI

struct WagenreihungCard: View {
    let coaches: [Coach]
    let selectedCoach: Int?
    var onCoachTap: ((Int?) -> Void)? = nil

    private let coachWidth: CGFloat = 44
    private let coachHeight: CGFloat = 120

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 6) {
                ScrollView(.horizontal, showsIndicators: false) {
                    VStack(spacing: 0) {
                        sectorLabels
                        trainComposition
                        coachNumbers
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }

                legendChips
            }
        }
    }

    private var sectorLabels: some View {
        let uniqueSectors = coaches
            .map(\.sector)
            .filter { !$0.isEmpty }
            .removingDuplicates()
        return HStack(spacing: 0) {
            ForEach(uniqueSectors, id: \.self) { sector in
                Text(sector)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: coachWidth * CGFloat(sectorCoachCount(sector)))
            }
        }
    }

    private var trainComposition: some View {
        HStack(spacing: 0) {
            ForEach(coaches, id: \.coachNumber) { coach in
                CoachView(
                    coach: coach,
                    isSelected: selectedCoach == coach.coachNumber,
                    width: coachWidth,
                    height: coachHeight
                )
                .onTapGesture {
                    onCoachTap?(selectedCoach == coach.coachNumber ? nil : coach.coachNumber)
                }
            }
        }
    }

    private var coachNumbers: some View {
        HStack(spacing: 0) {
            ForEach(coaches, id: \.coachNumber) { coach in
                Text("\(coach.coachNumber)")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(selectedCoach == coach.coachNumber ? Color(red: 0.925, green: 0, blue: 0.086) : .primary)
                    .frame(width: coachWidth)
            }
        }
    }

    private var legendChips: some View {
        let items = buildLegendItems()
        return HStack(spacing: 8) {
            ForEach(items, id: \.0) { label, color in
                HStack(spacing: 4) {
                    Circle()
                        .fill(color)
                        .frame(width: 8, height: 8)
                    Text(label)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
    }

    private func buildLegendItems() -> [(String, Color)] {
        var items: [(String, Color)] = []
        if coaches.contains(where: \.hasFirstClass) {
            items.append(("1. Klasse", firstClassFill))
        }
        if coaches.contains(where: \.hasSecondClass) {
            items.append(("2. Klasse", secondClassFill))
        }
        if coaches.contains(where: { $0.vehicleCategory.contains("DINING") || $0.vehicleCategory.contains("HALFDINING") }) {
            items.append(("Bordrestaurant", diningFill))
        }
        if coaches.contains(where: { $0.vehicleCategory.contains("CONTROLCAR") }) {
            items.append(("Steuerwagen", controlCarFill))
        }
        return items
    }

    private var firstClassFill: Color { Color(.systemOrange) }
    private var secondClassFill: Color { Color(.systemBlue) }
    private var diningFill: Color { Color(.systemTeal) }
    private var controlCarFill: Color { Color(.systemPurple) }

    private func sectorCoachCount(_ sector: String) -> Int {
        coaches.filter { $0.sector == sector }.count
    }
}

private struct CoachView: View {
    let coach: Coach
    let isSelected: Bool
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                Canvas { context, size in
                    let rect = CGRect(origin: .zero, size: size)
                    let fill = coachFillColor
                    let isControlCar = coach.vehicleCategory.contains("CONTROLCAR")
                    let cornerSize = CGSize(width: 6, height: 6)

                    if isControlCar {
                        let noseRect = CGRect(x: rect.minX, y: rect.minY + size.height * 0.05,
                                               width: rect.width, height: size.height * 0.95)
                        let path = Path { p in
                            let midX = noseRect.midX
                            let noseHeight: CGFloat = 8
                            p.move(to: CGPoint(x: midX, y: noseRect.minY - noseHeight))
                            p.addLine(to: CGPoint(x: noseRect.minX + 6, y: noseRect.minY))
                            p.addLine(to: CGPoint(x: noseRect.minX, y: noseRect.minY))
                            p.addLine(to: CGPoint(x: noseRect.minX, y: noseRect.maxY))
                            p.addLine(to: CGPoint(x: noseRect.maxX, y: noseRect.maxY))
                            p.addLine(to: CGPoint(x: noseRect.maxX, y: noseRect.minY))
                            p.addLine(to: CGPoint(x: noseRect.maxX - 6, y: noseRect.minY))
                            p.closeSubpath()
                        }
                        context.fill(path, with: .color(fill))
                    } else {
                        let rrect = RoundedRectangle(cornerSize: cornerSize).path(in: rect)
                        context.fill(rrect, with: .color(fill))
                    }

                    if isSelected {
                        let strokeRect: CGRect
                        if coach.vehicleCategory.contains("CONTROLCAR") {
                            strokeRect = CGRect(x: rect.minX, y: rect.minY + size.height * 0.05,
                                                width: rect.width, height: size.height * 0.95)
                        } else {
                            strokeRect = rect
                        }
                        let strokePath = RoundedRectangle(cornerSize: cornerSize).path(in: strokeRect)
                        context.stroke(strokePath, with: .color(Color(red: 0.925, green: 0, blue: 0.086)), lineWidth: 3)
                    }
                }

                amenityIconsOverlay
            }
            .frame(width: width, height: height)
        }
    }

    @ViewBuilder
    private var amenityIconsOverlay: some View {
        if !coach.amenities.isEmpty {
            VStack(spacing: 2) {
                Spacer()
                HStack(spacing: 0) {
                    Spacer()
                    ForEach(Array(coach.amenities.sorted()), id: \.self) { amenity in
                        Image(systemName: amenityIcon(amenity))
                            .font(.system(size: 8))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
            }
            .padding(.bottom, 6)
        }
    }

    private var coachFillColor: Color {
        if coach.vehicleCategory.contains("CONTROLCAR") {
            return Color(.systemPurple).opacity(0.35)
        }
        if coach.vehicleCategory.contains("DINING") || coach.vehicleCategory.contains("HALFDINING") {
            return Color(.systemTeal).opacity(0.35)
        }
        if coach.hasFirstClass {
            return Color(.systemOrange).opacity(0.35)
        }
        return Color(.systemBlue).opacity(0.3)
    }

    private func amenityIcon(_ key: String) -> String {
        switch key {
        case "ZONE_QUIET": return "speaker.slash.fill"
        case "ZONE_FAMILY": return "figure.2.and.child.holdinghands"
        case "BIKE_SPACE": return "bicycle"
        case "WHEELCHAIR_SPACE": return "figure.roll"
        case "SEATS_BAHN_COMFORT": return "star.fill"
        case "CABIN_INFANT": return "figure.and.child.holdinghands"
        default: return "circle.fill"
        }
    }
}

extension Sequence where Element: Hashable {
    fileprivate func removingDuplicates() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}

#Preview {
    WagenreihungCard(coaches: sampleCoaches, selectedCoach: 24)
        .padding()
}
