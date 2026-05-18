package com.nruge.iceinfo.ui.components

import android.content.Intent
import android.net.Uri
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AccountBalance
import androidx.compose.material.icons.filled.AddCircle
import androidx.compose.material.icons.filled.Cancel
import androidx.compose.material.icons.filled.Forest
import androidx.compose.material.icons.filled.LocationCity
import androidx.compose.material.icons.filled.Place
import androidx.compose.material.icons.filled.Terrain
import androidx.compose.material.icons.filled.Train
import androidx.compose.material.icons.filled.Water
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.unit.dp
import com.nruge.iceinfo.R
import com.nruge.iceinfo.model.PoiItem
import com.nruge.iceinfo.model.TrainStatus
import com.nruge.iceinfo.model.TrainStop
import com.nruge.iceinfo.ui.theme.onSuccessContainer
import com.nruge.iceinfo.ui.theme.rainbowColor

@Composable
fun TimelineStopRow(stop: TrainStop, isFirst: Boolean, isLast: Boolean) {
    val isPassed = stop.passed
    val isNext = stop.isNext

    val travelledLine = MaterialTheme.colorScheme.primary
    val pendingLine = MaterialTheme.colorScheme.outlineVariant

    val rowBackground = if (isNext)
        MaterialTheme.colorScheme.primaryContainer.copy(alpha = 0.45f)
    else
        Color.Transparent

    val isCancelled = stop.isCancelled

    val nameColor = when {
        isCancelled -> MaterialTheme.colorScheme.error.copy(alpha = 0.7f)
        isPassed    -> MaterialTheme.colorScheme.onSurface.copy(alpha = 0.45f)
        isNext      -> MaterialTheme.colorScheme.onPrimaryContainer
        else        -> MaterialTheme.colorScheme.onSurface
    }

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .height(IntrinsicSize.Min)
    ) {
        // Times + delay column LEFT of timeline
        Row(
            modifier = Modifier
                .fillMaxHeight()
                .padding(end = 4.dp, top = if (isNext) 12.dp else 8.dp, bottom = if (isNext) 12.dp else 8.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // 2×2 time grid
            Column(
                horizontalAlignment = Alignment.End,
                verticalArrangement = Arrangement.Center,
                modifier = Modifier.fillMaxHeight()
            ) {
                if (stop.scheduledArrival.isNotEmpty()) {
                    StopTimePair(
                        scheduled = stop.scheduledArrival,
                        actual = stop.actualArrival,
                        delay = stop.delayMinutes,
                        isPassed = isPassed,
                        isNext = isNext,
                        isCancelled = isCancelled
                    )
                }
                if (stop.scheduledDeparture.isNotEmpty()) {
                    StopTimePair(
                        scheduled = stop.scheduledDeparture,
                        actual = stop.actualDeparture,
                        delay = stop.departureDelayMinutes,
                        isPassed = isPassed,
                        isNext = isNext,
                        isCancelled = isCancelled
                    )
                }
            }

            // Delay column — zentriert neben dem 2×2 Block
            Column(
                modifier = Modifier
                    .width(34.dp)
                    .fillMaxHeight(),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.Center
            ) {
                if (!isPassed && !isCancelled) {
                    if (stop.scheduledArrival.isNotEmpty() && stop.delayMinutes != 0) {
                        StopDelayLabel(stop.delayMinutes)
                    }
                    val depDiffersFromArr = stop.departureDelayMinutes != stop.delayMinutes
                    if (stop.scheduledDeparture.isNotEmpty() && stop.departureDelayMinutes != 0 && depDiffersFromArr) {
                        StopDelayLabel(stop.departureDelayMinutes)
                    }
                }
            }
        }

        // Timeline column
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            modifier = Modifier.width(24.dp)
        ) {
            Box(
                modifier = Modifier
                    .width(2.dp)
                    .weight(1f)
                    .background(
                        when {
                            isFirst -> Color.Transparent
                            isPassed || isNext -> travelledLine
                            else -> pendingLine
                        }
                    )
            )
            when {
                isCancelled -> Icon(
                    imageVector = Icons.Default.Cancel,
                    contentDescription = null,
                    modifier = Modifier.size(16.dp),
                    tint = MaterialTheme.colorScheme.error.copy(alpha = 0.7f)
                )
                isNext -> Box(
                    modifier = Modifier
                        .size(20.dp)
                        .clip(CircleShape)
                        .background(MaterialTheme.colorScheme.primary),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Default.Train,
                        contentDescription = null,
                        modifier = Modifier.size(13.dp),
                        tint = MaterialTheme.colorScheme.onPrimary
                    )
                }
                isPassed -> Box(
                    modifier = Modifier
                        .size(8.dp)
                        .clip(CircleShape)
                        .background(travelledLine)
                )
                else -> Box(
                    modifier = Modifier
                        .size(12.dp)
                        .clip(CircleShape)
                        .background(MaterialTheme.colorScheme.surface)
                        .border(2.dp, MaterialTheme.colorScheme.outline, CircleShape)
                )
            }
            Box(
                modifier = Modifier
                    .width(2.dp)
                    .weight(1f)
                    .background(
                        when {
                            isLast -> Color.Transparent
                            isPassed -> travelledLine
                            else -> pendingLine
                        }
                    )
            )
        }

        // Station info RIGHT of timeline
        Column(
            modifier = Modifier
                .weight(1f)
                .clip(RoundedCornerShape(12.dp))
                .background(rowBackground)
                .padding(
                    vertical = if (isNext) 12.dp else 8.dp,
                    horizontal = 10.dp
                )
        ) {
            Text(
                text = stop.name,
                color = nameColor,
                style = if (isNext) MaterialTheme.typography.titleMedium
                        else MaterialTheme.typography.bodyMedium,
                fontWeight = when {
                    isNext -> FontWeight.Bold
                    isPassed -> FontWeight.Normal
                    else -> FontWeight.Medium
                },
                textDecoration = if (isCancelled) TextDecoration.LineThrough else TextDecoration.None
            )
            if (isCancelled) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(3.dp)
                ) {
                    Icon(
                        imageVector = Icons.Default.Cancel,
                        contentDescription = null,
                        modifier = Modifier.size(11.dp),
                        tint = MaterialTheme.colorScheme.error.copy(alpha = 0.7f)
                    )
                    Text(
                        text = stringResource(R.string.stop_cancelled),
                        color = MaterialTheme.colorScheme.error.copy(alpha = 0.7f),
                        style = MaterialTheme.typography.bodySmall
                    )
                }
            }
            if (!isCancelled && stop.track.isNotEmpty()) {
                Text(
                    text = stringResource(R.string.track_full, stop.track),
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                        .copy(alpha = if (isPassed) 0.5f else 1f),
                    style = MaterialTheme.typography.bodySmall
                )
            }
            if (stop.isAdditional) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(3.dp),
                    modifier = Modifier.padding(top = 2.dp)
                ) {
                    Icon(
                        imageVector = Icons.Default.AddCircle,
                        contentDescription = null,
                        modifier = Modifier.size(11.dp),
                        tint = onSuccessContainer()
                            .copy(alpha = if (isPassed) 0.5f else 1f)
                    )
                    Text(
                        text = stringResource(R.string.stop_additional),
                        color = onSuccessContainer()
                            .copy(alpha = if (isPassed) 0.5f else 1f),
                        style = MaterialTheme.typography.bodySmall
                    )
                }
            }
        }
    }
}

@Composable
private fun StopDelayLabel(delay: Int) {
    if (delay < 0) {
        Text(
            text = "($delay)",
            style = MaterialTheme.typography.labelSmall,
            fontFamily = androidx.compose.ui.text.font.FontFamily.Monospace,
            color = rainbowColor()
        )
    } else {
        Text(
            text = "(+$delay)",
            style = MaterialTheme.typography.labelSmall,
            fontFamily = androidx.compose.ui.text.font.FontFamily.Monospace,
            color = if (delay >= 5) MaterialTheme.colorScheme.error else onSuccessContainer()
        )
    }
}

@Composable
private fun StopTimePair(
    scheduled: String,
    actual: String,
    delay: Int,
    isPassed: Boolean,
    isNext: Boolean,
    isCancelled: Boolean = false
) {
    val isEarly = delay < 0 && !isPassed && !isCancelled && actual.isNotEmpty()
    val isDelayed = delay > 0 && !isPassed && !isCancelled && actual.isNotEmpty()
    val displayActual = actual.ifEmpty { scheduled }

    Row(horizontalArrangement = Arrangement.spacedBy(4.dp)) {
        Text(
            text = scheduled,
            style = MaterialTheme.typography.bodySmall,
            fontFamily = androidx.compose.ui.text.font.FontFamily.Monospace,
            fontWeight = if (isNext && !isDelayed && !isEarly && !isCancelled) FontWeight.SemiBold else FontWeight.Normal,
            color = when {
                isCancelled        -> MaterialTheme.colorScheme.onSurface.copy(alpha = 0.35f)
                isDelayed || isEarly -> MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.5f)
                isPassed           -> MaterialTheme.colorScheme.onSurface.copy(alpha = 0.4f)
                else               -> MaterialTheme.colorScheme.onSurface
            },
            textDecoration = if (isDelayed || isEarly || isCancelled) TextDecoration.LineThrough else TextDecoration.None
        )
        if (isEarly) {
            Text(
                text = displayActual,
                style = MaterialTheme.typography.bodySmall,
                fontFamily = androidx.compose.ui.text.font.FontFamily.Monospace,
                fontWeight = FontWeight.Bold,
                color = rainbowColor()
            )
        } else {
            Text(
                text = displayActual,
                style = MaterialTheme.typography.bodySmall,
                fontFamily = androidx.compose.ui.text.font.FontFamily.Monospace,
                fontWeight = if (isDelayed || isNext) FontWeight.Bold else FontWeight.Normal,
                color = when {
                    isCancelled             -> MaterialTheme.colorScheme.onSurface.copy(alpha = 0.35f)
                    isPassed                -> MaterialTheme.colorScheme.onSurface.copy(alpha = 0.4f)
                    isDelayed && delay >= 5 -> MaterialTheme.colorScheme.error
                    else                    -> onSuccessContainer()
                },
                textDecoration = if (isCancelled) TextDecoration.LineThrough else TextDecoration.None
            )
        }
    }
}
@Composable
fun StopsScreen(
    status: TrainStatus,
    modifier: Modifier = Modifier,
    pois: List<PoiItem> = emptyList()
) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .background(MaterialTheme.colorScheme.surfaceContainer)
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        if (status.stops.isNotEmpty()) {
            AppCard(modifier = Modifier.fillMaxWidth()) {
                Column(
                    modifier = Modifier.padding(16.dp),
                    verticalArrangement = Arrangement.spacedBy(0.dp)
                ) {
                    Text(
                        text = stringResource(R.string.stops_title),
                        style = MaterialTheme.typography.titleSmall,
                        fontWeight = FontWeight.Bold,
                        modifier = Modifier.padding(bottom = 12.dp)
                    )
                    status.stops.forEachIndexed { index, stop ->
                        TimelineStopRow(
                            stop = stop,
                            isFirst = index == 0,
                            isLast = index == status.stops.lastIndex
                        )
                    }
                }
            }
        } else {
            Box(
                modifier = Modifier.fillMaxSize(),
                contentAlignment = Alignment.Center
            ) {
                Text(stringResource(R.string.stops_none))
            }
        }
        PoisCard(status = status, pois = pois)
        Spacer(modifier = Modifier.height(96.dp))
    }

}

@Composable
fun PoisCard(status: TrainStatus, pois: List<PoiItem>) {
    val context = LocalContext.current
    if (pois.isEmpty()) return
    val displayPois = pois

    AppCard(modifier = Modifier.fillMaxWidth()) {
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Text(
                text = stringResource(R.string.pois_title),
                style = MaterialTheme.typography.titleSmall,
                fontWeight = FontWeight.Bold
            )

            Column(modifier = Modifier.padding(vertical = 4.dp)) {
                displayPois.forEachIndexed { index, poi ->
                    val icon = when (poi.type) {
                        "CITY" -> Icons.Default.LocationCity
                        "RIVER" -> Icons.Default.Water
                        "MOUNTAIN" -> Icons.Default.Terrain
                        "LAKE" -> Icons.Default.Water
                        "MONUMENT" -> Icons.Default.AccountBalance
                        "FOREST" -> Icons.Default.Forest
                        else -> Icons.Default.Place
                    }
                    val distanceText = if (poi.distance < 1000) {
                        "${poi.distance} m"
                    } else {
                        "${"%.1f".format(poi.distance / 1000.0)} km"
                    }

                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable {
                                val query = Uri.encode(poi.name)
                                context.startActivity(
                                    Intent(
                                        Intent.ACTION_VIEW,
                                        Uri.parse("https://www.google.com/search?q=$query")
                                    )
                                )
                            }
                            .padding(vertical = 10.dp, horizontal = 4.dp),
                        horizontalArrangement = Arrangement.spacedBy(16.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(
                            imageVector = icon,
                            contentDescription = null,
                            tint = MaterialTheme.colorScheme.primary,
                            modifier = Modifier.size(24.dp)
                        )
                        Column(modifier = Modifier.weight(1f)) {
                            Text(
                                text = poi.type.lowercase().replaceFirstChar { it.uppercase() },
                                style = MaterialTheme.typography.labelSmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                            Text(
                                text = poi.name,
                                style = MaterialTheme.typography.bodyMedium,
                                fontWeight = FontWeight.Medium
                            )
                            if (poi.description.isNotEmpty()) {
                                Text(
                                    text = poi.description,
                                    style = MaterialTheme.typography.bodySmall,
                                    color = MaterialTheme.colorScheme.onSurfaceVariant
                                )
                            }
                        }
                        AssistChip(
                            onClick = {},
                            enabled = false,
                            label = { Text(distanceText, style = MaterialTheme.typography.labelMedium) },
                            colors = AssistChipDefaults.assistChipColors(
                                disabledContainerColor = MaterialTheme.colorScheme.secondaryContainer,
                                disabledLabelColor = MaterialTheme.colorScheme.onSecondaryContainer
                            )
                        )
                    }

                    if (index < displayPois.lastIndex) {
                        HorizontalDivider(
                            modifier = Modifier.padding(horizontal = 16.dp),
                            color = MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.4f)
                        )
                    }
                }
            }
        }
    }
}