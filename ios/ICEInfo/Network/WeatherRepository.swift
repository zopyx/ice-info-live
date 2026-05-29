import Foundation

actor WeatherRepository {
    static let shared = WeatherRepository()

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        return d
    }()

    func fetchWeatherForStation(stationName: String) async -> WeatherInfo? {
        let searchName = stationName
            .replacingOccurrences(of: "\\(.*?\\)", with: "", options: .regularExpression)
            .replacingOccurrences(of: "Hbf", with: "")
            .replacingOccurrences(of: "Bhf", with: "")
            .trimmingCharacters(in: .whitespaces)

        guard let geoUrl = URL(string: "https://geocoding-api.open-meteo.com/v1/search?name=\(searchName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? searchName)&count=1&language=de&format=json") else { return nil }

        do {
            let (geoData, _) = try await URLSession.shared.data(from: geoUrl)
            let geo = try decoder.decode(GeoResponse.self, from: geoData)
            guard let loc = geo.results?.first else { return nil }

            let weatherUrl = URL(string: "https://api.open-meteo.com/v1/forecast?latitude=\(loc.latitude)&longitude=\(loc.longitude)&current=temperature_2m,precipitation,windspeed_10m,weather_code&timezone=auto")!
            let (weatherData, _) = try await URLSession.shared.data(from: weatherUrl)
            let weather = try decoder.decode(OpenMeteoResponse.self, from: weatherData)
            guard let current = weather.current else { return nil }

            return WeatherInfo(
                stationName: stationName,
                temperature: current.temperature_2m,
                precipitation: current.precipitation,
                windspeed: current.windspeed_10m,
                weatherCode: current.weather_code
            )
        } catch {
            return nil
        }
    }
}
