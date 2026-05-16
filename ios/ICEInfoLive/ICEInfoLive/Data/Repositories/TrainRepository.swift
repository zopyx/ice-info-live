import Foundation
import OSLog

actor TrainRepository {
    private let iceClient = ICEPortalClient()
    private let logger = Logger(subsystem: "com.nruge.iceinfo", category: "TrainRepository")

    func fetchTrainStatus() async throws -> TrainStatus {
        async let statusTask = iceClient.fetchStatus()
        async let tripTask = iceClient.fetchTrip()

        let status = try await statusTask
        let trip = try await tripTask

        return mapToDomain(status: status, trip: trip)
    }

    func fetchPois(latitude: Double, longitude: Double) async -> [PoiItem] {
        let delta = 0.5
        do {
            let responses = try await iceClient.fetchPois(
                lat1: latitude - delta,
                lon1: longitude - delta,
                lat2: latitude + delta,
                lon2: longitude + delta
            )
            return responses.map { response in
                PoiItem(
                    id: UUID(),
                    name: response.name ?? "",
                    type: response.type ?? "",
                    distance: response.distance ?? 0,
                    latitude: response.latitude ?? 0,
                    longitude: response.longitude ?? 0,
                    description: response.description
                )
            }
        } catch {
            logger.error("Failed to fetch POIs: \(error.localizedDescription)")
            return []
        }
    }

    func fetchConnections(evaNr: String) async -> [ConnectingTrain] {
        do {
            let response = try await iceClient.fetchConnections(evaNr: evaNr)
            return (response.connections ?? []).compactMap { apiConn in
                guard let _ = apiConn.station,
                      let direction = apiConn.info?.direction else { return nil }

                let schedDep = apiConn.timetable?.scheduledDepartureTime.map { Date(timeIntervalSince1970: $0 / 1000) }
                let actualDep = apiConn.timetable?.actualDepartureTime.map { Date(timeIntervalSince1970: $0 / 1000) }
                let delay = calculateDelay(scheduled: schedDep, actual: actualDep)

                return ConnectingTrain(
                    id: UUID(),
                    type: apiConn.trainType ?? "",
                    number: apiConn.vzn ?? "",
                    destination: direction,
                    departureTime: actualDep ?? schedDep ?? Date(),
                    track: apiConn.track?.actual ?? apiConn.track?.scheduled,
                    delayMinutes: delay,
                    reachable: apiConn.info?.status != 2,
                    transferMinutes: 5 // Simplified; would need arrival time diff
                )
            }
        } catch {
            logger.error("Failed to fetch connections: \(error.localizedDescription)")
            return []
        }
    }

    private func mapToDomain(status: StatusResponse, trip: TripResponse) -> TrainStatus {
        let apiStops = trip.trip?.stops ?? []
        let mappedStops = apiStops.enumerated().map { index, apiStop in
            mapStop(apiStop: apiStop, index: index, total: apiStops.count, currentPosition: trip.trip?.actualPosition ?? 0)
        }

        let nextStop = mappedStops.first { $0.isNextStop }
        let destination = mappedStops.last?.station ?? Station(name: status.vzn ?? "Unknown", evaNr: "")

        let schedArrival = nextStop?.timetable.scheduledArrival
        let actualArrival = nextStop?.timetable.actualArrival
        let delay = calculateDelay(scheduled: schedArrival, actual: actualArrival)

        return TrainStatus(
            trainType: status.trainType ?? trip.trip?.trainType ?? "ICE",
            trainNumber: status.vzn ?? trip.trip?.vzn ?? "",
            tzn: status.tzn ?? "",
            speed: status.speed ?? 0,
            latitude: status.latitude ?? 0,
            longitude: status.longitude ?? 0,
            wagonClass: status.wagonClass ?? 1,
            connectivity: ConnectivityState(from: status.connectivity),
            nextStop: nextStop,
            destination: destination,
            stops: mappedStops,
            delayMinutes: delay,
            delayReasons: [],
            targetStopEva: nil,
            isMockMode: false,
            totalDistance: trip.trip?.totalDistance ?? 0,
            distanceFromStart: trip.trip?.distanceFromStart ?? 0
        )
    }

    private func mapStop(apiStop: ApiStop, index: Int, total: Int, currentPosition: Int) -> TrainStop {
        let station = Station(
            name: apiStop.station?.name ?? "",
            evaNr: apiStop.station?.evaNr ?? ""
        )

        let schedArr = apiStop.timetable?.scheduledArrivalTime.map { Date(timeIntervalSince1970: $0 / 1000) }
        let actualArr = apiStop.timetable?.actualArrivalTime.map { Date(timeIntervalSince1970: $0 / 1000) }
        let schedDep = apiStop.timetable?.scheduledDepartureTime.map { Date(timeIntervalSince1970: $0 / 1000) }
        let actualDep = apiStop.timetable?.actualDepartureTime.map { Date(timeIntervalSince1970: $0 / 1000) }

        let delay = calculateDelay(scheduled: schedArr ?? schedDep, actual: actualArr ?? actualDep)
        let position = apiStop.info?.distanceFromStart ?? 0
        let passed = apiStop.info?.passed ?? (position < currentPosition)
        let isCurrent = index == currentPosition
        let isNext = !passed && !isCurrent && index == currentPosition + 1

        return TrainStop(
            id: UUID(),
            station: station,
            timetable: Timetable(
                scheduledArrival: schedArr,
                actualArrival: actualArr,
                scheduledDeparture: schedDep,
                actualDeparture: actualDep
            ),
            track: apiStop.track?.actual ?? apiStop.track?.scheduled,
            passed: passed,
            isCurrentStop: isCurrent,
            isNextStop: isNext,
            distanceFromStart: position,
            delayMinutes: delay,
            cancelled: apiStop.info?.status == 2,
            additionalStop: apiStop.info?.status == 3
        )
    }

    private func calculateDelay(scheduled: Date?, actual: Date?) -> Int {
        guard let scheduled, let actual else { return 0 }
        let diff = actual.timeIntervalSince(scheduled)
        return max(0, Int(diff / 60))
    }

    func reset() async {
        await iceClient.resetFallback()
    }
}
