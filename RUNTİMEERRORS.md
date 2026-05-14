# Torcav Runtime Error Analysis Report

Bu dosya, projedeki olası çalışma zamanı (runtime) hatalarını, zayıf noktaları ve kilitlenme (crash) risklerini feature bazlı olarak takip etmek için oluşturulmuştur.

> **Son güncelleme (2026-05-15):** 3 bağımsız doğrulama turu yapıldı — tüm iddialar kod üzerinde tek tek kontrol edildi. **3 bulgu geçersiz/abartılı çıktı** (Android native cast'ler nullable → güvenli, Captive Portal'da timeout mevcut, `shouldRepaint => true` painter'ları AnimatedBuilder sürüyor → severity LOW). **2 maddeye gözden kaçan guard notu eklendi** (ErrorWidget fallback delegate'leri, jsonDecode null-coalescing). Teknik kanıtlar için bkz. `RUNTİME_EVIDENCE.md`.

---

## 🏗️ Core & Bootstrap (Başlangıç ve Altyapı)
*   **[CRITICAL] DI Initialization Crash:** `AppSettingsStore` (Satır 17) constructor'ı içinde `_loadInitialValue` çağırıyor, bu da `HiveStorageService.get` (Satır 30) → `Hive.box()` kullanıyor. `@lazySingleton` olduğu için `configureDependencies()` aşamasında ilk erişimde Hive box'ı açık değilse `HiveError` ile uygulama `runApp`'e gelmeden çöker. Şu an `main.dart` sırası (`HiveStorageService.init` → `configureDependencies`) bunu önlüyor ancak desen kırılgan; constructor içinde senkron storage okuması tehlikeli.
*   **[MEDIUM] Hive Type Mismatch:** `HiveStorageService.get<T>` (Satır 44) `as T?` cast yapıyor. Kaydedilen veri tipi istenen tiple uyuşmazsa `TypeError` oluşur. Birçok store bu metoda güveniyor.
*   **[MEDIUM] DI Registration Failure:** `configureDependencies()` içinde bir servis kaydı başarısız olursa veya `getIt<T>` ile henüz kayıtlı olmayan bir servise erişilirse `StateError` fırlatılır.
*   **[LOW] Hive Box Race Condition:** `HiveStorageService.box` getter'ı (Satır 35) `init` tamamlanmadan çağrılırsa `HiveError` (Box not open) fırlatır.
*   **[LOW] Secure Storage Initialization:** `main.dart` (Satır 50) içinde `SecureStorageService` doğrudan (DI dışı) ilklendiriliyor. Android keychain sorunlarında bu aşama uygulamayı kilitleyebilir.

## 🛡️ Security (Güvenlik)
*   **[HIGH] Stream.last Exception:** `SecurityRepositoryImpl` içinde `scanStream.last` ve `portScanStream.last` (Satır 281, 309, 462, 481) kullanılıyor. Stream hiç veri yaymadan kapanırsa `StateError: No element` alınır ve "Deep Scan" sırasında tüm güvenlik analizi yarıda kesilir. `last` yerine `lastOrNull` / `fold` kullanılmalı.
*   **[MEDIUM] NetworkInfo Manual Instantiation:** `NetworkInfo` sınıfı DI'da (`di_module.dart:14`) sağlanmasına rağmen birçok yerde manuel `new` ediliyor: `security_repository_impl.dart:46`, `arp_spoofing_detector.dart:10`, `security_bloc.dart:33`, `arp_data_source.dart:82`, `router_hardening_wizard_page.dart:39`, `router_admin_guide_card.dart:39`, `spectrum_optimization_page.dart:131`, `diagnostics_repository_impl.dart:164`. Platform plugin hataları (`MissingPluginException`) veya izin eksiklikleri bu noktalarda yakalanmıyor.
*   **[RESOLVED] Captive Portal Detection:** `_captivePortalDetector.check()` (Satır 398). **Geçersiz bulgu:** `CaptivePortalDetector.check()` içinde `HttpClient.connectionTimeout = 5s` + request'te `.timeout(5s)` + dış try-catch (hata → `CaptivePortalStatus.unknown`) mevcut. Sonsuz `await` mümkün değil. Bkz. `EVIDENCE` R4.
*   **[MEDIUM] DNS Benchmark Empty List:** `_DnsBenchmarkSection.build` (`dns_security_card.dart:363`) içinde `sortedBenchmarks.last` çağrısı var; `benchmarks` boşsa `StateError: No element` fırlatır. Widget içinde `isEmpty` koruması yok.
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
*   **[HIGH] Model Loading Race Condition:** `OnnxDeviceClassifierService._ensureSession` (Satır 254-273) senkronizasyon (lock/mutex/Completer) mekanizmasına sahip değil. `classifyBatch` içinde eşzamanlı çağrılar aynı temp dosyasına (`device_classifier.onnx`) yazmaya çalışabilir; `FileSystemException` veya bozuk model yüklemesi.
*   **[MEDIUM] Session Run Memory Leak:** `_classifyFeatures` (Satır 81-88) `session.run` sonrası yalnızca `outputs.first` release ediliyor. `outputs` listesinde birden fazla tensor varsa veya araya exception girerse native memory leak.
*   **[MEDIUM] Unsafe Logit Casting:** `raw.cast<double>()` (Satır 94) — model çıktısında bir int dönerse `TypeError`. ONNX plugin'i bazen float'ları int olarak döndürebilir.
*   **[MEDIUM] Empty Output Access:** `outputs.first` (onnx Satır 85), `raw.first` (Satır 92) ve `decodeOutput` içinde `logits[0]` (`device_classifier.dart:180`) — boş çıktı tensörü dönerse `StateError` / `RangeError`.
*   **[RESOLVED] Softmax Division by Zero:** `decodeOutput` (`device_classifier.dart:191`) `probs[i] /= sumExp`. **Geçersiz bulgu:** `maxLogit` çıkarımı sayesinde en az bir terim `exp(0)=1.0`, dolayısıyla `sumExp >= 1.0` her zaman. Bölme sıfıra imkânsız (logits boş değilse — boşsa zaten Satır 180 önce crash eder).

## 📊 Monitoring & Performance (İzleme ve Performans)
*   **[MEDIUM] Infinite Generator Leak:** `MonitoringRepositoryImpl.monitorNetworks` (Satır 23) `while(true)` döngüsü. Stream'i dinleyen BLoC dispose edilmezse arka plan taraması sonsuza dek sürer (batarya/kaynak sızıntısı). `MonitoringBloc.close()` doğru iptal ediyor ancak başka bir tüketici unutursa risk var.
*   **[MEDIUM] Topology Process Output Casting:** `topology_repository_impl.dart:89, 174` `result.stdout as String` — Linux/Android datasource ile aynı cast riski.
*   **[LOW] Backoff Delay Precision:** `monitoring_repository_impl.dart:33` `Future.delayed` OS tarafından optimize edilebilir. Bit-shift `1 << consecutiveErrors` `.clamp(0,6)` ile sınırlı — overflow yok.
*   **[LOW] Topology Regex Parse:** `topology_repository_impl.dart:92` `double.parse(match.group(1)!)` — `group(1)` non-optional grup olduğu için `!` güvenli, ancak `[\d.]+` "1.2.3" gibi yakalarsa `double.parse` `FormatException` fırlatabilir.

## 📱 UI & App Shell (Arayüz ve Navigasyon)
*   **[MEDIUM] Localization Extension Crash:** `_NeonErrorWidget` (`main.dart:82, 93`) `context.l10n` kullanıyor. `ErrorWidget.builder` (Satır 42) DI/Bootstrap aşamasında bir render hatasında çağrılırsa `AppLocalizations` bulunamayabilir; `context.l10n` extension'ı `AppLocalizations.of(context)!` ile force-unwrap yaptığı için "Null check operator" hatasıyla crash loop riski. **Azaltıldı:** `main.dart:210-216`'da `FallbackMaterialLocalizationsDelegate` / `FallbackCupertinoLocalizationsDelegate` mevcut ve İngilizce fallback sağlıyor — yani çoğu senaryoda korunuyor. Ancak Localizations ağaçta hiç yoksa (erken bootstrap hatası) `!` riski tam ortadan kalkmıyor; hata ekranı yine de ham string fallback kullanmalı.
*   **[MEDIUM] Shader Performance Crash:** `CyberGridBackground` shader bazlı arka planları (Aurora, Quantum Mesh, Aegis Shield, Signal Topography, Holo Sphere, Neural Pulse) düşük donanımlı Android'de GPU belleğini tüketerek "Out of Memory" / ANR'ye sebep olabilir.
*   **[LOW] shouldRepaint => true:** Tüm arka plan painter'ları `shouldRepaint` içinde koşulsuz `true` döndürüyor: `classic_grid_background.dart:337`, `signal_topography_background.dart:265`, `aegis_shield_background.dart:353`, `holo_sphere_background.dart:450`, `aurora_mesh_background.dart:501`, `quantum_mesh_background.dart:246`, `neural_pulse_background.dart:436`. **Severity düşürüldü:** 7 painter'ın hepsi `AnimatedBuilder(animation: Listenable.merge([_controller, widget.scrollVelocity]))` içinde. Repaint zaten yalnızca animasyon ilerlediğinde tetikleniyor ve her frame animasyon değeri gerçekten değişiyor; bu bağlamda `shouldRepaint => true` **doğru ve beklenen** davranış — "veri değişmese bile çizim" durumu yok. "OOM/ANR" iddiası geçersiz. Kalan tek nokta minik kod kokusu: `progress`/`velocity` değerleri `oldDelegate` ile karşılaştırılarak yine de daha açık yazılabilir.
*   **[LOW] ValueNotifier Leak:** `CyberGridBackground` içindeki `static scrollVelocity` ValueNotifier (Satır 30) hiçbir zaman dispose edilmez; statik olduğu için uygulama ömrü boyunca bellekte kalır.

## 🗄️ Storage & Data Sources (Depolama ve Veri Kaynakları)
*   **[MEDIUM] Unguarded jsonDecode:** Birkaç datasource `jsonDecode(...)` çağrısını try-catch'siz yapıyor; **bozuk/geçersiz** JSON string'i `FormatException` ile yükleme işlemini çökertir:
    *   `lan_scan_history_local_data_source.dart:84`
    *   `wifi_scan_history_local_data_source.dart:197` (`_decodeChannelStats`), `:214` (`_decodeBandStats`)
    *   *(Not 1: Çağrılar `?? '[]'` null-coalescing guard'ı altında — dolayısıyla **null** girdi güvenli; risk yalnızca veritabanında **bozuk/atipik** JSON string'i olması durumunda geçerli. Kapsam dar ama madde geçerli.)*
    *   *(Not 2: `ping_stabilizer_settings_store.dart:44` ve `app_settings_store.dart:36` zaten try-catch içinde — güvenli.)*
*   **[MEDIUM] Unsafe Cast on Hive Read:** `device_label_override_store.dart:33` `box.get(key) as String` — bozuk girdide `TypeError`, fallback yok. `favorites_store.dart:42` `.cast<String>()` — listede String olmayan eleman varsa `TypeError`.
*   **[MEDIUM] ThemeCubit Unguarded Load:** `theme_cubit.dart:16` `_load()` içinde `_storage.get<String>` try-catch'siz; Hive hatası DI ilklendirmesini çökertir. (Karşılaştırma: `LocaleCubit._loadSavedLocale` try-catch ile sarılı — güvenli.)
*   **[LOW] StreamController Dispose Eksikliği:** `@lazySingleton` store'lar broadcast `StreamController` açıyor ama `@disposeMethod` yok: `app_settings_store.dart:14`, `favorites_store.dart:11`, `scan_session_store.dart:14`. Uygulama ömrü boyunca bellekte kalır.

## 🛰️ VPN & Ping Stabilizer
*   **[MEDIUM] EventChannel TypeError:** `PingStabilizerChannel._ensureListening` (Satır 124) `event as Map?` cast yapıyor. Native taraf farklı bir tip dönerse runtime crash. (İç alanlar `as num?` ile daha güvenli alınıyor.)
*   **[MEDIUM] VPN State Desync:** Native `VpnService` Android tarafından durdurulursa Dart BLoC/Cubit haberdar olmayabilir (event channel gelmezse). UI "Bağlı" görünüp tünel kapalı olabilir. *(Not: `tunnelStopped` stream'i bu senaryoyu kısmen ele alıyor; `_stoppedSub` `close()` Satır 366'da iptal ediliyor.)*

## 🗺️ Heatmap & AR
*   **[HIGH] Matrix Inversion Error:** `HeatmapCanvas` (Satır 136) `Matrix4.inverted(matrix)` kullanıyor. Zoom/scale 0 olursa (singular matrix) `ArgumentError` fırlatır ve tap handler'da kilitlenmeye sebep olur. `tryInvert` kullanılmalı.
*   **[HIGH] Painting Performance (OOM Risk):** `_StaticHeatmapPainter._drawHeatmap` (Satır 367-395) her nokta için `MaskFilter.blur` + `Gradient.radial` ile çoklu daire çiziyor (üstüne 397+ satırda ikinci döngü). 500+ nokta içeren survey'lerde frame başına binlerce pahalı GPU operasyonu → overload/ANR. Downsampling veya image caching gerekli.
*   **[MEDIUM] GlobalToLocal Cast Crash:** `heatmap_canvas.dart:130` `context.findRenderObject() as RenderBox` — null kontrolü yok. Widget tap sırasında ağaçtan çıkıyorsa `null` dönüp `TypeError` fırlatır.
*   **[LOW] RenderObject Tip Cast:** `heatmap_page.dart:516` `findRenderObject() as RenderRepaintBoundary?` — null kontrolü var (`if (boundary == null) return`), ancak farklı bir RenderObject tipi dönerse `as` yine de fırlatır. Pratikte `_boundaryKey` bir `RepaintBoundary`'de — risk düşük.

---

## 🛠️ Genel Tespitler (Mimari & Pattern)
*   **Null Safety:** `!` (null check operator) kullanımı — özellikle `findRenderObject() as RenderBox`, eski `mdnsMap[...]!` gibi noktalarda.
*   **Unsafe Casts:** Asıl risk **non-nullable** cast'lerde: `as String` / `as T?` (Hive okumaları), `result.stdout as String` (`Process.stdout`). *Not:* Method/event channel sınırlarındaki `as String?` / `as int?` gibi **nullable** cast'ler doğrulamada güvenli çıktı — başarısız olunca `null` döner, crash etmez (bkz. Android cast — RESOLVED). Odak gerçek non-nullable cast noktalarında olmalı.
*   **Empty Collection Access:** `.last` / `.first` / `[0]` boş olabilecek stream/list üzerinde — `lastOrNull` / `firstOrNull` tercih edilmeli.
*   **Async Race Conditions:** Lock/mutex eksikliği (ONNX session yükleme), constructor içinde senkron I/O (`AppSettingsStore`).
*   **Background Tasks & Leaks:** `while(true)` generator'lar, dispose edilmeyen `StreamController` / static `ValueNotifier`. *Not:* `shouldRepaint => true` painter'lar bu kategoriden çıkarıldı — AnimatedBuilder ile sürüldükleri için gerçek bir leak/perf sorunu değil (bkz. UI bölümü, LOW).
*   **Error Handling:** `Either<Failure, T>` kullanımı; try-catch'siz `jsonDecode`; `ErrorWidget.builder` içinde lokalizasyona bağımlılık.
*   **DI (GetIt):** DI'da kayıtlı servislerin (`NetworkInfo`) manuel `new` edilmesi — tutarsızlık ve yakalanmayan plugin hataları.
