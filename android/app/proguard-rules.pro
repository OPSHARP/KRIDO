# Flutter engine and plugins
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# AndroidX Startup & WorkManager
-keep class androidx.startup.** { *; }
-keep class androidx.work.** { *; }
-keep class androidx.work.impl.** { *; }
-keep class * extends androidx.work.Worker { *; }
-keep class * extends androidx.work.ListenableWorker { *; }
-keep class * extends androidx.work.impl.WorkDatabase { *; }
-keep class androidx.work.impl.WorkDatabase_Impl {
    public <init>();
    public *;
}
-keepclassmembers class androidx.work.impl.WorkDatabase {
    public *;
}

# AndroidX Room
-keep class * extends androidx.room.RoomDatabase { *; }
-dontwarn androidx.room.paging.**
-dontwarn androidx.work.impl.**

# Google Mobile Ads (AdMob)
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

# Flutter Plugins (TTS, AudioPlayers, SQLite)
-keep class com.tundralabs.fluttertts.** { *; }
-keep class xyz.luan.audioplayers.** { *; }
-keep class com.tekartik.sqflite.** { *; }

# Google Play Core Split Install & Tasks (Flutter Engine References)
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**
