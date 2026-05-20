package com.nruge.iceinfo.util

import com.nruge.iceinfo.R

// Derived from assets/ice_series.json
private data class SeriesInfo(val bezeichnung: String, val vmaxKmh: Int)

private val SERIES_MAP: Map<String, SeriesInfo> = mapOf(
    "401" to SeriesInfo("ICE 1",            280),
    "402" to SeriesInfo("ICE 2",            280),
    "403" to SeriesInfo("ICE 3",            300),
    "406" to SeriesInfo("ICE 3M",           300),
    "407" to SeriesInfo("ICE 3 Velaro D",   320),
    "408" to SeriesInfo("ICE 3neo",         320),
    "411" to SeriesInfo("ICE T",            230),
    "412" to SeriesInfo("ICE 4",            265),
    "415" to SeriesInfo("ICE T (5-teilig)", 230)
)

@Suppress("UNUSED_PARAMETER")
fun getIceDrawable(tzn: String): Int = R.drawable.ice

fun getIceClassFromSeries(series: String): String = SERIES_MAP[series]?.bezeichnung ?: ""

fun getIceVmax(series: String): Int? = SERIES_MAP[series]?.vmaxKmh
