import SwiftUI

struct TrainHeader: View {
    let trainStatus: TrainStatus
    let reducedMotion: Bool

    @State private var trackOffset: CGFloat = 0
    @Environment(\.dbTheme) var theme

    var body: some View {
        ZStack {
            // Background track animation
            if !reducedMotion {
                HStack(spacing: 0) {
                    ForEach(0..<5) { _ in
                        Image(systemName: "train.side.front.car")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(theme.divider)
                            .opacity(0.3)
                    }
                }
                .offset(x: trackOffset)
                .onAppear {
                    startAnimation()
                }
            }

            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "train.side.front.car")
                        .font(.system(size: 48))
                        .foregroundColor(theme.primary)

                    Spacer()

                    VStack(alignment: .trailing) {
                        Text("\(trainStatus.trainType) \(trainStatus.trainNumber)")
                            .font(.title2.bold())
                            .foregroundColor(theme.textPrimary)
                        Text(trainStatus.tzn)
                            .font(.subheadline)
                            .foregroundColor(theme.textSecondary)
                    }
                }

                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text("\(trainStatus.speed)")
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundColor(theme.textPrimary)
                    Text("km/h")
                        .font(.title3)
                        .foregroundColor(theme.textSecondary)
                }
            }
            .padding()
        }
        .frame(height: 180)
        .background(theme.surface)
        .cornerRadius(20)
    }

    private func startAnimation() {
        guard !reducedMotion else { return }
        let speedFactor = max(1, Double(trainStatus.speed)) / 100.0
        withAnimation(.linear(duration: 2.0 / speedFactor).repeatForever(autoreverses: false)) {
            trackOffset = -100
        }
    }
}
