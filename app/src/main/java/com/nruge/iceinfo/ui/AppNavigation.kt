package com.nruge.iceinfo.ui

import androidx.compose.animation.EnterTransition
import androidx.compose.animation.ExitTransition
import androidx.compose.animation.core.FastOutLinearInEasing
import androidx.compose.animation.core.LinearOutSlowInEasing
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import com.nruge.iceinfo.model.ConnectingTrain
import com.nruge.iceinfo.model.Departure
import com.nruge.iceinfo.model.OsmTrackData
import com.nruge.iceinfo.model.PoiItem
import com.nruge.iceinfo.model.StationInfo
import com.nruge.iceinfo.model.StationSearchResult
import com.nruge.iceinfo.model.TrainStatus
import com.nruge.iceinfo.model.WeatherInfo
import com.nruge.iceinfo.model.LiveRecordingState
import com.nruge.iceinfo.model.SavedJourney
import com.nruge.iceinfo.ui.components.ConnectionsScreen
import com.nruge.iceinfo.ui.components.HomeScreen
import com.nruge.iceinfo.ui.components.JourneysScreen
import com.nruge.iceinfo.ui.components.MapScreen
import com.nruge.iceinfo.ui.components.ServiceScreen
import com.nruge.iceinfo.ui.components.StopsScreen

@Composable
fun AppNavigation(
    navController: NavHostController,
    innerPadding: PaddingValues,
    trainStatus: TrainStatus,
    pois: List<PoiItem>,
    connections: List<ConnectingTrain>,
    departures: List<Departure>,
    weather: WeatherInfo?,
    osmData: OsmTrackData,
    isMockMode: Boolean,
    demoSpeed: Int,
    showDemoSpeed: Boolean,
    reducedMotion: Boolean,
    onDemoSpeedChange: (Int) -> Unit,
    onTargetStopChange: (String?) -> Unit,
    serviceStation: StationInfo?,
    stationSearchResults: List<StationSearchResult>,
    onStationSearchQueryChange: (String) -> Unit,
    onStationSelect: (StationSearchResult) -> Unit,
    onLoadTrainStation: (evaNr: String, name: String) -> Unit,
    savedJourneys: List<SavedJourney>,
    onDeleteJourney: (String) -> Unit,
    isRecording: Boolean,
    liveRecording: LiveRecordingState?,
    onStartRecording: () -> Unit
) {
    val enter: EnterTransition = if (reducedMotion) EnterTransition.None else
        fadeIn(animationSpec = tween(durationMillis = 300, delayMillis = 90, easing = LinearOutSlowInEasing))
    val exit: ExitTransition = if (reducedMotion) ExitTransition.None else
        fadeOut(animationSpec = tween(durationMillis = 90, easing = FastOutLinearInEasing))

    NavHost(
        navController = navController,
        startDestination = Screen.Home.route,
        modifier = Modifier.padding(innerPadding),
        enterTransition = { enter },
        exitTransition = { exit },
        popEnterTransition = { enter },
        popExitTransition = { exit }
    ) {
        composable(Screen.Home.route) {
            if (!trainStatus.isConnected && !isMockMode) {
                // Leere Fläche damit die Back-Gesture-Vorschau nicht den Status-Screen zeigt
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .background(MaterialTheme.colorScheme.surfaceContainer)
                )
            } else {
                HomeScreen(
                    status = if (isMockMode) trainStatus.copy(speed = demoSpeed) else trainStatus,
                    weather = weather,
                    isMockMode = isMockMode,
                    demoSpeed = demoSpeed,
                    showDemoSpeed = showDemoSpeed,
                    reducedMotion = reducedMotion,
                    onDemoSpeedChange = onDemoSpeedChange,
                    onTargetStopChange = onTargetStopChange
                )
            }
        }
        composable(Screen.Stops.route) {
            StopsScreen(status = trainStatus, isMockMode = isMockMode)
        }
        composable(Screen.Map.route) {
            MapScreen(status = trainStatus, osmData = osmData, pois = pois)
        }
        composable(Screen.Service.route) {
            ServiceScreen(
                status = trainStatus,
                serviceStation = serviceStation,
                searchResults = stationSearchResults,
                onSearchQueryChange = onStationSearchQueryChange,
                onStationSelect = onStationSelect,
                onLoadTrainStation = onLoadTrainStation,
            )
        }
        composable(Screen.Connections.route) {
            ConnectionsScreen(
                status = trainStatus,
                connections = connections,
                departures = departures,
                isMockMode = isMockMode
            )
        }
        composable(Screen.Journeys.route) {
            JourneysScreen(
                journeys = savedJourneys,
                onDeleteJourney = onDeleteJourney,
                isConnected = trainStatus.isConnected,
                isRecording = isRecording,
                liveRecording = liveRecording,
                onStartRecording = onStartRecording
            )
        }
    }
}
