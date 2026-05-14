package com.nruge.iceinfo.ui

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ReportProblem
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import com.nruge.iceinfo.R

/**
 * Asks the user whether to enable anonymous crash reporting via Firebase
 * Crashlytics. Shown on first install and once after every app update.
 */
@Composable
fun CrashReportingConsentDialog(
    onAccept: () -> Unit,
    onDecline: () -> Unit
) {
    AlertDialog(
        onDismissRequest = onDecline,
        icon = { Icon(Icons.Default.ReportProblem, contentDescription = null) },
        title = {
            Text(
                stringResource(R.string.crash_consent_title),
                fontWeight = FontWeight.Bold
            )
        },
        text = { Text(stringResource(R.string.crash_consent_body)) },
        confirmButton = {
            TextButton(onClick = onAccept) {
                Text(stringResource(R.string.crash_consent_accept))
            }
        },
        dismissButton = {
            TextButton(onClick = onDecline) {
                Text(stringResource(R.string.crash_consent_decline))
            }
        }
    )
}
