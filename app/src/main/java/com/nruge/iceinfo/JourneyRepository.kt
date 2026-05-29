package com.nruge.iceinfo

import android.content.Context
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import com.nruge.iceinfo.model.SavedJourney
import kotlinx.coroutines.flow.first
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

private val Context.journeyDataStore by preferencesDataStore(name = "journeys")

object JourneyRepository {

    private val JOURNEYS_KEY = stringPreferencesKey("saved_journeys")
    private val json = Json { ignoreUnknownKeys = true }

    suspend fun loadJourneys(context: Context): List<SavedJourney> {
        val prefs = context.journeyDataStore.data.first()
        val raw = prefs[JOURNEYS_KEY] ?: return emptyList()
        return runCatching { json.decodeFromString<List<SavedJourney>>(raw) }
            .getOrDefault(emptyList())
    }

    suspend fun saveJourney(context: Context, journey: SavedJourney) {
        context.journeyDataStore.edit { prefs ->
            val current = runCatching {
                json.decodeFromString<List<SavedJourney>>(prefs[JOURNEYS_KEY] ?: "[]")
            }.getOrDefault(emptyList())
            prefs[JOURNEYS_KEY] = json.encodeToString(listOf(journey) + current)
        }
    }

    suspend fun deleteJourney(context: Context, id: String) {
        context.journeyDataStore.edit { prefs ->
            val current = runCatching {
                json.decodeFromString<List<SavedJourney>>(prefs[JOURNEYS_KEY] ?: "[]")
            }.getOrDefault(emptyList())
            prefs[JOURNEYS_KEY] = json.encodeToString(current.filter { it.id != id })
        }
    }
}
