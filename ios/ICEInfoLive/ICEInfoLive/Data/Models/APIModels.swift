import Foundation

// MARK: - ICE Portal API Models

struct StatusResponse: Codable {
    let speed: Int?
    let latitude: Double?
    let longitude: Double?
    let trainType: String?
    let vzn: String?
    let tzn: String?
    let wagonClass: Int?
    let connectivity: ConnectivityResponse?
    let serviceLevel: String?
}

struct ConnectivityResponse: Codable {
    let currentState: String?
    let nextState: String?
    let remainingTimeSeconds: Int?
}

struct TripResponse: Codable {
    let trip: TripInfo?
}

struct TripInfo: Codable {
    let trainType: String?
    let vzn: String?
    let stops: [ApiStop]?
    let actualPosition: Int?
    let distanceFromStart: Int?
    let totalDistance: Int?
}

struct ApiStop: Codable {
    let station: ApiStation?
    let timetable: ApiTimetable?
    let track: Track?
    let info: StopInfo?
    let delayReasons: [DelayReason]?
}

struct ApiStation: Codable {
    let name: String?
    let evaNr: String?
}

struct ApiTimetable: Codable {
    let scheduledArrivalTime: Double?
    let actualArrivalTime: Double?
    let showActualArrivalTime: Bool?
    let scheduledDepartureTime: Double?
    let actualDepartureTime: Double?
    let showActualDepartureTime: Bool?
}

struct Track: Codable {
    let actual: String?
    let scheduled: String?
}

struct StopInfo: Codable {
    let passed: Bool?
    let distance: Int?
    let distanceFromStart: Int?
    let status: Int?
}

struct DelayReason: Codable {
    let text: String?
}

struct PoiResponse: Codable {
    let pois: [PoiItemResponse]?
}

struct PoiItemResponse: Codable {
    let name: String?
    let type: String?
    let distance: Int?
    let latitude: Double?
    let longitude: Double?
    let description: String?
}

struct ConnectionResponse: Codable {
    let connections: [ApiConnection]?
}

struct ApiConnection: Codable {
    let trainType: String?
    let vzn: String?
    let station: ApiStation?
    let timetable: ApiTimetable?
    let track: Track?
    let info: ConnectionInfo?
}

struct ConnectionInfo: Codable {
    let direction: String?
    let status: Int?
    let passed: Bool?
}

// MARK: - transport.rest API Models

struct DeparturesResponse: Codable {
    let departures: [TrDeparture]?
}

struct TrDeparture: Codable {
    let tripId: String?
    let when: String?
    let plannedWhen: String?
    let delay: Int?
    let platform: String?
    let plannedPlatform: String?
    let direction: String?
    let line: TrLine?
    let cancelled: Bool?
}

struct TrLine: Codable {
    let name: String?
    let productName: String?
}
