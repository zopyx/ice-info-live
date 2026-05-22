package com.nruge.iceinfo.ui.components

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.HorizontalDivider
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Cancel
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.DirectionsTransit
import androidx.compose.material.icons.filled.Train
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.nruge.iceinfo.R
import com.nruge.iceinfo.model.ConnectingTrain
import com.nruge.iceinfo.model.Departure
import com.nruge.iceinfo.model.TrainStatus
import com.nruge.iceinfo.ui.theme.onSuccessContainer
import com.nruge.iceinfo.ui.theme.onWarningContainer
import com.nruge.iceinfo.ui.theme.rainbowColor
import com.nruge.iceinfo.ui.theme.successContainer
import com.nruge.iceinfo.ui.theme.warningContainer

@Composable
fun ConnectionsScreen(
    status: TrainStatus,
    connections: List<ConnectingTrain>,
    departures: List<Departure> = emptyList(),
    modifier: Modifier = Modifier
) {
    val targetStop = status.stops.find { it.evaNr == status.targetStopEva && !it.passed }
    val stationName = targetStop?.name ?: status.nextStop

    val missed = connections.filter { !it.reachable }
    val tight = connections.filter { it.reachable && it.transferMinutes != null && it.transferMinutes < 5 }
    val reachable = connections.filter { it.reachable && (it.transferMinutes == null || it.transferMinutes >= 5) }

    LazyColumn(
        modifier = modifier.fillMaxSize(),
        contentPadding = PaddingValues(
            start = 16.dp,
            end = 16.dp,
            top = 16.dp,
            bottom = 16.dp
        ),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        // Station header
        item {
            Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                Text(
                    text = stationName,
                    style = MaterialTheme.typography.headlineSmall,
                    fontWeight = FontWeight.Bold
                )
                val stop = targetStop ?: status.stops.firstOrNull { !it.passed }
                if (stop != null && stop.scheduledArrival.isNotEmpty()) {
                    val isDelayed = stop.delayMinutes > 0
                    val displayTime = stop.actualArrival.ifEmpty { stop.scheduledArrival }
                    Row(
                        horizontalArrangement = Arrangement.spacedBy(4.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            text = stringResource(R.string.connections_arrival, stop.scheduledArrival),
                            style = MaterialTheme.typography.bodySmall,
                            color = if (isDelayed)
                                MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.5f)
                            else
                                MaterialTheme.colorScheme.onSurfaceVariant,
                            textDecoration = if (isDelayed) TextDecoration.LineThrough
                            else TextDecoration.None
                        )
                        if (isDelayed) {
                            Text(
                                text = displayTime,
                                style = MaterialTheme.typography.bodySmall,
                                fontWeight = FontWeight.SemiBold,
                                color = if (stop.delayMinutes < 0) rainbowColor()
                                else if (stop.delayMinutes >= 5) MaterialTheme.colorScheme.error
                                else onSuccessContainer()
                            )
                        }
                    }
                }
            }
        }

        if (connections.isEmpty()) {
            item {
                Text(
                    text = stringResource(R.string.connections_none),
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }

        // Reachable connections
        if (reachable.isNotEmpty()) {
            item(key = "header_reachable") {
                ConnectionSectionHeader(
                    icon = Icons.Default.CheckCircle,
                    title = stringResource(R.string.connections_section_reachable),
                    tint = onSuccessContainer()
                )
            }
            item(key = "group_reachable") {
                ConnectionGroup(reachable) { conn -> ConnectionCardContent(conn) }
            }
        }

        // Tight connections
        if (tight.isNotEmpty()) {
            item(key = "header_tight") {
                ConnectionSectionHeader(
                    icon = Icons.Default.Warning,
                    title = stringResource(R.string.connections_section_tight),
                    tint = onWarningContainer()
                )
            }
            item(key = "group_tight") {
                ConnectionGroup(tight) { conn -> ConnectionCardContent(conn) }
            }
        }

        // Missed connections
        if (missed.isNotEmpty()) {
            item(key = "header_missed") {
                ConnectionSectionHeader(
                    icon = Icons.Default.Cancel,
                    title = stringResource(R.string.connections_section_missed),
                    tint = MaterialTheme.colorScheme.error
                )
            }
            item(key = "group_missed") {
                ConnectionGroup(missed) { conn -> ConnectionCardContent(conn) }
            }
        }

        // Departures
        if (departures.isNotEmpty()) {
            item(key = "header_departures") {
                ConnectionSectionHeader(
                    icon = Icons.Default.DirectionsTransit,
                    title = stringResource(R.string.connections_section_departures)
                )
            }
            item(key = "group_departures") {
                ConnectionGroup(departures) { dep -> DepartureCardContent(dep) }
            }
        }
    }
}

@Composable
private fun ConnectionSectionHeader(
    icon: ImageVector,
    title: String,
    tint: androidx.compose.ui.graphics.Color = MaterialTheme.colorScheme.primary
) {
    Row(
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(6.dp)
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            modifier = Modifier.size(16.dp),
            tint = tint
        )
        Text(
            text = title,
            style = MaterialTheme.typography.labelLarge,
            color = tint,
            fontWeight = FontWeight.Bold
        )
    }
}

@Composable
private fun <T> ConnectionGroup(
    items: List<T>,
    containerColor: androidx.compose.ui.graphics.Color = MaterialTheme.colorScheme.surface,
    content: @Composable (T) -> Unit
) {
    Surface(
        shape = MaterialTheme.shapes.extraLarge,
        color = containerColor,
        modifier = Modifier.fillMaxWidth()
    ) {
        Column {
            items.forEachIndexed { index, item ->
                content(item)
                if (index < items.lastIndex) {
                    HorizontalDivider(
                        modifier = Modifier.padding(horizontal = 16.dp),
                        color = MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.5f)
                    )
                }
            }
        }
    }
}

@Composable
private fun ConnectionCardContent(conn: ConnectingTrain) {
    val isTight = conn.reachable && conn.transferMinutes != null && conn.transferMinutes < 5

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 12.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Status icon circle
            Surface(
                shape = CircleShape,
                color = when {
                    !conn.reachable -> MaterialTheme.colorScheme.errorContainer
                    isTight -> warningContainer()
                    else -> successContainer()
                },
                modifier = Modifier.size(44.dp)
            ) {
                Box(contentAlignment = Alignment.Center) {
                    Icon(
                        imageVector = Icons.Default.Train,
                        contentDescription = null,
                        tint = when {
                            !conn.reachable -> MaterialTheme.colorScheme.onErrorContainer
                            isTight -> onWarningContainer()
                            else -> onSuccessContainer()
                        },
                        modifier = Modifier.size(22.dp)
                    )
                }
            }

            // Train info + time
            Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(4.dp)) {
                Row(
                    horizontalArrangement = Arrangement.spacedBy(6.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    TrainTypeBadge(conn.trainType)
                    Text(
                        text = conn.trainNumber,
                        style = MaterialTheme.typography.bodyMedium,
                        fontWeight = FontWeight.Bold
                    )
                }
                Text(
                    text = conn.destination,
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
                DepartureTimePair(scheduled = conn.departure, delayMinutes = conn.delayMinutes)
            }

            // Track + transfer time
            Column(
                horizontalAlignment = Alignment.End,
                verticalArrangement = Arrangement.spacedBy(4.dp)
            ) {
                if (conn.track.isNotEmpty()) {
                    Surface(
                        color = MaterialTheme.colorScheme.surfaceContainerHigh,
                        shape = MaterialTheme.shapes.extraSmall
                    ) {
                        Text(
                            text = stringResource(R.string.track_short, conn.track),
                            modifier = Modifier.padding(horizontal = 8.dp, vertical = 3.dp),
                            style = MaterialTheme.typography.labelMedium,
                            fontWeight = FontWeight.SemiBold
                        )
                    }
                }
                if (conn.transferMinutes != null) {
                    Text(
                        text = stringResource(R.string.connection_transfer_minutes, conn.transferMinutes),
                        style = MaterialTheme.typography.labelSmall,
                        color = when {
                            !conn.reachable -> MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.5f)
                            isTight -> onWarningContainer()
                            else -> onSuccessContainer()
                        }
                    )
                }
            }
        }
}

@Composable
private fun DepartureCardContent(dep: Departure) {
    val isCancelled = dep.cancelled

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 12.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Icon circle
            Surface(
                shape = CircleShape,
                color = if (isCancelled) MaterialTheme.colorScheme.errorContainer
                else MaterialTheme.colorScheme.secondaryContainer,
                modifier = Modifier.size(44.dp)
            ) {
                Box(contentAlignment = Alignment.Center) {
                    Icon(
                        imageVector = Icons.Default.Train,
                        contentDescription = null,
                        tint = if (isCancelled) MaterialTheme.colorScheme.onErrorContainer
                        else MaterialTheme.colorScheme.onSecondaryContainer,
                        modifier = Modifier.size(22.dp)
                    )
                }
            }

            // Line + destination
            Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(4.dp)) {
                val parts = dep.line.trim().split(" ", limit = 2)
                Row(
                    horizontalArrangement = Arrangement.spacedBy(6.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    if (parts.size == 2) {
                        TrainTypeBadge(parts[0], muted = isCancelled)
                        Text(
                            text = parts[1],
                            style = MaterialTheme.typography.bodyMedium,
                            fontWeight = FontWeight.Bold,
                            color = if (isCancelled) MaterialTheme.colorScheme.onSurface.copy(alpha = 0.4f)
                            else MaterialTheme.colorScheme.onSurface
                        )
                    } else {
                        Text(
                            text = dep.line,
                            style = MaterialTheme.typography.bodyMedium,
                            fontWeight = FontWeight.Bold
                        )
                    }
                    if (isCancelled) {
                        Surface(
                            color = MaterialTheme.colorScheme.errorContainer,
                            shape = MaterialTheme.shapes.extraSmall
                        ) {
                            Text(
                                text = stringResource(R.string.stop_cancelled),
                                modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp),
                                style = MaterialTheme.typography.labelSmall,
                                fontWeight = FontWeight.SemiBold,
                                color = MaterialTheme.colorScheme.onErrorContainer
                            )
                        }
                    }
                }
                Text(
                    text = dep.destination,
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant.copy(
                        alpha = if (isCancelled) 0.5f else 1f
                    ),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
                DepartureTimePair(
                    scheduled = dep.scheduledTime,
                    delayMinutes = dep.delayMinutes,
                    cancelled = isCancelled
                )
            }

            // Platform
            if (dep.platform.isNotEmpty()) {
                Surface(
                    color = MaterialTheme.colorScheme.surfaceContainerHigh,
                    shape = MaterialTheme.shapes.extraSmall
                ) {
                    Text(
                        text = stringResource(R.string.track_short, dep.platform),
                        modifier = Modifier.padding(horizontal = 8.dp, vertical = 3.dp),
                        style = MaterialTheme.typography.labelMedium,
                        fontWeight = FontWeight.SemiBold
                    )
                }
            }
        }
}

private fun addMinutesToTime(time: String, minutes: Int): String {
    if (minutes == 0) return time
    val parts = time.split(":")
    if (parts.size != 2) return time
    val h = parts[0].toIntOrNull() ?: return time
    val m = parts[1].toIntOrNull() ?: return time
    val total = h * 60 + m + minutes
    return "%02d:%02d".format((total / 60) % 24, total % 60)
}

@Composable
private fun DepartureTimePair(scheduled: String, delayMinutes: Int, cancelled: Boolean = false) {
    val actual = addMinutesToTime(scheduled, delayMinutes)
    val isDelayed = delayMinutes != 0 && !cancelled
    val isEarly = delayMinutes < 0 && !cancelled
    Row(horizontalArrangement = Arrangement.spacedBy(4.dp), verticalAlignment = Alignment.CenterVertically) {
        Text(
            text = scheduled,
            style = MaterialTheme.typography.bodyMedium,
            fontFamily = FontFamily.Monospace,
            fontWeight = FontWeight.SemiBold,
            color = when {
                cancelled -> MaterialTheme.colorScheme.onSurface.copy(alpha = 0.35f)
                isDelayed -> MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.5f)
                else      -> MaterialTheme.colorScheme.onSurface
            },
            textDecoration = if (isDelayed || cancelled) TextDecoration.LineThrough else TextDecoration.None
        )
        if (isEarly) {
            Text(
                text = actual,
                style = MaterialTheme.typography.bodyMedium,
                fontFamily = FontFamily.Monospace,
                fontWeight = FontWeight.Bold,
                color = rainbowColor()
            )
        } else {
            Text(
                text = actual,
                style = MaterialTheme.typography.bodyMedium,
                fontFamily = FontFamily.Monospace,
                fontWeight = FontWeight.Bold,
                color = when {
                    cancelled                      -> MaterialTheme.colorScheme.onSurface.copy(alpha = 0.35f)
                    isDelayed && delayMinutes >= 5 -> MaterialTheme.colorScheme.error
                    else                           -> onSuccessContainer()
                },
                textDecoration = if (cancelled) TextDecoration.LineThrough else TextDecoration.None
            )
        }
    }
}

@Composable
private fun TrainTypeBadge(type: String, muted: Boolean = false) {
    Surface(
        color = if (muted) MaterialTheme.colorScheme.surfaceContainerHigh
        else MaterialTheme.colorScheme.secondaryContainer,
        shape = RoundedCornerShape(4.dp)
    ) {
        Text(
            text = type,
            modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp),
            style = MaterialTheme.typography.labelSmall,
            fontWeight = FontWeight.Bold,
            color = if (muted) MaterialTheme.colorScheme.onSurface.copy(alpha = 0.4f)
            else MaterialTheme.colorScheme.onSecondaryContainer
        )
    }
}
