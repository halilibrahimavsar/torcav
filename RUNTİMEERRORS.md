# Torcav Runtime Error Analysis Report

Bu dosya, projedeki olası çalışma zamanı (runtime) hatalarını, zayıf noktaları ve kilitlenme (crash) risklerini feature bazlı olarak takip etmek için oluşturulmuştur.

> **Son güncelleme (2026-05-17):** 2026-05-15 turundan sonra kodda **17 bulgu daha sessizce düzeltilmiş** (5'i bu dokümana stub olarak yansıtılmış, 12'si sadece kodda kalmış). CEO doğrulama turu tüm iddiaları teyit etti ve dokümanı kod gerçeğine **tam senkron** hale getirdi: RESOLVED işaretleri Türkçeleştirildi + satır referansı eklendi, `EVIDENCE`'a R5–R18 yeni RESOLVED kayıtları girdi, silinen jsonDecode notları geri yüklendi, Genel Tespitler stale referanslardan temizlendi. **Hâlâ açık:** reverseDNS timeout, Linux stdout cast, PingStabilizer event cast, CyberGrid static ValueNotifier, `while(true)` jeneratör, SecureStorage init try-catch, ONNX `raw.cast<double>()`, Heatmap per-point blur. Teknik kanıtlar: `RUNTİME_EVIDENCE.md`.

> **Önceki tur (2026-05-15):** 3 bağımsız doğrulama turu yapıldı; **3 bulgu geçersiz/abartılı çıktı** (Android native cast'ler nullable → güvenli, Captive Portal'da timeout mevcut, `shouldRepaint => true` painter'ları AnimatedBuilder sürüyor → severity LOW). **2 maddeye gözden kaçan guard notu eklendi** (ErrorWidget fallback delegate'leri, jsonDecode null-coalescing).

---

## 🏗️ Core & Bootstrap (Başlangıç ve Altyapı)
*   **[RESOLVED] DI Initialization Crash:** `AppSettingsStore` artık `@postConstruct` async `init()` kullanıyor (`app_settings_store.dart:19-23`); constructor sadece default değerle başlatıyor (Satır 17), Hive okuma async init'e taşındı. Injectable framework `init()`'i construction'dan sonra çağırıyor → "constructor içinde senkron storage" deseni tamamen kalktı. Bkz. `EVIDENCE` R5.
*   **[RESOLVED] Hive Type Mismatch:** `HiveStorageService.get<T>` artık try-catch + `is! T` runtime kontrolü + `defaultValue` fallback ile sarılı (`hive_storage_service.dart:43-56`). Tip uyuşmazlığında `AppLogger.w` ile loglanıp güvenli dönüş yapılıyor. Bkz. `EVIDENCE` R9.
*   **[MEDIUM] DI Registration Failure:** `configureDependencies()` içinde bir servis kaydı başarısız olursa veya `getIt<T>` ile henüz kayıtlı olmayan bir servise erişilirse `StateError` fırlatılır.
*   **[LOW] Hive Box Race Condition:** `HiveStorageService.box` getter'ı (Satır 35) `init` tamamlanmadan çağrılırsa `HiveError` (Box not open) fırlatır.
*   **[LOW] Secure Storage Initialization:** `main.dart` (Satır 50) içinde `SecureStorageService` doğrudan (DI dışı) ilklendiriliyor. Android keychain sorunlarında bu aşama uygulamayı kilitleyebilir.

## 🛡️ Security (Güvenlik)
*   **[RESOLVED] Stream.last Exception:** `SecurityRepositoryImpl` 4 noktada `.lastOrNull`'a geçti — yeni satırlar `283`, `312`, `465`, `485` (`stream_extensions.dart` import'u Satır 3). Boş stream artık `null` döner, `Either.fold` ile güvenli işlenir. Bkz. `EVIDENCE` R6.
*   **[RESOLVED] NetworkInfo Manual Instantiation:** 8 noktanın hepsi DI'a geçti. Alan injection: `security_repository_impl.dart:47`, `arp_spoofing_detector.dart:10`, `security_bloc.dart:33`, `arp_data_source.dart:82`, `diagnostics_repository_impl.dart:28`. `getIt<NetworkInfo>()`: `router_hardening_wizard_page.dart:39`, `spectrum_optimization_page.dart:~134`. Widget parametresi: `router_admin_guide_card.dart:39`. Bkz. `EVIDENCE` R10.
*   **[RESOLVED] Captive Portal Detection:** `_captivePortalDetector.check()` (Satır 398). **Geçersiz bulgu:** `CaptivePortalDetector.check()` içinde `HttpClient.connectionTimeout = 5s` + request'te `.timeout(5s)` + dış try-catch (hata → `CaptivePortalStatus.unknown`) mevcut. Sonsuz `await` mümkün değil. Bkz. `EVIDENCE` R4.
*   **[RESOLVED] DNS Benchmark Empty List:** `_DnsBenchmarkSection.build` (`dns_security_card.dart`) içine `if (sortedBenchmarks.isEmpty) return SizedBox.shrink();` guard eklendi (`.last` çağrısından önce). Caller'ın `isNotEmpty` kontrolüne ek olarak widget kendini de koruyor. Bkz. `EVIDENCE` R16.
*   **[LOW] IP String Parsing:** `ip.substring(0, ip.lastIndexOf('.'))` (Satır 277, 305, 456, 477). **Azaltıldı:** çağrılar artık `ip.contains('.')` koruması altında, dolayısıyla `lastIndexOf >= 0` garanti; RangeError riski büyük ölçüde mitige. Yine de boş/atipik girdilerde takip edilmeli.
*   **[LOW] Redundant Nested firstWhere:** `security_repository_impl.dart:409-414` iç içe `firstWhere((_) => false, orElse: ...)` kullanıyor. Crash etmez (iç orElse her zaman default profil döner) ama kafa karıştırıcı, kırılgan kod kokusu.

## 🌐 Network & WiFi Scan (Ağ Tarama)
*   **[MEDIUM] Command Dependency (Linux):** `LinuxWifiDataSource`, `nmcli`/`iwlist`/`iw` komutlarına bağımlı. Hepsi eksikse `ScanFailure` fırlatılır; UI'da düzgün yakalanmazsa "Infinite Loading" / kilitlenme.
*   **[MEDIUM] Process Output Casting (Linux):** `result.stdout as String` (Satır 94, 177, 248). Süreç beklenmedik bir çıktı (binary/null) üretirse `TypeError`. Normal çalışmada `Process.run` systemEncoding ile String döner ama encoding hatalarında risk var.
*   **[RESOLVED] Native Type Casting (Android):** `AndroidWifiDataSource` (Satır 109, 123, 126, 137) method channel verilerini cast ediyor. **Geçersiz bulgu:** tüm cast'ler **nullable** (`as String?` / `as int?`); native tarafta tip değişirse cast başarısız olur ama `TypeError` fırlatmaz, `null` döner ve alanlar opsiyonel olarak işlenir. Crash riski yok. Bkz. `EVIDENCE` R3.
*   **[MEDIUM] mDNS Empty List Access:** `network_scan_repository_impl.dart:95` `mdnsMap[host.ip]!.first` — `containsKey` kontrolünden sonra `!` güvenli, ancak değer listesi boşsa `.first` `StateError` fırlatır.
*   **[MEDIUM] Invalid IP in Reverse DNS:** `InternetAddress(ip)` (`network_scan_repository_impl.dart:160`) geçersiz IP ile `ArgumentError` fırlatır. **Mevcut try-catch var** (Satır 159-165). Ek risk: `address.reverse()` (Satır 161) timeout'suz; yanıtsız DNS sunucusunda askıda kalabilir.
*   **[MEDIUM] Android Throttling:** Android 9+ cihazlarda 2 dakikada 4 tarama sınırı. `startScan()` false döndüğünde UI uyarı vermezse kullanıcı verinin güncelliğinden şüphe eder. (Hata değil, platform kısıtlaması.)
*   **[LOW] nmcli Parsing Logic:** `_splitNmcli` (Linux Satır 153) SSID içinde kaçış karakteri `:` bulunmasında karmaşık mantık yürütüyor. `fields` erişimleri (Satır 127-133) `if (fields.length < 6) return null` + try-catch ile korunuyor — crash riski düşük, ama atipik locale çıktısı yanlış parsing'e yol açabilir.

## 🤖 AI Features (Yapay Zeka)
*   **[RESOLVED] Model Loading Race Condition:** `OnnxDeviceClassifierService._ensureSession` (`onnx_device_classifier_service.dart:263-303`) `Completer<void>? _initCompleter` ile serileştirildi; eşzamanlı çağrılar aynı future'ı `await` ediyor, ikinci kez init çalışmıyor. `finally` bloğunda completer temizleniyor. Bkz. `EVIDENCE` R7.
*   **[RESOLVED] Session Run Memory Leak:** `_classifyFeatures` artık `finally` bloğunda `for (final tensor in outputs) tensor?.release()` ile **tüm** tensor'ları release ediyor (Satır ~107-109); dış `finally`'de `inputOrt.release()` + `runOptions.release()`. Exception path'i bile sızdırmıyor. Bkz. `EVIDENCE` R14.
*   **[MEDIUM] Unsafe Logit Casting:** `raw.cast<double>()` (Satır 94) — model çıktısında bir int dönerse `TypeError`. ONNX plugin'i bazen float'ları int olarak döndürebilir. Hâlâ açık.
*   **[RESOLVED] Empty Output Access:** Artık `outputs.isEmpty` early-return (Satır ~86) ve `decodeOutput` içinde `if (logits.isEmpty) return DeviceClassification('Unknown', 0.0);` (`device_classifier.dart:179`) guard'ları var. `raw.first` yolu da `outputTensor == null` kontrolüyle korunuyor. Bkz. `EVIDENCE` R15.
*   **[RESOLVED] Softmax Division by Zero:** `decodeOutput` (`device_classifier.dart:191`) `probs[i] /= sumExp`. **Geçersiz bulgu:** `maxLogit` çıkarımı sayesinde en az bir terim `exp(0)=1.0`, dolayısıyla `sumExp >= 1.0` her zaman. Bölme sıfıra imkânsız (logits boş değilse — boşsa zaten Satır 180 önce crash eder).

## 📊 Monitoring & Performance (İzleme ve Performans)
*   **[MEDIUM] Infinite Generator Leak:** `MonitoringRepositoryImpl.monitorNetworks` (Satır 23) `while(true)` döngüsü. Stream'i dinleyen BLoC dispose edilmezse arka plan taraması sonsuza dek sürer (batarya/kaynak sızıntısı). `MonitoringBloc.close()` doğru iptal ediyor ancak başka bir tüketici unutursa risk var.
*   **[RESOLVED] Topology Process Output Casting:** `topology_repository_impl.dart:89-90, 174-180` artık `if (output is String)` runtime kontrolü yapıyor; `as String` zorlaması kalktı. Beklenmedik tipte sessizce skip. Bkz. `EVIDENCE` R17.
*   **[LOW] Backoff Delay Precision:** `monitoring_repository_impl.dart:33` `Future.delayed` OS tarafından optimize edilebilir. Bit-shift `1 << consecutiveErrors` `.clamp(0,6)` ile sınırlı — overflow yok.
*   **[RESOLVED] Topology Regex Parse:** `topology_repository_impl.dart:95` `double.parse` → `double.tryParse(timeStr)?.round()` ile değiştirildi; geçersiz girdi `null` döner, crash yok. Bkz. `EVIDENCE` R17.

## 📱 UI & App Shell (Arayüz ve Navigasyon)
*   **[MEDIUM] Localization Extension Crash:** `_NeonErrorWidget` (`main.dart:82, 93`) `context.l10n` kullanıyor. `ErrorWidget.builder` (Satır 42) DI/Bootstrap aşamasında bir render hatasında çağrılırsa `AppLocalizations` bulunamayabilir; `context.l10n` extension'ı `AppLocalizations.of(context)!` ile force-unwrap yaptığı için "Null check operator" hatasıyla crash loop riski. **Azaltıldı (çok katmanlı):** (1) `main.dart:210-216` `FallbackMaterialLocalizationsDelegate` / `FallbackCupertinoLocalizationsDelegate` mevcut → İngilizce fallback. (2) Operasyonel olarak `ErrorWidget.builder` yalnızca `WidgetsFlutterBinding.ensureInitialized()` + `runZonedGuarded` içinde MaterialApp ağaçtayken tetikleniyor → l10n hazır oluyor. **Kalan teorik risk:** MaterialApp hiç kurulmadan ham bootstrap exception → `!` yine fırlatır; defansif olarak hata ekranı ham string fallback kullanmalı.
*   **[MEDIUM] Shader Performance Crash:** `CyberGridBackground` shader bazlı arka planları (Aurora, Quantum Mesh, Aegis Shield, Signal Topography, Holo Sphere, Neural Pulse) düşük donanımlı Android'de GPU belleğini tüketerek "Out of Memory" / ANR'ye sebep olabilir.
*   **[LOW] shouldRepaint => true:** Tüm arka plan painter'ları `shouldRepaint` içinde koşulsuz `true` döndürüyor: `classic_grid_background.dart:337`, `signal_topography_background.dart:265`, `aegis_shield_background.dart:353`, `holo_sphere_background.dart:450`, `aurora_mesh_background.dart:501`, `quantum_mesh_background.dart:246`, `neural_pulse_background.dart:436`. **Severity düşürüldü:** 7 painter'ın hepsi `AnimatedBuilder(animation: Listenable.merge([_controller, widget.scrollVelocity]))` içinde. Repaint zaten yalnızca animasyon ilerlediğinde tetikleniyor ve her frame animasyon değeri gerçekten değişiyor; bu bağlamda `shouldRepaint => true` **doğru ve beklenen** davranış — "veri değişmese bile çizim" durumu yok. "OOM/ANR" iddiası geçersiz. Kalan tek nokta minik kod kokusu: `progress`/`velocity` değerleri `oldDelegate` ile karşılaştırılarak yine de daha açık yazılabilir.
*   **[LOW] ValueNotifier Leak:** `CyberGridBackground` içindeki `static scrollVelocity` ValueNotifier (Satır 30) hiçbir zaman dispose edilmez; statik olduğu için uygulama ömrü boyunca bellekte kalır.

## 🗄️ Storage & Data Sources (Depolama ve Veri Kaynakları)
*   **[MEDIUM] Unguarded jsonDecode:** Birkaç datasource `jsonDecode(...)` çağrısını try-catch'siz yapıyor; **bozuk/geçersiz** JSON string'i `FormatException` ile yükleme işlemini çökertir:
    *   `lan_scan_history_local_data_source.dart:84`
    *   `wifi_scan_history_local_data_source.dart:197` (`_decodeChannelStats`), `:214` (`_decodeBandStats`)
    *   *(Not 1: Çağrılar `?? '[]'` null-coalescing guard'ı altında — dolayısıyla **null** girdi güvenli; risk yalnızca veritabanında **bozuk/atipik** JSON string'i olması durumunda geçerli. Kapsam dar ama madde geçerli.)*
    *   *(Not 2: `ping_stabilizer_settings_store.dart:44` ve `app_settings_store.dart:36` zaten try-catch içinde — güvenli.)*
*   **[RESOLVED] Unsafe Cast on Hive Read:** `device_label_override_store.dart:34` artık `if (value is String)` ile kontrol ediyor; `favorites_store.dart:48` `.whereType<String>().toSet()` kullanıyor. `as String` zorlamaları kalktı. Bkz. `EVIDENCE` R12.
*   **[RESOLVED] ThemeCubit Unguarded Load:** `theme_cubit.dart:15-28` `_load()` tamamen try-catch içine alındı; hata durumunda sessiz `ThemeMode.dark` fallback. Bkz. `EVIDENCE` R13.
*   **[RESOLVED] StreamController Dispose Eksikliği:** 3 store'a da `@disposeMethod` eklendi: `app_settings_store.dart:35-38`, `favorites_store.dart:41-44`, `scan_session_store.dart:54-57`. Bkz. `EVIDENCE` R18.

## 🛰️ VPN & Ping Stabilizer
*   **[MEDIUM] EventChannel TypeError:** `PingStabilizerChannel._ensureListening` (Satır 124) `event as Map?` cast yapıyor. Native taraf farklı bir tip dönerse runtime crash. (İç alanlar `as num?` ile daha güvenli alınıyor.)
*   **[MEDIUM] VPN State Desync:** Native `VpnService` Android tarafından durdurulursa Dart BLoC/Cubit haberdar olmayabilir (event channel gelmezse). UI "Bağlı" görünüp tünel kapalı olabilir. *(Not: `tunnelStopped` stream'i bu senaryoyu kısmen ele alıyor; `_stoppedSub` `close()` Satır 366'da iptal ediliyor.)*

## 🗺️ Heatmap & AR
*   **[RESOLVED] Matrix Inversion Error:** `heatmap_canvas.dart:140-141` `if (matrix.determinant() == 0) return;` guard eklendi; singular matrix güvenli erken-return. Bkz. `EVIDENCE` R8.
*   **[MEDIUM] Painting Performance (Kısmen Mitige):** `_StaticHeatmapPainter._drawHeatmap` her nokta için `MaskFilter.blur` + `Gradient.radial` ile çoklu daire çiziyor (iki ardışık döngü, Satır ~374-413). **Mitige:** Static layer `RepaintBoundary` ile sarıldı (`heatmap_canvas.dart:155-169`), dynamic layer için ayrı `RepaintBoundary` (176-185) — re-paint maliyeti büyük ölçüde elimine. **Kalan:** İlk-frame ve veri değişikliğinde per-point blur/gradient hâlâ pahalı; 500+ nokta için image caching (`PictureRecorder`/`toImage`) veya downsampling önerilir. Severity HIGH → MEDIUM.
*   **[RESOLVED] GlobalToLocal Cast Crash:** `heatmap_canvas.dart:130-131` `final renderObject = context.findRenderObject(); if (renderObject is! RenderBox) return;` ile güvenli type-check eklendi. Bkz. `EVIDENCE` R11.
*   **[LOW] RenderObject Tip Cast:** `heatmap_page.dart:516` `findRenderObject() as RenderRepaintBoundary?` — null kontrolü var (`if (boundary == null) return`), ancak farklı bir RenderObject tipi dönerse `as` yine de fırlatır. Pratikte `_boundaryKey` bir `RepaintBoundary`'de — risk düşük.

---

## 🛠️ Genel Tespitler (Mimari & Pattern)
*   **Null Safety:** `!` (null check operator) kullanımı azaldı — `findRenderObject() as RenderBox` ve `Stream.last` gibi sıcak noktalar `is!` guard'larına ve `lastOrNull`'a geçti. Kalan riskli yer: `mdnsMap[host.ip]!.first` (containsKey guard'ı altında, düşük risk).
*   **Unsafe Casts:** **Önemli iyileşme:** `HiveStorageService.get<T>` artık `is! T` runtime check + try-catch ile güvenli. Hive store cast'leri `is String` / `whereType<String>()`'e geçti. Kalan riskler: `LinuxWifiDataSource.result.stdout as String` (3 nokta) ve `PingStabilizerChannel event as Map?` (event non-null non-Map ise). Method/event channel sınırlarındaki **nullable** cast'ler (`as String?` / `as int?`) doğrulamada güvenli çıktı.
*   **Empty Collection Access:** Stream `.last` örnekleri `.lastOrNull`'a, `decodeOutput logits[0]` ve `DnsCard sortedBenchmarks.last` `isEmpty` guard'larına geçti. Kalan: nadir `firstOrNull` aday noktaları.
*   **Async Race Conditions:** ONNX session yükleme `Completer` ile serileştirildi; `AppSettingsStore` `@postConstruct` async init'e geçti. Bu pattern kategorisi büyük ölçüde temizlendi.
*   **Background Tasks & Leaks:** `while(true)` `monitoring_repository_impl.dart:23` hâlâ aktif (subscription cancel'a bağlı), `CyberGridBackground` static `ValueNotifier` hâlâ açık. **İyileşme:** 3 store'a `@disposeMethod` eklendi → `StreamController` leak'leri kapandı. `shouldRepaint => true` painter'lar AnimatedBuilder ile sürüldükleri için gerçek bir sorun değil (UI bölümü, LOW).
*   **Error Handling:** `Either<Failure, T>` kullanımı; try-catch'siz `jsonDecode` (kısıtlı, `?? '[]'` ile null-safe); `ErrorWidget.builder` operasyonel olarak güvenli ama defansif olarak ham fallback önerilir.
*   **DI (GetIt):** **Önemli iyileşme:** Önceden manuel `new` edilen `NetworkInfo` 8 noktada DI'a geçti (field injection / `getIt<>()` / widget parametresi). DI kullanım tutarlılığı arttı.
