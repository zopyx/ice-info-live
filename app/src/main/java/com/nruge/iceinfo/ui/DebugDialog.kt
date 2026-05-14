package com.nruge.iceinfo.ui

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.BugReport
import androidx.compose.material.icons.filled.ContentCopy
import androidx.compose.material.icons.filled.Share
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.core.content.FileProvider
import com.nruge.iceinfo.R
import com.nruge.iceinfo.TrainRepository
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonElement
import java.io.File
import java.time.Instant
import java.time.ZoneId
import java.time.format.DateTimeFormatter

private val prettyJson = Json { prettyPrint = true; ignoreUnknownKeys = true; coerceInputValues = true }

@Composable
fun DebugDialog(onDismiss: () -> Unit) {
    val context = LocalContext.current
    var debugData by remember { mutableStateOf<TrainRepository.DebugData?>(null) }
    var isLoading by remember { mutableStateOf(true) }

    val appVersion = remember {
        try {
            context.packageManager.getPackageInfo(context.packageName, 0).versionName ?: "?"
        } catch (_: PackageManager.NameNotFoundException) { "?" }
    }
    val osVersion = "Android ${Build.VERSION.RELEASE} (API ${Build.VERSION.SDK_INT})"
    val device = "${Build.MANUFACTURER} ${Build.MODEL}"

    LaunchedEffect(Unit) {
        debugData = TrainRepository.fetchDebugData()
        isLoading = false
    }

    val fullShareText = remember(debugData) {
        val data = debugData ?: return@remember ""
        val timestamp = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")
            .withZone(ZoneId.systemDefault())
            .format(Instant.now())
        buildString {
            appendLine("=== ICE Info Debug Report ===")
            appendLine("Zeitstempel: $timestamp")
            appendLine("Betriebssystem: $osVersion")
            appendLine("Gerät: $device")
            appendLine("App-Version: $appVersion")
            appendLine()
            appendLine("--- GET /api1/rs/tripInfo/trip ---")
            if (data.tripError != null) appendLine("FEHLER: ${data.tripError}")
            else appendLine(data.tripRaw)
            appendLine()
            appendLine("--- GET /api1/rs/tripInfo/connection/${data.evaNr} ---")
            if (data.connectionError != null) appendLine("FEHLER: ${data.connectionError}")
            else appendLine(data.connectionRaw)
        }
    }

    AlertDialog(
        onDismissRequest = onDismiss,
        icon = { Icon(Icons.Default.BugReport, contentDescription = null) },
        title = {
            Text(stringResource(R.string.debug_title), fontWeight = FontWeight.Bold)
        },
        text = {
            if (isLoading) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(200.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                        CircularProgressIndicator()
                        Text(
                            text = stringResource(R.string.debug_loading),
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }
            } else {
                val data = debugData
                Column(
                    modifier = Modifier.verticalScroll(rememberScrollState()),
                    verticalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    DebugCard(title = stringResource(R.string.debug_section_device)) {
                        DebugRow(stringResource(R.string.debug_os), osVersion)
                        DebugRow(stringResource(R.string.debug_device), device)
                        DebugRow(stringResource(R.string.debug_app_version), appVersion ?: "?")
                    }

                    DebugCard(title = "GET /api1/rs/tripInfo/trip") {
                        if (data?.tripError != null) {
                            Text(
                                text = data.tripError,
                                style = MaterialTheme.typography.bodySmall,
                                fontFamily = FontFamily.Monospace,
                                color = MaterialTheme.colorScheme.error
                            )
                        } else {
                            Text(
                                text = jsonExcerpt(data?.tripRaw ?: "", lines = 2),
                                style = MaterialTheme.typography.bodySmall,
                                fontFamily = FontFamily.Monospace,
                                color = MaterialTheme.colorScheme.onSurface
                            )
                        }
                    }

                    DebugCard(title = "GET /api1/rs/tripInfo/connection/${data?.evaNr ?: "?"}") {
                        if (data?.connectionError != null) {
                            Text(
                                text = data.connectionError,
                                style = MaterialTheme.typography.bodySmall,
                                fontFamily = FontFamily.Monospace,
                                color = MaterialTheme.colorScheme.error
                            )
                        } else {
                            Text(
                                text = jsonExcerpt(data?.connectionRaw ?: "", lines = 2),
                                style = MaterialTheme.typography.bodySmall,
                                fontFamily = FontFamily.Monospace,
                                color = MaterialTheme.colorScheme.onSurface
                            )
                        }
                    }

                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        OutlinedButton(
                            onClick = {
                                val cb = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
                                cb.setPrimaryClip(ClipData.newPlainText("ICE Debug", fullShareText))
                            },
                            modifier = Modifier.weight(1f)
                        ) {
                            Icon(Icons.Default.ContentCopy, contentDescription = null, modifier = Modifier.size(18.dp))
                            Spacer(Modifier.width(6.dp))
                            Text(stringResource(R.string.debug_copy))
                        }
                        OutlinedButton(
                            onClick = { shareDebugText(context, fullShareText) },
                            modifier = Modifier.weight(1f)
                        ) {
                            Icon(Icons.Default.Share, contentDescription = null, modifier = Modifier.size(18.dp))
                            Spacer(Modifier.width(6.dp))
                            Text(stringResource(R.string.debug_share))
                        }
                    }
                }
            }
        },
        confirmButton = {
            TextButton(onClick = onDismiss) {
                Text(stringResource(R.string.info_close))
            }
        }
    )
}

@Composable
private fun DebugCard(title: String, content: @Composable ColumnScope.() -> Unit) {
    Surface(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(12.dp),
        color = MaterialTheme.colorScheme.surfaceContainerHigh
    ) {
        Column(
            modifier = Modifier.padding(14.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Text(
                text = title,
                style = MaterialTheme.typography.labelMedium,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.primary
            )
            HorizontalDivider(color = MaterialTheme.colorScheme.outlineVariant)
            content()
        }
    }
}

@Composable
private fun DebugRow(label: String, value: String) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Text(
            text = label,
            style = MaterialTheme.typography.bodySmall,
            fontWeight = FontWeight.Medium,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier.width(110.dp)
        )
        Text(
            text = value,
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurface,
            modifier = Modifier.weight(1f)
        )
    }
}

private fun jsonExcerpt(raw: String, lines: Int): String {
    if (raw.isBlank()) return "–"
    return try {
        val element = prettyJson.parseToJsonElement(raw)
        val pretty = prettyJson.encodeToString(JsonElement.serializer(), element)
        pretty.lines()
            .map { it.trimEnd() }
            .filter { trimmed -> trimmed.trim().let { it.isNotEmpty() && it != "{" && it != "}" && it != "[" && it != "]" } }
            .take(lines)
            .joinToString("\n")
    } catch (_: Exception) {
        raw.lines().filter { it.isNotBlank() }.take(lines).joinToString("\n")
    }
}

private fun shareDebugText(context: Context, text: String) {
    val timestamp = DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss")
        .withZone(ZoneId.systemDefault())
        .format(Instant.now())
    val dir = File(context.cacheDir, "debug").also { it.mkdirs() }
    val file = File(dir, "ice_debug_$timestamp.txt")
    file.writeText(text)
    val uri = FileProvider.getUriForFile(context, "${context.packageName}.fileprovider", file)
    val intent = Intent(Intent.ACTION_SEND).apply {
        type = "text/plain"
        putExtra(Intent.EXTRA_STREAM, uri)
        addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
    }
    context.startActivity(Intent.createChooser(intent, context.getString(R.string.debug_share_chooser)))
}
