package com.nruge.iceinfo

import android.util.Log
import com.nruge.iceinfo.model.AvailabilityItem
import com.nruge.iceinfo.model.MenuCategory
import com.nruge.iceinfo.model.MenuDeclarationEntry
import com.nruge.iceinfo.model.MenuPageResponse
import io.ktor.client.*
import io.ktor.client.call.*
import io.ktor.client.engine.okhttp.*
import io.ktor.client.plugins.*
import io.ktor.client.plugins.contentnegotiation.*
import io.ktor.client.plugins.logging.*
import io.ktor.client.request.*
import io.ktor.serialization.kotlinx.json.*
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.json.Json

data class MenuResult(
    val categories: List<MenuCategory>,
    val declarations: Map<String, String>
)

object MenuRepository {

    private const val API_PATH = "/bap/api/products"
    private const val AVAILABILITY_PATH = "/bap/api/availabilities"
    private val hosts = listOf("https://iceportal.de", "http://iceportal.de")

    private val json = Json {
        ignoreUnknownKeys = true
        coerceInputValues = true
    }

    private val client = HttpClient(OkHttp) {
        install(ContentNegotiation) {
            json(json, contentType = io.ktor.http.ContentType.Any)
        }
        install(Logging) { level = LogLevel.INFO }
        install(HttpTimeout) {
            requestTimeoutMillis = 8000
            connectTimeoutMillis = 5000
            socketTimeoutMillis = 8000
        }
        defaultRequest { header("Accept", "application/json") }
    }

    suspend fun fetchMenu(): MenuResult = withContext(Dispatchers.IO) {
        for (host in hosts) {
            try {
                val page = client.get("$host$API_PATH").body<MenuPageResponse>()
                val order = com.nruge.iceinfo.model.MENU_CATEGORY_ORDER
                val categories = page.teaserGroups
                    .filter { it.items.isNotEmpty() }
                    .sortedBy { g -> order.indexOf(g.title).let { if (it < 0) Int.MAX_VALUE else it } }
                    .map { MenuCategory(it.title, it.items) }
                val declarations = page.declarationGroup?.items
                    ?.associate { it.key to it.text } ?: emptyMap()
                return@withContext MenuResult(categories, declarations)
            } catch (e: Exception) {
                Log.w("MenuRepo", "GET $host$API_PATH failed: ${e.message}")
            }
        }
        MenuResult(emptyList(), emptyMap())
    }

    suspend fun fetchAvailabilities(): Map<Int, Boolean> = withContext(Dispatchers.IO) {
        for (host in hosts) {
            try {
                val items = client.get("$host$AVAILABILITY_PATH").body<List<AvailabilityItem>>()
                return@withContext items.associate { it.ecmId to it.visible }
            } catch (e: Exception) {
                Log.w("MenuRepo", "GET $host$AVAILABILITY_PATH failed: ${e.message}")
            }
        }
        emptyMap()
    }
}
