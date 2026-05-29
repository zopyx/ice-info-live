import SwiftUI

struct ContentView: View {
    @State private var viewModel = MainViewModel()
    @State private var showSettings = false
    @State private var showInfo = false
    @State private var showChangelog = false
    @State private var showDebug = false
    @State private var notificationActive = false
    @State private var showJourneys = false

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

            // Journeys overlay
            if showJourneys {
                JourneysScreenView(
                    journeys: viewModel.journeys,
                    onDeleteJourney: { viewModel.deleteJourney(id: $0) },
                    isConnected: viewModel.trainStatus.isConnected,
                    isRecording: viewModel.isRecording,
                    liveRecording: viewModel.liveRecording,
                    onStartRecording: { viewModel.requestRecording() }
                )
                .transition(.move(edge: .leading))
                .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showJourneys)
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
        .sheet(isPresented: $viewModel.showRecordingConsent) {
            RecordingConsentDialog(
                trainStatus: viewModel.trainStatus,
                onRecord: { viewModel.startRecording(recordGps: $0) },
                onDecline: { viewModel.declineRecording() }
            )
        }
    }

    @State private var selectedTab: Tab = .status

    enum Tab: String {
        case status, stops, map, menu, service, connections
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
                weather: viewModel.weather,
                coaches: viewModel.coaches,
                selectedCoach: viewModel.selectedCoach,
                onDemoSpeedChange: { viewModel.setDemoSpeed($0) },
                onTargetStopChange: { viewModel.setTargetStop($0) },
                onCoachChange: { viewModel.setCoach($0) }
            )
            .tag(Tab.status)
            .tabItem { Label("Status", systemImage: "tram.fill") }

            StopsView(
                status: viewModel.trainStatus,
                pois: viewModel.pois,
                osmData: viewModel.osmData
            )
            .tag(Tab.stops)
            .tabItem { Label("Halte", systemImage: "list.bullet") }

            MenuScreenView(
                categories: viewModel.menuCategories,
                isLoading: viewModel.isMenuLoading,
                onLoad: { viewModel.fetchMenuIfNeeded() },
                onRefresh: { viewModel.refreshMenu() }
            )
            .tag(Tab.menu)
            .tabItem { Label("Speisen", systemImage: "fork.knife") }

            ServiceScreenView(
                trainStatus: viewModel.trainStatus,
                serviceStation: viewModel.serviceStation,
                searchResults: viewModel.stationSearchResults,
                onSearchQueryChange: { viewModel.searchStations(query: $0) },
                onStationSelect: { viewModel.selectServiceStation($0) },
                onLoadTrainStation: { viewModel.loadServiceStationFromTrain(evaNr: $0, name: $1) }
            )
            .tag(Tab.service)
            .tabItem { Label("Service", systemImage: "building.columns.fill") }

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
                showJourneys.toggle()
            } label: {
                Image(systemName: showJourneys ? "clock.fill" : "clock")
                    .font(.body)
                    .foregroundStyle(showJourneys ? Color(red: 0.925, green: 0, blue: 0.086) : .primary)
            }
            .padding(.leading, 16)

            Spacer()

            HStack(spacing: 0) {
                tabButton(.status, icon: "tram.fill", label: "Status")
                tabButton(.stops, icon: "list.bullet", label: "Halte")
                tabButton(.menu, icon: "fork.knife", label: "Speisen")
                tabButton(.service, icon: "building.columns.fill", label: "Service")
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
