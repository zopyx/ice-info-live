import Foundation
import OSLog
import UIKit

@Observable
@MainActor
class AppViewModel {
    private let logger = Logger(subsystem: "com.nruge.iceinfo", category: "AppViewModel")
    private let trainRepository = TrainRepository()
    private let departureRepository = DepartureRepository()
    private let liveActivityManager = LiveActivityManager()
    private let widgetUpdater = WidgetUpdater()

    var settings = SettingsService()
    let wifiDetection = WiFiDetectionService()

    var trainStatus: TrainStatus?
    var pois: [PoiItem] = []
    var connections: [ConnectingTrain] = []
    var departures: [Departure] = []
    var isLoading = false
    var errorMessage: String?

    private var pollingTask: Task<Void, Never>?
    private var connectionTask: Task<Void, Never>?
    private var departureTask: Task<Void, Never>?

    // MARK: - Lifecycle

    init() {
        if settings.isMockMode {
            loadMockData()
        }
    }

    // MARK: - Polling

    func startPolling() {
        guard pollingTask == nil else { return }

        pollingTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                await self.fetchData()
                try? await Task.sleep(nanoseconds: 3_000_000_000)
            }
        }
    }

    func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
    }

    func fetchData() async {
        guard !settings.isMockMode else {
            updateMockData()
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let status = try await trainRepository.fetchTrainStatus()
            var mutableStatus = status

            // Apply target stop from settings
            mutableStatus.targetStopEva = settings.targetStopEva

            self.trainStatus = mutableStatus
            self.errorMessage = nil

            // Fetch POIs in background
            Task {
                let pois = await trainRepository.fetchPois(
                    latitude: mutableStatus.latitude,
                    longitude: mutableStatus.longitude
                )
                await MainActor.run {
                    self.pois = pois
                }
            }

            // Fetch connections for next/target stop
            fetchConnectionsAndDepartures(for: mutableStatus)

            // Update Live Activity
            updateLiveActivity(status: mutableStatus)

            // Update widget
            await widgetUpdater.update(trainStatus: mutableStatus)

        } catch {
            logger.error("Failed to fetch train status: \(error.localizedDescription)")
            errorMessage = String(localized: "error_fetch_data")
        }
    }

    private func fetchConnectionsAndDepartures(for status: TrainStatus) {
        let evaNr = settings.targetStopEva ?? status.nextStop?.station.evaNr
        guard let evaNr else { return }

        connectionTask?.cancel()
        connectionTask = Task { [weak self] in
            guard let self else { return }
            let connections = await trainRepository.fetchConnections(evaNr: evaNr)
            await MainActor.run {
                self.connections = connections
            }
        }

        departureTask?.cancel()
        departureTask = Task { [weak self] in
            guard let self else { return }
            let departures = await departureRepository.fetchDepartures(evaNr: evaNr)
            await MainActor.run {
                self.departures = departures
            }
        }
    }

    // MARK: - Mock Mode

    func toggleMockMode() {
        settings.isMockMode.toggle()
        if settings.isMockMode {
            loadMockData()
            stopPolling()
        } else {
            trainStatus = nil
            pois = []
            connections = []
            departures = []
            startPolling()
        }
    }

    private func loadMockData() {
        var mock = DemoData.trainStatus
        mock.targetStopEva = settings.targetStopEva
        mock = applyDemoSpeed(status: mock)
        trainStatus = mock
        pois = DemoData.pois
        connections = DemoData.connections
        departures = DemoData.departures
    }

    private func updateMockData() {
        guard var mock = trainStatus, mock.isMockMode else { return }
        mock = applyDemoSpeed(status: mock)
        trainStatus = mock
    }

    private func applyDemoSpeed(status: TrainStatus) -> TrainStatus {
        var mutable = status
        mutable.speed = settings.demoSpeed
        return mutable
    }

    // MARK: - Target Stop

    func setTargetStop(evaNr: String?) {
        settings.targetStopEva = evaNr
        guard var status = trainStatus else { return }
        status.targetStopEva = evaNr
        trainStatus = status
        fetchConnectionsAndDepartures(for: status)
    }

    // MARK: - Live Activity

    func toggleLiveActivity() {
        guard #available(iOS 16.1, *) else { return }
        settings.isLiveActivityEnabled.toggle()

        if settings.isLiveActivityEnabled, let status = trainStatus {
            liveActivityManager.startActivity(
                trainStatus: status,
                targetStop: status.stops.first { $0.station.evaNr == status.targetStopEva }
            )
        } else {
            liveActivityManager.endActivity()
        }
    }

    private func updateLiveActivity(status: TrainStatus) {
        guard #available(iOS 16.1, *), settings.isLiveActivityEnabled else { return }
        liveActivityManager.updateActivity(
            trainStatus: status,
            targetStop: status.stops.first { $0.station.evaNr == status.targetStopEva }
        )
    }

    // MARK: - Debug

    func fetchDebugData() async -> String {
        do {
            let status = try await trainRepository.fetchTrainStatus()
            return "Train: \(status.trainType) \(status.trainNumber)\nSpeed: \(status.speed) km/h\nNext: \(status.nextStop?.station.name ?? "N/A")\nDelay: +\(status.delayMinutes) min"
        } catch {
            return "Error: \(error.localizedDescription)"
        }
    }
}
