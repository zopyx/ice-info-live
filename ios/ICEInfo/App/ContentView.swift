import SwiftUI

struct ContentView: View {
    @State private var viewModel = MainViewModel()
    @State private var showSettings = false
    @State private var showInfo = false
    @State private var showChangelog = false
    @State private var showDebug = false
    @State private var notificationActive = false

    var body: some View {
        ZStack(alignment: .bottom) {
            if !viewModel.trainStatus.isConnected && !viewModel.isMockMode {
                NoWifiView(
                    isChecking: viewModel.isChecking,
                    onRetry: { viewModel.retryConnection() },
                    onMockMode: { viewModel.setMockMode(true) }
                )
            } else {
                mainTabView
                bottomBar
            }
        }
        .onAppear {
            viewModel.startWifiCheck()
            if !viewModel.isMockMode {
                viewModel.startPolling()
            }
        }
        .onDisappear {
            viewModel.stopPolling()
            viewModel.stopWifiCheck()
        }
        .onChange(of: viewModel.isWIFIonICE) { _, connected in
            if connected && !viewModel.isMockMode {
                viewModel.startPolling()
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsSheet(
                appTheme: Binding(
                    get: { viewModel.appTheme },
                    set: { viewModel.setTheme($0) }
                ),
                isMockMode: Binding(
                    get: { viewModel.isMockMode },
                    set: { viewModel.setMockMode($0) }
                ),
                showDemoSpeed: $viewModel.showDemoSpeed,
                reducedMotion: $viewModel.reducedMotion,
                crashReportingEnabled: Binding(
                    get: { SettingsManager.shared.crashReportingEnabled },
                    set: { SettingsManager.shared.crashReportingEnabled = $0 }
                ),
                language: SettingsManager.shared.language,
                onLanguageChange: { SettingsManager.shared.language = $0 },
                onDebug: {
                    showSettings = false
                    showDebug = true
                },
                onDismiss: { showSettings = false }
            )
        }
        .sheet(isPresented: $showInfo) {
            InfoSheet(onDismiss: { showInfo = false })
        }
        .sheet(isPresented: $showChangelog) {
            ChangelogSheet(onDismiss: { showChangelog = false })
        }
        .sheet(isPresented: $showDebug) {
            DebugSheet(onDismiss: { showDebug = false })
        }
    }

    @State private var selectedTab: Tab = .status

    enum Tab: String {
        case status, stops, map, service, connections
    }

    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            StatusView(
                status: viewModel.trainStatus,
                isDarkTheme: viewModel.appTheme == .dark,
                isMockMode: viewModel.isMockMode,
                demoSpeed: viewModel.demoSpeed,
                showDemoSpeed: viewModel.showDemoSpeed,
                reducedMotion: viewModel.reducedMotion,
                onDemoSpeedChange: { viewModel.setDemoSpeed($0) },
                onTargetStopChange: { viewModel.setTargetStop($0) }
            )
            .tag(Tab.status)
            .tabItem { Label("Status", systemImage: "tram.fill") }

            StopsView(
                status: viewModel.trainStatus,
                pois: viewModel.pois
            )
            .tag(Tab.stops)
            .tabItem { Label("Halte", systemImage: "list.bullet") }

            TrainMapView(status: viewModel.trainStatus)
            .tag(Tab.map)
            .tabItem { Label("Karte", systemImage: "map.fill") }

            ServiceView()
            .tag(Tab.service)
            .tabItem { Label("Service", systemImage: "fork.knife") }

            ConnectionsView(
                status: viewModel.trainStatus,
                connections: viewModel.connections,
                departures: viewModel.departures
            )
            .tag(Tab.connections)
            .tabItem { Label("Anschl\u{00FC}sse", systemImage: "arrow.triangle.branch") }
        }
        .tint(Color(red: 0.925, green: 0, blue: 0.086))
    }

    private var bottomBar: some View {
        HStack {
            Button {
                notificationActive.toggle()
                if notificationActive {
                    TrainLiveActivity.startActivity(status: viewModel.trainStatus)
                } else {
                    TrainLiveActivity.stopAllActivities()
                }
            } label: {
                Image(systemName: notificationActive ? "bell.fill" : "bell")
                    .font(.body)
                    .foregroundStyle(notificationActive ? Color(red: 0.925, green: 0, blue: 0.086) : .primary)
            }
            .padding(.leading, 16)

            Spacer()

            HStack(spacing: 0) {
                tabButton(.status, icon: "tram.fill", label: "Status")
                tabButton(.stops, icon: "list.bullet", label: "Halte")
                tabButton(.map, icon: "map.fill", label: "Karte")
                tabButton(.service, icon: "fork.knife", label: "Service")
                tabButton(.connections, icon: "arrow.triangle.branch", label: "Anschl\u{00FC}sse")
            }

            Spacer()

            Button {
                showSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.body)
            }
            .padding(.trailing, 16)
        }
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }

    private func tabButton(_ tab: Tab, icon: String, label: String) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(label)
                    .font(.system(size: 10))
            }
            .foregroundStyle(selectedTab == tab ? Color(red: 0.925, green: 0, blue: 0.086) : .secondary)
            .frame(maxWidth: .infinity)
        }
    }
}
