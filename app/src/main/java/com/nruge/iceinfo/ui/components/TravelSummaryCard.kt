package com.nruge.iceinfo.ui.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.KeyboardArrowDown
import androidx.compose.material.icons.filled.KeyboardArrowUp
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.drawscope.withTransform
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.drawText
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.rememberTextMeasurer
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.nruge.iceinfo.R
import com.nruge.iceinfo.model.TrainStatus
import com.nruge.iceinfo.util.formatRemainingTimeUntil

@OptIn(ExperimentalMaterial3ExpressiveApi::class)
@Composable
fun TravelSummaryCard(status: TrainStatus) {
    val targetStop = status.stops.find { it.evaNr == status.targetStopEva }
    val displayDestination = targetStop?.name ?: status.destination
    val displayEta = targetStop
        ?.let { it.actualArrival.takeIf { t -> t.isNotEmpty() } ?: it.scheduledArrival }
        ?: status.destinationEta
    val displayDelay = targetStop?.delayMinutes ?: status.destinationDelay

    val stopsToTarget = if (targetStop != null) {
        status.stops.filter { !it.passed && it.distanceFromStart <= targetStop.distanceFromStart }
    } else {
        status.stops.filter { !it.passed }
    }

    val totalStopsInJourney = status.stops.size
    val passedStops = status.stops.count { it.passed }

    val targetDistance = targetStop?.distanceFromStart ?: status.stops.lastOrNull()?.distanceFromStart ?: 0
    val currentPosition = status.actualPosition
    val remainingDistanceToTarget = (targetDistance - currentPosition).coerceAtLeast(0)

    val totalDistanceForProgress = targetDistance.toFloat()
    val progressPercent = if (totalDistanceForProgress > 0) {
        (currentPosition.toFloat() / totalDistanceForProgress).coerceIn(0f, 1f)
    } else 0f

    val primaryColor = MaterialTheme.colorScheme.primary

    val endStop = targetStop ?: status.stops.lastOrNull { !it.passed && !it.isCancelled }
    val intermediateDotStops = stopsToTarget.filter {
        it.distanceFromStart > currentPosition && !it.isCancelled && it != endStop
    }
    val labelStops = buildList {
        addAll(intermediateDotStops)
        if (endStop != null) add(endStop)
    }

    val textMeasurer = rememberTextMeasurer()
    var showStopLabels by remember { mutableStateOf(true) }

    AppCard(modifier = Modifier.fillMaxWidth()) {
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            // Destination + label toggle
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = " ➜ $displayDestination",
                    style = MaterialTheme.typography.titleSmall,
                    fontWeight = FontWeight.Bold,
                    color = primaryColor,
                    modifier = Modifier.weight(1f)
                )
                if (labelStops.isNotEmpty()) {
                    IconButton(
                        onClick = { showStopLabels = !showStopLabels },
                        modifier = Modifier.size(28.dp)
                    ) {
                        Icon(
                            imageVector = if (showStopLabels) Icons.Default.KeyboardArrowUp
                                          else Icons.Default.KeyboardArrowDown,
                            contentDescription = if (showStopLabels) "Halte ausblenden"
                                                 else "Halte einblenden",
                            tint = primaryColor.copy(alpha = 0.6f),
                            modifier = Modifier.size(18.dp)
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(7.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = stringResource(R.string.travel_remaining_km, remainingDistanceToTarget / 1000),
                    style = MaterialTheme.typography.bodyMedium,
                    color = primaryColor
                )
                Text(
                    text = if (targetStop != null)
                        stringResource(R.string.travel_remaining_stops, labelStops.size)
                    else
                        stringResource(R.string.travel_stops_progress, passedStops, totalStopsInJourney),
                    style = MaterialTheme.typography.bodySmall,
                    color = primaryColor.copy(alpha = 0.7f)
                )
            }

            // Progress bar with stop dots
            Box(modifier = Modifier.fillMaxWidth()) {
                if (status.speed > 0) {
                    LinearWavyProgressIndicator(
                        progress = { progressPercent },
                        modifier = Modifier.fillMaxWidth(),
                        color = primaryColor,
                        trackColor = primaryColor.copy(alpha = 0.2f),
                        waveSpeed = (status.speed / 15f).coerceAtMost(20f).dp
                    )
                } else {
                    LinearProgressIndicator(
                        progress = { progressPercent },
                        modifier = Modifier.fillMaxWidth(),
                        color = primaryColor,
                        trackColor = primaryColor.copy(alpha = 0.2f)
                    )
                }
                if (totalDistanceForProgress > 0 && labelStops.isNotEmpty()) {
                    Canvas(modifier = Modifier.matchParentSize()) {
                        intermediateDotStops.forEach { stop ->
                            val fraction = (stop.distanceFromStart.toFloat() / totalDistanceForProgress)
                                .coerceIn(0f, 1f)
                            drawCircle(
                                color = if (stop.isNext) primaryColor else primaryColor.copy(alpha = 0.5f),
                                radius = if (stop.isNext) 5.dp.toPx() else 3.5.dp.toPx(),
                                center = Offset(fraction * size.width, size.height / 2f)
                            )
                        }
                        if (endStop != null) {
                            drawCircle(
                                color = primaryColor,
                                radius = 5.dp.toPx(),
                                center = Offset(size.width, size.height / 2f)
                            )
                        }
                    }
                }
            }

            // Station name labels — vertically below each dot, centered on the dot's x position
            if (showStopLabels && totalDistanceForProgress > 0 && labelStops.isNotEmpty()) {
                val labelStyle = TextStyle(fontSize = 9.sp, color = primaryColor.copy(alpha = 0.65f))
                val labelStyleBold = TextStyle(fontSize = 9.sp, color = primaryColor)
                Canvas(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(70.dp)
                ) {
                    labelStops.forEach { stop ->
                        val isEndpoint = stop == endStop
                        val style = if (stop.isNext || isEndpoint) labelStyleBold else labelStyle
                        val measured = textMeasurer.measure(stop.name, style)

                        val dotX = if (isEndpoint) size.width
                                   else (stop.distanceFromStart.toFloat() / totalDistanceForProgress)
                                       .coerceIn(0f, 1f) * size.width

                        val labelYOffset = 0.dp.toPx()
                        withTransform({
                            translate(left = dotX, top = labelYOffset)
                            rotate(degrees = -45f, pivot = Offset.Zero)
                        }) {
                            // Right edge of text anchored at dot → text hangs down-left
                            drawText(measured, topLeft = Offset(-measured.size.width.toFloat() - 8.dp.toPx(), 0f))
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(7.dp))
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column(verticalArrangement = Arrangement.spacedBy(2.dp)) {
                    Text(
                        text = stringResource(R.string.travel_arrival, displayEta),
                        style = MaterialTheme.typography.bodyMedium,
                        fontWeight = FontWeight.SemiBold,
                        color = primaryColor
                    )
                    Text(
                        text = stringResource(
                            R.string.travel_remaining_time,
                            formatRemainingTimeUntil(
                                targetStop?.scheduledArrival ?: status.destinationEta,
                                displayDelay
                            )
                        ),
                        style = MaterialTheme.typography.bodySmall,
                        color = primaryColor.copy(alpha = 0.7f)
                    )
                }
                if (displayDelay > 0) {
                    DelayBadge(delayMinutes = displayDelay)
                } else {
                    Surface(
                        color = primaryColor.copy(alpha = 0.1f),
                        shape = MaterialTheme.shapes.small
                    ) {
                        Text(
                            text = stringResource(R.string.travel_on_time),
                            modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp),
                            color = primaryColor,
                            style = MaterialTheme.typography.labelMedium,
                            fontWeight = FontWeight.Bold
                        )
                    }
                }
            }
        }
    }
}
