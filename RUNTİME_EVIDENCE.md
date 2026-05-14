# Torcav Runtime Error Evidence & Proof (Kanıtlar)

Bu dosya, `RUNTİMEERRORS.md` raporundaki iddiaların teknik kanıtlarını ve kod referanslarını içerir. Girdiler önem derecesine (CRITICAL → HIGH → MEDIUM → LOW) göre gruplanmıştır. Satır numaraları proje üzerinde doğrulanmıştır.

> **Doğrulama notu (2026-05-15):** 3 bağımsız tur ile tüm iddialar kod üzerinde yeniden kontrol edildi. Sonuç: #10 (Captive Portal) ve #12 (Android cast) **geçersiz** çıktı → RESOLVED bölümüne R3/R4 olarak taşındı. #22 (shouldRepaint) severity LOW'a düşürüldü. #3 (ErrorWidget) ve #19 (jsonDecode) maddelerine gözden kaçan guard notları eklendi.

---

## 🔴 CRITICAL

### 1. [CRITICAL] AppSettingsStore: DI Initialization Crash
**Hata:** Hive box'ı açılmadan (init tamamlanmadan) constructor içinde senkron storage erişimi.
**Dosya:** `lib/features/settings/domain/services/app_settings_store.dart`
```dart
17: AppSettingsStore(this._storage) : _settings = _loadInitialValue(_storage);
...
29: static AppSettings _loadInitialValue(HiveStorageService storage) {
30:   final raw = storage.get<String>(_settingsKey); // <--- BOOM!
```
**Dosya (Altyapı):** `lib/core/storage/hive_storage_service.dart`
```dart
35: Box get box => Hive.box(_defaultBoxName);
43: T? get<T>(String key, {T? defaultValue}) {
44:   return box.get(key, defaultValue: defaultValue) as T?;
45: }
```
**Analiz:** `AppSettingsStore` bir `@lazySingleton`. `configureDependencies()` aşamasında ilk erişimde `HiveStorageService.init` bitmemişse `Hive.box()` "Box not open" hatasıyla uygulamayı `runApp`'e gelmeden çökertir. Şu an `main.dart` sırası (`HiveStorageService.init` Satır 53 → `configureDependencies` Satır 54) bunu önlüyor; ancak constructor içinde senkron storage okuması kırılgan bir desen. `_loadInitialValue` lazy/async hale getirilmeli.

---

## 🟠 HIGH

### 2. [HIGH] SecurityRepositoryImpl: Stream.last Exception
**Hata:** Boş bir stream üzerinde `.last` çağrıldığında `StateError: No element`.
**Dosya:** `lib/features/security/data/repositories/security_repository_impl.dart`
```dart
280: final scanStream = _networkScanRepository.scanNetwork(subnet);
281: final scanResult = await scanStream.last;        // <--- RISK
...
306: final portScanStream = _networkScanRepository.scanWithProfile(gatewayIp);
309: final portScanResult = await portScanStream.last; // <--- RISK
...
461: final scanStream = _networkScanRepository.scanNetwork(subnet);
462: final scanResult = await scanStream.last;        // <--- RISK
...
478: final portScanStream = _networkScanRepository.scanWithProfile(gatewayIp);
481: final portScanResult = await portScanStream.last; // <--- RISK
```
**Analiz:** Ağ taraması sonuç üretmeden kapanırsa (empty stream) `StateError: No element` fırlar ve "Deep Scan" sırasında tüm güvenlik analizi yarıda kesilir. `last` yerine `lastOrNull` veya `fold` ile boşluk kontrolü yapılmalı.

### 3. [MEDIUM] _NeonErrorWidget: Localization Extension Crash
> **Not:** Severity HIGH → MEDIUM. Fallback localization delegate'leri bulundu (aşağıya bkz.); risk azaldı ama force-unwrap nedeniyle tamamen sıfırlanmadı. Konum gereği bu bölümde bırakıldı.

**Hata:** Lokalizasyon altyapısı kurulmadan hata ekranında `context.l10n` kullanımı.
**Dosya:** `lib/main.dart`
```dart
42: ErrorWidget.builder = (details) => _NeonErrorWidget(details: details);
...
82: Text(context.l10n.renderingErrorTitle, ...)
93:   ? context.l10n.renderingErrorBody
```
**Analiz:** `ErrorWidget.builder` bir render hatasında çağrılır. Hata `MaterialApp` ağaca eklenmeden (DI/Bootstrap aşamasında) oluşursa `context` içinde `AppLocalizations` bulunamaz. `context.l10n` extension'ı `AppLocalizations.of(context)!` yaptığı için `null` check operator hatasıyla crash loop'a girer.
**Azaltıcı faktör (doğrulamada bulundu):** `main.dart:210-216`'da `FallbackMaterialLocalizationsDelegate` ve `FallbackCupertinoLocalizationsDelegate` kayıtlı; bunlar İngilizce fallback sağlıyor (`fallback_localization_delegate.dart:24-30`). Yani `MaterialApp` ağaçtayken risk pratikte ortadan kalkıyor. Kalan risk: `MaterialApp` hiç kurulmadan (çok erken bootstrap hatası) `ErrorWidget` tetiklenirse `!` yine fırlatır. Hata ekranı yine de ham string / fallback kullanmalı.

### 4. [HIGH] OnnxDeviceClassifierService: Model Loading Race Condition
**Hata:** Eşzamanlı model yükleme denemelerinin dosya sisteminde çakışması.
**Dosya:** `lib/features/ai/data/services/onnx_device_classifier_service.dart`
```dart
254: Future<OrtSession?> _ensureSession() async {
255:   if (_session != null) return _session;
...
266:   final modelFile = File(p.join(tempDir.path, 'device_classifier.onnx'));
267:   await modelFile.writeAsBytes(modelBytes.buffer.asUint8List(), flush: true);
...
273:   _session = OrtSession.fromFile(modelFile, sessionOptions);
```
**Analiz:** `_ensureSession` içinde lock/mutex yok. İki sınıflandırma aynı anda başlarsa ikisi de aynı `modelFile` yoluna yazar; biri yazarken diğeri açmaya çalışırsa `FileSystemException` fırlar ve AI modülü `_initFailed = true` ile kalıcı devre dışı kalır. Bir `Completer` veya mutex kullanılmalı.

### 5. [HIGH] HeatmapCanvas: Matrix Inversion Error
**Hata:** Singular (tersi alınamaz) matrisin `Matrix4.inverted` ile çevrilmesi.
**Dosya:** `lib/features/heatmap/presentation/widgets/heatmap_canvas.dart`
```dart
134: final Matrix4 matrix = _transformationController.value;
136: final Matrix4 inverse = Matrix4.inverted(matrix); // <--- ARGUMENTERROR
```
**Analiz:** Zoom/scale değeri sıfıra yaklaşırsa veya transform matrisi singular olursa `Matrix4.inverted` `ArgumentError` fırlatır ve tap handler kilitlenir. `matrix.clone()..invert()` dönüş değeri kontrolü veya `tryInvert` deseni kullanılmalı.

### 6. [HIGH] HeatmapCanvas: Painting Performance (OOM Risk)
**Hata:** Nokta başına çoklu blur + gradient çizimi.
**Dosya:** `lib/features/heatmap/presentation/widgets/heatmap_canvas.dart`
```dart
367: for (final point in points) {
...
377:   ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
...
385:   ..shader = ui.Gradient.radial(centre, heatmapRadius, [...], const [0.2, 1]),
...
397: for (final point in points) {  // ikinci tam tur
```
**Analiz:** `_drawHeatmap` her nokta için bir `MaskFilter.blur` + bir `Gradient.radial` oluşturuyor, ardından ikinci bir döngü daha. 500+ noktalı survey'de frame başına binlerce pahalı GPU operasyonu → düşük donanımda OOM / "Frame Hang" (ANR). Nokta sayısı arttıkça downsampling veya image caching yapılmalı.

---

## 🟡 MEDIUM

### 7. [MEDIUM] HiveStorageService: Type Mismatch on Cast
**Hata:** `as T?` cast'inin kaydedilen tiple uyuşmaması.
**Dosya:** `lib/core/storage/hive_storage_service.dart`
```dart
43: T? get<T>(String key, {T? defaultValue}) {
44:   return box.get(key, defaultValue: defaultValue) as T?;
45: }
```
**Analiz:** Kaydedilen veri tipi istenen `T` ile uyuşmazsa (örn. `int` kaydedilmiş, `String` isteniyor) `TypeError` fırlar. Birçok store bu metoda güveniyor; tip uyuşmazlığında güvenli `null` dönüşü yok.

### 8. [MEDIUM] DI: Registration Failure / Unregistered Access
**Hata:** Kayıtsız servise `getIt<T>` ile erişim veya kayıt başarısızlığı.
**Dosya:** `lib/core/di/` (`configureDependencies`)
**Analiz:** `configureDependencies()` içinde bir servis kaydı başarısız olursa veya henüz kayıtlı olmayan bir servise `getIt<T>` ile erişilirse `StateError` fırlatılır. Bootstrap aşamasında yakalanmazsa uygulama açılmaz.

### 9. [MEDIUM] NetworkInfo: Manual Instantiation (DI Bypass)
**Hata:** DI'da sağlanan `NetworkInfo`'nun manuel `new` edilmesi, plugin hatalarının yakalanmaması.
**Dosya (DI sağlayıcı):** `lib/core/di/di_module.dart:14` → `NetworkInfo get networkInfo => NetworkInfo();`
**Manuel kullanım noktaları:**
```dart
lib/features/security/data/repositories/security_repository_impl.dart:46  final NetworkInfo _networkInfo = NetworkInfo();
lib/features/security/domain/usecases/arp_spoofing_detector.dart:10       final NetworkInfo _networkInfo = NetworkInfo();
lib/features/security/presentation/bloc/security_bloc.dart:33             final NetworkInfo _networkInfo = NetworkInfo();
lib/features/network_scan/data/datasources/arp_data_source.dart:82        final info = NetworkInfo();
lib/features/security/presentation/pages/router_hardening_wizard_page.dart:39
lib/features/monitoring/presentation/widgets/router_admin_guide_card.dart:39
lib/features/monitoring/presentation/pages/spectrum_optimization_page.dart:131
lib/features/diagnostics/data/repositories/diagnostics_repository_impl.dart:164
```
**Analiz:** Bu noktalarda platform plugin hataları (`MissingPluginException`, `PlatformException`) veya izin eksiklikleri yakalanmıyor. DI üzerinden tek noktadan sağlanması ve hata sarmalama eklenmesi gerekir.

### 10. [RESOLVED] CaptivePortalDetector: Infinite Await
> **Geçersiz bulgu — RESOLVED bölümüne taşındı (R4).** `CaptivePortalDetector.check()` içinde `HttpClient.connectionTimeout = 5s` + request'te `.timeout(5s)` + dış try-catch mevcut. Sonsuz `await` mümkün değil. Detay için bkz. **R4**.

### 11. [MEDIUM] LinuxWifiDataSource: Process Output Casting
**Hata:** `result.stdout`'un koşulsuz `as String` cast'i.
**Dosya:** `lib/features/wifi_scan/data/datasources/linux_wifi_data_source.dart`
```dart
94:  (result.stdout as String).split('\n')...
177: return _parseIwlist(result.stdout as String, request);
248: ).firstMatch(result.stdout as String);
```
**Analiz:** `Process.run` normalde `systemEncoding` ile String döner; ancak binary çıktı veya encoding hatasında `stdout` `List<int>` olabilir → `TypeError`. Cast öncesi tip kontrolü veya `stdoutEncoding` belirtimi gerekir.

### 12. [RESOLVED] AndroidWifiDataSource: Native Type Casting
> **Geçersiz bulgu — RESOLVED bölümüne taşındı (R3).** Cited cast'lerin hepsi **nullable** (`as String?` / `as int?`); native tarafta tip değişse bile cast `TypeError` fırlatmaz, `null` döner. Detay için bkz. **R3**.

### 13. [MEDIUM] NetworkScanRepositoryImpl: mDNS Empty List Access
**Hata:** mDNS eşleşmesinin boş liste değeri üzerinde `.first`.
**Dosya:** `lib/features/network_scan/data/repositories/network_scan_repository_impl.dart`
```dart
94: if (hostName.isEmpty && mdnsMap.containsKey(host.ip)) {
95:   hostName = mdnsMap[host.ip]!.first;
96: }
```
**Analiz:** `containsKey` kontrolü `!` operatörünü güvenli kılar (arada `await` yok), ancak `mdnsMap[host.ip]` değeri boş bir liste ise `.first` `StateError: No element` fırlatır. `firstOrNull` kullanılmalı.

### 14. [MEDIUM] NetworkScanRepositoryImpl: Reverse DNS Timeout
**Hata:** `InternetAddress.reverse()`'in timeout'suz çağrılması ve geçersiz IP riski.
**Dosya:** `lib/features/network_scan/data/repositories/network_scan_repository_impl.dart`
```dart
158: Future<String> _reverseDnsLookup(String ip) async {
159:   try {
160:     final address = InternetAddress(ip);   // geçersiz IP → ArgumentError
161:     final result = await address.reverse(); // timeout yok
162:     return result.host != ip ? result.host : '';
163:   } catch (_) {
164:     return '';
165:   }
```
**Analiz:** `InternetAddress(ip)` geçersiz IP ile `ArgumentError` fırlatır — **mevcut try-catch bunu yakalıyor**. Asıl risk: `address.reverse()` üzerinde timeout yok; yanıtsız bir DNS sunucusunda çağrı uzun süre askıda kalabilir ve tarama yavaşlar.

### 15. [MEDIUM] TopologyRepositoryImpl: Process Output Casting
**Hata:** `result.stdout`'un koşulsuz `as String` cast'i.
**Dosya:** `lib/features/monitoring/data/repositories/topology_repository_impl.dart`
```dart
89:  final output = result.stdout as String;
174: final output = result.stdout as String;
```
**Analiz:** #11 ile aynı failure mode — `ping` çıktısı beklenmedik tipte dönerse `TypeError`.

### 16. [MEDIUM] HeatmapCanvas: GlobalToLocal Cast Crash
**Hata:** `findRenderObject()` sonucunun null kontrolsüz `as RenderBox` cast'i.
**Dosya:** `lib/features/heatmap/presentation/widgets/heatmap_canvas.dart`
```dart
129: final RenderBox box =
130:     context.findRenderObject() as RenderBox;
131: final Offset localOffset = box.globalToLocal(details.globalPosition);
```
**Analiz:** Tap işlemi sırasında widget ağaçtan çıkıyorsa `findRenderObject()` `null` dönebilir; `as RenderBox` cast'i `TypeError` fırlatır. `as RenderBox?` + null guard kullanılmalı.

### 17. [MEDIUM] PingStabilizerChannel: EventChannel TypeError
**Hata:** EventChannel olayının `as Map?` cast'i.
**Dosya:** `lib/features/ping_stabilizer/data/datasources/ping_stabilizer_channel.dart`
```dart
122:   _eventSub ??= _events.receiveBroadcastStream().listen(
123:     (event) {
124:       final m = (event as Map?) ?? const {};
```
**Analiz:** Native taraf yanlışlıkla `List` / `String` / başka bir tip yayarsa `as Map?` cast'i `TypeError` fırlatır. (İç alanlar `as num?` ile güvenli alınıyor, ancak dış cast korumasız.)

### 18. [MEDIUM] VPN State Desync
**Hata:** Native VPN servisi ile Dart Cubit durumunun senkronizasyon kaybı.
**Dosya:** `lib/features/ping_stabilizer/` (native `VpnService` ↔ `PingStabilizerCubit`)
**Analiz:** Native `VpnService` Android tarafından sistem kaynakları için durdurulursa ve event channel olayı gelmezse, Cubit "Bağlı" durumunda kalır ancak tünel kapalıdır. `tunnelStopped` stream'i (`ping_stabilizer_channel.dart:117`) bu senaryoyu kısmen ele alıyor; `_stoppedSub` `ping_stabilizer_cubit.dart:366`'da düzgün iptal ediliyor — yine de native teardown event'i hiç gelmezse desync sürer.

### 19. [MEDIUM] Unguarded jsonDecode in Data Sources
**Hata:** Bozuk JSON'da yakalanmayan `FormatException`.
**Dosya:** `lib/features/network_scan/data/datasources/lan_scan_history_local_data_source.dart`
```dart
84: (jsonDecode(row['payload_json'] as String? ?? '[]') as List<dynamic>)
```
**Dosya:** `lib/features/wifi_scan/data/datasources/wifi_scan_history_local_data_source.dart`
```dart
197: final decoded = jsonDecode(raw) as List<dynamic>;  // _decodeChannelStats
214: final decoded = jsonDecode(raw) as List<dynamic>;  // _decodeBandStats
```
**Analiz:** Veritabanında bozuk/eksik JSON varsa `jsonDecode` `FormatException` fırlatır ve yükleme işlemi çöker. Bu metotlar try-catch ile sarılmalı.
**Azaltıcı faktör (doğrulamada bulundu):** `lan_scan_history_local_data_source.dart:84` çağrısı `?? '[]'` null-coalescing guard'ı altında — yani satır/sütun **null** olduğunda güvenli, geçerli boş JSON'a düşüyor. Risk yalnızca veritabanında fiilen **bozuk/atipik** bir JSON string'i bulunması durumunda geçerli. Madde geçerli kalır, kapsamı dardır. *(Not: `ping_stabilizer_settings_store.dart:44` ve `app_settings_store.dart:36` zaten try-catch içinde — güvenli.)*

### 20. [MEDIUM] Unsafe Cast on Hive Read (Stores)
**Hata:** Hive okumalarında fallback'siz `as` cast'leri.
**Dosya:** `lib/features/ai/data/stores/device_label_override_store.dart`
```dart
33: result[mac] = box.get(key) as String;
```
**Dosya:** `lib/features/wifi_scan/data/services/favorites_store.dart`
```dart
42: return (storage.get<List<dynamic>>(_key) ?? []).cast<String>().toSet();
```
**Analiz:** `box.get(key) as String` — değer bozulmuş/farklı tipteyse `TypeError`, fallback yok. `.cast<String>()` — listede String olmayan eleman varsa erişimde `TypeError`. `whereType<String>()` veya tryCast deseni güvenli.

### 21. [MEDIUM] ThemeCubit: Unguarded Storage Read in Constructor
**Hata:** Constructor'da try-catch'siz senkron storage okuması.
**Dosya:** `lib/core/theme/theme_cubit.dart`
```dart
11: ThemeCubit(this._storage) : super(ThemeMode.dark) {
12:   _load();
13: }
15: void _load() {
16:   final saved = _storage.get<String>(_key);  // <--- korumasız
```
**Analiz:** `_storage.get` Hive hatası fırlatırsa DI ilklendirmesi çöker. Karşılaştırma: `LocaleCubit._loadSavedLocale` (`locale_cubit.dart:17-37`) try-catch ile sarılı ve güvenli — `ThemeCubit._load` aynı korumayı almalı.

### 22. [LOW] Shader Backgrounds: shouldRepaint => true (Kod Kokusu)
> **Severity MEDIUM → LOW. "Perf/OOM" iddiası geçersiz.**

**Durum:** Painter'lar `shouldRepaint` içinde koşulsuz `true` döndürüyor.
**Dosyalar (hepsi koşulsuz `true`):**
```dart
lib/features/security/presentation/widgets/classic_grid_background.dart:337
lib/features/security/presentation/widgets/signal_topography_background.dart:265
lib/features/security/presentation/widgets/aegis_shield_background.dart:353
lib/features/security/presentation/widgets/holo_sphere_background.dart:450
lib/features/security/presentation/widgets/aurora_mesh_background.dart:501
lib/features/security/presentation/widgets/quantum_mesh_background.dart:246
lib/features/security/presentation/widgets/neural_pulse_background.dart:436
```
**Analiz (doğrulamada düzeltildi):** 7 painter'ın **hepsi** `AnimatedBuilder(animation: Listenable.merge([_controller, widget.scrollVelocity]))` içinde sarılı (örn. `classic_grid_background.dart:81-83`). Painter zaten yalnızca `_controller` (AnimationController) ilerlediğinde veya `scrollVelocity` değiştiğinde çağrılıyor ve bu durumlarda animasyon değeri **gerçekten** değişiyor. Dolayısıyla `shouldRepaint => true` bu bağlamda **doğru ve beklenen** davranıştır — "veri değişmese bile çizim" senaryosu yok, "her frame gereksiz repaint" yanlış. "OOM / ANR" iddiası geçersiz. Kalan tek nokta: `progress` / `velocity` değerleri `oldDelegate` ile karşılaştırılarak niyet daha açık ifade edilebilirdi (kozmetik kod kokusu, crash/perf riski değil).

### 23. [MEDIUM] OnnxDeviceClassifierService: Session Run Memory Leak & Unsafe Cast
**Hata:** Tensor release eksikliği ve `raw.cast<double>()` tip riski.
**Dosya:** `lib/features/ai/data/services/onnx_device_classifier_service.dart`
```dart
81: final outputs = session.run(runOptions, {'features': inputOrt});
85: final outputTensor = outputs.first;   // boş liste → StateError
...
88: outputTensor.release();               // yalnızca .first release
92: logits = raw.first;                   // boş iç liste → StateError
94: logits = raw.cast<double>();           // int dönerse → TypeError
```
**Analiz:** `outputs` listesinde birden fazla tensor varsa yalnızca `.first` release ediliyor → native memory leak. `outputs.first` / `raw.first` boş listede `StateError`. `raw.cast<double>()` model çıktısında bir int dönerse `TypeError` (ONNX plugin'i bazen float'ları int döndürür).

### 24. [MEDIUM] DeviceFeatureExtractor: Empty Logits Access
**Hata:** Boş logit listesinde indeks erişimi.
**Dosya:** `lib/features/ai/domain/services/device_classifier.dart`
```dart
178: static DeviceClassification decodeOutput(List<double> logits) {
180:   var maxLogit = logits[0];  // <--- boş liste → RangeError
```
**Analiz:** Model boş çıktı tensörü dönerse `logits[0]` `RangeError` fırlatır. `if (logits.isEmpty)` koruması eklenmeli.

### 25. [MEDIUM] MonitoringRepositoryImpl: Infinite Generator Leak
**Hata:** `while(true)` generator'ın tüketici tarafından iptal edilmemesi.
**Dosya:** `lib/features/monitoring/data/repositories/monitoring_repository_impl.dart`
```dart
22: var consecutiveErrors = 0;
23: while (true) {
24:   final result = await _wifiRepository.scanNetworks();
...
39: }
```
**Analiz:** Stream'i dinleyen BLoC dispose edilmezse arka plan taraması sonsuza dek sürer (batarya/kaynak sızıntısı). `MonitoringBloc.close()` doğru iptal ediyor ancak başka bir tüketici subscription'ı iptal etmeyi unutursa sızıntı kaçınılmaz.

### 26. [MEDIUM] DnsSecurityCard: Empty Benchmark List .last
**Hata:** Boş benchmark listesinde `.last`.
**Dosya:** `lib/features/security/presentation/widgets/dns_security_card.dart`
```dart
360: final sortedBenchmarks = List<DnsBenchmarkResult>.from(benchmarks)
361:   ..sort((a, b) => a.latencyMs.compareTo(b.latencyMs));
363: final maxLatency = sortedBenchmarks.last.latencyMs; // <--- StateError
```
**Analiz:** `_DnsBenchmarkSection.build` içinde `benchmarks` boşsa `sortedBenchmarks.last` `StateError: No element` fırlatır. Widget içinde `isEmpty` koruması yok; çağıran taraf veri yüklenmeden build ederse crash.

---

## 🟢 LOW

### 27. [LOW] HiveStorageService: Box Getter Race Condition
**Dosya:** `lib/core/storage/hive_storage_service.dart`
```dart
35: Box get box => Hive.box(_defaultBoxName);
```
**Analiz:** `init` tamamlanmadan `box` getter çağrılırsa `HiveError` (Box not open) fırlatır. Normal bootstrap sırasında önlenir ancak savunmacı kontrol yok.

### 28. [LOW] main.dart: SecureStorage Direct Initialization
**Dosya:** `lib/main.dart`
```dart
47: const secureStorage = FlutterSecureStorage(...);
50: final hiveKey = await const SecureStorageService(secureStorage).getOrCreateHiveBoxKey();
```
**Analiz:** `SecureStorageService` DI dışında doğrudan ilklendiriliyor. Android keychain sorunlarında (`PlatformException`) bu aşama uygulamayı `runApp`'e gelmeden kilitleyebilir; try-catch yok.

### 29. [LOW] SecurityRepositoryImpl: IP String Parsing (Azaltıldı)
**Dosya:** `lib/features/security/data/repositories/security_repository_impl.dart`
```dart
276: if (ip != null && ip.contains('.')) {
277:   final subnet = '${ip.substring(0, ip.lastIndexOf('.'))}.0';
...
305: cloudGateway ?? '${ip.substring(0, ip.lastIndexOf('.'))}.1';
456: final subnet = '${ip.substring(0, ip.lastIndexOf('.'))}.0';
477: '${subnet.substring(0, subnet.lastIndexOf('.'))}.1';
```
**Analiz:** **Azaltılmış risk:** çağrılar `ip.contains('.')` koruması altında, dolayısıyla `lastIndexOf('.') >= 0` garanti ve `substring(0, idx)` geçerli. Eski raporda HIGH/MEDIUM olarak işaretliydi; mevcut kodda guard mevcut. Atipik girdilerde takip edilmesi yeterli.

### 30. [LOW] LinuxWifiDataSource: nmcli Parsing Logic
**Dosya:** `lib/features/wifi_scan/data/datasources/linux_wifi_data_source.dart`
```dart
124: final fields = _splitNmcli(line);
125: if (fields.length < 6) return null;
127: final ssid = fields[0].replaceAll(r'\:', ':');
...
133: final security = _mapNmcliSecurity(fields[5]);
```
**Analiz:** `fields` erişimleri `if (fields.length < 6) return null` + dış try-catch (Satır 121/147) ile korunuyor — crash riski düşük. Ancak farklı locale / atipik nmcli çıktısında `_splitNmcli` mantığı yanlış parsing yapabilir (sessiz veri kaybı).

### 31. [LOW] AndroidWifiDataSource: Scan Throttling
**Dosya:** `lib/features/wifi_scan/data/datasources/android_wifi_data_source.dart`
**Analiz:** Android 9+ cihazlarda 2 dakikada 4 tarama sınırı vardır; `startScan()` false döner. Bu bir crash değil platform kısıtlamasıdır, ancak UI'da uyarı verilmezse kullanıcı verinin güncelliğinden şüphe eder.

### 32. [LOW] MonitoringRepositoryImpl: Backoff Precision
**Dosya:** `lib/features/monitoring/data/repositories/monitoring_repository_impl.dart`
```dart
27: final backoff = Duration(
28:   milliseconds: (interval.inMilliseconds * (1 << consecutiveErrors.clamp(0, 6)))
30:       .clamp(interval.inMilliseconds, _maxBackoff.inMilliseconds),
```
**Analiz:** `1 << consecutiveErrors` `.clamp(0, 6)` ile sınırlı (maks `1 << 6 = 64`) — integer overflow yok. `Future.delayed` OS tarafından optimize edilebilir; hassas zamanlama gerektiren durumlarda kaymalar olabilir. Crash riski yok.

### 33. [LOW] TopologyRepositoryImpl: Regex Parse FormatException
**Dosya:** `lib/features/monitoring/data/repositories/topology_repository_impl.dart`
```dart
90: final match = RegExp(r'time=([\d.]+)').firstMatch(output);
92:   final ms = double.parse(match.group(1)!).round();
...
180: final ttl = int.parse(ttlMatch.group(1)!);
```
**Analiz:** `group(1)` non-optional capture grup olduğu için eşleşme sonrası `!` güvenli. Ancak `[\d.]+` "1.2.3" gibi geçersiz bir dize yakalarsa `double.parse` `FormatException` fırlatabilir. `double.tryParse` kullanılmalı. (`int.parse` Satır 180 `\d+` ile güvenli.)

### 34. [LOW] CyberGridBackground: Static ValueNotifier Leak
**Dosya:** `lib/features/security/presentation/widgets/cyber_grid_background.dart`
```dart
30: static final ValueNotifier<double> scrollVelocity = ValueNotifier<double>(0.0);
```
**Analiz:** Statik `ValueNotifier` hiçbir zaman dispose edilmez; uygulama ömrü boyunca bellekte kalır. `AnimatedBuilder` üzerinden eklenen listener'lar da temizlenmez. Crash değil, kalıcı bellek tüketimi.

### 35. [LOW] Singleton Stores: StreamController Not Disposed
**Dosyalar:**
```dart
lib/features/settings/domain/services/app_settings_store.dart:14   StreamController<AppSettings>.broadcast()
lib/features/wifi_scan/data/services/favorites_store.dart:11        StreamController<Set<String>>.broadcast()
lib/features/wifi_scan/domain/services/scan_session_store.dart:14   StreamController<ScanSnapshot>.broadcast()
```
**Analiz:** `@lazySingleton` store'lar broadcast `StreamController` açıyor ancak `@disposeMethod` tanımlamıyor. Uygulama ömrü boyunca açık kalır — kritik değil ama temiz kapanış için `@disposeMethod` eklenmeli.

### 36. [LOW] HeatmapPage: RenderObject Type Cast
**Dosya:** `lib/features/heatmap/presentation/pages/heatmap_page.dart`
```dart
515: final boundary = _boundaryKey.currentContext?.findRenderObject()
516:     as RenderRepaintBoundary?;
517: if (boundary == null) return;
```
**Analiz:** Null kontrolü mevcut (`if (boundary == null) return`). Ancak `findRenderObject()` farklı bir `RenderObject` tipi dönerse `as RenderRepaintBoundary?` yine de `TypeError` fırlatır (`?` yalnızca null'a izin verir, yanlış tipe değil). Pratikte `_boundaryKey` bir `RepaintBoundary`'de olduğu için risk çok düşük.

---

## ⚪ RESOLVED / Geçersiz Bulgular (Önceki Raporda Yanlış İşaretlenmiş)

### R1. [RESOLVED] DeviceFeatureExtractor: Softmax Division by Zero
**Dosya:** `lib/features/ai/domain/services/device_classifier.dart`
```dart
184: var sumExp = 0.0;
186: for (var i = 0; i < logits.length; i++) {
187:   probs[i] = math.exp(logits[i] - maxLogit);
188:   sumExp += probs[i];
189: }
191: probs[i] /= sumExp;
```
**Analiz:** **Geçersiz bulgu.** `maxLogit` çıkarımı nedeniyle en az bir terim `exp(0) = 1.0` olur, dolayısıyla `sumExp >= 1.0` her zaman garanti. Bölme sıfıra matematiksel olarak imkânsız. (logits boşsa zaten Satır 180 `logits[0]` önce `RangeError` fırlatır — bkz. #24.) Önceki raporda LOW olarak yer alıyordu; gerçek risk değil.

### R2. [RESOLVED] PositionTracker: session.points.last Race
**Dosya:** `lib/features/heatmap/domain/services/position_tracker.dart`
```dart
88: if (session.points.isEmpty) return true;
89: final lastPoint = session.points.last;
```
**Analiz:** **Geçersiz bulgu.** `isEmpty` kontrolü ile `.last` erişimi arasında `await` yok — tamamen senkron. Eşzamanlılık race'i mümkün değil. Güvenli.

---

### R3. [RESOLVED] AndroidWifiDataSource: Native Type Casting (eski #12)
**Dosya:** `lib/features/wifi_scan/data/datasources/android_wifi_data_source.dart`
```dart
109: final capabilities = ext?['capabilities'] as String?;
123: ext?['channelWidth'] as int?,
126: ext?['wifiStandard'] as int?,
137: apMldMac: ext?['apMldMac'] as String?,
```
**Analiz:** **Geçersiz bulgu.** Cited cast'lerin **tamamı nullable** (`as String?` / `as int?`). Dart'ta `x as T?` ifadesi `x` `T` değilse `TypeError` fırlatmaz; `null` döner. Native (Kotlin) taraf bir alanın tipini değiştirse bile cast başarısız olur ve alan `null` olarak işlenir — ilgili alanlar zaten opsiyonel. Crash mümkün değil. Önceki raporda MEDIUM olarak yer alıyordu; gerçek risk değil. *(Karşılaştırma: gerçek risk **non-nullable** cast'lerde — örn. `result.stdout as String` (#11, #15) veya `box.get(key) as String` (#20).)*

### R4. [RESOLVED] CaptivePortalDetector: Infinite Await (eski #10)
**Dosya:** `lib/features/security/domain/services/captive_portal_detector.dart`
```dart
22: try {
27:   final client = HttpClient()..connectionTimeout = const Duration(seconds: 5);
32:   final response = await request.close().timeout(const Duration(seconds: 5));
...
58: } catch (_) {
59:   return (status: CaptivePortalStatus.unknown, event: null);
60: }
```
**Analiz:** **Geçersiz bulgu.** `check()` üç katmanlı korumaya sahip: (1) `HttpClient.connectionTimeout = 5s`, (2) `request.close()` üzerinde `.timeout(5s)`, (3) tüm gövdeyi saran dış try-catch — herhangi bir hata/timeout `CaptivePortalStatus.unknown` ile sessizce sonuçlanır. Yanıtsız bir ağda `await` sonsuza dek askıda kalamaz; en kötü senaryo 5 saniyelik gecikmedir. Önceki raporda MEDIUM olarak yer alıyordu; gerçek risk değil.
