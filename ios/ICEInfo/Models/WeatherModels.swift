import Foundation

struct WeatherInfo: Codable, Sendable {
    var stationName: String
    var temperature: Double
    var precipitation: Double
    var windspeed: Double
    var weatherCode: Int

    enum JacketType: String, Sendable {
        case none = "Keine Jacke nötig"
        case light = "Leichte Jacke"
        case warm = "Warme Jacke"
        case rain = "Regenjacke"
        case wind = "Windjacke"
    }

    var jacketRecommendation: JacketType {
        if precipitation > 0.1 { return .rain }
        if temperature < 8 { return .warm }
        if temperature < 16 { return .light }
        if windspeed > 40 { return .wind }
        return .none
    }
}
