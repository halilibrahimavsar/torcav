# Kısım 11 — Settings & Heatmap

> Kapsam: `lib/features/settings/` (5), `lib/features/heatmap/` (53) = 58 dosya
>
> **Compliance kritik:** Heatmap'in AR + IMU + barometer + camera sensör pipeline'ı; Settings'in account deletion / privacy linkleri.

---

## 🎉 Çok Güçlü Compliance Pozitifleri

### B11.✅1 — Heatmap izin akışı Play Store policy'ye TAM uyumlu
**Kanıt (`new_session_dialog.dart:88-115`):**
```dart
final shouldProceed = await showDialog<bool>(
  context: context,
  builder: (ctx) => ProminentDisclosureDialog(
    title: l10n.heatmapPermissionsTitle,
    description: l10n.newSessionPermissionsBody,
    icon: Icons.map_rounded,
    privacyPoints: [
      l10n.newSessionPermLocation,      // ← Konum: Wi-Fi BSSID için
      l10n.newSessionPermActivity,      // ← Aktivite: step counter
      l10n.newSessionPermCamera,        // ← Kamera: AR pose tracking
    ],
    actionLabel: l10n.continueLabel,
    ...
  ),
) ?? false;
if (!shouldProceed) return;
await [
  Permission.activityRecognition,
  Permission.location,
  Permission.camera,
].request();
```

**Play Store policy:**
- ✅ Prominent disclosure izin isteğinden ÖNCE
- ✅ 3 ayrı izin için 3 ayrı privacy point
- ✅ Toplu izin isteği user accept sonrası
- ✅ ActivityRecognition (Play Store *Health & Fitness* policy: step counter için)
- ✅ Camera (Play Store: AR feature için açık beyan)
- ✅ Location (FINE_LOCATION: Wi-Fi BSSID + indoor positioning)

### B11.✅2 — Settings: "Wipe All Local Data" — GDPR right to erasure
**Kanıt (`settings_page.dart:875-897`):**
```dart
context.l10n.wipeAllAction → confirm dialog → multi-store deleteAll:
  - SpeedTestHistoryRepository.deleteAll()
  - SecurityLocalDataSource.deleteAllData()
  - HeatmapLocalDataSource.deleteAll()
  - LanScanHistoryLocalDataSource.deleteAllSessions()
  - DeviceLabelOverrideStore.clearAll()
  - (+ daha fazla store, Hive box clear, AppDatabase reset)
```
**Compliance:**
- **Play Store *Account Deletion***: Kullanıcı uygulama içinden tüm verisini silebilir ✅
- **GDPR Article 17 (Right to erasure)**: ✅
- **Türkiye KVKK Madde 7 (Silme hakkı)**: ✅

### B11.✅3 — Privacy Policy + ToS public erişilebilir
**Kanıt (`privacy_policy_page.dart:9-13`):**
```dart
static const String _privacyPolicyUrl =
    'https://halirlnj.github.io/torcav-privacy/';
static const String _contactEmail = 'halirlnj@gmail.com';
```
- ✅ Public URL — Play Store submit'te zorunlu
- ✅ Contact email — kullanıcı veri-konusu hakları için iletişim noktası
- ✅ App içinde tam metni gösteriyor (offline okuma için)

### B11.✅4 — Settings 5 dosyada SIFIR sızıntı
**Kanıt:** 0 hardcoded, 0 debugPrint, 0 HttpClient, 0 TLS bypass.

### B11.✅5 — Heatmap sıfır HttpClient, sıfır TLS bypass
**Kanıt:** 53 dosya, 0 ağ erişimi (tüm sensör verisi local).

### B11.✅6 — Tüm projede `debugPrint`/`print` kalıntısı **SIFIR** (Kısım 1'den taşınan son iz çözüldü)
**Kanıt:**
```
$ grep -rnE "^\s*(debugPrint|print)\(" lib/ --include="*.dart" | wc -l
0
```
Kısım 1'de 6 adet vardı:
1. `oui_database_service.dart:113` → Kısım 5'te AppLogger.e
2. `locale_cubit.dart:31` → Kısım 3'te AppLogger.e
3. `notification_service.dart:47` → Kısım 5'te AppLogger.d
4. `neomorphic_background.dart:49` → Kısım 8c'de AppLogger.e
5. `classic_grid_background.dart:55` → Kısım 8c'de AppLogger.e
6. `heatmap_page.dart:537` → **Kısım 11'de AppLogger.e ✅ (bu kısım)**

---

## Bulgular

### B11.1 — `heatmap_page.dart:537` `debugPrint('Share failed: $e')` (D) ✅ DÜZELTİLDİ
**Aksiyon:** `AppLogger.e('Heatmap share failed', error: e, stackTrace: stack)`. Release'de görünür (Kısım 1'deki AppLogger gating'i sadece `d/i/w` için).

### B11.2 — `heatmap_placement_service.dart` 2 hardcoded user-facing cümle (O)
**Kanıt:**
```
:34 'Walk around your space with the heatmap survey active so we...'
:46 'Coverage looks good — fewer than 5% of the area you walked...'
```
**Tespit:** UI'da gösterilen rehberlik cümleleri.
**Aksiyon:** Backlog — sürüm sonrası `failure_refactor_backlog.md`'ye eklenecek. Kullanıcı görünür ama hata değil; bilgilendirme metni.

### B11.3 — Heatmap teknik label'lar — false positive (D)
**Kanıt:**
```
ar_hud_overlay.dart:285,296 '0.5m', '2.5m' (mesafe etiketi)
live_signal_tag.dart:88 'STD ${slice.stdDev}...' (interpolasyon)
live_signal_tag.dart:149 'AR' (kısa marka)
ready_banner.dart:77 'COVERAGE COMPLETE' (statü)
recording_status.dart:72 'REC' (statü)
recording_status.dart:99 'PTS' (point count abbr)
sparse_region_arrow.dart:65 '— SPARSE COVERAGE' (uyarı etiketi)
```
**Tespit:** Çoğu teknik label / kısa statü. `'COVERAGE COMPLETE'` ve `'— SPARSE COVERAGE'` user-facing — sürüm sonrası lokalize edilebilir. Diğerleri false positive (mesafe, marka, abbreviation).

### B11.4 — `position_datasource.dart:66` `AppLogger.i('Manual heading realign requested...')` (D) — bilgi
**Kanıt:** Kısım 1 B1.10'da tespit edildi. AppLogger.i release'de no-op (Kısım 1'de gating eklendi).
**Aksiyon:** Yok. AppLogger gating zaten release'de sessizliğini sağlıyor.

---

## Compliance Özeti (Kısım 14'e)

| Konu | Durum | Etki |
|---|---|---|
| Heatmap 3 izin disclosure | ✅ Var | Play Store Network Tools/AR uyumlu |
| Camera izni AR için disclosure | ✅ Var | Play Store *Camera Use* zorunluluk |
| Activity recognition disclosure | ✅ Var | Step counter (Health & Fitness policy) |
| **Account deletion (Wipe all)** | ✅ Var | Play Store zorunluluk + GDPR |
| **Privacy Policy public URL** | ✅ `halirlnj.github.io/torcav-privacy` | Play Store zorunluluk |
| **Contact email** | ✅ `halirlnj@gmail.com` | GDPR DSR iletişim noktası |
| Sensör verisi local-only | ✅ 0 HttpClient | Play Store *Personal & Sensitive Info* uyumlu |

---

## Sensor Verisi Data Safety Beyanı (Kısım 14'e)

Heatmap'te toplanan veriler (cihazda):
- **Konum (FINE_LOCATION):** Wi-Fi BSSID okuma için — Data Safety: "Approximate location" ⚠️ (FINE = "Precise location")
- **Aktivite tanıma:** Step counter (yürüyüş tespit)
- **Kamera:** AR pose tracking (kamera frame'leri **kaydedilmiyor**, sadece tracking)
- **Barometer:** Kat tespiti (sensors_plus)
- **IMU (accel/gyro):** Pose tracking, heading
- **Wi-Fi RSSI:** Sinyal heatmap

**Önemli:** Tüm bu veriler **sadece cihazda saklanır**, hiç dış servise gönderilmez. Data Safety formunda:
- *"Data collected"* → Approximate/Precise location (FINE_LOCATION), Sensor data (barometer, IMU)
- *"Data shared"* → **No data shared with third parties** (vurgulanacak)
- *"Data encrypted at rest"* → Yes (Kısım 5'te Hive AES + SQLCipher)

---

## Kanıt Tablosu

| İddia | Konum | Sonuç |
|---|---|---|
| Heatmap 3 izin disclosure | `new_session_dialog.dart:88-115` | ProminentDisclosureDialog → 3 privacyPoint → toplu Permission.request |
| Wipe all data | `settings_page.dart:891-897` | Multi-store deleteAll çağrıları |
| Privacy URL | `privacy_policy_page.dart:11` | `https://halirlnj.github.io/torcav-privacy/` |
| Contact email | `privacy_policy_page.dart:14` | `halirlnj@gmail.com` |
| Heatmap network | `grep "HttpClient(" lib/features/heatmap/` | 0 |
| Tüm projede debugPrint | `grep "(debugPrint|print)(" lib/` | **0** (Kısım 1'den 6'sı 11'e kadar tüketildi) |

---

## Kısım 11 Bulgu Özeti

| Bulgu | Şiddet | Durum |
|---|---|---|
| B11.1 heatmap_page debugPrint | D | ✅ Düzeltildi (AppLogger.e) |
| B11.2 heatmap_placement_service 2 hardcoded cümle | O | Backlog |
| B11.3 Heatmap teknik label'lar | D | False positive (çoğu) |
| B11.4 position_datasource INFO log | D | AppLogger gating çözüyor |
| ✅ Compliance pozitifleri | — | **6** |

**Kısım 11 — denetimin en güçlü compliance kısmı.** Bu, app'in **Play Store submit'e en yakın bölümü**:
- 3 farklı sensör tipinde disclosure ✅
- Account deletion ✅
- Privacy Policy public ✅
- Contact email ✅
- Wipe All flow ✅

flutter analyze: temiz

## Bonus Milestone 🎯

Bu kısımla birlikte **tüm projede `debugPrint`/`print` kalıntısı SIFIR**. Kısım 1'de tespit edilen 6 iz kademe kademe çözüldü (Kısım 3, 5, 8c, 11). AppLogger artık tek log noktası, release'de `d/i/w` no-op, sadece `e` görünür.
