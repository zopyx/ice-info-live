package com.nruge.iceinfo.model

import kotlinx.serialization.Serializable

@Serializable
data class SavedJourney(
    val id: String,
    val trainType: String,
    val trainNumber: String,
    val originStation: String,
    val destinationStation: String,
    val date: String,               // "23.05.2025"
    val departureTime: String,      // "14:02"
    val arrivalTime: String,        // "18:47"
    val delayMinutes: Int,
    val distanceKm: Int,
    val topSpeedKmh: Int,
    val avgSpeedKmh: Int,
    val durationMinutes: Int,
    val stopsCount: Int,
    val recordedGps: Boolean = false,
    val trackPoints: List<TrackPoint> = emptyList()
)
