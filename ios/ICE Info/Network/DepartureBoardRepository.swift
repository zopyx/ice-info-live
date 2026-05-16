import Foundation

actor DepartureBoardRepository {
    static let shared = DepartureBoardRepository()

    private let baseURL = "https://v6.db.transport.rest"
    private let session: URLSession
    private let decoder: JSONDecoder
    private let dateFormatter: DateFormatter

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 8
        config.timeoutIntervalForResource = 8
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        session = URLSession(configuration: config)

        decoder = JSONDecoder()

        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = TimeZone.current
    }

    func fetchDepartures(evaNr: String, arrivalMs: Int64) async -> [Departure] {
        guard !evaNr.isEmpty, arrivalMs > 0 else { return [] }

        let arrivalDate = Date(timeIntervalSince1970: TimeInterval(arrivalMs) / 1000)
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let whenString = isoFormatter.string(from: arrivalDate)

        let queryItems = [
            URLQueryItem(name: "when", value: whenString),
            URLQueryItem(name: "duration", value: "90"),
            URLQueryItem(name: "results", value: "30")
        ]

        guard var components = URLComponents(string: "\(baseURL)/stops/\(evaNr)/departures") else {
            return []
        }
        components.queryItems = queryItems

        guard let url = components.url else { return [] }

        do {
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                return []
            }

            let rawDepartures = try decoder.decode([RawDeparture].self, from: data)
            return rawDepartures.map { raw in
                let scheduledTime = formatTime(isoString: raw.whenScheduled)
                let delayMin = (raw.delay ?? 0) / 60
                let platform = raw.platform ?? ""
                return Departure(
                    line: raw.line.name,
                    destination: raw.destination.name,
                    scheduledTime: scheduledTime,
                    delayMinutes: delayMin,
                    platform: platform,
                    cancelled: raw.cancelled ?? false
                )
            }
        } catch {
            print("Departure board error: \(error)")
            return []
        }
    }

    private func formatTime(isoString: String?) -> String {
        guard let isoString, !isoString.isEmpty else { return "" }
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = isoFormatter.date(from: isoString) else {
            let fallback = ISO8601DateFormatter()
            fallback.formatOptions = [.withInternetDateTime]
            guard let date = fallback.date(from: isoString) else { return "" }
            return dateFormatter.string(from: date)
        }
        return dateFormatter.string(from: date)
    }
}

private struct RawDeparture: Decodable {
    let line: RawLine
    let destination: RawDestination
    let whenScheduled: String?
    let delay: Int?
    let platform: String?
    let cancelled: Bool?

    enum CodingKeys: String, CodingKey {
        case line, destination, delay, platform, cancelled, when
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        line = try container.decode(RawLine.self, forKey: .line)
        destination = try container.decode(RawDestination.self, forKey: .destination)

        let whenRaw = try container.decodeIfPresent(RawWhen.self, forKey: .when)
        whenScheduled = whenRaw?.scheduled

        delay = try container.decodeIfPresent(Int.self, forKey: .delay)
        platform = try container.decodeIfPresent(String.self, forKey: .platform)
        cancelled = try container.decodeIfPresent(Bool.self, forKey: .cancelled)
    }
}

private struct RawWhen: Codable {
    let scheduled: String?
}

private struct RawLine: Codable {
    let name: String
}

private struct RawDestination: Codable {
    let name: String
}
