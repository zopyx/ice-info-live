package com.nruge.iceinfo.widget

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.intPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.GlanceTheme
import androidx.glance.action.actionStartActivity
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.cornerRadius
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.currentState
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.width
import androidx.glance.state.GlanceStateDefinition
import androidx.glance.state.PreferencesGlanceStateDefinition
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.LocalContext
import com.nruge.iceinfo.MainActivity
import com.nruge.iceinfo.R

class TrainWidget : GlanceAppWidget() {

    override val stateDefinition: GlanceStateDefinition<*> = PreferencesGlanceStateDefinition

    companion object {
        val KEY_CONNECTED       = booleanPreferencesKey("isConnected")
        val KEY_TRAIN_NAME      = stringPreferencesKey("trainName")
        val KEY_SPEED           = intPreferencesKey("speed")
        val KEY_NEXT_STOP       = stringPreferencesKey("nextStop")
        val KEY_NEXT_STOP_EVA   = stringPreferencesKey("nextStopEva")
        val KEY_NEXT_STOP_ETA   = stringPreferencesKey("nextStopEta")
        val KEY_TARGET_STOP     = stringPreferencesKey("targetStop")
        val KEY_TARGET_STOP_EVA = stringPreferencesKey("targetStopEva")
        val KEY_DELAY           = intPreferencesKey("delay")
        val KEY_MOCK_MODE       = booleanPreferencesKey("isMockMode")
    }

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            GlanceTheme {
                val prefs = currentState<androidx.datastore.preferences.core.Preferences>()
                TrainWidgetContent(prefs)
            }
        }
    }

    @Composable
    private fun TrainWidgetContent(prefs: androidx.datastore.preferences.core.Preferences) {
        val isConnected   = prefs[KEY_CONNECTED] ?: false
        val trainName     = prefs[KEY_TRAIN_NAME] ?: ""
        val speed         = prefs[KEY_SPEED] ?: 0
        val nextStop      = prefs[KEY_NEXT_STOP] ?: ""
        val nextStopEva   = prefs[KEY_NEXT_STOP_EVA] ?: ""
        val nextStopEta   = prefs[KEY_NEXT_STOP_ETA] ?: ""
        val targetStop    = prefs[KEY_TARGET_STOP] ?: ""
        val targetStopEva = prefs[KEY_TARGET_STOP_EVA] ?: ""
        val delay         = prefs[KEY_DELAY] ?: 0
        val isMockMode    = prefs[KEY_MOCK_MODE] ?: false

        val isAtTarget = targetStopEva.isNotEmpty() && nextStopEva == targetStopEva

        Box(
            modifier = GlanceModifier
                .fillMaxSize()
                .background(GlanceTheme.colors.widgetBackground)
                .cornerRadius(28.dp)
                .clickable(actionStartActivity<MainActivity>())
                .padding(16.dp)
        ) {
            if (!isConnected && !isMockMode) {
                DisconnectedState()
            } else {
                Column(modifier = GlanceModifier.fillMaxSize()) {
                    // Header row: train chip + demo chip
                    Row(
                        modifier = GlanceModifier.fillMaxWidth(),
                        verticalAlignment = Alignment.Vertical.CenterVertically
                    ) {
                        if (trainName.isNotBlank()) {
                            TrainChip(trainName)
                        }
                        Spacer(GlanceModifier.defaultWeight())
                        if (isMockMode) {
                            DemoChip()
                        }
                    }

                    Spacer(GlanceModifier.height(10.dp))

                    // Hero speed
                    Row(verticalAlignment = Alignment.Vertical.Bottom) {
                        Text(
                            text = "$speed",
                            style = TextStyle(
                                fontSize = 44.sp,
                                fontWeight = FontWeight.Bold,
                                color = GlanceTheme.colors.primary
                            )
                        )
                        Spacer(GlanceModifier.width(4.dp))
                        Text(
                            text = "km/h",
                            style = TextStyle(
                                fontSize = 13.sp,
                                fontWeight = FontWeight.Medium,
                                color = GlanceTheme.colors.onSurfaceVariant
                            ),
                            modifier = GlanceModifier.padding(bottom = 9.dp)
                        )
                    }

                    Spacer(GlanceModifier.height(10.dp))

                    if (isAtTarget) {
                        ExitAlert()
                    } else {
                        val context = LocalContext.current
                        InfoSection(
                            label = context.getString(R.string.widget_next_stop),
                            value = nextStop.ifBlank { context.getString(R.string.notif_no_eta) },
                            trailing = {
                                if (nextStopEta.isNotEmpty()) {
                                    EtaPill(eta = nextStopEta, delayMinutes = delay)
                                } else {
                                    DelayPill(delayMinutes = delay)
                                }
                            }
                        )

                        Spacer(GlanceModifier.height(6.dp))

                        InfoSection(
                            label = context.getString(R.string.home_target_title),
                            value = if (targetStop.isNotEmpty()) targetStop
                                    else context.getString(R.string.widget_target_not_chosen),
                            valueMuted = targetStop.isEmpty()
                        )
                    }
                }
            }
        }
    }

    @Composable
    private fun DisconnectedState() {
        val context = LocalContext.current
        Box(
            modifier = GlanceModifier.fillMaxSize(),
            contentAlignment = Alignment.Center
        ) {
            Column(horizontalAlignment = Alignment.Horizontal.CenterHorizontally) {
                Text(
                    text = context.getString(R.string.widget_no_connection),
                    style = TextStyle(
                        fontSize = 14.sp,
                        fontWeight = FontWeight.Medium,
                        color = GlanceTheme.colors.onSurface
                    )
                )
                Spacer(GlanceModifier.height(2.dp))
                Text(
                    text = context.getString(R.string.widget_tap_to_connect),
                    style = TextStyle(
                        fontSize = 11.sp,
                        color = GlanceTheme.colors.onSurfaceVariant
                    )
                )
            }
        }
    }

    @Composable
    private fun TrainChip(name: String) {
        Box(
            modifier = GlanceModifier
                .background(GlanceTheme.colors.secondaryContainer)
                .cornerRadius(8.dp)
                .padding(horizontal = 8.dp, vertical = 3.dp)
        ) {
            Text(
                text = name,
                style = TextStyle(
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Bold,
                    color = GlanceTheme.colors.onSecondaryContainer
                )
            )
        }
    }

    @Composable
    private fun DemoChip() {
        Box(
            modifier = GlanceModifier
                .background(GlanceTheme.colors.tertiaryContainer)
                .cornerRadius(8.dp)
                .padding(horizontal = 8.dp, vertical = 3.dp)
        ) {
            Text(
                text = LocalContext.current.getString(R.string.widget_demo_chip),
                style = TextStyle(
                    fontSize = 10.sp,
                    fontWeight = FontWeight.Bold,
                    color = GlanceTheme.colors.onTertiaryContainer
                )
            )
        }
    }

    @Composable
    private fun InfoSection(
        label: String,
        value: String,
        valueMuted: Boolean = false,
        trailing: (@Composable () -> Unit)? = null
    ) {
        Box(
            modifier = GlanceModifier
                .fillMaxWidth()
                .background(GlanceTheme.colors.surfaceVariant)
                .cornerRadius(16.dp)
                .padding(horizontal = 12.dp, vertical = 10.dp)
        ) {
            Row(
                modifier = GlanceModifier.fillMaxWidth(),
                verticalAlignment = Alignment.Vertical.CenterVertically
            ) {
                Column(modifier = GlanceModifier.defaultWeight()) {
                    Text(
                        text = label,
                        style = TextStyle(
                            fontSize = 10.sp,
                            fontWeight = FontWeight.Medium,
                            color = GlanceTheme.colors.onSurfaceVariant
                        )
                    )
                    Spacer(GlanceModifier.height(2.dp))
                    Text(
                        text = value,
                        style = TextStyle(
                            fontSize = 15.sp,
                            fontWeight = FontWeight.Bold,
                            color = if (valueMuted) GlanceTheme.colors.onSurfaceVariant
                                    else GlanceTheme.colors.onSurface
                        ),
                        maxLines = 1
                    )
                }
                if (trailing != null) {
                    Spacer(GlanceModifier.width(8.dp))
                    trailing()
                }
            }
        }
    }

    @Composable
    private fun EtaPill(eta: String, delayMinutes: Int) {
        val (containerColor, textColor) = when {
            delayMinutes >= 5 -> GlanceTheme.colors.errorContainer to GlanceTheme.colors.onErrorContainer
            delayMinutes > 0  -> GlanceTheme.colors.secondaryContainer to GlanceTheme.colors.onSecondaryContainer
            else              -> GlanceTheme.colors.primaryContainer to GlanceTheme.colors.onPrimaryContainer
        }
        Box(
            modifier = GlanceModifier
                .background(containerColor)
                .cornerRadius(10.dp)
                .padding(horizontal = 8.dp, vertical = 4.dp)
        ) {
            Text(
                text = if (delayMinutes > 0) "$eta  +$delayMinutes min" else eta,
                style = TextStyle(
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Bold,
                    color = textColor
                )
            )
        }
    }

    @Composable
    private fun DelayPill(delayMinutes: Int) {
        val context = LocalContext.current
        val (containerColor, textColor, label) = when {
            delayMinutes >= 5 -> Triple(
                GlanceTheme.colors.errorContainer,
                GlanceTheme.colors.onErrorContainer,
                context.getString(R.string.widget_delay_format, delayMinutes)
            )
            delayMinutes > 0 -> Triple(
                GlanceTheme.colors.secondaryContainer,
                GlanceTheme.colors.onSecondaryContainer,
                context.getString(R.string.widget_delay_format, delayMinutes)
            )
            else -> Triple(
                GlanceTheme.colors.primaryContainer,
                GlanceTheme.colors.onPrimaryContainer,
                context.getString(R.string.travel_on_time)
            )
        }
        Box(
            modifier = GlanceModifier
                .background(containerColor)
                .cornerRadius(10.dp)
                .padding(horizontal = 8.dp, vertical = 4.dp)
        ) {
            Text(
                text = label,
                style = TextStyle(
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Bold,
                    color = textColor
                )
            )
        }
    }

    @Composable
    private fun ExitAlert() {
        val context = LocalContext.current
        Box(
            modifier = GlanceModifier
                .fillMaxWidth()
                .background(GlanceTheme.colors.primaryContainer)
                .cornerRadius(16.dp)
                .padding(horizontal = 14.dp, vertical = 12.dp)
        ) {
            Column {
                Text(
                    text = context.getString(R.string.widget_exit_now_title),
                    style = TextStyle(
                        fontSize = 14.sp,
                        fontWeight = FontWeight.Bold,
                        color = GlanceTheme.colors.onPrimaryContainer
                    )
                )
                Spacer(GlanceModifier.height(2.dp))
                Text(
                    text = context.getString(R.string.widget_exit_now_subtitle),
                    style = TextStyle(
                        fontSize = 11.sp,
                        color = GlanceTheme.colors.onPrimaryContainer
                    )
                )
            }
        }
    }
}
