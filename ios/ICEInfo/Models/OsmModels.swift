import Foundation

struct TrackInfo: Codable, Sendable {
    var maxSpeed: Int? = nil
    var electrified: String? = nil
    var voltage: Int? = nil
    var tracks: Int? = nil
    var usage: String? = nil
}

enum RailFeatureType: String, Codable, Sendable {
    case tunnel = "TUNNEL"
    case bridge = "BRIDGE"
    case station = "STATION"
    case halt = "HALT"
}

struct RailFeature: Codable, Sendable, Identifiable {
    var id: String { name + type.rawValue }
    var name: String
    var type: RailFeatureType
    var distanceKm: Double
}

struct OsmTrackData: Codable, Sendable {
    var trackInfo: TrackInfo = TrackInfo()
    var features: [RailFeature] = []
    var isLoading: Bool = false
    var error: String? = nil
}
