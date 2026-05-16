import Foundation
import OSLog

actor DepartureRepository {
    private let client = TransportRestClient()
    private let logger = Logger(subsystem: "com.nruge.iceinfo", category: "DepartureRepository")

    func fetchDepartures(evaNr: String, when: Date = Date()) async -> [Departure] {
        do {
            let responses = try await client.fetchDepartures(evaNr: evaNr, when: when)
            return responses.compactMap { tr in
                guard let lineName = tr.line?.name ?? tr.line?.productName,
                      let direction = tr.direction else { return nil }

                let formatter = ISO8601DateFormatter()
                let scheduledTime = formatter.date(from: tr.plannedWhen ?? "") ?? Date()
                let actualTime = formatter.date(from: tr.when ?? "")
                let delay = tr.delay.map { Int($0 / 60) } ?? 0

                return Departure(
                    id: UUID(),
                    lineName: lineName,
                    destination: direction,
                    scheduledTime: scheduledTime,
                    delayMinutes: delay,
                    platform: tr.platform ?? tr.plannedPlatform,
                    cancelled: tr.cancelled ?? false
                )
            }
        } catch {
            logger.error("Failed to fetch departures: \(error.localizedDescription)")
            return []
        }
    }
}
