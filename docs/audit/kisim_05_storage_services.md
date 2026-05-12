# Kısım 5 — Storage & Services (v2 — kanıt-doğrulanmış)

> Kapsam: `lib/core/storage/` (4 dosya), `lib/core/services/` (2 dosya)
> **Compliance-kritik kısım** — encryption-at-rest, retention, secure_storage.
>
> **v2 notu:** Tüm bulgular paket kaynak kodu ve içerik envanteriyle doğrulandı. Halüsinasyon çıkmadı. UUID v4 karakter seti spot check'le sınanmıştır.

## Paket Versiyonları (pubspec.lock, doğrulanmış)
| Paket | Versiyon | Not |
|---|---|---|
| `sqflite_sqlcipher` | **2.3.6** | DB encryption-at-rest |
| `flutter_secure_storage` | **10.0.0** | AES-GCM + RSA-OAEP (Kısım 1) |
| `flutter_local_notifications` | **17.2.4** | Modern |
| `hive` | **2.3.2** | ⚠️ **maintenance mode** — Hive 2.x artık aktif geliştirilmiyor (hive_ce / isar / drift önerilen yenisi). Sürüm sonrası migration backlog'a. |
| `uuid` | **4.5.3** | RFC 4122 v4 (122-bit entropi) |

## Boyutlar
| Dosya | Satır |
|---|---|
| `app_database.dart` | 391 |
| `oui_database_service.dart` | 136 |
| `hive_storage_service.dart` | 44 |
| `secure_storage_service.dart` | 44 |
| `data_retention_service.dart` | 108 |
| `notification_service.dart` | 231 |

---

## Bulgular

### B5.1 — `Hive` storage ŞİFRELENMEMİŞ, hassas veri saklanıyor (K) — **Play Store compliance riski**
**Kanıt:**
```
grep -rn "encryptionCipher\|HiveAesCipher" lib/ → 0 sonuç
```
`hive_storage_service.dart:17`: `await Hive.openBox(_defaultBoxName);` — **`encryptionCipher` parametresi YOK**, default mod düz dosya (`{box}.hive` JSON-like).

**Hive box'ında saklanan veri envanteri** (`grep "_storage.save\|_storage.get"`):
| Kaynak | Saklanan | Hassasiyet |
|---|---|---|
| `theme_cubit` | `theme_mode` | Düşük |
| `locale_cubit` | `app_locale` | Düşük |
| `new_device_detector` | **MAC adresi listesi** | **PII (Device IDs)** |
| `favorites_store` (wifi) | **Favori SSID/BSSID listesi** | **PII (Network IDs + konum çıkarımı)** |
| `network_context_override_store` | **BSSID + context (home/public/...)** | **PII + konum çıkarımı** |
| `router_hardening_store` | **BSSID + router config JSON** | **PII** |
| `app_settings_store` | Settings JSON | Orta |
| `heatmap_local_data_source` | **Heatmap session (x,y, signal samples)** | **Konum verisi** |
| `PingStabilizerSettingsStore` | Ping ayarları | Düşük |

**Play Store etkisi:**
- **Data Safety formunda "Data is encrypted at rest" beyanı verilirse YALAN olur.** BSSID/MAC ve konum verisi düz disk'te.
- Cihaz adli kontrolünde (forensics, malware, root erişim) hassas veri okunabilir.
- **GDPR/Türkiye KVKK:** kullanıcı verisi şifreli depolanmalı yorumu yaygın yorum.

**Aksiyon:**
1. `HiveStorageService.init()` içinde:
```dart
final key = await secureStorage.getOrCreateHiveEncryptionKey(); // 256-bit
await Hive.openBox(_defaultBoxName, encryptionCipher: HiveAesCipher(key));
```
2. `SecureStorageService`'a yeni metod: `getOrCreateHiveBoxKey()` → 32-byte random, secure_storage'da sakla.
3. **Migration:** İlk açılışta eski şifrelenmemiş box varsa içeriği oku → yeni şifrelenmiş box'a yaz → eskiyi sil. (sürüm öncesi tek tetik)

**Şiddet:** **K** — sürüm öncesi mutlaka düzeltilmeli.

---

### B5.2 — `NotificationService.initialize()` Android `POST_NOTIFICATIONS` runtime izni istemiyor (Y) — bug
**Kanıt:**
- `notification_service.dart` initialize'da sadece iOS için `requestAlertPermission/Badge/Sound: true`.
- **Android için runtime izin isteği YOK.**
- `grep "POST_NOTIFICATIONS\|Permission\.notification" lib/`: sadece `ping_stabilizer_cubit.dart` istiyor (kendi modülünde).
- AndroidManifest `<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />` ✅ var (Kısım 12).

**Etki:** Android 13+ cihazda kullanıcı izin vermediyse:
- `_plugin.show(...)` sessizce hata verir → security alert kullanıcıya ulaşmaz
- Kullanıcı "neden bildirim almıyorum?" şüphesi → kötü UX

**Aksiyon:** `NotificationService.initialize()` içine:
```dart
if (Platform.isAndroid) {
  await _plugin.resolvePlatformSpecificImplementation<
    AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
}
```
veya `permission_handler` ile `Permission.notification.request()`. Önce prominent disclosure (Play Store policy: bildirim izninin sebebi açıklanmalı).

---

### B5.3 — `AppDatabase._open()` auto-heal **uyarısız veri kaybı** (Y) — UX + compliance
**Kanıt:** `lib/core/storage/app_database.dart:73-80`:
```dart
if (isCorruption) {
  AppLogger.w('Vault mismatch/corruption detected ($errorStr). Healing...');
  final file = File(dbPath);
  if (await file.exists()) {
    await file.delete();   // ← TÜM KULLANICI VERİSİ SİLİNİR
  }
  return await _openDatabase(dbPath, password);
}
```
**Tespit:** SQLCipher key mismatch (örn. uygulama yeniden yüklendi ama secure_storage temizlendi) veya disk bozulması durumunda **uygulama sessizce tüm kullanıcı verisini siler**:
- Trusted networks (kullanıcının onayladığı ağlar)
- Security events (geçmiş uyarılar)
- Scan history (geçmiş taramalar)
- Heatmap session'ları
- Speed test geçmişi
- Score history

**Compliance:**
- Veri kaybı **kullanıcıya bildirilmemeli**? Hayır, normalde lokal kayıp prod tarafında accepted. Ama:
- Play Store "Data deletion" → kullanıcı veri silme talebi farklı; bu **otomatik** silme.
- En azından `AppLogger.e` ile loglanmalı, ileride hata raporlama eklendiğinde takip edilebilsin.

**Aksiyon:**
1. **Şart:** `AppLogger.e` (release'de de görünür) — `AppLogger.w` yerine.
2. **Önerilen:** Recovery işlemi başlamadan önce bir flag set et (`hive: 'last_db_healed_at'`), sonraki app açılışında kullanıcıya "Verileriniz teknik bir nedenle sıfırlandı" toast'ı göster.
3. **İdeal:** Sadece corruption gerçekten doğrulandığında sil; key mismatch durumunda **password sıfırla, eski veriyi koru** (yapılamaz ama varsayım).

---

### B5.4 — `_onUpgrade` v9 migration: `DROP TABLE channel_rating_history` (Y) — sürüm öncesi tehlike
**Kanıt:** `lib/core/storage/app_database.dart:338-352`:
```dart
if (oldVersion < 9) {
  // App is still in development; the channel rating history table is
  // recreated cleanly so we don't have to worry about back-filling
  // frequency on legacy rows.
  await db.execute('DROP TABLE IF EXISTS channel_rating_history');
  await db.execute('''
    CREATE TABLE channel_rating_history (...)
  ''');
}
```
**Tespit:** Yorum açıkça "App is still in development" diyor. **Play Store sürümünden sonra** bir kullanıcı v9'a güncellendiğinde **tüm kanal değerlendirme geçmişi silinir, uyarı yok**. Sürüm tarihinden sonra bu blok dokunulmamalı; ancak hâlâ "development" varsayımıyla yazılmış.

**Aksiyon:**
- **Sürümden önce karar:** v9'da bu davranışı koru (kullanıcılar henüz v9 ile başlıyor olacak).
- **Sürümden sonra:** v10 migration'da `ALTER TABLE ... ADD COLUMN frequency INTEGER` ile non-destructive yap.
- **Şimdi:** Yorumu net bir TODO'ya çevir: `// TODO(prod): replace with non-destructive migration after first Play Store release`.

---

### B5.5 — `oui_database_service.dart:113` `debugPrint` (Kısım 1'den taşındı) (D)
**Kanıt:** `debugPrint('OUI lookup failed: $e');`
**Aksiyon:** `AppLogger.w('OUI lookup failed', /* error: e */);` — `AppLogger.w` error parametresi almıyor, sadece mesaj alır → `AppLogger.e` daha doğru:
```dart
AppLogger.e('OUI lookup failed', error: e);
```

### B5.6 — `notification_service.dart:47` `debugPrint` (Kısım 1'den taşındı) (D)
**Kanıt:** `debugPrint('Notification tapped: ${response.payload}');`
**Tespit:** Payload'da BSSID, IP, attack type olabilir — **PII risk**. Release'de sessiz olmalı.
**Aksiyon:** `AppLogger.d('Notification tapped: ${response.payload}');` → kReleaseMode gating ile zaten guard'lanır.

---

### B5.7 — `_onUpgrade` v1→v2 toplu `DROP TABLE` listesi (D) — bilgi
**Kanıt:** `app_database.dart:296-311`:
```dart
if (oldVersion < 2) {
  await db.execute('DROP TABLE IF EXISTS wifi_signal_samples');
  ... 13 tablo daha
}
```
**Tespit:** Bu da geliştirme aşaması ama v2 zaten geçilmiş — şimdi sadece "erken adopter" kullanıcı v1'den v9'a yükseltirse silinir. Sürüm sonrası bu blok artık dokunulmaz; **ihmal edilebilir bulgu**.

---

### B5.8 — Notification renkleri AppColors yerine inline hex (D)
**Kanıt:** `notification_service.dart:177-183`:
```dart
SecurityEventSeverity.critical => const Color(0xFFFF0000),
SecurityEventSeverity.high => const Color(0xFFFF6B6B),
...
```
**Tespit:** `AppColors.neonRed = 0xFFFF1744`, `AppColors.neonOrange = 0xFFFF6E27` var; tutarlılık için kullanılmalı. Bu renkler tema değişiminden etkilenmiyor (notification renkleri).
**Aksiyon:** Düşük öncelik kozmetik düzeltme. Sürüm sonrası.

---

### B5.9 — `HiveStorageService.init` exception yutuluyor (O) — boğuk hata
**Kanıt:** `hive_storage_service.dart:14-21`:
```dart
static Future<void> init() async {
  try {
    await Hive.initFlutter();
    await Hive.openBox(_defaultBoxName);
  } catch (e, stack) {
    AppLogger.e('Failed to initialize Hive', error: e, stackTrace: stack);
  }
}
```
**Tespit:** Hive init başarısızsa `init()` sessizce döner. Ama sonra `Hive.box(_defaultBoxName)` getter çağrıldığında `HiveError: Box not found` fırlatır → app çöker.
**Sonuç:** Hata aslında yutulmuyor, **gecikiyor**. Stack trace anlamlı yerde değil.
**Aksiyon:** `rethrow;` eklensin. Hata erken anlaşılsın. Veya `init` boolean döndürsün, çağıran karar versin.

---

### B5.10 — `PRAGMA key` SQL injection riski (D) — false positive
**Kanıt:** `app_database.dart:98`:
```dart
await db.execute("PRAGMA key = '${password.replaceAll("'", "''")}'");
```
**Doğrulama:** `password` UUID v4 ile üretiliyor (`Uuid().v4()`) → sadece `[0-9a-f\-]` karakterleri. `'` içermez. Escape var. **Güvenli.**

---

## Compliance Pozitifleri (✅)

| Konu | Durum | Kanıt |
|---|---|---|
| **DB encryption at rest** | ✅ Açık | `sqflite_sqlcipher 2.3.6` ile DB şifreli (`password` zorunlu) |
| **Encryption key** | ✅ Güvenli | UUID v4 (122-bit entropi), flutter_secure_storage'da saklı |
| **Secure storage backend** | ✅ Modern | flutter_secure_storage v10 (AES-GCM, RSA-OAEP — Kısım 1 doğrulandı) |
| **Account deletion / privacy reset** | ✅ Mevcut | `SecureStorageService.deleteAll()` ve `HiveStorageService.clearAll()` |
| **Retention enforcement** | ✅ Aktif | `DataRetentionService.enforceRetention()` her açılışta `splash_page.dart:97`'den tetikleniyor |
| **POST_NOTIFICATIONS manifest** | ✅ Var | `AndroidManifest.xml:17` |
| **Hive read-only OUI DB** | ✅ Güvenli | `readOnly: true`, SHA-256 ile asset sync doğrulaması |

---

## Compliance Açıkları (Kısım 14'e)

| Konu | Durum | Şiddet |
|---|---|---|
| **Hive box encryption** | ❌ Yok — BSSID/MAC/heatmap düz disk'te | **K** |
| **Android notification runtime izin akışı** | ❌ Eksik | Y |
| **Auto-heal veri kaybı bilgilendirme** | ❌ Yok | Y |

---

## Kanıt Tablosu (v2 — detaylı doğrulama)

### B5.1 — Hive şifresiz + PII envanteri
| Kanıt | Komut / Konum | Bulgu |
|---|---|---|
| Şifreleme yok | `grep -rn "encryptionCipher\|HiveAesCipher" lib/` | **0 sonuç** |
| Hive open call | `hive_storage_service.dart:17` | `await Hive.openBox(_defaultBoxName)` — `encryptionCipher` parametresi YOK |
| MAC listesi | `new_device_detector.dart:10` | `static const _key = 'known_mac_addresses';` |
| BSSID listesi | `favorites_store.dart:9` | `static const _key = 'pinned_bssids';` |
| BSSID + context | `network_context_override_store.dart:19` | `_storage.save('$_prefix${bssid.toUpperCase()}', context.name)` |
| BSSID + router JSON | `router_hardening_store.dart:17,36` | `_storage.save(_key(bssid), encoded)` (JSON string) |
| Heatmap session | `heatmap_local_data_source.dart:38` | `_storage.save('heatmap_session_${session.id}', _toJson(session))` |

### B5.2 — Notification Android izin
| Kanıt | Konum | Bulgu |
|---|---|---|
| AndroidManifest izni | `android/app/src/main/AndroidManifest.xml:17` | `<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>` ✅ |
| NotificationService init | `notification_service.dart:18-44` | Sadece `DarwinInitializationSettings` `requestAlertPermission: true` — Android için izin isteği YOK |
| Paket davranışı (kaynak) | `~/.pub-cache/.../flutter_local_notifications-17.2.4/lib/src/platform_flutter_local_notifications.dart` | `AndroidFlutterLocalNotificationsPlugin.initialize()` izin İSTEMEZ; ayrı `requestNotificationsPermission()` metodu var ama proje çağırmıyor |
| Tek runtime istek | `ping_stabilizer_cubit.dart:149-156` | `Permission.notification.status` + `.request()` — sadece bu modülde |
| Yorum kanıtı | `ping_stabilizer_cubit.dart:149` | `// Android 13+ requires POST_NOTIFICATIONS at runtime; without it the ...` |

### B5.3 — Auto-heal veri kaybı
| Kanıt | Konum | Alıntı |
|---|---|---|
| Koşul | `app_database.dart:67-72` | `errorStr.contains('not a database') \|\| 'code 26' \|\| 'open_failed' \|\| 'malformed'` |
| Silme | `app_database.dart:75-78` | `final file = File(dbPath); if (await file.exists()) { await file.delete(); }` |
| Uyarı (eksik) | `app_database.dart:74` | Sadece `AppLogger.w('Vault mismatch/corruption detected ($errorStr). Healing...');` — kullanıcıya bildirim YOK |

### B5.4 — v9 dev migration
| Kanıt | Konum | Alıntı |
|---|---|---|
| Yorum | `app_database.dart:339-341` | `// App is still in development; the channel rating history table is recreated cleanly` |
| DROP | `app_database.dart:342` | `await db.execute('DROP TABLE IF EXISTS channel_rating_history');` |

### B5.5–B5.6 debugPrint
| Konum | Satır |
|---|---|
| `oui_database_service.dart:113` | `debugPrint('OUI lookup failed: $e');` |
| `notification_service.dart:47` | `debugPrint('Notification tapped: ${response.payload}');` |

### B5.10 — PRAGMA SQL injection FALSE POSITIVE
| Kanıt | Doğrulama |
|---|---|
| UUID v4 örnek (Python `uuid.uuid4()` ×5) | `58e309b6-7988-4663-a285-00eee4f39282`, `8d54f83a-...`, `73de4918-...`, `f2529698-...`, `3c79517f-...` — hepsi `[0-9a-f-]` |
| RFC 4122 v4 spec | 32 hex digit + 4 hyphen, 36 char toplam. `'`, `"`, `;` veya başka SQL meta-karakter **çıkamaz** |
| Escape | `app_database.dart:98` | `password.replaceAll("'", "''")` — savunma katmanı (zorunlu değil, defense-in-depth) |

### Pozitifler (✅)
| Kanıt | Konum |
|---|---|
| Retention tetik | `splash_page.dart:90,97` | `final retentionService = getIt<DataRetentionService>(); retentionService.enforceRetention().then(...)` |
| DB encryption | `app_database.dart:107` | `password: password // Enable encryption via sqflite_sqlcipher on mobile` |
| Account deletion API | `secure_storage_service.dart:31`, `hive_storage_service.dart:42` | `deleteAll()` ve `clearAll()` mevcut |
| OUI DB readonly + SHA | `oui_database_service.dart:50,86-88` | `readOnly: true`, `sha256.convert(...)` ile asset doğrulaması |

---

## Uygulanan Düzeltmeler (v2)

1. ✅ **B5.1 — Hive AES encryption** (kullanıcı kararı: temiz başlangıç)
   - `SecureStorageService.getOrCreateHiveBoxKey()` — 32-byte AES-256 key (Random.secure), base64 olarak secure_storage'a yazılır
   - `HiveStorageService.init(List<int> encryptionKey)` — `HiveAesCipher` ile box açar
   - Cipher mismatch'te (eski şifresiz box veya key değişimi) box dosyaları silinir ve yeni şifreli box açılır
   - `main.dart` Hive init'i SecureStorageService üzerinden geçiyor (DI henüz hazır değil, manuel instantiation)
2. ✅ **B5.2 — `NotificationService.requestAndroidNotificationPermission()` public metod eklendi**
   - `AndroidFlutterLocalNotificationsPlugin.requestNotificationsPermission()` çağırıyor
   - Onboarding entegrasyonu **Kısım 6'da** (prominent disclosure + iste)
3. ✅ **B5.3 — Auto-heal flag + log seviyesi**
   - `AppDatabase._open` corruption durumunda `AppLogger.e` (release'de de görünür), error parametresi orijinal exception
   - `AppDatabase.healedFlagKey = 'last_db_healed_at'` Hive'a yazılır
   - **SnackBar entegrasyonu Kısım 6 (Splash)'da** — `dbHealedNotice` ARB key 4 dilde hazır
4. ✅ **B5.4 — v9 migration yorumu netleştirildi**
   - "App is still in development" → "v9 is the first version shipped to Play Store; future migrations must be non-destructive"
   - Davranış değişmedi (kullanıcı kararı)
5. ✅ **B5.5 — `oui_database_service.dart:113` debugPrint → `AppLogger.e('OUI lookup failed', error: e)`**
6. ✅ **B5.6 — `notification_service.dart:47` debugPrint → `AppLogger.d` (kReleaseMode gating)**
7. ✅ **B5.9 — `HiveStorageService.init` hata yönetimi:** cipher mismatch'te otomatik recovery, diğer hatalar propagate

## Kısım 6'ya Bağlanan TODO'lar
- **Onboarding'de** `ProminentDisclosureDialog` + `NotificationService.requestAndroidNotificationPermission()` çağrısı (B5.2 tamamlanması)
- **Splash'ta** `hive.get(AppDatabase.healedFlagKey)` kontrolü + `SnackBar(context.l10n.dbHealedNotice)` + key sil (B5.3 tamamlanması)

## Eklenen / Değişen Dosyalar
- `lib/core/storage/secure_storage_service.dart` — `getOrCreateHiveBoxKey()` (yeni)
- `lib/core/storage/hive_storage_service.dart` — encrypted, instance-aware init
- `lib/core/storage/app_database.dart` — heal flag + Hive bağımlılık + v9 yorum
- `lib/core/storage/oui_database_service.dart` — AppLogger.e
- `lib/core/services/notification_service.dart` — public Android perm istek + AppLogger.d
- `lib/main.dart` — Hive key resolution before DI
- `lib/core/l10n/app_*.arb` — `dbHealedNotice` (4 dilde)
- `lib/core/di/injection.config.dart` — AppDatabase constructor regenerate

**Kısım 5 bulgu sayısı: 10** — **1 K**, 3 Y, 2 O, 4 D. Bu kısım denetimin **en kritik** kısmı.
**Düzeltme: 7/10 (3'ü Kısım 6'da onboarding/splash entegrasyonu ile tamamlanacak).**

---

## Açık Sorular

1. **Hive encryption migration:** Mevcut kullanıcı verisi (eğer beta sürümünden gelenler varsa) korunsun mu, sıfırdan mı başlasın? **Önerim: korunsun** — migration script (eski box → yeni encrypted box → eski sil).
2. **Auto-heal davranışı:** Veri kaybedildiğinde kullanıcıya snackbar/dialog gösterilsin mi? **Önerim: evet, splash sonrası** — i18n key gerekir.
3. **v9 migration:** Şimdi non-destructive yapalım mı yoksa sürüm sonrası v10'da mı? **Önerim: şimdi non-destructive** — `ALTER TABLE` ile frequency kolonu eklenir.
