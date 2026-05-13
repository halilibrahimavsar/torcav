# Kısım 14 — Play Store Final Denetim & Konsolidasyon

> **Denetim tarihi:** 2026-05-12 / 2026-05-13
> **Kapsam:** Tüm Kısım 0-13 bulgularının konsolidasyonu, Play Store submit hazırlığı, manifest ↔ privacy policy çapraz kontrol, final checklist.

---

## 🎯 Denetim Genel Sonuç

**14 kısım, ~120+ bulgu işlendi. Net repo etkisi:**

| Metrik | Değer |
|---|---|
| Toplam denetim commit'i | **22** (Kısım 0-13) |
| Doğrulanmış bulgu | **~120** |
| Düzeltme uygulanan | **~50** |
| Halüsinasyon iptali (kanıt-tabanlı doğrulama) | **8** |
| Backlog'a ertelenen | **~25** (sürüm sonrası refactor) |
| Compliance pozitifi doğrulanan ✅ | **70+** |
| Sürüm engelleyici kalmış kritik | **1** (release keystore, B12.7) |
| Repo'dan silinen ölü kod | **~700 satır** |
| APK boyutu azalması | **49.4 MB → 47.2 MB** (-2.2 MB) |
| ARB key | 1641 → 1516 (-125 dead key) |
| `debugPrint`/`print` kalıntısı | 6 → **0** |

---

## 📋 Kısım-Bazlı Özet

| Kısım | Bulgu | Düzeltme | Vurgular |
|---|---|---|---|
| **0** Kök temizlik | 8 | 7 | `scratch/`, `testsprite_tests/`, geçmiş analiz çıktıları |
| **1** Core I | 10 | 5 | `runZonedGuarded`, `kReleaseMode` logger gating, iOS UnsupportedError, Equatable halüsinasyon iptal |
| **2** Core II | 3 | 1 | 4 boş `core/` klasörü silindi |
| **3** Localization | 9 | 5 | **125 ölü ARB key**, 7 `.txt` artığı, placeholder metadata bug, 353 untranslated → backlog |
| **4** Tema/UI | 6 | 3 | Shader + 2 ölü widget, ProminentDisclosureDialog widget compliance ✅ |
| **5** Storage 🔴 | 10 | 7 | **Hive AES encryption**, secureStorage hive key, DB auto-heal flag, NotificationService Android perm metodu |
| **6** Splash/Onboarding 🔴 | 10 | 5 | **OnboardingPage routing** (Play ihlali fix), _NotificationsPage, healSnackBar, package_info_plus |
| **7** Wi-Fi/Network 🟢 | 8 | 0 | 5 ✅ pozitif — disclosure + permission akışı doğru, PII logging YOK |
| **8a** Security engines 🟢 | 9 (v2) | 2 | CaptivePortalDetector dead → bağlandı, HardeningCheckMeta dead fields silindi |
| **8b** Vuln DB & AI 🟢 | 7 | 0 | 8 ✅ — AI on-device, vuln DB local-asset, ONNX memory yönetimi |
| **8c** Security UI | 7 | 3 | SecurityReport dead chain silindi (~70 satır), EvilTwinExplanation 7/8 field dead silindi (~190 satır) |
| **9** Monitoring/Diagnostics/Ping 🔴 | 5 | 1 | **VPN prominent disclosure** + 6 ARB key x 4 dil |
| **10** Dashboard/Reports/Performance | 5 | 1 | PDF lock `Random.secure()` salt, LocalDataExportService GDPR-uyumlu ✅ |
| **11** Settings/Heatmap 🟢 | 4 | 1 | 6 ✅ — Wipe All Data, Privacy Policy URL, heatmap 3-izin disclosure, **TÜM debugPrint = 0** |
| **12** Android/iOS native 🔴 | 7 | 6 | **targetSdk 35**, **NEARBY_WIFI_DEVICES**, R8 minify, **Firebase çıkarıldı** (-34 paket, -2.2 MB) |
| **13** Test/CI/CD | 6 | 1 | analysis_options.yaml 17 yeni lint kuralı |

🔴 = denetimin en yoğun düzeltme kısımları
🟢 = kanıtla beklenenden çok daha temiz çıkan kısımlar

---

## 🔍 Halüsinasyon Doğrulama Özeti

GPT roadmap'leri ile başlanan denetimde **8 büyük halüsinasyon yakalandı**:

| # | Kısım | İddia | Gerçek |
|---|---|---|---|
| 1 | 1 (B1.5) | `Failure` Equatable bug | Equatable kaynağı zaten `runtimeType` kontrol ediyor |
| 2 | 1 (B1.8) | `AndroidOptions()` zayıf encryption | flutter_secure_storage 10.x default AES_GCM + RSA_OAEP |
| 3 | 5 (B5.10) | PRAGMA SQL injection | UUID v4 sadece `[0-9a-f-]`, escape var, güvenli |
| 4 | 8a (B8a.✅4) | CaptivePortalDetector çalışıyor | DI'a kayıtlı ama hiç çağrılmıyor → dead code (sonra bağlandı) |
| 5 | 8a (B8a.2) | hardening_check 20 hardcoded UI'da | UI `meta.id.title(context)` l10n çağırıyor; alanlar dead fields |
| 6 | 8c (B8a.1) | security_analyzer 29 hardcoded UI'da | `vulnerability_extensions.dart` ruleId → l10n switch yapıyor |
| 7 | 8c (B8a.3) | evil_twin_explainer 8 hardcoded UI'da | UI `assessment` üzerinden l10n switch yapıyor; 7/8 field dead |
| 8 | 8c (B8a.5) | dns_test_data_source UI'da | UI `l10n.dnsSecure/Warning/ReadyStatus` kullanıyor |

**Ders:** GPT roadmap'leri "hardcoded var → kullanıcıya gidiyor" varsayımı yapıyordu. Gerçekte UI tarafında zaten ruleId/enum switch ile lokalize var. Kanıt-tabanlı doğrulama ile **yanlış refactor'lerin önüne geçildi** (örn. 50+ ARB key tasarlanması, dead code'u canlandırma).

---

## 🛡️ Compliance Çapraz Kontrol (Manifest ↔ Privacy ↔ Code)

### Android İzinleri ↔ Privacy Policy ↔ Kullanım Yeri

| Manifest İzni | Privacy Policy bölümü | UI disclosure | Kod kullanım |
|---|---|---|---|
| `NEARBY_WIFI_DEVICES` (neverForLocation) | §2.1 Wi-Fi metadata | `wifi_scan_page` ProminentDisclosureDialog | Wi-Fi scan API |
| `ACCESS_FINE_LOCATION` | §2.1 Wi-Fi metadata | aynı | Android <13 Wi-Fi scan |
| `ACCESS_WIFI_STATE` / `CHANGE_WIFI_STATE` | §2.1 | implicit | Wi-Fi state read/scan trigger |
| `INTERNET` | §3 Outbound endpoints | implicit | 4 endpoint (captive, DoH, speed, DNS) |
| `CAMERA` | §2.6 AR-only, frames not stored | `new_session_dialog` ProminentDisclosure | AR pose tracking |
| `ACTIVITY_RECOGNITION` | §2.5 Motion | aynı dialog | Step counter (heatmap) |
| `POST_NOTIFICATIONS` | §2.4 Notifications | Onboarding `_NotificationsPage` (K6) | Security alerts + stabilizer |
| `FOREGROUND_SERVICE_DATA_SYNC` | §3.4 Background monitoring | Settings → Privacy → Background monitoring (opt-in, default OFF) | `MonitoringService` |
| `FOREGROUND_SERVICE_SPECIAL_USE` + `BIND_VPN_SERVICE` | §3.5 Ping stabilizer (local-only VPN) | `stabilizer_toggle_card` ProminentDisclosure (K9) | Local DNS routing tunnel |

**Sonuç:** Tüm manifest izinleri için **Privacy Policy maddesi VAR** + **Disclosure UI VAR** + **Kullanım yeri kod tarafında doğrulandı**. Üçlü uyum sağlanıyor.

### Privacy Policy değişiklikleri gerek mi?
- ✅ Mevcut PRIVACY_POLICY.md (12 KB) detaylı, contact email + KVKK/GDPR var
- ✅ Tüm veri kategorileri belirtilmiş
- ⚠️ Versiyon bilgisi `1.0` (Effective date: 2026-05-08) — Kısım 5 Hive AES + Kısım 12 NEARBY_WIFI yansıtılmamış olabilir
- **Aksiyon:** Privacy Policy'yi minor update yap (örneğin **1.1**, effective date 2026-05-13) ve "encryption at rest" bölümünü genişlet:
  - Mevcut metin: "encrypted at rest using SQLCipher"
  - Yeni metin: "encrypted at rest using SQLCipher (database) and Hive AES-256 (preferences)"

---

## 🚨 Sürüm Engelleyici Kalan (1 kritik)

### B12.7 — Release Keystore Yapılandırması
**Durum:** `build.gradle.kts` hâlâ debug keystore ile imzalıyor:
```kotlin
signingConfig = signingConfigs.getByName("debug")  // TODO(prod)
```

**Çözüm adımları (sürüm öncesi mutlaka):**
1. **Keystore oluştur:**
   ```bash
   keytool -genkey -v -keystore ~/torcav-upload-keystore.jks \
     -keyalg RSA -keysize 2048 -validity 10000 \
     -alias torcav-upload
   ```
2. **`android/key.properties`** (gitignore'da olacak):
   ```properties
   storePassword=<store password>
   keyPassword=<key password>
   keyAlias=torcav-upload
   storeFile=/home/garuda/torcav-upload-keystore.jks
   ```
3. **`build.gradle.kts`** güncelle:
   ```kotlin
   val keystoreProperties = Properties().apply {
     val file = rootProject.file("key.properties")
     if (file.exists()) load(file.inputStream())
   }

   android {
     signingConfigs {
       create("release") {
         keyAlias = keystoreProperties["keyAlias"] as String
         keyPassword = keystoreProperties["keyPassword"] as String
         storeFile = file(keystoreProperties["storeFile"] as String)
         storePassword = keystoreProperties["storePassword"] as String
       }
     }
     buildTypes {
       release {
         signingConfig = signingConfigs.getByName("release")
         ...
       }
     }
   }
   ```
4. **`.gitignore`'a ekle:** `android/key.properties`, `*.jks`
5. **CI release pipeline** (opsiyonel): GitHub Actions secret'lerle (`KEYSTORE_BASE64`, `KEY_PASSWORD`, vb.) — manual `workflow_dispatch` ile.

---

## 📋 Sürüm Öncesi Final Checklist

### Kod hijyeni
- [x] Tüm `debugPrint`/`print` kalıntıları silindi (Kısım 11 milestone)
- [x] `flutter analyze` temiz (0 error/warning; 269 info — sürüm sonrası `dart fix --apply`)
- [x] `flutter build apk --release` ✅ (47.2 MB)
- [x] Generated kod güncel (`build_runner` + `gen-l10n`)
- [ ] **Release keystore oluştur** (B12.7)

### Manifest & Native
- [x] `targetSdk = 35`
- [x] `NEARBY_WIFI_DEVICES + neverForLocation`
- [x] R8 minify + resource shrink etkin
- [x] `proguard-rules.pro` mevcut
- [x] 10 hassas izin `tools:node="remove"`
- [x] iOS Info.plist: Camera + Motion + Location + LocalNetwork usage descriptions
- [x] ARCore optional + uses-feature required=false
- [x] Foreground service tipleri doğru (dataSync, specialUse + subtype)

### Compliance (Play Store)
- [x] **Privacy Policy public URL** mevcut: `halirlnj.github.io/torcav-privacy/`
- [x] **Contact email** mevcut: `halirlnj@gmail.com`
- [x] **Onboarding zorunlu** (Kısım 6 — ToS + Privacy + Age + Authorization)
- [x] **Wipe All Local Data** (Kısım 11)
- [x] **Export Local Data** (Kısım 10 — 12 kategori, JSON/CSV/HTML, anonymize toggle)
- [x] **3 ProminentDisclosureDialog akışı:** Wi-Fi scan, Network scan, Heatmap (location+activity+camera), VPN stabilizer
- [x] **POST_NOTIFICATIONS** runtime izin akışı (Kısım 6 onboarding)
- [x] **Data encryption at rest:** SQLCipher + Hive AES-256
- [x] **Data encryption in transit:** TLS bypass yok, HTTPS endpoints
- [x] **No 3rd-party data sharing:** Firebase çıkarıldı (Kısım 12)

### Play Console submit
- [ ] Release AAB hazırla: `flutter build appbundle --release`
- [ ] Data Safety form: `docs/PLAY_STORE_DATA_SAFETY.md`'ye göre doldur
- [ ] VPN Permission Declaration Form: "Network-related functionality / Local-only"
- [ ] Content rating questionnaire
- [ ] Screenshots + feature graphic
- [ ] Store listing metni (TR/EN/DE/KU)
- [ ] In-app onboarding manuel test (yeni kullanıcı simülasyonu)
- [ ] Wipe All Data manuel test
- [ ] VPN disclosure flow manuel test

### Backlog (sürüm sonrası refactor PR)
Bkz. `docs/internal/failure_refactor_backlog.md`:
- HostTrustAssessment + HostTrustReason enum refactor (B7.3)
- network_scan_bloc Failure code (B7.4)
- Wi-Fi/Failure base code (B7.2 + B1.6)
- 353 untranslated ARB key — TR/DE/KU çeviri (Kısım 3)
- `dart fix --apply` 269 info-level lint (Kısım 13)
- ar_hud_overlay_test 3 failing — test maintenance (Kısım 13)
- Centralized HTTP client wrapper (Kısım 2)
- Hive 2.x → hive_ce migration (Kısım 5 paket maintenance mode notu)

---

## 📊 Denetim Vital İstatistikler

### Repo değişim özeti (Kısım 0-13)
```
22 commit, 14 audit raporu, 2 internal backlog dokümanı
~700 satır ölü kod silindi
APK 49.4 → 47.2 MB (-2.2 MB, %4.5 küçülme)
ARB 1641 → 1516 key (-125 dead)
Paket: 34 transitive paket düştü (Firebase + Cloud Firestore + Auth)
debugPrint: 6 → 0
core/ boş klasör: 4 → 0
git rm: scratch/, testsprite_tests/, firebase.json, analysis_output.txt, strings_found.txt, l10n_report.txt, coverage/lcov.info, 7 .txt artığı, security_report.dart
```

### Yeni eklenenler
```
docs/audit/kisim_00..14 (15 rapor)
docs/internal/failure_refactor_backlog.md (sürüm sonrası roadmap)
docs/internal/untranslated_keys_list.md (353 key, TR/DE/KU çeviri için)
docs/internal/ROADMAP_AUDIT.md, TODO.md, lib_feature_backlog.md (taşındı kökten)
android/app/proguard-rules.pro (yeni)
6 yeni ARB key (pingStabilizerConsent*, dbHealedNotice, renderingErrorBody,
  onboardingNotifications*) x 4 dil = 24 metin
SecureStorageService.getOrCreateHiveBoxKey()
NotificationService.requestAndroidNotificationPermission()
AppDatabase.healedFlagKey + auto-heal flag
OnboardingPage.completionKey
```

### Halüsinasyon kontrolünden kazanım
```
8 yanlış iddianın takip edilmediği refactor saatlerce zaman tasarrufu
Yanlış ARB key tasarımı (~50 key) önlendi
Dead code'u canlandırma denemeleri önlendi
```

---

## ✅ Denetim Sonucu

Torcav **sürüme önemli ölçüde yakın**. Tek kalan engelleyici **release keystore yapılandırması (B12.7)**. Diğer her şey Play Store policy uyumlu:

- ✅ targetSdk 35
- ✅ Tüm izinler için disclosure + Privacy Policy + kod kullanımı eşleşiyor
- ✅ Data Safety form hazır (`PLAY_STORE_DATA_SAFETY.md`)
- ✅ Account deletion + data export GDPR uyumlu
- ✅ Encryption at rest + in transit beyan edilebilir
- ✅ Misleading claims riski yok (PDF "lock", AI "discriminative")
- ✅ VPN policy uyumlu (local-only + prominent disclosure + permission declaration form hazırlığı)

**Denetim tamamlandı.** Sürüm aşamasında keystore + AAB build + Play Console form doldurma kalıyor.
