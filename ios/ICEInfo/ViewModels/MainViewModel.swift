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

    // Journey Recording
    var journeys: [SavedJourney] = []
    var showRecordingConsent = false
    var isRecording = false
    var liveRecording: LiveRecordingState? = nil

    // Menu
    var menuCategories: [MenuCategory] = []
    var isMenuLoading = false

    // Wagenreihung
    var coaches: [Coach] = []
    var selectedCoach: Int? = nil
    var seatNumber = ""

    // OSM
    var osmData = OsmTrackData()

    // Weather
    var weather: WeatherInfo? = nil

    // Station Facilities
    var serviceStation: StationInfo? = nil
    var stationSearchResults: [StationSearchResult] = []

    // Internal state
    private var pollingTask: Task<Void, Never>? = nil
    private var wifiCheckTask: Task<Void, Never>? = nil
    private var lastConnectionsFetchMs: Int64 = 0
    private var lastWeatherEva = ""
    private var lastWeatherFetchMs: Int64 = 0
    private var lastOsmLat = 0.0
    private var lastOsmLon = 0.0
    private var menuFetchedForTrain: String? = nil
    private var wagenreihungFetchedForTrain: String? = nil
    private var wasConnected = false
    private var lastConnectedMs: Int64 = 0
    private let reconnectingWindowMs: Int64 = 30_000

    // Active recording state
    private var activeRecording: ActiveRecording? = nil

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd.MM.yyyy"
        return f
    }()

    private class ActiveRecording {
        let id: String
        let trainType: String
        let trainNumber: String
        let originStation: String
        let destinationEvaNr: String
        let destinationStation: String
        let date: String
        let departureTime: String
        let originDistanceFromStart: Int
        let destinationDistanceFromStart: Int
        let stopsCount: Int
        let recordGps: Bool
        let startMs: Int64
        var speedSamples: [Int]
        var trackPoints: [TrackPoint]
        var topSpeedKmh: Int

        init(trainType: String, trainNumber: String, originStation: String,
             destinationEvaNr: String, destinationStation: String, date: String,
             departureTime: String, originDistanceFromStart: Int,
             destinationDistanceFromStart: Int, stopsCount: Int, recordGps: Bool) {
            self.id = UUID().uuidString
            self.trainType = trainType
            self.trainNumber = trainNumber
            self.originStation = originStation
            self.destinationEvaNr = destinationEvaNr
            self.destinationStation = destinationStation
            self.date = date
            self.departureTime = departureTime
            self.originDistanceFromStart = originDistanceFromStart
            self.destinationDistanceFromStart = destinationDistanceFromStart
            self.stopsCount = stopsCount
            self.recordGps = recordGps
            self.startMs = Int64(Date().timeIntervalSince1970 * 1000)
            self.speedSamples = []
            self.trackPoints = []
            self.topSpeedKmh = 0
        }
    }

    init() {
        loadSettings()

        Task {
            journeys = await JourneyRepository.shared.loadJourneys()
        }

        if isMockMode {
            trainStatus = sampleTrainStatus
            trainStatus.isConnected = true
            trainStatus.targetStopEva = SettingsManager.shared.targetStopEva
            connections = sampleConnections
            departures = sampleDepartures
            pois = samplePois
            weather = sampleWeather
            osmData = sampleOsmTrackData
            coaches = sampleCoaches
            menuCategories = sampleMenuCategories
            menuFetchedForTrain = "\(sampleTrainStatus.trainType)\(sampleTrainStatus.trainNumber)"
        } else {
            startPolling()
        }
    }

    // MARK: - Polling

    func startPolling() {
        pollingTask?.cancel()
        pollingTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self else { break }
                if !isMockMode {
                    let status = await TrainRepository.shared.fetchTrainStatus()
                    let currentTarget = SettingsManager.shared.targetStopEva
                    let updatedStatus = status.withTargetStop(currentTarget)
                    trainStatus = updatedStatus
                    pois = await TrainRepository.shared.fetchPois(lat: status.latitude, lon: status.longitude)

                    refreshOsmIfNeeded(lat: status.latitude, lon: status.longitude)
                    refreshWeatherIfNeeded(updatedStatus)

                    // Wagenreihung
                    let targetStop = currentTarget.flatMap { eva in
                        updatedStatus.stops.first { $0.evaNr == eva && !$0.passed }
                    }
                    let trainKey = "\(status.trainType)\(status.trainNumber)_\(targetStop?.evaNr ?? "")"
                    if wagenreihungFetchedForTrain != trainKey {
                        wagenreihungFetchedForTrain = trainKey
                        let coaches = await WagenreihungRepository.shared.fetch(status: status, queryStop: targetStop)
                        if !coaches.isEmpty { self.coaches = coaches }
                    }

                    // Connection tracking
                    if status.isConnected {
                        lastConnectedMs = Int64(Date().timeIntervalSince1970 * 1000)
                    }

                    // New journey detection
                    if !wasConnected && status.isConnected {
                        checkForNewJourney(status)
                    }
                    wasConnected = status.isConnected

                    // Update recording
                    if status.isConnected { updateRecording(status) }

                    // Connections / departures (every 30s)
                    let nowMs = Int64(Date().timeIntervalSince1970 * 1000)
                    if nowMs - lastConnectionsFetchMs > 30_000 {
                        lastConnectionsFetchMs = nowMs
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

    // MARK: - Target Stop

    func setTargetStop(_ eva: String?) {
        SettingsManager.shared.targetStopEva = eva
        trainStatus = trainStatus.withTargetStop(eva)

        let status = trainStatus
        let boardStop = relevantBoardStop(from: status)

        Task { [weak self] in
            guard let self else { return }
            connections = await TrainRepository.shared.fetchConnections(
                evaNr: boardStop?.evaNr ?? status.nextStopEva,
                ourArrivalMs: boardStop?.effectiveArrivalMs ?? 0
            )
            if let stop = boardStop {
                departures = await DepartureBoardRepository.shared.fetchDepartures(
                    evaNr: stop.evaNr, arrivalMs: stop.effectiveArrivalMs
                )
            }
            refreshWeatherIfNeeded(status)

            // Wagenreihung: sectors gelten für Ausstiegsbahnhof
            let targetStop = eva.flatMap { e in status.stops.first { $0.evaNr == e && !$0.passed } }
            let trainKey = "\(status.trainType)\(status.trainNumber)_\(targetStop?.evaNr ?? "")"
            if wagenreihungFetchedForTrain != trainKey {
                wagenreihungFetchedForTrain = trainKey
                let coaches = await WagenreihungRepository.shared.fetch(status: status, queryStop: targetStop)
                if !coaches.isEmpty { self.coaches = coaches }
            }
        }
    }

    // MARK: - Demo Mode

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
            weather = sampleWeather
            osmData = sampleOsmTrackData
            coaches = sampleCoaches
            menuCategories = sampleMenuCategories
            menuFetchedForTrain = "\(sampleTrainStatus.trainType)\(sampleTrainStatus.trainNumber)"
            wagenreihungFetchedForTrain = "\(sampleTrainStatus.trainType)\(sampleTrainStatus.trainNumber)_\(sampleTrainStatus.stops.last?.evaNr ?? "")"
        } else {
            trainStatus.isConnected = false
            trainStatus.targetStopEva = SettingsManager.shared.targetStopEva
            connections = []
            departures = []
            pois = []
            weather = nil
            osmData = OsmTrackData()
            coaches = []
            menuCategories = []
            menuFetchedForTrain = nil
            lastWeatherEva = ""
            lastOsmLat = 0
            lastOsmLon = 0
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

    // MARK: - Coach / Seat

    func setCoach(_ coach: Int?) {
        selectedCoach = coach
        SettingsManager.shared.coachNumber = coach
    }

    func setSeat(_ seat: String) {
        seatNumber = seat
        SettingsManager.shared.seatNumber = seat
    }

    // MARK: - Connection Retry

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

    // MARK: - Journey Recording

    private func checkForNewJourney(_ status: TrainStatus) {
        guard !status.trainNumber.isEmpty else { return }
        let date = dateFormatter.string(from: Date())
        let journeyKey = "\(status.trainType)\(status.trainNumber)_\(date)"
        let lastKey = SettingsManager.shared.lastJourneyKey
        if journeyKey != lastKey {
            SettingsManager.shared.lastJourneyKey = journeyKey
            showRecordingConsent = true
        }
    }

    func requestRecording() {
        guard trainStatus.isConnected else { return }
        showRecordingConsent = true
    }

    func startRecording(recordGps: Bool = false) {
        showRecordingConsent = false
        let status = trainStatus
        guard status.isConnected else { return }

        let targetEva = status.targetStopEva
        let destinationStop = targetEva.flatMap { eva in status.stops.first { $0.evaNr == eva && !$0.passed } }
            ?? status.stops.last
        let originStop = status.stops.last { $0.passed } ?? status.stops.first

        isRecording = true
        let rec = ActiveRecording(
            trainType: status.trainType,
            trainNumber: status.trainNumber,
            originStation: originStop?.name ?? "Unbekannt",
            destinationEvaNr: destinationStop?.evaNr ?? "",
            destinationStation: destinationStop?.name ?? status.destination,
            date: dateFormatter.string(from: Date()),
            departureTime: originStop?.actualDeparture.isEmpty == false ? originStop!.actualDeparture : (originStop?.scheduledDeparture ?? ""),
            originDistanceFromStart: originStop?.distanceFromStart ?? 0,
            destinationDistanceFromStart: destinationStop?.distanceFromStart ?? 0,
            stopsCount: status.stops.filter { !$0.passed && !$0.isCancelled }.count,
            recordGps: recordGps
        )
        activeRecording = rec
        liveRecording = LiveRecordingState(
            trainType: rec.trainType, trainNumber: rec.trainNumber,
            originStation: rec.originStation, destinationStation: rec.destinationStation,
            date: rec.date, departureTime: rec.departureTime,
            startMs: rec.startMs, currentSpeedKmh: status.speed,
            topSpeedKmh: 0, sampleCount: 0, trackPointCount: 0, recordGps: rec.recordGps
        )
    }

    func declineRecording() {
        showRecordingConsent = false
    }

    func cancelRecording() {
        activeRecording = nil
        isRecording = false
        liveRecording = nil
    }

    private func updateRecording(_ status: TrainStatus) {
        guard let rec = activeRecording else { return }
        if status.speed > rec.topSpeedKmh { rec.topSpeedKmh = status.speed }
        rec.speedSamples.append(status.speed)
        if rec.recordGps && status.latitude != 0 && status.longitude != 0 {
            let secondsFromStart = Int((Date().timeIntervalSince1970 * 1000 - Double(rec.startMs)) / 1000)
            rec.trackPoints.append(TrackPoint(
                lat: status.latitude, lon: status.longitude,
                speedKmh: status.speed, secondsFromStart: secondsFromStart
            ))
        }
        liveRecording = liveRecording.map {
            LiveRecordingState(
                trainType: $0.trainType, trainNumber: $0.trainNumber,
                originStation: $0.originStation, destinationStation: $0.destinationStation,
                date: $0.date, departureTime: $0.departureTime,
                startMs: $0.startMs, currentSpeedKmh: status.speed,
                topSpeedKmh: rec.topSpeedKmh, sampleCount: rec.speedSamples.count,
                trackPointCount: rec.trackPoints.count, recordGps: $0.recordGps
            )
        }

        let destinationStop = status.stops.first { $0.evaNr == rec.destinationEvaNr }
        if destinationStop?.passed == true {
            finishRecording(status, destinationStop: destinationStop!)
        }
    }

    private func finishRecording(_ status: TrainStatus, destinationStop: TrainStop) {
        guard let rec = activeRecording else { return }
        activeRecording = nil
        isRecording = false
        liveRecording = nil

        let durationMinutes = Int((Date().timeIntervalSince1970 * 1000 - Double(rec.startMs)) / 60_000)
        let avgSpeed = rec.speedSamples.isEmpty ? 0 : rec.speedSamples.reduce(0, +) / rec.speedSamples.count
        let distanceKm = (destinationStop.distanceFromStart - rec.originDistanceFromStart) / 1000
        let arrivalTime = destinationStop.actualArrival.isEmpty ? destinationStop.scheduledArrival : destinationStop.actualArrival

        let journey = SavedJourney(
            id: rec.id, trainType: rec.trainType, trainNumber: rec.trainNumber,
            originStation: rec.originStation, destinationStation: rec.destinationStation,
            date: rec.date, departureTime: rec.departureTime, arrivalTime: arrivalTime,
            delayMinutes: destinationStop.delayMinutes, distanceKm: distanceKm,
            topSpeedKmh: rec.topSpeedKmh, avgSpeedKmh: avgSpeed,
            durationMinutes: durationMinutes, stopsCount: rec.stopsCount,
            recordedGps: rec.recordGps, trackPoints: rec.trackPoints
        )

        Task {
            await JourneyRepository.shared.saveJourney(journey)
            journeys = await JourneyRepository.shared.loadJourneys()
        }
    }

    func deleteJourney(id: String) {
        Task {
            await JourneyRepository.shared.deleteJourney(id: id)
            journeys = await JourneyRepository.shared.loadJourneys()
        }
    }

    // MARK: - Menu

    func fetchMenuIfNeeded() {
        let trainKey = "\(trainStatus.trainType)\(trainStatus.trainNumber)"
        guard !trainKey.isEmpty else { return }
        if menuFetchedForTrain == trainKey && !menuCategories.isEmpty { return }
        menuFetchedForTrain = trainKey
        Task { [weak self] in
            guard let self else { return }
            isMenuLoading = true
            let result = await MenuRepository.shared.fetchMenu()
            let availabilities = await MenuRepository.shared.fetchAvailabilities()
            menuCategories = MenuRepository.shared.applyAvailabilities(categories: result.categories, availabilities: availabilities)
            isMenuLoading = false
        }
    }

    func refreshMenu() {
        guard !isMockMode else { return }
        Task { [weak self] in
            guard let self else { return }
            isMenuLoading = true
            let result = await MenuRepository.shared.fetchMenu()
            let availabilities = await MenuRepository.shared.fetchAvailabilities()
            menuCategories = MenuRepository.shared.applyAvailabilities(categories: result.categories, availabilities: availabilities)
            menuFetchedForTrain = "\(trainStatus.trainType)\(trainStatus.trainNumber)"
            isMenuLoading = false
        }
    }

    // MARK: - Station Facilities

    func searchStations(query: String) {
        guard query.count >= 4 else {
            stationSearchResults = []
            return
        }
        Task { [weak self] in
            guard let self else { return }
            try? await Task.sleep(for: .milliseconds(300))
            stationSearchResults = await StationFacilitiesRepository.shared.searchStations(query: query)
        }
    }

    func selectServiceStation(_ result: StationSearchResult) {
        stationSearchResults = []
        serviceStation = StationInfo(evaNr: result.evaNr, name: result.name, isLoading: true)
        Task { [weak self] in
            guard let self else { return }
            serviceStation = await StationFacilitiesRepository.shared.fetchFacilities(evaNr: result.evaNr, stationName: result.name)
        }
    }

    func loadServiceStationFromTrain(evaNr: String, name: String) {
        serviceStation = StationInfo(evaNr: evaNr, name: name, isLoading: true)
        Task { [weak self] in
            guard let self else { return }
            serviceStation = await StationFacilitiesRepository.shared.fetchFacilities(evaNr: evaNr, stationName: name)
        }
    }

    // MARK: - Helpers

    private func relevantBoardStop(from status: TrainStatus) -> TrainStop? {
        let targetEva = status.targetStopEva
        if let eva = targetEva, let target = status.stops.first(where: { $0.evaNr == eva && !$0.passed }) {
            return target
        }
        return status.stops.first(where: { !$0.passed })
    }

    private func refreshOsmIfNeeded(lat: Double, lon: Double) {
        guard lat != 0 || lon != 0 else { return }
        let dLat = abs(lat - lastOsmLat)
        let dLon = abs(lon - lastOsmLon)
        if lastOsmLat != 0 && dLat < 0.027 && dLon < 0.035 { return }
        lastOsmLat = lat
        lastOsmLon = lon
        Task { [weak self] in
            guard let self else { return }
            osmData = OsmTrackData(isLoading: true)
            osmData = await OsmRepository.shared.fetchTrackData(lat: lat, lon: lon)
        }
    }

    private func refreshWeatherIfNeeded(_ status: TrainStatus) {
        let stop = weatherStop(from: status)
        guard let stop else { return }
        let nowMs = Int64(Date().timeIntervalSince1970 * 1000)
        guard stop.evaNr != lastWeatherEva || nowMs - lastWeatherFetchMs > 120_000 else { return }
        lastWeatherEva = stop.evaNr
        lastWeatherFetchMs = nowMs
        Task { [weak self] in
            guard let self else { return }
            weather = await WeatherRepository.shared.fetchWeatherForStation(stationName: stop.name)
        }
    }

    private func weatherStop(from status: TrainStatus) -> TrainStop? {
        if let targetEva = status.targetStopEva,
           let stop = status.stops.first(where: { $0.evaNr == targetEva && !$0.passed }) {
            return stop
        }
        return status.stops.last
    }

    private func loadSettings() {
        let settings = SettingsManager.shared
        isMockMode = settings.isMockMode
        demoSpeed = settings.demoSpeed
        reducedMotion = settings.reducedMotion
        showDemoSpeed = settings.showDemoSpeed
        appTheme = AppTheme(rawValue: settings.appTheme) ?? .system
        selectedCoach = settings.coachNumber
        seatNumber = settings.seatNumber
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
