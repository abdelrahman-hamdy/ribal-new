# Optimized ProGuard rules for maximum size reduction and security
# This file contains aggressive optimization rules for production builds

# Enable aggressive optimization
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
-optimizationpasses 5
-allowaccessmodification
-repackageclasses ''

# Keep essential Flutter classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Parcelable classes
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep Serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.InputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep R8 rules
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keepattributes Signature
-keepattributes Exceptions

# Firebase rules
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Google Play Core library rules
-keep class com.google.android.play.core.** { *; }
-keep interface com.google.android.play.core.** { *; }

# Dio (HTTP client) rules
-keep class retrofit2.** { *; }

# Hive (local storage) rules
-keep class * extends com.google.protobuf.GeneratedMessageLite { *; }

# Shorebird rules
-keep class com.shorebird.** { *; }
-keep class dev.shorebird.** { *; }

# Keep essential model classes
-keep class com.ribal.tasks.** { *; }

# Aggressive obfuscation for security
-repackageclasses 'O'
-allowaccessmodification
-mergeinterfacesaggressively

# Remove logging in production
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# Remove debug information
-renamesourcefileattribute SourceFile

# Keep only essential attributes
-keepattributes *Annotation*,Signature,Exceptions

# Enable aggressive code shrinking
-dontwarn **
-ignorewarnings

# Remove unused code aggressively
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-verbose

# Keep only what's absolutely necessary
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider
-keep public class * extends android.preference.Preference
-keep public class * extends android.view.View
-keep public class * extends android.app.Fragment

# Remove all debug information
-keepattributes !SourceFile,!LineNumberTable

# Enable aggressive string encryption
-adaptclassstrings
-adaptresourcefilenames
-adaptresourcefilecontents
