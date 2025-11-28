plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.ribal.tasks"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        // Enable core library desugaring for flutter_local_notifications
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    signingConfigs {
        create("release") {
            keyAlias = "ribal-key"
            keyPassword = "ribal123456"
            storeFile = file("ribal-release-key.jks")
            storePassword = "ribal123456"
        }
    }

    defaultConfig {
        applicationId = "com.ribal.tasks"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Enable multidex for large apps
        multiDexEnabled = true

        // Enable vector drawables
        vectorDrawables.useSupportLibrary = true
    }

    buildTypes {
        release {
            // Using release signing for Google Play Store
            signingConfig = signingConfigs.getByName("release")

            // TODO: Re-enable after resolving Play Core R8 issues
            isMinifyEnabled = false
            isShrinkResources = false

            // Use optimized ProGuard rules
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")

            // Enable additional optimizations
            isDebuggable = false
            isJniDebuggable = false
            isRenderscriptDebuggable = false
            isPseudoLocalesEnabled = false
            isZipAlignEnabled = true
            isCrunchPngs = true
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Core library desugaring for flutter_local_notifications
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")

    // Multidex support for large apps
    implementation("androidx.multidex:multidex:2.0.1")

    // Play Core libraries for deferred components
    implementation("com.google.android.play:app-update:2.1.0")
    implementation("com.google.android.play:feature-delivery:2.1.0")
    implementation("com.google.android.gms:play-services-tasks:18.0.2")
}

// Fix task ordering issue between extractDeepLinksRelease and processReleaseGoogleServices
afterEvaluate {
    tasks.named("extractDeepLinksRelease").configure {
        mustRunAfter("processReleaseGoogleServices")
    }
}
