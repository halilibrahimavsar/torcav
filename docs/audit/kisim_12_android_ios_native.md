# Kısım 12 — Android & iOS Native

> Kapsam: `android/app/src/main/AndroidManifest.xml`, `android/app/build.gradle.kts`, `ios/Runner/Info.plist`, `firebase.json`, `pubspec.yaml` external dependencies.
>
> **Compliance kritik:** target SDK, izin manifest, Info.plist usage descriptions, release signing, ProGuard/R8.

---

## Uygulanan Düzeltmeler

### B12.1 — `targetSdk = 34` → **35** (K) ✅
**Kanıt:** `android/app/build.gradle.kts:25`
**Tespit:** Google Play Console **2026 itibarıyla yeni app gönderimleri ve güncellemeler için targetSdk 35 (Android 15) zorunlu**.
**Aksiyon:** Yorum eklendi + targetSdk 35. compileSdk zaten 36.

### B12.2 — `NEARBY_WIFI_DEVICES` (Android 13+) izni eklendi (Y) ✅
**Kanıt (Kısım 7 B7.1):**
```xml
<!-- ÖNCE: yok -->
<!-- SONRA: -->
<uses-permission android:name="android.permission.NEARBY_WIFI_DEVICES"
    android:usesPermissionFlags="neverForLocation"
    tools:targetApi="tiramisu" />
```
**Etki:** Android 13+ kullanıcıda Wi-Fi tarama için konum izni gerekmez (modern yol). Mevcut FINE_LOCATION her sürüm için korundu (Dart layer hâlâ `Permission.location` kullanıyor); **TODO yorum eklendi** — sürüm sonrası Dart tarafı API 33+ için `Permission.nearbyWifiDevices`'a geçecek.

### B12.3 — Release ProGuard/R8 minify etkinleştirildi (Y) ✅
**Kanıt:** `build.gradle.kts` release block:
```kotlin
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("debug")  // TODO(prod)
        isMinifyEnabled = true       // ← Yeni
        isShrinkResources = true     // ← Yeni
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro",
        )
    }
}
```
**Aksiyon:** `proguard-rules.pro` eklendi — Kotlin native bridges (MainActivity, PingStabilizerVpnService, MonitoringService), ARCore + Filament + Sceneview, ONNX Runtime, Hive type adapters için keep rules.

### B12.4 — iOS Info.plist eksik usage descriptions (K) ✅
**Kanıt:** Apple App Store reject riski; mevcut metinler aşırı kısa.
**Aksiyon (4 description güncellendi/eklendi):**
- `NSCameraUsageDescription`: "Indoor heatmap surveys — no video or photos leave the device"
- `NSMotionUsageDescription`: "Motion sensors (step counter, barometer) ... stays on the device"
- **YENİ** `NSLocationWhenInUseUsageDescription`: "Used only to read nearby Wi-Fi BSSIDs (Apple requires location)..."
- **YENİ** `NSLocalNetworkUsageDescription`: "Scans local Wi-Fi for devices, ports... only on networks user is authorized to audit"

iOS reject riski (eksik description) giderildi.

### B12.5 — `firebase.json` dead config silindi (Y) ✅
**Kanıt:**
- `firebase.json` mevcut (projectId: torcav-app-2026)
- `lib/firebase_options.dart` yok
- `pubspec.yaml`'da firebase paketi yok (direct)
- `grep "Firebase\.initialize" lib/` → 0 sonuç

Firebase **hiçbir yerde kullanılmıyor**. Config dosyası eski geliştirme aşamasından kalmış.
**Aksiyon:** `git rm firebase.json`.

### B12.6 — `remote_auth_module` + `unified_flutter_features` dead path dep'leri (K) ✅
**Kanıt:**
- Pubspec.yaml'da iki `path:` dependency (yerel `../remote_auth_module`, `../unified_flutter_features`)
- `grep -rn "remote_auth_module\|unified_flutter_features" lib/` → **0 import**
- Bu modüller transitif olarak Firebase Auth + Cloud Firestore çekiyordu
- `dart pub deps` → `firebase_core`, `firebase_auth`, `cloud_firestore` tümü transitive

**Etki kanıtı:**
- Pubspec temizliği sonrası `flutter pub get`: **34 paket kaldırıldı**
- Release APK boyutu: **49.4 MB → 47.2 MB** (-2.2 MB)
- `grep firebase pubspec.lock` → **0 sonuç** (Firebase artık yok)

**Aksiyon:** Pubspec'ten path dep'ler kaldırıldı + yorum eklendi (re-integration için referans).
**Play Store etkisi:** Data Safety formundan Firebase Auth + Firestore beyan zorunluluğu kalktı. Veri toplamadan beyana gerek yok.

---

## Compliance Pozitifleri (Doğrulandı)

### B12.✅1 — Manifest hassas izin temizliği (`tools:node="remove"`)
**Kanıt:** 10 hassas izin kasıtlı olarak kaldırılmış:
```
BODY_SENSORS, HIGH_SAMPLING_RATE_SENSORS, READ/WRITE_EXTERNAL_STORAGE,
RECORD_AUDIO, READ_PHONE_STATE, CALL_PHONE, SEND/RECEIVE_SMS,
FOREGROUND_SERVICE_MEDIA_PROJECTION
```
**Tespit:** Plugin'lerin otomatik injection'ına karşı koruma. Play Store *Minimum permissions* policy ✅.

### B12.✅2 — Foreground service tipleri doğru
**Kanıt:**
- `MonitoringService` → `foregroundServiceType="dataSync"` ✅
- `PingStabilizerVpnService` → `foregroundServiceType="specialUse"` + `PROPERTY_SPECIAL_USE_FGS_SUBTYPE="local_ping_stabilizer_tunnel"` ✅

### B12.✅3 — ARCore optional + uses-feature
**Kanıt:**
```xml
<uses-feature android:name="android.hardware.camera.ar" android:required="false"/>
<meta-data android:name="com.google.ar.core" android:value="optional"/>
```
ARCore olmayan cihazlarda dahi uygulama yüklenir (Sobel fallback'i var).

### B12.✅4 — `<queries>` block url_launcher için
**Kanıt:** Android 11+ package visibility filtering için doğru tanımlı (`http`, `https`, `PROCESS_TEXT`).

### B12.✅5 — minSdk 24, compileSdk 36, JDK 11, R8 + core library desugaring
**Kanıt:** Modern Android toolchain. flutter_secure_storage v10 minSdk 23'ten yüksek değer (24) sorun değil.

### B12.✅6 — ABI filter doğru
**Kanıt:** `abiFilters += listOf("armeabi-v7a", "arm64-v8a")` — sadece Android cihaz ABIs.

---

## Ertelenen — Production Release Engelleyici (Kısım 14)

### B12.7 — Release keystore (signing) henüz yapılandırılmamış (K — Kısım 14)
**Kanıt:** `build.gradle.kts`:
```kotlin
signingConfig = signingConfigs.getByName("debug")  // TODO(prod)
```
**Tespit:** Şu an `flutter build apk --release` debug keystore ile imzalanıyor — **Play Store rejecte eder**.
**Aksiyon:** Kısım 14'te Play Store submit öncesi:
1. `keytool -genkey -v -keystore upload-keystore.jks ...`
2. `android/key.properties` oluştur (gitignore'da)
3. `build.gradle.kts`'de `signingConfigs.release { keyAlias = ..., keyPassword = ..., storeFile = ..., storePassword = ... }` ekle
4. `signingConfig = signingConfigs.getByName("release")`

---

## Kanıt Tablosu

| Bulgu | Komut / Konum | Önce → Sonra |
|---|---|---|
| B12.1 targetSdk | `build.gradle.kts:25` | `34` → `35` |
| B12.2 NEARBY_WIFI_DEVICES | AndroidManifest | yok → eklendi + neverForLocation |
| B12.3 R8 minify | `build.gradle.kts:release` | `isMinifyEnabled` eksik → true + proguard-rules.pro |
| B12.4 iOS Info.plist | `Info.plist` | 2 kısa metin → 4 detaylı description (yeni Location + LocalNetwork) |
| B12.5 firebase.json | `firebase.json` | var (dead) → silindi |
| B12.6 path dep'ler | `pubspec.yaml` | 2 path dep + Firebase transitive → kaldırıldı; **34 paket düştü, APK -2.2 MB** |

**flutter analyze: temiz**
**flutter build apk --release: ✅ 47.2 MB**

---

## Kısım 12 Bulgu Özeti

| Bulgu | Şiddet | Durum |
|---|---|---|
| B12.1 targetSdk 35 | K | ✅ Düzeltildi |
| B12.2 NEARBY_WIFI_DEVICES | Y | ✅ Düzeltildi (Dart layer migrate TODO) |
| B12.3 R8 minify | Y | ✅ Düzeltildi |
| B12.4 iOS Info.plist | K | ✅ Düzeltildi (Location + LocalNetwork) |
| B12.5 firebase.json | Y | ✅ Silindi |
| B12.6 Dead path dep'ler | K | ✅ Silindi (Firebase çıktı, APK -2.2 MB) |
| B12.7 Release keystore | K | Kısım 14'e |
| ✅ Compliance pozitifleri | — | **6** |

**Kısım 12 düzeltme: 6/7 (B12.7 sürüm aşaması).**

Bu kısım denetimin **en yoğun düzeltme kısmı** — 4 kritik + 2 yüksek bulgu giderildi.
