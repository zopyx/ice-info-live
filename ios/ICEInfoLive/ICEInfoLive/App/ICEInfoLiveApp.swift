import SwiftUI

@main
struct ICEInfoLiveApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var viewModel = AppViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .iceInfoTheme(viewModel.settings.appTheme)
                .onAppear {
                    viewModel.wifiDetection.startMonitoring()
                    if !viewModel.settings.isMockMode {
                        viewModel.startPolling()
                    }
                }
                .onChange(of: viewModel.settings.appTheme) { _, _ in
                    // Theme change triggers recomposition via environment
                }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Firebase or other SDK initialization would go here
        return true
    }
}

struct ContentView: View {
    @Environment(\.dbTheme) var theme
    @Bindable var viewModel: AppViewModel
    @State private var showSettings = false
    @State private var showInfo = false

    var body: some View {
        Group {
            if viewModel.wifiDetection.isOnTrainNetwork || viewModel.settings.isMockMode || viewModel.trainStatus != nil {
                mainContent
            } else if viewModel.wifiDetection.isChecking {
                ProgressView(String(localized: "checking_connection"))
                    .scaleEffect(1.5)
            } else {
                NoWifiView(viewModel: viewModel)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $showInfo) {
            InfoSheet()
        }
        .fullScreenCover(isPresented: .init(
            get: { !viewModel.settings.onboardingShown },
            set: { if $0 == false { viewModel.settings.onboardingShown = true } }
        )) {
            OnboardingSheet(viewModel: viewModel)
        }
    }

    private var mainContent: some View {
        NavigationStack {
            MainTabView(viewModel: viewModel)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("ICE Info Live")
                            .font(.headline)
                            .foregroundColor(theme.textPrimary)
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        HStack(spacing: 12) {
                            Button {
                                viewModel.toggleLiveActivity()
                            } label: {
                                Image(systemName: viewModel.settings.isLiveActivityEnabled ? "bell.badge.fill" : "bell")
                                    .foregroundColor(viewModel.settings.isLiveActivityEnabled ? theme.primary : theme.textSecondary)
                            }

                            Menu {
                                Button {
                                    showSettings = true
                                } label: {
                                    Label(String(localized: "settings_title"), systemImage: "gear")
                                }

                                Button {
                                    showInfo = true
                                } label: {
                                    Label(String(localized: "info_title"), systemImage: "info.circle")
                                }

                                if viewModel.settings.isMockMode {
                                    Button {
                                        viewModel.toggleMockMode()
                                    } label: {
                                        Label(String(localized: "exit_demo"), systemImage: "xmark.circle")
                                    }
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle")
                                    .foregroundColor(theme.textPrimary)
                            }
                        }
                    }
                }
        }
    }
}
