package com.nruge.iceinfo

import com.nruge.iceinfo.model.*
import com.nruge.iceinfo.model.SavedJourney
import com.nruge.iceinfo.model.TrackPoint

val sampleTrainStatus = TrainStatus(
    distanceLastToNext = 120000,
    trainType = "ICE",
    trainNumber = "212",
    speed = 114,
    nextStop = "Göttingen",
    destination = "München Hbf",
    eta = "14:34",
    delayMinutes = 21,
    tzn = "ICE0304",
    series = "408",
    track = "4",
    delayReason = "Kurzfristiger Personalausfall",
    distanceToNext = 86760,
    wagonClass = "FIRST",
    connectivity = "STRONG",
    nextConnectivity = "MIDDLE",
    connectivityRemainingSeconds = 600,
    latitude = 51.4825,
    longitude = 11.9906,
    stops = listOf(
        // Startbahnhof — kein Delay, nur Abfahrt
        TrainStop(
            name = "Hamburg-Altona", evaNr = "8002545",
            scheduledArrival = "", actualArrival = "", delayMinutes = 0,
            track = "12", passed = true, isNext = false, distanceFromStart = 0,
            scheduledDeparture = "08:13", actualDeparture = "08:13", departureDelayMinutes = 0
        ),
        // 3 min Delay → grün
        TrainStop(
            name = "Hamburg Hbf", evaNr = "8002549",
            scheduledArrival = "08:24", actualArrival = "08:27", delayMinutes = 3,
            track = "14", passed = true, isNext = false, distanceFromStart = 25000,
            scheduledDeparture = "08:26", actualDeparture = "08:29", departureDelayMinutes = 3
        ),
        // Ausgefallener Halt
        TrainStop(
            name = "Hannover-Linden", evaNr = "8000226",
            scheduledArrival = "09:18", actualArrival = "09:18", delayMinutes = 3,
            track = "2", passed = false, isNext = false, distanceFromStart = 140000,
            scheduledDeparture = "09:20", actualDeparture = "09:20", departureDelayMinutes = 3,
            isCancelled = true
        ),
        // Nächster Halt — 3 min Delay → grün
        TrainStop(
            name = "Hannover Hbf", evaNr = "8000152",
            scheduledArrival = "09:31", actualArrival = "09:34", delayMinutes = 3,
            track = "4", passed = false, isNext = true, distanceFromStart = 150000,
            scheduledDeparture = "09:33", actualDeparture = "09:36", departureDelayMinutes = 3
        ),
        // -5 min → überpünktlich → Rainbow 🌈
        TrainStop(
            name = "Göttingen", evaNr = "8000128",
            scheduledArrival = "10:15", actualArrival = "10:10", delayMinutes = -5,
            track = "10", passed = false, isNext = false, distanceFromStart = 250000,
            scheduledDeparture = "10:17", actualDeparture = "10:17", departureDelayMinutes = 0
        ),
        // 4 min Delay → grün (Grenzfall)
        TrainStop(
            name = "Kassel-Wilhelmshöhe", evaNr = "8003197",
            scheduledArrival = "10:35", actualArrival = "10:39", delayMinutes = 4,
            track = "2", passed = false, isNext = false, distanceFromStart = 300000,
            scheduledDeparture = "10:37", actualDeparture = "10:41", departureDelayMinutes = 4
        ),
        // Zusatzhalt — 4 min Delay → grün
        TrainStop(
            name = "Fulda", evaNr = "8000052",
            scheduledArrival = "11:12", actualArrival = "11:16", delayMinutes = 4,
            track = "3", passed = false, isNext = false, distanceFromStart = 400000, isAdditional = true,
            scheduledDeparture = "11:14", actualDeparture = "11:18", departureDelayMinutes = 4
        ),
        // 7 min Delay → rot
        TrainStop(
            name = "Würzburg Hbf", evaNr = "8000260",
            scheduledArrival = "11:58", actualArrival = "12:05", delayMinutes = 7,
            track = "6", passed = false, isNext = false, distanceFromStart = 500000,
            scheduledDeparture = "12:01", actualDeparture = "12:08", departureDelayMinutes = 7
        ),
        // 12 min Delay → rot
        TrainStop(
            name = "Nürnberg Hbf", evaNr = "8000284",
            scheduledArrival = "12:54", actualArrival = "13:06", delayMinutes = 12,
            track = "9", passed = false, isNext = false, distanceFromStart = 600000,
            scheduledDeparture = "12:57", actualDeparture = "13:09", departureDelayMinutes = 12
        ),
        // Endbahnhof — 21 min Delay → rot, nur Ankunft
        TrainStop(
            name = "München Hbf", evaNr = "8000261",
            scheduledArrival = "14:11", actualArrival = "14:32", delayMinutes = 21,
            track = "18", passed = false, isNext = false, distanceFromStart = 800000,
            scheduledDeparture = "", actualDeparture = "", departureDelayMinutes = 0
        ),
    ),
    destinationEta = "14:11",
    destinationTrack = "6",
    destinationDelay = 21,
    distanceToDestination = 467000,
    actualPosition = 130000
)

val samplePois = listOf(
    PoiItem(
        name = "Erfurter Dom",
        type = "MONUMENT",
        distance = 2500,
        latitude = 51.4825,
        longitude = 11.9906,
        description = "Gotischer Dom aus dem 14. Jahrhundert"
    ),
    PoiItem(
        name = "Saale",
        type = "RIVER",
        distance = 5000,
        latitude = 51.4825,
        longitude = 11.9906,
        description = "Nebenfluss der Elbe"
    ),
    PoiItem(
        name = "Halle (Saale)",
        type = "CITY",
        distance = 8000,
        latitude = 51.4825,
        longitude = 11.9700,
        description = "Größte Stadt Sachsen-Anhalts"
    ),
    PoiItem(
        name = "Petersberg",
        type = "MOUNTAIN",
        distance = 12000,
        latitude = 51.5500,
        longitude = 11.9500,
        description = "234 m hoher Tafelberg"
    ),
    PoiItem(
        name = "Concordiasee",
        type = "LAKE",
        distance = 15000,
        latitude = 51.6000,
        longitude = 11.8500,
        description = "Ehemaliger Braunkohletagebau"
    )
)

val sampleConnections = listOf(
    ConnectingTrain(
        trainType = "ICE",
        trainNumber = "598",
        destination = "Berlin Hbf",
        departure = "10:24",
        track = "7",
        delayMinutes = 0,
        reachable = true,
        transferMinutes = 18
    ),
    ConnectingTrain(
        trainType = "IC",
        trainNumber = "2045",
        destination = "Frankfurt (Main) Hbf",
        departure = "10:31",
        track = "3",
        delayMinutes = 5,
        reachable = true,
        transferMinutes = 3
    ),
    ConnectingTrain(
        trainType = "RE",
        trainNumber = "3",
        destination = "Hannover Hbf",
        departure = "10:18",
        track = "12",
        delayMinutes = 0,
        reachable = false,
        transferMinutes = null
    ),
    ConnectingTrain(
        trainType = "ICE",
        trainNumber = "1077",
        destination = "München Hbf",
        departure = "10:47",
        track = "5",
        delayMinutes = 12,
        reachable = true,
        transferMinutes = 25
    ),
    ConnectingTrain(
        trainType = "RB",
        trainNumber = "87",
        destination = "Bebra",
        departure = "10:55",
        track = "1",
        delayMinutes = 0,
        reachable = true,
        transferMinutes = null
    )
)

val sampleWeather = WeatherInfo(
    stationName = "München Hbf",
    temperature = 14.0,
    precipitation = 0.0,
    windspeed = 18.0,
    weatherCode = 2
)

val sampleOsmTrackData = OsmTrackData(
    trackInfo = TrackInfo(
        maxSpeed = 280,
        electrified = "contact_line",
        voltage = 15000,
        tracks = 2,
        usage = "main"
    ),
    features = listOf(
        RailFeature("Göttingen", RailFeatureType.STATION, 8.3),
        RailFeature("Mühlbergtunnel", RailFeatureType.TUNNEL, 14.2),
        RailFeature("Kassel-Wilhelmshöhe", RailFeatureType.STATION, 47.8),
        RailFeature("Sinntalviadukt", RailFeatureType.BRIDGE, 73.1),
        RailFeature("Landrückentunnel", RailFeatureType.TUNNEL, 78.4),
        RailFeature("Fulda", RailFeatureType.STATION, 91.6),
        RailFeature("Würzburg Hbf", RailFeatureType.STATION, 156.2)
    )
)

val sampleDepartures = listOf(
    Departure(line = "ICE 372", destination = "Basel SBB", scheduledTime = "11:08", delayMinutes = 0, platform = "9"),
    Departure(line = "RE 7", destination = "Kassel-Wilhelmshöhe", scheduledTime = "11:14", delayMinutes = 3, platform = "4"),
    Departure(line = "S 1", destination = "Hannover-Bismarckstr.", scheduledTime = "11:17", delayMinutes = 0, platform = "2"),
    Departure(line = "ICE 1075", destination = "München Hbf", scheduledTime = "11:23", delayMinutes = 12, platform = "5"),
    Departure(line = "IC 2027", destination = "Köln Hbf", scheduledTime = "11:29", delayMinutes = 0, platform = "7", cancelled = true),
    Departure(line = "RB 87", destination = "Bebra", scheduledTime = "11:36", delayMinutes = 0, platform = "1"),
    Departure(line = "ICE 884", destination = "Hamburg-Altona", scheduledTime = "11:42", delayMinutes = 5, platform = "8")
)

// ---------------------------------------------------------------------------
// Demo-Fahrten für die Fahrten-History
// ---------------------------------------------------------------------------

/** Schlüssel-Wegpunkte entlang der Strecke Hamburg-Altona → München Hbf
 *  (NBS Hannover–Würzburg, dann Würzburg–Nürnberg–München via NBS).
 *  lat, lon, speedKmh, secondsFromStart */
private data class Wp(val lat: Double, val lon: Double, val spd: Int, val sec: Int)

private val hamburgMuenchenWaypoints = listOf(
    Wp(53.5677,  9.9364,   0,     0),   // Hamburg-Altona – dep 08:13
    Wp(53.5532, 10.0056,  60,   840),   // Hamburg Hbf – arr 08:27
    Wp(53.5532, 10.0056,   0,   960),   // Hamburg Hbf – dep 08:29
    Wp(53.4562,  9.9926, 180,  1500),   // Harburg
    Wp(53.3100, 10.2200, 250,  2100),   // Lüneburg-Süd
    Wp(52.9648, 10.5645, 250,  3100),   // Uelzen
    Wp(52.7500, 10.3200, 250,  3900),   // Lehrte
    Wp(52.6206, 10.0848, 250,  4400),   // Celle
    Wp(52.3766,  9.7415, 100,  4860),   // Hannover Hbf – arr 09:34
    Wp(52.3766,  9.7415,   0,  4980),   // Hannover Hbf – dep 09:36
    Wp(52.1900,  9.8200, 280,  5600),   // NBS Hannover-Würzburg Nordabschnitt
    Wp(51.9700,  9.8500, 280,  6200),   // NBS – Kreiensen-Bereich
    Wp(51.7500,  9.9700, 280,  6700),   // NBS – Northeim-Bereich
    Wp(51.5368,  9.9268, 100,  7020),   // Göttingen – arr 10:10
    Wp(51.5368,  9.9268,   0,  7440),   // Göttingen – dep 10:17
    Wp(51.4200,  9.7500, 250,  7800),   // NBS südlich Göttingen
    Wp(51.3149,  9.4416, 100,  8760),   // Kassel-Wilhelmshöhe – arr 10:39
    Wp(51.3149,  9.4416,   0,  8880),   // Kassel-Wilhelmshöhe – dep 10:41
    Wp(51.1500,  9.6200, 280,  9500),   // NBS – Bebraer Kurve
    Wp(50.8680,  9.7060, 280, 10200),   // NBS – Bad Hersfeld
    Wp(50.6600,  9.7200, 280, 10700),   // NBS – Lauterbach-Tunnel
    Wp(50.5548,  9.6836, 100, 10980),   // Fulda – arr 11:16
    Wp(50.5548,  9.6836,   0, 11100),   // Fulda – dep 11:18
    Wp(50.3700,  9.8000, 250, 11750),   // NBS – Schlüchterner Tunnel
    Wp(50.1500,  9.9200, 250, 12400),   // NBS – Jossa-Bereich
    Wp(49.9800,  9.9600, 200, 13100),   // Nähe Gemünden
    Wp(49.8023,  9.9358, 100, 13920),   // Würzburg Hbf – arr 12:05
    Wp(49.8023,  9.9358,   0, 14100),   // Würzburg Hbf – dep 12:08
    Wp(49.6500, 10.1500, 160, 14700),   // Nähe Kitzingen
    Wp(49.5500, 10.5000, 160, 15400),   // Nähe Neustadt/Aisch
    Wp(49.4980, 10.7500, 160, 16000),   // Nähe Ansbach-Nord
    Wp(49.4454, 11.0825, 100, 17580),   // Nürnberg Hbf – arr 13:06
    Wp(49.4454, 11.0825,   0, 17760),   // Nürnberg Hbf – dep 13:09
    Wp(49.2900, 11.2500, 220, 18450),   // NBS Nürnberg-München – Feucht
    Wp(49.0300, 11.3500, 300, 19200),   // NBS – Ingolstadt-Bereich
    Wp(48.7600, 11.4200, 300, 20100),   // NBS – Pfaffenhofen
    Wp(48.5600, 11.5000, 280, 20900),   // NBS – Freising-Nord
    Wp(48.4000, 11.5600, 200, 21700),   // Nähe Freising
    Wp(48.2600, 11.5500, 160, 22200),   // Nordeinfahrt München
    Wp(48.1402, 11.5581,  40, 22680),   // München Hbf – einfahrend
    Wp(48.1402, 11.5581,   0, 22740),   // München Hbf – arr 14:32
)

private fun buildTrackPoints(waypoints: List<Wp>, intervalSec: Int = 30): List<TrackPoint> {
    if (waypoints.size < 2) return emptyList()
    val points = mutableListOf<TrackPoint>()
    val totalSec = waypoints.last().sec
    var t = 0
    while (t <= totalSec) {
        // Finde das aktuelle Segment
        val idx = waypoints.indexOfLast { it.sec <= t }.coerceAtLeast(0)
        val from = waypoints[idx]
        val to = waypoints.getOrNull(idx + 1) ?: from
        val frac = if (to.sec == from.sec) 1.0
                   else (t - from.sec).toDouble() / (to.sec - from.sec)
        points.add(
            TrackPoint(
                lat = from.lat + (to.lat - from.lat) * frac,
                lon = from.lon + (to.lon - from.lon) * frac,
                speedKmh = (from.spd + (to.spd - from.spd) * frac).toInt(),
                secondsFromStart = t
            )
        )
        t += intervalSec
    }
    return points
}

val sampleJourneys: List<SavedJourney> = listOf(
    // Fahrt 1 – ICE 212 Hamburg → München, MIT GPS-Spur
    SavedJourney(
        id = "demo-ice212-hh-muc",
        trainType = "ICE",
        trainNumber = "212",
        originStation = "Hamburg-Altona",
        destinationStation = "München Hbf",
        date = "12.05.2025",
        departureTime = "08:13",
        arrivalTime = "14:32",
        delayMinutes = 21,
        distanceKm = 778,
        topSpeedKmh = 300,
        avgSpeedKmh = 187,
        durationMinutes = 379,
        stopsCount = 7,
        recordedGps = true,
        trackPoints = buildTrackPoints(hamburgMuenchenWaypoints, intervalSec = 30)
    ),
    // Fahrt 2 – ICE 599 Frankfurt → Berlin, OHNE GPS
    SavedJourney(
        id = "demo-ice599-fra-ber",
        trainType = "ICE",
        trainNumber = "599",
        originStation = "Frankfurt (Main) Hbf",
        destinationStation = "Berlin Hbf",
        date = "28.04.2025",
        departureTime = "09:55",
        arrivalTime = "13:48",
        delayMinutes = 0,
        distanceKm = 546,
        topSpeedKmh = 280,
        avgSpeedKmh = 210,
        durationMinutes = 233,
        stopsCount = 3,
        recordedGps = false,
        trackPoints = emptyList()
    ),
    // Fahrt 3 – ICE 77 Köln → München, OHNE GPS, stark verspätet
    SavedJourney(
        id = "demo-ice77-cgn-muc",
        trainType = "ICE",
        trainNumber = "77",
        originStation = "Köln Hbf",
        destinationStation = "München Hbf",
        date = "03.04.2025",
        departureTime = "07:02",
        arrivalTime = "11:58",
        delayMinutes = 34,
        distanceKm = 611,
        topSpeedKmh = 270,
        avgSpeedKmh = 163,
        durationMinutes = 296,
        stopsCount = 4,
        recordedGps = false,
        trackPoints = emptyList()
    )
)