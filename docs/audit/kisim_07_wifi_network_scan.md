# Kısım 7 — Wi-Fi & Network Scan

> Kapsam: `lib/features/wifi_scan/` (38 dosya), `lib/features/network_scan/` (29 dosya), `lib/core/platform/wifi_extended_channel.dart`
>
> **Compliance-kritik:** Play Store *Network Tools* policy + Data Safety beyanı için en önemli kısım.

## Kapsam
- Wi-Fi: 38 dosya — data/domain/presentation tam katmanlı
- Network: 29 dosya — ARP, mDNS, NetBIOS, UPnP, port scan
- Platform bridge: 1 dosya (`wifi_extended_channel.dart`)

---

## Compliance Pozitifleri (✅) — bu kısımda çok güçlü

### B7.✅1 — Wi-Fi scan ProminentDisclosure → Permission akışı doğru
**Kanıt (`wifi_scan_page.dart:77-114`):**
```dart
Future<void> _checkPermissionAndStart() async {
  if (!Platform.isAndroid) return;
  final status = await Permission.location.status;
  if (status.isGranted) return;
  // → ProminentDisclosureDialog (privacyPoints: scan SSIDs / analyze signal / no tracking)
  // → User accept → Permission.location.request()
}
```
**Tetiklenme:** `initState`'te `addPostFrameCallback((_) => _checkPermissionAndStart())` ile.
**Play Store uyumu:**
- Açık başlık (`wifiScanPermissionTitle`) ✅
- Açıklayıcı body (`wifiScanPermissionDesc`) ✅
- 3 gizlilik noktası: SSID tarama, sinyal analizi, **tracking yok** beyanı ✅
- Onay öncesi sistem permission istenmiyor ✅

**İkinci çağrı yeri (`wifi_scan_page.dart:589-617`):** Manuel re-scan butonu için aynı akış tekrarlanıyor — kullanıcı izni reddetmiş veya geri almışsa gösteriliyor. ✅

### B7.✅2 — Network scan consent + "authorized user" onayı
**Kanıt (`network_scan_page.dart:117-134`):**
```dart
ProminentDisclosureDialog(
  title: l10n.networkAuditConsentTitle,
  icon: Icons.gavel_rounded,
  privacyPoints: [
    l10n.consentScanNodes,
    l10n.consentFingerprint,
    l10n.consentIdentifyVulns,
    l10n.consentConfirmAuth,   // ← "this network is authorized"
  ],
  actionLabel: l10n.iUnderstand,
)
```
**Bloc akışı:** `NetworkScanConsentRequired` state → dialog → `AcknowledgeLegalRisk(accepted)` event → bloc devam eder.
**Play Store Network Tools policy:**
- *"Network Tools must obtain explicit user acknowledgement that they are authorized to access the target network"* → `consentConfirmAuth` ✅
- *"vulnerability discovery"* → `consentIdentifyVulns` ✅

### B7.✅3 — Strict Safety Mode hidden SSID active probing'i engelliyor
**Kanıt (`android_wifi_data_source.dart:48-51`):**
```dart
// ENFORCEMENT: If strictSafetyMode is ON, we disable hidden SSID scanning
// regardless of the request parameter to prevent active probing.
final effectiveIncludeHidden =
    _settingsStore.value.strictSafetyMode ? false : request.includeHidden;
```
**Tespit:** Active probe scan (`scanResults` requesting hidden SSIDs) Play Store ve ağ etiketinde "intrusive" sayılır. Strict safety mode bu davranışı kapatıyor. ✅

`network_scan_repository_impl.dart:93,102`: NetBIOS gibi aktif hostname sorgular da strict mode'da atlanıyor.

`port_scan_data_source.dart:73` (`final isStrict = ...`): port scan da strict safety'ye saygı duyuyor.

### B7.✅4 — PII (BSSID/MAC) loglama YOK
**Kanıt:**
```
grep -rn "AppLogger\|debugPrint" lib/features/wifi_scan/ lib/features/network_scan/  → 0 sonuç
```
BSSID, MAC, SSID hiçbir yere loglanmıyor. Sadece Hive (şimdi şifreli — Kısım 5) ve SQLCipher DB'ye yazılıyor.

### B7.✅5 — `wifi_extended_channel.dart` native bridge temiz
**Kanıt:** 122 satır, `PlatformException` düzgün yakalıyor (boş map dön), BSSID `.toUpperCase()` ile normalize, defensive null-checks. 0 hardcoded, 0 log.

---

## Bulgular

### B7.1 — `NEARBY_WIFI_DEVICES` izni Manifest'te YOK (Y) — Android 13+ modern yaklaşım eksik
**Kanıt (`android/app/src/main/AndroidManifest.xml`):**
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />
<!-- NEARBY_WIFI_DEVICES yok -->
```
```
grep -rn "NEARBY_WIFI_DEVICES" → 0 sonuç (manifest + kod)
```
**Tespit:** Android 13 (API 33)'ten beri Wi-Fi tarama için iki yol var:
1. **Eski yöntem (mevcut):** `ACCESS_FINE_LOCATION` istemek — kullanıcı "neden konum?" şüphesi
2. **Yeni yöntem (önerilen):** `NEARBY_WIFI_DEVICES` + `usesPermissionFlags="neverForLocation"` — konum istemeden Wi-Fi tarar, kullanıcı dostu

**Play Store etkisi:**
- Mevcut yaklaşım **çalışır** (Android 13+'da location ile fallback)
- Data Safety formunda "konum verisi topluyoruz" beyanı vermeniz gerekir (gerçekte sadece Wi-Fi'yi listelemek için)
- Eğer `NEARBY_WIFI_DEVICES + neverForLocation` eklerseniz, **konum beyanı kalkar** ✅

**Aksiyon (Kısım 12'de uygulanacak):**
```xml
<uses-permission android:name="android.permission.NEARBY_WIFI_DEVICES"
    android:usesPermissionFlags="neverForLocation"
    tools:targetApi="33" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"
    android:maxSdkVersion="32" />
```
Ve `_checkPermissionAndStart` mantığı Android 13+ için `Permission.nearbyWifiDevices` kontrol edecek şekilde güncellenmeli. **Burada işaret, Kısım 12'de detaylı planlanacak.**

### B7.2 — Wi-Fi data source hardcoded hata mesajları (O) — UX
**Kanıt (`find_strings.py lib/features/wifi_scan`): 9 string**
```
android_wifi_data_source.dart:38 'Android scanner is only supported on Android'
android_wifi_data_source.dart:44 'Location permission required for Wi-Fi scanning'
android_wifi_data_source.dart:87 'Cannot retrieve Wi-Fi scan results.'
android_wifi_data_source.dart:88 'Please ensure Location is enabled in system settings.'
android_wifi_data_source.dart:96 'No Wi-Fi networks found.'
android_wifi_data_source.dart:97 'Ensure Wi-Fi and Location services are enabled.'
linux_wifi_data_source.dart:63 'Wi-Fi scan failed. Ensure NetworkManager or wireless-tools is...'
linux_wifi_data_source.dart:110 'No Wi-Fi networks found. Ensure Wi-Fi is enabled.'
```
**Tespit:** Bunlar `PermissionFailure(msg)` ve `ScanFailure(msg)` parametresine geçen mesajlar. Failure → presentation'da `Text(failure.message)` ile gösteriliyor olabilir. Lokalize edilmeli.
**Aksiyon:** Failure sınıfına `code` (örn. `ScanFailureCode.locationDisabled`) ekle, presentation `switch` ile `l10n.X` çevirsin. **Kısım sonuna ertele — Kısım 1'de B1.6 olarak işaretlemiştik.**
**False positive:** `linux_wifi_data_source.dart:81 'SSID,BSSID,SIGNAL,CHAN,FREQ,SECURITY,BARS'` — `nmcli` komut argümanı, lokalize edilemez.

### B7.3 — `host_trust_classifier.dart` kullanıcıya gösterilen açıklamalar İngilizce hardcoded (Y)
**Kanıt:**
```dart
// lib/features/network_scan/domain/services/host_trust_classifier.dart:54
'this device has multiple weak signals stacked together.'
// :67
'Device looks unusual for this network — vendor or naming '
"doesn't match the rest of your home gear."
```
**Tespit:** Bu metinler UI'da `host_device_card`'a görünüyor (trust badge altında). Türkçe/Almanca kullanıcı İngilizce metin görüyor.
**Aksiyon:** Domain → presentation arası bir "reason code" pattern (örn. `HostTrustReason.weakSignals` enum) → l10n key'lere map. Sürüm öncesi düzeltilmeli ama büyük refactor; Kısım 8c (Security UI) ile birlikte ele alınabilir.

### B7.4 — `network_scan_bloc.dart` 3 hardcoded hata mesajı (Y) — UX
**Kanıt:**
```dart
// network_scan_bloc.dart:145
'Legal acknowledgement required for LAN discovery.'
// :163
'Scan target exceeds safety limits. Please restrict to /24 or smaller subnets.'
// :173
'Deep scanning is disabled when Strict Safety Mode is active.'
```
**Tespit:** Bloc state'lerinden UI'a aktarılan hata metinleri. Kullanıcıya gösteriliyor.
**Aksiyon:** B7.2 ile aynı pattern; failure code → l10n.

### B7.5 — `network_scan_repository_impl.dart:142` `'Router/Gateway'` (D) — device type label
**Kanıt:** `'Router/Gateway'` static string.
**Doğrulama (`grep -rn "translateDeviceType" lib/`):**
- `context_extensions.dart:12` — `translateDeviceType` metodu var
- 3 yerde kullanılıyor (`host_device_card.dart:85,295,346`)
- Switch'te `'Router/Gateway' => l10n.deviceTypeRouterGateway` var

**Sonuç:** ✅ Pattern doğru — internal string presentation'da çevriliyor. Hardcoded olarak görünüyor ama **doğru tasarım** (data layer canonical, presentation çeviri). False positive.

### B7.6 — `arp_data_source.dart` 'Unknown' vendor placeholder'ları (D)
**Kanıt:**
```
arp_data_source.dart:168 'Unknown'
arp_data_source.dart:168 'Unknown (Android Limited)'
arp_data_source.dart:275 'Android Device (Restricted)'
arp_data_source.dart:276 'Unknown'
```
**Tespit:** Vendor placeholder'lar. `translateVendor` extension'ı var (context_extensions.dart:6). Pattern aynı — internal canonical, presentation'da çeviri. Doğrulama:
```
grep "translateVendor" lib/  → 1 yer (host_device_card.dart)
```
**Aksiyon:** `Unknown (Android Limited)` ve `Android Device (Restricted)` çeviri map'inde var mı kontrol edilmeli (Kısım 8c). Şu an düşük öncelik.

### B7.7 — `mdns_data_source.dart` 5 mDNS service type string (D) — false positive
**Kanıt:** `'_ipp._tcp.local'`, `'_printer._tcp.local'`, `'_smb._tcp.local'`, vb.
**Tespit:** mDNS service identifier'ları — RFC 6762 protokol sabitleri. **Lokalize EDİLEMEZ.** False positive. ✅

### B7.8 — `network_scan_bloc.dart` legal acknowledgement state akışı (✅) — bilgi
**Kanıt:** `NetworkScanConsentRequired` → `AcknowledgeLegalRisk` event → bloc devam.
**Tespit:** Disclosure ↔ scan başlatma arasında BLoC akışı düzgün modellenmiş. Kullanıcı reddederse `acknowledged=false` event → scan başlamıyor. ✅

---

## Compliance Özeti

| Konu | Durum |
|---|---|
| Wi-Fi scan prominent disclosure + permission | ✅ Doğru sırada (B7.✅1) |
| Network scan "authorized user" onayı | ✅ Var (B7.✅2) |
| Hidden SSID active probing engeli | ✅ Strict safety mode (B7.✅3) |
| BSSID/MAC PII loglama | ✅ Yok (B7.✅4) |
| Native bridge güvenliği | ✅ Temiz (B7.✅5) |
| NEARBY_WIFI_DEVICES modern izin | ❌ Yok (B7.1) — Kısım 12'e |
| Data Safety beyanı: "location" toplama | Beyan gerekli (B7.1 nedeniyle) |
| Data Safety beyanı: "wifi info" | Beyan gerekli (BSSID/SSID/security) |

---

## Kanıt Tablosu

| Bulgu | Komut / Konum | Çıktı |
|---|---|---|
| B7.✅1 | `wifi_scan_page.dart:77-114` + `:583-617` | İki yerde de Disclosure → Accept → Permission.request |
| B7.✅2 | `network_scan_page.dart:117-134` | `consentConfirmAuth` privacy point |
| B7.✅3 | `android_wifi_data_source.dart:48-51` | `strictSafetyMode ? false : request.includeHidden` |
| B7.✅4 | `grep "AppLogger\|debugPrint" lib/features/wifi_scan lib/features/network_scan` | **0 sonuç** |
| B7.1 | `grep -rn "NEARBY_WIFI_DEVICES" .` | **0 sonuç** (kod + manifest) |
| B7.2 | `find_strings.py lib/features/wifi_scan` | 9 hardcoded (1 false positive) |
| B7.3 | `host_trust_classifier.dart:54,67-68` | İngilizce metin domain layer'da |
| B7.4 | `network_scan_bloc.dart:145,163,173` | 3 bloc hata mesajı İngilizce |
| B7.5 | `grep "translateDeviceType" + context_extensions.dart:12` | `'Router/Gateway' → l10n.deviceTypeRouterGateway` |
| B7.7 | `mdns_data_source.dart:31-35` | mDNS RFC 6762 sabitleri (false positive) |

---

## Önerilen Düzeltme Sırası

1. **🟠 B7.3, B7.4 — Failure/Reason code pattern**: domain layer'dan İngilizce metin yerine enum/code; presentation çevirir. Hem `host_trust_classifier` (Kısım 8c'ye bağlı) hem `network_scan_bloc` aynı pattern.
2. **🟠 B7.1 — NEARBY_WIFI_DEVICES**: Kısım 12'de Manifest + Dart kontrolü.
3. **🟢 B7.2 — Wi-Fi data source hata mesajları**: Kısım 14 öncesi failure code refactor.
4. **🟢 B7.6 — Vendor placeholder çeviri map kontrolü**: Kısım 8c'de.

**Kısım 7 doğrulanmış bulgu sayısı: 8** — 0 K, 3 Y, 2 O, 3 D
**Pozitif (✅) sayısı: 5** — Compliance açısından bu kısım **çok güçlü**.

Bu kısım büyük olmasına rağmen mimari + compliance açısından **iyi durumda**. Asıl iş Kısım 8 (Security, 68 dosya) ve Kısım 12 (Native) olacak.

---

## Açık Sorular

1. **B7.3 / B7.4 / B7.2 — Failure code refactor şimdi mi sonra mı?** Kısım 8c (Security UI) ile birleştirilirse daha tutarlı olur ama büyük iş.
2. **B7.1 — NEARBY_WIFI_DEVICES şimdi mi Kısım 12'de mi?** Manifest değişikliği + Dart permission check. Kısım 12'de bütünsel yapılması mantıklı.
