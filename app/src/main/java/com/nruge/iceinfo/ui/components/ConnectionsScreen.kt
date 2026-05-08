package com.nruge.iceinfo.ui.components

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.foundation.background
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.nruge.iceinfo.R
import com.nruge.iceinfo.model.ConnectingTrain
import com.nruge.iceinfo.model.Departure
import com.nruge.iceinfo.model.TrainStatus
import com.nruge.iceinfo.sampleConnections
import com.nruge.iceinfo.sampleDepartures

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
            .background(MaterialTheme.colorScheme.background)
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        val displayConnections =
            if (status.isConnected && connections.isNotEmpty()) connections
            else sampleConnections

        AppCard(modifier = Modifier.fillMaxWidth()) {
            Column(
                modifier = Modifier.padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    val targetStop = status.stops.find { it.evaNr == status.targetStopEva && !it.passed }
                    val stationName = targetStop?.name ?: status.nextStop
                    Text(
                        text = stringResource(R.string.connections_title, stationName),
                        style = MaterialTheme.typography.titleSmall,
                        fontWeight = FontWeight.Bold
                    )
                    if (!status.isConnected) {
                        Text(
                            text = stringResource(R.string.pois_demo),
                            style = MaterialTheme.typography.labelSmall,
                            color = MaterialTheme.colorScheme.secondary,
                            fontStyle = FontStyle.Italic
                        )
                    }
                }

                displayConnections.forEachIndexed { index, conn ->
                    ConnectionRow(conn)
                    if (index < displayConnections.lastIndex) {
                        HorizontalDivider(
                            color = MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.4f)
                        )
                    }
                }
            }
        }

        run {
            val displayDepartures = if (departures.isNotEmpty()) departures else sampleDepartures
            val targetStop = status.stops.find { it.evaNr == status.targetStopEva && !it.passed }
            val stationName = targetStop?.name ?: status.nextStop
            DeparturesCard(stationName = stationName, departures = displayDepartures)
        }

        Spacer(modifier = Modifier.height(96.dp))
    }
}

@Composable
private fun DeparturesCard(stationName: String, departures: List<Departure>) {
    AppCard(modifier = Modifier.fillMaxWidth()) {
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Text(
                text = stringResource(R.string.connections_more_departures, stationName),
                style = MaterialTheme.typography.titleSmall,
                fontWeight = FontWeight.Bold
            )
            departures.forEachIndexed { index, dep ->
                DepartureRow(dep)
                if (index < departures.lastIndex) {
                    HorizontalDivider(
                        color = MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.4f)
                    )
                }
            }
        }
    }
}

@Composable
private fun DepartureRow(dep: Departure) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 8.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Column(
            modifier = Modifier.width(56.dp),
            horizontalAlignment = Alignment.Start
        ) {
            Text(
                text = dep.scheduledTime,
                style = MaterialTheme.typography.bodyMedium,
                fontWeight = FontWeight.SemiBold,
                textDecoration = if (dep.cancelled) androidx.compose.ui.text.style.TextDecoration.LineThrough else null
            )
            if (dep.delayMinutes > 0) {
                Text(
                    text = "+${dep.delayMinutes}",
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.error,
                    fontWeight = FontWeight.Bold
                )
            }
        }
        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = dep.line,
                style = MaterialTheme.typography.bodyMedium,
                fontWeight = FontWeight.Bold
            )
            Text(
                text = dep.destination,
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                maxLines = 1
            )
        }
        if (dep.platform.isNotEmpty()) {
            Surface(
                color = MaterialTheme.colorScheme.surfaceContainerHigh,
                shape = MaterialTheme.shapes.small
            ) {
                Text(
                    text = stringResource(R.string.track_short, dep.platform),
                    modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp),
                    style = MaterialTheme.typography.labelMedium,
                    fontWeight = FontWeight.SemiBold
                )
            }
        }
    }
}

@Composable
fun ConnectionRow(conn: ConnectingTrain) {
    ListItem(
        colors = ListItemDefaults.colors(containerColor = androidx.compose.ui.graphics.Color.Transparent),
        overlineContent = {
            Row(
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "${conn.trainType} ${conn.trainNumber}",
                    fontWeight = FontWeight.Bold,
                    style = MaterialTheme.typography.bodyMedium
                )
                AssistChip(
                    onClick = {},
                    enabled = false,
                    label = {
                        Text(
                            text = if (conn.reachable) stringResource(R.string.connection_reachable)
                                   else stringResource(R.string.connection_missed),
                            style = MaterialTheme.typography.labelSmall,
                            fontWeight = FontWeight.Bold
                        )
                    },
                    colors = AssistChipDefaults.assistChipColors(
                        disabledContainerColor = if (conn.reachable)
                            MaterialTheme.colorScheme.primaryContainer
                            else MaterialTheme.colorScheme.errorContainer,
                        disabledLabelColor = if (conn.reachable)
                            MaterialTheme.colorScheme.onPrimaryContainer
                            else MaterialTheme.colorScheme.onErrorContainer
                    ),
                    border = null
                )
            }
        },
        headlineContent = {
            Text(
                text = "→ ${conn.destination}",
                style = MaterialTheme.typography.bodyMedium
            )
        },
        trailingContent = {
            Column(horizontalAlignment = Alignment.End) {
                Text(
                    text = conn.departure,
                    fontWeight = FontWeight.SemiBold,
                    style = MaterialTheme.typography.bodyMedium
                )
                if (conn.track.isNotEmpty()) {
                    Text(
                        text = stringResource(R.string.track_short, conn.track),
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
                if (conn.delayMinutes > 0) {
                    DelayBadge(delayMinutes = conn.delayMinutes, size = DelayBadgeSize.SMALL)
                }
            }
        }
    )
}