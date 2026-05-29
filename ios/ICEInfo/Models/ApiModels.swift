import Foundation

struct StatusResponse: Codable, Sendable {
    let speed: Double
    let latitude: Double
    let longitude: Double
    let tzn: String
    let series: String
    let wagonClass: String
    let connectivity: Connectivity?

    enum CodingKeys: String, CodingKey {
        case speed, latitude, longitude, tzn, series, wagonClass, connectivity
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        speed = try container.decodeIfPresent(Double.self, forKey: .speed) ?? 0
        latitude = try container.decodeIfPresent(Double.self, forKey: .latitude) ?? 0
        longitude = try container.decodeIfPresent(Double.self, forKey: .longitude) ?? 0
        tzn = try container.decodeIfPresent(String.self, forKey: .tzn) ?? ""
        series = try container.decodeIfPresent(String.self, forKey: .series) ?? ""
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

// MARK: - Wagenreihung (Carriage Order) API

struct WagenreihungResponse: Codable, Sendable {
    var departurePlatform: String = ""
    var departurePlatformSchedule: String = ""
    var groups: [WagenreihungGroup] = []
}

struct WagenreihungGroup: Codable, Sendable {
    var vehicles: [WagenreihungVehicle] = []
}

struct WagenreihungVehicle: Codable, Sendable {
    var wagonIdentificationNumber: Int = 0
    var status: String = "OPEN"
    var type: WagenreihungVehicleType = WagenreihungVehicleType()
    var platformPosition: WagenreihungPlatformPosition = WagenreihungPlatformPosition()
    var amenities: [WagenreihungAmenity] = []
}

struct WagenreihungAmenity: Codable, Sendable {
    var type: String = ""
    var status: String = "AVAILABLE"
    var amount: Int = 0
}

struct WagenreihungVehicleType: Codable, Sendable {
    var category: String = ""
    var hasFirstClass: Bool = false
    var hasEconomyClass: Bool = false
}

struct WagenreihungPlatformPosition: Codable, Sendable {
    var sector: String = ""
    var start: Double = 0.0
    var end: Double = 0.0
}

// MARK: - StaDa / FaSta (Station Facilities) API

struct StadaResponse: Codable, Sendable {
    var result: [StadaStation] = []
    var total: Int = 0
}

struct StadaStation: Codable, Sendable {
    var number: Int? = nil
    var name: String? = nil
    var evaNumbers: [EvaNumber] = []
    var hasWiFi: Bool? = nil
    var hasPublicFacilities: Bool? = nil
    var hasBicycleParking: Bool? = nil
    var hasLockerSystem: Bool? = nil
    var hasMobilityService: String? = nil
    var hasParking: Bool? = nil
    var hasLostAndFound: Bool? = nil

    var stationNumber: Int? { number }
}

struct EvaNumber: Codable, Sendable {
    var number: Int64? = nil
    var isMain: Bool? = nil
}

struct FastaFacility: Codable, Sendable {
    var equipmentnumber: Int64 = 0
    var type: String? = nil
    var state: String? = nil
    var stateExplanation: String? = nil
    var description: String? = nil
    var stationnumber: Int? = nil
}

// MARK: - Open-Meteo Weather API

struct GeoResponse: Codable, Sendable {
    var results: [GeoLocation]? = nil
}

struct GeoLocation: Codable, Sendable {
    var latitude: Double = 0.0
    var longitude: Double = 0.0
}

struct OpenMeteoResponse: Codable, Sendable {
    var current: CurrentWeather? = nil
}

struct CurrentWeather: Codable, Sendable {
    var temperature_2m: Double = 0.0
    var precipitation: Double = 0.0
    var windspeed_10m: Double = 0.0
    var weather_code: Int = 0
}

// MARK: - OSM Overpass API

struct OverpassResponse: Codable, Sendable {
    var elements: [OverpassElement] = []
}

struct OverpassElement: Codable, Sendable {
    var type: String = ""
    var id: Int64 = 0
    var lat: Double? = nil
    var lon: Double? = nil
    var center: OverpassLatLon? = nil
    var tags: [String: String] = [:]
}

struct OverpassLatLon: Codable, Sendable {
    var lat: Double = 0.0
    var lon: Double = 0.0
}
