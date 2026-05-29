package com.nruge.iceinfo.ui

import androidx.annotation.StringRes
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.History
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Restaurant
import androidx.compose.material.icons.filled.Route
import androidx.compose.material.icons.filled.SyncAlt
import androidx.compose.material.icons.filled.Train
import androidx.compose.material.icons.filled.TransferWithinAStation
import androidx.compose.ui.graphics.vector.ImageVector
import com.nruge.iceinfo.R

sealed class Screen(val route: String, val icon: ImageVector, @StringRes val labelRes: Int) {
    object Home : Screen("home", Icons.Default.Train, R.string.nav_status)
    object Stops : Screen("stops", Icons.Default.Route, R.string.nav_journey)
    object Map : Screen("map", Icons.Default.Route, R.string.nav_map)
    object Service : Screen("service", Icons.Default.Home, R.string.nav_service)
    object Connections : Screen("connections", Icons.Default.TransferWithinAStation, R.string.nav_connections)
    object Journeys : Screen("journeys", Icons.Default.History, R.string.nav_connections) // nav label unused
    object Menu : Screen("menu", Icons.Default.Restaurant, R.string.nav_menu)
}

val navigationItems = listOf(
    Screen.Home,
    Screen.Stops,
    Screen.Menu,
    Screen.Service,
    Screen.Connections
)
