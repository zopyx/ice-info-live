package com.nruge.iceinfo

import com.nruge.iceinfo.model.*

val sampleTrainStatus = TrainStatus(
    distanceLastToNext = 120000,
    trainType = "ICE",
    trainNumber = "212",
    speed = 114,
    nextStop = "Göttingen",
    destination = "München Hbf",
    eta = "14:34",
    delayMinutes = 21,
    tzn = "ICE0701",
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
        // 0 min Delay — pünktlich, kein Highlight
        TrainStop(
            name = "Göttingen", evaNr = "8000128",
            scheduledArrival = "10:15", actualArrival = "10:15", delayMinutes = 0,
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
    actualPosition = 180000
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

val sampleDepartures = listOf(
    Departure(line = "ICE 372", destination = "Basel SBB", scheduledTime = "11:08", delayMinutes = 0, platform = "9"),
    Departure(line = "RE 7", destination = "Kassel-Wilhelmshöhe", scheduledTime = "11:14", delayMinutes = 3, platform = "4"),
    Departure(line = "S 1", destination = "Hannover-Bismarckstr.", scheduledTime = "11:17", delayMinutes = 0, platform = "2"),
    Departure(line = "ICE 1075", destination = "München Hbf", scheduledTime = "11:23", delayMinutes = 12, platform = "5"),
    Departure(line = "IC 2027", destination = "Köln Hbf", scheduledTime = "11:29", delayMinutes = 0, platform = "7", cancelled = true),
    Departure(line = "RB 87", destination = "Bebra", scheduledTime = "11:36", delayMinutes = 0, platform = "1"),
    Departure(line = "ICE 884", destination = "Hamburg-Altona", scheduledTime = "11:42", delayMinutes = 5, platform = "8")
)