import Foundation

actor JourneyRepository {
    static let shared = JourneyRepository()

    private let defaults = UserDefaults.standard
    private let journeysKey = "saved_journeys"

    func loadJourneys() -> [SavedJourney] {
        guard let data = defaults.data(forKey: journeysKey) else { return sampleJourneys }
        let journeys = (try? JSONDecoder().decode([SavedJourney].self, from: data)) ?? []
        return journeys.isEmpty ? sampleJourneys : journeys
    }

    func saveJourney(_ journey: SavedJourney) {
        var current = loadJourneys()
        current.insert(journey, at: 0)
        if let data = try? JSONEncoder().encode(current) {
            defaults.set(data, forKey: journeysKey)
        }
    }

    func deleteJourney(id: String) {
        var current = loadJourneys()
        current.removeAll { $0.id == id }
        if let data = try? JSONEncoder().encode(current) {
            defaults.set(data, forKey: journeysKey)
        }
    }
}
