plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "dev.halilibrahim.torcav"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "dev.halilibrahim.torcav"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = maxOf(flutter.minSdkVersion, 24)
        // Play Console requires targetSdk 35 (Android 15) for new app
        // submissions and updates starting 2026.
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        ndk {
            // Sceneform/ARCore legacy plugins usually only support these architectures.
            abiFilters += listOf("armeabi-v7a", "arm64-v8a")
        }
    }

    packaging {
        jniLibs {
            // Required for legacy Sceneform native libraries to be loaded correctly on AGP 8.0+
            useLegacyPackaging = true
        }
    }

    buildTypes {
        release {
            // TODO(prod): replace with a real release keystore before Play Store
            // submission. Signing with debug keys for now so `flutter run
            // --release` works for local profiling.
            signingConfig = signingConfigs.getByName("debug")
            // R8 (code shrinker + obfuscator) + resource shrinker. Reduces
            // APK/AAB size and removes unused symbols. Flutter ships a
            // proguard-rules baseline; add app-specific keep rules in
            // android/app/proguard-rules.pro if needed.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // Background monitoring ticks (MonitoringWorker). WorkManager survives
    // Doze + reboots and has no foreground-service time cap.
    implementation("androidx.work:work-runtime-ktx:2.10.1")

    // Native ARCore scene view (replaces deprecated Sceneform).
    // SceneView wraps ARCore + Filament so we can ship a PlatformView that
    // streams real vertical-plane polygons into Dart via EventChannel.
    implementation("io.github.sceneview:arsceneview:2.2.1")
    implementation("com.google.ar:core:1.45.0")
}
