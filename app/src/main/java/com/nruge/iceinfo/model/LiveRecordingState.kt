package com.nruge.iceinfo.model

data class LiveRecordingState(
    val trainType: String,
    val trainNumber: String,
    val originStation: String,
    val destinationStation: String,
    val date: String,
    val departureTime: String,
    val startMs: Long,
    val currentSpeedKmh: Int,
    val topSpeedKmh: Int,
    val sampleCount: Int,
    val trackPointCount: Int,
    val recordGps: Boolean
)
