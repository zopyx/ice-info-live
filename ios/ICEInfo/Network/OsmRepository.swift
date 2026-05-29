import Foundation

actor OsmRepository {
    static let shared = OsmRepository()

    private let overpassUrl = "https://overpass-api.de/api/interpreter"
    private let lookaheadDeg = 0.18
    private let trackRadiusM = 200

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        return d
    }()

    func fetchTrackData(lat: Double, lon: Double) async -> OsmTrackData {
        guard lat != 0 || lon != 0 else { return OsmTrackData(error: nil) }
        do {
            async let trackInfo = fetchTrackInfo(lat: lat, lon: lon)
            async let features = fetchFeatures(lat: lat, lon: lon)
            return try await OsmTrackData(trackInfo: trackInfo, features: features)
        } catch {
            return OsmTrackData(error: "Streckendaten konnten nicht geladen werden.")
        }
    }

    private func fetchTrackInfo(lat: Double, lon: Double) async -> TrackInfo {
        let query = "[out:json][timeout:15];way(around:\(trackRadiusM),\(lat),\(lon))[\"railway\"=\"rail\"];out tags;"
        guard let url = URL(string: overpassUrl) else { return TrackInfo() }
        var request = URLRequest(url: url, timeoutInterval: 20)
        request.httpMethod = "POST"
        request.httpBody = "data=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query)".data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try decoder.decode(OverpassResponse.self, from: data)
            guard let tags = response.elements.first?.tags else { return TrackInfo() }
            return TrackInfo(
                maxSpeed: Int(tags["maxspeed"] ?? ""),
                electrified: tags["electrified"],
                voltage: Int(tags["voltage"] ?? ""),
                tracks: Int(tags["tracks"] ?? ""),
                usage: tags["usage"]
            )
        } catch {
            return TrackInfo()
        }
    }

    private func fetchFeatures(lat: Double, lon: Double) async -> [RailFeature] {
        let south = lat - lookaheadDeg
        let north = lat + lookaheadDeg
        let west = lon - lookaheadDeg
        let east = lon + lookaheadDeg
        let bbox = "\(south),\(west),\(north),\(east)"

        let query = "[out:json][timeout:20];(way[\"railway\"=\"rail\"][\"tunnel\"=\"yes\"](\(bbox));way[\"railway\"=\"rail\"][\"bridge\"=\"yes\"](\(bbox));node[\"railway\"=\"station\"](\(bbox));node[\"railway\"=\"halt\"](\(bbox)););out tags center;"

        guard let url = URL(string: overpassUrl) else { return [] }
        var request = URLRequest(url: url, timeoutInterval: 25)
        request.httpMethod = "POST"
        request.httpBody = "data=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query)".data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try decoder.decode(OverpassResponse.self, from: data)
            return response.elements.compactMap { element -> RailFeature? in
                let elLat = element.lat ?? element.center?.lat ?? 0
                let elLon = element.lon ?? element.center?.lon ?? 0
                guard elLat != 0, elLon != 0 else { return nil }
                let tags = element.tags

                let type: RailFeatureType
                if tags["railway"] == "station" { type = .station }
                else if tags["railway"] == "halt" { type = .halt }
                else if tags["tunnel"] == "yes" { type = .tunnel }
                else if tags["bridge"] == "yes" { type = .bridge }
                else { return nil }

                let name = tags["name"] ?? tags["tunnel:name"] ?? tags["bridge:name"]
                if (type == .bridge || type == .station || type == .halt) && (name == nil || name!.isEmpty) { return nil }

                return RailFeature(
                    name: name ?? "Tunnel",
                    type: type,
                    distanceKm: haversineKm(lat1: lat, lon1: lon, lat2: elLat, lon2: elLon)
                )
            }
            .sorted { $0.distanceKm < $1.distanceKm }
            .reduce([]) { acc, feature in
                if acc.contains(where: { $0.type == feature.type && $0.name == feature.name }) { return acc }
                return acc + [feature]
            }
            .prefix(10)
            .map { $0 }
        } catch {
            return []
        }
    }

    private func haversineKm(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let r = 6371.0
        let dLat = (lat2 - lat1) * .pi / 180
        let dLon = (lon2 - lon1) * .pi / 180
        let a = sin(dLat / 2) * sin(dLat / 2) +
                cos(lat1 * .pi / 180) * cos(lat2 * .pi / 180) * sin(dLon / 2) * sin(dLon / 2)
        return r * 2 * atan2(sqrt(a), sqrt(1 - a))
    }
}
