## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

## flutter_local_notifications
-keep class com.dexterous.** { *; }
-keep class androidx.core.app.** { *; }

## Notification related
-keep class * extends android.app.Service
-keep class * extends android.content.BroadcastReceiver

## Prevent obfuscation of notification models
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

## Google Play Core (for deferred components)
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**
-keep class com.google.android.play.core.** { *; }
