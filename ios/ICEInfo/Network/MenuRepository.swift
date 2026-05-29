import Foundation

actor MenuRepository {
    static let shared = MenuRepository()

    private let apiPath = "/bap/api/products"
    private let availabilityPath = "/bap/api/availabilities"
    private let hosts = ["https://iceportal.de", "http://iceportal.de"]

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        return d
    }()

    func fetchMenu() async -> MenuResult {
        for host in hosts {
            guard let url = URL(string: "\(host)\(apiPath)") else { continue }
            do {
                let request = URLRequest(url: url, timeoutInterval: 8)
                let (data, _) = try await URLSession.shared.data(for: request)
                let page = try decoder.decode(MenuPageResponse.self, from: data)
                let categories = page.teaserGroups
                    .filter { !$0.items.isEmpty }
                    .sorted { a, b in
                        let orderA = menuCategoryOrder.firstIndex(of: a.title) ?? Int.max
                        let orderB = menuCategoryOrder.firstIndex(of: b.title) ?? Int.max
                        return orderA < orderB
                    }
                    .map { MenuCategory(title: $0.title, items: $0.items) }
                let declarations = page.declarationGroup?.items
                    .reduce(into: [:]) { $0[$1.key] = $1.text } ?? [:]
                return MenuResult(categories: categories, declarations: declarations)
            } catch {
                continue
            }
        }
        return MenuResult(categories: [], declarations: [:])
    }

    func fetchAvailabilities() async -> [Int: Bool] {
        for host in hosts {
            guard let url = URL(string: "\(host)\(availabilityPath)") else { continue }
            do {
                let request = URLRequest(url: url, timeoutInterval: 8)
                let (data, _) = try await URLSession.shared.data(for: request)
                let items = try decoder.decode([AvailabilityItem].self, from: data)
                return items.reduce(into: [:]) { $0[$1.ecmId] = $1.visible }
            } catch {
                continue
            }
        }
        return [:]
    }

    nonisolated func applyAvailabilities(categories: [MenuCategory], availabilities: [Int: Bool]) -> [MenuCategory] {
        guard !availabilities.isEmpty else { return categories }
        return categories.map { cat in
            MenuCategory(title: cat.title, items: cat.items.map { item in
                var copy = item
                if let visible = availabilities[item.id] { copy.visible = visible }
                return copy
            })
        }
    }
}
