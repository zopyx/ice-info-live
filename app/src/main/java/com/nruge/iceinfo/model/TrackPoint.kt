package com.nruge.iceinfo.model

import kotlinx.serialization.Serializable

@Serializable
data class TrackPoint(
    val lat: Double,
    val lon: Double,
    val speedKmh: Int,
    val secondsFromStart: Int
)
