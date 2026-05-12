# Kısım 1 — Giriş Noktası & Core I (v2 — doğrulanmış)

> Kapsam: `lib/main.dart`, `lib/core/di/`, `lib/core/errors/`, `lib/core/logging/`, `lib/core/env/`
>
> **v2 notu:** v1'deki B1.5 halüsinasyon çıktı (Equatable zaten `runtimeType` kontrolü yapıyor — paket kaynağında doğrulandı). İptal edildi. Diğer bulgular paket kaynak kodları ve build dosyalarıyla doğrulandı.

## Şiddet Skalası
**K**ritik / **Y**üksek / **O**rta / **D**üşük

---

## Bulgular

### B1.1 — `kReleaseMode` / `kDebugMode` kullanımı YOK (K) — Play Store etkili
**Kanıt:** `grep -rn "kReleaseMode\|kDebugMode\|kProfileMode" lib/` → **0 sonuç**.
**Tespit:** `AppLogger` `dart:developer`'ın `log()` fonksiyonunu çağırıyor — bu fonksiyon **release build'de de çalışır**, sadece DevTools ile yakalanır olur ama loglar süreçten silinmez. Üstüne 6 doğrudan `debugPrint` var (`debugPrint` da release'de stdout'a yazar; sadece Flutter override mekanizması var). Production binary'de geliştirici log'ları (db yolu, dosya yolları, adım koordinatları) çıktı veriyor.
**Compliance:** Play Store "Data Safety" gereği: kullanıcı verisi/cihaz bilgisi loglara akan herhangi bir akış beyan edilmeli. Şu an PII içermese de prod log'larda potansiyel veri sızıntısı için iz yok.
**Aksiyon:**
- `AppLogger.d/i/w` çağrılarını `if (kDebugMode)` ile koru, ya da `AppLogger` içinde tek noktadan release-mode kontrolü ekle.
- `AppLogger.e` release'de bile çalışsın ama hata raporlama servisine (Crashlytics değil — kullanılmıyor) gönderim için ileride hazır olsun.
- Tüm 6 `debugPrint` çağrısını `AppLogger.w` veya `AppLogger.e`'ye çevir (Kısım 2-11 boyunca doğal akışta yapılacak).

### B1.2 — `runZonedGuarded` yok, async error yutuluyor (Y)
**Kanıt:** `main.dart` 20-40. `WidgetsFlutterBinding.ensureInitialized()` → `FlutterError.onError` → `PlatformDispatcher.instance.onError` → `await HiveStorageService.init()` → `await configureDependencies()` → `runApp(...)`.
**Tespit:** `FlutterError.onError` Flutter framework hatalarını, `PlatformDispatcher.onError` zone-uncaught hatalarını yakalar. Ama `HiveStorageService.init()` veya `configureDependencies()` `runApp`'ten önce hata atarsa, `PlatformDispatcher.onError` henüz aktif değil; uygulama sessiz çöker.
**Aksiyon:** Tüm main'i `runZonedGuarded` içine al:
```dart
runZonedGuarded(() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ...
  runApp(...);
}, (error, stack) {
  AppLogger.e('Zone error', error: error, stackTrace: stack);
});
```

### B1.3 — `_NeonErrorWidget` exception string'i kullanıcıya gösteriyor (Y) — UX + compliance
**Kanıt:** `main.dart:72` → `Text(details.exceptionAsString(), ...)`.
**Tespit:** Release build'de bile internal exception mesajı, stack hint'i kullanıcıya gösteriliyor. Bu hem kötü UX hem de potansiyel olarak dosya yolu / debug bilgi sızıntısı.
**Aksiyon:** `kReleaseMode` ise jenerik mesaj (`context.l10n.renderingErrorBody` gibi), debug ise teknik detay. ARB'a yeni anahtar gerekecek.

### B1.4 — `core/env/` BOŞ klasör, prod/dev ayrımı yok (Y)
**Kanıt:** `ls lib/core/env/` → 0 dosya.
**Tespit:** Beklenen environment config (flavor, BASE_URL, debug bayrakları, telemetry on/off) yok. `core/env/` plan dosyalarında geçiyor ama hiç implementasyon yok.
**Aksiyon:** İki yol —
1. **Kullanılmıyorsa sil:** `rmdir lib/core/env/`.
2. **Kullanılacaksa eklenmesi gerekenler:** `app_env.dart` (flavor, isProduction getter), build flavor (debug/release) ayrımı. Kısım 12'de native flavors ile birlikte değerlendirilebilir.

### ~~B1.5 — `Failure` Equatable hatası~~ ❌ İPTAL (v1 halüsinasyon)
**v1 iddiası:** Farklı `Failure` alt sınıfları aynı mesajla eşit görünüyor; `runtimeType` props'a eklenmeli.
**Doğrulama (`~/.pub-cache/hosted/pub.dev/equatable-*/lib/src/equatable.dart`):**
```dart
@override
bool operator ==(Object other) {
  return identical(this, other) ||
      other is Equatable &&
          runtimeType == other.runtimeType &&    // <-- ZATEN VAR
          iterableEquals(props, other.props);
}
```
Equatable paketi `==` operator'ünde `runtimeType` kontrolünü kendi yapıyor. `ServerFailure("X") == CacheFailure("X")` → **false** (doğru davranış). Mevcut kod doğru, müdahale gerekmez. Bulgu iptal.

### B1.6 — `Failure` sınıfları sadece `message` taşıyor, kod/detay yok (O)
**Kanıt:** Aynı dosya, hiçbir alt sınıfta ek alan yok.
**Tespit:** Hata izlemeyi (kullanıcıya gösterim, telemetry, kategorize hata yönetimi) zorlaştırır. Örn. `PermissionFailure` hangi izin? `ScanFailure` hangi tarama tipi?
**Aksiyon:** En azından `final String? code` ekle; zorunlu değil, geriye dönük uyumlu. Sürüm sonrası refactor.

### B1.7 — `di_module.dart` iOS fallback'ı Linux datasource'a düşüyor (K) — bug
**Kanıt:** `lib/core/di/di_module.dart:24`:
```dart
WifiDataSource wifiDataSource(...) {
  if (Platform.isAndroid) return android;
  return linux;  // <-- iOS, macOS, Windows, Web — hepsi linux'a
}
```
**Tespit:** iOS'ta `LinuxWifiDataSource` çalışacak — büyük olasılıkla LinuxWifiDataSource (nmcli vb. CLI bağımlı) iOS'ta hata fırlatır veya hiçbir şey döndürmez.
**Compliance:** Play Store sadece Android — iOS şu an sürüm hedefi değilse not düşmek yeterli ama gelecekteki iOS hedefini engelliyor.
**Aksiyon:** Şu an Android-only ise açıkça reddet:
```dart
WifiDataSource wifiDataSource(...) {
  if (Platform.isAndroid) return android;
  if (Platform.isLinux) return linux;
  throw UnsupportedError('Platform not supported: ${Platform.operatingSystem}');
}
```

### ~~B1.8 — `storage_module.dart` Android için EncryptedSharedPreferences kapalı~~ ❌ İPTAL (v2 halüsinasyon)
**v1 iddiası:** `AndroidOptions()` default'u `encryptedSharedPreferences: false` olduğu için Android'de zayıf encryption kullanılıyor; `encryptedSharedPreferences: true` eklenmeli.
**Doğrulama:** `flutter_secure_storage 10.0.0` CHANGELOG ve kaynak kodu:
- `encryptedSharedPreferences` parametresi **deprecated**, no-op:
  > `@Deprecated('... Remove this parameter - it will be ignored.')`
- v10'da Jetpack Security tamamen kaldırıldı, default ciphers:
  - Storage: `AES_GCM_NoPadding`
  - Key: `RSA_ECB_OAEPwithSHA_256andMGF1Padding`
  - `resetOnError: true`, `migrateOnAlgorithmChange: true`
- analyze çıktısı: `'encryptedSharedPreferences' is deprecated ... Your data will be automatically migrated to custom ciphers on first access. Remove this parameter - it will be ignored`

**Sonuç:** Mevcut `AndroidOptions()` (parametresiz) zaten güçlü encryption sağlıyor — EncryptedSharedPreferences'tan **üstün**. v1'deki tavsiye yanlıştı, geri alındı. **Compliance açısından mevcut kod yeterli.**

**Not (Play Store):** Data Safety formunda "Data is encrypted in transit and at rest" → ✅ doğrulanabilir (paket kaynak kodu kanıt).

### B1.9 — `app_database.dart:53` veritabanı yolu loglanıyor (O)
**Kanıt:** `AppLogger.d('Initializing Vault at: $dbPath');`
**Tespit:** Sistem dosya yolu (örn. `/data/user/0/com.torcav.app/files/torcav.sqlite`) prod log'larda görünüyor. PII değil ama gereksiz; saldırı yüzeyi azaltma kuralı gereği prod'da log'lanmamalı.
**Aksiyon:** B1.1 çözüldükten sonra otomatik düzelir (kDebugMode guard).

### B1.10 — `position_datasource.dart:214` her adımda INFO log (O)
**Kanıt:** `AppLogger.i('👟 Step Detected: Heading ..., New Pos (...)');`
**Tespit:** Heatmap kullanırken saniyede 1-2 INFO log spam'i. Koordinatlar yerel (AR-IMU lokal frame), PII değil ama performans + log gürültüsü.
**Aksiyon:** `AppLogger.d`'ye düşür; B1.1 düzeltildikten sonra prod'da görünmez. Kısım 11 (Heatmap) içinde tekrar bakılacak.

### B1.11 — `PlatformDispatcher.instance.onError` `return true` ile her şeyi yutuyor (D)
**Kanıt:** `main.dart:30` `return true;` — Flutter'a "hata handle edildi, devam et" diyor.
**Tespit:** Beklenen davranış ama hiçbir telemetry/crash reporting yok. Sürüm sonrası bug görünmez olur.
**Aksiyon:** Kısa vadede yeterli. Uzun vadede Crashlytics/Sentry düşünülmeli (kullanıcıdan onay gerektirir — Play Store Data Safety beyanı eklenir).

### B1.12 — `injection.config.dart` (29.6 KB) generated — denetlenmeyecek (D)
**Kanıt:** Header'da `// GeneratedCodeContents` benzeri yorum. Bu dosya `build_runner` ile üretilir.
**Aksiyon:** Yok. Sadece `dart run build_runner build --delete-conflicting-outputs` ile yeniden üretilir; manuel düzenleme yapılmıyor.

---

## Compliance Özeti (Kısım 1 → Kısım 14'e taşınacak notlar)

| Konu | Durum | Etki |
|---|---|---|
| Prod log'da PII sızıntısı | Doğrulanmadı (bu kısımda) ama log gating yok → Kısım 7/8/11'de derin bakılacak | Y |
| Encryption-at-rest beyanı (secure_storage) | Android tarafı eksik (B1.8) | K |
| Crash reporting / telemetry | Yok — Data Safety formunda "no" beyan edilebilir, avantajlı | Bilgi |
| Internal exception kullanıcıya gösterimi | Var (B1.3) | Y |

---

## Compliance "Yan Bulgu" (Kısım 12'e ön not)

**targetSdk = 34** (android/app/build.gradle.kts). Play Console **2026 itibarıyla yeni app'ler için targetSdk 35 zorunlu** (Google Play hedef API politikası, mevcut tarih: 2026-05-12). **Bu sürüm öncesi targetSdk 35'e çıkarılmazsa Play Console upload'u reddeder.** Kısım 12'de detaylı işlenecek; burada **K** olarak işaretle.

---

## Önerilen Düzeltme Sırası (onay sonrası, tek commit)

1. **`AppLogger`** revize: kReleaseMode gating, e()'de bile guard yok ama d/i/w guard'lı (B1.1, B1.9, B1.10 otomatik düzelir).
2. **`main.dart`** revize:
   - `runZonedGuarded` ile sar (B1.2)
   - `_NeonErrorWidget` release modda jenerik metin (B1.3) — ARB'a `renderingErrorBody` ekle
3. **`di_module.dart`** — iOS fallback `UnsupportedError` (B1.7).
4. **`core/env/`** — boş klasörü sil (B1.4); ilerideki flavor sistemi Kısım 12'de.
5. ~~`storage_module.dart`~~ — B1.8 iptal (paket v10 default'u zaten güvenli).

**Kısım 1 doğrulanmış bulgu sayısı: 10** — 2 kritik, 3 yüksek, 3 orta, 2 düşük. (v1: 12; B1.5 ve B1.8 iptal — Equatable ve flutter_secure_storage paket davranışı v1'de yanlış varsayılmıştı.)

### iOS Hedefi Durum Notu
- `ios/Runner.xcodeproj` mevcut (`IPHONEOS_DEPLOYMENT_TARGET = 12.0`)
- `ios/Podfile` **yok** → henüz `pod install` çalıştırılmamış, iOS build pipeline kurulmamış
- `wifi_scan` paketinin iOS desteği var (kaynak doğrulandı) ama `LinuxWifiDataSource` iOS'ta çalışmaz → B1.7 geçerli

---

## Kanıt Tablosu (v2 doğrulama turundan)

| Bulgu | Komut / dosya | Çıktı / alıntı |
|---|---|---|
| B1.1a | `grep -rn "kReleaseMode\|kDebugMode" lib/` | **0 sonuç** |
| B1.1b | `lib/core/logging/app_logger.dart:1` | `import 'dart:developer';` — `log()` Dart docs'a göre release'de optimize edilme **garantisi yok** |
| B1.1c | `grep "debugPrint(" lib/` | **6 çağrı** (oui_database, locale_cubit, notification_service, 2× background widget, heatmap_page) |
| B1.2 | `grep "runZonedGuarded" lib/` | **0 sonuç** |
| B1.3 | `lib/main.dart:33` | `ErrorWidget.builder = (details) => _NeonErrorWidget(details: details);` — koşulsuz |
| B1.3 | `lib/main.dart:72` | `Text(details.exceptionAsString(), ...)` — release/debug ayrımı yok |
| B1.4 | `ls -la lib/core/env/` | klasör boş (toplam 0) |
| B1.5 | `~/.pub-cache/.../equatable/lib/src/equatable.dart` | `runtimeType == other.runtimeType` zaten kontrol ediliyor → iddia çürüdü, **iptal** |
| B1.7 | `lib/core/di/di_module.dart:24-25` | `if (Platform.isAndroid) return android; return linux;` — iOS dahil her şey linux |
| B1.8 | `lib/core/di/storage_module.dart:8` | `aOptions: AndroidOptions()` (parametresiz) |
| B1.8 | `flutter_secure_storage/lib/options/android_options.dart` | constructor default: `bool encryptedSharedPreferences = false` |
| B1.9 | `lib/core/storage/app_database.dart:53` | `AppLogger.d('Initializing Vault at: $dbPath');` |
| B1.10 | `lib/features/heatmap/data/datasources/position_datasource.dart:214` | `AppLogger.i('👟 Step Detected: Heading ..., New Pos ...');` — her step'te |
| B1.11 | `lib/main.dart:30` | `return true;` — sessizce yutuluyor |
| B1.12 | `lib/core/di/injection.config.dart:2` | `// GENERATED CODE - DO NOT MODIFY BY HAND` — denetlenmez |
| Yan | `android/app/build.gradle.kts` | `targetSdk = 34` — Play 2026'da 35 zorunlu |

---

## Açık Sorular (kullanıcı onayı bekliyor)

1. `core/env/` boş klasör tamamen silinsin mi yoksa şimdi minimal bir `app_env.dart` (flavor + isProduction) ile başlatılsın mı? **Önerim: şimdi sil, Kısım 12'de native flavors ile birlikte ekleyelim.**
2. `_NeonErrorWidget` release'de neyi göstersin? **Önerim:** "Bir hata oluştu, lütfen tekrar deneyin." gibi sade bir mesaj, ARB anahtarı `renderingErrorBody`.
3. Logger için 3rd-party bir paket (örn. `logger`, `talker`) düşünülüyor mu, yoksa `AppLogger` minimal wrapper olarak mı kalsın? **Önerim: minimal kalsın; Crashlytics/Sentry ekleme kararı sürüm sonrası.**
