import SwiftUI

struct ServiceView: View {
    @Environment(\.dbTheme) var theme

    var body: some View {
        VStack {
            ContentUnavailableView(
                String(localized: "service_title"),
                systemImage: "wrench.fill",
                description: Text(String(localized: "service_wip"))
            )
        }
        .background(theme.background.ignoresSafeArea())
    }
}
