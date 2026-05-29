import Foundation

actor StationFacilitiesRepository {
    static let shared = StationFacilitiesRepository()

    private let stadaBase = "https://apis.deutschebahn.com/db-api-marketplace/apis/station-data/v2"
    private let fastaBase = "https://apis.deutschebahn.com/db-api-marketplace/apis/fasta/v2"

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        return d
    }()

    func searchStations(query: String) async -> [StationSearchResult] {
        guard query.count >= 4 else { return [] }
        guard let url = URL(string: "\(stadaBase)/stations?searchstring=\(query)*&limit=10"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else { return [] }
        do {
            var request = URLRequest(url: url, timeoutInterval: 10)
            request.setValue(BuildConfig.dbClientId, forHTTPHeaderField: "DB-Client-ID")
            request.setValue(BuildConfig.dbApiKey, forHTTPHeaderField: "DB-Api-Key")
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { return [] }
            let stada = try decoder.decode(StadaResponse.self, from: data)
            return stada.result.compactMap { station in
                guard let name = station.name, let eva = station.evaNumbers.first?.number else { return nil }
                return StationSearchResult(evaNr: "\(eva)", name: name)
            }
        } catch {
            return []
        }
    }

    func fetchFacilities(evaNr: String, stationName: String) async -> StationInfo {
        do {
            async let stadaResult = fetchStada(evaNr: evaNr)
            let result = await stadaResult
            let liveFacilities: [StationFacility]
            if let stationNumber = result?.stationNumber {
                liveFacilities = await fetchFasta(stationNumber: stationNumber)
            } else {
                liveFacilities = []
            }
            return StationInfo(
                evaNr: evaNr,
                name: stationName,
                liveFacilities: liveFacilities,
                staticFacilities: result?.toStaticFacilityTypes() ?? [],
                isLoading: false
            )
        }
    }

    private func fetchStada(evaNr: String) async -> StadaStation? {
        guard let url = URL(string: "\(stadaBase)/stations?eva=\(evaNr)&limit=1") else { return nil }
        do {
            var request = URLRequest(url: url, timeoutInterval: 10)
            request.setValue(BuildConfig.dbClientId, forHTTPHeaderField: "DB-Client-ID")
            request.setValue(BuildConfig.dbApiKey, forHTTPHeaderField: "DB-Api-Key")
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { return nil }
            let stada = try decoder.decode(StadaResponse.self, from: data)
            return stada.result.first
        } catch {
            return nil
        }
    }

    private func fetchFasta(stationNumber: Int) async -> [StationFacility] {
        guard let url = URL(string: "\(fastaBase)/facilities?stationnumber=\(stationNumber)&type=ELEVATOR,ESCALATOR") else { return [] }
        do {
            var request = URLRequest(url: url, timeoutInterval: 10)
            request.setValue(BuildConfig.dbClientId, forHTTPHeaderField: "DB-Client-ID")
            request.setValue(BuildConfig.dbApiKey, forHTTPHeaderField: "DB-Api-Key")
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { return [] }
            let facilities = try decoder.decode([FastaFacility].self, from: data)
            return facilities.map { fac in
                StationFacility(
                    id: "\(fac.equipmentnumber)",
                    type: (fac.type?.uppercased() == "ESCALATOR") ? .escalator : .elevator,
                    label: fac.description ?? fac.type?.lowercased().prefix(1).uppercased() ?? "Anlage",
                    status: fac.state?.uppercased() == "ACTIVE" ? .active :
                            fac.state?.uppercased() == "INACTIVE" ? .inactive : .unknown,
                    description: fac.stateExplanation ?? ""
                )
            }
        } catch {
            return []
        }
    }
}

private extension StadaStation {
    func toStaticFacilityTypes() -> [FacilityType] {
        var types: [FacilityType] = []
        if hasPublicFacilities == true { types.append(.toilet) }
        if hasWiFi == true { types.append(.wifi) }
        if let svc = hasMobilityService, svc != "no" { types.append(.infoDesk) }
        if hasLockerSystem == true { types.append(.waitingRoom) }
        if hasBicycleParking == true { types.append(.bikeParking) }
        if hasParking == true { types.append(.parking) }
        return types
    }
}
