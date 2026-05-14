# ICE Info Live — ProGuard / R8 rules

# Keep line numbers for crash reports, but hide source file names.
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# Strip verbose/debug logging in release builds.
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# ---------------------------------------------------------------
# kotlinx.serialization
# ---------------------------------------------------------------
-keepattributes *Annotation*, InnerClasses
-dontnote kotlinx.serialization.AnnotationsKt

-if @kotlinx.serialization.Serializable class **
-keepclassmembers class <1> {
    static <1>$Companion Companion;
}

-if @kotlinx.serialization.Serializable class ** {
    static **$* *;
}
-keepclassmembers class <2>$<3> {
    kotlinx.serialization.KSerializer serializer(...);
}

-if @kotlinx.serialization.Serializable class **
-keepclassmembers class <1> {
    public static ** INSTANCE;
    kotlinx.serialization.KSerializer serializer(...);
}

# Keep all model classes used by ktor/serialization.
-keep,includedescriptorclasses class com.nruge.iceinfo.model.** { *; }
-keep,includedescriptorclasses class com.nruge.iceinfo.TrainRepository$DebugData { *; }

# ---------------------------------------------------------------
# Ktor / OkHttp
# ---------------------------------------------------------------
-dontwarn io.ktor.**
-dontwarn org.slf4j.**
-keep class io.ktor.client.engine.okhttp.** { *; }

-dontwarn okhttp3.internal.platform.**
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**

# ---------------------------------------------------------------
# Glance / AppWidget
# ---------------------------------------------------------------
-keep class androidx.glance.** { *; }
-keep class com.nruge.iceinfo.widget.** { *; }

# ---------------------------------------------------------------
# osmdroid
# ---------------------------------------------------------------
-keep class org.osmdroid.** { *; }
-dontwarn org.osmdroid.**

# ---------------------------------------------------------------
# Google Play in-app updates
# ---------------------------------------------------------------
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# ---------------------------------------------------------------
# Room / WorkManager
# WorkManager is pulled in transitively (Glance, Firebase) and uses Room.
# Room loads generated `_Impl` classes via reflection — without these
# keep rules WorkDatabase fails to instantiate at app startup.
# ---------------------------------------------------------------
-keep class * extends androidx.room.RoomDatabase {
    <init>();
}
-keep @androidx.room.Entity class *
-keep class **_Impl { *; }
-dontwarn androidx.room.paging.**

-keep class androidx.work.** { *; }
-keep class androidx.work.impl.** { *; }
-keep class * extends androidx.work.Worker
-keep class * extends androidx.work.ListenableWorker {
    public <init>(...);
}
-keepclassmembers class * extends androidx.work.Worker {
    public <init>(android.content.Context, androidx.work.WorkerParameters);
}

# ---------------------------------------------------------------
# Firebase Crashlytics
# ---------------------------------------------------------------
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Keep the Application class — referenced by manifest, but defensive.
-keep class com.nruge.iceinfo.IceInfoApplication { *; }
