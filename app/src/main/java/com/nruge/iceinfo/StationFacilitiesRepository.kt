package com.nruge.iceinfo

import android.util.Log
import com.nruge.iceinfo.model.*
import io.ktor.client.*
import io.ktor.client.call.*
import io.ktor.client.engine.okhttp.*
import io.ktor.client.plugins.*
import io.ktor.client.plugins.contentnegotiation.*
import io.ktor.client.request.*
import io.ktor.client.statement.*
import io.ktor.http.*
import io.ktor.serialization.kotlinx.json.*
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json

object StationFacilitiesRepository {

    private const val STADA_BASE  = "https://apis.deutschebahn.com/db-api-marketplace/apis/station-data/v2"
    private const val FASTA_BASE  = "https://apis.deutschebahn.com/db-api-marketplace/apis/fasta/v2"

    private val json = Json {
        ignoreUnknownKeys = true
        coerceInputValues = true
    }

    private val client = HttpClient(OkHttp) {
        install(ContentNegotiation) {
            json(json, contentType = ContentType.Any)
        }
        install(HttpTimeout) {
            requestTimeoutMillis = 10_000
            connectTimeoutMillis = 5_000
            socketTimeoutMillis = 10_000
        }
        defaultRequest {
            header("Accept", "application/json")
        }
    }

    // ── Station search via StaDa ─────────────────────────────────────────────

    suspend fun searchStations(query: String): List<StationSearchResult> = withContext(Dispatchers.IO) {
        if (query.length < 4) return@withContext emptyList()
        try {
            val httpResponse = client.get("$STADA_BASE/stations") {
                header("DB-Client-ID", BuildConfig.DB_CLIENT_ID)
                header("DB-Api-Key", BuildConfig.DB_CLIENT_SECRET)
                parameter("searchstring", "$query*")
                parameter("limit", 10)
            }
            if (!httpResponse.status.isSuccess()) return@withContext emptyList()
            val response: StadaResponse = httpResponse.body()
            response.result.mapNotNull { station ->
                val name = station.name ?: return@mapNotNull null
                val eva  = station.evaNumbers.firstOrNull()?.number ?: return@mapNotNull null
                StationSearchResult(evaNr = eva.toString(), name = name)
            }
        } catch (e: Exception) {
            Log.e("StationFacilities", "searchStations failed: ${e::class.simpleName} — ${e.message}")
            emptyList()
        }
    }

    // ── Facilities: StaDa (static) + FaSta (live) ───────────────────────────

    suspend fun fetchFacilities(evaNr: String, stationName: String): StationInfo = withContext(Dispatchers.IO) {
        try {
            // 1. StaDa: EVA → DB station number + static features
            val stadaResult = fetchStada(evaNr)

            // 2. FaSta: live elevator/escalator status (needs DB station number)
            val liveFacilities = stadaResult?.stationNumber
                ?.let { fetchFasta(it) }
                ?: emptyList()

            StationInfo(
                evaNr = evaNr,
                name = stationName,
                liveFacilities = liveFacilities,
                staticFacilities = stadaResult?.toStaticFacilityTypes() ?: emptyList()
            )
        } catch (e: Exception) {
            Log.e("StationFacilities", "fetchFacilities failed: ${e::class.simpleName} — ${e.message}")
            StationInfo(evaNr = evaNr, name = stationName, error = "Daten konnten nicht geladen werden.")
        }
    }

    // ── StaDa ────────────────────────────────────────────────────────────────

    private suspend fun fetchStada(evaNr: String): StadaStation? {
        return try {
            val httpResponse = client.get("$STADA_BASE/stations") {
                header("DB-Client-ID", BuildConfig.DB_CLIENT_ID)
                header("DB-Api-Key", BuildConfig.DB_CLIENT_SECRET)
                parameter("eva", evaNr.toLongOrNull() ?: evaNr)
                parameter("limit", 1)
            }
            if (!httpResponse.status.isSuccess()) {
                Log.e("StationFacilities", "StaDa HTTP ${httpResponse.status} for EVA $evaNr — ${httpResponse.bodyAsText()}")
                return null
            }
            val response: StadaResponse = httpResponse.body()
            Log.d("StationFacilities", "StaDa returned ${response.result.size} station(s) for EVA $evaNr")
            response.result.firstOrNull()
        } catch (e: Exception) {
            Log.e("StationFacilities", "StaDa exception for EVA $evaNr: ${e::class.simpleName} — ${e.message}")
            null
        }
    }

    private fun StadaStation.toStaticFacilityTypes(): List<FacilityType> = buildList {
        if (hasPublicFacilities == true)                    add(FacilityType.TOILET)
        if (hasWiFi == true)                               add(FacilityType.WIFI)
        if (hasMobilityService != null
            && hasMobilityService != "no")                 add(FacilityType.INFO_DESK)
        if (hasLockerSystem == true)                       add(FacilityType.WAITING_ROOM)
        if (hasBicycleParking == true)                     add(FacilityType.BIKE_PARKING)
        if (hasParking == true)                            add(FacilityType.PARKING)
    }

    // ── FaSta ────────────────────────────────────────────────────────────────

    private suspend fun fetchFasta(stationNumber: Int): List<StationFacility> {
        return try {
            val httpResponse = client.get("$FASTA_BASE/facilities") {
                header("DB-Client-ID", BuildConfig.DB_CLIENT_ID)
                header("DB-Api-Key", BuildConfig.DB_CLIENT_SECRET)
                parameter("stationnumber", stationNumber)
                parameter("type", "ELEVATOR,ESCALATOR")
            }
            if (!httpResponse.status.isSuccess()) {
                Log.e("StationFacilities", "FaSta HTTP ${httpResponse.status} for station $stationNumber — ${httpResponse.bodyAsText()}")
                return emptyList()
            }
            val facilities: List<FastaFacility> = httpResponse.body()
            Log.d("StationFacilities", "FaSta returned ${facilities.size} facilities for station $stationNumber")
            facilities.map { it.toStationFacility() }
        } catch (e: Exception) {
            Log.e("StationFacilities", "FaSta exception for station $stationNumber: ${e::class.simpleName} — ${e.message}")
            emptyList()
        }
    }

    private fun FastaFacility.toStationFacility() = StationFacility(
        id = equipmentNumber.toString(),
        type = when (type?.uppercase()) {
            "ELEVATOR"  -> FacilityType.ELEVATOR
            "ESCALATOR" -> FacilityType.ESCALATOR
            else        -> FacilityType.ELEVATOR
        },
        label = description.orEmpty().ifBlank { type?.lowercase()?.replaceFirstChar { it.uppercase() } ?: "Anlage" },
        status = when (state?.uppercase()) {
            "ACTIVE"   -> FacilityStatus.ACTIVE
            "INACTIVE" -> FacilityStatus.INACTIVE
            else       -> FacilityStatus.UNKNOWN
        },
        description = stateExplanation.orEmpty()
    )

    // ── Response models ──────────────────────────────────────────────────────

    @Serializable
    private data class StadaResponse(
        val result: List<StadaStation> = emptyList(),
        val total: Int = 0
    )

    @Serializable
    private data class StadaStation(
        val number: Int? = null,
        val name: String? = null,
        val evaNumbers: List<EvaNumber> = emptyList(),
        val hasWiFi: Boolean? = null,
        val hasPublicFacilities: Boolean? = null,
        val hasBicycleParking: Boolean? = null,
        val hasLockerSystem: Boolean? = null,
        val hasMobilityService: String? = null,
        val hasParking: Boolean? = null,
        val hasLostAndFound: Boolean? = null,
    ) {
        val stationNumber: Int? get() = number
    }

    @Serializable
    private data class EvaNumber(
        val number: Long? = null,
        val isMain: Boolean? = null
    )

    @Serializable
    private data class FastaFacility(
        @SerialName("equipmentnumber") val equipmentNumber: Long = 0L,
        val type: String? = null,
        val state: String? = null,
        val stateExplanation: String? = null,
        val description: String? = null,
        @SerialName("stationnumber") val stationNumber: Int? = null,
    )
}
