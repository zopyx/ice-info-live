import Foundation

struct GpxExporter {
    static func generateGpx(journey: SavedJourney) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let isoFormatter = ISO8601DateFormatter()

        var departureDate: Date? = nil
        if let date = dateFormatter.date(from: journey.date),
           let time = timeFormatter.date(from: journey.departureTime) {
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day], from: date)
            let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
            components.hour = timeComponents.hour
            components.minute = timeComponents.minute
            departureDate = calendar.date(from: components)
        }

        var gpx = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        gpx += "<gpx version=\"1.1\" creator=\"ICE Info\" xmlns=\"http://www.topografix.com/GPX/1/1\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd\">\n"
        gpx += "  <metadata>\n"
        gpx += "    <name>\(journey.trainType) \(journey.trainNumber) · \(journey.originStation) → \(journey.destinationStation)</name>\n"
        if let dep = departureDate {
            gpx += "    <time>\(isoFormatter.string(from: dep))</time>\n"
        }
        gpx += "  </metadata>\n"
        gpx += "  <trk>\n"
        gpx += "    <name>\(journey.trainType) \(journey.trainNumber) · \(journey.date)</name>\n"
        gpx += "    <trkseg>\n"

        for point in journey.trackPoints {
            let timestamp = departureDate.flatMap { dep in
                Calendar.current.date(byAdding: .second, value: point.secondsFromStart, to: dep)
            }.map { isoFormatter.string(from: $0) } ?? ""

            gpx += "      <trkpt lat=\"\(point.lat)\" lon=\"\(point.lon)\">\n"
            if !timestamp.isEmpty {
                gpx += "        <time>\(timestamp)</time>\n"
            }
            gpx += "        <extensions><speed>\(point.speedKmh)</speed></extensions>\n"
            gpx += "      </trkpt>\n"
        }

        gpx += "    </trkseg>\n"
        gpx += "  </trk>\n"
        gpx += "</gpx>\n"
        return gpx
    }
}
