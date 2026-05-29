package com.nruge.iceinfo.ui

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.nruge.iceinfo.DepartureBoardRepository
import com.nruge.iceinfo.JourneyRepository
import com.nruge.iceinfo.MenuRepository
import com.nruge.iceinfo.OsmRepository
import com.nruge.iceinfo.StationFacilitiesRepository
import com.nruge.iceinfo.TrainRepository
import com.nruge.iceinfo.WeatherRepository
import com.nruge.iceinfo.model.*
import com.nruge.iceinfo.sampleConnections
import com.nruge.iceinfo.sampleDepartures
import com.nruge.iceinfo.sampleJourneys
import com.nruge.iceinfo.sampleCoaches
import com.nruge.iceinfo.sampleMenuCategories
import com.nruge.iceinfo.sampleOsmTrackData
import com.nruge.iceinfo.samplePois
import com.nruge.iceinfo.sampleTrainStatus
import com.nruge.iceinfo.sampleWeather
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import com.nruge.iceinfo.model.ConnectingTrain
import com.nruge.iceinfo.model.LiveRecordingState
import com.nruge.iceinfo.model.SavedJourney
import com.nruge.iceinfo.model.TrackPoint
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import java.util.UUID
import com.nruge.iceinfo.util.SettingsManager
import com.nruge.iceinfo.widget.WidgetUpdater
import com.nruge.iceinfo.WagenreihungRepository

class MainViewModel(application: Application) : AndroidViewModel(application) {

    private val _trainStatus: MutableStateFlow<TrainStatus> = MutableStateFlow(sampleTrainStatus.copy(isConnected = false))
    val trainStatus: StateFlow<TrainStatus> = _trainStatus.asStateFlow()

    private val _pois: MutableStateFlow<List<PoiItem>> = MutableStateFlow<List<PoiItem>>(emptyList())
    val pois: StateFlow<List<PoiItem>> = _pois.asStateFlow()

    private val _isMockMode: MutableStateFlow<Boolean> = MutableStateFlow(false)
    val isMockMode: StateFlow<Boolean> = _isMockMode.asStateFlow()

    private val _demoSpeed: MutableStateFlow<Int> = MutableStateFlow(SettingsManager.getDemoSpeed(application))
    val demoSpeed: StateFlow<Int> = _demoSpeed.asStateFlow()

    private val _reducedMotion: MutableStateFlow<Boolean> = MutableStateFlow(SettingsManager.isReducedMotion(application))
    val reducedMotion: StateFlow<Boolean> = _reducedMotion.asStateFlow()

    private val _isChecking: MutableStateFlow<Boolean> = MutableStateFlow(false)
    val isChecking: StateFlow<Boolean> = _isChecking.asStateFlow()

    private val _isWIFIonICE: MutableStateFlow<Boolean> = MutableStateFlow(false)
    val isWIFIonICE: StateFlow<Boolean> = _isWIFIonICE.asStateFlow()

    private var pollingJob: Job? = null

    private val _connections: MutableStateFlow<List<ConnectingTrain>> = MutableStateFlow<List<ConnectingTrain>>(emptyList())
    val connections: StateFlow<List<ConnectingTrain>> = _connections.asStateFlow()

    private val _departures: MutableStateFlow<List<Departure>> = MutableStateFlow<List<Departure>>(emptyList())
    val departures: StateFlow<List<Departure>> = _departures.asStateFlow()

    private val _serviceStation = MutableStateFlow<StationInfo?>(null)
    val serviceStation: StateFlow<StationInfo?> = _serviceStation.asStateFlow()

    private val _stationSearchResults = MutableStateFlow<List<StationSearchResult>>(emptyList())
    val stationSearchResults: StateFlow<List<StationSearchResult>> = _stationSearchResults.asStateFlow()

    private val _weather = MutableStateFlow<WeatherInfo?>(null)
    val weather: StateFlow<WeatherInfo?> = _weather.asStateFlow()

    private val _osmData = MutableStateFlow(OsmTrackData(isLoading = false))
    val osmData: StateFlow<OsmTrackData> = _osmData.asStateFlow()

    private var lastWeatherEva = ""
    private var lastWeatherFetchMs = 0L
    private var lastOsmLat = 0.0
    private var lastOsmLon = 0.0
    private var lastConnectionsFetchMs = 0L

    private val _journeys = MutableStateFlow<List<SavedJourney>>(emptyList())
    val journeys: StateFlow<List<SavedJourney>> = _journeys.asStateFlow()

    private val _showRecordingConsent = MutableStateFlow(false)
    val showRecordingConsent: StateFlow<Boolean> = _showRecordingConsent.asStateFlow()

    private val _isRecording = MutableStateFlow(false)
    val isRecording: StateFlow<Boolean> = _isRecording.asStateFlow()

    private val _isReconnecting = MutableStateFlow(false)
    val isReconnecting: StateFlow<Boolean> = _isReconnecting.asStateFlow()
    private var lastConnectedMs = 0L
    private val RECONNECTING_WINDOW_MS = 30_000L

    private val _liveRecording = MutableStateFlow<LiveRecordingState?>(null)
    val liveRecording: StateFlow<LiveRecordingState?> = _liveRecording.asStateFlow()

    private val _menuCategories = MutableStateFlow<List<com.nruge.iceinfo.model.MenuCategory>>(emptyList())
    val menuCategories: StateFlow<List<com.nruge.iceinfo.model.MenuCategory>> = _menuCategories.asStateFlow()

    private val _isMenuLoading = MutableStateFlow(false)
    val isMenuLoading: StateFlow<Boolean> = _isMenuLoading.asStateFlow()

    private var menuFetchedForTrain: String? = null
    private var wagenreihungFetchedForTrain: String? = null

    private val _coaches = MutableStateFlow<List<com.nruge.iceinfo.model.Coach>>(emptyList())
    val coaches: StateFlow<List<com.nruge.iceinfo.model.Coach>> = _coaches.asStateFlow()

    private val _selectedCoach = MutableStateFlow<Int?>(SettingsManager.getCoachNumber(application))
    val selectedCoach: StateFlow<Int?> = _selectedCoach.asStateFlow()

    private val _seatNumber = MutableStateFlow(SettingsManager.getSeatNumber(application))
    val seatNumber: StateFlow<String> = _seatNumber.asStateFlow()

    // Interner Aufzeichnungszustand
    private inner class ActiveRecording(
        val id: String = UUID.randomUUID().toString(),
        val trainType: String,
        val trainNumber: String,
        val originStation: String,
        val destinationEvaNr: String,
        val destinationStation: String,
        val date: String,
        val departureTime: String,
        val originDistanceFromStart: Int,
        val destinationDistanceFromStart: Int,
        val stopsCount: Int,
        val recordGps: Boolean = false,
        val startMs: Long = System.currentTimeMillis(),
        val speedSamples: MutableList<Int> = mutableListOf(),
        val trackPoints: MutableList<TrackPoint> = mutableListOf(),
        var topSpeedKmh: Int = 0
    )

    private var activeRecording: ActiveRecording? = null
    private var wasConnected = false

    private val dateFormatter = DateTimeFormatter.ofPattern("dd.MM.yyyy")

    private var searchJob: Job? = null

    init {
        viewModelScope.launch {
            val stored = JourneyRepository.loadJourneys(getApplication())
            _journeys.value = stored.ifEmpty { sampleJourneys }
        }
        val initialTarget = SettingsManager.getTargetStopEva(application)
        if (_isMockMode.value) {
            _trainStatus.value = sampleTrainStatus.copy(
                isConnected = true,
                targetStopEva = initialTarget
            )
            _connections.value = sampleConnections
            _departures.value = sampleDepartures
            _pois.value = samplePois
            _weather.value = sampleWeather
            _osmData.value = sampleOsmTrackData
            _coaches.value = sampleCoaches
            updateWidget(_trainStatus.value)
        } else {
            startPolling()
        }
    }

    fun setCoach(coach: Int?) {
        _selectedCoach.value = coach
        SettingsManager.setCoachNumber(getApplication(), coach)
    }

    fun setSeat(seat: String) {
        _seatNumber.value = seat
        SettingsManager.setSeatNumber(getApplication(), seat)
    }

    fun setTargetStop(eva: String?) {
        SettingsManager.setTargetStopEva(getApplication(), eva)
        _trainStatus.value = _trainStatus.value.copy(targetStopEva = eva)
        updateWidget(_trainStatus.value)

        lastConnectionsFetchMs = 0L
        viewModelScope.launch {
            val status = _trainStatus.value
            val updatedStatus = status.copy(targetStopEva = eva)

            // Verbindungen + Wetter für neuen Zielbahnhof
            val boardStop = relevantBoardStop(updatedStatus)
            val connections = TrainRepository.fetchConnections(
                boardStop?.evaNr ?: status.nextStopEva,
                boardStop?.effectiveArrivalMs ?: 0L
            )
            val departures = boardStop?.let { fetchDeparturesForStop(it) } ?: emptyList()
            _departures.value = departures
            _connections.value = enrichConnectionDestinations(connections, departures)
            refreshWeatherIfNeeded(updatedStatus)

            // Wagenreihung neu abfragen: Sektoren gelten für den Ausstiegsbahnhof
            val targetStop = eva?.let { e -> updatedStatus.stops.find { it.evaNr == e && !it.passed } }
            val trainKey = "${status.trainType}${status.trainNumber}_${targetStop?.evaNr.orEmpty()}"
            if (wagenreihungFetchedForTrain != trainKey) {
                wagenreihungFetchedForTrain = trainKey
                val wagenreihung = WagenreihungRepository.fetch(status, targetStop)
                if (wagenreihung.isNotEmpty()) _coaches.value = wagenreihung
            }
        }
        
        if (com.nruge.iceinfo.IceNotificationService.isRunning.value) {
            val intent = android.content.Intent(getApplication(), com.nruge.iceinfo.IceNotificationService::class.java).apply {
                action = com.nruge.iceinfo.IceNotificationService.ACTION_UPDATE_TARGET
                putExtra(com.nruge.iceinfo.IceNotificationService.EXTRA_TARGET_EVA, eva)
            }
            getApplication<android.app.Application>().startService(intent)
        }
    }

    fun setMockMode(enabled: Boolean) {
        _isMockMode.value = enabled
        val currentTarget = SettingsManager.getTargetStopEva(getApplication())
        if (enabled) {
            stopPolling()
            val status = sampleTrainStatus.copy(
                isConnected = true,
                speed = _demoSpeed.value,
                targetStopEva = currentTarget,
                nextConnectivity = sampleTrainStatus.nextConnectivity,
                connectivityRemainingSeconds = sampleTrainStatus.connectivityRemainingSeconds
            )
            _trainStatus.value = status
            _connections.value = sampleConnections
            _departures.value = sampleDepartures
            _pois.value = samplePois
            _weather.value = sampleWeather
            _osmData.value = sampleOsmTrackData
            _menuCategories.value = sampleMenuCategories
            _coaches.value = sampleCoaches
            menuFetchedForTrain = "${sampleTrainStatus.trainType}${sampleTrainStatus.trainNumber}"
            updateWidget(status)
        } else {
            _trainStatus.value = _trainStatus.value.copy(isConnected = false, targetStopEva = currentTarget)
            _connections.value = emptyList()
            _departures.value = emptyList()
            _pois.value = emptyList()
            _weather.value = null
            _osmData.value = OsmTrackData()
            _menuCategories.value = emptyList()
            menuFetchedForTrain = null
            lastWeatherEva = ""
            lastOsmLat = 0.0
            lastOsmLon = 0.0
            startPolling()
        }
    }

    fun setReducedMotion(enabled: Boolean) {
        _reducedMotion.value = enabled
        SettingsManager.setReducedMotion(getApplication(), enabled)
    }

    fun setDemoSpeed(speed: Int) {
        _demoSpeed.value = speed
        SettingsManager.setDemoSpeed(getApplication(), speed)
        if (_isMockMode.value) {
            val status = _trainStatus.value.copy(speed = speed)
            _trainStatus.value = status
            updateWidget(status)
        }
    }

    private fun updateWidget(status: TrainStatus) {
        val targetEva = SettingsManager.getTargetStopEva(getApplication())
        val targetStop = status.stops.find { it.evaNr == targetEva }
        WidgetUpdater.update(
            getApplication(),
            status,
            _isMockMode.value,
            targetStop?.name
        )
    }

    fun updateWifiStatus(isOnICE: Boolean) {
        _isWIFIonICE.value = isOnICE
    }

    fun retryConnection() {
        _isMockMode.value = false
        _isChecking.value = true
        viewModelScope.launch {
            val status = TrainRepository.fetchTrainStatus()
            _trainStatus.value = status
            _pois.value = TrainRepository.fetchPois(status.latitude, status.longitude)
            _isChecking.value = false
            if (status.isConnected) {
                startPolling()
            }
            updateWidget(status)
        }
    }

    private fun startPolling() {
        if (pollingJob?.isActive == true) return
        pollingJob = viewModelScope.launch {
            while (isActive) {
                if (!_isMockMode.value) {
                    val status = TrainRepository.fetchTrainStatus()
                    val currentTarget = SettingsManager.getTargetStopEva(getApplication())
                    val updatedStatus = status.copy(targetStopEva = currentTarget)
                    _trainStatus.value = updatedStatus
                    _pois.value = TrainRepository.fetchPois(status.latitude, status.longitude)
                    refreshOsmDataIfNeeded(status.latitude, status.longitude)
                    refreshWeatherIfNeeded(updatedStatus)
                    val targetStop = updatedStatus.targetStopEva
                        ?.let { eva -> updatedStatus.stops.find { it.evaNr == eva && !it.passed } }
                    // Key enthält Ziel-EVA → neu abfragen wenn Ausstieg geändert wird
                    val trainKey = "${status.trainType}${status.trainNumber}_${targetStop?.evaNr.orEmpty()}"
                    if (wagenreihungFetchedForTrain != trainKey) {
                        wagenreihungFetchedForTrain = trainKey
                        val wagenreihung = WagenreihungRepository.fetch(status, targetStop)
                        _coaches.value = wagenreihung.ifEmpty {
                            TrainRepository.fetchCoaches()
                        }
                    }

                    // Verbindungsstatus tracken
                    if (status.isConnected) {
                        lastConnectedMs = System.currentTimeMillis()
                        _isReconnecting.value = false
                    } else if (_isWIFIonICE.value && lastConnectedMs > 0) {
                        val elapsed = System.currentTimeMillis() - lastConnectedMs
                        _isReconnecting.value = elapsed < RECONNECTING_WINDOW_MS
                    } else {
                        _isReconnecting.value = false
                    }

                    // Neue Fahrt erkennen
                    if (!wasConnected && status.isConnected) {
                        checkForNewJourney(status)
                    }
                    wasConnected = status.isConnected

                    // Aufzeichnung aktualisieren
                    if (status.isConnected) {
                        updateRecording(status)
                    }

                    val now = System.currentTimeMillis()
                    if (now - lastConnectionsFetchMs > 30_000L) {
                        lastConnectionsFetchMs = now
                        val boardStop = relevantBoardStop(updatedStatus)
                        val connections = TrainRepository.fetchConnections(
                            boardStop?.evaNr ?: status.nextStopEva,
                            boardStop?.effectiveArrivalMs ?: 0L
                        )
                        val departures = boardStop?.let { fetchDeparturesForStop(it) } ?: emptyList()
                        _departures.value = departures
                        _connections.value = enrichConnectionDestinations(connections, departures)
                    }

                    updateWidget(updatedStatus)
                }
                delay(5000)
            }
        }
    }

    private fun checkForNewJourney(status: TrainStatus) {
        if (status.trainNumber.isBlank()) return
        val date = LocalDate.now().format(dateFormatter)
        val journeyKey = "${status.trainType}${status.trainNumber}_$date"
        val lastKey = SettingsManager.getLastJourneyKey(getApplication())
        if (journeyKey != lastKey) {
            SettingsManager.setLastJourneyKey(getApplication(), journeyKey)
            _showRecordingConsent.value = true
        }
    }

    fun requestRecording() {
        if (!_trainStatus.value.isConnected) return
        _showRecordingConsent.value = true
    }

    fun startRecording(recordGps: Boolean = false) {
        _showRecordingConsent.value = false
        val status = _trainStatus.value
        if (!status.isConnected) return
        val targetEva = status.targetStopEva
        val destinationStop = targetEva?.let { eva -> status.stops.find { it.evaNr == eva && !it.passed } }
            ?: status.stops.lastOrNull()
        val originStop = status.stops.lastOrNull { it.passed }
            ?: status.stops.firstOrNull()
        _isRecording.value = true
        val rec = ActiveRecording(
            trainType = status.trainType,
            trainNumber = status.trainNumber,
            originStation = originStop?.name ?: "Unbekannt",
            destinationEvaNr = destinationStop?.evaNr ?: "",
            destinationStation = destinationStop?.name ?: status.destination,
            date = LocalDate.now().format(dateFormatter),
            departureTime = originStop?.actualDeparture?.ifEmpty { originStop.scheduledDeparture } ?: "",
            originDistanceFromStart = originStop?.distanceFromStart ?: 0,
            destinationDistanceFromStart = destinationStop?.distanceFromStart ?: 0,
            stopsCount = status.stops.count { !it.passed && !it.isCancelled },
            recordGps = recordGps
        )
        activeRecording = rec
        _liveRecording.value = LiveRecordingState(
            trainType = rec.trainType,
            trainNumber = rec.trainNumber,
            originStation = rec.originStation,
            destinationStation = rec.destinationStation,
            date = rec.date,
            departureTime = rec.departureTime,
            startMs = rec.startMs,
            currentSpeedKmh = status.speed,
            topSpeedKmh = 0,
            sampleCount = 0,
            trackPointCount = 0,
            recordGps = rec.recordGps
        )
    }

    fun declineRecording() {
        _showRecordingConsent.value = false
    }

    private fun updateRecording(status: TrainStatus) {
        val rec = activeRecording ?: return
        // Speed tracken
        if (status.speed > rec.topSpeedKmh) rec.topSpeedKmh = status.speed
        rec.speedSamples.add(status.speed)
        // GPS-Spur aufzeichnen
        if (rec.recordGps && status.latitude != 0.0 && status.longitude != 0.0) {
            val secondsFromStart = ((System.currentTimeMillis() - rec.startMs) / 1000L).toInt()
            rec.trackPoints.add(
                TrackPoint(
                    lat = status.latitude,
                    lon = status.longitude,
                    speedKmh = status.speed,
                    secondsFromStart = secondsFromStart
                )
            )
        }
        // Live-State aktualisieren
        _liveRecording.value = _liveRecording.value?.copy(
            currentSpeedKmh = status.speed,
            topSpeedKmh = rec.topSpeedKmh,
            sampleCount = rec.speedSamples.size,
            trackPointCount = rec.trackPoints.size
        )
        // Prüfen ob Ziel-Halt erreicht
        val destinationStop = status.stops.find { it.evaNr == rec.destinationEvaNr }
        if (destinationStop?.passed == true) {
            finishRecording(status, destinationStop)
        }
    }

    private fun finishRecording(status: TrainStatus, destinationStop: com.nruge.iceinfo.model.TrainStop) {
        val rec = activeRecording ?: return
        activeRecording = null
        _isRecording.value = false
        _liveRecording.value = null
        val durationMinutes = ((System.currentTimeMillis() - rec.startMs) / 60_000L).toInt()
        val avgSpeed = if (rec.speedSamples.isNotEmpty()) rec.speedSamples.average().toInt() else 0
        val distanceKm = (destinationStop.distanceFromStart - rec.originDistanceFromStart) / 1000
        val arrivalTime = destinationStop.actualArrival.ifEmpty { destinationStop.scheduledArrival }
        val journey = SavedJourney(
            id = rec.id,
            trainType = rec.trainType,
            trainNumber = rec.trainNumber,
            originStation = rec.originStation,
            destinationStation = rec.destinationStation,
            date = rec.date,
            departureTime = rec.departureTime,
            arrivalTime = arrivalTime,
            delayMinutes = destinationStop.delayMinutes,
            distanceKm = distanceKm,
            topSpeedKmh = rec.topSpeedKmh,
            avgSpeedKmh = avgSpeed,
            durationMinutes = durationMinutes,
            stopsCount = rec.stopsCount,
            recordedGps = rec.recordGps,
            trackPoints = rec.trackPoints.toList()
        )
        viewModelScope.launch {
            JourneyRepository.saveJourney(getApplication(), journey)
            _journeys.value = listOf(journey) + _journeys.value
        }
    }

    fun cancelRecording() {
        activeRecording = null
        _isRecording.value = false
        _liveRecording.value = null
    }

    fun deleteJourney(id: String) {
        viewModelScope.launch {
            JourneyRepository.deleteJourney(getApplication(), id)
            _journeys.value = _journeys.value.filter { it.id != id }
        }
    }

    fun searchStations(query: String) {
        searchJob?.cancel()
        if (query.length < 4) {
            _stationSearchResults.value = emptyList()
            return
        }
        searchJob = viewModelScope.launch {
            delay(300)
            _stationSearchResults.value = StationFacilitiesRepository.searchStations(query)
        }
    }

    fun selectServiceStation(result: StationSearchResult) {
        _stationSearchResults.value = emptyList()
        _serviceStation.value = StationInfo(evaNr = result.evaNr, name = result.name, isLoading = true)
        viewModelScope.launch {
            _serviceStation.value = StationFacilitiesRepository.fetchFacilities(result.evaNr, result.name)
        }
    }

    fun loadServiceStationFromTrain(evaNr: String, name: String) {
        _serviceStation.value = StationInfo(evaNr = evaNr, name = name, isLoading = true)
        viewModelScope.launch {
            _serviceStation.value = StationFacilitiesRepository.fetchFacilities(evaNr, name)
        }
    }

    fun fetchMenuIfNeeded() {
        val trainKey = _trainStatus.value.let { "${it.trainType}${it.trainNumber}" }
            .takeIf { it.isNotBlank() } ?: return
        if (menuFetchedForTrain == trainKey && _menuCategories.value.isNotEmpty()) return
        menuFetchedForTrain = trainKey
        viewModelScope.launch {
            _isMenuLoading.value = true
            val result = MenuRepository.fetchMenu()
            val availabilities = MenuRepository.fetchAvailabilities()
            _menuCategories.value = applyAvailabilities(result.categories, availabilities)
            _isMenuLoading.value = false
        }
    }

    fun refreshMenu() {
        if (_isMockMode.value) return
        viewModelScope.launch {
            _isMenuLoading.value = true
            val result = MenuRepository.fetchMenu()
            val availabilities = MenuRepository.fetchAvailabilities()
            _menuCategories.value = applyAvailabilities(result.categories, availabilities)
            menuFetchedForTrain = _trainStatus.value
                .let { "${it.trainType}${it.trainNumber}" }.takeIf { it.isNotBlank() }
            _isMenuLoading.value = false
        }
    }

    private fun applyAvailabilities(
        categories: List<com.nruge.iceinfo.model.MenuCategory>,
        availabilities: Map<Int, Boolean>
    ): List<com.nruge.iceinfo.model.MenuCategory> {
        if (availabilities.isEmpty()) return categories
        return categories.map { cat ->
            cat.copy(items = cat.items.map { item ->
                availabilities[item.id]?.let { visible -> item.copy(visible = visible) } ?: item
            })
        }
    }

    private fun stopPolling() {
        pollingJob?.cancel()
    }

    private fun refreshOsmDataIfNeeded(lat: Double, lon: Double) {
        if (lat == 0.0 && lon == 0.0) return
        val dLat = kotlin.math.abs(lat - lastOsmLat)
        val dLon = kotlin.math.abs(lon - lastOsmLon)
        // ~3 km threshold before re-querying
        if (lastOsmLat != 0.0 && dLat < 0.027 && dLon < 0.035) return
        lastOsmLat = lat
        lastOsmLon = lon
        viewModelScope.launch {
            _osmData.value = OsmTrackData(isLoading = true)
            _osmData.value = OsmRepository.fetchTrackData(lat, lon)
        }
    }

    private fun relevantBoardStop(status: TrainStatus): TrainStop? {
        val targetEva = status.targetStopEva
        val target = targetEva?.let { eva -> status.stops.find { it.evaNr == eva && !it.passed } }
        return target ?: status.stops.firstOrNull { !it.passed }
    }

    private suspend fun fetchDeparturesForStop(stop: TrainStop): List<Departure> {
        if (stop.evaNr.isBlank() || stop.scheduledArrivalMs <= 0L) return emptyList()
        val arrivalMs = stop.scheduledArrivalMs + stop.delayMinutes * 60_000L
        return DepartureBoardRepository.fetchDepartures(stop.evaNr, arrivalMs)
    }

    private fun enrichConnectionDestinations(
        connections: List<ConnectingTrain>,
        departures: List<Departure>
    ): List<ConnectingTrain> {
        if (departures.isEmpty()) return connections
        val destinationByLine = departures.associate { it.line.trim() to it.destination }
        return connections.map { conn ->
            if (conn.destination.isNotBlank()) conn
            else conn.copy(destination = destinationByLine["${conn.trainType} ${conn.trainNumber}"].orEmpty())
        }
    }

    private fun weatherStop(status: TrainStatus): TrainStop? {
        val targetEva = status.targetStopEva
        return if (targetEva != null) {
            status.stops.find { it.evaNr == targetEva && !it.passed }
        } else {
            status.stops.lastOrNull()
        }
    }

    private suspend fun refreshWeatherIfNeeded(status: TrainStatus) {
        val stop = weatherStop(status) ?: return
        val now = System.currentTimeMillis()
        if (stop.evaNr == lastWeatherEva && now - lastWeatherFetchMs < 120_000L) return
        lastWeatherEva = stop.evaNr
        lastWeatherFetchMs = now
        _weather.value = WeatherRepository.fetchWeatherForStation(stop.name)
    }
}
