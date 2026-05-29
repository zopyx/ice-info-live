import Foundation

let sampleTrainStatus = TrainStatus(
    trainType: "ICE",
    trainNumber: "212",
    speed: 114,
    nextStop: "Hannover Hbf",
    destination: "München Hbf",
    eta: "09:34",
    delayMinutes: 3,
    track: "4",
    delayReason: "Kurzfristiger Personalausfall",
    distanceToNext: 86760,
    distanceLastToNext: 120000,
    nextStopEva: "8000152",
    stops: [
        TrainStop(name: "Hamburg-Altona", evaNr: "8002545",
            scheduledArrival: "", actualArrival: "", delayMinutes: 0,
            track: "12", passed: true, isNext: false, distanceFromStart: 0,
            scheduledDeparture: "08:13", actualDeparture: "08:13", departureDelayMinutes: 0),
        TrainStop(name: "Hamburg Hbf", evaNr: "8002549",
            scheduledArrival: "08:24", actualArrival: "08:27", delayMinutes: 3,
            track: "14", passed: true, isNext: false, distanceFromStart: 25000,
            scheduledDeparture: "08:26", actualDeparture: "08:29", departureDelayMinutes: 3),
        TrainStop(name: "Hannover-Linden", evaNr: "8000226",
            scheduledArrival: "09:18", actualArrival: "09:18", delayMinutes: 3,
            track: "2", passed: false, isNext: false, distanceFromStart: 140000,
            scheduledDeparture: "09:20", actualDeparture: "09:20", departureDelayMinutes: 3,
            isCancelled: true),
        TrainStop(name: "Hannover Hbf", evaNr: "8000152",
            scheduledArrival: "09:31", actualArrival: "09:34", delayMinutes: 3,
            track: "4", passed: false, isNext: true, distanceFromStart: 150000,
            scheduledDeparture: "09:33", actualDeparture: "09:36", departureDelayMinutes: 3),
        TrainStop(name: "Göttingen", evaNr: "8000128",
            scheduledArrival: "10:15", actualArrival: "10:10", delayMinutes: -5,
            track: "10", passed: false, isNext: false, distanceFromStart: 250000,
            scheduledDeparture: "10:17", actualDeparture: "10:17", departureDelayMinutes: 0),
        TrainStop(name: "Kassel-Wilhelmshöhe", evaNr: "8003197",
            scheduledArrival: "10:35", actualArrival: "10:39", delayMinutes: 4,
            track: "2", passed: false, isNext: false, distanceFromStart: 300000,
            scheduledDeparture: "10:37", actualDeparture: "10:41", departureDelayMinutes: 4),
        TrainStop(name: "Fulda", evaNr: "8000052",
            scheduledArrival: "11:12", actualArrival: "11:16", delayMinutes: 4,
            track: "3", passed: false, isNext: false, distanceFromStart: 400000, isAdditional: true,
            scheduledDeparture: "11:14", actualDeparture: "11:18", departureDelayMinutes: 4),
        TrainStop(name: "Würzburg Hbf", evaNr: "8000260",
            scheduledArrival: "11:58", actualArrival: "12:05", delayMinutes: 7,
            track: "6", passed: false, isNext: false, distanceFromStart: 500000,
            scheduledDeparture: "12:01", actualDeparture: "12:08", departureDelayMinutes: 7),
        TrainStop(name: "Nürnberg Hbf", evaNr: "8000284",
            scheduledArrival: "12:54", actualArrival: "13:06", delayMinutes: 12,
            track: "9", passed: false, isNext: false, distanceFromStart: 600000,
            scheduledDeparture: "12:57", actualDeparture: "13:09", departureDelayMinutes: 12),
        TrainStop(name: "München Hbf", evaNr: "8000261",
            scheduledArrival: "14:11", actualArrival: "14:32", delayMinutes: 21,
            track: "18", passed: false, isNext: false, distanceFromStart: 800000,
            scheduledDeparture: "", actualDeparture: "", departureDelayMinutes: 0),
    ],
    wagonClass: "FIRST",
    connectivity: "STRONG",
    nextConnectivity: "MIDDLE",
    connectivityRemainingSeconds: 600,
    tzn: "ICE0304",
    series: "408",
    latitude: 51.4825,
    longitude: 11.9906,
    distanceToDestination: 467000,
    actualPosition: 130000,
    destinationEta: "14:11",
    destinationTrack: "6",
    destinationDelay: 21
)

let sampleCoaches: [Coach] = [
    Coach(coachNumber: 21, hasFirstClass: false, hasSecondClass: true,
          vehicleCategory: "CONTROLCAR_ECONOMY_CLASS", sector: "A",
          amenities: ["BIKE_SPACE", "WHEELCHAIR_SPACE"]),
    Coach(coachNumber: 22, hasFirstClass: false, hasSecondClass: true,
          vehicleCategory: "PASSENGERCARRIAGE_ECONOMY_CLASS", sector: "A",
          amenities: ["ZONE_QUIET"]),
    Coach(coachNumber: 23, hasFirstClass: false, hasSecondClass: true,
          vehicleCategory: "PASSENGERCARRIAGE_ECONOMY_CLASS", sector: "B",
          amenities: ["ZONE_FAMILY", "CABIN_INFANT"]),
    Coach(coachNumber: 24, hasFirstClass: false, hasSecondClass: true,
          vehicleCategory: "PASSENGERCARRIAGE_ECONOMY_CLASS", sector: "B"),
    Coach(coachNumber: 25, hasFirstClass: false, hasSecondClass: true,
          vehicleCategory: "HALFDININGCAR_ECONOMY_CLASS", sector: "B"),
    Coach(coachNumber: 26, hasFirstClass: true, hasSecondClass: false,
          vehicleCategory: "PASSENGERCARRIAGE_FIRST_CLASS", sector: "C",
          amenities: ["SEATS_BAHN_COMFORT"]),
    Coach(coachNumber: 27, hasFirstClass: true, hasSecondClass: false,
          vehicleCategory: "PASSENGERCARRIAGE_FIRST_CLASS", sector: "C",
          amenities: ["SEATS_SEVERELY_DISABLED"]),
    Coach(coachNumber: 28, hasFirstClass: true, hasSecondClass: false,
          vehicleCategory: "CONTROLCAR_FIRST_CLASS", sector: "C",
          amenities: ["SEATS_BAHN_COMFORT", "ZONE_QUIET"]),
]

let samplePois: [PoiItem] = [
    PoiItem(name: "Erfurter Dom", type: "MONUMENT", distance: 2500, latitude: 51.4825, longitude: 11.9906, description: "Gotischer Dom aus dem 14. Jahrhundert"),
    PoiItem(name: "Saale", type: "RIVER", distance: 5000, latitude: 51.4825, longitude: 11.9906, description: "Nebenfluss der Elbe"),
    PoiItem(name: "Halle (Saale)", type: "CITY", distance: 8000, latitude: 51.4825, longitude: 11.9700, description: "Größte Stadt Sachsen-Anhalts"),
    PoiItem(name: "Petersberg", type: "MOUNTAIN", distance: 12000, latitude: 51.5500, longitude: 11.9500, description: "234 m hoher Tafelberg"),
    PoiItem(name: "Concordiasee", type: "LAKE", distance: 15000, latitude: 51.6000, longitude: 11.8500, description: "Ehemaliger Braunkohletagebau"),
]

let sampleConnections: [ConnectingTrain] = [
    ConnectingTrain(trainType: "ICE", trainNumber: "598", destination: "Berlin Hbf", departure: "10:24", track: "7", delayMinutes: 0, reachable: true, transferMinutes: 18),
    ConnectingTrain(trainType: "IC", trainNumber: "2045", destination: "Frankfurt (Main) Hbf", departure: "10:31", track: "3", delayMinutes: 5, reachable: true, transferMinutes: 3),
    ConnectingTrain(trainType: "RE", trainNumber: "3", destination: "Hannover Hbf", departure: "10:18", track: "12", delayMinutes: 0, reachable: false, transferMinutes: nil),
    ConnectingTrain(trainType: "ICE", trainNumber: "1077", destination: "München Hbf", departure: "10:47", track: "5", delayMinutes: 12, reachable: true, transferMinutes: 25),
    ConnectingTrain(trainType: "RB", trainNumber: "87", destination: "Bebra", departure: "10:55", track: "1", delayMinutes: 0, reachable: true, transferMinutes: nil),
]

let sampleWeather = WeatherInfo(
    stationName: "München Hbf",
    temperature: 14.0,
    precipitation: 0.0,
    windspeed: 18.0,
    weatherCode: 2
)

let sampleOsmTrackData = OsmTrackData(
    trackInfo: TrackInfo(maxSpeed: 280, electrified: "contact_line", voltage: 15000, tracks: 2, usage: "main"),
    features: [
        RailFeature(name: "Göttingen", type: .station, distanceKm: 8.3),
        RailFeature(name: "Mühlbergtunnel", type: .tunnel, distanceKm: 14.2),
        RailFeature(name: "Kassel-Wilhelmshöhe", type: .station, distanceKm: 47.8),
        RailFeature(name: "Sinntalviadukt", type: .bridge, distanceKm: 73.1),
        RailFeature(name: "Landrückentunnel", type: .tunnel, distanceKm: 78.4),
        RailFeature(name: "Fulda", type: .station, distanceKm: 91.6),
        RailFeature(name: "Würzburg Hbf", type: .station, distanceKm: 156.2),
    ]
)

let sampleDepartures: [Departure] = [
    Departure(line: "ICE 372", destination: "Basel SBB", scheduledTime: "11:08", delayMinutes: 0, platform: "9"),
    Departure(line: "RE 7", destination: "Kassel-Wilhelmshöhe", scheduledTime: "11:14", delayMinutes: 3, platform: "4"),
    Departure(line: "S 1", destination: "Hannover-Bismarckstr.", scheduledTime: "11:17", delayMinutes: 0, platform: "2"),
    Departure(line: "ICE 1075", destination: "München Hbf", scheduledTime: "11:23", delayMinutes: 12, platform: "5"),
    Departure(line: "IC 2027", destination: "Köln Hbf", scheduledTime: "11:29", delayMinutes: 0, platform: "7", cancelled: true),
    Departure(line: "RB 87", destination: "Bebra", scheduledTime: "11:36", delayMinutes: 0, platform: "1"),
    Departure(line: "ICE 884", destination: "Hamburg-Altona", scheduledTime: "11:42", delayMinutes: 5, platform: "8"),
]

let sampleJourneys: [SavedJourney] = [
    SavedJourney(id: "demo-ice212-hh-muc", trainType: "ICE", trainNumber: "212",
        originStation: "Hamburg-Altona", destinationStation: "München Hbf",
        date: "12.05.2025", departureTime: "08:13", arrivalTime: "14:32",
        delayMinutes: 21, distanceKm: 778, topSpeedKmh: 300, avgSpeedKmh: 187,
        durationMinutes: 379, stopsCount: 7, recordedGps: true,
        trackPoints: buildSampleTrackPoints()),
    SavedJourney(id: "demo-ice599-fra-ber", trainType: "ICE", trainNumber: "599",
        originStation: "Frankfurt (Main) Hbf", destinationStation: "Berlin Hbf",
        date: "28.04.2025", departureTime: "09:55", arrivalTime: "13:48",
        delayMinutes: 0, distanceKm: 546, topSpeedKmh: 280, avgSpeedKmh: 210,
        durationMinutes: 233, stopsCount: 3, recordedGps: false, trackPoints: []),
    SavedJourney(id: "demo-ice77-cgn-muc", trainType: "ICE", trainNumber: "77",
        originStation: "Köln Hbf", destinationStation: "München Hbf",
        date: "03.04.2025", departureTime: "07:02", arrivalTime: "11:58",
        delayMinutes: 34, distanceKm: 611, topSpeedKmh: 270, avgSpeedKmh: 163,
        durationMinutes: 296, stopsCount: 4, recordedGps: false, trackPoints: []),
]

func buildSampleTrackPoints() -> [TrackPoint] {
    struct Wp { let lat: Double; let lon: Double; let spd: Int; let sec: Int }
    let waypoints: [Wp] = [
        Wp(lat: 53.5677, lon: 9.9364, spd: 0, sec: 0),
        Wp(lat: 53.5532, lon: 10.0056, spd: 60, sec: 840),
        Wp(lat: 53.5532, lon: 10.0056, spd: 0, sec: 960),
        Wp(lat: 53.4562, lon: 9.9926, spd: 180, sec: 1500),
        Wp(lat: 53.3100, lon: 10.2200, spd: 250, sec: 2100),
        Wp(lat: 52.9648, lon: 10.5645, spd: 250, sec: 3100),
        Wp(lat: 52.7500, lon: 10.3200, spd: 250, sec: 3900),
        Wp(lat: 52.6206, lon: 10.0848, spd: 250, sec: 4400),
        Wp(lat: 52.3766, lon: 9.7415, spd: 100, sec: 4860),
        Wp(lat: 52.3766, lon: 9.7415, spd: 0, sec: 4980),
        Wp(lat: 52.1900, lon: 9.8200, spd: 280, sec: 5600),
        Wp(lat: 51.9700, lon: 9.8500, spd: 280, sec: 6200),
        Wp(lat: 51.7500, lon: 9.9700, spd: 280, sec: 6700),
        Wp(lat: 51.5368, lon: 9.9268, spd: 100, sec: 7020),
        Wp(lat: 51.5368, lon: 9.9268, spd: 0, sec: 7440),
        Wp(lat: 51.4200, lon: 9.7500, spd: 250, sec: 7800),
        Wp(lat: 51.3149, lon: 9.4416, spd: 100, sec: 8760),
        Wp(lat: 51.3149, lon: 9.4416, spd: 0, sec: 8880),
        Wp(lat: 51.1500, lon: 9.6200, spd: 280, sec: 9500),
        Wp(lat: 50.8680, lon: 9.7060, spd: 280, sec: 10200),
        Wp(lat: 50.6600, lon: 9.7200, spd: 280, sec: 10700),
        Wp(lat: 50.5548, lon: 9.6836, spd: 100, sec: 10980),
        Wp(lat: 50.5548, lon: 9.6836, spd: 0, sec: 11100),
        Wp(lat: 50.3700, lon: 9.8000, spd: 250, sec: 11750),
        Wp(lat: 50.1500, lon: 9.9200, spd: 250, sec: 12400),
        Wp(lat: 49.9800, lon: 9.9600, spd: 200, sec: 13100),
        Wp(lat: 49.8023, lon: 9.9358, spd: 100, sec: 13920),
        Wp(lat: 49.8023, lon: 9.9358, spd: 0, sec: 14100),
        Wp(lat: 49.6500, lon: 10.1500, spd: 160, sec: 14700),
        Wp(lat: 49.5500, lon: 10.5000, spd: 160, sec: 15400),
        Wp(lat: 49.4980, lon: 10.7500, spd: 160, sec: 16000),
        Wp(lat: 49.4454, lon: 11.0825, spd: 100, sec: 17580),
        Wp(lat: 49.4454, lon: 11.0825, spd: 0, sec: 17760),
        Wp(lat: 49.2900, lon: 11.2500, spd: 220, sec: 18450),
        Wp(lat: 49.0300, lon: 11.3500, spd: 300, sec: 19200),
        Wp(lat: 48.7600, lon: 11.4200, spd: 300, sec: 20100),
        Wp(lat: 48.5600, lon: 11.5000, spd: 280, sec: 20900),
        Wp(lat: 48.4000, lon: 11.5600, spd: 200, sec: 21700),
        Wp(lat: 48.2600, lon: 11.5500, spd: 160, sec: 22200),
        Wp(lat: 48.1402, lon: 11.5581, spd: 40, sec: 22680),
        Wp(lat: 48.1402, lon: 11.5581, spd: 0, sec: 22740),
    ]
    guard waypoints.count >= 2 else { return [] }
    var points: [TrackPoint] = []
    let totalSec = waypoints.last!.sec
    var t = 0
    let interval = 30
    while t <= totalSec {
        let idx = max(waypoints.lastIndex { $0.sec <= t } ?? 0, 0)
        let from = waypoints[idx]
        let to = idx + 1 < waypoints.count ? waypoints[idx + 1] : from
        let frac = to.sec == from.sec ? 1.0 : Double(t - from.sec) / Double(to.sec - from.sec)
        points.append(TrackPoint(
            lat: from.lat + (to.lat - from.lat) * frac,
            lon: from.lon + (to.lon - from.lon) * frac,
            speedKmh: Int(Double(from.spd) + Double(to.spd - from.spd) * frac),
            secondsFromStart: t
        ))
        t += interval
    }
    return points
}

let sampleMenuCategories: [MenuCategory] = {
    func item(id: Int, title: String, subject: String = "", imgPath: String, eurPrice: Double, decls: [String] = [], visible: Bool = true) -> MenuItem {
        MenuItem(id: id, title: title, subject: subject,
            picture: MenuPicture(src: imgPath),
            priceInfo: MenuPriceInfo(prices: [MenuPrice(currency: "EUR", value: eurPrice)]),
            declarationBox: decls.isEmpty ? nil : MenuDeclarationBox(
                productMainGroup: MenuProductGroup(
                    declarationGroups: [MenuItemDeclarationGroup(keys: decls)])),
            visible: visible)
    }
    let IMG = "img/grains/Sites/ICE-Portal/Germany/de/Release_2.0/Startseite_3.0/BaP_-_Bestellen_am_Platz/Speisekarte"
    return [
        MenuCategory(title: "Aktion", items: [
            item(id: 9000000, title: "Burger mit Beef-Bacon-Zwiebel-Chutney & Pommes", subject: "dazu Ketchup oder Mayo", imgPath: "\(IMG)/00_Aktion/2026_02-Februar/Burger__Pommes/Bild_Burger_mit_Beef-Bacon-Zwiebel-Chutney__Pommes.data.jpg", eurPrice: 14.5, decls: ["1","2","5","9"]),
            item(id: 9000001, title: "Burger", subject: "mit Beef-Bacon-Zwiebel-Chutney", imgPath: "\(IMG)/00_Aktion/2026_02-Februar/Burger/Bild_Burger.data.jpg", eurPrice: 10.9, decls: ["1","2","5","9"]),
            item(id: 9000002, title: "Orangina Original", subject: "Orangenlimonade, 0,25 l Flasche", imgPath: "\(IMG)/00_Aktion/2026_02-Februar/Orangina/Bild_Orangina_Original.data.jpg", eurPrice: 4.2),
            item(id: 9000003, title: "Peroni Nastro Azzurro", subject: "Lagerbier, 0,33 l Flasche", imgPath: "\(IMG)/00_Aktion/2026_02-Februar/Peroni_Nastro_Azzurro/Bild_Peroni_Nastro_Azzurro.data.jpg", eurPrice: 4.2),
        ]),
        MenuCategory(title: "Snacks", items: [
            item(id: 9000004, title: "Sandwich Chicken Caesar Style", subject: "mit Pulled Chicken, italienischem Hartkäse", imgPath: "\(IMG)/03_Snacks/Sandwich_Chicken_Caesar_Style/Bild_Sandwich_Chicken_Caesar_Style.data.jpg", eurPrice: 7.9),
            item(id: 9000005, title: "Pizza Mozza-Bella Deluxe", imgPath: "\(IMG)/00_Aktion/2026_02-Februar/Pizza_Mozza-Bella_Deluxe/Bild_Pizza_Mozza-Bella_Deluxe.data.jpg", eurPrice: 6.9),
            item(id: 9000028, title: "Vegane Currywurst mit BIO Brötchen", imgPath: "\(IMG)/03_Snacks/Vegane_Currywurst/Bild_Vegane_Currywurst.data.jpg", eurPrice: 7.9, visible: false),
        ]),
        MenuCategory(title: "Hauptgerichte", items: [
            item(id: 9000008, title: "Hähnchen Tikka Masala", subject: "mit Basmatireis", imgPath: "\(IMG)/01_Hauptgerichte/Haehnchen_Tikka_Masala/Bild_Haehnchen_Tikka_Masala.data.jpg", eurPrice: 14.9),
            item(id: 9000009, title: "Rotes Thai Curry mit Shiitake-Pilzen", imgPath: "\(IMG)/01_Hauptgerichte/Rotes_Thai_Curry_mit_Shiitake-Pilze/Bild_Rotes_Thai_Curry_mit_Shiitake-Pilze.data.jpg", eurPrice: 13.9, decls: ["1"]),
            item(id: 9000010, title: "Chili con Carne", imgPath: "\(IMG)/01_Hauptgerichte/Chili_con_Carne/Bild_Chili_con_Carne.data.jpg", eurPrice: 12.5, decls: ["2"]),
        ]),
        MenuCategory(title: "Heißgetränke", items: [
            item(id: 9000033, title: "Filterkaffee", imgPath: "\(IMG)/07_Heissgetraenke/Filterkaffee/Bild_Kaffee.data.jpg", eurPrice: 3.9),
            item(id: 9000034, title: "Filterkaffee mit OATLY", imgPath: "\(IMG)/07_Heissgetraenke/Filterkaffee_mit_Oatly/Bild_Filterkaffee_Oatly.data.jpg", eurPrice: 3.9),
        ]),
        MenuCategory(title: "Kaltgetränke", items: [
            item(id: 9000037, title: "share Mineralwasser sprudelnd", subject: "0,5 l Flasche", imgPath: "\(IMG)/08_Kaltgetraenke/share_Mineralwasser_sprudelnd/Bild_share_Mineralwasser_sprudelnd.data.jpg", eurPrice: 3.8),
            item(id: 9000038, title: "share Mineralwasser still", subject: "0,5 l Flasche", imgPath: "\(IMG)/08_Kaltgetraenke/share_Mineralwasser_still/Bild_share_Mineralwasser_still.data.jpg", eurPrice: 3.8),
        ]),
    ]
}()
