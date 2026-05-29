import Foundation

struct SavedJourney: Codable, Sendable, Identifiable {
    var id: String
    var trainType: String
    var trainNumber: String
    var originStation: String
    var destinationStation: String
    var date: String
    var departureTime: String
    var arrivalTime: String
    var delayMinutes: Int
    var distanceKm: Int
    var topSpeedKmh: Int
    var avgSpeedKmh: Int
    var durationMinutes: Int
    var stopsCount: Int
    var recordedGps: Bool = false
    var trackPoints: [TrackPoint] = []
}

struct TrackPoint: Codable, Sendable {
    var lat: Double
    var lon: Double
    var speedKmh: Int
    var secondsFromStart: Int
}

struct LiveRecordingState: Codable, Sendable {
    var trainType: String
    var trainNumber: String
    var originStation: String
    var destinationStation: String
    var date: String
    var departureTime: String
    var startMs: Int64
    var currentSpeedKmh: Int
    var topSpeedKmh: Int
    var sampleCount: Int
    var trackPointCount: Int
    var recordGps: Bool
}
