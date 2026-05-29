package com.nruge.iceinfo

import android.app.Application
import com.google.firebase.Firebase
import com.google.firebase.crashlytics.FirebaseCrashlytics
import com.google.firebase.initialize
import com.nruge.iceinfo.util.IceUtils
import com.nruge.iceinfo.util.SettingsManager

class IceInfoApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        IceUtils.init(this)
        try {
            Firebase.initialize(this)
            FirebaseCrashlytics.getInstance()
                .isCrashlyticsCollectionEnabled = SettingsManager.isCrashReportingEnabled(this)
        } catch (_: Exception) {
            // Firebase nicht verfügbar (z.B. Beta-Build ohne google-services.json Eintrag)
        }
    }
}
