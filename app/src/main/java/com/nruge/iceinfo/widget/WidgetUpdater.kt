package com.nruge.iceinfo.widget

import android.content.Context
import androidx.glance.appwidget.GlanceAppWidgetManager
import androidx.glance.appwidget.state.updateAppWidgetState
import androidx.glance.appwidget.updateAll
import com.nruge.iceinfo.model.TrainStatus
import com.nruge.iceinfo.sampleTrainStatus
import com.nruge.iceinfo.util.SettingsManager
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

object WidgetUpdater {

    // Single managed scope — lives for the process lifetime, never leaks
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.IO)

    fun update(context: Context, status: TrainStatus, isMockMode: Boolean, targetStopName: String?) {
        scope.launch {
            // Authoritative source for mock mode is the app settings — overrides
            // whatever the caller passed, so the widget stays consistent even
            // when the notification service pushes real data in parallel.
            val effectiveMock = isMockMode || SettingsManager.isMockMode(context)
            val targetEva = SettingsManager.getTargetStopEva(context)

            val effectiveStatus: TrainStatus
            val effectiveTargetName: String?
            if (effectiveMock) {
                val demoStatus = sampleTrainStatus.copy(
                    isConnected = true,
                    speed = SettingsManager.getDemoSpeed(context),
                    targetStopEva = targetEva
                )
                effectiveStatus = demoStatus
                effectiveTargetName = demoStatus.stops.find { it.evaNr == targetEva }?.name
            } else {
                effectiveStatus = status
                effectiveTargetName = targetStopName
            }

            val manager = GlanceAppWidgetManager(context)
            val glanceIds = manager.getGlanceIds(TrainWidget::class.java)

            glanceIds.forEach { glanceId ->
                updateAppWidgetState(context, glanceId) { prefs ->
                    prefs[TrainWidget.KEY_CONNECTED]       = effectiveStatus.isConnected
                    prefs[TrainWidget.KEY_TRAIN_NAME]      = "${effectiveStatus.trainType} ${effectiveStatus.trainNumber}"
                    prefs[TrainWidget.KEY_SPEED]           = effectiveStatus.speed
                    prefs[TrainWidget.KEY_NEXT_STOP]       = effectiveStatus.nextStop
                    prefs[TrainWidget.KEY_NEXT_STOP_EVA]   = effectiveStatus.nextStopEva
                    prefs[TrainWidget.KEY_NEXT_STOP_ETA]   = effectiveStatus.eta
                    prefs[TrainWidget.KEY_TARGET_STOP]     = effectiveTargetName ?: ""
                    prefs[TrainWidget.KEY_TARGET_STOP_EVA] = effectiveStatus.targetStopEva ?: ""
                    prefs[TrainWidget.KEY_DELAY]           = effectiveStatus.delayMinutes
                    prefs[TrainWidget.KEY_MOCK_MODE]       = effectiveMock
                }
            }
            TrainWidget().updateAll(context)
        }
    }
}
