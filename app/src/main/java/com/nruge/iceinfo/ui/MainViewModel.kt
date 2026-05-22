package com.nruge.iceinfo.ui

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.nruge.iceinfo.DepartureBoardRepository
import com.nruge.iceinfo.StationFacilitiesRepository
import com.nruge.iceinfo.TrainRepository
import com.nruge.iceinfo.WeatherRepository
import com.nruge.iceinfo.model.*
import com.nruge.iceinfo.sampleConnections
import com.nruge.iceinfo.sampleDepartures
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
import com.nruge.iceinfo.util.SettingsManager
import com.nruge.iceinfo.widget.WidgetUpdater

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

    private var lastWeatherEva = ""

    private var searchJob: Job? = null

    init {
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
            updateWidget(_trainStatus.value)
        } else {
            startPolling()
        }
    }

    fun setTargetStop(eva: String?) {
        SettingsManager.setTargetStopEva(getApplication(), eva)
        _trainStatus.value = _trainStatus.value.copy(targetStopEva = eva)
        updateWidget(_trainStatus.value)

        viewModelScope.launch {
            val status = _trainStatus.value
            val boardStop = relevantBoardStop(status)
            _connections.value = TrainRepository.fetchConnections(
                boardStop?.evaNr ?: status.nextStopEva,
                boardStop?.effectiveArrivalMs ?: 0L
            )
            _departures.value = boardStop?.let { fetchDeparturesForStop(it) } ?: emptyList()
            refreshWeatherIfNeeded(status.copy(targetStopEva = eva))
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
            updateWidget(status)
        } else {
            _trainStatus.value = _trainStatus.value.copy(isConnected = false, targetStopEva = currentTarget)
            _connections.value = emptyList()
            _departures.value = emptyList()
            _pois.value = emptyList()
            _weather.value = null
            lastWeatherEva = ""
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
                    val boardStop = relevantBoardStop(updatedStatus)
                    _connections.value = TrainRepository.fetchConnections(
                        boardStop?.evaNr ?: status.nextStopEva,
                        boardStop?.effectiveArrivalMs ?: 0L
                    )
                    _departures.value = boardStop?.let { fetchDeparturesForStop(it) } ?: emptyList()
                    refreshWeatherIfNeeded(updatedStatus)
                    updateWidget(updatedStatus)
                }
                delay(3000)
            }
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

    private fun stopPolling() {
        pollingJob?.cancel()
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
        if (stop.evaNr == lastWeatherEva) return
        lastWeatherEva = stop.evaNr
        _weather.value = WeatherRepository.fetchWeatherForStation(stop.name)
    }
}
