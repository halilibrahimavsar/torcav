# Kısım 2 — Core II (Router, Network, Utils, Constants, Data)

> Kapsam: `lib/core/router/`, `lib/core/network/`, `lib/core/utils/`, `lib/core/constants/`, `lib/core/data/`

## Çarpıcı Ön Bulgu
5 klasörün **4'ü tamamen boş** — `router/`, `network/`, `constants/`, `data/` hiç dosya içermiyor. Sadece `utils/` altında tek dosya (`oui_lookup.dart`, 30 satır). Yani bu kısım küçük, ama boş klasörler birer bulgudur.

---

## Bulgular

### B2.1 — 4 boş `core/` alt-klasörü (Y) — geliştirme artığı
**Kanıt:**
```
lib/core/router/     → 0 dosya
lib/core/network/    → 0 dosya
lib/core/constants/  → 0 dosya
lib/core/data/       → 0 dosya
```
**Tespit:** Bu klasörler ilk mimari iskelet kurulurken oluşturulmuş ama hiç doldurulmamış. Git boş dizinleri izlemez, dolayısıyla bunlar sadece local file system'da var ama yine de proje kafa karışıklığı yaratır ("router/ var demek GoRouter mı?", "network/ var demek centralized HTTP client mı?").
**Aksiyon:**
- `rmdir lib/core/router lib/core/network lib/core/constants lib/core/data`
- Gelecekte gerçek implementasyon eklendiğinde klasör tek dosya ile başlasın.

### B2.2 — Dağınık `dart:io HttpClient()` kullanımı, centralized client yok (Y)
**Kanıt:** `grep "HttpClient(" lib/`:
```
lib/features/security/domain/services/captive_portal_detector.dart:27  (HTTP, 5s timeout)
lib/features/security/data/datasources/dns_test_data_source.dart:203   (HTTPS, 2s timeout)
lib/features/performance/data/repositories/speed_test_repository_impl.dart:44, 67  (2 ayrı yerde)
```
**Tespit:** 4 ayrı yerde inline `HttpClient()` kullanımı. Hiçbir merkezi yapılandırma yok — kullanıcı agent string'i (User-Agent), TLS pinning, request logging, hata haritalama, retry politikası **hiçbiri yok**. Bu durum:
- Play Store Data Safety: "Data transmitted over network" beyanında her ayrı çağrı izlenmek zorunda; merkezi olmadan denetimi zor.
- Test edilemez: her test'te HttpOverrides ile mock'lamak zorunlu.
- Bakım zor: yeni timeout politikası tek noktadan değiştirilemiyor.

**Aksiyon (kısa vadeli, Kısım 14 öncesi yeterli):** Hiçbiri TLS bypass yapmıyor, default sertifika doğrulama açık. `User-Agent` belirtilmediği için Dart varsayılan UA'sı kullanılıyor (`Dart/X.Y (dart:io)`). Bu bilgi sızıntısı küçük ama Play Store için problem değil.
**Aksiyon (orta vadeli, sürüm sonrası):** `lib/core/network/app_http_client.dart` ile minimal wrapper (sadece UA + timeout + structured error). Şimdilik **bulgu olarak işaretle**, düzeltme acil değil.

### B2.3 — `OuiLookup.isSuspicious` MAC randomization tespiti (D) — bilgi/doğrulama
**Kanıt:** `lib/core/utils/oui_lookup.dart:23-28`:
```dart
static bool isSuspicious(String mac) {
  final oui = OuiDatabaseService.normalizeMacToOui(mac);
  if (oui == null) return false;
  final secondChar = oui[1].toUpperCase();
  return ['2', '6', 'A', 'E'].contains(secondChar);
}
```
**Tespit:** LAA bit kontrolü (`bit 1 of first byte`) doğru — IEEE standardı:
- `02:...` (binary `0000 0010`) → bit 1 set → LAA ✅
- `06:...` (`0000 0110`) → bit 1 set → LAA ✅
- `0A:...` (`0000 1010`) → bit 1 set → LAA ✅
- `0E:...` (`0000 1110`) → bit 1 set → LAA ✅
- ama: `12`, `16`, `1A`, `1E`, `22`, `26`, ... gibi tüm "ikinci karakteri 2/6/A/E" olan MAC'ler de LAA. Mevcut kod sadece **ikinci karakter** kontrol ediyor, **ilk karakter** yok sayılıyor.

**Sorun mu?** Hayır, MAC randomization tüm LAA MAC'lerini kapsar; ilk hex karakter da olabilir. Mevcut kod tüm geçerli LAA MAC'leri yakalar.

Yine de bu mantığın MAC standartlarına 100% uygun olduğunu **resmen** doğrulamak için Kısım 8 (security)'de tekrar incelenecek. Şu an için **doğru kabul**.

**Compliance notu:** MAC adresleri Play Store "Personal Info — Other identifiers" kategorisinde sayılabilir; OUI lookup ile vendor çıkarımı yapıldığı için "Device or other IDs" beyanı şart. Kısım 14'e taşınacak.

---

## Yan Bulgular (sonraki kısımlara taşınanlar)

### B2.X1 → Kısım 9 (Monitoring/Diagnostics/Ping)
AndroidManifest.xml'de `<intent-filter><action android:name="android.net.VpnService" /></intent-filter>` mevcut. Bu **Google Play VPN policy** kapsamında özel ele alma gerektirir (Play Store "Permission Declaration Form"). Ping stabilizer modülünde VPN servisi kullanılıyor olmalı — Kısım 9'da derinlemesine.

### B2.X2 → Kısım 11/12 (Heatmap/Native)
Deep link / app link YOK — sadece MAIN+LAUNCHER intent. Play Store için zorunlu değil ama uygulamadan paylaşım/açma akışı varsa gözden geçirilmeli.

---

## Kanıt Tablosu

| Bulgu | Komut | Çıktı |
|---|---|---|
| B2.1 | `ls -la lib/core/{router,network,constants,data}/` | 4 klasör de **0 dosya** |
| B2.2 | `grep "HttpClient(" lib/ -rn` | **4 inline kullanım** (security ×2, performance ×2) |
| B2.2 | `grep "badCertificateCallback\|allowBadCertificates" lib/` | **0 sonuç** (TLS bypass yok ✅) |
| B2.3 | OuiLookup kaynak kodu okundu | LAA bit kontrolü mantıken doğru |
| B2.X1 | `grep -A3 "intent-filter" AndroidManifest.xml` | `android.net.VpnService` mevcut |

---

## Önerilen Düzeltme Sırası

1. **`rmdir`** boş 4 klasör (B2.1) — tek satır, risksiz.
2. Centralized HTTP client (B2.2) — **şimdilik atla**, sürüm sonrası refactor olarak işaretle. `lib_feature_backlog.md` veya `docs/internal/`'a not düş.

**Kısım 2 doğrulanmış bulgu sayısı: 3** — 0 kritik, 2 yüksek, 0 orta, 1 düşük.

---

## Açık Sorular

1. **Centralized HTTP client şimdi mi sonra mı?** Önerim: sonra. Şu an 4 çağrı, TLS bypass yok, bug yaratmıyor. Refactor sürüm öncesi gereksiz risk.
2. **Boş `core/` klasörleri** silinsin mi yoksa `.gitkeep` ile "ileride doldurulacak" sinyali mi verilsin? Önerim: sil — git boş klasör izlemez, `.gitkeep` "burada bir şey olacak" yalanı söyler.
