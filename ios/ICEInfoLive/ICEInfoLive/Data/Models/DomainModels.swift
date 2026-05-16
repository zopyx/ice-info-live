import Foundation

struct TrainStatus: Equatable, Sendable {
    var trainType: String
    var trainNumber: String
    var tzn: String
    var speed: Int
    var latitude: Double
    var longitude: Double
    var wagonClass: Int
    var connectivity: ConnectivityState
    var nextStop: TrainStop?
    var destination: Station
    var stops: [TrainStop]
    var delayMinutes: Int
    var delayReasons: [String]
    var targetStopEva: String?
    var isMockMode: Bool
    var totalDistance: Int
    var distanceFromStart: Int

    static func == (lhs: TrainStatus, rhs: TrainStatus) -> Bool {
        lhs.trainType == rhs.trainType &&
        lhs.trainNumber == rhs.trainNumber &&
        lhs.tzn == rhs.tzn &&
        lhs.speed == rhs.speed &&
        lhs.latitude == rhs.latitude &&
        lhs.longitude == rhs.longitude &&
        lhs.wagonClass == rhs.wagonClass &&
        lhs.connectivity == rhs.connectivity &&
        lhs.nextStop == rhs.nextStop &&
        lhs.destination == rhs.destination &&
        lhs.stops == rhs.stops &&
        lhs.delayMinutes == rhs.delayMinutes &&
        lhs.delayReasons == rhs.delayReasons &&
        lhs.targetStopEva == rhs.targetStopEva &&
        lhs.isMockMode == rhs.isMockMode &&
        lhs.totalDistance == rhs.totalDistance &&
        lhs.distanceFromStart == rhs.distanceFromStart
    }
}

struct TrainStop: Equatable, Identifiable, Sendable {
    let id: UUID
    let station: Station
    let timetable: Timetable
    let track: String?
    let passed: Bool
    let isCurrentStop: Bool
    let isNextStop: Bool
    let distanceFromStart: Int
    let delayMinutes: Int
    let cancelled: Bool
    let additionalStop: Bool

    static func == (lhs: TrainStop, rhs: TrainStop) -> Bool {
        lhs.station == rhs.station &&
        lhs.timetable == rhs.timetable &&
        lhs.track == rhs.track &&
        lhs.passed == rhs.passed &&
        lhs.isCurrentStop == rhs.isCurrentStop &&
        lhs.isNextStop == rhs.isNextStop &&
        lhs.distanceFromStart == rhs.distanceFromStart &&
        lhs.delayMinutes == rhs.delayMinutes &&
        lhs.cancelled == rhs.cancelled &&
        lhs.additionalStop == rhs.additionalStop
    }
}

struct Station: Equatable, Sendable {
    let name: String
    let evaNr: String
}

struct Timetable: Equatable, Sendable {
    let scheduledArrival: Date?
    let actualArrival: Date?
    let scheduledDeparture: Date?
    let actualDeparture: Date?
}

struct PoiItem: Equatable, Identifiable, Sendable {
    let id: UUID
    let name: String
    let type: String
    let distance: Int
    let latitude: Double
    let longitude: Double
    let description: String?

    static func == (lhs: PoiItem, rhs: PoiItem) -> Bool {
        lhs.name == rhs.name &&
        lhs.type == rhs.type &&
        lhs.distance == rhs.distance &&
        lhs.latitude == rhs.latitude &&
        lhs.longitude == rhs.longitude &&
        lhs.description == rhs.description
    }
}

struct ConnectingTrain: Equatable, Identifiable, Sendable {
    let id: UUID
    let type: String
    let number: String
    let destination: String
    let departureTime: Date
    let track: String?
    let delayMinutes: Int
    let reachable: Bool
    let transferMinutes: Int

    static func == (lhs: ConnectingTrain, rhs: ConnectingTrain) -> Bool {
        lhs.type == rhs.type &&
        lhs.number == rhs.number &&
        lhs.destination == rhs.destination &&
        lhs.departureTime == rhs.departureTime &&
        lhs.track == rhs.track &&
        lhs.delayMinutes == rhs.delayMinutes &&
        lhs.reachable == rhs.reachable &&
        lhs.transferMinutes == rhs.transferMinutes
    }
}

struct Departure: Equatable, Identifiable, Sendable {
    let id: UUID
    let lineName: String
    let destination: String
    let scheduledTime: Date
    let delayMinutes: Int
    let platform: String?
    let cancelled: Bool

    static func == (lhs: Departure, rhs: Departure) -> Bool {
        lhs.lineName == rhs.lineName &&
        lhs.destination == rhs.destination &&
        lhs.scheduledTime == rhs.scheduledTime &&
        lhs.delayMinutes == rhs.delayMinutes &&
        lhs.platform == rhs.platform &&
        lhs.cancelled == rhs.cancelled
    }
}

enum ConnectivityState: Equatable, Sendable {
    case strong
    case weak
    case noConnection
    case noInfo

    init(from response: ConnectivityResponse?) {
        guard let state = response?.currentState?.lowercased() else {
            self = .noInfo
            return
        }
        switch state {
        case "strong": self = .strong
        case "weak": self = .weak
        case "no_connection", "none": self = .noConnection
        default: self = .noInfo
        }
    }
}

extension TrainStatus {
    var coordinate: Coordinate {
        Coordinate(latitude: latitude, longitude: longitude)
    }
}

struct Coordinate: Equatable, Sendable {
    let latitude: Double
    let longitude: Double
}
