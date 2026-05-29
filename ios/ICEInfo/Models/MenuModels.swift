import Foundation

struct MenuPageResponse: Codable, Sendable {
    var teaserGroups: [MenuTeaserGroup] = []
    var messages: [MenuMessage] = []
    var declarationGroup: MenuDeclarationGroup? = nil
}

struct MenuTeaserGroup: Codable, Sendable {
    var title: String = ""
    var items: [MenuItem] = []
}

struct MenuItem: Codable, Sendable, Identifiable {
    var id: Int = 0
    var title: String = ""
    var subject: String = ""
    var picture: MenuPicture? = nil
    var priceInfo: MenuPriceInfo? = nil
    var declarationBox: MenuDeclarationBox? = nil
    var visible: Bool = true

    var imageUrl: String { picture?.src ?? "" }
    var eurPrice: Double? { priceInfo?.prices.first { $0.currency == "EUR" }?.value }
    var declarationKeys: [String] {
        declarationBox?.productMainGroup?.declarationGroups.flatMap { $0.keys } ?? []
    }
}

struct MenuPicture: Codable, Sendable {
    var src: String = ""
}

struct MenuPriceInfo: Codable, Sendable {
    var prices: [MenuPrice] = []
}

struct MenuPrice: Codable, Sendable {
    var currency: String = ""
    var value: Double = 0.0
}

struct MenuDeclarationBox: Codable, Sendable {
    var productMainGroup: MenuProductGroup? = nil
}

struct MenuProductGroup: Codable, Sendable {
    var declarationGroups: [MenuItemDeclarationGroup] = []
}

struct MenuItemDeclarationGroup: Codable, Sendable {
    var keys: [String] = []
}

struct MenuDeclarationGroup: Codable, Sendable {
    var items: [MenuDeclarationEntry] = []
}

struct MenuDeclarationEntry: Codable, Sendable {
    var key: String = ""
    var text: String = ""
}

struct MenuMessage: Codable, Sendable {
    var type: String = ""
    var text: String = ""
}

struct AvailabilityItem: Codable, Sendable {
    var ecmId: Int = 0
    var status: String = ""
    var visible: Bool = true
}

struct MenuCategory: Sendable {
    var title: String
    var items: [MenuItem]
}

struct MenuResult: Sendable {
    var categories: [MenuCategory]
    var declarations: [String: String]
}

let menuCategoryOrder = [
    "Aktion", "Snacks", "Hauptgerichte", "Frühstück", "Süß & salzig",
    "Suppe", "Kindermenü", "Vegetarisch", "Vegan", "Heißgetränke",
    "Kaltgetränke", "Alkoholische Getränke"
]
