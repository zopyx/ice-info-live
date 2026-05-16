import SwiftUI

struct MainTabView: View {
    @Environment(\.dbTheme) var theme
    @Bindable var viewModel: AppViewModel
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(viewModel: viewModel)
                .tabItem {
                    Label(String(localized: "tab_status"), systemImage: "train.side.front.car")
                }
                .tag(0)

            StopsView(viewModel: viewModel)
                .tabItem {
                    Label(String(localized: "tab_stops"), systemImage: "list.bullet")
                }
                .tag(1)

            MapView(viewModel: viewModel)
                .tabItem {
                    Label(String(localized: "tab_map"), systemImage: "map")
                }
                .tag(2)

            ServiceView()
                .tabItem {
                    Label(String(localized: "tab_service"), systemImage: "wrench.fill")
                }
                .tag(3)

            ConnectionsView(viewModel: viewModel)
                .tabItem {
                    Label(String(localized: "tab_connections"), systemImage: "arrow.triangle.2.circlepath")
                }
                .tag(4)
        }
        .tint(theme.primary)
    }
}
