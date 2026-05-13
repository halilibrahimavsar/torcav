# Torcav Manuel Test Planı — Bug Avı

> **Hedef:** Denetim sonrası (Kısım 0-14) tüm uygulamayı + denetim değişikliklerini manuel doğrulamak.
> **Süre tahmini:** 3-4 saat tek seferde (veya 2 günde 2 oturum).
> **Cihaz ihtiyacı:**
> - **Android 13+ telefon** (NEARBY_WIFI_DEVICES + POST_NOTIFICATIONS testi için zorunlu)
> - **Android <13 telefon** (ACCESS_FINE_LOCATION yolunu test için — opsiyonel)
> - **Bir kablosuz ağ** (ev/ofis Wi-Fi)
> - **2+ Wi-Fi cihazı** ağda (LAN scan için)

---

## ✅ Test Ön Hazırlık

```bash
# 1. Release build çıkar (R8 minify aktif test için)
cd ~/Masaüstü/torcav
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter build apk --release

# 2. APK'yı cihaza yükle
adb install -r build/app/outputs/flutter-apk/app-release.apk

# 3. Logcat'i hazırla (paralel terminal, AppLogger.e çıktıları için)
adb logcat *:S flutter:V TorcavStabilizer:V
```

**Beklenen APK boyutu:** ~47 MB (denetim sonrası, Firebase çıkarıldı).
**Eğer 49+ MB ise:** `pubspec.lock`'ta firebase paketleri varsa B12.6 geri gelmiş demektir.

---

## 📋 Test Numaralandırması

- **T01-T09:** Smoke + denetim regression
- **T10-T19:** Onboarding (Kısım 6)
- **T20-T29:** Wi-Fi & LAN Scan (Kısım 7)
- **T30-T39:** Security (Kısım 8a/8b/8c)
- **T40-T49:** Monitoring / Diagnostics / Ping (Kısım 9)
- **T50-T59:** Heatmap (Kısım 11)
- **T60-T69:** Reports + Settings (Kısım 10/11)
- **T70-T79:** Performance + Dashboard (Kısım 10)
- **T80-T89:** Edge cases + stres
- **T90-T99:** Storage / Encryption (Kısım 5 derin)

---

# 🔥 BÖLÜM 1 — Smoke & Denetim Regression (T01-T09)

## T01 — Cold start & version display
**Önkoşul:** App'i ilk kez yükle (veya `adb uninstall` sonra `adb install`).
**Adımlar:**
1. App'i aç.
2. Splash ekranı çıksın.
3. Sağ üstte "PLATFORM" yazsın altta "ANDROID".
4. Sol üstte "BUILD" yazsın altta versiyon (örn. `v1.0.0`).
5. Alt sağda "VAULT STATUS: AES-256-GCM" (yeşil) ya da "MOUNTING..." görsün.

**Beklenen:**
- ✅ Splash ~800ms-2sn içinde geçsin (anti-flicker)
- ✅ Versiyon `pubspec.yaml`'daki `1.0.0+1` ile eşleşmeli → ekranda **`v1.0.0`** (Kısım 6 B6.6 dinamik okuma)

**Bug işaretleri:**
- ❌ Versiyon `v1.0.4` görüyorsan → eski hardcoded geri gelmiş
- ❌ Versiyon "..." donuyorsa → `PackageInfo.fromPlatform()` çağrısı başarısız
- ❌ Splash 5+ sn donuyorsa → `_runInitSequence` blocking

**İlgili denetim:** Kısım 6 (B6.6)

---

## T02 — İlk açılış → Onboarding zorunlu
**Önkoşul:** T01 sonrası, ilk açılış.
**Adımlar:**
1. Splash bitsin.
2. **OnboardingPage** açılmalı (6 sayfalı).
3. Sayfa 1: Welcome — "Torcav'a hoşgeldin..."

**Beklenen:**
- ✅ Onboarding ekranı çıkmalı, **direkt AppShell'e atlamamalı**.
- ✅ Sayfanın altında 6 nokta indikatörü.

**Bug işaretleri:**
- 🔴 Direkt Dashboard açılıyorsa → **Kısım 6 B6.1 KIRIK** (Play ihlali geri gelmiş)
- ❌ 5 nokta varsa → `_NotificationsPage` eklenmemiş (B6.3 kırık)

**İlgili denetim:** Kısım 6 (B6.1, B6.3)

---

## T03 — Logcat'te debug log spam testi
**Önkoşul:** App release modda çalışıyor, logcat açık.
**Adımlar:**
1. Logcat'i temizle: `adb logcat -c`
2. App'i tamamen kapat (recents'ten swipe).
3. App'i tekrar aç.
4. 30 saniye boyunca dolaş (Dashboard → Wi-Fi → Geri).
5. Logcat'te `DEBUG:`, `INFO:`, `WARNING:` etiketli satırları say.

**Beklenen:**
- ✅ `DEBUG: ...` satırı **0 olmalı** (Kısım 1 B1.1 — release'de no-op)
- ✅ `INFO: ...` satırı **0 olmalı**
- ✅ `WARNING: ...` satırı **0 olmalı**
- ✅ Sadece `ERROR: ...` çıkabilir (gerçek hata varsa)

**Bug işaretleri:**
- ❌ DEBUG/INFO/WARNING logları varsa → AppLogger gating bozulmuş
- ❌ `print` / `debugPrint` ham çıktıları varsa → Kısım 1-11 düzeltmeleri bozulmuş

**İlgili denetim:** Kısım 1 (B1.1) + tüm `debugPrint` temizlikleri

---

## T04 — Tek-tıkla "Wipe All Local Data" smoke
**Önkoşul:** Bir kez tarama yapmış, biraz veri biriktirmiş ol.
**Adımlar:**
1. Settings → Privacy → "Wipe All Local Data".
2. Confirm dialog gelsin.
3. "Yes, wipe everything" tıkla.

**Beklenen:**
- ✅ Snackbar veya feedback: "Done"
- ✅ Geri Dashboard'a dönünce: 0 networks, 0 scan history, 0 security events
- ✅ Ek bir kez tarama yapınca veriler temizmiş gibi gelmeli

**Bug işaretleri:**
- ❌ Confirm yok → kullanıcı yanlışlıkla siler
- ❌ Wipe sonrası app çöker → Hive box reset hatalı
- ❌ Eski veriler hâlâ görünüyor → multi-store deleteAll eksik

**İlgili denetim:** Kısım 11 (Wipe All flow)

---

## T05 — Tema (Light/Dark) toggle
**Önkoşul:** App açık, herhangi bir sayfada.
**Adımlar:**
1. Drawer aç (sol üstten swipe veya hamburger).
2. Tema toggle butonu.
3. Light → Dark veya Dark → Light geçiş yap.

**Beklenen:**
- ✅ Anında geçiş.
- ✅ Tüm sayfalar yeni temaya uyumlu.

**Bug işaretleri:**
- ❌ Bazı widget'lar eski temada kalıyor → ColorScheme eksik kullanım
- ❌ Geçiş sonrası bazı text okunmuyor → contrast hatası

---

## T06 — Dil değişimi (TR / EN / DE / KU)
**Önkoşul:** App açık.
**Adımlar:**
1. Settings → Language → Türkçe.
2. Geri dön, Dashboard'da metinleri kontrol et.
3. Tekrar Settings → English → kontrol et.
4. German → ku kontrol et.

**Beklenen:**
- ✅ Tüm UI metinleri seçilen dile geçer.
- ✅ TR/DE: bazı metinler (313 marka/teknik) İngilizce kalabilir (false positive)
- ⚠️ TR/DE/KU: ~353 metin İngilizce kalabilir (untranslated_keys_list.md — sürüm sonrası çevrilecek)

**Bug işaretleri:**
- ❌ Hiçbir metin değişmiyorsa → LocaleCubit save/load bozuk
- ❌ Crash → ARB key generated kod ile uyumsuz

**İlgili denetim:** Kısım 3 (Localization)

---

## T07 — Hata ekranı (rendering error)
**Önkoşul:** App release modda.
**Test (yapay hata yok — sadece spot check):**
- Eğer bir UI render error olursa: NeonErrorWidget açılmalı, kullanıcıya jenerik mesaj göstermeli (Türkçe/İngilizce vs.), exception detayı **gizli olmalı** (release modda).

**Beklenen mesaj (TR):** "Bu ekran çizilirken bir sorun oluştu. Lütfen uygulamayı yeniden başlatın."

**Bug işaretleri:**
- ❌ Stack trace görünüyorsa → `_NeonErrorWidget` kReleaseMode kontrolü kırık (B1.3)

**İlgili denetim:** Kısım 1 (B1.3)

---

## T08 — Dinamik versiyon eşleşme
**Adımlar:**
1. Settings sayfasında / About / Hakkında bölümü ara.
2. Versiyon bilgisi göster.

**Beklenen:**
- ✅ Splash'taki versiyonla aynı: `v1.0.0`.

---

## T09 — Asenkron hata yakalama (runZonedGuarded)
**Test:** Bu zor manuel yapmak. Ama spotça:
- App'i uçak modunda aç.
- Wi-Fi scan başlat.
- Hata mesajı görsen bile **app çökmesin**.

**Beklenen:**
- ✅ Hata yakalama akışı çalışmalı.

**İlgili denetim:** Kısım 1 (B1.2)

---

# 🚀 BÖLÜM 2 — Onboarding (T10-T19)

## T10 — Sayfa 1: Welcome
**Adımlar:** İlk açılışta gelen welcome ekranını incele.

**Beklenen:**
- ✅ İkon: wifi_find_rounded
- ✅ Başlık + body lokalize
- ✅ Alt butonda "Next" yazsın

---

## T11 — Sayfa 2: Permissions (Location)
**Adımlar:** Welcome'dan Next.

**Beklenen:**
- ✅ İkon: location_on_rounded
- ✅ Body: Konum izninin neden gerekli olduğu açıklanır.

**Bug işaretleri:**
- ❌ Bu sayfada "İzin ver" butonu varsa → eski tasarım (Kısım 6 B6.2 — backlog'a alındı, bu kısımda buton yok)

**Not:** Konum izni gerçek tarama sırasında istenecek (wifi_scan_page disclosure flow).

---

## T12 — 🔴 Sayfa 3: Notifications (YENİ — Kısım 6 B6.3)
**Adımlar:** Permissions'dan Next.

**Beklenen:**
- ✅ Sayfa 3'te gelmeli.
- ✅ İkon: notifications_active_rounded
- ✅ Başlık: "Güvenlik Uyarıları" / "SECURITY ALERTS"
- ✅ Body: "Torcav ağınızda bir güvenlik olayı tespit ettiği an haberdar olun..."
- ✅ Buton: "Bildirimleri etkinleştir" (mavi/secondary renkte)
- ✅ Altında: "Şimdilik geç" yazısı

**Test:**
1. "Bildirimleri etkinleştir" butonuna bas.
2. Android sistem dialogu çıkmalı: "Allow Torcav to send you notifications?"
3. "Allow" seç.
4. Tekrar dene → buton tekrar basılınca yeniden istek çıkmasın (zaten verilmiş).

**Bug işaretleri:**
- 🔴 Sayfa **yoksa** → Kısım 6 B6.3 düzeltmesi kırık
- ❌ Butona basınca sistem dialog çıkmıyorsa → `NotificationService.requestAndroidNotificationPermission()` bozuk (Kısım 5 B5.2)
- ❌ Allow sonrası bildirimler hiç gelmiyorsa → permission cache hatası

**İlgili denetim:** Kısım 5 B5.2 + Kısım 6 B6.3

---

## T13 — Sayfa 4: Tour
**Beklenen:**
- ✅ "Dashboard / Discovery / Operations" 3 kart.

---

## T14 — Sayfa 5: Network Context
**Adımlar:** Bir context seç (Home/Public/Guest/Unknown).

**Beklenen:**
- ✅ 4 seçenek.
- ✅ Seçim sonrası kart highlight olur.
- ✅ Bir tane seçmeden Next'e basamaz isen... aslında basabilirsin (varsayılan unknown).

---

## T15 — Sayfa 6: Done (Onaylar)
**Beklenen:**
- ✅ 3 checkbox:
  - ToS + Privacy Policy onayı (linkler tıklanabilir)
  - "Authorized user" onayı
  - Yaş (13+) onayı
- ✅ 3'ü işaretlenmeden "START SCANNING" butonu **disabled** (gri).

**Test:**
1. ToS linkine bas → Terms of Service sayfası açılmalı.
2. Privacy linkine bas → Privacy Policy sayfası açılmalı.
3. 3 checkbox işaretle → buton aktive olsun.
4. "START SCANNING" → Dashboard'a geç.

**Bug işaretleri:**
- 🔴 Checkbox işaretlenmeden buton aktif → Play Store onay akışı bozuk
- ❌ ToS/Privacy linkleri açılmıyorsa → MaterialPageRoute bozuk

---

## T16 — Onboarding atlandığında re-trigger
**Adımlar:**
1. Onboarding tamamla, Dashboard'a gel.
2. Settings → "Replay Onboarding" (veya benzeri).
3. Onboarding tekrar başlasın.

**Beklenen:**
- ✅ Onboarding ekranı tekrar açılır.
- ✅ Tamamlanınca tekrar Dashboard'a döner.

**İlgili denetim:** Kısım 6 B6.10 (`OnboardingPage.completionKey`)

---

## T17 — Onboarding kalıcılık (kapatıp aç)
**Adımlar:**
1. Onboarding tamamla.
2. App'i tamamen kapat (swipe).
3. Tekrar aç.

**Beklenen:**
- ✅ Splash → Dashboard (Onboarding atlanır).
- ✅ `onboarding_complete = true` Hive'da saklı.

**İlgili denetim:** Kısım 6 B6.1

---

# 📡 BÖLÜM 3 — Wi-Fi & LAN Scan (T20-T29)

## T20 — Wi-Fi Scan: İlk açılış prominent disclosure
**Önkoşul:** Onboarding tamam, Wi-Fi izni daha önce verilmedi.
**Adımlar:**
1. Bottom nav → Discovery → Wi-Fi.

**Beklenen:**
- ✅ ProminentDisclosureDialog açılır:
  - Başlık: "Wi-Fi Permission" / "Wi-Fi İzni"
  - İkon: location_on_rounded
  - 3 privacy point:
    - "We scan nearby Wi-Fi SSIDs"
    - "Signal strength is analyzed"
    - "No tracking, all local"
  - Buton: "Continue" + "NOT NOW"

**Test:**
1. "Continue" bas.
2. Android sistem dialog: "Allow location access?" → "While using the app".
3. Sonra otomatik Wi-Fi scan başlamalı.

**Bug işaretleri:**
- 🔴 Disclosure YOK direkt sistem dialog çıkarsa → Kısım 7 B7.✅1 kırık
- ❌ "NOT NOW" → app çökerse → fallback eksik

**İlgili denetim:** Kısım 7 B7.✅1

---

## T21 — Wi-Fi Scan: Network listesi
**Adımlar:**
1. T20 sonrası scan tamamlansın.
2. Network listesini incele.

**Beklenen:**
- ✅ En az 1 network göster (etrafında Wi-Fi olduğu varsayım).
- ✅ Her network için: SSID, BSSID, signal strength (dBm), security badge, channel.

**Bug işaretleri:**
- ❌ SSID `[redacted]` görünüyorsa → anonymize toggle yanlışlıkla aktif
- ❌ BSSID `00:00:00...` görünüyorsa → MAC randomization veya OS sınırı
- ❌ Crash → wifi_scan paketi versiyon uyumsuzluğu

---

## T22 — Wi-Fi Scan: Detay sayfası + Hardening
**Adımlar:**
1. Bir networke tap.
2. Wi-Fi Details sayfasında security skoru görsün.
3. Findings (vulnerabilities) listesi varsa incele.
4. Hardening tab veya butonu → Router Hardening Wizard.

**Beklenen:**
- ✅ Score göster (0-100).
- ✅ Findings lokalize (TR seçiliyse Türkçe).
- ✅ Hardening Wizard 8 öğelik checklist.
- ✅ Her hardening item için: title, body, step-by-step (l10n'dan)

**Bug işaretleri:**
- ❌ Findings İngilizce kalır (TR'de) → vulnerability_extensions.dart ruleId switch eksik
- ❌ Hardening çekçek başlığı İngilizce → `HardeningCheckX.title(context)` çağrılmıyor

**İlgili denetim:** Kısım 8a (B8a.1 halüsinasyon doğrulaması), Kısım 8a (B8a.2 dead fields)

---

## T23 — LAN Scan: Consent akışı
**Adımlar:**
1. Bottom nav → Discovery → Network/LAN.
2. "Start scan" butonu.

**Beklenen:**
- ✅ ProminentDisclosureDialog:
  - Başlık: "Network Audit Consent" / "Ağ Denetimi Onayı"
  - İkon: gavel_rounded
  - 4 privacy point:
    - "We scan network nodes"
    - "Device fingerprinting"
    - "Vulnerability identification"
    - **"I confirm authorized user"** ← Play Store policy şartı!
  - Buton: "I Understand"

**Test:**
1. "Cancel" — scan başlamaz.
2. Tekrar başlat → disclosure → "I Understand" → scan başlasın.

**Bug işaretleri:**
- 🔴 "Authorized user" privacy point eksikse → Play Store Network Tools policy ihlali

**İlgili denetim:** Kısım 7 B7.✅2

---

## T24 — LAN Scan: Host listesi
**Adımlar:** T23 sonrası scan tamamlansın.

**Beklenen:**
- ✅ En az 1 host (kendisi + router minimum).
- ✅ Her host: IP, MAC, vendor (OUI), device type (AI sınıflandırma).
- ✅ Suspicious host'lar amber/red badge ile.

**Bug işaretleri:**
- ❌ AI classification "Unknown" çoğunluk → ONNX model yüklenmiyor
- ❌ Vendor "Unknown" → OUI database yüklenmiyor (Kısım 5 OUI service)

---

## T25 — LAN Scan: Yeni cihaz bildirimi
**Adımlar:**
1. T24 sonrası LAN scan tamamla.
2. Sonra ağa yeni bir cihaz bağla (telefon hotspot vs.).
3. Tekrar LAN scan.

**Beklenen:**
- ✅ Yeni cihazlar SnackBar ile bildirilir: "{n} new devices found"

**İlgili denetim:** new_device_detector (Hive encrypted)

---

## T26 — Wi-Fi Strict Safety Mode
**Adımlar:**
1. Settings → Strict Safety Mode → ON.
2. Wi-Fi Scan başlat.

**Beklenen:**
- ✅ Hidden SSID'ler **görünmüyor** (active probing engellendi).

**İlgili denetim:** Kısım 7 B7.✅3

---

## T27 — Wi-Fi Scan: Auto-scan timer
**Adımlar:**
1. Settings → Auto-scan: ON, interval: 60s.
2. Wi-Fi sayfasında dur, 60 saniye bekle.

**Beklenen:**
- ✅ Otomatik scan tetiklenir.
- ✅ Eski listeden farklı olabilir.

---

## T28 — Wi-Fi Comparison
**Adımlar:** Scan history varsa "Compare" özelliği.

**Beklenen:**
- ✅ İki snapshot karşılaştırması.

---

## T29 — Channel Rating
**Adımlar:** Wi-Fi sayfasındaki recommendation banner.

**Beklenen:**
- ✅ "Best channel: X" önerisi.

---

# 🛡️ BÖLÜM 4 — Security (T30-T39)

## T30 — Security Center hub
**Adımlar:** Drawer veya Operations → Security Center.

**Beklenen:**
- ✅ Score radar (0-100).
- ✅ Recent security events listesi.
- ✅ "Run Deep Scan" butonu.

---

## T31 — Vulnerability Lab
**Adımlar:** Security → Vulnerability Lab.

**Beklenen:**
- ✅ Bağlı network için detaylı section'lar:
  - Wi-Fi Configuration findings
  - Trusted Network drift
  - Hardware vulnerabilities
  - LAN Exposure
- ✅ Her finding lokalize.

**Bug işaretleri:**
- ❌ İngilizce metin (TR'de) → vulnerability_extensions ruleId eşlemesi eksik

---

## T32 — Evil Twin Detection
**Adımlar:** Eğer aynı SSID ile 2+ AP varsa Security'de "Evil Twin" alert göster.

**Beklenen:**
- ✅ Confidence label: Safe/Low/Medium/High
- ✅ Tap → Evil Twin Detail sayfası
- ✅ Detail sayfada:
  - Headline (l10n, scenario'ya göre)
  - What is / Why it matters (l10n bölüm başlıkları)
  - Observed signals (enum → l10n)
  - Recommended actions (enum → l10n)

**Bug işaretleri:**
- 🔴 Headline/body İngilizce kalırsa (TR'de) → Kısım 8c EvilTwinExplanation refactor bozuk
- ❌ Confidence renkleri yanlış → `_palette(confidenceLabel)` switch bozuk

**İlgili denetim:** Kısım 8c B8a.3 (halüsinasyon doğrulaması — UI zaten l10n switch)

---

## T33 — Router Hardening Wizard
**Adımlar:** Security → Router Hardening (veya Wi-Fi Detail → Hardening).

**Beklenen:**
- ✅ 8 checklist:
  1. Change admin password (critical)
  2. Use WPA3 / WPA2-AES (critical)
  3. Disable WPS (critical)
  4. Enable PMF
  5. Enable Guest Network
  6. Disable Remote Admin (critical)
  7. Update Firmware
  8. Strong Passphrase
- ✅ Her öğeyi expand: title, body, steps (l10n), menu hints (vendor names, İngilizce ok)

**Test:**
1. Bir öğeyi "Mark Done" → strikethrough görünsün, persist olsun.
2. App kapatıp aç → progress kayıtlı.

**Bug işaretleri:**
- ❌ Title/body İngilizce → HardeningCheckX.title(context) bozuk (Kısım 8a B8a.2 halüsinasyon)

**İlgili denetim:** Kısım 8a B8a.2 + Kısım 8a B8a.10 (dead fields silindi)

---

## T34 — Captive Portal Detection (Kısım 8a B8a.9 — YENİ)
**Önkoşul:** Captive portal'lı bir Wi-Fi'a bağlan (otel, kafe, public Wi-Fi).
**Adımlar:**
1. App'i aç.
2. Security Center → Run Deep Scan.

**Beklenen:**
- ✅ Security Events listesinde "Captive Portal Detected" alert görsün.
- ✅ Notification göster (POST_NOTIFICATIONS izni verilmişse).

**Bug işaretleri:**
- 🔴 Captive portal var ama alert yok → Kısım 8a B8a.9 düzeltmesi kırık (CaptivePortalDetector.check çağrılmıyor)

**İlgili denetim:** Kısım 8a B8a.9 (YENİ — dead → wired)

---

## T35 — DNS Security Card
**Adımlar:** Security → DNS Security panel.

**Beklenen:**
- ✅ DNS provider info.
- ✅ DoH/DoT durumu.
- ✅ Latency.
- ✅ Status: Secure / Warning / Ready

**Bug işaretleri:**
- ❌ "DoH Enabled" İngilizce kalırsa (TR'de) — aslında bu false positive, internal state

---

## T36 — ARP Spoofing Detection
**Adımlar:** Security tarama sırasında ARP table check.

**Beklenen:**
- ✅ ARP anomalileri tespit edilirse alert.

---

## T37 — Trusted Network ekleme
**Adımlar:** Wi-Fi Details → "Trust Network".

**Beklenen:**
- ✅ Network "trusted" olarak işaretlenir.
- ✅ Gelecek scan'lerde baseline drift kontrol edilir.

---

## T38 — Gateway Drift Detection
**Adımlar:** Eğer router IP'si değişirse alert beklenir.

---

## T39 — Security score history
**Adımlar:** Dashboard veya Security'de skor grafiği.

**Beklenen:**
- ✅ Zaman içinde skor grafiği.

---

# 🌐 BÖLÜM 5 — Monitoring / Diagnostics / Ping Stabilizer (T40-T49)

## T40 — Topology Page
**Adımlar:** Operations → Topology.

**Beklenen:**
- ✅ Network topology grafiği (gateway merkezde, host'lar yıldız).

---

## T41 — Spectrum Optimization
**Adımlar:** Operations → Spectrum.

**Beklenen:**
- ✅ Channel overlap chart.
- ✅ Channel history (varsa).
- ✅ Recommendation: "Switch to channel X".

---

## T42 — Speed Doctor (Diagnostics)
**Adımlar:** Operations → Diagnostics → Speed Doctor.

**Beklenen:**
- ✅ 5 phase progress (signal, channel, bufferbloat, DNS, etc.)
- ✅ Final diagnosis + recommended action.

---

## T43 — 🔴 Ping Stabilizer VPN Prominent Disclosure (Kısım 9 B9.1)
**Önkoşul:** App'te ping stabilizer hiç açılmadı.
**Adımlar:**
1. Operations → Ping Stabilizer.
2. Profile seç (örn. Valorant).
3. Ana toggle switch'i AÇ.

**Beklenen:**
- ✅ ProminentDisclosureDialog açılır:
  - İkon: shield_moon_rounded
  - Başlık: "Activate Ping Stabilizer" / "Ping Stabilizer'ı Etkinleştir"
  - 3 privacy point:
    - "Traffic stays on device, no remote server"
    - "Only DNS queries redirected, others passthrough"
    - "Stop anytime from screen or notification"
  - Buton: "Start stabilizer"
4. "Start stabilizer" bas.
5. Android sistem dialog: "Torcav wants to set up a VPN connection..." → Allow.
6. Tunnel başlamalı.

**Bug işaretleri:**
- 🔴 Disclosure YOK, direkt sistem dialog → Kısım 9 B9.1 KIRIK
- ❌ "Stop" sonrası tekrar başlatınca disclosure'ı GÖSTERMEYEBİLİR — bu OK (kullanıcı zaten onaylamış)
- ❌ POST_NOTIFICATIONS reddedilmişse → "notifications_blocked" banner göstermeli

**İlgili denetim:** Kısım 9 B9.1 (YENİ — düzeltildi)

---

## T44 — Ping Stabilizer aktifken Live Stats
**Önkoşul:** T43 sonrası tunnel active.
**Adımlar:**
1. Live jitter chart görsün.
2. 30 saniye bekle.

**Beklenen:**
- ✅ Latency / Jitter / Loss canlı güncelleniyor (~1 Hz).
- ✅ "Before/After" delta varsa baseline gösterilir.

---

## T45 — Ping Stabilizer Stop
**Adımlar:** Switch OFF.

**Beklenen:**
- ✅ Tunnel hemen kapanır.
- ✅ Notification kaybolur.
- ✅ Sistem ayarlarında Torcav'ın VPN profil aktif değil.

---

## T46 — Ping Stabilizer: DNS resolver seçimi
**Adımlar:** DNS Picker → Cloudflare / Google / vb. seç.

**Beklenen:**
- ✅ Seçilen resolver active.
- ✅ Tunnel açıksa setDns ile native'e gönderilir.

---

## T47 — Ping Stabilizer Profil değiştirme
**Adımlar:** Tunnel kapalı iken profile değiştir.

**Beklenen:**
- ✅ Yeni profile aktif.
- ✅ Tunnel açılınca yeni profile ile başlar.

---

## T48 — Ping Stabilizer: Cihaz dışarıdan revoke
**Adımlar:**
1. T44 sonrası tunnel açık.
2. Android Settings → Network → VPN → Torcav → Disconnect.

**Beklenen:**
- ✅ App'e geri dönünce status: idle (tunnelStopped event handler).

---

## T49 — Notification: Security alert (T43 sonrası)
**Önkoşul:** POST_NOTIFICATIONS izni verilmiş.
**Adımlar:**
1. Eğer bir security event tetiklenirse (örn. captive portal detection).
2. Notification shade'ı aç.

**Beklenen:**
- ✅ Torcav'dan notification: title + body lokalize.
- ✅ Tap → app açılır.

---

# 🗺️ BÖLÜM 6 — Heatmap (T50-T59)

## T50 — Heatmap: 3-izin prominent disclosure
**Önkoşul:** Camera, Location, ActivityRecognition izinleri verilmedi.
**Adımlar:**
1. Operations → Heatmap.
2. "New Session" butonu.
3. Session adı yaz: "Living Room".
4. "Continue" bas.

**Beklenen:**
- ✅ ProminentDisclosureDialog:
  - İkon: map_rounded
  - Başlık: "Heatmap Permissions"
  - 3 privacy point:
    - Location (Wi-Fi BSSID için)
    - Activity recognition (step counter)
    - Camera (AR pose)
- ✅ "Continue" → 3 izin TOPLU istek (sistem dialogları).

**Bug işaretleri:**
- 🔴 Disclosure YOK → Kısım 11 B11.✅1 kırık
- ❌ İzinler ayrı ayrı isteniyorsa → batch request bozuk

**İlgili denetim:** Kısım 11 B11.✅1

---

## T51 — Heatmap session başlatma
**Adımlar:** T50 sonrası, tüm izinler verilmiş.

**Beklenen:**
- ✅ AR view açılır (kamera akışı).
- ✅ AR HUD overlay: scan progress, RSSI live tag.

---

## T52 — Heatmap: Yürürken nokta toplama
**Adımlar:**
1. Telefonu yürüyerek 2-3 adım at.
2. AR HUD'da step indicator göster.

**Beklenen:**
- ✅ Her adımda yeni heatmap point eklenir.
- ✅ "Sample count" artar.

---

## T53 — Heatmap: Floor change (barometer)
**Önkoşul:** Çok katlı bina.
**Adımlar:** Asansör/merdivenle bir kat çıkıp inerek session test.

**Beklenen:**
- ✅ Floor index değişir (barometer-based).

**Not:** Tek katlı ortamda atlanır.

---

## T54 — Heatmap: Sparse region uyarısı
**Adımlar:** Yeterli ölçüm yapmadan dur.

**Beklenen:**
- ✅ "Sparse coverage" arrow göstergesi belirsiz alanlara işaret.

---

## T55 — Heatmap: Coverage Complete
**Adımlar:** Yeterli alan tarayınca.

**Beklenen:**
- ✅ "Ready Banner" göster: "Coverage looks good"
- ✅ Tamamlama opsiyonu.

---

## T56 — Heatmap: Session kaydetme
**Adımlar:** Session bitirme.

**Beklenen:**
- ✅ Session Hive'a (encrypted) kaydedilir.
- ✅ Geri dönünce listede görsün.

---

## T57 — Heatmap: Session paylaşma
**Adımlar:** Session detayında "Share" butonu.

**Beklenen:**
- ✅ Share sheet açılır (image/PDF).
- ❌ Eğer share başarısız olursa → AppLogger.e ile log (release'de görünür)

**İlgili denetim:** Kısım 11 B11.1 (debugPrint → AppLogger.e)

---

## T58 — Heatmap: AR HUD test edilen widget'lar
**Adımlar:** Session sırasında ekrandaki HUD elemanları.

**Beklenen:**
- ✅ Live signal tag (STD ± value)
- ✅ Sparse region arrow
- ✅ Recording status (REC + PTS count)
- ✅ Reticle ortada

---

## T59 — Heatmap: Manuel heading realign
**Adımlar:** AR HUD'da kompas yönlendirme butonu (varsa).

**Beklenen:**
- ✅ Yön sıfırlanır.

---

# 📄 BÖLÜM 7 — Reports & Settings (T60-T69)

## T60 — Reports: Generate PDF
**Adımlar:** Reports → "Generate Report".

**Beklenen:**
- ✅ PDF üretilir.
- ✅ "Share" veya "Save" seçeneği.

---

## T61 — Reports: PDF password lock
**Adımlar:**
1. Reports → password alanına "test123" yaz.
2. PDF üret.
3. Dosya `.torcav-pdf` uzantılı olmalı.

**Beklenen:**
- ✅ Locked file ile share/save.
- ✅ UI metni: "Locked file: .torcav-pdf — open it again from Reports"
- ❌ "encrypted" deme yok! (B10.✅3 — naming dürüst)

**İlgili denetim:** Kısım 10 B10.1 (Random.secure)

---

## T62 — Reports: PDF unlock
**Adımlar:** Reports'a geri → "Open locked file" → şifre gir.

**Beklenen:**
- ✅ Doğru şifre: PDF açılır.
- ✅ Yanlış şifre: "Wrong password" hatası.

---

## T63 — 🔴 Local Data Export — JSON
**Adımlar:** Reports → Local Data Export → JSON format → kategori seç → Export.

**Beklenen:**
- ✅ JSON dosyası üretilir.
- ✅ "anonymized" toggle ile SSID/BSSID/MAC mask olur.

**Bug işaretleri:**
- ❌ Hassas veri (SSID/BSSID) anonymize OFF iken plaintext (beklenen)
- ❌ Anonymize ON iken hala SSID görünüyorsa → mask fonksiyonu bozuk

**İlgili denetim:** Kısım 10 B10.✅2 (GDPR data export)

---

## T64 — Local Data Export — CSV
**Adımlar:** Format CSV → kategori seç → Export.

**Beklenen:**
- ✅ CSV (proper escape).
- ❌ "All categories" CSV seçilemez (FormatException doğru davranış).

---

## T65 — Local Data Export — HTML
**Adımlar:** Format HTML → All categories → Export.

**Beklenen:**
- ✅ HTML dosyası (header'lar, tablolar).
- ✅ Browser'da açınca CSS injection yok.

---

## T66 — 🔴 Wipe All Local Data
**Adımlar:** Settings → Privacy → "Wipe All Local Data".

**Beklenen:**
- ✅ Confirm dialog: "Are you sure?"
- ✅ Onay sonra tüm veri silinir.
- ✅ Dashboard sıfırlanır.
- ✅ Tekrar onboarding gerekmiyorsa onboarding flag korunmuş (Hive box reset'te sadece veri silinmiş)

**Bug işaretleri:**
- 🔴 Onaylamadan silinirse → Confirm dialog eksik
- 🔴 Wipe sonrası app çöker → store kaskad fail

**İlgili denetim:** Kısım 11 B11.✅2

---

## T67 — Settings: Retention periyodları
**Adımlar:** Settings → Privacy → Retention (Wi-Fi history, Speed test, Security events).

**Beklenen:**
- ✅ 3 kaydırıcı 7-365 gün.
- ✅ Değiştirince sonraki açılışta `DataRetentionService.enforceRetention()` etkisi.

---

## T68 — Settings: Strict Safety Mode
**Adımlar:** Settings → Privacy → Strict Safety Mode → toggle.

**Beklenen:**
- ✅ ON iken Wi-Fi scan hidden SSID atlar (T26).
- ✅ Deep scan disable.

---

## T69 — Settings: Replay Onboarding
**Adımlar:** Settings → "Replay Onboarding".

**Beklenen:** T16 ile aynı.

---

# 🎯 BÖLÜM 8 — Performance & Dashboard (T70-T79)

## T70 — Speed Test başlatma
**Adımlar:** Operations → Performance → "Run Speed Test".

**Beklenen:**
- ✅ 4 phase: latency → download → upload → jitter
- ✅ Sonuçta: ms / Mbps değerleri.

---

## T71 — Speed Test history
**Adımlar:** Performance sayfasında geçmiş test'ler.

**Beklenen:**
- ✅ Geçmiş sonuçlar listesi.

---

## T72 — Dashboard: Status header
**Adımlar:** Bottom nav → Dashboard.

**Beklenen:**
- ✅ Üstte: Wi-Fi connection status (CONNECTED / DISCONNECTED), SSID.
- ✅ Security score circle.

---

## T73 — Dashboard: Notification sheet
**Adımlar:** Dashboard → notifications icon → notification sheet.

**Beklenen:**
- ✅ Geçmiş security events listesi.
- ✅ Tap → detay.

---

## T74 — Dashboard: Activity timeline
**Adımlar:** Activity timeline widget'ı.

**Beklenen:**
- ✅ Recent scan + security event'ler.

---

## T75 — Dashboard: Stabilizer toggle (mini)
**Adımlar:** Dashboard'daki stabilizer mini-toggle.

**Beklenen:**
- ✅ T43 ile aynı disclosure flow.

---

## T76 — Dashboard: Internet slow → Speed Doctor önerisi
**Adımlar:** Dashboard'da "Internet slow?" kartı.

**Beklenen:**
- ✅ Tap → Speed Doctor.

---

## T77 — Dashboard: Score history graph
**Beklenen:** ✅ Zaman içinde skor grafiği.

---

## T78 — Live metrics bento
**Beklenen:** ✅ Real-time current Wi-Fi / signal / etc.

---

## T79 — Radial dashboard core (security_core)
**Beklenen:** ✅ Görsel score gösterimi.

---

# 🔥 BÖLÜM 9 — Edge Cases & Stress (T80-T89)

## T80 — 🔴 Auto-heal flag testi (Kısım 5 B5.3 + Kısım 6 B6.4)
**Bu test özel — manuel veri bozma:**
1. App'i kapat.
2. Telefonda Settings → Apps → Torcav → Storage → Clear data **AMA** "Clear cache" değil, sadece **secure storage'ı manipüle** — bunu manuel yapmak imkansız.

**Alternatif test:**
1. App'i yükleyip kullan.
2. App'i uninstall et **AMA** secure storage Android Keychain'de kalır (cihaz-bağımlı).
3. Tekrar install et.
4. **Eğer** DB encryption key kayboldursa: AppDatabase auto-heal devreye girer → eski DB silinir → snackbar görmeli:
   - "Some of your data was reset to recover from a storage issue."

**Beklenen:**
- ✅ Snackbar mesajı çıksın (l10n.dbHealedNotice).
- ✅ App çökmeden devam.

**Bug işaretleri:**
- ❌ Sessiz veri kaybı (snackbar yok) → Kısım 5 B5.3 + Kısım 6 B6.4 kırık

**İlgili denetim:** Kısım 5 B5.3 + Kısım 6 B6.4

---

## T81 — Hive encryption boot test
**Adımlar:** App ilk açılışta.

**Beklenen (log):**
- Hive box AES key generated (secure_storage), box AES cipher ile açılır.
- ❌ Eğer cipher mismatch logu varsa → box reset olur (Kısım 5 B5.1 fallback)

---

## T82 — Build APK boyut testi (Kısım 12 regression)
```bash
ls -lh build/app/outputs/flutter-apk/app-release.apk
```

**Beklenen:**
- ✅ ~47 MB
- ❌ 49+ MB → Firebase geri gelmiş (Kısım 12 B12.6)
- ❌ 60+ MB → R8 minify kapalı

---

## T83 — Test edilemez izinlerin durumu (Android 13+)
**Önkoşul:** Android 13+ cihaz.
**Adımlar:**
1. Settings → Apps → Torcav → Permissions.
2. Hangi izinler listede?

**Beklenen:**
- ✅ Nearby devices (NEARBY_WIFI_DEVICES)
- ✅ Location
- ✅ Camera
- ✅ Physical activity (ACTIVITY_RECOGNITION)
- ✅ Notifications
- ❌ Body sensors GÖRÜNMEMELİ (`tools:node="remove"` ile çıkarıldı)
- ❌ Storage / Phone / SMS GÖRÜNMEMELİ
- ❌ Microphone GÖRÜNMEMELİ

**İlgili denetim:** Kısım 12 B12.✅1 (10 izin tools:node="remove")

---

## T84 — Uçak modunda app davranışı
**Adımlar:**
1. App açık iken cihazı uçak moduna al.
2. Sayfalar arası gez.

**Beklenen:**
- ✅ Network'e bağlı sayfalar uygun "no connection" mesajı.
- ✅ App çökmesin.

---

## T85 — Konum servisleri OFF
**Adımlar:**
1. Settings → Location → OFF.
2. Wi-Fi scan dene.

**Beklenen:**
- ✅ "Please ensure Location is enabled in system settings" mesajı.
- ✅ App çökmesin.

---

## T86 — Düşük bellek senaryosu (yapay zor)
**Adımlar:** Çok büyük scan + heatmap + reports paralel.

**Beklenen:**
- ✅ ONNX session dispose çağrılırsa native memory leak yok.
- ✅ App responsive kalır.

---

## T87 — Tema değişimi sırasında widget rebuild
**Adımlar:** Tema toggle hızlı tekrarla 5 kez.

**Beklenen:**
- ✅ Crash yok.

---

## T88 — Dil değişimi + ekran döndürme
**Adımlar:** Dil değiştir + ekranı yatay/dikey çevir.

**Beklenen:**
- ✅ Restoration ile son tab korunur.

---

## T89 — Background → Foreground
**Adımlar:**
1. App'i background'a al (home button).
2. 5-10 dakika bekle.
3. App'i geri aç.

**Beklenen:**
- ✅ State korunur (RestorableInt).
- ✅ Veri tutarlı.

---

# 🔐 BÖLÜM 10 — Storage / Encryption Derin (T90-T99)

## T90 — `flutter_secure_storage` test
**Manuel test zorluğu:** Bu cihazın Keychain/Keystore'una dokunmadan zor.

**Spot check:** Settings → Privacy → "Wipe All Local Data" sonrası tekrar açıldığında **DB encryption key yeniden üretilmesi**.

---

## T91 — Hive box dosyası encryption doğrulama
**Manuel adım:**
```bash
adb shell run-as dev.halilibrahim.torcav cat files/torcav_preferences.hive | head -c 200 | xxd
```
Eğer şifrelenmemiş ise SSID/BSSID metinleri açıkça görünür.

**Beklenen:**
- ✅ Output binary garbage (AES encryption aktif).
- ❌ Plaintext SSID/BSSID varsa → Kısım 5 B5.1 kırık

**İlgili denetim:** Kısım 5 B5.1 KRİTİK

---

## T92 — SQLCipher DB encryption doğrulama
```bash
adb shell run-as dev.halilibrahim.torcav cat databases/torcav.sqlite | head -c 100 | xxd
```

**Beklenen:**
- ✅ Binary, SQLite header değil.
- ❌ "SQLite format 3" → encryption kırık

---

## T93 — Onboarding flag persistence
**Adımlar:**
1. Onboarding tamamla.
2. App kapat, aç → onboarding skip ✅
3. Settings → Replay Onboarding → onboarding açıl ✅
4. Onboarding bitirme **olmadan** app'i kapat ve aç → tekrar onboarding ✅

---

## T94 — Network context override
**Adımlar:**
1. Bir network için context değiştir (Home → Public).
2. App kapat aç → değişiklik korunmuş.

---

## T95 — Router hardening progress
**Adımlar:**
1. T33'te bir item mark done.
2. App kapat aç → done olarak korunmuş.

---

## T96 — Heatmap session listesi
**Adımlar:** Heatmap → "Sessions" → eski session'ları gör.

**Beklenen:**
- ✅ Saved session'lar listede.
- ✅ Tap → detay görüntüsü.

---

## T97 — Device label override
**Adımlar:** LAN scan'de bir host'un label'ını manuel değiştir (örn. "Mobile Device" → "Mehmet'in iPhone'u").

**Beklenen:**
- ✅ Override kayıtlı.
- ✅ AI tekrar inference çalışsa bile override öncelikli.

---

## T98 — Pinned networks (favorites)
**Adımlar:** Wi-Fi scan'de bir networke pin/favorite işareti.

**Beklenen:**
- ✅ Favoriler ayrı section.

---

## T99 — Score history retention
**Adımlar:** Settings retention 7 gün ayarla, 7 gün sonra eski score'lar silinmiş olmalı.

**Manuel olarak test edilemez (zaman alır).**

---

# 📊 Test Sonuç Şablonu

Test sonuçlarını şu formatta kaydet:

```markdown
## Test Sonuçları — [TARİH]

**Cihaz:** [Marka / Model / Android sürümü]
**APK Boyutu:** [MB]
**Tester:** [İsim]

| Test ID | Durum | Not |
|---|---|---|
| T01 | ✅ | Versiyon doğru |
| T02 | ✅ | Onboarding zorunlu çıktı |
| T12 | ❌ | _NotificationsPage göstermedi, Kısım 6 B6.3 kontrol |
| ... | | |

**Bulgular:**
1. [Bug] T12: ...
2. [Improvement] T20: ...

**Kapsanmayan testler:** T80 (uninstall sonrası heal), T91/T92 (root erişim).
```

---

# 🎯 Öncelik Sırası (zaman kısıtlıysa)

**P0 — Mutlaka test (denetim regression kritik):**
T01, T02, T03, T12, T20, T23, T43, T50, T66, T83

**P1 — Önemli (sürüm öncesi):**
T07, T08, T15, T22, T34, T56, T63, T82

**P2 — Genel kapsama:**
Diğerleri

---

# ⚠️ Bug Raporlama Şablonu

```markdown
### BUG-XXX: [Kısa başlık]

**Test ID:** Txx
**Cihaz:** [Marka / Android sürümü]
**Şiddet:** [Critical / High / Medium / Low]

**Beklenen:** ...
**Gerçek:** ...

**Reproduce adımları:**
1. ...
2. ...

**İlgili denetim kısmı:** Kısım X (B X.Y)
**Logcat çıktısı:**
[varsa ekle]

**Ek bilgi:**
[ekran görüntüsü, screen recording, vb.]
```

---

**Toplam test sayısı:** 99 senaryo.
**Tahmini süre:** 3-4 saat hızlı geçiş, 6+ saat detaylı.
**İlk öncelik:** P0 testleri tamamla, regression yakalamak için.

Bu denetim sonrası **0 regression** olması beklenir. Bulduğun her şeyi `BUG-XXX` formatında raporla.
