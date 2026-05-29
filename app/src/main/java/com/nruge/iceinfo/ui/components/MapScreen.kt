package com.nruge.iceinfo.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Bolt
import androidx.compose.material.icons.filled.GridView
import androidx.compose.material.icons.filled.Place
import androidx.compose.material.icons.filled.Route
import androidx.compose.material.icons.filled.Speed
import androidx.compose.material.icons.filled.Train
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.nruge.iceinfo.R
import com.nruge.iceinfo.model.OsmTrackData
import com.nruge.iceinfo.model.PoiItem
import com.nruge.iceinfo.model.RailFeature
import com.nruge.iceinfo.model.RailFeatureType
import com.nruge.iceinfo.model.TrackInfo
import com.nruge.iceinfo.model.TrainStatus


@Composable
fun MapScreen(
    status: TrainStatus,
    osmData: OsmTrackData,
    pois: List<PoiItem>,
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.surfaceContainer)
    ) {
        when {
            !status.isConnected || (status.latitude == 0.0 && status.longitude == 0.0) ->
                TrackEmptyState()
            osmData.isLoading ->
                Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    CircularProgressIndicator()
                }
            osmData.error != null ->
                TrackErrorState(message = osmData.error)
            else ->
                TrackContent(trackInfo = osmData.trackInfo, features = osmData.features, pois = pois)
        }
    }
}

@Composable
internal fun TrackContent(trackInfo: TrackInfo, features: List<RailFeature>, pois: List<PoiItem>) {
    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(start = 16.dp, end = 16.dp, top = 16.dp, bottom = 96.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        item {
            TrackSectionHeader(icon = Icons.Default.Train, title = stringResource(R.string.track_section_track))
            Spacer(Modifier.height(8.dp))
            TrackPropertiesCard(trackInfo = trackInfo)
        }

        item {
            TrackSectionHeader(icon = Icons.Default.Route, title = stringResource(R.string.track_section_features))
            Spacer(Modifier.height(8.dp))
            if (features.isEmpty()) {
                Text(
                    text = stringResource(R.string.track_no_features),
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            } else {
                AppCard(modifier = Modifier.fillMaxWidth()) {
                    features.forEachIndexed { index, feature ->
                        FeatureRow(
                            label = feature.type.shortLabel(),
                            containerColor = feature.type.containerColor(),
                            onContainerColor = feature.type.onContainerColor(),
                            name = feature.name,
                            distanceKm = feature.distanceKm
                        )
                        if (index < features.lastIndex) {
                            HorizontalDivider(modifier = Modifier.padding(horizontal = 16.dp))
                        }
                    }
                }
            }
        }

        if (pois.isNotEmpty()) {
            item {
                TrackSectionHeader(icon = Icons.Default.Place, title = stringResource(R.string.pois_title_plain))
                Spacer(Modifier.height(8.dp))
                AppCard(modifier = Modifier.fillMaxWidth()) {
                    pois.forEachIndexed { index, poi ->
                        FeatureRow(
                            label = poi.type.poiLabel(),
                            containerColor = MaterialTheme.colorScheme.secondaryContainer,
                            onContainerColor = MaterialTheme.colorScheme.onSecondaryContainer,
                            name = poi.name,
                            distanceKm = poi.distance / 1000.0
                        )
                        if (index < pois.lastIndex) {
                            HorizontalDivider(modifier = Modifier.padding(horizontal = 16.dp))
                        }
                    }
                }
            }
        }

        item {
            Text(
                text = stringResource(R.string.track_source),
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.padding(top = 4.dp)
            )
        }
    }
}

@Composable
internal fun FeatureRow(
    label: String,
    containerColor: Color,
    onContainerColor: Color,
    name: String,
    distanceKm: Double
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 12.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Surface(shape = CircleShape, color = containerColor) {
            Text(
                text = label,
                style = MaterialTheme.typography.labelSmall,
                color = onContainerColor,
                modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp),
                fontWeight = FontWeight.SemiBold
            )
        }
        Text(
            text = name,
            style = MaterialTheme.typography.bodyMedium,
            modifier = Modifier.weight(1f)
        )
        Text(
            text = "%.1f km".format(distanceKm),
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

@Composable
internal fun TrackPropertiesCard(trackInfo: TrackInfo) {
    AppCard(modifier = Modifier.fillMaxWidth()) {
        Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
            TrackPropertyRow(
                icon = Icons.Default.Speed,
                label = stringResource(R.string.track_property_max_speed),
                value = trackInfo.maxSpeed?.let { "$it km/h" } ?: "–"
            )
            HorizontalDivider()
            TrackPropertyRow(
                icon = Icons.Default.Bolt,
                label = stringResource(R.string.track_property_electrified),
                value = electrifiedLabel(trackInfo.electrified, trackInfo.voltage)
            )
            HorizontalDivider()
            TrackPropertyRow(
                icon = Icons.Default.GridView,
                label = stringResource(R.string.track_property_tracks),
                value = trackInfo.tracks?.toString() ?: "–"
            )
            if (trackInfo.usage != null) {
                HorizontalDivider()
                TrackPropertyRow(
                    icon = Icons.Default.Route,
                    label = stringResource(R.string.track_property_usage),
                    value = usageLabel(trackInfo.usage)
                )
            }
        }
    }
}

@Composable
internal fun TrackPropertyRow(icon: ImageVector, label: String, value: String) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            modifier = Modifier.size(18.dp),
            tint = MaterialTheme.colorScheme.primary
        )
        Text(
            text = label,
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier.weight(1f)
        )
        Text(
            text = value,
            style = MaterialTheme.typography.bodyMedium,
            fontWeight = FontWeight.Medium
        )
    }
}

@Composable
internal fun TrackSectionHeader(icon: ImageVector, title: String) {
    Row(
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(6.dp)
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            modifier = Modifier.size(16.dp),
            tint = MaterialTheme.colorScheme.primary
        )
        Text(
            text = title,
            style = MaterialTheme.typography.labelLarge,
            color = MaterialTheme.colorScheme.primary,
            fontWeight = FontWeight.Bold
        )
    }
}

@Composable
private fun TrackEmptyState() {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(horizontal = 32.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Icon(
            Icons.Default.Train,
            contentDescription = null,
            modifier = Modifier.size(52.dp),
            tint = MaterialTheme.colorScheme.onSurfaceVariant
        )
        Spacer(Modifier.height(16.dp))
        Text(
            stringResource(R.string.track_empty_title),
            style = MaterialTheme.typography.titleLarge,
            fontWeight = FontWeight.Bold
        )
        Spacer(Modifier.height(8.dp))
        Text(
            stringResource(R.string.track_empty_desc),
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            textAlign = TextAlign.Center
        )
    }
}

@Composable
private fun TrackErrorState(message: String) {
    Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        Column(horizontalAlignment = Alignment.CenterHorizontally, modifier = Modifier.padding(32.dp)) {
            Icon(
                Icons.Default.Warning,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.error,
                modifier = Modifier.size(40.dp)
            )
            Spacer(Modifier.height(8.dp))
            Text(message, color = MaterialTheme.colorScheme.error, textAlign = TextAlign.Center)
        }
    }
}

@Composable
internal fun RailFeatureType.containerColor(): Color = when (this) {
    RailFeatureType.TUNNEL -> MaterialTheme.colorScheme.secondaryContainer
    RailFeatureType.BRIDGE -> MaterialTheme.colorScheme.tertiaryContainer
    RailFeatureType.STATION -> MaterialTheme.colorScheme.primaryContainer
    RailFeatureType.HALT -> MaterialTheme.colorScheme.surfaceVariant
}

@Composable
internal fun RailFeatureType.onContainerColor(): Color = when (this) {
    RailFeatureType.TUNNEL -> MaterialTheme.colorScheme.onSecondaryContainer
    RailFeatureType.BRIDGE -> MaterialTheme.colorScheme.onTertiaryContainer
    RailFeatureType.STATION -> MaterialTheme.colorScheme.onPrimaryContainer
    RailFeatureType.HALT -> MaterialTheme.colorScheme.onSurfaceVariant
}

@Composable
internal fun RailFeatureType.shortLabel(): String = when (this) {
    RailFeatureType.TUNNEL -> stringResource(R.string.track_feature_tunnel)
    RailFeatureType.BRIDGE -> stringResource(R.string.track_feature_bridge)
    RailFeatureType.STATION -> stringResource(R.string.track_feature_station)
    RailFeatureType.HALT -> stringResource(R.string.track_feature_halt)
}

internal fun String.poiLabel(): String = when (this) {
    "CITY" -> "Stadt"
    "RIVER" -> "Fluss"
    "LAKE" -> "See"
    "MOUNTAIN" -> "Berg"
    "MONUMENT" -> "Sehenswürdigkeit"
    "FOREST" -> "Wald"
    "CASTLE" -> "Schloss"
    "CHURCH" -> "Kirche"
    else -> this.lowercase().replaceFirstChar { it.uppercase() }
}

internal fun electrifiedLabel(electrified: String?, voltage: Int?): String {
    if (electrified == "no" || electrified == null) return "Nicht elektrifiziert"
    val type = when (electrified) {
        "contact_line" -> "Oberleitung"
        "rail" -> "Stromschiene"
        "4th_rail" -> "4. Schiene"
        "yes" -> "Elektrifiziert"
        else -> electrified
    }
    val voltageStr = when {
        voltage == null -> ""
        voltage >= 1000 -> " · ${voltage / 1000} kV"
        else -> " · $voltage V"
    }
    return "$type$voltageStr"
}

internal fun usageLabel(usage: String): String = when (usage) {
    "main" -> "Hauptstrecke"
    "branch" -> "Nebenstrecke"
    "industrial" -> "Industriegleis"
    "tourism" -> "Touristikbahn"
    "military" -> "Militärstrecke"
    else -> usage
}
