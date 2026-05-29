import SwiftUI

struct RecordingConsentDialog: View {
    let trainStatus: TrainStatus
    let onRecord: (Bool) -> Void
    let onDecline: () -> Void

    @State private var recordGps: Bool = true

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 16) {
                headerView
                routeInfoView
                whatIsSaved
                gpsToggle
            }
            .padding(24)

            Divider()

            buttonsView
                .padding(16)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.15), radius: 24, y: 8)
        .padding(24)
    }

    private var headerView: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.925, green: 0, blue: 0.086).opacity(0.1))
                    .frame(width: 56, height: 56)
                Image(systemName: "record.circle")
                    .font(.title2)
                    .foregroundStyle(Color(red: 0.925, green: 0, blue: 0.086))
            }

            Text("Reise aufzeichnen")
                .font(.title3.weight(.bold))

            Text("Deine Reisedaten werden lokal auf dem Ger\u{00E4}t gespeichert und nicht geteilt.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var routeInfoView: some View {
        HStack(spacing: 12) {
            Text(trainStatus.trainType)
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color(red: 0.925, green: 0, blue: 0.086))
                .clipShape(RoundedRectangle(cornerRadius: 4))

            Text(trainStatus.trainNumber)
                .font(.subheadline.weight(.bold))

            Text("\u{00B7}")

            HStack(spacing: 0) {
                Text(trainStatus.nextStop)
                    .font(.subheadline)
                    .lineLimit(1)
                Text(" \u{2192} ")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(trainStatus.destination)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }

    private var whatIsSaved: some View {
        VStack(spacing: 8) {
            Text("Gespeicherte Daten")
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
                savedDataItem("clock", "Abfahrt & Ankunft")
                savedDataItem("hourglass", "Fahrtdauer")
                savedDataItem("speedometer", "H\u{00F6}chstgeschwindigkeit")
                savedDataItem("gauge.with.dots.needle.33percent", "Durchschnittsgeschw.")
                savedDataItem("map", "Gefahrene Strecke")
                savedDataItem("bell", "P\u{00FC}nktlichkeit")
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func savedDataItem(_ icon: String, _ label: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(label)
                .font(.caption)
                .foregroundStyle(.primary)
            Spacer()
        }
    }

    private var gpsToggle: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.caption)
                        .foregroundStyle(.blue)
                    Text("GPS-Track aufzeichnen")
                        .font(.subheadline.weight(.medium))
                }
                Text("Erm\u{00F6}glicht eine genaue Streckenaufzeichnung inkl. GPX-Export. Die GPS-Daten verlassen dein Ger\u{00E4}t nicht.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 12)
            Toggle("", isOn: $recordGps)
                .labelsHidden()
        }
    }

    private var buttonsView: some View {
        HStack(spacing: 12) {
            Button(action: onDecline) {
                Text("Ablehnen")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Button(action: { onRecord(recordGps) }) {
                Text("Aufzeichnen")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(red: 0.925, green: 0, blue: 0.086))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

#Preview {
    RecordingConsentDialog(
        trainStatus: sampleTrainStatus,
        onRecord: { _ in },
        onDecline: {}
    )
    .background(Color.black.opacity(0.3))
}
