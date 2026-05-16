import SwiftUI

struct NoWifiView: View {
    @Environment(\.dbTheme) var theme
    @Bindable var viewModel: AppViewModel

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "wifi.slash")
                .font(.system(size: 64))
                .foregroundColor(theme.textSecondary)

            Text(String(localized: "no_wifi_title"))
                .font(.title2.bold())
                .foregroundColor(theme.textPrimary)

            Text(String(localized: "no_wifi_message"))
                .font(.body)
                .foregroundColor(theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            VStack(spacing: 12) {
                Button {
                    Task {
                        await viewModel.fetchData()
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text(String(localized: "retry"))
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(theme.primary)
                    .cornerRadius(12)
                }

                Button {
                    viewModel.toggleMockMode()
                } label: {
                    HStack {
                        Image(systemName: "play.circle")
                        Text(String(localized: "try_demo"))
                    }
                    .font(.headline)
                    .foregroundColor(theme.primary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(theme.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(theme.primary, lineWidth: 1)
                    )
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal, 32)

            Spacer()
        }
        .background(theme.background.ignoresSafeArea())
    }
}
