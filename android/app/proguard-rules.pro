# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Firebase rules
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Google Play Core library rules
-keep class com.google.android.play.core.** { *; }
-keep interface com.google.android.play.core.** { *; }

# Dio (HTTP client) rules
-keep class retrofit2.** { *; }
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions

# Hive (local storage) rules
-keep class * extends com.google.protobuf.GeneratedMessageLite { *; }

# ============================================
# Shorebird Code Push ProGuard Rules
# ============================================

# Keep Shorebird updater classes
-keep class io.shorebird.** { *; }
-keep interface io.shorebird.** { *; }
-keep class dev.shorebird.** { *; }
-dontwarn dev.shorebird.**

# Preserve annotations for entry points
-keepattributes RuntimeVisibleAnnotations
-keepattributes RuntimeInvisibleAnnotations

# Keep FCM background handler (CRITICAL for Ribal app)
# The @pragma('vm:entry-point') annotation in lib/main.dart
# must be preserved through ProGuard optimization
-keep class io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingBackgroundService { *; }

# Preserve @pragma annotations
-keepclassmembers class * {
    @pragma <methods>;
}

# Keep native method names for Shorebird
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Flutter engine classes used by Shorebird
-keep class io.flutter.embedding.engine.FlutterEngine { *; }
-keep class io.flutter.embedding.android.FlutterActivity { *; } 