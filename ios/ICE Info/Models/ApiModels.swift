import Foundation

struct StatusResponse: Codable, Sendable {
    let speed: Double
    let latitude: Double
    let longitude: Double
    let tzn: String
    let wagonClass: String
    let connectivity: Connectivity?

    enum CodingKeys: String, CodingKey {
        case speed, latitude, longitude, tzn, wagonClass, connectivity
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        speed = try container.decodeIfPresent(Double.self, forKey: .speed) ?? 0
        latitude = try container.decodeIfPresent(Double.self, forKey: .latitude) ?? 0
        longitude = try container.decodeIfPresent(Double.self, forKey: .longitude) ?? 0
        tzn = try container.decodeIfPresent(String.self, forKey: .tzn) ?? ""
        wagonClass = try container.decodeIfPresent(String.self, forKey: .wagonClass) ?? ""
        connectivity = try container.decodeIfPresent(Connectivity.self, forKey: .connectivity)
    }
}

struct Connectivity: Codable, Sendable {
    let currentState: String
    let nextState: String?
    let remainingTimeSeconds: Int?

    enum CodingKeys: String, CodingKey {
        case currentState, nextState, remainingTimeSeconds
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        currentState = try container.decodeIfPresent(String.self, forKey: .currentState) ?? ""
        nextState = try container.decodeIfPresent(String.self, forKey: .nextState)
        remainingTimeSeconds = try container.decodeIfPresent(Int.self, forKey: .remainingTimeSeconds)
    }
}

struct TripResponse: Codable, Sendable {
    let trip: TripInfo?

    enum CodingKeys: String, CodingKey {
        case trip
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        trip = try container.decodeIfPresent(TripInfo.self, forKey: .trip)
    }
}

struct TripInfo: Codable, Sendable {
    let trainType: String
    let vzn: String
    let actualPosition: Int
    let stops: [ApiStop]

    enum CodingKeys: String, CodingKey {
        case trainType, vzn, actualPosition, stops
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        trainType = try container.decodeIfPresent(String.self, forKey: .trainType) ?? "ICE"
        vzn = try container.decodeIfPresent(String.self, forKey: .vzn) ?? ""
        actualPosition = try container.decodeIfPresent(Int.self, forKey: .actualPosition) ?? 0
        stops = try container.decodeIfPresent([ApiStop].self, forKey: .stops) ?? []
    }
}

struct ApiStop: Codable, Sendable {
    let station: Station?
    let info: StopInfo?
    let timetable: Timetable?
    let track: Track?
    let delayReasons: [DelayReason]?
    let cancelled: Bool
}

struct Station: Codable, Sendable {
    let name: String
    let evaNr: String

    enum CodingKeys: String, CodingKey {
        case name, evaNr
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        evaNr = try container.decodeIfPresent(String.self, forKey: .evaNr) ?? ""
    }
}

struct StopInfo: Codable, Sendable {
    let passed: Bool
    let distance: Int
    let distanceFromStart: Int
    let status: Int

    enum CodingKeys: String, CodingKey {
        case passed, distance, distanceFromStart, status
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        passed = try container.decodeIfPresent(Bool.self, forKey: .passed) ?? false
        distance = try container.decodeIfPresent(Int.self, forKey: .distance) ?? 0
        distanceFromStart = try container.decodeIfPresent(Int.self, forKey: .distanceFromStart) ?? 0
        status = try container.decodeIfPresent(Int.self, forKey: .status) ?? 0
    }
}

struct Timetable: Codable, Sendable {
    let scheduledArrivalTime: Int64
    let actualArrivalTime: Int64
    let scheduledDepartureTime: Int64
    let actualDepartureTime: Int64

    enum CodingKeys: String, CodingKey {
        case scheduledArrivalTime, actualArrivalTime
        case scheduledDepartureTime, actualDepartureTime
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        scheduledArrivalTime = try container.decodeIfPresent(Int64.self, forKey: .scheduledArrivalTime) ?? 0
        actualArrivalTime = try container.decodeIfPresent(Int64.self, forKey: .actualArrivalTime) ?? 0
        scheduledDepartureTime = try container.decodeIfPresent(Int64.self, forKey: .scheduledDepartureTime) ?? 0
        actualDepartureTime = try container.decodeIfPresent(Int64.self, forKey: .actualDepartureTime) ?? 0
    }
}

struct Track: Codable, Sendable {
    let actual: String

    enum CodingKeys: String, CodingKey {
        case actual
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        actual = try container.decodeIfPresent(String.self, forKey: .actual) ?? ""
    }
}

struct DelayReason: Codable, Sendable {
    let text: String

    enum CodingKeys: String, CodingKey {
        case text
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try container.decodeIfPresent(String.self, forKey: .text) ?? ""
    }
}

struct PoiResponse: Codable, Sendable {
    let pois: [PoiItem]?

    enum CodingKeys: String, CodingKey {
        case pois
    }
}

struct ConnectionResponse: Codable, Sendable {
    let connections: [ApiConnection]?

    enum CodingKeys: String, CodingKey {
        case connections
    }
}

struct ApiConnection: Codable, Sendable {
    let trainType: String
    let vzn: String
    let finalStation: String
    let timetable: Timetable?
    let track: Track?
    let missed: Bool

    enum CodingKeys: String, CodingKey {
        case trainType, vzn, finalStation, timetable, track, missed
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        trainType = try container.decodeIfPresent(String.self, forKey: .trainType) ?? ""
        vzn = try container.decodeIfPresent(String.self, forKey: .vzn) ?? ""
        finalStation = try container.decodeIfPresent(String.self, forKey: .finalStation) ?? ""
        timetable = try container.decodeIfPresent(Timetable.self, forKey: .timetable)
        track = try container.decodeIfPresent(Track.self, forKey: .track)
        missed = try container.decodeIfPresent(Bool.self, forKey: .missed) ?? false
    }
}
