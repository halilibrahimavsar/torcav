# Kısım 8b — Security II (Vuln DB & AI)

> Kapsam: vulnerability data source + meta + DTO + entities + use-case + 2 store (network_context, router_hardening) + features/ai (3 dosya).
>
> **Compliance kritik:** Play Store *AI/ML* policy, *Data Safety* (network data toplama).

## Boyutlar
| Dosya | Satır |
|---|---|
| `vulnerability_data_source.dart` | 55 |
| `vulnerability_db_meta_data_source.dart` | 34 |
| `vulnerable_router_dto.dart` | 60 |
| `check_router_vulnerability_usecase.dart` | 18 |
| `network_context_override_store.dart` | 43 |
| `router_hardening_store.dart` | 53 |
| **AI** | |
| `device_classifier.dart` | **421** (160 satırı MD5 implementasyonu) |
| `onnx_device_classifier_service.dart` | 287 |
| `device_label_override_store.dart` | 47 |

---

## Compliance Pozitifleri (✅) — bu kısım son derece güçlü

### B8b.✅1 — AI tamamen on-device, sıfır dış servis
**Kanıt:**
```
grep "HttpClient\(\)|http\.|dio\." lib/features/ai/ → 0 sonuç
```
**README.md:1-7:**
> "tamamen cihaz üzerinde çalışan bir sinir ağı ile sınıflandırır. Hiçbir veri dış servise gönderilmez"

`OnnxRuntime` lokal model (`assets/models/device_classifier.onnx`), asset → temp dir kopyalama → `OrtSession.fromFile`. **Play Store *AI/ML disclosure*** açısından çok temiz — Data Safety formunda *"This data isn't shared with any third parties"* doğru beyan edilebilir.

### B8b.✅2 — Vulnerability DB local-only, asset-bundled
**Kanıt:**
```
vulnerability_data_source.dart:17 → 'assets/data/vulnerable_routers.json'
vulnerability_db_meta_data_source.dart:16 → 'assets/data/vulnerable_routers_meta.json'
```
Hiçbir CVE feed sorgusu yok. Cache in-memory, exception'da boş liste fallback.
**Compliance:** Hiç ağ trafiği yok → izin/disclosure gerekmiyor.

### B8b.✅3 — Tüm debugPrint/print kalıntısı yok
**Kanıt:** `grep "(debugPrint|print)(" lib/features/security/data/datasources/vulnerability* lib/features/security/data/stores/ lib/features/ai/` → 0 sonuç.

### B8b.✅4 — AppLogger kullanılmıyor (sessiz fail kabul edilir, in-process)
**Kanıt:** Catch blokları `_initFailed = true` flag + `return null` ile graceful degradation. Inference başarısızsa `_vendorHeuristic` (regex-tabanlı OUI fallback) devreye giriyor — kullanıcı için tamamen şeffaf.

### B8b.✅5 — ONNX session memory yönetimi doğru
**Kanıt (`onnx_device_classifier_service.dart`):**
- `OrtSessionOptions.release()` (line 274)
- `OrtRunOptions.release()` (line 83, 106)
- `inputOrt.release()` (line 82, 105)
- `outputTensor.release()` (line 88)
- `@disposeMethod void dispose()` (line 282)
- `_initFailed` flag → retry önler
**Sonuç:** Native handle leak yok. Lazy singleton + dispose.

### B8b.✅6 — Vendor heuristic graceful fallback
**Kanıt (`onnx_device_classifier_service.dart:113-247`):**
- Model unavailable → vendor heuristic (regex tabanlı)
- Model confidence < 0.50 → vendor heuristic + model birleşimi
- Hostname/vendor lookup → device type
**UX:** kullanıcı AI bozulsa bile her zaman bir etiket görür.

### B8b.✅7 — Hive store'ları artık şifreli (Kısım 5)
**Kanıt:** `network_context_override_store`, `router_hardening_store`, `device_label_override_store` hepsi `HiveStorageService` üzerinden — Kısım 5'te AES-256 cipher eklendi.
**Etki:** BSSID'lere bağlı user override'lar artık disk'te düz değil.

### B8b.✅8 — Feature extraction izolat'ta
**Kanıt (`onnx_device_classifier_service.dart:52-54`):**
```dart
final features = await Isolate.run(() {
  return hosts.map(DeviceFeatureExtractor.extractFeatures).toList();
});
```
Batch sınıflandırmada feature extraction (pure Dart, CPU-heavy MD5) **arka isolate**'ta. UI freeze yok.

---

## Bulgular

### B8b.1 — MD5 implementation custom (D) — 160 satır gereksiz duplicate
**Kanıt (`device_classifier.dart:209-420`):**
- 200+ satır RFC 1321 MD5 implementation
- Yorum: "to avoid crypto package dependency"
- AMA `crypto` paketi pubspec'te zaten var:
  ```
  grep "import.*'package:crypto" lib/
    lib/features/reports/domain/services/pdf_lock_service.dart:4
    lib/core/storage/oui_database_service.dart:2
  ```
**Tespit:** `crypto.md5.convert(bytes).bytes` ile aynı sonuç elde edilebilir; **160 satır ölü güzergah**. Custom implementation tek avantajı: dış API bağımlılığını minimal tutmak (paket sürüm değişimi → davranış değişimi riski yok). Ama crypto paketinin MD5'i RFC 1321 ile bit-perfect uyumlu olduğu için bu argüman zayıf.
**Risk:** Kendi MD5 implementasyonunda subtle bug çıkarsa, Python eğitim pipeline'ı ile feature vektörü uyumsuz olur → model **sessizce yanlış sonuç** verir. Test edilmiş ama yine de bakım yükü.
**Aksiyon:** Sürüm sonrası refactor — `crypto.md5.convert(input).bytes` ile değiştir. Test coverage gerekli.
**Şimdilik:** Yok (çalışan kod, sürüm engelleyici değil).

### B8b.2 — `vulnerability_data_source` exception'da silent fail (D)
**Kanıt (`vulnerability_data_source.dart:50-53`):**
```dart
} catch (e) {
  // In case of error, return empty list to prevent crash
  return [];
}
```
**Tespit:** JSON parse hatası, asset eksikse boş liste dönüyor. Kullanıcı "hiç vuln yok" şeklinde yanıltıcı bilgi alabilir.
**Aksiyon:** `AppLogger.e('Failed to load vulnerable_routers.json', error: e);` ekle — debug'da görünsün, prod'da Crashlytics ileride yakalasın.

### B8b.3 — `vulnerable_router_dto` JSON cast hata fırlatabilir (D)
**Kanıt (`vulnerable_router_dto.dart:15-22`):**
```dart
factory VulnerableRouterDto.fromJson(Map<String, dynamic> json) {
  return VulnerableRouterDto(
    prefix: json['prefix'] as String,
    ...
  );
}
```
Eğer `vulnerable_routers.json`'da bir kayıt eksik field içerirse `TypeError` → `_loadDatabase()` catch'inde yakalanır → tüm DB boş döner.
**Tespit:** Her kaydı tek tek try/catch içine almak daha defansif olur (bir kötü kayıt diğerlerini iptal etmesin).
**Aksiyon:** Düşük öncelik. JSON kaynağı bizim (asset), kontrol elimizde. Sürüm sonrası refactor.

### B8b.4 — AI hardcoded'lar — false positive (D)
**Kanıt:**
```
device_classifier.dart:203 'Unknown' (default kategori)
onnx_device_classifier_service.dart:119,125 'Mobile Device' (canonical)
onnx_device_classifier_service.dart:132 'tp-link' (marka)
onnx_device_classifier_service.dart:141 'Router/Gateway' (canonical)
onnx_device_classifier_service.dart:164 'western digital' (marka)
onnx_device_classifier_service.dart:170 'NAS/Storage' (canonical)
... (toplam 14)
```
**Tespit:** Bu metinler ya **canonical device type label** (presentation `translateDeviceType` ile çeviriyor — Kısım 2 + 7'de doğrulanmış pattern), ya da **marka adı / regex keyword** (lokalize edilmez).
**Aksiyon:** False positive, müdahale gerekmez.

### B8b.5 — `vulnerable_routers.json` versiyon mekanizması (✅ ama Kısım 14 not'u)
**Kanıt:** `vulnerable_routers_meta.json` versiyon + lastUpdated + source URL + entryCount içeriyor. UI'da freshness card var (`vulnerability_db_freshness_card.dart`, Kısım 8c'de).
**Compliance:** Play Store *Security Apps Best Practices* — "vulnerability data freshness clearly displayed".
**Aksiyon:** Yok. Tasarım doğru.

### B8b.6 — `router_hardening_store` her get'te O(N²) loop (D) — performans
**Kanıt (`router_hardening_store.dart:22-30`):**
```dart
for (final name in raw.split(',')) {
  for (final value in HardeningCheck.values) {
    if (value.name == name) {
      result.add(value);
      break;
    }
  }
}
```
**Tespit:** İç döngü `HardeningCheck.values` (8 değer) → ihmal edilebilir. `HardeningCheck.values.byName(name)` (Dart 3) tek satır olur.
**Aksiyon:** Düşük öncelik kozmetik.

### B8b.7 — `DeviceLabelOverrideStore.getAll()` tüm Hive box'ı iterate ediyor (D)
**Kanıt (line 28-37):** `box.keys` üzerinden filter — Hive 2.x'te O(N) tüm box.
**Tespit:** Hive box'ta 100+ key olunca yavaşlayabilir; ama şu an total key sayısı düşük (10-50). Yorum'da "we'd need a separate box for this to be efficient" diyor — gelecek refactor için işaret.
**Aksiyon:** Yok. Yorum mevcut, sürüm sonrası ele alınabilir.

---

## Compliance Özeti (Kısım 14'e)

| Konu | Durum |
|---|---|
| AI on-device, dış servis yok | ✅ README + kod kanıtı |
| Vuln DB local-only | ✅ Asset-bundled |
| Vuln DB versiyon görünür | ✅ Meta + freshness card |
| Hive store encryption | ✅ Kısım 5'te uygulandı |
| ONNX memory yönetimi | ✅ release() + dispose() |
| AI çıktıları yanıltıcı? | ⚠️ Vendor heuristic fallback "0.55 confidence" — kullanıcı bilgilendirmesi UI'da (Kısım 8c'de doğrulanacak) |

---

## Kanıt Tablosu

| Bulgu | Komut / Konum | Sonuç |
|---|---|---|
| B8b.✅1 | `grep "HttpClient\\(\\)\\|http\\.\\|dio\\." lib/features/ai/` | **0 sonuç** |
| B8b.✅1 | `lib/features/ai/README.md:7` | "Hiçbir veri dış servise gönderilmez" |
| B8b.✅2 | `vulnerability_data_source.dart:17`, `vulnerability_db_meta_data_source.dart:16` | Sadece `rootBundle.loadString('assets/...')` |
| B8b.✅3 | `grep "(debugPrint\\|print)(" ...` 8b dosyaları | **0 sonuç** |
| B8b.✅5 | `onnx_device_classifier_service.dart` 4 ayrı `.release()` çağrısı + `@disposeMethod` | Memory leak yok |
| B8b.✅8 | `onnx_..._service.dart:52-54` | `Isolate.run(() => ...)` batch feature extraction |
| B8b.1 | `device_classifier.dart:209-420` (160 satır) | Custom MD5; `crypto` paketi zaten projede |
| B8b.4 | `find_strings.py lib/features/ai` | 14 hardcoded — canonical/marka adları (false positive) |

---

## Bu Kısımda Yapılan Düzeltmeler

**Kod değişikliği yok.** Tüm bulgular düşük şiddet veya zaten doğru tasarım. B8b.1 (MD5 duplicate) ve B8b.2 (silent fail logging) sürüm sonrası refactor backlog'una.

**Kısım 8b bulgu sayısı: 7** — 0 K, 0 Y, 0 O, 7 D (hepsi düşük öncelik)
**Pozitif (✅) sayısı: 8** — Bu kısım denetimin **en temiz** kısmı.

Bu beklenmedikti: 11 dosyalık AI + vuln katmanı **sıfır kritik bulgu**. Mimarinin on-device, asset-only, defensive-fail tasarımı Play Store için ideal.
