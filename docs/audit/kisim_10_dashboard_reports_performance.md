# Kısım 10 — Dashboard, Reports, Performance

> Kapsam: `lib/features/dashboard/` (7), `lib/features/reports/` (14), `lib/features/performance/` (10) = 31 dosya
>
> **Compliance kritik:** Reports'taki **local data export** + PDF lock → kullanıcı verisi dışa aktarımı (GDPR / Data Safety).

---

## Çarpıcı Pozitifler

### B10.✅1 — Dashboard sıfır hardcoded / sıfır sızıntı
**Kanıt:** 7 dosya, 0 hardcoded user-facing string, 0 debugPrint, 0 HttpClient, 0 TLS bypass. Tüm metinler `l10n.*` üzerinden. `statusLabel` `l10n.connectedStatusCaps / disconnectedStatusCaps`.

### B10.✅2 — `LocalDataExportServiceImpl` GDPR-uyumlu tasarım
**Kanıt (`lib/features/reports/data/services/local_data_export_service_impl.dart`):**

| Özellik | Durum |
|---|---|
| **`anonymize: bool`** parametresi | ✅ SSID `[redacted]`, BSSID son 3 octet mask, MAC mask, hostname `[redacted]` |
| **12 ayrı kategori** (`UserDataCategory` enum) | ✅ wifi history, speed test, security events, trusted networks, channel ratings, heatmap, LAN scan, device labels, pinned, score history, context overrides, router hardening |
| **3 format** | ✅ JSON, CSV, HTML |
| **`exportAll`** + per-category `exportCategory` | ✅ Data portability |
| **Tüm export local** | ✅ Hiç dış servise gitmiyor |
| **HTML CSS injection koruması** | ✅ `_htmlEscape` 5 karakter |
| **CSV escape** | ✅ Quote/escape doğru |

**Play Store Data Safety compliance:**
- *"Data deletion option"* → `clearAll` metodları (Kısım 5 + 8b'de doğrulandı)
- *"Data portability"* → Bu service ✅
- *"User can opt out of data collection"* → `anonymize: true` mode ✅

### B10.✅3 — PDF "lock" naming dürüst
**Kanıt:**
- `pdf_lock_service.dart:11-22` yorumu açıkça: *"This isn't AES. There's no key stretching... obfuscation against casual leakage — not protection against a determined attacker"*
- UI metin `l10n.pdfLockedHint`: *"Locked file: .torcav-pdf"* — **"encrypted" demiyor, "locked" diyor**
- Play Store *Misleading Claims* riski **YOK** — naming + UI metni teknik gerçeklikle örtüşüyor

### B10.✅4 — `Hmac(sha256, ...)` integrity check + constant-time compare
**Kanıt (`pdf_lock_service.dart`):**
- `_constantTimeEquals(expected, hmacBytes)` (line 105) — timing attack koruması
- `_macKey()` — domain-separated key (`'torcav-mac'` tag) → key/MAC reuse engeli
- File magic header `TCV1` → diğer dosyaları "decrypt" etmeye çalışmayı önler

---

## Bulgular

### B10.1 — `PdfLockService._randomBytes` zayıf entropi (D) ✅ DÜZELTİLDİ
**Kanıt (önceden):**
```dart
Iterable<int> _randomBytes(int n) {
  final seed = DateTime.now().microsecondsSinceEpoch;  // ← predictable
  final mixed = sha256.convert([seed & 0xff, ...]).bytes;
  return mixed.take(n);
}
```
**Tespit:** Salt source `DateTime.now()` — predictable, aynı milisaniyede üretilen iki lock dosyası aynı salt'a sahip olur. SHA-256 keystream XOR olduğu için salt benzersizliği **kritik** (aynı password + aynı salt = key stream tekrarı = XOR ile plaintext leak).
**Aksiyon ✅:** `Random.secure()` kullanıldı (Kısım 5 `getOrCreateHiveBoxKey` ile aynı pattern):
```dart
Iterable<int> _randomBytes(int n) {
  final rng = Random.secure();
  return List<int>.generate(n, (_) => rng.nextInt(256));
}
```

### B10.2 — PDF report'taki yasal disclaimer Türkçe/İngilizce karışık hardcoded (O)
**Kanıt (`report_export_repository_impl.dart:145-189`):**
```
:145 'TORCAV — Wi-Fi Scan Report'             ← branding (false positive)
:162 'Yasal Uyarı / Legal Disclaimer'         ← 2 dilli karışık
:170-171 (Türkçe disclaimer, 2 satır)
:178-179 (İngilizce disclaimer, 2 satır)
```
**Tespit:** PDF report'unda yasal uyarı **statik olarak hem Türkçe hem İngilizce** birlikte basılıyor. Lokalize değil — kullanıcının dili ne olursa olsun hep iki dil.
**Karar:** İki yaklaşım:
1. **Mevcut hâli koru** — yasal disclaimer'ı her zaman iki dilde göstermek **savunulabilir bir karar** (PDF üçüncü taraflara gidebilir, onlar kullanıcının dilini bilmiyor olabilir, iki dil daha güvenli)
2. **ARB'a taşı** — kullanıcının dilinde göster
**Aksiyon:** Yorum eklendi: bu davranış kasıtlı tasarım gibi görünüyor, sürüm sonrası değerlendirilmek üzere backlog'a ekle. **Şu an düzeltme yapılmadı** (Play Store engelleyici değil).

### B10.3 — Performance HttpClient inline (D) — Kısım 2'den taşınan iz
**Kanıt:** `speed_test_repository_impl.dart:44, 68` — 2 inline `HttpClient()`. TLS bypass yok, güvenli kullanım.
**Aksiyon:** Sürüm sonrası centralized client refactor (Kısım 2'de karara bağlandı).

### B10.4 — `'MBPS $centerLabel'`, `'DL'` false positive (D)
**Kanıt:** `speedometer_arc.dart:176, 205` — teknik birim/etiket. Lokalize edilmez.

### B10.5 — `'ANONYMIZE BSSID'` UI label (D)
**Kanıt:** `reports_page.dart:224` `find_strings.py` tarafından yakalandı.
**Kontrol gerek:** Bu UI label mı yoksa parameter mi? Eğer Text() içinde gösterilen UI label ise lokalize edilmeli. Kısım 14 öncesi tekrar bakılabilir.

---

## Kanıt Tablosu

| İddia | Konum | Sonuç |
|---|---|---|
| Dashboard 0 hardcoded | `find_strings.py lib/features/dashboard` | 0 |
| LocalDataExport anonymize | `local_data_export_service_impl.dart:413-423` | `_maskBssid`, `_maskMac`, `_maskSsid` 3 anonymizer |
| 12 kategori coverage | `UserDataCategory` enum | wifi/speed/security/trusted/.../router-hardening |
| PDF lock crypto sınırı | `pdf_lock_service.dart:11-22` doc | "obfuscation, not encryption — not for determined attacker" |
| Constant-time compare | `pdf_lock_service.dart:105` | `_constantTimeEquals` (`diff |= a[i] ^ b[i]`) |
| Salt entropi | `pdf_lock_service.dart:_randomBytes` | Önce `DateTime.now()`, sonra `Random.secure()` ✅ |
| UI naming "lock" değil "encrypt" | `app_en.arb pdfLockedHint` | "Locked file: .torcav-pdf" |
| 0 dış servis (export) | `grep "http\|cloud\|upload" reports/` | yalnızca `'upload_mbps'` (speed test alanı) |

---

## Kısım 10 Bulgu Özeti

| Bulgu | Şiddet | Durum |
|---|---|---|
| B10.1 PDF lock zayıf entropi | D | ✅ Düzeltildi (Random.secure) |
| B10.2 PDF disclaimer iki-dilli hardcoded | O | Backlog (kasıtlı tasarım olabilir) |
| B10.3 Performance HttpClient | D | Kısım 2'den taşınan |
| B10.4 Speedometer label'lar | D | False positive |
| B10.5 'ANONYMIZE BSSID' UI label | D | Kısım 14 öncesi tekrar bak |
| ✅ Compliance pozitifleri | — | 4 (Dashboard temiz, Export GDPR, PDF naming dürüst, HMAC/CT-compare) |

**Düzeltme: 1 uygulandı (B10.1 Random.secure)**

flutter analyze: temiz

---

## Play Store Submit Notu (Kısım 14'e)

- **Data Safety form:**
  - "Data is encrypted in transit" → N/A (lokal export, ağa gitmiyor)
  - "Users can request data deletion" → ✅ ("Wipe all local data" akışı zaten var)
  - "Users can request their data" → ✅ Export functionality (12 kategori, 3 format)
- **Misleading Claims:**
  - PDF "lock" özelliği "encrypt" olarak satılmıyor ✅
  - `pdfLockedHint` UI metni teknik gerçeklikle uyumlu ✅
