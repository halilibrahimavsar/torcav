# Torcav Audit ve Play Store Roadmap

Bu belge 2026-04-20 tarihinde repo içinden yapılan statik inceleme, yerel build/test doğrulamaları ve resmi Google Play politika kaynakları üzerinden hazırlanmıştır. Ölçülen mevcut durum şudur: `flutter analyze` temiz, `flutter test` 10 hata ile kırık, `flutter build apk --debug --no-pub` ve `flutter build appbundle --release --no-pub` lokal olarak başarılıdır. Sonuç olarak uygulama teknik olarak derlenebilir, ancak politika ve mağaza hazırlığı açısından henüz hazır değildir. Play Store değerlendirmeleri hukuki mütalaa değil, repo bulguları + resmi politika metinlerinden türetilmiş yayın riski yorumudur.

## Executive Verdict

**Karar:** Google Play'e yükleme teknik olarak mümkün, mevcut haliyle inceleme/red riski **orta-yüksek**.

- Uygulama lokal olarak derlenebiliyor: `flutter build apk --debug --no-pub` ve `flutter build appbundle --release --no-pub` başarılı.
- Kod tabanı genel olarak derli toplu: `flutter analyze` temiz döndü.
- Buna rağmen yayın hazırlığı eksik: fazla/hassas izinler, gerçek privacy policy yüzeyinin yokluğu, "passive-only" söylemi ile gerçek ağ davranışı arasındaki uyumsuzluk ve eksik veri silme/retention kapsamı Play incelemesinde soru çıkarabilir.
- Ağ güvenliği ve LAN taraması yapan uygulama sınıfında olduğundan, Google Play tarafında sıradan utility app'e göre daha yüksek scrutiny beklenmeli.

**Kanıtlar**

- Manifest izinleri: `android/app/src/main/AndroidManifest.xml:2-16`
- Android kimlik/signing: `android/app/build.gradle.kts:12-29`, `android/app/build.gradle.kts:49-54`
- Onboarding beyanları: `lib/features/app_shell/presentation/pages/onboarding_page.dart:34-41`, `lib/features/app_shell/presentation/pages/onboarding_page.dart:321-388`
- Wi-Fi tarama davranışı: `lib/features/wifi_scan/data/datasources/android_wifi_data_source.dart:34-53`
- LAN aktif tarama/onay: `lib/features/network_scan/presentation/bloc/network_scan_bloc.dart:132-160`, `lib/features/network_scan/presentation/widgets/lan_consent_dialog.dart:52-55`

## Strengths

- **Modüler feature ayrımı güçlü.** `lib/features/` altında `wifi_scan`, `network_scan`, `security`, `ai`, `monitoring`, `heatmap`, `performance`, `reports`, `settings` gibi net sınırlar var; bu uzun vadede refactor ve ownership açısından avantaj.
- **On-device ML yaklaşımı doğru.** ONNX modeli asset olarak gömülü ve inference cihaz üstünde tutuluyor; bu, hassas ağ verisinin buluta gitmemesi açısından artı (`pubspec.yaml:101-103`, `assets/models/device_classifier.onnx`, `lib/features/ai/data/services/onnx_device_classifier_service.dart`).
- **Lokal veri işleme yaklaşımı baskın.** Wi-Fi, LAN, security event, assessment ve heatmap verileri yerelde tutuluyor (`lib/core/storage/app_database.dart:31-182`, `lib/features/heatmap/data/datasources/heatmap_local_data_source.dart:22-52`).
- **Görsel polish ortalamanın üstünde.** Özel theme, shader ve büyük ölçekli custom widget yatırımı var (`pubspec.yaml:105-108`, `lib/core/theme/neon_widgets.dart`, `lib/features/security/presentation/widgets/cyber_grid_background.dart`).
- **CI ve lokal Android build hattı var.** Repo'da GitHub Actions pipeline mevcut ve Android debug build artifact üretiyor (`.github/workflows/ci.yml:1-71`).
- **Yetkisiz kullanım riskini azaltmaya çalışan UI akışları başlamış.** Onboarding checkbox'ları, LAN consent dialog ve deep scan uyarıları doğru yönde ilk adımlar (`lib/features/app_shell/presentation/pages/onboarding_page.dart:372-388`, `lib/features/network_scan/presentation/widgets/lan_consent_dialog.dart:52-55`, `lib/features/settings/presentation/pages/settings_page.dart:675-728`).

## Feature Audit

### app_shell / dashboard

- **Artılar:** İlk açılışta onboarding ve temel legal acknowledgment var; kullanıcıyı doğrudan shell'e alıyor (`lib/features/app_shell/presentation/pages/onboarding_page.dart:34-41`, `lib/features/app_shell/presentation/pages/onboarding_page.dart:362-388`).
- **Eksikler:** Terms of Service / Privacy Policy checkbox'ı gerçek bir policy ekranına veya URL'ye bağlı değil; metin kabulü var ama okunabilir policy yüzeyi yok (`lib/features/app_shell/presentation/pages/onboarding_page.dart:372-388`).
- **Olursa Daha İyi:** Dashboard tarafında canlı veri güncellemesi, explainable score katmanı ve ekran paylaşımına uygun identifier masking varsayılanı eklenmeli.
- **Play/etik notu:** Onboarding metni yararlı ama Google Play'in istediği "permission request'ten hemen önce, feature-spesifik prominent disclosure" standardını tek başına karşılamaz. Özellikle heatmap ve location/sensor tarafında disclosure daha bağlamsal olmalı.

### wifi_scan

- **Artılar:** Android'de location runtime izni isteniyor, tarama throttling farkında ve extended Wi-Fi metadata okunuyor (`lib/features/wifi_scan/data/datasources/android_wifi_data_source.dart:34-53`, `lib/features/wifi_scan/data/datasources/android_wifi_data_source.dart:86-139`).
- **Eksikler:** UI yükleme metni hâlâ "Broadcasting Probe Requests" diyor; bu, "passive-only" anlatısıyla gerilim yaratıyor (`lib/features/wifi_scan/presentation/pages/wifi_scan_page.dart:146-172`).
- **Olursa Daha İyi:** DFS/6 GHz açıklığı, Android scan backoff görünürlüğü, canlı stream temelli refresh ve iOS sınırlılıklarının daha sert UX anlatımı eklenmeli.
- **Play/etik notu:** Tarama davranışı pasif değilse "pasif savunma aracı" söylemi yumuşatılmalı; pasif kalınacaksa UI ve implementation aynı dili konuşmalı. Bu bölümde location disclosure daha net ve izin istemine daha yakın olmalı.

### network_scan

- **Artılar:** Açık legal consent gate var, hedef subnet `/24` ile sınırlandırılıyor ve aktif tarama bunu kabul ederek başlıyor (`lib/features/network_scan/presentation/bloc/network_scan_bloc.dart:132-160`, `lib/features/network_scan/domain/entities/network_scan_policy.dart:21-34`).
- **Eksikler:** Port scan doğrudan socket connect yapıyor, banner okuyor ve SSDP multicast atıyor; bu alan en yüksek mağaza/politika scrutiny yüzeyi (`lib/features/network_scan/data/datasources/port_scan_data_source.dart:48-109`, `lib/features/network_scan/data/datasources/port_scan_data_source.dart:121-180`, `lib/features/network_scan/data/datasources/upnp_data_source.dart:18-39`).
- **Olursa Daha İyi:** IPv6, rate limiting, retry/backoff, kurumsal ağ guardrail'i ve daha görünür partial-result UX eklenmeli.
- **Play/etik notu:** Bu feature teknik olarak "passive-only" değil; aktif LAN discovery yapıyor. Store listing, onboarding ve legal disclaimer bunu dürüstçe anlatmalı, aksi halde Device and Network Abuse açısından yanlış konumlama riski oluşur.

### security

- **Artılar:** Captive portal ve DNS testleri gerçek ağ semptomlarını kullanıcıya çevirmeye çalışıyor; security event persistence yapısı mevcut (`lib/features/security/domain/services/captive_portal_detector.dart:21-58`, `lib/features/security/data/datasources/dns_test_data_source.dart:37-125`, `lib/features/security/data/datasources/security_local_data_source.dart:117-174`).
- **Eksikler:** "Wipe all" yalnızca security event'leri siliyor; `known_networks`, `trusted_network_profiles` ve `assessment_sessions` veri yüzeyleri akış dışında kalıyor (`lib/features/settings/presentation/pages/settings_page.dart:781-788`, `lib/features/security/data/datasources/security_local_data_source.dart:10-26`, `lib/features/security/data/datasources/security_local_data_source.dart:36-113`, `lib/features/security/data/datasources/security_local_data_source.dart:177-200`).
- **Olursa Daha İyi:** False-positive dili, explainable findings, CVE feed otomasyonu ve export/retention kapsamı güçlendirilmeli.
- **Play/etik notu:** Security app sınıfında olduğu için privacy policy zorunluluğu pratikte daha kritik. Ayrıca `connectivitycheck.gstatic.com`, `whoami.akamai.net` ve benzeri probelar privacy policy + in-app disclosure içinde açık yazılmalı.

### ai

- **Artılar:** Model cihaz üstünde çalışıyor ve kullanıcı ayarlarından kapatılabiliyor (`lib/features/settings/presentation/pages/settings_page.dart:340-361`, `lib/features/settings/domain/entities/app_settings.dart:21-22`, `lib/features/settings/domain/entities/app_settings.dart:38-42`).
- **Eksikler:** Test suite içinde ONNX classifier servisinin bazı senaryoları `SharedPreferences` mock eksikliği yüzünden kırık; bu da feature stabilitesini düşürüyor (örnek failing suite: `test/features/ai/data/services/onnx_device_classifier_service_test.dart`).
- **Olursa Daha İyi:** Model card, asset lisansı, düşük güven fallback'i, explainability ve batch inference isolation eklenmeli.
- **Play/etik notu:** Hostname/MAC/vendor kombinasyonu kişisel veri çağrışımı yapabilir; export davranışı, retention ve local-only garantisi privacy policy'de açık yazılmalı.

### monitoring / heatmap

- **Artılar:** Topology + signal monitoring + indoor survey iddiası ürün farkı yaratıyor. Heatmap oturumları yerel saklanıyor (`lib/features/monitoring/data/repositories/monitoring_repository_impl.dart:18-39`, `lib/features/heatmap/data/datasources/heatmap_local_data_source.dart:22-52`).
- **Eksikler:** Monitoring repository sonsuz döngü ile çalışıyor; batarya ve lifecycle kontrolü sınırlı (`lib/features/monitoring/data/repositories/monitoring_repository_impl.dart:22-38`). Heatmap yeni oturumunda sensor/activity/location/camera izinleri tek blokta isteniyor (`lib/features/heatmap/presentation/widgets/heatmap/new_session_dialog.dart:79-87`). Ayrıca wipe-all heatmap verisini temizlemiyor (`lib/features/settings/presentation/pages/settings_page.dart:781-788`, `lib/features/heatmap/data/datasources/heatmap_local_data_source.dart:22-52`).
- **Olursa Daha İyi:** Permission UX'nin parçalanması, session cleanup, batarya/backoff, export ve monitoring/heatmap duplication cleanup yapılmalı.
- **Play/etik notu:** `BODY_SENSORS`/`Permission.sensors` kullanımı mevcut ürün anlatısına göre aşırı geniş ve Google tarafında health scrutiny tetikleyebilir. Kamera ve activity recognition için de izin öncesi daha bağlamsal disclosure gerekli.

### performance / reports / settings

- **Artılar:** Speed test saf HTTP ile yürütülüyor, rapor export katmanı var, settings merkezi kontrol noktası görevi görüyor (`lib/features/performance/data/repositories/speed_test_repository_impl.dart:15-30`, `lib/features/reports/presentation/pages/reports_page.dart:195-263`, `lib/features/settings/presentation/pages/settings_page.dart:464-603`).
- **Eksikler:** Export anonymization varsayılan kapalı (`lib/features/reports/presentation/pages/reports_page.dart:42-47`, `lib/features/reports/presentation/pages/reports_page.dart:239-241`). Retention slider'ları UI seviyesinde var ama otomatik enforcement görünmüyor (`lib/features/settings/domain/entities/app_settings.dart:24-42`, `lib/features/settings/presentation/pages/settings_page.dart:495-531`). Wipe-all açıklaması "all local data" diyor ama LAN/heatmap/security profile yüzeylerini kapsamıyor (`lib/features/settings/presentation/pages/settings_page.dart:577-586`, `lib/features/settings/presentation/pages/settings_page.dart:781-788`).
- **Olursa Daha İyi:** Anonymization default ON, veri tüketim uyarısı, şifreli/signed export ve per-network policy eklenmeli.
- **Play/etik notu:** Reports feature üçüncü taraf SSID/BSSID/MAC benzeri verileri dışarı taşıyabildiği için privacy policy ve export redaction default'ları kritik.

## Project-wide Gaps

- **Aşırı büyümüş merkezi ekran dosyaları var.** İnceleme sırasında en büyük dosyalar arasında `lib/features/monitoring/presentation/pages/topology_page.dart` (1328 satır), `lib/features/settings/presentation/pages/settings_page.dart` (1253), `lib/features/dashboard/presentation/pages/dashboard_page.dart` (1229), `lib/features/network_scan/presentation/widgets/host_device_card.dart` (1058), `lib/features/performance/presentation/pages/performance_page.dart` (1035) ve `lib/features/network_scan/presentation/pages/network_scan_page.dart` (921) öne çıktı.
- **Test paketi kırık.** Mevcut durumda `flutter test` 10 failure ile dönüyor; kırılma kümeleri `profile_hub_page_test`, `ar_hud_overlay_test` ve `onnx_device_classifier_service_test` etrafında toplanıyor.
- **Dokümantasyon/artefact drift'i var.** Repo kökünde `analysis_results.txt`, `current_analysis.txt`, `final_analysis_output.txt` gibi önceki analiz artefact'ları duruyor; bunlar güncel durumla çelişebiliyor.
- **Absolute local path dependency release hijyeni bozuk.** `pubspec.yaml` içinde absolute `path` dependency var (`pubspec.yaml:55-56`). Repo taramasında bu pakete doğrudan import görünmedi; dolayısıyla release/CI için kaldırılmalı ya da repo içine alınmalı.
- **Stale Firebase / Google Services izi var.** Gradle'da `com.google.gms.google-services` plugin'i aktif ve `google-services.json` repoda duruyor; fakat kod tarafında aktif Firebase kullanımı görünmüyor (`android/app/build.gradle.kts:1-8`, `android/app/google-services.json:1-29`).
- **Placeholder package/bundle identity bırakılmış.** Android, iOS, macOS ve Linux tarafında `com.example.torcav` izi sürüyor (`android/app/build.gradle.kts:12-29`, `android/app/src/main/kotlin/com/example/torcav/MainActivity.kt:1-6`, `android/app/google-services.json:10-18`, ayrıca `ios/Runner.xcodeproj/project.pbxproj`, `macos/Runner/Configs/AppInfo.xcconfig`, `linux/CMakeLists.txt`).
- **Gerçek privacy policy yüzeyi yok.** Checkbox metni var ama policy ekranı, in-app sayfa ya da public URL yok (`lib/features/app_shell/presentation/pages/onboarding_page.dart:372-388`).
- **Bazı ayarlar kozmetik kalmış durumda.** `strictSafetyMode` entity/UI seviyesinde tanımlı (`lib/features/settings/domain/entities/app_settings.dart:14-17`, `lib/features/settings/presentation/pages/settings_page.dart:386-407`), fakat Wi-Fi tarama request'i bu flag'i kullanmadan doğrudan `isDeepScanEnabled`/`includeHiddenSsids` üzerinden kuruluyor (`lib/features/wifi_scan/presentation/pages/wifi_scan_page.dart:35-40`, `lib/features/wifi_scan/presentation/pages/wifi_scan_page.dart:99-105`).
- **Crash reporting yerine debug print var.** Global error hook mevcut ama prod-grade crash analytics entegrasyonu görünmüyor (`lib/main.dart:20-30`).

## Permission & Data Matrix

| İzin | Kodda kullanım | Kullanıcı faydası | Play riski | Aksiyon |
|---|---|---|---|---|
| `ACCESS_FINE_LOCATION` | Android Wi-Fi scan öncesi runtime isteniyor (`lib/features/wifi_scan/data/datasources/android_wifi_data_source.dart:34-37`) | Wi-Fi tarama Android'de bununla açılıyor | Orta: core feature ile uyumlu ama prominent disclosure + Data safety eşleşmesi şart | **Tut**, ama izin isteminden hemen önce Wi-Fi scanning disclosure ekle |
| `ACCESS_COARSE_LOCATION` | Repo içinde ayrı anlamlı kullanım görünmedi; manifestte declare (`android/app/src/main/AndroidManifest.xml:2-3`) | Düşük, `FINE` zaten var | Düşük-Orta: gereksiz scope sorusu çıkarabilir | **Gözden geçir**, muhtemelen kaldır veya nedenini netleştir |
| `CAMERA` | Heatmap yeni oturumunda runtime isteniyor (`lib/features/heatmap/presentation/widgets/heatmap/new_session_dialog.dart:79-87`) | AR/heatmap survey | Orta: core feature ile savunulabilir, fakat izin öncesi açıklama yetersiz | **Tut**, ama feature-spesifik disclosure + store listing anlatısı ekle |
| `ACTIVITY_RECOGNITION` | Heatmap yeni oturumunda runtime isteniyor (`lib/features/heatmap/presentation/widgets/heatmap/new_session_dialog.dart:82-87`) | Indoor yürüyüş/measurement akışı | Orta: core feature ile uyumlu olabilir | **Tut**, ama core feature + prominent disclosure + Data safety eşleşmesi gerekli |
| `BODY_SENSORS` | Heatmap akışında `Permission.sensors` isteniyor (`lib/features/heatmap/presentation/widgets/heatmap/new_session_dialog.dart:82-87`); manifestte declare (`android/app/src/main/AndroidManifest.xml:8-10`) | Mevcut ürün anlatısında net değil; fitness/health feature yok | **Yüksek:** health scrutiny, justification burden ve yanlış permission scope riski | **Muhtemelen kaldır**; gerçekten gerekiyorsa health-policy uyum seti hazırlanmalı |
| `HIGH_SAMPLING_RATE_SENSORS` | Manifestte declare, kodda ayrı usage gerekçesi görünmedi (`android/app/src/main/AndroidManifest.xml:8-10`) | Belirsiz | Orta: gereksiz hassas permission izlenimi | **Muhtemelen kaldır** veya teknik gerekçeyi netleştir |
| `READ_EXTERNAL_STORAGE` | Manifestte declare, repo içinde anlamlı kullanım görünmedi (`android/app/src/main/AndroidManifest.xml:11-12`) | File picker/share akışları için broad storage gerekmeyebilir | Orta-Yüksek: unnecessary sensitive access form riski | **Muhtemelen kaldır** |
| `WRITE_EXTERNAL_STORAGE` | Manifestte declare, repo içinde anlamlı kullanım görünmedi (`android/app/src/main/AndroidManifest.xml:11-12`) | Android modern storage modelde büyük ölçüde gereksiz | Orta-Yüksek: permission mismatch sorusu çıkarır | **Muhtemelen kaldır** |
| `RECORD_AUDIO` | Manifestte declare, repo içinde kullanım görünmedi (`android/app/src/main/AndroidManifest.xml:13`) | Belirsiz | Yüksek: hassas izin, açıklanamayan veri erişimi izlenimi | **Muhtemelen kaldır** |
| `FOREGROUND_SERVICE` | Manifestte declare, aktif foreground service implementasyonu görünmedi (`android/app/src/main/AndroidManifest.xml:14`) | Belirsiz | Orta-Yüksek: FGS declaration burden doğurur | **Muhtemelen kaldır** ya da gerçek FGS tasarımını ekle |
| `FOREGROUND_SERVICE_MEDIA_PROJECTION` | Manifestte declare, media projection kullanımı görünmedi (`android/app/src/main/AndroidManifest.xml:15`) | Yok | **Yüksek:** ekran kaydı / projection çağrışımı, yanlış beyan riski | **Muhtemelen kaldır** |

## Policy Review

| Resmi Kaynak | Neden Önemli | Repo Riski | Repo Kanıtı |
|---|---|---|---|
| [Google Play Device and Network Abuse](https://support.google.com/googleplay/android-developer/answer/16559646?hl=en) | Google Play yetkisiz erişim, hacking facilitation ve ağ/service abuse davranışlarını yasaklar | **Aktif LAN taraması** store listing ve app copy'de "pasif" gibi konumlanırsa red riski doğar | `lib/features/network_scan/presentation/widgets/lan_consent_dialog.dart:52-55`, `lib/features/network_scan/data/datasources/port_scan_data_source.dart:121-180`, `lib/features/network_scan/data/datasources/upnp_data_source.dart:18-39` |
| [Google Play User Data](https://support.google.com/googleplay/android-developer/answer/10144311?hl=en) | Security-related app'lerde privacy policy ve prominent disclosure beklentisini sertleştirir | **Eksik privacy policy / disclosure yüzeyi** | `lib/features/app_shell/presentation/pages/onboarding_page.dart:372-388`, `lib/features/settings/presentation/pages/settings_page.dart:640-648` |
| [Permissions and APIs that Access Sensitive Information](https://support.google.com/googleplay/android-developer/answer/16558241?hl=en) | Hassas izinlerin yalnızca current core feature için ve incrementally istenmesini bekler | **Hassas izin fazlalığı ve permission-to-feature mismatch** | `android/app/src/main/AndroidManifest.xml:2-15`, `lib/features/heatmap/presentation/widgets/heatmap/new_session_dialog.dart:79-87` |
| [Health apps declaration](https://support.google.com/googleplay/android-developer/answer/14738291?hl=en) | Tüm Play uygulamalarında health declaration formu istenir; health feature yoksa bunu da beyan etmek gerekir | **BODY_SENSORS nedeniyle review soruları daha erken gelebilir** | `android/app/src/main/AndroidManifest.xml:8-10`, `lib/features/heatmap/presentation/widgets/heatmap/new_session_dialog.dart:82-87` |
| [Android Health Permissions Guidance](https://support.google.com/googleplay/android-developer/answer/12991134) | Body sensor/health-adjacent permission'lar yalnızca net user benefit ve approved use case ile savunulabilir | **BODY_SENSORS ve sensor seti mevcut ürün amacıyla orantısız görünüyor** | `android/app/src/main/AndroidManifest.xml:8-10`, `lib/features/heatmap/presentation/widgets/heatmap/new_session_dialog.dart:82-87` |

## Roadmap

| Priority | Area | Item | Impact | Effort | Risk if skipped | Evidence |
|---|---|---|---|---|---|---|
| P0 | Permissions | Unused sensitive permissions temizliği (`BODY_SENSORS`, `RECORD_AUDIO`, `READ/WRITE_EXTERNAL_STORAGE`, `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_MEDIA_PROJECTION`, gerekirse `HIGH_SAMPLING_RATE_SENSORS`) | Çok yüksek | Düşük-Orta | Play review'da permission mismatch / scrutiny | `android/app/src/main/AndroidManifest.xml:8-15` |
| P0 | Release Hygiene | `com.example` kimliklerini ve release signing stratejisini düzelt | Çok yüksek | Orta | Store submission, signing ve brand güveni bloklanır | `android/app/build.gradle.kts:12-29`, `android/app/build.gradle.kts:49-54`, `android/app/src/main/kotlin/com/example/torcav/MainActivity.kt:1-6`, `android/app/google-services.json:10-18` |
| P0 | Dependency Hygiene | Absolute `path` dependency kaldır veya repo içine al | Yüksek | Düşük | CI/reproducible build kırılgan kalır | `pubspec.yaml:55-56` |
| P0 | Privacy Surface | Gerçek privacy policy URL + in-app policy ekranı ekle | Çok yüksek | Orta | User Data policy red riski devam eder | `lib/features/app_shell/presentation/pages/onboarding_page.dart:372-388` |
| P0 | Consent UX | Hassas izin istemlerinden hemen önce prominent disclosure ekle | Çok yüksek | Orta | Permission review ve Data safety çelişkisi | `lib/features/wifi_scan/data/datasources/android_wifi_data_source.dart:34-37`, `lib/features/heatmap/presentation/widgets/heatmap/new_session_dialog.dart:79-87` |
| P0 | Product Messaging | "Passive-only" iddiasını gerçek ağ davranışıyla hizala | Çok yüksek | Orta | Device and Network Abuse / deceptive positioning riski | `lib/features/app_shell/presentation/pages/onboarding_page.dart:362-375`, `lib/features/wifi_scan/presentation/pages/wifi_scan_page.dart:159-163`, `lib/features/network_scan/presentation/widgets/lan_consent_dialog.dart:52-55` |
| P0 | Safety Controls | `strictSafetyMode` runtime enforcement ekle | Yüksek | Orta | Safety mode kullanıcıya false sense of control verir | `lib/features/settings/domain/entities/app_settings.dart:14-17`, `lib/features/settings/presentation/pages/settings_page.dart:386-407`, `lib/features/wifi_scan/presentation/pages/wifi_scan_page.dart:35-40` |
| P0 | Data Governance | `Wipe All Local Data` ve retention ayarlarını tüm veri yüzeylerini kapsayacak şekilde tamamla | Çok yüksek | Orta | KVKK/GDPR deletion beklentisi ve kullanıcı güveni zedelenir | `lib/features/settings/presentation/pages/settings_page.dart:577-586`, `lib/features/settings/presentation/pages/settings_page.dart:781-788`, `lib/features/heatmap/data/datasources/heatmap_local_data_source.dart:22-52`, `lib/features/network_scan/data/datasources/lan_scan_history_local_data_source.dart:30-106`, `lib/features/security/data/datasources/security_local_data_source.dart:10-26` |
| P1 | Test Quality | 10 failing test'i onar | Yüksek | Orta | Release regression'ları görünmez kalır | failing suites: `test/features/app_shell/presentation/pages/profile_hub_page_test.dart`, `test/features/heatmap/presentation/widgets/ar_hud_overlay_test.dart`, `test/features/ai/data/services/onnx_device_classifier_service_test.dart` |
| P1 | Privacy by Default | Export anonymization default ON yap | Yüksek | Düşük | Üçüncü taraf BSSID/SSID verisi kolayca sızar | `lib/features/reports/presentation/pages/reports_page.dart:42-47`, `lib/features/reports/presentation/pages/reports_page.dart:239-241` |
| P1 | Repo Hygiene | Stale analysis/doc artefact dosyalarını temizle veya `docs/` altına taşı | Orta | Düşük | Yanıltıcı kalite sinyali üretir | repo root: `analysis_results.txt`, `current_analysis.txt`, `final_analysis_output.txt` |
| P1 | Play Console Prep | Data safety formu için veri envanteri çıkar | Yüksek | Orta | Console submission yavaşlar/çelişir | `android/app/src/main/AndroidManifest.xml:2-15`, `lib/core/storage/app_database.dart:31-182`, `lib/features/heatmap/data/datasources/heatmap_local_data_source.dart:22-52` |
| P1 | Product Language | Ghost/offensive semantik temizliği yap (`handshake capture`, benzeri) | Orta | Düşük | Security tool konumlandırması gereksiz agresif görünür | `lib/core/services/notification_service.dart:171-178` |
| P2 | Dashboard | Canlı refresh + explainable score | Orta | Orta | Değer algısı ve güven zayıf kalır | `lib/features/dashboard/presentation/pages/dashboard_page.dart` |
| P2 | Wi-Fi | Throttling, 6 GHz/DFS ve scan behavior netliği | Orta | Orta | Yanlış beklenti ve yanlış kanal önerileri sürer | `lib/features/wifi_scan/data/datasources/android_wifi_data_source.dart:43-67`, `lib/features/wifi_scan/presentation/pages/wifi_scan_page.dart:146-172` |
| P2 | LAN | IPv6, rate limiting, partial-result UX | Orta-Yüksek | Orta-Yüksek | Kurumsal/yoğun ağlarda riskli ve kaba davranış sürer | `lib/features/network_scan/data/datasources/port_scan_data_source.dart:75-109`, `lib/features/network_scan/domain/entities/network_scan_policy.dart:21-34` |
| P2 | Security | CVE feed otomasyonu, evidence-first dil, false-positive tuning | Orta | Orta | Security score güvenilirliği sorgulanır | `lib/features/security/data/datasources/dns_test_data_source.dart:37-125`, `lib/features/security/domain/services/captive_portal_detector.dart:21-58` |
| P2 | Heatmap/Monitoring | Permission UX, duplication cleanup, battery/backoff | Orta-Yüksek | Yüksek | Pil tüketimi ve permission friction sürer | `lib/features/monitoring/data/repositories/monitoring_repository_impl.dart:22-38`, `lib/features/heatmap/presentation/widgets/heatmap/new_session_dialog.dart:79-87` |
| P2 | Reports | LAN/security/speed/heatmap export kapsamını genişlet | Orta | Orta | Raporlama feature'i kısmi kalır | `lib/features/reports/presentation/pages/reports_page.dart:195-263` |
| P3 | Automation | Scheduled jobs / scheduled tests / background-safe jobs | Orta | Yüksek | Ürün tekrar kullanım oranı sınırlı kalır | `lib/features/wifi_scan/presentation/pages/wifi_scan_page.dart:76-89`, `lib/features/monitoring/data/repositories/monitoring_repository_impl.dart:22-38` |
| P3 | Surface Area | Widget ve deep link desteği | Orta | Orta | Hızlı erişim ve retention zayıf kalır | `lib/core/router` boş; `lib/features/app_shell/presentation/pages/app_shell_page.dart` |
| P3 | Trust Layer | Signed veya encrypted reports | Orta | Orta-Yüksek | Hassas export'lar çıplak paylaşılmaya devam eder | `lib/features/reports/presentation/pages/reports_page.dart:195-263` |
| P3 | Policy Engine | Per-network policy / environment profile | Orta | Orta | Ev/ofis/kafe ayrımı yapılamaz | `lib/features/settings/domain/entities/app_settings.dart:10-42` |
| P3 | Analytics | Gelişmiş topology/insight katmanı | Düşük-Orta | Yüksek | Teknik kullanıcı değeri sınırlı kalır | `lib/features/monitoring/presentation/pages/topology_page.dart` |

## Kamuya Açık Arayüz / Sözleşme Etkileri

Bu çalışma aşamasında **kod API değişikliği önerilmiyor**. Belge, mevcut repo durumunu ve sıralı iyileştirme planını tarif eder.

İleride zorunlu contract/developer-facing davranış değişikliği gerektirecek başlıklar:

- `strictSafetyMode` yalnızca settings flag'i olmaktan çıkıp gerçek scan policy enforcement katmanına bağlanmalı.
- Merkezi privacy/disclosure yüzeyi gelmeli; onboarding checkbox'ı gerçek policy ekranı/URL ile desteklenmeli.
- Retention cleanup servisi eklenmeli; slider değişiklikleri otomatik cleanup job veya startup cleanup ile işletilmeli.
- "Tam veri silme" akışı Wi-Fi, LAN, security, heatmap, cached sessions ve export artefact'larını kapsayacak şekilde tamamlanmalı.
- Permission-to-feature eşleşmesi netleştirilmeli; store listing, in-app disclosure ve runtime permission sırası tek bir sözleşme gibi çalışmalı.

## Doğrulama ve Ölçüm Özeti

- **Play Store karar seviyeleri:** `Şu an yayınlanamaz` / `Koşullu yayınlanabilir` / `Yayınlanabilir`
- **Lokal analiz durumu:** `flutter analyze` temiz.
- **Test durumu:** `flutter test` 10 hata ile kırık.
- **Build durumu:** `flutter build apk --debug --no-pub` ve `flutter build appbundle --release --no-pub` başarılı.
- **Play Store kararı:** **Şu an yayınlanamaz.** `P0` tamamlanmadan **koşullu yayınlanabilir** sayılmamalı.

## Varsayımlar

- Belge dili Türkçe tutuldu.
- Çıktı repo kökünde tek dosya olarak hazırlandı.
- Öncelik release/compliance-first sıralandı; feature derinliği ve büyüme işleri P0/P1 sonrasına bırakıldı.
