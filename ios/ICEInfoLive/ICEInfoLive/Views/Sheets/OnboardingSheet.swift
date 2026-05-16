import SwiftUI

struct OnboardingSheet: View {
    @Environment(\.dbTheme) var theme
    @Bindable var viewModel: AppViewModel
    @State private var currentPage = 0

    let pages = [
    OnboardingPage(
            icon: "train.side.front.car",
            titleKey: "onboard_welcome_title",
            descriptionKey: "onboard_welcome_desc"
        ),
        OnboardingPage(
            icon: "wifi",
            titleKey: "onboard_wifi_title",
            descriptionKey: "onboard_wifi_desc"
        ),
        OnboardingPage(
            icon: "map",
            titleKey: "onboard_features_title",
            descriptionKey: "onboard_features_desc"
        ),
        OnboardingPage(
            icon: "bell.badge",
            titleKey: "onboard_notifications_title",
            descriptionKey: "onboard_notifications_desc"
        )
    ]

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    OnboardingPageView(page: page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .frame(height: 400)

            Button {
                viewModel.settings.onboardingShown = true
            } label: {
                Text(currentPage == pages.count - 1 ? String(localized: "get_started") : String(localized: "next"))
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(theme.primary)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 32)

            Spacer()
        }
        .background(theme.background.ignoresSafeArea())
    }
}

struct OnboardingPage: Identifiable {
    let id = UUID()
    let icon: String
    let titleKey: String
    let descriptionKey: String
}

struct OnboardingPageView: View {
    @Environment(\.dbTheme) var theme
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: page.icon)
                .font(.system(size: 80))
                .foregroundColor(theme.primary)

            Text(LocalizedStringKey(page.titleKey))
                .font(.title2.bold())
                .foregroundColor(theme.textPrimary)
                .multilineTextAlignment(.center)

            Text(LocalizedStringKey(page.descriptionKey))
                .font(.body)
                .foregroundColor(theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }
}
