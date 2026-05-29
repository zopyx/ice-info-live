import Foundation

enum FacilityType: String, Codable, Sendable {
    case elevator = "ELEVATOR"
    case escalator = "ESCALATOR"
    case toilet = "TOILET"
    case wifi = "WIFI"
    case infoDesk = "INFO_DESK"
    case departureMonitor = "DEPARTURE_MONITOR"
    case ramp = "RAMP"
    case parking = "PARKING"
    case bikeParking = "BIKE_PARKING"
    case waitingRoom = "WAITING_ROOM"
}

enum FacilityStatus: String, Codable, Sendable {
    case active = "ACTIVE"
    case inactive = "INACTIVE"
    case unknown = "UNKNOWN"
}

struct StationFacility: Codable, Sendable, Identifiable {
    var id: String
    var type: FacilityType
    var label: String
    var status: FacilityStatus
    var description: String = ""
}

struct StationInfo: Codable, Sendable {
    var evaNr: String
    var name: String
    var liveFacilities: [StationFacility] = []
    var staticFacilities: [FacilityType] = []
    var isLoading: Bool = false
    var error: String? = nil
}

struct StationSearchResult: Codable, Sendable, Identifiable {
    var id: String { evaNr }
    var evaNr: String
    var name: String
}
