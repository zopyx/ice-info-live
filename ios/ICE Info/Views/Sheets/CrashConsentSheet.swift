import SwiftUI

struct CrashConsentSheet: View {
    var onAccept: () -> Void
    var onDecline: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.orange)

            Text("Crash-Berichte")
                .font(.title2.weight(.bold))

            Text("ICE Info kann anonyme Absturzberichte senden, um die App zu verbessern. Es werden keine pers\u{00F6}nlichen Daten \u{00FC}bermittelt.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()

            VStack(spacing: 12) {
                Button(action: onAccept) {
                    Text("Teilen")
                        .font(.body.weight(.semibold))
                        .frame(maxWidth: 280)
                        .padding(.vertical, 12)
                        .background(Color(red: 0.925, green: 0, blue: 0.086))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button(action: onDecline) {
                    Text("Nicht teilen")
                        .font(.body.weight(.semibold))
                        .frame(maxWidth: 280)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}
