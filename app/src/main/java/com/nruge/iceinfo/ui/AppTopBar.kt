package com.nruge.iceinfo.ui

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.nruge.iceinfo.R

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AppTopBar(
    isMockMode: Boolean,
    isConnected: Boolean,
    isOnTrainWifi: Boolean,
    serviceRunning: Boolean,
    onToggleService: () -> Unit,
    onExitDemo: () -> Unit,
    onShowSettings: () -> Unit,
    onShowInfo: () -> Unit,
    onShowChangelog: () -> Unit,
    scrollBehavior: TopAppBarScrollBehavior? = null
) {
    val apiUnreachable = isOnTrainWifi && !isConnected && !isMockMode
    val barContainerColor = MaterialTheme.colorScheme.surfaceContainer
    val barContentColor = MaterialTheme.colorScheme.onSurface
    val scrolledFraction = scrollBehavior?.state?.overlappedFraction ?: 0f

    Column {
        TopAppBar(
        title = {
            Column {
                Text(
                    text = stringResource(R.string.app_title),
                    fontWeight = FontWeight.Bold
                )
                when {
                    isMockMode -> Text(
                        text = stringResource(R.string.status_demo),
                        style = MaterialTheme.typography.labelSmall,
                        color = barContentColor,
                        fontStyle = FontStyle.Italic
                    )
                    apiUnreachable -> Text(
                        text = stringResource(R.string.status_api_unreachable),
                        style = MaterialTheme.typography.labelSmall,
                        color = barContentColor
                    )
                    isConnected -> Text(
                        text = stringResource(R.string.status_live),
                        style = MaterialTheme.typography.labelSmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }
        },
        navigationIcon = {
            if (isMockMode) {
                IconButton(onClick = onExitDemo) {
                    Icon(
                        Icons.Default.Close,
                        contentDescription = stringResource(R.string.demo_end)
                    )
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
        color = MaterialTheme.colorScheme.outlineVariant.copy(alpha = scrolledFraction)
    )
    } // Column
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
