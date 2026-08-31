import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing credentials, kept out of the repo.
//
// Create android/key.properties (gitignored) with:
//   storeFile=/absolute/path/to/torcav-release.jks
//   storePassword=...
//   keyAlias=torcav
//   keyPassword=...
//
// Generate the keystore once and back it up somewhere durable — losing it
// means never being able to update the Play Store listing again:
//   keytool -genkey -v -keystore torcav-release.jks -keyalg RSA \
//           -keysize 2048 -validity 10000 -alias torcav
//
// Without the file the release build still works and signs with the debug
// key, so `flutter run --release` keeps working for local profiling — but
// such a build cannot be uploaded to the Play Store.
val keystoreProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) file.inputStream().use { load(it) }
}
val hasReleaseKeystore = keystoreProperties.getProperty("storeFile") != null

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

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            // Real keystore when android/key.properties is present, debug key
            // otherwise. The fallback keeps `flutter run --release` working
            // for local profiling; a debug-signed build is NOT uploadable.
            signingConfig =
                if (hasReleaseKeystore) {
                    signingConfigs.getByName("release")
                } else {
                    signingConfigs.getByName("debug")
                }
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

    // JVM unit tests for the pure native rules (StabilizerAlertRules). These
    // run without a device or Robolectric — the rules carry no Android types
    // precisely so that stays true.
    testImplementation("junit:junit:4.13.2")

    // Background monitoring ticks (MonitoringWorker). WorkManager survives
    // Doze + reboots and has no foreground-service time cap.
    implementation("androidx.work:work-runtime-ktx:2.10.1")

    // Native ARCore scene view (replaces deprecated Sceneform).
    // SceneView wraps ARCore + Filament so we can ship a PlatformView that
    // streams real vertical-plane polygons into Dart via EventChannel.
    implementation("io.github.sceneview:arsceneview:2.2.1")
    implementation("com.google.ar:core:1.45.0")
}
