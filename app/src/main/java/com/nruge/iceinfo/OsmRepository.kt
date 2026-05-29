package com.nruge.iceinfo

import android.util.Log
import com.nruge.iceinfo.model.OsmTrackData
import com.nruge.iceinfo.model.RailFeature
import com.nruge.iceinfo.model.RailFeatureType
import com.nruge.iceinfo.model.TrackInfo
import io.ktor.client.*
import io.ktor.client.call.*
import io.ktor.client.engine.okhttp.*
import io.ktor.client.plugins.*
import io.ktor.client.plugins.contentnegotiation.*
import io.ktor.client.request.*
import io.ktor.http.*
import io.ktor.serialization.kotlinx.json.*
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import kotlin.math.*

object OsmRepository {

    private const val OVERPASS_URL = "https://overpass-api.de/api/interpreter"
    private const val LOOKAHEAD_DEG = 0.18   // ~20 km
    private const val TRACK_RADIUS_M = 200

    private val json = Json { ignoreUnknownKeys = true; coerceInputValues = true }

    private val client = HttpClient(OkHttp) {
        install(ContentNegotiation) { json(json, contentType = ContentType.Any) }
        install(HttpTimeout) {
            requestTimeoutMillis = 25_000
            connectTimeoutMillis = 5_000
            socketTimeoutMillis = 25_000
        }
    }

    suspend fun fetchTrackData(lat: Double, lon: Double): OsmTrackData = withContext(Dispatchers.IO) {
        try {
            val trackInfo = fetchTrackInfo(lat, lon)
            val features = fetchFeatures(lat, lon)
            OsmTrackData(trackInfo = trackInfo, features = features)
        } catch (e: Exception) {
            Log.e("OsmRepository", "fetchTrackData failed: ${e::class.simpleName} — ${e.message}")
            OsmTrackData(error = "Streckendaten konnten nicht geladen werden.")
        }
    }

    private suspend fun fetchTrackInfo(lat: Double, lon: Double): TrackInfo {
        val query = """
            [out:json][timeout:15];
            way(around:$TRACK_RADIUS_M,$lat,$lon)["railway"="rail"];
            out tags;
        """.trimIndent()
        return try {
            val response: OverpassResponse = client.get(OVERPASS_URL) {
                parameter("data", query)
            }.body()
            val tags = response.elements.firstOrNull()?.tags ?: return TrackInfo()
            TrackInfo(
                maxSpeed = tags["maxspeed"]?.toIntOrNull(),
                electrified = tags["electrified"],
                voltage = tags["voltage"]?.toIntOrNull(),
                tracks = tags["tracks"]?.toIntOrNull(),
                usage = tags["usage"]
            )
        } catch (e: Exception) {
            Log.e("OsmRepository", "fetchTrackInfo failed: ${e.message}")
            TrackInfo()
        }
    }

    private suspend fun fetchFeatures(lat: Double, lon: Double): List<RailFeature> {
        val south = lat - LOOKAHEAD_DEG
        val north = lat + LOOKAHEAD_DEG
        val west = lon - LOOKAHEAD_DEG
        val east = lon + LOOKAHEAD_DEG
        val bbox = "$south,$west,$north,$east"

        val query = """
            [out:json][timeout:20];
            (
              way["railway"="rail"]["tunnel"="yes"]($bbox);
              way["railway"="rail"]["bridge"="yes"]($bbox);
              node["railway"="station"]($bbox);
              node["railway"="halt"]($bbox);
            );
            out tags center;
        """.trimIndent()

        return try {
            val response: OverpassResponse = client.get(OVERPASS_URL) {
                parameter("data", query)
            }.body()

            response.elements.mapNotNull { element ->
                val elLat = element.lat ?: element.center?.lat ?: return@mapNotNull null
                val elLon = element.lon ?: element.center?.lon ?: return@mapNotNull null
                val tags = element.tags

                val type = when {
                    tags["railway"] == "station" -> RailFeatureType.STATION
                    tags["railway"] == "halt" -> RailFeatureType.HALT
                    tags["tunnel"] == "yes" -> RailFeatureType.TUNNEL
                    tags["bridge"] == "yes" -> RailFeatureType.BRIDGE
                    else -> return@mapNotNull null
                }

                val name = tags["name"] ?: tags["tunnel:name"] ?: tags["bridge:name"]

                // Skip unnamed bridges; show unnamed tunnels with generic label
                if (type == RailFeatureType.BRIDGE && name.isNullOrBlank()) return@mapNotNull null
                if ((type == RailFeatureType.STATION || type == RailFeatureType.HALT) && name.isNullOrBlank()) return@mapNotNull null

                RailFeature(
                    name = name ?: "Tunnel",
                    type = type,
                    distanceKm = haversineKm(lat, lon, elLat, elLon)
                )
            }
                .sortedBy { it.distanceKm }
                .distinctBy { it.type to it.name }
                .take(10)
        } catch (e: Exception) {
            Log.e("OsmRepository", "fetchFeatures failed: ${e.message}")
            emptyList()
        }
    }

    fun haversineKm(lat1: Double, lon1: Double, lat2: Double, lon2: Double): Double {
        val r = 6371.0
        val dLat = Math.toRadians(lat2 - lat1)
        val dLon = Math.toRadians(lon2 - lon1)
        val a = sin(dLat / 2).pow(2) +
                cos(Math.toRadians(lat1)) * cos(Math.toRadians(lat2)) * sin(dLon / 2).pow(2)
        return r * 2 * atan2(sqrt(a), sqrt(1 - a))
    }

    @Serializable
    private data class OverpassResponse(val elements: List<OverpassElement> = emptyList())

    @Serializable
    private data class OverpassElement(
        val type: String = "",
        val id: Long = 0L,
        val lat: Double? = null,
        val lon: Double? = null,
        val center: LatLon? = null,
        val tags: Map<String, String> = emptyMap()
    )

    @Serializable
    private data class LatLon(val lat: Double = 0.0, val lon: Double = 0.0)
}
