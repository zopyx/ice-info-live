package com.nruge.iceinfo.util

import java.time.LocalTime
import java.time.temporal.ChronoUnit

fun calculateDelayMinutes(actualMs: Long, scheduledMs: Long): Int =
    if (actualMs > 0 && scheduledMs > 0)
        ((actualMs - scheduledMs) / 60000L).toInt()
    else 0

fun formatRemainingTime(distanceMeters: Int, speedKmh: Int): String {
    if (speedKmh <= 0) return "--"
    val remainingMinutes = (distanceMeters / 1000f / speedKmh * 60).toInt()
    val hours = remainingMinutes / 60
    val minutes = remainingMinutes % 60
    return if (hours > 0) "${hours}h ${minutes}min" else "${minutes}min"
}

fun formatRemainingTimeUntil(scheduledArrival: String, delayMinutes: Int): String {
    if (scheduledArrival.isBlank()) return "--"
    val arrival = runCatching { LocalTime.parse(scheduledArrival) }.getOrNull() ?: return "--"
    val now = LocalTime.now()
    var diff = ChronoUnit.MINUTES.between(now, arrival).toInt() + delayMinutes
    if (diff < -60) diff += 24 * 60
    if (diff < 0) return "0min"
    val hours = diff / 60
    val minutes = diff % 60
    return if (hours > 0) "${hours}h ${minutes}min" else "${minutes}min"
}
