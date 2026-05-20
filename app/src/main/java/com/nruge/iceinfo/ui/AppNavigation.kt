package com.nruge.iceinfo.ui

import androidx.compose.animation.EnterTransition
import androidx.compose.animation.ExitTransition
import androidx.compose.animation.core.FastOutLinearInEasing
import androidx.compose.animation.core.LinearOutSlowInEasing
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import com.nruge.iceinfo.model.ConnectingTrain
import com.nruge.iceinfo.model.Departure
import com.nruge.iceinfo.model.PoiItem
import com.nruge.iceinfo.model.TrainStatus
import com.nruge.iceinfo.model.WeatherInfo
import com.nruge.iceinfo.ui.components.ConnectionsScreen
import com.nruge.iceinfo.ui.components.HomeScreen
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
    isMockMode: Boolean,
    demoSpeed: Int,
    showDemoSpeed: Boolean,
    reducedMotion: Boolean,
    onDemoSpeedChange: (Int) -> Unit,
    onTargetStopChange: (String?) -> Unit
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
        composable(Screen.Stops.route) {
            StopsScreen(status = trainStatus, pois = pois)
        }
        composable(Screen.Map.route) {
            MapScreen(status = trainStatus)
        }
        composable(Screen.Service.route) {
            ServiceScreen(status = trainStatus)
        }
        composable(Screen.Connections.route) {
            ConnectionsScreen(
                status = trainStatus,
                connections = connections,
                departures = departures
            )
        }
    }
}
