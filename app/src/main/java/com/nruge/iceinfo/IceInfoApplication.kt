package com.nruge.iceinfo

import android.app.Application
import com.google.firebase.crashlytics.FirebaseCrashlytics
import com.nruge.iceinfo.util.IceUtils
import com.nruge.iceinfo.util.SettingsManager

class IceInfoApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        IceUtils.init(this)
        FirebaseCrashlytics.getInstance()
            .isCrashlyticsCollectionEnabled = SettingsManager.isCrashReportingEnabled(this)
    }
}
