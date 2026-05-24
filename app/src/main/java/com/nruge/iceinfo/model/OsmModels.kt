package com.nruge.iceinfo.model

data class TrackInfo(
    val maxSpeed: Int? = null,
    val electrified: String? = null,
    val voltage: Int? = null,
    val tracks: Int? = null,
    val usage: String? = null
)

enum class RailFeatureType { TUNNEL, BRIDGE, STATION, HALT }

data class RailFeature(
    val name: String,
    val type: RailFeatureType,
    val distanceKm: Double
)

data class OsmTrackData(
    val trackInfo: TrackInfo = TrackInfo(),
    val features: List<RailFeature> = emptyList(),
    val isLoading: Boolean = false,
    val error: String? = null
)
