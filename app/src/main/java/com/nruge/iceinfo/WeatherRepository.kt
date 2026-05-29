package com.nruge.iceinfo

import android.util.Log
import com.nruge.iceinfo.model.WeatherInfo
import io.ktor.client.*
import io.ktor.client.call.*
import io.ktor.client.engine.okhttp.*
import io.ktor.client.plugins.*
import io.ktor.client.plugins.contentnegotiation.*
import io.ktor.client.request.*
import io.ktor.serialization.kotlinx.json.*
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json

object WeatherRepository {

    private val json = Json {
        ignoreUnknownKeys = true
        coerceInputValues = true
    }

    private val client = HttpClient(OkHttp) {
        install(ContentNegotiation) {
            json(json, contentType = io.ktor.http.ContentType.Any)
        }
        install(HttpTimeout) {
            requestTimeoutMillis = 8000
            connectTimeoutMillis = 4000
            socketTimeoutMillis = 8000
        }
        defaultRequest { header("Accept", "application/json") }
    }

    suspend fun fetchWeatherForStation(stationName: String): WeatherInfo? = withContext(Dispatchers.IO) {
        try {
            val searchName = stationName
                .replace(Regex("\\(.*?\\)"), "")
                .replace("Hbf", "")
                .replace("Bhf", "")
                .trim()

            val geo = client.get("https://geocoding-api.open-meteo.com/v1/search") {
                parameter("name", searchName)
                parameter("count", 1)
                parameter("language", "de")
                parameter("format", "json")
            }.body<GeoResponse>()

            val loc = geo.results?.firstOrNull() ?: return@withContext null

            val weather = client.get("https://api.open-meteo.com/v1/forecast") {
                parameter("latitude", loc.latitude)
                parameter("longitude", loc.longitude)
                parameter("current", "temperature_2m,precipitation,windspeed_10m,weather_code")
                parameter("timezone", "auto")
            }.body<WeatherResponse>()

            val current = weather.current ?: return@withContext null
            WeatherInfo(
                stationName = stationName,
                temperature = current.temperature,
                precipitation = current.precipitation,
                windspeed = current.windspeed,
                weatherCode = current.weatherCode
            )
        } catch (e: Exception) {
            Log.e("WeatherRepo", "fetchWeather failed for '$stationName': ${e.message}")
            null
        }
    }

    @Serializable
    private data class GeoResponse(val results: List<GeoLocation>? = null)

    @Serializable
    private data class GeoLocation(
        val latitude: Double = 0.0,
        val longitude: Double = 0.0
    )

    @Serializable
    private data class WeatherResponse(val current: CurrentWeather? = null)

    @Serializable
    private data class CurrentWeather(
        @SerialName("temperature_2m") val temperature: Double = 0.0,
        val precipitation: Double = 0.0,
        @SerialName("windspeed_10m") val windspeed: Double = 0.0,
        @SerialName("weather_code") val weatherCode: Int = 0
    )
}
