# Kısım 8a — Security I (İzinler & Scan Engines) (v2 — derin halüsinasyon kontrolü)

> Kapsam: 29 dosya — detection engines (services), use-cases, scan-related entities, DNS + security_local data sources.
>
> **Compliance:** Bu kısım çok güçlü — TLS bypass yok, SQL injection riski yok, PII loglama yok.

## Kapsam
| Kategori | Dosya | Toplam |
|---|---|---|
| Detection services | captive_portal_detector, evil_twin_classifier/explainer, gateway_drift_detector, mesh_vendor_database, network_context_inferrer/resolver | 7 |
| Use-cases | analyze_network_security, arp_spoofing_detector, deauth_detector, dns_leak_test, dns_security, security_analyzer, check_router_vulnerability | 7 |
| Data sources | dns_test_data_source, security_local_data_source | 2 |
| Scan entities | assessment_session, dns_test_result, evil_twin_assessment, hardening_check, known_network, network_context_type, network_fingerprint, security_assessment, security_drift_finding, security_event, security_finding, security_report, trusted_network_profile | 13 |

---

## Compliance Pozitifleri (✅)

### B8a.✅1 — SQL injection riski YOK
**Kanıt:**
```
grep -nE "execute\(.*\\\$|rawQuery\(.*\\\$" security_local_data_source.dart  → 0 sonuç
```
Tüm SQL `db.query/insert/update` `whereArgs` ve `values` üzerinden parametre bağlama yapıyor. String interpolation YOK.

### B8a.✅2 — TLS bypass YOK
**Kanıt:** 8a kapsamında 2 `HttpClient()` kullanımı var ama:
- `captive_portal_detector.dart:27` → `http://connectivitycheck.gstatic.com/generate_204` (kasıtlı HTTP, Android standart captive portal probe — HTTP redirect tespiti gereklidir)
- `dns_test_data_source.dart:203` → `https://1.1.1.1/cdn-cgi/trace` (HTTPS, Cloudflare DoH probe)

`badCertificateCallback`, `allowBadCertificates` çağrısı **0**.

### B8a.✅3 — debugPrint / print kalıntısı YOK
**Kanıt:** `grep -nE "^\s*(debugPrint|print)\(" lib/features/security/{data,domain}/...` → 0 sonuç.

### B8a.✅4 — Captive portal detector tasarımı doğru
**Kanıt (`captive_portal_detector.dart`):**
- HTTP/204 probe (Android standardı): `connectivitycheck.gstatic.com/generate_204` ✅
- 5s connection timeout + 5s response timeout ✅
- Non-204 → `SecurityEventType.captivePortalDetected`, BSSID + SSID Hive'a (artık şifreli — Kısım 5) ✅
- Exception → `CaptivePortalStatus.unknown` (silent fail, doğru) ✅

### B8a.✅5 — DNS test data source güvenli
**Kanıt:**
- HTTPS probe (1.1.1.1) ✅
- DoH/DoT tespiti `body.contains('doh=on')` ile (Cloudflare resmi response format)
- 2s timeout ✅
- Exception → `{'active': false, 'status': 'Basic UDP'}` (safe fallback)

### B8a.✅6 — `deauth_detector` tasarım açıklaması doğru
**Kanıt (`deauth_detector.dart:17-21`):**
```dart
/// **Design rationale**: Native deauth detection requires monitor-mode Wi-Fi
/// and `pcap`/nl80211, which are not available in Flutter on stock Android.
```
Heuristic detection (beacon count drop + RSSI swing) — root/pcap **gerektirmiyor**. Play Store stoplist'inde değil ✅.

---

## Bulgular

### B8a.1 — `security_analyzer.dart` 29 hardcoded title/description (Y) — kullanıcı görünür
**Kanıt (`find_strings.py`):**
| Satır | Reason | İçerik (kısaltılmış) |
|---|---|---|
| 42 | `title` | `'Active Probing Active'` |
| 44 | `description` | `'Deep scan is enabled, performing more intrusive...'` |
| 62 | `title` | `'Open Network'` |
| 64 | `description` | `'No encryption detected. All traffic can be sniffed...'` |
| 83 | `title` | `'WEP Encryption'` |
| 84 | `description` | `'WEP is deprecated and can be cracked quickly.'` |
| 102 | `title` | `'Legacy WPA'` |
| 128 | `title` | `'Hidden SSID'` |
| 150 | `title` | `'Very Weak Signal'` |
| 171 | `title` | `'WPS Enabled'` |
| 199 | `title` | `'Management Frames Unprotected'` |
| 233 | `title` | `'Potential Evil Twin'` |
| ... | | (toplam 29) |

**Tespit:** Bu metinler `SecurityFinding(title: ..., description: ...)` ile entity'ye geçiyor → presentation katmanı doğrudan `Text(finding.title)` ile gösteriyor. Türk/Alman/Kürt kullanıcı her bir güvenlik bulgusunu **İngilizce** görür.

**Aksiyon:** Kısım 7'deki kararla aynı: **Failure/Finding code pattern**. Domain'de `SecurityFindingCode` enum (`openNetwork`, `wepEncryption`, ...) + presentation'da `switch(code) → l10n`. **Kısım 8c'ye birleştirildi.**

### B8a.2 — `hardening_check.dart` 20 hardcoded öneri (Y) — kullanıcı görünür
**Kanıt:** Router hardening önerileri data layer'da:
```
:53  title: 'Change router admin password'
:56  body: 'Default admin credentials (admin/admin, admin/password)...'
:89  title: 'Use WPA3, fall back to WPA2-AES'
:121 title: 'Disable WPS'
:146 title: 'Enable PMF / 802.11w'
```
**Tespit:** `HardeningCheck` entity'sinin `title`/`body`'si — kullanıcıya gösteriliyor (router_hardening_wizard_page).
**Aksiyon:** B8a.1 ile aynı pattern. **Kısım 8c'ye.**

### B8a.3 — `evil_twin_explainer.dart` 8 hardcoded açıklama (Y)
**Kanıt:**
```
:41 'Looks like the same router on different bands'
:43 'Most home routers broadcast the same Wi-Fi name (SSID) over...'
:65 'No evil-twin pattern detected'
:153 'your router and compare it with the BSSIDs shown for this'
:212 'but not the other.'
```
**Tespit:** Evil twin tespit sonucunun kullanıcıya açıklaması. **Kısım 8c'ye.**

### B8a.4 — `mesh_vendor_database.dart` 8 hardcoded — false positive (D)
**Kanıt:**
```
:46 '04:d4:c4'  → MAC OUI prefix (vendor identifier)
:46 'Asus AiMesh' → vendor brand name
```
**Tespit:** MAC OUI'leri RFC standart, vendor isimleri marka isimleri. **Lokalize EDİLEMEZ.** ✅ false positive.

### B8a.5 — `dns_test_data_source.dart` 6 hardcoded (D)
**Kanıt:**
```
'AdGuard Encrypted', 'DoH Enabled', 'DoT Enabled', 'UDP/Unencrypted', 'Basic UDP'
```
**Tespit:** DNS test sonuç string'leri. UI'da `dns_security_card` tarafından gösterilebilir; presentation kontrolünden geçmesi gerek.
**Aksiyon:** Kısım 8c'de incelenecek (`dns_security_card.dart` ile birlikte).

### B8a.6 — `dns_test_result.dart` 3 hardcoded (D)
**Kanıt:** Entity'de default değer veya enum-to-string map'i. Spot check sonrası karar verilecek. Düşük öncelik.

### B8a.7 — `network_context_inferrer.dart` 1 hardcoded (D)
**Kanıt:** Tek satır, muhtemelen marker string. Düşük öncelik.

### B8a.8 — `HttpClient` centralized client yok (O) — Kısım 2'den taşınan iz
**Kanıt:** `captive_portal_detector.dart:27` ve `dns_test_data_source.dart:203` ikisi de inline `HttpClient()`. Centralized wrapper yok.
**Tespit:** Kısım 2'de bilinçli olarak ertelendi (TLS bypass yok, güvenli kullanım). Sürüm sonrası refactor.
**Aksiyon:** Yok bu kısımda.

---

## Compliance Özeti

| Konu | Durum |
|---|---|
| SQL injection (security_local_data_source) | ✅ Güvenli |
| TLS bypass (captive portal + DNS test) | ✅ Yok |
| HTTP probe URL'leri (gstatic, 1.1.1.1) | ✅ Standart, güvenli |
| Heuristic detection (root/pcap gerektirmez) | ✅ Play Store uyumlu |
| Hassas veri logging | ✅ Yok |
| SecurityFinding/HardeningCheck l10n | ❌ Hardcoded — Kısım 8c'ye |

---

## Kanıt Tablosu

| Bulgu | Komut / Konum | Çıktı |
|---|---|---|
| B8a.✅1 | `grep "execute\\(.*\\\\$" security_local_data_source.dart` | 0 |
| B8a.✅2 | `grep "badCertificateCallback" lib/features/security/` | 0 |
| B8a.✅3 | `grep "debugPrint\\|print(" lib/features/security/{data,domain}/` | 0 |
| B8a.✅4 | `captive_portal_detector.dart` tam okuma | HTTP/204 probe + 5s timeout + safe fallback |
| B8a.✅6 | `deauth_detector.dart:17-21` doc yorum | "monitor-mode requires root, heuristic kullanılıyor" |
| B8a.1 | `find_strings.py` 8a dosyalar | **29** hardcoded title/description |
| B8a.2 | aynı | **20** hardcoded hardening |
| B8a.3 | aynı | **8** hardcoded evil twin açıklama |
| B8a.4 | aynı | **8** false positive (MAC OUI + brand) |
| B8a.5–B8a.7 | aynı | **10** düşük öncelik hardcoded |
| B8a.8 | `captive_portal_detector.dart:27` + `dns_test_data_source.dart:203` | 2 inline HttpClient (Kısım 2'den) |

---

## Önerilen Düzeltme Sırası

**Bu kısımda kod değişikliği yok** — tüm bulgular ileri kısımlara taşındı:
- B8a.1, B8a.2, B8a.3, B8a.5 → **Kısım 8c** (Failure/Finding code refactor)
- B8a.8 → sürüm sonrası
- Pozitiflerin tümü Kısım 14 (Play Store final) için bilgi olarak kayıtlı

**Kısım 8a bulgu sayısı: 8** — 0 K, 3 Y, 1 O, 4 D
**Pozitif (✅) sayısı: 6** — Güvenlik mimarisi **çok güçlü**.

---

## v2 — Halüsinasyon Kontrolü Sonrası Düzeltmeler

Derin doğrulama (`grep .toVulnerability`, `grep "meta\\." router_hardening_wizard_page`, `grep CaptivePortalDetector`) ile v1 raporundaki **3 iddia yanlış çıktı**, **2 yeni bulgu yakalandı**.

### ❌ B8a.✅4 İPTAL → 🆕 B8a.9 (Y) `CaptivePortalDetector` DEAD CODE — ✅ DÜZELTİLDİ
**v1 iddiası:** "Captive portal detector tasarımı doğru, kullanılıyor." ❌
**Doğrulama:** `grep "CaptivePortalDetector\|captivePortalDetect" lib/`:
- `injection.config.dart` — DI register
- `captive_portal_detector.dart` — tanım yeri
- **Hiçbir yerden `getIt<CaptivePortalDetector>` çağrısı YOK**
- `.check()` metoduna hiçbir referans yok
- Ama `SecurityEventType.captivePortalDetected` enum'ı notification timeline'da **kullanılıyor** → kullanıcıya "feature var" gibi gözüküp gerçek tespit kodu **hiç çalışmıyor**

**Play Store etkisi:** *Misleading Claims* riski — kullanıcıya vaad edilen güvenlik özelliği fiilen yok.

**Aksiyon uygulandı:**
```dart
// security_repository_impl.dart constructor:
final CaptivePortalDetector _captivePortalDetector;
SecurityRepositoryImpl(..., this._captivePortalDetector);

// analyzeNetworks() içinde, arp/dns detector'lardan sonra:
final portal = await _captivePortalDetector.check();
if (portal.event != null) alerts.add(portal.event!);
```
Artık captive portal tespit edildiğinde gerçek `SecurityEvent` oluşur, notification timeline'a düşer.

### ❌ B8a.2 ÇOK BÜYÜK HALÜSİNASYON → 🆕 B8a.10 (D) DEAD FIELDS — ✅ DÜZELTİLDİ
**v1 iddiası:** "`hardening_check.dart` 20 hardcoded öneri kullanıcıya gösteriliyor, Kısım 8c'de Failure code refactor." ❌
**Doğrulama (`router_hardening_wizard_page.dart`):**
```dart
title: Text(meta.id.title(context)),    // ← l10n extension
meta.id.body(context),                   // ← l10n extension
meta.id.steps(context).length            // ← l10n extension
```
UI **`meta.id.X(context)`** kullanıyor — `HardeningCheckX` extension'ı zaten `l10n.hardeningChangeAdminPasswordTitle` vb. çekiyor.
**`HardeningCheckMeta.title`, `.body`, `.steps` ALANLARI HİÇ OKUNMUYOR** — saf ölü kod.

**Aksiyon uygulandı:** `HardeningCheckMeta` class'tan `title`, `body`, `steps` field'ları kaldırıldı; catalog yeniden yazıldı (sadece `id`, `critical`, `menuHints`). **150 satır → 109 satır.**

### ❌ B8a.1 NÜANS DÜZELTMESİ — bulgu hâlâ geçerli ama mekanizma farklı
**v1 iddiası:** "`security_analyzer.dart` 29 hardcoded `title`/`description` doğrudan UI'a gidiyor."
**Doğrulama:**
- security_analyzer → `SecurityFinding(title: 'Open Network', description: '...')`
- `SecurityFinding.toVulnerability()` → `Vulnerability(title: title, description: description, ...)` (**aynen kopyalıyor**)
- UI `assessment.findings.map((v) => _VulnerabilityCard(vulnerability: v))` → `Vulnerability.title` kullanılıyor

**Sonuç:** İddia doğru ama dönüşüm var. `SecurityFinding → Vulnerability → UI`. **Kısım 8c'de** `_VulnerabilityCard`'ın hangi alanları çağırdığı incelenecek ve Failure code refactor o zaman tasarlanacak.

### 🆕 B8a.11 (O) — `SecurityAssessment.statusLabel` hardcoded İngilizce
**Kanıt:**
```dart
// security_assessment.dart:24
String get statusLabel => switch (status) {
  SecurityStatus.secure => 'Secure',
  SecurityStatus.moderate => 'Moderate',
  SecurityStatus.atRisk => 'At Risk',
  SecurityStatus.critical => 'Critical',
};
```
**Kullanım:** `security_analyzer.dart:438` → `SecurityReport(overallStatus: assessment.statusLabel)`. `SecurityReport.overallStatus` String alanı UI'a aktarılıyor olabilir.

**Karar:** Düzeltme **Kısım 8c'ye taşındı** — UI'da `SecurityReport.overallStatus`'un nasıl tüketildiği netleşince entity getter silinecek, dashboard kendi l10n switch'ini yapacak.

---

## v2 Güncel Sayım

| Konu | v1 | v2 |
|---|---|---|
| Bulgu sayısı | 8 | **9** (B8a.11 eklendi) |
| Pozitif ✅ | 6 | **5** (B8a.✅4 iptal) |
| Halüsinasyon | 0 | **3 yakalandı** (✅4 iptal, B8a.2 dead-fields-yanlış-yorum, B8a.1 mekanizma nüansı) |
| Düzeltme uygulanan | 0 | **2** (B8a.9 CaptivePortal bağlama, B8a.10 dead fields temizliği) |

flutter analyze: temiz (build_runner sonrası)
