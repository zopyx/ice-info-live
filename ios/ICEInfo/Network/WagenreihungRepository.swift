import Foundation

actor WagenreihungRepository {
    static let shared = WagenreihungRepository()

    private let baseUrl = "https://www.bahn.de/web/api/reisebegleitung/wagenreihung/vehicle-sequence"

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        return d
    }()

    private let isoDateFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    func fetch(status: TrainStatus, queryStop: TrainStop? = nil) async -> [Coach] {
        let stop: TrainStop
        let timeMs: Int64
        if let qs = queryStop, !qs.evaNr.isEmpty {
            stop = qs
            timeMs = qs.scheduledArrivalMs > 0 ? qs.scheduledArrivalMs :
                     qs.scheduledDepartureMs > 0 ? qs.scheduledDepartureMs : 0
        } else {
            guard let first = status.stops.first else { return [] }
            stop = first
            timeMs = first.scheduledDepartureMs > 0 ? first.scheduledDepartureMs : 0
        }

        guard timeMs > 0, !stop.evaNr.isEmpty, let trainNumber = Int(status.trainNumber) else { return [] }

        let dateMillis = timeMs
        let date = Date(timeIntervalSince1970: TimeInterval(dateMillis) / 1000.0)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let dateStr = dateFormatter.string(from: date)

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        timeFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let timeStr = timeFormatter.string(from: date)

        var components = URLComponents(string: baseUrl)
        components?.queryItems = [
            URLQueryItem(name: "administrationId", value: "80"),
            URLQueryItem(name: "category", value: status.trainType),
            URLQueryItem(name: "date", value: dateStr),
            URLQueryItem(name: "evaNumber", value: stop.evaNr),
            URLQueryItem(name: "number", value: "\(trainNumber)"),
            URLQueryItem(name: "time", value: timeStr),
        ]

        guard let url = components?.url else { return [] }
        do {
            var request = URLRequest(url: url, timeoutInterval: 8)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try decoder.decode(WagenreihungResponse.self, from: data)
            return response.groups
                .flatMap { $0.vehicles }
                .filter { $0.status == "OPEN" }
                .map { vehicle in
                    Coach(
                        coachNumber: vehicle.wagonIdentificationNumber,
                        hasFirstClass: vehicle.type.hasFirstClass,
                        hasSecondClass: vehicle.type.hasEconomyClass,
                        vehicleCategory: vehicle.type.category,
                        sector: vehicle.platformPosition.sector,
                        amenities: Set(vehicle.amenities.filter { $0.status != "UNAVAILABLE" }.map { $0.type })
                    )
                }
        } catch {
            return []
        }
    }
}
