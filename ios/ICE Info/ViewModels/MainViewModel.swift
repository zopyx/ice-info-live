import Foundation
import SystemConfiguration.CaptiveNetwork

@MainActor @Observable
final class MainViewModel {
    var trainStatus = TrainStatus.disconnected
    var pois: [PoiItem] = []
    var connections: [ConnectingTrain] = []
    var departures: [Departure] = []
    var isMockMode = false
    var demoSpeed = 114
    var reducedMotion = false
    var showDemoSpeed = true
    var isChecking = false
    var isWIFIonICE = false
    var appTheme: AppTheme = .system

    private var pollingTask: Task<Void, Never>? = nil
    private var wifiCheckTask: Task<Void, Never>? = nil

    init() {
        loadSettings()
        if isMockMode {
            trainStatus = sampleTrainStatus
            trainStatus.isConnected = true
            trainStatus.targetStopEva = SettingsManager.shared.targetStopEva
            connections = sampleConnections
            departures = sampleDepartures
            pois = samplePois
        }
    }

    func startPolling() {
        pollingTask?.cancel()
        pollingTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self else { break }
                if !isMockMode {
                    let status = await TrainRepository.shared.fetchTrainStatus()
                    let updatedStatus = status.withTargetStop(SettingsManager.shared.targetStopEva)
                    trainStatus = updatedStatus
                    pois = await TrainRepository.shared.fetchPois(
                        lat: status.latitude, lon: status.longitude
                    )
                    let boardStop = relevantBoardStop(from: updatedStatus)
                    connections = await TrainRepository.shared.fetchConnections(
                        evaNr: boardStop?.evaNr ?? status.nextStopEva,
                        ourArrivalMs: boardStop?.effectiveArrivalMs ?? 0
                    )
                    if let stop = boardStop {
                        departures = await DepartureBoardRepository.shared.fetchDepartures(
                            evaNr: stop.evaNr, arrivalMs: stop.effectiveArrivalMs
                        )
                    } else {
                        departures = []
                    }
                }
                try? await Task.sleep(for: .seconds(3))
            }
        }
    }

    func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
    }

    func startWifiCheck() {
        wifiCheckTask?.cancel()
        wifiCheckTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self else { break }
                isWIFIonICE = false
                if let interfaces = CNCopySupportedInterfaces() as? [String] {
                    for interface in interfaces {
                        guard let info = CNCopyCurrentNetworkInfo(interface as CFString) as? [String: Any],
                              let ssid = info[kCNNetworkInfoKeySSID as String] as? String else { continue }
                        if ssid == "WIFIonICE" {
                            isWIFIonICE = true
                            break
                        }
                    }
                }
                try? await Task.sleep(for: .seconds(5))
            }
        }
    }

    func stopWifiCheck() {
        wifiCheckTask?.cancel()
        wifiCheckTask = nil
    }

    func setTargetStop(_ eva: String?) {
        SettingsManager.shared.targetStopEva = eva
        trainStatus = trainStatus.withTargetStop(eva)

        Task { [weak self] in
            guard let self else { return }
            let status = trainStatus
            let boardStop = relevantBoardStop(from: status)
            connections = await TrainRepository.shared.fetchConnections(
                evaNr: boardStop?.evaNr ?? status.nextStopEva,
                ourArrivalMs: boardStop?.effectiveArrivalMs ?? 0
            )
            if let stop = boardStop {
                departures = await DepartureBoardRepository.shared.fetchDepartures(
                    evaNr: stop.evaNr, arrivalMs: stop.effectiveArrivalMs
                )
            } else {
                departures = []
            }
        }
    }

    func setMockMode(_ enabled: Bool) {
        isMockMode = enabled
        SettingsManager.shared.isMockMode = enabled
        if enabled {
            stopPolling()
            trainStatus = sampleTrainStatus
            trainStatus.isConnected = true
            trainStatus.speed = demoSpeed
            trainStatus.targetStopEva = SettingsManager.shared.targetStopEva
            connections = sampleConnections
            departures = sampleDepartures
            pois = samplePois
        } else {
            trainStatus.isConnected = false
            trainStatus.targetStopEva = SettingsManager.shared.targetStopEva
            connections = []
            departures = []
            pois = []
            startPolling()
        }
    }

    func setDemoSpeed(_ speed: Int) {
        demoSpeed = speed
        SettingsManager.shared.demoSpeed = speed
        if isMockMode {
            trainStatus = trainStatus.withSpeed(speed)
        }
    }

    func setReducedMotion(_ enabled: Bool) {
        reducedMotion = enabled
        SettingsManager.shared.reducedMotion = enabled
    }

    func setTheme(_ theme: AppTheme) {
        appTheme = theme
        SettingsManager.shared.appTheme = theme.rawValue
    }

    func retryConnection() {
        isMockMode = false
        SettingsManager.shared.isMockMode = false
        isChecking = true
        Task { [weak self] in
            guard let self else { return }
            let status = await TrainRepository.shared.fetchTrainStatus()
            trainStatus = status
            pois = await TrainRepository.shared.fetchPois(lat: status.latitude, lon: status.longitude)
            isChecking = false
            if status.isConnected {
                startPolling()
            }
        }
    }

    private func relevantBoardStop(from status: TrainStatus) -> TrainStop? {
        let targetEva = status.targetStopEva
        if let eva = targetEva, let target = status.stops.first(where: { $0.evaNr == eva && !$0.passed }) {
            return target
        }
        return status.stops.first(where: { !$0.passed })
    }

    private func loadSettings() {
        let settings = SettingsManager.shared
        isMockMode = settings.isMockMode
        demoSpeed = settings.demoSpeed
        reducedMotion = settings.reducedMotion
        showDemoSpeed = settings.showDemoSpeed
        appTheme = AppTheme(rawValue: settings.appTheme) ?? .system
    }
}

extension TrainStatus {
    func withTargetStop(_ eva: String?) -> TrainStatus {
        var copy = self
        copy.targetStopEva = eva
        return copy
    }

    func withSpeed(_ speed: Int) -> TrainStatus {
        var copy = self
        copy.speed = speed
        return copy
    }
}

