# Kısım 3 — Localization

> Kapsam: `lib/core/l10n/`, `l10n.yaml`, 4 ARB dosyası, locale_cubit, fallback delegate, security_localization_helper.

## Sayılar
- **1641 key / dil**, 4 dilde toplam **6564 string**
- ARB dosya boyutu: her biri ~300 KB; 4 dosya = ~1.2 MB
- Generated `app_localizations*.dart`: 5 dosya, toplam ~31k satır
- Desteklenen diller: `en`, `tr`, `de`, `ku`

---

## Bulgular

### B3.1 — l10n klasöründe 7 geliştirme artığı `.txt` dosyası (Y) — geliştirme artığı
**Kanıt:** `ls lib/core/l10n/*.txt`:
```
de_funcs.txt      (482 B)     — fonksiyon sinyatür dump'ı
de_getters.txt    (27.8 KB)   — getter dump'ı
de_names.txt      (5.0 KB)
en_funcs.txt      (481 B)
en_getters.txt    (26.2 KB)
en_names.txt      (5.0 KB)
ku_names.txt      (5.0 KB)
```
Toplam ~70 KB, **hepsi git'te izleniyor**.
**İçerik örneği** (`en_getters.txt`):
```
  String get accessEngine => 'ACCESS ENGINE';
  String get activeMonitoringProgress => 'Active monitoring in progress...';
```
Bu, `app_localizations_en.dart`'tan otomatik çıkarılmış bir snapshot. Hiçbir kod tarafından referans alınmıyor (`grep -rn "en_getters\|de_getters\|..." lib/` → 0 sonuç).
**Aksiyon:** `git rm lib/core/l10n/*.txt` — 7 dosya, kayıpsız silinir.
**Not:** Kısım 0 kök temizliğinde gözden kaçtı çünkü o aşamada `lib/` içine bakılmamıştı.

### B3.2 — 413 key 4 dilde de **aynı string** (Y) — UX sorunu, çoğu çevrilmemiş
**Kanıt:** Python diff (tüm 4 ARB karşılaştırması):
- Toplam: 413 key 4 dilde identik
- **False positive (gerçekten aynı kalmalı):** marka/teknik/sayı (`'BSSID'`, `'Wi-Fi 6 (802.11ax)'`, `'5 GHz'`, `'{ms} ms'`)
- **Gerçek çevrilmemiş örnekler:**
  ```
  deepScanExperimentalTitle: 'Deep Scan (Experimental)'
  topologyGuideTitle: 'TOPOLOGY GUIDE'
  gatewayTitle: 'The Gateway'
  pingAction: 'TEST LATENCY'
  pingFailure: 'Host Unreachable'
  dnsIntegrity: 'DNS INTEGRITY'
  noPortsFound: 'No open ports found'
  trustNetwork: 'TRUST NETWORK'
  portRangeHint: 'Port range (e.g. 80,443 or 1-1000)'
  ...
  ```
**Tespit:** Kabaca tahminim, 413'ün **~200-250'si gerçek çevrilmemiş**. TR/DE/KU kullanıcısı uygulamanın yarısında İngilizce metin görüyor.
**Play Store etkisi:** Sürümü engellemez ama uygulama Türkçe/Almanca pazarda profesyonel görünmez. Açıklama/screenshot'larda "4 dilde" iddia ediliyorsa yanıltıcı olabilir.
**Aksiyon (büyük iş):**
1. Bu kısımda **liste çıkarılır**, çeviri kararı kullanıcıya bırakılır.
2. Önerilen: gerçek çevrilmemiş key'lerin tam listesi `docs/internal/untranslated_keys.md`'ye yazılır, kullanıcı çevirir veya bir çeviri servisine gönderir.
3. **Bu kısımda kod düzeyinde düzeltme yapılmaz** — manuel/kültürel çeviri kararı.

### B3.3 — 133 kullanılmayan ARB key (O) — ölü kod
**Kanıt:** Her key için `grep "\.<key>\b\|\.<key>(" lib/` → kullanılmayan **133 key** (1641'in %8'i).
**Örnek (ilk 20):**
```
wifiScanTitle, deviceTypeIoTSensor, deviceTypePrinter,
searchingNetworksPlaceholder, filterNetworksPlaceholder,
deepScanExperimentalTitle, deepScanExperimentalSubtitle,
operationsLabel, accessEngine, strictSafetyEnabled,
activeMonitoringProgress, plusNewLabel, goneLabel, trustedLabel,
securityEventTitle, targetIpSubnet,
scanProfileFast, scanProfileBalanced, scanProfileAggressive,
scanProfileNormal, ...
```
**Risk (false positive):** Bazı key'ler `String key = 'foo'; l10n.toString()` gibi dinamik çağrılarla erişilebilir. Doğrudan silmek **yıkıcı**.
**Aksiyon:**
1. **Bu kısımda silmiyoruz.** Liste `docs/internal/unused_arb_keys.md`'ye yazılır.
2. Her feature kısmına (5-11) geldiğimizde, o feature ile ilgili key'ler manuel doğrulanıp silinir.
3. Otomatik silme sadece `flutter analyze` + smoke test sonrası onaylanır.

### B3.4 — `hardcoded_strings.json`: 204 hardcoded string raporu (Y) — kısmi gerçek
**Kanıt:** `find_strings.py` çıktısı (2026-05-11). Spot check: 5 örnekten **5'i hâlâ kodda mevcut**.
**Dağılım:**
| Klasör | Hardcoded |
|---|---|
| features/security | 85 |
| features/monitoring | 22 |
| features/network_scan | 19 |
| features/ai | 14 |
| features/wifi_scan | 14 |
| features/heatmap | 11 |
| features/ping_stabilizer | 10 |
| features/reports | 10 |
| features/splash | 8 |
| features/diagnostics | 6 |
| features/app_shell | 2 |
| features/performance | 2 |
| core | 1 |

**False positive oranı (spot tahmin):** ~%30-40 (marka isimleri, teknik standartlar `AES-256-GCM`, sınıflandırma label'ları `'Router/Gateway'`).
**Aksiyon:**
- **Bu kısımda 1 core bulgusu** düzeltilir: `lib/core/services/notification_service.dart:29` → `'Open notification'`.
- Feature kısımlarına (5-11) geldiğimizde her birinin hardcoded string'leri ilgili kısımda düzeltilir.
- `hardcoded_strings.json` Kısım 14 öncesi silinir (Kısım 0'da ertelenmişti).

### B3.5 — `locale_cubit.dart:31` `debugPrint` (D) — Kısım 1'den taşınan iz
**Kanıt:** `debugPrint('[TorcavError] LocaleCubit failed to load saved locale: $e');`
**Aksiyon:** `AppLogger.w('LocaleCubit failed to load saved locale', /* error: e */);` — `e` parametresi `AppLogger.w`'de yok, `AppLogger.e` kullanılırsa daha doğru:
```dart
AppLogger.e('LocaleCubit failed to load saved locale', error: e);
```
Bu Kısım 3'te düzeltilebilir.

### B3.6 — `l10n.yaml` `untranslated-messages-file: l10n_report.txt` (D)
**Kanıt:** `l10n.yaml` 6. satır.
**Tespit:** Bu dosya Kısım 0'da silindi ve `.gitignore`'a alındı. `flutter gen-l10n` her çalıştığında yeniden üretilir, sorun yok. **Aksiyon gerekmez** — sadece bilgi.

### B3.7 — `security_localization_helper.dart` "parse-by-string-prefix" anti-pattern (O) — bug riski
**Kanıt:** `lib/core/l10n/security_localization_helper.dart:12-55`.
```dart
if (evidence.startsWith('Discovered: ')) {
  final devices = evidence.replaceFirst('Discovered: ', '');
  return l10n.lanDiscoveryEvidence(devices);
}
```
**Tespit:** Data layer'ın **İngilizce metin formatında** ürettiği "Discovered: 4 devices" gibi string'leri presentation katmanı bu helper ile parse ediyor. Hassas:
- Eğer data layer string formatını değiştirirse (örn. "Found: 4 devices") helper sessizce orijinal string'i döndürür — Türkçe kullanıcı İngilizce metin görür.
- Aynı zamanda **internal kaynak istenmeyen şekilde çevrildiğinde** (someone localizes the data string), helper kırılır.

**Compliance:** UX problemi, Play Store etkisi yok.
**Aksiyon:** Sürüm sonrası refactor — data layer hata kodu + parametreler döndürsün, helper sadece eşleştirme yapsın. Şimdilik **bulgu olarak işaretle**, düzeltme acil değil.

### B3.9 — `@securityEventSeverity` placeholder metadata bozuk (Y) — bug ✅ DÜZELTİLDİ
**Kanıt (yeni bulgu, taze taramayla yakalandı):**
```json
"@securityEventSeverity": {
  "placeholders": {
    "severity": { "type": "String" },
    "Low": { "type": "String" },       // ← sahte
    "Medium": { "type": "String" },    // ← sahte
    "Info": { "type": "String" },      // ← sahte
    "Warning": { "type": "String" },   // ← sahte
    "High": { "type": "String" },      // ← sahte
    "Critical": { "type": "String" }   // ← sahte
  }
}
```
Mesaj: `{severity, select, low{Low} medium{Medium} ...}` — ICU select formatı, `Low/Medium/...` placeholder DEĞİL, select case'i. Metadata yanlış.
**Etki:** Flutter `gen-l10n` belirli sürümlerde uyarı verir (`"The placeholder is defined in the metadata, but not in the message"`), bazı IDE'ler hata gösterir. Generated kodda kullanılmıyor ama metadata kirli.
**Aksiyon:** 4 ARB'da @securityEventSeverity.placeholders sadece `{"severity": {"type": "String"}}` olarak bırakıldı. ✅

### B3.8 — `core/l10n/security_localization_helper.dart` ile features/security arası coupling (D)
**Kanıt:** Helper, security feature'a özel string'leri parse ediyor ama `lib/core/l10n/` altında. Genel l10n altyapısı değil.
**Aksiyon:** `lib/features/security/presentation/` altına taşınabilir. Kısım 8c'de değerlendirilecek.

---

## Compliance Özeti

| Konu | Durum |
|---|---|
| Tüm kullanıcıya gösterilen string'ler ARB'da mı? | **HAYIR** — ~100-150 gerçek hardcoded string (B3.4) |
| Tüm dillere çevrilmiş mi? | **HAYIR** — ~200-250 gerçek çevrilmemiş key (B3.2) |
| Play Store sürüm engelleyici mi? | Hayır — sürümü durdurmaz. Profesyonel görünüm açısından önemli. |
| İzin diyalog metinleri lokalize mi? | Kısım 6 (Onboarding) ve Kısım 12 (Manifest/Info.plist) görecek |

---

## Kanıt Tablosu

| Bulgu | Komut | Çıktı |
|---|---|---|
| B3.1 | `ls lib/core/l10n/*.txt; git ls-files lib/core/l10n/*.txt` | **7 dosya**, hepsi izleniyor; **0 koddan referans** |
| B3.2 | Python diff 4 ARB | **413 key** 4 dilde identik |
| B3.3 | `grep "\.<key>" lib/` (her key için) | **133 key** kullanılmıyor |
| B3.4 | `hardcoded_strings.json` + spot 5 sample | **204 string**, spot örneklerinin **5/5'i hâlâ var** |
| B3.5 | `lib/core/l10n/locale_cubit.dart:31` | `debugPrint(...)` Kısım 1'den taşınan iz |
| B3.7 | `lib/core/l10n/security_localization_helper.dart:12-99` | 5 farklı `.startsWith(...)` parse path |

---

## Uygulanan Düzeltmeler (v2)

1. ✅ **7 `.txt` artığı silindi** — `lib/core/l10n/*.txt` (B3.1)
2. ✅ **`locale_cubit.dart:31`** — `debugPrint` → `AppLogger.e` (B3.5, stackTrace dahil)
3. ✅ **`@securityEventSeverity` placeholder metadata düzeltildi** — 6 sahte placeholder kaldırıldı, sadece `severity` (YENİ B3.9)
4. ✅ **125 kullanılmayan key silindi** (B3.3) — 4 ARB'dan ortalama 250 satır temizlik
   - `findings_count: 133 → silinmesi güvenli: 133 → flutter analyze sonrası kurtarılan: 8 → net silinmiş: 125`
   - Kurtarılanlar: `security_localization_helper.dart` tarafından kullanılan 8 key (`lanDiscoveryEvidence`, `gatewayPortsExposedEvidence`, `openServiceDetectedEvidence`, `lanDeviceDiscoveredEvidence`, `evidenceNoEncryption`, `lanDiscoveryDesc`, `gatewayPortsExposedDesc`, `openServiceDetectedDesc`)
   - **Öğrenme:** ilk grep'te `--exclude-dir=l10n` filtresi `security_localization_helper.dart`'ı dışlamıştı (yanlış varsayım). Düzeltildi.
5. ✅ **`docs/internal/untranslated_keys_list.md`** — 353 gerçek çevrilmemiş key listesi (B3.2, marka/teknik filtresi sonrası)
6. ❌ **`notification_service.dart:29`** — Zaten çözülmüş; taze taramada (`scripts/find_strings.py`) yok. Eski rapor güncel değildi.

**Bu kısımda çeviri yapılmadı** — kullanıcı kararıyla ayrı görev olarak ertelendi.

---

## Güncel Sayılar (düzeltmelerden sonra)

| Metrik | Önce | Sonra |
|---|---|---|
| ARB key sayısı | 1641 | **1516** (-125) |
| ARB toplam ekleme (4 dosya) | ~6564 string | 6064 string |
| Kullanılmayan key | 133 | **8** (security_localization_helper kullananlar) |
| Çevrilmemiş key (gerçek) | 353 | 353 (ertelendi) |
| Placeholder metadata hatası | 6 | **0** |
| l10n klasör artığı | 7 .txt | **0** |

---

## Kısım 3 Bulgu Sayısı: 9 — 0 K, 3 Y, 3 O, 3 D (YENİ: B3.9 placeholder bug)

(Sürüm öncesi mutlaka çevrilmesi gerekenler "yüksek" şiddet — Play Store engelleyici değil ama profesyonel UX için).

---

## Açık Sorular

1. **Çevrilmemiş 413 key:** Bu kısımda sadece liste mi çıkaralım, yoksa öncelikli ~50 key'i şimdi mi çevirelim? Çeviri yaparsam Türkçe öğrenmek isteyen kullanıcılar açısından **öneririm**: TR/KU için en sık kullanılan 30-50 ekran metni şimdi çevrilsin. DE sonraki PR'da bırakılsın.
2. **133 kullanılmayan key:** Hemen siliniyor mu, feature kısımlarına ertelensin mi? **Önerim: ertele** — false positive riski yüksek, feature içinde doğrulamak güvenli.
3. **`hardcoded_strings.json`:** Bu kısım sonunda silinsin mi yoksa Kısım 14'e kadar bekletilsin mi? **Önerim: Kısım 14 sonrası** — her feature kısmında referans olarak gerekecek.
