import SwiftUI

struct NoWifiView: View {
    let isChecking: Bool
    let onRetry: () -> Void
    let onMockMode: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "wifi.slash")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)

            Text("Nicht mit WIFIonICE verbunden")
                .font(.title2.weight(.semibold))

            Text("Bitte verbinden Sie sich mit dem WLAN\n\"WIFIonICE\" im ICE.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if isChecking {
                ProgressView()
                    .padding()
            }

            Button(action: onRetry) {
                Label("Erneut versuchen", systemImage: "arrow.clockwise")
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: 280)
                    .padding(.vertical, 12)
                    .background(Color(red: 0.925, green: 0, blue: 0.086))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(isChecking)

            Button(action: onMockMode) {
                Label("Demo-Modus", systemImage: "tram.fill")
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: 280)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
    }
}
