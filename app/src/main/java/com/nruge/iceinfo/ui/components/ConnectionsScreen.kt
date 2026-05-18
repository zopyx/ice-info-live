package com.nruge.iceinfo.ui.components

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.foundation.background
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.nruge.iceinfo.R
import com.nruge.iceinfo.model.ConnectingTrain
import com.nruge.iceinfo.model.Departure
import com.nruge.iceinfo.ui.theme.onSuccessContainer
import com.nruge.iceinfo.ui.theme.onWarningContainer
import com.nruge.iceinfo.ui.theme.rainbowColor
import com.nruge.iceinfo.ui.theme.successContainer
import com.nruge.iceinfo.ui.theme.warningContainer
import com.nruge.iceinfo.model.TrainStatus

@Composable
fun ConnectionsScreen(
    status: TrainStatus,
    connections: List<ConnectingTrain>,
    departures: List<Departure> = emptyList(),
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .background(MaterialTheme.colorScheme.surfaceContainer)
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        val displayConnections = connections

        val targetStop = status.stops.find { it.evaNr == status.targetStopEva && !it.passed }
        val stationName = targetStop?.name ?: status.nextStop

        AppCard(modifier = Modifier.fillMaxWidth()) {
            Column(
                modifier = Modifier.padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(0.dp)
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth().padding(bottom = 12.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column(verticalArrangement = Arrangement.spacedBy(2.dp)) {
                        Text(
                            text = stringResource(R.string.connections_title, stationName),
                            style = MaterialTheme.typography.titleSmall,
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
                                    textDecoration = if (isDelayed) androidx.compose.ui.text.style.TextDecoration.LineThrough
                                                     else androidx.compose.ui.text.style.TextDecoration.None
                                )
                                if (isDelayed) {
                                    if (stop.delayMinutes < 0) {
                                        Text(
                                            text = displayTime,
                                            style = MaterialTheme.typography.bodySmall,
                                            fontWeight = FontWeight.SemiBold,
                                            color = rainbowColor()
                                        )
                                    } else {
                                        Text(
                                            text = displayTime,
                                            style = MaterialTheme.typography.bodySmall,
                                            fontWeight = FontWeight.SemiBold,
                                            color = if (stop.delayMinutes >= 5)
                                                MaterialTheme.colorScheme.error
                                            else
                                                onSuccessContainer()
                                        )
                                    }
                                }
                            }
                        }
                    }
                }

                if (displayConnections.isEmpty()) {
                    Text(
                        text = stringResource(R.string.connections_none),
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                } else {
                    displayConnections.forEachIndexed { index, conn ->
                        ConnectionRow(conn)
                        if (index < displayConnections.lastIndex) {
                            HorizontalDivider(
                                modifier = Modifier.padding(vertical = 2.dp),
                                color = MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.4f)
                            )
                        }
                    }
                }
            }
        }

        if (departures.isNotEmpty()) {
            DeparturesCard(stationName = stationName, departures = departures)
        }

        Spacer(modifier = Modifier.height(96.dp))
    }
}

@Composable
private fun DeparturesCard(stationName: String, departures: List<Departure>) {
    AppCard(modifier = Modifier.fillMaxWidth()) {
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(0.dp)
        ) {
            Text(
                text = stringResource(R.string.connections_more_departures, stationName),
                style = MaterialTheme.typography.titleSmall,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.padding(bottom = 12.dp)
            )
            departures.forEachIndexed { index, dep ->
                DepartureRow(dep)
                if (index < departures.lastIndex) {
                    HorizontalDivider(
                        modifier = Modifier.padding(vertical = 2.dp),
                        color = MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.4f)
                    )
                }
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
private fun ConnectionRow(conn: ConnectingTrain) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 10.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        // Zeit
        DepartureTimePair(scheduled = conn.departure, delayMinutes = conn.delayMinutes)

        // Zugnummer + Ziel
        Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(3.dp)) {
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
        }

        // Gleis + erreichbar
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
            val isTight = conn.reachable && conn.transferMinutes != null && conn.transferMinutes < 5
            Surface(
                color = when {
                    !conn.reachable -> MaterialTheme.colorScheme.errorContainer
                    isTight         -> warningContainer()
                    else            -> successContainer()
                },
                shape = MaterialTheme.shapes.extraSmall
            ) {
                Text(
                    text = when {
                        !conn.reachable -> stringResource(R.string.connection_missed)
                        isTight         -> stringResource(R.string.connection_tight)
                        else            -> stringResource(R.string.connection_reachable)
                    },
                    modifier = Modifier.padding(horizontal = 8.dp, vertical = 3.dp),
                    style = MaterialTheme.typography.labelSmall,
                    fontWeight = FontWeight.SemiBold,
                    color = when {
                        !conn.reachable -> MaterialTheme.colorScheme.onErrorContainer
                        isTight         -> onWarningContainer()
                        else            -> onSuccessContainer()
                    }
                )
            }
            if (conn.transferMinutes != null) {
                Text(
                    text = stringResource(R.string.connection_transfer_minutes, conn.transferMinutes),
                    style = MaterialTheme.typography.labelSmall,
                    color = when {
                        !conn.reachable -> MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.5f)
                        isTight         -> onWarningContainer()
                        else            -> onSuccessContainer()
                    }
                )
            }
        }
    }
}

@Composable
private fun DepartureRow(dep: Departure) {
    val isCancelled = dep.cancelled
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 10.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        // Zeit
        DepartureTimePair(
            scheduled = dep.scheduledTime,
            delayMinutes = dep.delayMinutes,
            cancelled = isCancelled
        )

        // Linie + Ziel
        Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(3.dp)) {
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
                color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = if (isCancelled) 0.5f else 1f),
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
        }

        // Gleis
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
