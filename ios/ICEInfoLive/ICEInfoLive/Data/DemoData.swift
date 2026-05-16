import Foundation

enum DemoData {
    static let trainStatus: TrainStatus = {
        let stops = [
            TrainStop(
                id: UUID(),
                station: Station(name: "Berlin Hbf", evaNr: "8011160"),
                timetable: Timetable(
                    scheduledArrival: nil,
                    actualArrival: nil,
                    scheduledDeparture: Date().addingTimeInterval(-3600),
                    actualDeparture: Date().addingTimeInterval(-3540)
                ),
                track: "14",
                passed: true,
                isCurrentStop: false,
                isNextStop: false,
                distanceFromStart: 0,
                delayMinutes: 1,
                cancelled: false,
                additionalStop: false
            ),
            TrainStop(
                id: UUID(),
                station: Station(name: "Berlin Südkreuz", evaNr: "8011113"),
                timetable: Timetable(
                    scheduledArrival: Date().addingTimeInterval(-3000),
                    actualArrival: Date().addingTimeInterval(-2940),
                    scheduledDeparture: Date().addingTimeInterval(-2880),
                    actualDeparture: Date().addingTimeInterval(-2820)
                ),
                track: "6",
                passed: true,
                isCurrentStop: false,
                isNextStop: false,
                distanceFromStart: 4500,
                delayMinutes: 1,
                cancelled: false,
                additionalStop: false
            ),
            TrainStop(
                id: UUID(),
                station: Station(name: "Lutherstadt Wittenberg", evaNr: "8011505"),
                timetable: Timetable(
                    scheduledArrival: Date().addingTimeInterval(-1200),
                    actualArrival: Date().addingTimeInterval(-1140),
                    scheduledDeparture: Date().addingTimeInterval(-1080),
                    actualDeparture: Date().addingTimeInterval(-1020)
                ),
                track: "1",
                passed: true,
                isCurrentStop: false,
                isNextStop: false,
                distanceFromStart: 89000,
                delayMinutes: 1,
                cancelled: false,
                additionalStop: false
            ),
            TrainStop(
                id: UUID(),
                station: Station(name: "Leipzig Hbf", evaNr: "8010205"),
                timetable: Timetable(
                    scheduledArrival: Date().addingTimeInterval(600),
                    actualArrival: Date().addingTimeInterval(720),
                    scheduledDeparture: Date().addingTimeInterval(780),
                    actualDeparture: Date().addingTimeInterval(900)
                ),
                track: "12",
                passed: false,
                isCurrentStop: false,
                isNextStop: true,
                distanceFromStart: 165000,
                delayMinutes: 2,
                cancelled: false,
                additionalStop: false
            ),
            TrainStop(
                id: UUID(),
                station: Station(name: "Erfurt Hbf", evaNr: "8010101"),
                timetable: Timetable(
                    scheduledArrival: Date().addingTimeInterval(2400),
                    actualArrival: Date().addingTimeInterval(2520),
                    scheduledDeparture: Date().addingTimeInterval(2580),
                    actualDeparture: Date().addingTimeInterval(2700)
                ),
                track: "4",
                passed: false,
                isCurrentStop: false,
                isNextStop: false,
                distanceFromStart: 280000,
                delayMinutes: 2,
                cancelled: false,
                additionalStop: false
            ),
            TrainStop(
                id: UUID(),
                station: Station(name: "Frankfurt(Main)Hbf", evaNr: "8000105"),
                timetable: Timetable(
                    scheduledArrival: Date().addingTimeInterval(4800),
                    actualArrival: Date().addingTimeInterval(4920),
                    scheduledDeparture: nil,
                    actualDeparture: nil
                ),
                track: "8",
                passed: false,
                isCurrentStop: false,
                isNextStop: false,
                distanceFromStart: 520000,
                delayMinutes: 2,
                cancelled: false,
                additionalStop: false
            )
        ]

        return TrainStatus(
            trainType: "ICE",
            trainNumber: " Sprinter",
            tzn: "ICE 4",
            speed: 114,
            latitude: 51.34,
            longitude: 12.37,
            wagonClass: 1,
            connectivity: .strong,
            nextStop: stops.first { $0.isNextStop },
            destination: Station(name: "Frankfurt(Main)Hbf", evaNr: "8000105"),
            stops: stops,
            delayMinutes: 2,
            delayReasons: ["Warten auf Anschlussreisende"],
            targetStopEva: stops[4].station.evaNr,
            isMockMode: true,
            totalDistance: 520000,
            distanceFromStart: 150000
        )
    }()

    static let pois: [PoiItem] = [
        PoiItem(id: UUID(), name: "Leipzig", type: "city", distance: 15000, latitude: 51.34, longitude: 12.37, description: "Großstadt in Sachsen"),
        PoiItem(id: UUID(), name: "Saale", type: "river", distance: 3200, latitude: 51.32, longitude: 12.35, description: "Fluss in Mitteldeutschland")
    ]

    static let connections: [ConnectingTrain] = [
        ConnectingTrain(
            id: UUID(),
            type: "IC",
            number: "2152",
            destination: "Dresden Hbf",
            departureTime: Date().addingTimeInterval(1200),
            track: "3",
            delayMinutes: 0,
            reachable: true,
            transferMinutes: 8
        ),
        ConnectingTrain(
            id: UUID(),
            type: "RE",
            number: "5",
            destination: "Halle(Saale)Hbf",
            departureTime: Date().addingTimeInterval(900),
            track: "2",
            delayMinutes: 3,
            reachable: true,
            transferMinutes: 5
        ),
        ConnectingTrain(
            id: UUID(),
            type: "S-Bahn",
            number: "1",
            destination: "Leipzig Miltitzer Allee",
            departureTime: Date().addingTimeInterval(300),
            track: "1",
            delayMinutes: 0,
            reachable: false,
            transferMinutes: 1
        )
    ]

    static let departures: [Departure] = [
        Departure(
            id: UUID(),
            lineName: "RE 5",
            destination: "Halle(Saale)Hbf",
            scheduledTime: Date().addingTimeInterval(600),
            delayMinutes: 0,
            platform: "2",
            cancelled: false
        ),
        Departure(
            id: UUID(),
            lineName: "S 1",
            destination: "Leipzig Miltitzer Allee",
            scheduledTime: Date().addingTimeInterval(780),
            delayMinutes: 2,
            platform: "1",
            cancelled: false
        ),
        Departure(
            id: UUID(),
            lineName: "IC 2152",
            destination: "Dresden Hbf",
            scheduledTime: Date().addingTimeInterval(1200),
            delayMinutes: 5,
            platform: "3",
            cancelled: false
        )
    ]
}
