package com.nruge.iceinfo.ui

import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Image
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.nruge.iceinfo.R

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AppTopBar(
    isMockMode: Boolean,
    isConnected: Boolean,
    isOnTrainWifi: Boolean,
    isReconnecting: Boolean = false,
    serviceRunning: Boolean,
    showPrideBadge: Boolean = false,
    onToggleService: () -> Unit,
    onExitDemo: () -> Unit,
    onStartDemo: () -> Unit,
    onShowSettings: () -> Unit,
    onShowInfo: () -> Unit,
    onShowChangelog: () -> Unit,
    onShowJourneys: () -> Unit,
    onNavigateBack: (() -> Unit)? = null,
    showScrollDivider: Boolean = true,
    scrollBehavior: TopAppBarScrollBehavior? = null
) {
    val apiUnreachable = isOnTrainWifi && !isConnected && !isMockMode
    val barContainerColor = MaterialTheme.colorScheme.surfaceContainer
    val barContentColor = MaterialTheme.colorScheme.onSurface
    val scrolledFraction = scrollBehavior?.state?.overlappedFraction ?: 0f
    var showPrideDialog by remember { mutableStateOf(false) }

    if (showPrideDialog) {
        PrideDialog(onDismiss = { showPrideDialog = false })
    }

    Column {
        TopAppBar(
        title = {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
            Column {
                Text(
                    text = stringResource(R.string.app_title),
                    fontWeight = FontWeight.Bold
                )
                when {
                    isMockMode -> ConnectionStatusBadge(state = ConnectionState.DEMO)
                    isReconnecting -> ConnectionStatusBadge(state = ConnectionState.RECONNECTING)
                    apiUnreachable -> ConnectionStatusBadge(state = ConnectionState.OFFLINE)
                    isConnected    -> ConnectionStatusBadge(state = ConnectionState.LIVE)
                }
            }
            Image(
                painter = painterResource(R.drawable.progressive_pride),
                contentDescription = "Pride Flag",
                contentScale = ContentScale.Crop,
                modifier = Modifier
                    .size(width = 32.dp, height = 22.dp)
                    .clip(RoundedCornerShape(6.dp))
                    .clickable { showPrideDialog = true }
            )
            } // Row
        },
        navigationIcon = {
            when {
                onNavigateBack != null -> IconButton(onClick = onNavigateBack) {
                    Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Zurück")
                }
                isMockMode -> IconButton(onClick = onExitDemo) {
                    Icon(Icons.Default.Close, contentDescription = stringResource(R.string.demo_end))
                }
            }
        },
        actions = {
            var menuExpanded by remember { mutableStateOf(false) }

            if (isConnected || isMockMode) {
                IconButton(onClick = onToggleService) {
                    Icon(
                        imageVector = if (serviceRunning) Icons.Default.NotificationsActive else Icons.Default.Notifications,
                        contentDescription = stringResource(R.string.notifications_cd)
                    )
                }
            }
            IconButton(onClick = { menuExpanded = true }) {
                Icon(Icons.Default.MoreVert, contentDescription = stringResource(R.string.menu_cd))
            }

            DropdownMenu(
                expanded = menuExpanded,
                onDismissRequest = { menuExpanded = false },
                containerColor = MaterialTheme.colorScheme.surface
            ) {
                if (!isMockMode) {
                    DropdownMenuItem(
                        text = { Text(stringResource(R.string.demo_mode)) },
                        onClick = { onStartDemo(); menuExpanded = false },
                        leadingIcon = { Icon(Icons.Default.PlayArrow, null) }
                    )
                }
                DropdownMenuItem(
                    text = { Text("Meine Fahrten") },
                    onClick = { onShowJourneys(); menuExpanded = false },
                    leadingIcon = { Icon(Icons.Default.History, null) }
                )
                DropdownMenuItem(
                    text = { Text(stringResource(R.string.menu_settings)) },
                    onClick = { onShowSettings(); menuExpanded = false },
                    leadingIcon = { Icon(Icons.Default.Settings, null) }
                )
                DropdownMenuItem(
                    text = { Text(stringResource(R.string.menu_changelog)) },
                    onClick = { onShowChangelog(); menuExpanded = false },
                    leadingIcon = { Icon(Icons.Default.NewReleases, null) }
                )
                DropdownMenuItem(
                    text = { Text(stringResource(R.string.menu_info)) },
                    onClick = { onShowInfo(); menuExpanded = false },
                    leadingIcon = { Icon(Icons.Default.Info, null) }
                )
            }
        },
        colors = TopAppBarDefaults.topAppBarColors(
            containerColor = barContainerColor,
            scrolledContainerColor = barContainerColor,
            titleContentColor = barContentColor,
            navigationIconContentColor = barContentColor,
            actionIconContentColor = barContentColor
        ),
        scrollBehavior = scrollBehavior
    )
    HorizontalDivider(
        color = MaterialTheme.colorScheme.outlineVariant.copy(alpha = if (showScrollDivider) scrolledFraction else 0f)
    )
    } // Column
}

private enum class ConnectionState { LIVE, DEMO, RECONNECTING, OFFLINE }

@Composable
private fun ConnectionStatusBadge(state: ConnectionState) {
    val infiniteTransition = rememberInfiniteTransition(label = "connection")

    Row(
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(5.dp)
    ) {
        when (state) {
            ConnectionState.LIVE -> {
                val alpha by infiniteTransition.animateFloat(
                    initialValue = 1f, targetValue = 0.3f,
                    animationSpec = infiniteRepeatable(
                        tween(1200), RepeatMode.Reverse
                    ), label = "livePulse"
                )
                val dotColor = Color(0xFF4CAF50)
                Canvas(modifier = Modifier.size(7.dp)) {
                    drawCircle(color = dotColor.copy(alpha = alpha))
                }
                Text(
                    text = "Live",
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
            ConnectionState.DEMO -> {
                val alpha by infiniteTransition.animateFloat(
                    initialValue = 1f, targetValue = 0.3f,
                    animationSpec = infiniteRepeatable(
                        tween(1400), RepeatMode.Reverse
                    ), label = "demoPulse"
                )
                val dotColor = Color(0xFFAB47BC)
                Canvas(modifier = Modifier.size(7.dp)) {
                    drawCircle(color = dotColor.copy(alpha = alpha))
                }
                Text(
                    text = stringResource(R.string.status_demo),
                    style = MaterialTheme.typography.labelSmall,
                    color = Color(0xFFAB47BC)
                )
            }
            ConnectionState.RECONNECTING -> {
                val rotation by infiniteTransition.animateFloat(
                    initialValue = 0f, targetValue = 360f,
                    animationSpec = infiniteRepeatable(
                        tween(1000, easing = LinearEasing), RepeatMode.Restart
                    ), label = "spin"
                )
                Icon(
                    imageVector = Icons.Default.Refresh,
                    contentDescription = null,
                    modifier = Modifier
                        .size(11.dp)
                        .rotate(rotation),
                    tint = Color(0xFFFFA726)
                )
                Text(
                    text = "Verbinde...",
                    style = MaterialTheme.typography.labelSmall,
                    color = Color(0xFFFFA726)
                )
            }
            ConnectionState.OFFLINE -> {
                Icon(
                    imageVector = Icons.Default.WifiOff,
                    contentDescription = null,
                    modifier = Modifier.size(11.dp),
                    tint = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Text(
                    text = stringResource(R.string.status_api_unreachable),
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
    }
}

@Composable
private fun PrideDialog(onDismiss: () -> Unit) {
    AlertDialog(
        onDismissRequest = onDismiss,
        icon = {
        },
        title = {
            Text(
                text = "Für Vielfalt und Toleranz, gegen Hass und Hetze",
                textAlign = TextAlign.Center
            )
        },
        text = {
            Text(
                text = "Diese App ist für alle Menschen - unabhängig von Herkunft, Identität oder wen sie lieben. Aber nicht für dich, wenn du damit ein Problem hast. Gute Reise!",
                textAlign = TextAlign.Center,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        },
        confirmButton = {
            TextButton(onClick = onDismiss) {
                Text("Slay ✨")
            }
        }
    )
}

@Composable
fun AppNavigationBar(
    currentRoute: String?,
    enabled: Boolean,
    onNavigate: (String) -> Unit,
    modifier: Modifier = Modifier
) {
    Column(modifier = modifier) {
        HorizontalDivider(
            color = MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.4f)
        )
        NavigationBar {
            navigationItems.forEach { screen ->
                val isSelected = currentRoute == screen.route
                NavigationBarItem(
                    selected = isSelected,
                    onClick = { if (!isSelected) onNavigate(screen.route) },
                    enabled = enabled,
                    icon = {
                        Icon(
                            imageVector = screen.icon,
                            contentDescription = stringResource(screen.labelRes)
                        )
                    },
                    label = { Text(stringResource(screen.labelRes)) }
                )
            }
        }
    }
}
