import Foundation
import OSLog

actor ICEPortalClient {
    private var useHTTPFallback = false
    private let logger = Logger(subsystem: "com.nruge.iceinfo", category: "ICEPortalClient")

    private func makeRequest(path: String) async throws -> Data {
        let scheme = useHTTPFallback ? "http" : "https"
        guard let url = URL(string: "\(scheme)://iceportal.de\(path)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.noData
            }
            if (200..<300).contains(httpResponse.statusCode) {
                return data
            } else if httpResponse.statusCode >= 500 {
                throw APIError.serverError(statusCode: httpResponse.statusCode)
            } else {
                throw APIError.unknown
            }
        } catch let error as APIError {
            throw error
        } catch {
            if !useHTTPFallback {
                logger.warning("HTTPS failed, trying HTTP fallback: \(error.localizedDescription)")
                useHTTPFallback = true
                return try await makeRequest(path: path)
            }
            throw APIError.networkError(error)
        }
    }

    func fetchStatus() async throws -> StatusResponse {
        let data = try await makeRequest(path: "/api1/rs/status")
        do {
            return try JSONDecoder().decode(StatusResponse.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }

    func fetchTrip() async throws -> TripResponse {
        let data = try await makeRequest(path: "/api1/rs/tripInfo/trip")
        do {
            return try JSONDecoder().decode(TripResponse.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }

    func fetchPois(lat1: Double, lon1: Double, lat2: Double, lon2: Double) async throws -> [PoiItemResponse] {
        let path = "/api1/rs/pois/map/\(lat1)/\(lon1)/\(lat2)/\(lon2)"
        let data = try await makeRequest(path: path)

        // Some firmware returns object, some array
        if let response = try? JSONDecoder().decode(PoiResponse.self, from: data),
           let pois = response.pois {
            return pois
        }

        if let array = try? JSONDecoder().decode([PoiItemResponse].self, from: data) {
            return array
        }

        return []
    }

    func fetchConnections(evaNr: String) async throws -> ConnectionResponse {
        let data = try await makeRequest(path: "/api1/rs/tripInfo/connection/\(evaNr)")
        do {
            return try JSONDecoder().decode(ConnectionResponse.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }

    func resetFallback() {
        useHTTPFallback = false
    }
}
