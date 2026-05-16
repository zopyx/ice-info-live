import SwiftUI

struct StopsView: View {
    let status: TrainStatus
    let pois: [PoiItem]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if !status.stops.isEmpty {
                    AppCard {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Halte")
                                .font(.subheadline.weight(.bold))
                                .padding(.bottom, 12)
                                .padding(.horizontal, 16)
                                .padding(.top, 16)

                            VStack(spacing: 0) {
                                ForEach(Array(status.stops.enumerated()), id: \.element.id) { index, stop in
                                    TimelineStopRow(
                                        stop: stop,
                                        isFirst: index == 0,
                                        isLast: index == status.stops.count - 1
                                    )
                                    .padding(.horizontal, 16)
                                }
                            }
                            .padding(.bottom, 16)
                        }
                    }
                } else {
                    Spacer()
                    Text("Keine Halte verf\u{00FC}gbar")
                        .foregroundStyle(.secondary)
                    Spacer()
                }

                PoiCard(pois: pois)

                Spacer().frame(height: 96)
            }
            .padding(16)
        }
        .background(Color(.systemBackground))
    }
}
