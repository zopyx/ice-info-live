import Foundation
import OSLog

actor TransportRestClient {
    private let logger = Logger(subsystem: "com.nruge.iceinfo", category: "TransportRestClient")
    private let baseURL = "https://v6.db.transport.rest"

    func fetchDepartures(evaNr: String, when: Date, duration: Int = 60) async throws -> [TrDeparture] {
        let formatter = ISO8601DateFormatter()
        let whenString = formatter.string(from: when)

        var components = URLComponents(string: "\(baseURL)/stops/\(evaNr)/departures")!
        components.queryItems = [
            URLQueryItem(name: "when", value: whenString),
            URLQueryItem(name: "duration", value: "\(duration)"),
            URLQueryItem(name: "results", value: "30")
        ]

        guard let url = components.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 8
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {
                throw APIError.serverError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 0)
            }

            let decoded = try JSONDecoder().decode(DeparturesResponse.self, from: data)
            return decoded.departures ?? []
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
}
