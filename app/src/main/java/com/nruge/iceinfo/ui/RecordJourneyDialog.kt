package com.nruge.iceinfo.ui

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.nruge.iceinfo.model.TrainStatus

@Composable
fun RecordJourneyDialog(
    status: TrainStatus,
    onRecord: (recordGps: Boolean) -> Unit,
    onDecline: () -> Unit
) {
    val destination = status.targetStopEva
        ?.let { eva -> status.stops.find { it.evaNr == eva }?.name }
        ?: status.destination
    val origin = status.stops.firstOrNull { it.passed }?.name
        ?: status.stops.firstOrNull()?.name
        ?: "Unbekannt"

    var recordGps by remember { mutableStateOf(false) }

    AlertDialog(
        onDismissRequest = onDecline,
        icon = {
            Icon(
                imageVector = Icons.Default.Train,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.primary,
                modifier = Modifier.size(32.dp)
            )
        },
        title = {
            Text(
                text = "Fahrt aufzeichnen?",
                style = MaterialTheme.typography.headlineSmall,
                fontWeight = FontWeight.Bold
            )
        },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(16.dp)) {
                // Zuginfo
                Surface(
                    shape = MaterialTheme.shapes.large,
                    color = MaterialTheme.colorScheme.primaryContainer
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 16.dp, vertical = 12.dp),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            text = "${status.trainType} ${status.trainNumber}",
                            style = MaterialTheme.typography.titleMedium,
                            fontWeight = FontWeight.Bold,
                            color = MaterialTheme.colorScheme.onPrimaryContainer
                        )
                        Text(
                            text = "$origin → $destination",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onPrimaryContainer.copy(alpha = 0.8f)
                        )
                    }
                }

                // Was wird gespeichert
                Text(
                    text = "Was gespeichert wird:",
                    style = MaterialTheme.typography.labelMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    fontWeight = FontWeight.SemiBold
                )

                Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                    RecordItem(Icons.Default.Schedule,    "Abfahrt & Ankunftszeit")
                    RecordItem(Icons.Default.Timer,       "Fahrtdauer")
                    RecordItem(Icons.Default.Speed,       "Höchst- & Durchschnittsgeschwindigkeit")
                    RecordItem(Icons.Default.Route,       "Gefahrene Kilometer")
                    RecordItem(Icons.Default.CheckCircle, "Pünktlichkeit")
                }

                HorizontalDivider(color = MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.5f))

                // GPS-Toggle
                Surface(
                    shape = MaterialTheme.shapes.large,
                    color = if (recordGps)
                        MaterialTheme.colorScheme.secondaryContainer
                    else
                        MaterialTheme.colorScheme.surfaceContainerHigh
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 16.dp, vertical = 10.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                        Icon(
                            imageVector = Icons.Default.GpsFixed,
                            contentDescription = null,
                            modifier = Modifier.size(20.dp),
                            tint = if (recordGps)
                                MaterialTheme.colorScheme.onSecondaryContainer
                            else
                                MaterialTheme.colorScheme.onSurfaceVariant
                        )
                        Column(modifier = Modifier.weight(1f)) {
                            Text(
                                text = "GPS-Spur aufzeichnen",
                                style = MaterialTheme.typography.bodyMedium,
                                fontWeight = FontWeight.SemiBold,
                                color = if (recordGps)
                                    MaterialTheme.colorScheme.onSecondaryContainer
                                else
                                    MaterialTheme.colorScheme.onSurface
                            )
                            Text(
                                text = "Nutzt das Zug-GPS (nicht dein Handy-GPS) · GPX-Export (~75 KB)",
                                style = MaterialTheme.typography.bodySmall,
                                color = if (recordGps)
                                    MaterialTheme.colorScheme.onSecondaryContainer.copy(alpha = 0.7f)
                                else
                                    MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                        Switch(
                            checked = recordGps,
                            onCheckedChange = { recordGps = it }
                        )
                    }
                }
            }
        },
        confirmButton = {
            Button(onClick = { onRecord(recordGps) }) {
                Icon(Icons.Default.FiberManualRecord, contentDescription = null,
                    modifier = Modifier.size(16.dp))
                Spacer(Modifier.width(6.dp))
                Text("Aufzeichnen")
            }
        },
        dismissButton = {
            TextButton(onClick = onDecline) {
                Text("Nein, danke")
            }
        }
    )
}

@Composable
private fun RecordItem(icon: androidx.compose.ui.graphics.vector.ImageVector, text: String) {
    Row(
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            modifier = Modifier.size(16.dp),
            tint = MaterialTheme.colorScheme.primary
        )
        Text(
            text = text,
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}
