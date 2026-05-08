package com.nruge.iceinfo.ui

import androidx.annotation.StringRes
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.List
import androidx.compose.material.icons.filled.Map
import androidx.compose.material.icons.filled.Restaurant
import androidx.compose.material.icons.filled.Train
import androidx.compose.material.icons.filled.SyncAlt
import androidx.compose.ui.graphics.vector.ImageVector
import com.nruge.iceinfo.R

sealed class Screen(val route: String, val icon: ImageVector, @StringRes val labelRes: Int) {
    object Home : Screen("home", Icons.Default.Train, R.string.nav_status)
    object Stops : Screen("stops", Icons.AutoMirrored.Filled.List, R.string.nav_stops)
    object Map : Screen("map", Icons.Default.Map, R.string.nav_map)
    object Service : Screen("service", Icons.Default.Restaurant, R.string.nav_service)
    object Connections : Screen("connections", Icons.Default.SyncAlt, R.string.nav_connections)
}

val navigationItems = listOf(
    Screen.Home,
    Screen.Stops,
    Screen.Map,
    Screen.Service,
    Screen.Connections
)
