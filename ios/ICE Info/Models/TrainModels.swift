import Foundation

enum AppTheme: String, Codable, Sendable {
    case light, dark, system
}

struct TrainStatus: Codable, Sendable {
    let trainType: String
    let trainNumber: String
    let speed: Int
    let nextStop: String
    let destination: String
    let eta: String
    let delayMinutes: Int
    let track: String
    let delayReason: String
    let distanceToNext: Int
    let distanceLastToNext: Int
    let nextStopEva: String
    let stops: [TrainStop]
    let wagonClass: String
    let connectivity: String
    let nextConnectivity: String?
    let connectivityRemainingSeconds: Int?
    let tzn: String
    let latitude: Double
    let longitude: Double
    let distanceToDestination: Int
    let actualPosition: Int
    let destinationEta: String
    let destinationTrack: String
    let destinationDelay: Int
    let isConnected: Bool
    let targetStopEva: String?

    static let disconnected: TrainStatus = TrainStatus(
        trainType: "ICE", trainNumber: "—", speed: 0,
        nextStop: "—", destination: "—", eta: "--:--",
        isConnected: false
    )
}

extension TrainStatus {
    init(
        trainType: String = "",
        trainNumber: String = "",
        speed: Int = 0,
        nextStop: String = "",
        destination: String = "",
        eta: String = "",
        delayMinutes: Int = 0,
        track: String = "",
        delayReason: String = "",
        distanceToNext: Int = 0,
        distanceLastToNext: Int = 0,
        nextStopEva: String = "",
        stops: [TrainStop] = [],
        wagonClass: String = "",
        connectivity: String = "",
        nextConnectivity: String? = nil,
        connectivityRemainingSeconds: Int? = nil,
        tzn: String = "",
        latitude: Double = 0,
        longitude: Double = 0,
        distanceToDestination: Int = 0,
        actualPosition: Int = 0,
        destinationEta: String = "",
        destinationTrack: String = "",
        destinationDelay: Int = 0,
        isConnected: Bool = true,
        targetStopEva: String? = nil
    ) {
        self.trainType = trainType
        self.trainNumber = trainNumber
        self.speed = speed
        self.nextStop = nextStop
        self.destination = destination
        self.eta = eta
        self.delayMinutes = delayMinutes
        self.track = track
        self.delayReason = delayReason
        self.distanceToNext = distanceToNext
        self.distanceLastToNext = distanceLastToNext
        self.nextStopEva = nextStopEva
        self.stops = stops
        self.wagonClass = wagonClass
        self.connectivity = connectivity
        self.nextConnectivity = nextConnectivity
        self.connectivityRemainingSeconds = connectivityRemainingSeconds
        self.tzn = tzn
        self.latitude = latitude
        self.longitude = longitude
        self.distanceToDestination = distanceToDestination
        self.actualPosition = actualPosition
        self.destinationEta = destinationEta
        self.destinationTrack = destinationTrack
        self.destinationDelay = destinationDelay
        self.isConnected = isConnected
        self.targetStopEva = targetStopEva
    }
}

struct TrainStop: Codable, Sendable, Identifiable {
    var id: String { "\(evaNr)-\(name)" }
    let name: String
    let evaNr: String
    let scheduledArrival: String
    let actualArrival: String
    let delayMinutes: Int
    let track: String
    let passed: Bool
    let isNext: Bool
    let distanceFromStart: Int
    let scheduledArrivalMs: Int64
    let isAdditional: Bool
    let scheduledDeparture: String
    let actualDeparture: String
    let departureDelayMinutes: Int
    let isCancelled: Bool

    var effectiveArrivalMs: Int64 {
        if scheduledArrivalMs > 0 {
            return scheduledArrivalMs + Int64(delayMinutes) * 60_000
        }
        return 0
    }
}

extension TrainStop {
    init(
        name: String = "",
        evaNr: String = "",
        scheduledArrival: String = "",
        actualArrival: String = "",
        delayMinutes: Int = 0,
        track: String = "",
        passed: Bool = false,
        isNext: Bool = false,
        distanceFromStart: Int = 0,
        scheduledArrivalMs: Int64 = 0,
        isAdditional: Bool = false,
        scheduledDeparture: String = "",
        actualDeparture: String = "",
        departureDelayMinutes: Int = 0,
        isCancelled: Bool = false
    ) {
        self.name = name
        self.evaNr = evaNr
        self.scheduledArrival = scheduledArrival
        self.actualArrival = actualArrival
        self.delayMinutes = delayMinutes
        self.track = track
        self.passed = passed
        self.isNext = isNext
        self.distanceFromStart = distanceFromStart
        self.scheduledArrivalMs = scheduledArrivalMs
        self.isAdditional = isAdditional
        self.scheduledDeparture = scheduledDeparture
        self.actualDeparture = actualDeparture
        self.departureDelayMinutes = departureDelayMinutes
        self.isCancelled = isCancelled
    }
}

struct ConnectingTrain: Codable, Sendable, Identifiable {
    var id: String { "\(trainType)-\(trainNumber)-\(departure)" }
    let trainType: String
    let trainNumber: String
    let destination: String
    let departure: String
    let track: String
    let delayMinutes: Int
    let reachable: Bool
    let transferMinutes: Int?
}

extension ConnectingTrain {
    init(
        trainType: String = "",
        trainNumber: String = "",
        destination: String = "",
        departure: String = "",
        track: String = "",
        delayMinutes: Int = 0,
        reachable: Bool = true,
        transferMinutes: Int? = nil
    ) {
        self.trainType = trainType
        self.trainNumber = trainNumber
        self.destination = destination
        self.departure = departure
        self.track = track
        self.delayMinutes = delayMinutes
        self.reachable = reachable
        self.transferMinutes = transferMinutes
    }
}

struct Departure: Codable, Sendable, Identifiable {
    var id: String { "\(line)-\(scheduledTime)" }
    let line: String
    let destination: String
    let scheduledTime: String
    let delayMinutes: Int
    let platform: String
    let cancelled: Bool
}

extension Departure {
    init(
        line: String = "",
        destination: String = "",
        scheduledTime: String = "",
        delayMinutes: Int = 0,
        platform: String = "",
        cancelled: Bool = false
    ) {
        self.line = line
        self.destination = destination
        self.scheduledTime = scheduledTime
        self.delayMinutes = delayMinutes
        self.platform = platform
        self.cancelled = cancelled
    }
}

struct PoiItem: Codable, Sendable, Identifiable {
    var id: String { name }
    let name: String
    let type: String
    let distance: Int
    let latitude: Double
    let longitude: Double
    let description: String
}

extension PoiItem {
    init(
        name: String = "",
        type: String = "",
        distance: Int = 0,
        latitude: Double = 0,
        longitude: Double = 0,
        description: String = ""
    ) {
        self.name = name
        self.type = type
        self.distance = distance
        self.latitude = latitude
        self.longitude = longitude
        self.description = description
    }
}
