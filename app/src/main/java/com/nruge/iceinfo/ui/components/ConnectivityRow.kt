package com.nruge.iceinfo.ui.components

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.tooling.preview.Preview
import com.nruge.iceinfo.R
import com.nruge.iceinfo.sampleTrainStatus
import com.nruge.iceinfo.model.TrainStatus
import com.nruge.iceinfo.ui.theme.ICEInfoTheme
import com.nruge.iceinfo.ui.theme.onSuccessContainer
import com.nruge.iceinfo.ui.theme.onWarningContainer
import com.nruge.iceinfo.ui.theme.successContainer
import com.nruge.iceinfo.ui.theme.warningContainer

private data class ConnectivityColors(val container: Color, val content: Color)

@Composable
private fun connectivityColors(connectivity: String): ConnectivityColors {
    return when (connectivity) {
        "STRONG", "HIGH" -> ConnectivityColors(
            container = successContainer(),
            content = onSuccessContainer()
        )
        "WEAK", "MIDDLE" -> ConnectivityColors(
            container = warningContainer(),
            content = onWarningContainer()
        )
        "NO_CONNECTION", "LOW" -> ConnectivityColors(
            container = MaterialTheme.colorScheme.errorContainer,
            content = MaterialTheme.colorScheme.onErrorContainer
        )
        else -> ConnectivityColors(
            container = MaterialTheme.colorScheme.surfaceContainerHigh,
            content = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

@Composable
private fun connectivityLabel(connectivity: String): String = when (connectivity) {
    "STRONG", "HIGH" -> stringResource(R.string.connectivity_strong)
    "MIDDLE", "WEAK" -> stringResource(R.string.connectivity_weak)
    "NO_INFO" -> stringResource(R.string.connectivity_no_info)
    "NO_CONNECTION", "LOW" -> stringResource(R.string.connectivity_none)
    else -> "—"
}

private fun formatRemainingSeconds(seconds: Int?): String {
    if (seconds == null || seconds <= 0) return ""
    val minutes = seconds / 60
    return if (minutes > 0) "~${minutes} min" else "<1 min"
}

@Composable
private fun wagonClassLabel(wagonClass: String): String = when (wagonClass) {
    "FIRST" -> "1"
    "SECOND" -> "2"
    else -> "—"
}

@Composable
fun ConnectivityRow(status: TrainStatus) {
    val colors = connectivityColors(status.connectivity)
    val nextColors = if (status.nextConnectivity != null) {
        connectivityColors(status.nextConnectivity)
    } else null

    AppCard(
        modifier = Modifier
            .fillMaxWidth()
            .height(IntrinsicSize.Min),
        containerColor = MaterialTheme.colorScheme.surface
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = androidx.compose.ui.Alignment.CenterVertically
        ) {
                Column(
                    modifier = Modifier.padding(16.dp),
                    verticalArrangement = Arrangement.spacedBy(4.dp)
                ) {
                    Text(
                        text = stringResource(R.string.wagon_class_label),
                        style = MaterialTheme.typography.labelMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    Text(
                        text = wagonClassLabel(status.wagonClass),
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Bold,
                        color = MaterialTheme.colorScheme.onSurface
                    )
                }
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .fillMaxHeight()
                        .drawBehind {
                            drawRect(color = colors.container)
                            if (nextColors != null) {
                                val path = Path().apply {
                                    moveTo(size.width * 0.70f, 0f)
                                    lineTo(size.width, 0f)
                                    lineTo(size.width, size.height)
                                    lineTo(size.width * 0.80f, size.height)
                                    close()
                                }
                                drawPath(path, color = nextColors.container)
                            }
                        }
                        .padding(16.dp)
                ) {
                Column(
                    modifier = Modifier.fillMaxWidth(),
                    verticalArrangement = Arrangement.spacedBy(4.dp)
                ) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Text(
                            text = stringResource(R.string.wifi_label),
                            style = MaterialTheme.typography.labelMedium,
                            color = colors.content.copy(alpha = 0.8f)
                        )
                        if (status.nextConnectivity != null) {
                            Text(
                                text = "➔ ${connectivityLabel(status.nextConnectivity)}",
                                style = MaterialTheme.typography.labelSmall,
                                color = nextColors?.content?.copy(alpha = 0.8f) ?: colors.content.copy(alpha = 0.8f)
                            )
                        }
                    }
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = androidx.compose.ui.Alignment.Bottom
                    ) {
                        Text(
                            text = connectivityLabel(status.connectivity),
                            style = MaterialTheme.typography.titleMedium,
                            fontWeight = FontWeight.Bold,
                            color = colors.content
                        )
                        if (status.connectivityRemainingSeconds != null) {
                            Text(
                                text = "in ${formatRemainingSeconds(status.connectivityRemainingSeconds)}",
                                style = TextStyle(
                                    fontSize = 10.sp,
                                    color = nextColors?.content?.copy(alpha = 0.7f) ?: colors.content.copy(alpha = 0.7f)
                                )
                            )
                        }
                    }
                }
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
fun ConnectivityRowPreview() {
    ICEInfoTheme {
        Box(modifier = Modifier.padding(16.dp)) {
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                ConnectivityRow(status = sampleTrainStatus)
                ConnectivityRow(
                    status = sampleTrainStatus.copy(
                        connectivity = "WEAK",
                        nextConnectivity = "NO_CONNECTION",
                        connectivityRemainingSeconds = 300
                    )
                )
                ConnectivityRow(
                    status = sampleTrainStatus.copy(
                        connectivity = "NO_CONNECTION",
                        nextConnectivity = "STRONG",
                        connectivityRemainingSeconds = 120
                    )
                )
            }
        }
    }
}

@Preview(showBackground = true, uiMode = android.content.res.Configuration.UI_MODE_NIGHT_YES)
@Composable
fun ConnectivityRowDarkPreview() {
    ICEInfoTheme(darkTheme = true) {
        Box(modifier = Modifier.padding(16.dp)) {
            ConnectivityRow(status = sampleTrainStatus)
        }
    }
}
