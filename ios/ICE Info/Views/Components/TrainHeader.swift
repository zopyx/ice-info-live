import SwiftUI

struct TrainHeader: View {
    let status: TrainStatus
    var reducedMotion: Bool = false

    @State private var trackOffset: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 5)

            ZStack(alignment: .topLeading) {
                if !reducedMotion {
                    TrackAnimationView(offset: $trackOffset, speed: status.speed)
                        .frame(height: 50)
                        .offset(y: -45)
                }

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Image(systemName: "tram.fill")
                                .font(.caption)
                                .foregroundStyle(.white)
                                .padding(4)
                                .background(Color(red: 0.925, green: 0, blue: 0.086))
                                .clipShape(RoundedRectangle(cornerRadius: 4))

                            Text("\(status.trainType) \(status.trainNumber)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .italic()
                                .foregroundStyle(Color(red: 0.925, green: 0, blue: 0.086))
                        }

                        Text(getIceClass(tzn: status.tzn))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text("\(status.speed) km/h")
                        .font(.title)
                        .fontWeight(.black)
                        .foregroundStyle(Color(red: 0.925, green: 0, blue: 0.086))
                }
                .padding(16)
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
                }
                .offset(y: 50)
            }
            .frame(height: 140)
            .clipped()
        }
        .onAppear {
            if !reducedMotion {
                startTrackAnimation()
            }
        }
    }

    private func startTrackAnimation() {
        withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
            trackOffset = -200
        }
    }
}

private struct TrackAnimationView: UIViewRepresentable {
    @Binding var offset: CGFloat
    let speed: Int

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.clipsToBounds = true
        let trackImage = UIImage(systemName: "minus")?
            .withTintColor(.systemGray3, renderingMode: .alwaysOriginal)
        let imageView = UIImageView(image: trackImage)
        imageView.contentMode = .scaleAspectFill
        imageView.frame = CGRect(x: 0, y: 0, width: 1000, height: 50)
        view.addSubview(imageView)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        uiView.transform = CGAffineTransform(translationX: offset, y: 0)
    }
}
