import Foundation

enum AppTheme: String, Codable, Sendable {
    case light, dark, system
}

struct TrainStatus: Codable, Sendable {
    var trainType = ""
    var trainNumber = ""
    var speed = 0
    var nextStop = ""
    var destination = ""
    var eta = ""
    var delayMinutes = 0
    var track = ""
    var delayReason = ""
    var distanceToNext = 0
    var distanceLastToNext = 0
    var nextStopEva = ""
    var stops: [TrainStop] = []
    var wagonClass = ""
    var connectivity = ""
    var nextConnectivity: String? = nil
    var connectivityRemainingSeconds: Int? = nil
    var tzn = ""
    var latitude = 0.0
    var longitude = 0.0
    var distanceToDestination = 0
    var actualPosition = 0
    var destinationEta = ""
    var destinationTrack = ""
    var destinationDelay = 0
    var isConnected = true
    var targetStopEva: String? = nil

    static let disconnected = TrainStatus(
        trainType: "ICE", trainNumber: "\u{2014}", speed: 0,
        nextStop: "\u{2014}", destination: "\u{2014}", eta: "--:--",
        isConnected: false
    )
}

struct TrainStop: Codable, Sendable, Identifiable {
    var id: String { "\(evaNr)-\(name)" }
    var name = ""
    var evaNr = ""
    var scheduledArrival = ""
    var actualArrival = ""
    var delayMinutes = 0
    var track = ""
    var passed = false
    var isNext = false
    var distanceFromStart = 0
    var scheduledArrivalMs: Int64 = 0
    var isAdditional = false
    var scheduledDeparture = ""
    var actualDeparture = ""
    var departureDelayMinutes = 0
    var isCancelled = false

    var effectiveArrivalMs: Int64 {
        scheduledArrivalMs > 0 ? scheduledArrivalMs + Int64(delayMinutes) * 60_000 : 0
    }
}

struct ConnectingTrain: Codable, Sendable, Identifiable {
    var id: String { "\(trainType)-\(trainNumber)-\(departure)" }
    var trainType = ""
    var trainNumber = ""
    var destination = ""
    var departure = ""
    var track = ""
    var delayMinutes = 0
    var reachable = true
    var transferMinutes: Int? = nil
}

struct Departure: Codable, Sendable, Identifiable {
    var id: String { "\(line)-\(scheduledTime)" }
    var line = ""
    var destination = ""
    var scheduledTime = ""
    var delayMinutes = 0
    var platform = ""
    var cancelled = false
}

struct PoiItem: Codable, Sendable, Identifiable {
    var id: String { name }
    var name = ""
    var type = ""
    var distance = 0
    var latitude = 0.0
    var longitude = 0.0
    var description = ""
}
