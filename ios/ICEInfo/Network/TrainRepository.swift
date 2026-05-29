import Foundation

actor TrainRepository {
    static let shared = TrainRepository()

    private let hosts = ["https://iceportal.de", "http://iceportal.de"]
    private let session: URLSession
    private let decoder: JSONDecoder
    private let dateFormatter: DateFormatter

    private let pathStatus = "/api1/rs/status"
    private let pathTrip = "/api1/rs/tripInfo/trip"
    private let pathPois = "/api1/rs/pois/map"
    private let pathConn = "/api1/rs/tripInfo/connection"

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 5
        config.timeoutIntervalForResource = 5
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        session = URLSession(configuration: config)

        decoder = JSONDecoder()

        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = TimeZone.current
    }

    private func getWithFallback<T: Decodable & Sendable>(path: String) async throws -> T {
        var lastError: Error? = nil
        for host in hosts {
            guard let url = URL(string: "\(host)\(path)") else { continue }
            do {
                var request = URLRequest(url: url)
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                let (data, response) = try await session.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.noData
                }
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw APIError.httpError(httpResponse.statusCode)
                }
                return try decoder.decode(T.self, from: data)
            } catch {
                lastError = error
                continue
            }
        }
        throw lastError ?? APIError.allHostsFailed
    }

    private func getRawWithFallback(path: String) async throws -> String {
        var lastError: Error? = nil
        for host in hosts {
            guard let url = URL(string: "\(host)\(path)") else { continue }
            do {
                var request = URLRequest(url: url)
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                let (data, response) = try await session.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.noData
                }
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw APIError.httpError(httpResponse.statusCode)
                }
                return String(data: data, encoding: .utf8) ?? ""
            } catch {
                lastError = error
                continue
            }
        }
        throw lastError ?? APIError.allHostsFailed
    }

    func fetchPois(lat: Double, lon: Double, radiusDeg: Double = 0.5) async -> [PoiItem] {
        guard !(lat == 0 && lon == 0) else { return [] }
        let path = "\(pathPois)/\(lat - radiusDeg)/\(lon - radiusDeg)/\(lat + radiusDeg)/\(lon + radiusDeg)"
        do {
            let raw = try await getRawWithFallback(path: path)
            guard let data = raw.data(using: .utf8) else { return [] }

            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let poisArray = json["pois"] as? [[String: Any]] {
                let poisData = try JSONSerialization.data(withJSONObject: poisArray)
                var items = try decoder.decode([PoiItem].self, from: poisData)
                items.sort { $0.distance < $1.distance }
                return items
            } else if let poisArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                let poisData = try JSONSerialization.data(withJSONObject: poisArray)
                var items = try decoder.decode([PoiItem].self, from: poisData)
                items.sort { $0.distance < $1.distance }
                return items
            }
            return []
        } catch {
            print("POI error: \(error)")
            return []
        }
    }

    func fetchTrainStatus() async -> TrainStatus {
        do {
            async let statusResult: StatusResponse = getWithFallback(path: pathStatus)
            async let tripResult: TripResponse = getWithFallback(path: pathTrip)
            let (status, tripResponse) = try await (statusResult, tripResult)
            guard let trip = tripResponse.trip else { return disconnectedStatus() }
            return mapToTrainStatus(status: status, trip: trip)
        } catch {
            print("Status error: \(error)")
            return disconnectedStatus()
        }
    }

    func fetchDebugData() async -> (tripRaw: String, tripError: String?, connectionRaw: String, connectionError: String?, evaNr: String) {
        var tripRaw = ""
        var tripError: String? = nil
        var evaNr = ""
        do {
            tripRaw = try await getRawWithFallback(path: pathTrip)
            if let data = tripRaw.data(using: .utf8),
               let tripResponse = try? decoder.decode(TripResponse.self, from: data) {
                evaNr = tripResponse.trip?.stops.first(where: { $0.info?.passed == false })?.station?.evaNr ?? ""
            }
        } catch {
            tripError = error.localizedDescription
        }

        var connectionRaw = ""
        var connectionError: String? = nil
        if !evaNr.isEmpty {
            do {
                connectionRaw = try await getRawWithFallback(path: "\(pathConn)/\(evaNr)")
            } catch {
                connectionError = error.localizedDescription
            }
        } else {
            connectionError = "EVA number not available"
        }

        return (tripRaw, tripError, connectionRaw, connectionError, evaNr)
    }

    func fetchConnections(evaNr: String, ourArrivalMs: Int64 = 0) async -> [ConnectingTrain] {
        guard !evaNr.isEmpty else { return [] }
        do {
            let response: ConnectionResponse = try await getWithFallback(path: "\(pathConn)/\(evaNr)")
            let now = Date().timeIntervalSince1970 * 1000
            return response.connections?.map { conn in
                let scheduledMs = conn.timetable?.scheduledDepartureTime ?? 0
                let actualMs = conn.timetable?.actualDepartureTime ?? 0
                let delayMin = calculateDelayMinutes(actual: actualMs, scheduled: scheduledMs)
                let effectiveDepartureMs = actualMs > 0 ? actualMs : scheduledMs
                let reachable: Bool
                if effectiveDepartureMs <= 0 {
                    reachable = true
                } else if ourArrivalMs > 0 {
                    reachable = effectiveDepartureMs > ourArrivalMs
                } else {
                    reachable = effectiveDepartureMs > Int64(now)
                }
                let transferMinutes: Int?
                if ourArrivalMs > 0 && effectiveDepartureMs > ourArrivalMs {
                    transferMinutes = Int((effectiveDepartureMs - ourArrivalMs) / 60_000)
                } else {
                    transferMinutes = nil
                }
                return ConnectingTrain(
                    trainType: conn.trainType,
                    trainNumber: conn.vzn,
                    destination: conn.finalStation,
                    departure: formatTime(ms: scheduledMs),
                    track: conn.track?.actual ?? "",
                    delayMinutes: delayMin,
                    reachable: reachable,
                    transferMinutes: transferMinutes
                )
            } ?? []
        } catch {
            print("Connection error: \(error)")
            return []
        }
    }

    private func mapToTrainStatus(status: StatusResponse, trip: TripInfo) -> TrainStatus {
        let stops = trip.stops
        let lastStop = stops.last
        let destination = lastStop?.station?.name ?? "Unbekannt"
        let destTimetable = lastStop?.timetable
        let destScheduledMs = destTimetable?.scheduledArrivalTime ?? 0
        let destActualMs = destTimetable?.actualArrivalTime ?? 0
        let destinationEta = formatTime(ms: destScheduledMs)
        let destinationTrack = lastStop?.track?.actual ?? ""
        let destinationDelay = calculateDelayMinutes(actual: destActualMs, scheduled: destScheduledMs)
        let totalDistance = lastStop?.info?.distanceFromStart ?? 0
        let currentDistance = trip.actualPosition
        let distanceToDestination = totalDistance - currentDistance

        var nextStopName = "Unbekannt"
        var eta = "--:--"
        var delayMinutes = 0
        var track = ""
        var delayReason = ""
        var distanceToNext = 0
        var distanceLastToNext = 0
        var stopList: [TrainStop] = []
        var nextFound = false
        var nextStopEva = ""

        for (i, stop) in stops.enumerated() {
            guard let info = stop.info else { continue }
            let passed = info.passed
            let timetable = stop.timetable

            let scheduledMs = timetable?.scheduledArrivalTime ?? 0
            let actualMs = timetable?.actualArrivalTime ?? 0
            let stopDelay = calculateDelayMinutes(actual: actualMs, scheduled: scheduledMs)

            let depScheduledMs = timetable?.scheduledDepartureTime ?? 0
            let depActualMs = timetable?.actualDepartureTime ?? 0
            let depDelay = calculateDelayMinutes(actual: depActualMs, scheduled: depScheduledMs)

            let stopTrack = stop.track?.actual ?? ""
            let stopName = stop.station?.name ?? "?"

            let isNext = !passed && !nextFound
            if isNext {
                nextStopEva = stop.station?.evaNr ?? ""
                nextFound = true
                nextStopName = stopName
                eta = formatTime(ms: scheduledMs)
                delayMinutes = stopDelay
                track = stopTrack
                distanceToNext = info.distance

                let distanceFromStart = info.distanceFromStart
                distanceLastToNext = distanceFromStart - (i > 0 ? (stops[i - 1].info?.distanceFromStart ?? 0) : 0)

                delayReason = stop.delayReasons?.first?.text ?? ""
            }

            stopList.append(TrainStop(
                name: stopName,
                evaNr: stop.station?.evaNr ?? "",
                scheduledArrival: formatTime(ms: scheduledMs),
                actualArrival: formatTime(ms: actualMs),
                delayMinutes: stopDelay,
                track: stopTrack,
                passed: passed,
                isNext: isNext,
                distanceFromStart: info.distanceFromStart,
                scheduledArrivalMs: scheduledMs,
                scheduledDepartureMs: depScheduledMs,
                isAdditional: info.status == 2,
                scheduledDeparture: formatTime(ms: depScheduledMs),
                actualDeparture: formatTime(ms: depActualMs),
                departureDelayMinutes: depDelay,
                isCancelled: stop.cancelled || info.status == 3
            ))
        }

        return TrainStatus(
            trainType: trip.trainType,
            trainNumber: trip.vzn,
            speed: Int(status.speed),
            nextStop: nextStopName,
            destination: destination,
            eta: eta,
            delayMinutes: delayMinutes,
            track: track,
            delayReason: delayReason,
            distanceToNext: distanceToNext,
            distanceLastToNext: distanceLastToNext,
            nextStopEva: nextStopEva,
            stops: stopList,
            wagonClass: status.wagonClass,
            connectivity: status.connectivity?.currentState ?? "",
            nextConnectivity: status.connectivity?.nextState,
            connectivityRemainingSeconds: status.connectivity?.remainingTimeSeconds,
            tzn: status.tzn,
            series: status.series,
            latitude: status.latitude,
            longitude: status.longitude,
            distanceToDestination: distanceToDestination,
            actualPosition: trip.actualPosition,
            destinationEta: destinationEta,
            destinationTrack: destinationTrack,
            destinationDelay: destinationDelay,
            isConnected: true
        )
    }

    private func formatTime(ms: Int64) -> String {
        guard ms > 0 else { return "" }
        let date = Date(timeIntervalSince1970: TimeInterval(ms) / 1000)
        return dateFormatter.string(from: date)
    }

    private func disconnectedStatus() -> TrainStatus {
        var status = sampleTrainStatus
        status.isConnected = false
        return status
    }
}

func calculateDelayMinutes(actual: Int64, scheduled: Int64) -> Int {
    guard actual > 0 && scheduled > 0 else { return 0 }
    return Int((actual - scheduled) / 60_000)
}
