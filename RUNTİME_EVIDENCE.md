# Torcav Runtime Error Evidence & Proof (Kanıtlar)

Bu dosya, `RUNTİMEERRORS.md` raporundaki iddiaların teknik kanıtlarını ve kod referanslarını içerir. Girdiler önem derecesine (CRITICAL → HIGH → MEDIUM → LOW) göre gruplanmıştır. Satır numaraları proje üzerinde doğrulanmıştır.

> **Doğrulama notu (2026-05-18):** Önceki turun "Hâlâ açık" listesindeki **10 madde kodda fix'lendi** (R19–R28) ve **2 madde by-design olarak kapatıldı** (R26 `while(true)`, R29 CyberGrid ValueNotifier). Android scan throttling zaten implement (R25). Heatmap painting daha da optimize edildi (R30). `flutter analyze`: 0 issue. **Tüm bilinen aktif runtime bulguları kapatıldı.**

> **Doğrulama notu (2026-05-17):** CEO turu, 2026-05-15'ten sonra kodda **12 ek bulgunun sessizce düzeltildiğini** tespit etti. Şu maddeler RESOLVED'a taşındı: #1 (AppSettings @postConstruct → R5), #2 (Stream.last → R6), #4 (ONNX race → R7), #5 (Matrix4 → R8), #7 (HiveStorage get<T> → R9), #9 (NetworkInfo DI → R10), #16 (findRenderObject → R11), #20 (Hive cast → R12), #21 (ThemeCubit → R13), #23 (ONNX leak — kısmi: R14), #24 (decodeOutput → R15), #26 (DnsCard → R16), #33 (Topology regex+stdout → R17), #35 (StreamController → R18). #6 (Heatmap painting) **PARTIAL** — RepaintBoundary eklendi ama per-point blur sürüyor. #13 (mdnsMap) severity LOW'a düşürüldü. #23 yalnızca `raw.cast<double>()` kısmı için MEDIUM kalır.

> **Doğrulama notu (2026-05-15):** 3 bağımsız tur ile tüm iddialar kod üzerinde yeniden kontrol edildi. Sonuç: #10 (Captive Portal) ve #12 (Android cast) **geçersiz** çıktı → RESOLVED bölümüne R3/R4 olarak taşındı. #22 (shouldRepaint) severity LOW'a düşürüldü. #3 (ErrorWidget) ve #19 (jsonDecode) maddelerine gözden kaçan guard notları eklendi.

---

## 🔴 CRITICAL

### 1. [RESOLVED] AppSettingsStore: DI Initialization Crash
> **RESOLVED — bkz. R5.** `AppSettingsStore` `@postConstruct` async `init()` deseniyle yeniden yazıldı; constructor yalnızca default değer atıyor. Detay R5'te.

---

## 🟠 HIGH

### 2. [RESOLVED] SecurityRepositoryImpl: Stream.last Exception
> **RESOLVED — bkz. R6.** 4 noktanın hepsi `.lastOrNull`'a geçti (yeni satırlar 283, 312, 465, 485). Detay R6'da.

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

### 4. [RESOLVED] OnnxDeviceClassifierService: Model Loading Race Condition
> **RESOLVED — bkz. R7.** `Completer<void>? _initCompleter` ile serileştirildi (Satır 263-303). Detay R7'de.

### 5. [RESOLVED] HeatmapCanvas: Matrix Inversion Error
> **RESOLVED — bkz. R8.** `determinant() == 0` guard'ı eklendi (Satır 140-141). Detay R8'de.

### 6. [MEDIUM — PARTIAL] HeatmapCanvas: Painting Performance
> **Kısmen mitige:** `heatmap_canvas.dart:155-169` static layer `RepaintBoundary` ile sarıldı; dynamic layer için ayrı `RepaintBoundary` (Satır 176-185). Re-paint maliyeti büyük ölçüde elimine. **Kalan:** İlk-frame ve veri değişikliğinde per-point `MaskFilter.blur` + `Gradient.radial` döngüleri (Satır ~374-413) hâlâ var; 500+ nokta için image caching (`PictureRecorder` → `toImage`) veya downsampling önerilir. Severity HIGH → MEDIUM.

**Dosya:** `lib/features/heatmap/presentation/widgets/heatmap_canvas.dart`
```dart
// 155-169: static layer RepaintBoundary
// 176-185: dynamic layer RepaintBoundary
// 374-413: hâlâ per-point blur+gradient (iki döngü)
```
**Analiz:** Re-paint sıklığı RepaintBoundary sayesinde dramatik olarak düştü, ancak ilk paint maliyeti aynı kaldı. ANR / OOM riski büyük ölçüde azaldı ama eliminate edilmedi.

---

## 🟡 MEDIUM

### 7. [RESOLVED] HiveStorageService: Type Mismatch on Cast
> **RESOLVED — bkz. R9.** Artık try-catch + `is! T` runtime check + `defaultValue` fallback (`hive_storage_service.dart:43-56`). Detay R9'da.

### 8. [MEDIUM] DI: Registration Failure / Unregistered Access
**Hata:** Kayıtsız servise `getIt<T>` ile erişim veya kayıt başarısızlığı.
**Dosya:** `lib/core/di/` (`configureDependencies`)
**Analiz:** `configureDependencies()` içinde bir servis kaydı başarısız olursa veya henüz kayıtlı olmayan bir servise `getIt<T>` ile erişilirse `StateError` fırlatılır. Bootstrap aşamasında yakalanmazsa uygulama açılmaz.

### 9. [RESOLVED] NetworkInfo: Manual Instantiation (DI Bypass)
> **RESOLVED — bkz. R10.** 8 noktanın hepsi DI'a geçti (field injection / `getIt<>()` / widget parametresi). Detay R10'da.

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

### 13. [LOW] NetworkScanRepositoryImpl: mDNS Empty List Access
> **Severity MEDIUM → LOW.** `containsKey` guard'ı pratikte etkili; boş liste değeri mDNS implementasyonunda nadir bir durum.

**Dosya:** `lib/features/network_scan/data/repositories/network_scan_repository_impl.dart`
```dart
94: if (hostName.isEmpty && mdnsMap.containsKey(host.ip)) {
95:   hostName = mdnsMap[host.ip]!.first;
96: }
```
**Analiz:** `containsKey` kontrolü `!` operatörünü güvenli kılar (arada `await` yok); değer listesi boşsa `.first` yine `StateError` fırlatır ama mDNS resolver normal şartlarda boş liste tutmuyor. Yine de defansif olarak `firstOrNull` ile değiştirilmesi önerilir.

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

### 16. [RESOLVED] HeatmapCanvas: GlobalToLocal Cast Crash
> **RESOLVED — bkz. R11.** `is! RenderBox` guard'ı eklendi (Satır 130-131). Detay R11'de.

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

### 20. [RESOLVED] Unsafe Cast on Hive Read (Stores)
> **RESOLVED — bkz. R12.** `device_label_override_store.dart:34` `if (value is String)` ile kontrol; `favorites_store.dart:48` `.whereType<String>().toSet()`. Detay R12'de.

### 21. [RESOLVED] ThemeCubit: Unguarded Storage Read in Constructor
> **RESOLVED — bkz. R13.** `_load()` tamamen try-catch içine alındı; hata durumunda sessiz `ThemeMode.dark` fallback (`theme_cubit.dart:15-28`). Detay R13'te.

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

### 23. [MEDIUM — PARTIAL] OnnxDeviceClassifierService: raw.cast<double>() (eski memory leak + empty access RESOLVED)
> **Memory leak ve empty access RESOLVED** (bkz. R14 ve R15). **Hâlâ açık:** `raw.cast<double>()` (Satır 94) — model çıktısında bir int dönerse `TypeError`.

**Dosya:** `lib/features/ai/data/services/onnx_device_classifier_service.dart`
```dart
94: logits = raw.cast<double>();           // int dönerse → TypeError
```
**Analiz:** ONNX plugin'i bazen float'ları int olarak döndürebilir. `raw.map((e) => (e as num).toDouble()).toList()` daha güvenli olur. *(Memory leak ve empty access için R14/R15'e bkz.)*

### 24. [RESOLVED] DeviceFeatureExtractor: Empty Logits Access
> **RESOLVED — bkz. R15.** `if (logits.isEmpty) return DeviceClassification('Unknown', 0.0);` guard'ı eklendi (`device_classifier.dart:179`). Detay R15'te.

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

### 26. [RESOLVED] DnsSecurityCard: Empty Benchmark List .last
> **RESOLVED — bkz. R16.** Widget içine `if (sortedBenchmarks.isEmpty) return SizedBox.shrink();` guard'ı eklendi (`.last` çağrısından önce). Detay R16'da.

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

### 33. [RESOLVED] TopologyRepositoryImpl: Regex Parse FormatException
> **RESOLVED — bkz. R17.** `double.parse` → `double.tryParse(timeStr)?.round()` (Satır 95). Ayrıca stdout cast'leri `is String` runtime check'e geçti (Satır 89-90, 174-180). Detay R17'de.

### 34. [LOW] CyberGridBackground: Static ValueNotifier Leak
**Dosya:** `lib/features/security/presentation/widgets/cyber_grid_background.dart`
```dart
30: static final ValueNotifier<double> scrollVelocity = ValueNotifier<double>(0.0);
```
**Analiz:** Statik `ValueNotifier` hiçbir zaman dispose edilmez; uygulama ömrü boyunca bellekte kalır. `AnimatedBuilder` üzerinden eklenen listener'lar da temizlenmez. Crash değil, kalıcı bellek tüketimi.

### 35. [RESOLVED] Singleton Stores: StreamController Not Disposed
> **RESOLVED — bkz. R18.** 3 store'a da `@disposeMethod dispose()` eklendi: `app_settings_store.dart:35-38`, `favorites_store.dart:41-44`, `scan_session_store.dart:54-57`. Detay R18'de.

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

---

## ✅ 2026-05-17 turu: Kod Refactor'ları (R5–R18)

> Bu bölümdeki maddeler önceden bulgu olarak işaretlenmişti, sonra kodda düzeltildi.

### R5. [RESOLVED] AppSettingsStore: @PostConstruct(preResolve: true) async init (eski #1)
**Dosya:** `lib/features/settings/domain/services/app_settings_store.dart`
```dart
17: AppSettingsStore(this._storage) : _settings = const AppSettings();
19: @PostConstruct(preResolve: true)
20: Future<void> init() async {
21:   _settings = await _loadInitialValue(_storage);
22:   _changes.add(_settings);
23: }
```
**Dosya:** `lib/core/di/injection.dart`
```dart
13: Future<void> configureDependencies() async {
14:   await getIt.init();   // <-- await şart: async lazySingletonAsync'ler için
15: }
```
**Analiz:** Constructor artık sadece default `AppSettings()` atıyor; Hive okuma `@PostConstruct(preResolve: true)` async `init()`'e taşındı. `preResolve: true` flag'i kritik — injectable generated config'i `await gh.lazySingletonAsync(() async { final i = AppSettingsStore(...); await i.init(); return i; })` yapar, böylece instance kayıt sırasında tam olarak init olur ve consumer'lar (örn. `_CyberGridBackgroundState.initState`) her zaman ready instance alır. Bayraksız `@postConstruct` ile get_it "not ready yet" StateError fırlatıyordu. Önceki kırılgan pattern eliminate edildi.

### R6. [RESOLVED] SecurityRepositoryImpl: Stream.last → lastOrNull (eski #2)
**Dosya:** `lib/features/security/data/repositories/security_repository_impl.dart`
```dart
  3: import '...stream_extensions.dart';
283: final scanResult = await scanStream.lastOrNull;
312: final portScanResult = await portScanStream.lastOrNull;
465: final scanResult = await scanStream.lastOrNull;
485: final portScanResult = await portScanStream.lastOrNull;
```
**Analiz:** 4 noktanın hepsi `.lastOrNull` extension'ına geçti. Boş stream artık `null` döner, `null` durumu `Either.fold` öncesinde güvenli işleniyor. Önceki `StateError: No element` riski eliminate edildi.

### R7. [RESOLVED] OnnxDeviceClassifierService: Completer ile Race Önleme (eski #4)
**Dosya:** `lib/features/ai/data/services/onnx_device_classifier_service.dart`
```dart
263: Future<OrtSession?> _ensureSession() async {
264:   if (_session != null) return _session;
265:   if (_initFailed) return null;
266:
267:   if (_initCompleter != null) {
268:     await _initCompleter!.future;
269:     return _session;
270:   }
271:
272:   _initCompleter = Completer<void>();
273:   try { ... } catch (_) { ... } finally {
302:     _initCompleter = null;
303:   }
304: }
```
**Analiz:** `Completer<void>? _initCompleter` ile serileştirildi. Eşzamanlı çağrılar varsa ikinci çağrı mevcut completer'ın future'ını await ediyor; tek bir init çalışıyor. `finally` bloğu completer'ı temizliyor. `FileSystemException` riski eliminate edildi.

### R8. [RESOLVED] HeatmapCanvas: Matrix Determinant Guard (eski #5)
**Dosya:** `lib/features/heatmap/presentation/widgets/heatmap_canvas.dart`
```dart
139: // Guard against singular matrix (scale 0 etc)
140: final determinant = matrix.determinant();
141: if (determinant == 0) return;
143: final Matrix4 inverse = Matrix4.inverted(matrix);
```
**Analiz:** `determinant() == 0` kontrolüyle singular matrix erken-return. `Matrix4.inverted` artık yalnızca tersi alınabilir matrix'lerle çağrılıyor; `ArgumentError` riski eliminate.

### R9. [RESOLVED] HiveStorageService: Type-Safe get<T> (eski #7)
**Dosya:** `lib/core/storage/hive_storage_service.dart`
```dart
43: T? get<T>(String key, {T? defaultValue}) {
44:   try {
45:     final value = box.get(key, defaultValue: defaultValue);
46:     if (value == null) return null;
47:     if (value is! T) {
48:       AppLogger.w('Hive type mismatch for key $key: expected $T, got ${value.runtimeType}');
49:       return defaultValue;
50:     }
51:     return value;
52:   } catch (e) {
53:     AppLogger.e('Hive read error for key $key', error: e);
54:     return defaultValue;
55:   }
56: }
```
**Analiz:** Üç katmanlı koruma: (1) try-catch tüm okumayı sarıyor, (2) `is! T` runtime check tip uyuşmazlığını yakalıyor, (3) `defaultValue` fallback. Tüm Hive okuyan store'lar bu güvenli API'den yararlanıyor. `TypeError` riski eliminate.

### R10. [RESOLVED] NetworkInfo: 8 Nokta DI'a Geçti (eski #9)
**Dosya (alan injection):**
```dart
lib/features/security/data/repositories/security_repository_impl.dart:47   final NetworkInfo _networkInfo;  // ctor injected
lib/features/security/domain/usecases/arp_spoofing_detector.dart:10        final NetworkInfo _networkInfo;
lib/features/security/presentation/bloc/security_bloc.dart:33              final NetworkInfo _networkInfo;
lib/features/network_scan/data/datasources/arp_data_source.dart:82         final NetworkInfo _networkInfo;
lib/features/diagnostics/data/repositories/diagnostics_repository_impl.dart:28  final NetworkInfo _networkInfo;
```
**Dosya (getIt servis lookup'ı):**
```dart
lib/features/security/presentation/pages/router_hardening_wizard_page.dart:39  final info = getIt<NetworkInfo>();
lib/features/monitoring/presentation/pages/spectrum_optimization_page.dart:~134  await getIt<NetworkInfo>().getWifiBSSID()
```
**Dosya (widget parametresi):**
```dart
lib/features/monitoring/presentation/widgets/router_admin_guide_card.dart:39  final info = widget.networkInfo;
```
**Analiz:** Önceki 8 manuel `NetworkInfo()` instantiation'ı tamamen kalktı. DI'da tek singleton var, hata sarmalama mümkün. `MissingPluginException` / `PlatformException` yakalanması artık merkezi olarak yapılabilir.

### R11. [RESOLVED] HeatmapCanvas: findRenderObject Safe Type Check (eski #16)
**Dosya:** `lib/features/heatmap/presentation/widgets/heatmap_canvas.dart`
```dart
130: final renderObject = context.findRenderObject();
131: if (renderObject is! RenderBox) return;
132: final Offset localOffset = renderObject.globalToLocal(details.globalPosition);
```
**Analiz:** `as RenderBox` zorlaması yerine `is! RenderBox` early-return. `null` veya farklı RenderObject tipinde sessiz iptal — `TypeError` riski eliminate.

### R12. [RESOLVED] Hive Store Read'leri: is String / whereType (eski #20)
**Dosya:** `lib/features/ai/data/stores/device_label_override_store.dart`
```dart
30: for (final key in box.keys) {
31:   if (key is String && key.startsWith(_prefix)) {
32:     final mac = key.substring(_prefix.length);
33:     final value = box.get(key);
34:     if (value is String) {
35:       result[mac] = value;
36:     }
37:   }
38: }
```
**Dosya:** `lib/features/wifi_scan/data/services/favorites_store.dart`
```dart
46: static Set<String> _load(HiveStorageService storage) {
47:   final raw = storage.get<List<dynamic>>(_key) ?? [];
48:   return raw.whereType<String>().toSet();
49: }
```
**Analiz:** Zorlamalı cast'ler kalktı. `is String` + `whereType<String>()` ile bozuk/karışık verilerde sessiz filtreleme; `TypeError` riski eliminate.

### R13. [RESOLVED] ThemeCubit: try-catch Sarmalı _load (eski #21)
**Dosya:** `lib/core/theme/theme_cubit.dart`
```dart
15: void _load() {
16:   try {
17:     final saved = _storage.get<String>(_key);
18:     final mode = switch (saved) {
19:       'light' => ThemeMode.light,
20:       'dark' => ThemeMode.dark,
21:       _ => ThemeMode.system,
22:     };
23:     emit(mode);
24:   } catch (e) {
25:     // Silently fail and keep default theme if storage is corrupted
26:     emit(ThemeMode.dark);
27:   }
28: }
```
**Analiz:** `LocaleCubit` ile aynı pattern uygulandı. Hive hatası DI ilklendirmesini çökertmez; sessizce `ThemeMode.dark` fallback.

### R14. [RESOLVED] OnnxDeviceClassifierService: Tüm Tensor Release (eski #23 leak kısmı)
**Dosya:** `lib/features/ai/data/services/onnx_device_classifier_service.dart`
```dart
 82: final runOptions = OrtRunOptions();
 83: try {
 84:   final outputs = session.run(runOptions, {'features': inputOrt});
 85:   try {
 86:     if (outputs.isEmpty) return _vendorHeuristic(host);
 87:     final outputTensor = outputs.first;
 88:     if (outputTensor == null) return _vendorHeuristic(host);
 ...
106:   } finally {
107:     for (final tensor in outputs) {
108:       tensor?.release();
109:     }
110:   }
111: } catch (_) {
112:   return _vendorHeuristic(host);
113: } finally {
114:   inputOrt.release();
115:   runOptions.release();
116: }
```
**Analiz:** İç `finally` tüm `outputs` tensor'larını release ediyor (sadece `.first` değil); dış `finally` `inputOrt` + `runOptions`'ı kapatıyor. Exception path'i bile sızdırmıyor. `outputs.isEmpty` ve `outputTensor == null` guard'ları boş çıktıyı yakalıyor. Native memory leak eliminate.

### R15. [RESOLVED] DeviceClassifier: Empty Logits Guard (eski #24)
**Dosya:** `lib/features/ai/domain/services/device_classifier.dart`
```dart
178: static DeviceClassification decodeOutput(List<double> logits) {
179:   if (logits.isEmpty) {
180:     return const DeviceClassification(deviceType: 'Unknown', confidence: 0.0);
181:   }
182:   var maxLogit = logits[0];
```
**Analiz:** `logits.isEmpty` guard'ı `logits[0]` erişiminden önce güvenli default dönüyor. `RangeError` riski eliminate.

### R16. [RESOLVED] DnsSecurityCard: isEmpty Guard (eski #26)
**Dosya:** `lib/features/security/presentation/widgets/dns_security_card.dart`
```dart
// Önce:
final sortedBenchmarks = List<DnsBenchmarkResult>.from(benchmarks)
  ..sort((a, b) => a.latencyMs.compareTo(b.latencyMs));
// Şimdi:
if (sortedBenchmarks.isEmpty) return const SizedBox.shrink();
final maxLatency = sortedBenchmarks.last.latencyMs;
```
**Analiz:** Widget kendini caller'dan bağımsız olarak koruyor. Boş benchmark listesinde sessiz `SizedBox.shrink()` dönüyor; `StateError` riski eliminate.

### R17. [RESOLVED] TopologyRepositoryImpl: tryParse + is String (eski #15, #33)
**Dosya:** `lib/features/monitoring/data/repositories/topology_repository_impl.dart`
```dart
89: final output = result.stdout;
90: if (output is String) {
91:   final match = RegExp(r'time=([\d.]+)').firstMatch(output);
92:   if (match != null) {
93:     final timeStr = match.group(1);
94:     if (timeStr != null) {
95:       final ms = double.tryParse(timeStr)?.round();
...
```
**Analiz:** Üç iyileşme bir arada: (1) `result.stdout as String` zorlaması `if (output is String)` runtime check'e geçti, (2) `match.group(1)` non-null kontrol ediliyor, (3) `double.parse` → `double.tryParse` — geçersiz girdi `null` döner. `TypeError` ve `FormatException` riskleri eliminate.

### R18. [RESOLVED] Singleton Stores: @disposeMethod Eklendi (eski #35)
**Dosya:** `lib/features/settings/domain/services/app_settings_store.dart`
```dart
35: @disposeMethod
36: void dispose() {
37:   _changes.close();
38: }
```
**Dosya:** `lib/features/wifi_scan/data/services/favorites_store.dart`
```dart
41: @disposeMethod
42: void dispose() {
43:   _changes.close();
44: }
```
**Dosya:** `lib/features/wifi_scan/domain/services/scan_session_store.dart`
```dart
54: @disposeMethod
55: void dispose() {
56:   _controller.close();
57: }
```
**Analiz:** 3 store'un hepsi `StreamController` kapatma sözleşmesine sahip. `getIt.reset()` veya uygulama kapanışında temiz teardown garantili.

---

## ✅ 2026-05-18 turu: Kalan Açık Bulgu Fix'leri (R19–R30)

> Önceki turun "Hâlâ açık" listesindeki 10 madde kodda fix'lendi + 3 madde by-design olarak kapatıldı.

### R19. [RESOLVED] _reverseDnsLookup: 3sn Timeout (F1)
**Dosya:** `lib/features/network_scan/data/repositories/network_scan_repository_impl.dart:158-169`
```dart
Future<String> _reverseDnsLookup(String ip) async {
  try {
    final address = InternetAddress(ip);
    // Timeout: yanıtsız DNS sunucusunda tarama stream'inin askıda kalmaması için.
    final result = await address.reverse().timeout(
      const Duration(seconds: 3),
    );
    return result.host != ip ? result.host : '';
  } catch (_) {
    // ArgumentError (invalid IP), TimeoutException, SocketException tümünü yakalar.
    return '';
  }
}
```
**Analiz:** `InternetAddress.reverse()` üzerine `.timeout(3s)` eklendi. Mevcut `catch (_)` blokları `TimeoutException`, `ArgumentError` (invalid IP), `SocketException`'ı zaten yakalıyordu. Yanıtsız DNS sunucusunda tarama stream'i en fazla 3 saniye bekler. Pattern: `dns_test_data_source.dart` ile aynı.

### R20. [RESOLVED] mDNS firstOrNull Guard (F2)
**Dosya:** `lib/features/network_scan/data/repositories/network_scan_repository_impl.dart:93-98`
```dart
// Use mDNS name if hostName is empty
if (hostName.isEmpty) {
  final names = mdnsMap[host.ip];
  if (names != null && names.isNotEmpty) {
    hostName = names.first;
  }
}
```
**Analiz:** `mdnsMap[host.ip]!.first` deseni kaldırıldı. Null/empty kontrolü explicit; mDNS resolver boş liste döndürse bile `.first` `StateError`'ı imkânsız. `containsKey` çağrısı da elimine — tek `[]` lookup yeterli.

### R21. [RESOLVED] LinuxWifiDataSource: utf8 + LANG=C + per-tool errors (F3)
**Dosya:** `lib/features/wifi_scan/data/datasources/linux_wifi_data_source.dart`

**Locale-safe env (Satır 24-31):**
```dart
/// `LANG=C` ile çağrılan subprocess'ler İngilizce/C locale'de çıktı verir;
/// güvenlik anahtarı (`WPA2`/`WPA3`/`WEP`) gibi token'ların lokalize
/// edilmesini engeller. `PATH` ve diğer env değişkenleri korunur.
static final Map<String, String> _cLocaleEnv = {
  'LANG': 'C',
  ...Platform.environment,
};
```

**Per-tool error accumulation (Satır 53-77):**
```dart
Future<List<WifiNetwork>> _scan(ScanRequest request) async {
  final errors = <String>[];
  try {
    return await _scanWithNmcli(request);
  } catch (e) {
    errors.add('nmcli: $e');
  }
  try {
    return await _scanWithIwlist(request);
  } catch (e) {
    errors.add('iwlist: $e');
  }
  throw ScanFailure(
    'Wi-Fi scan failed. Ensure NetworkManager or wireless-tools is '
    'installed and Wi-Fi is enabled.\n${errors.join('\n')}',
  );
}
```

**Process.run çağrılarına encoding + env eklendi** (nmcli rescan, nmcli list, iwlist, iw dev):
```dart
final result = await Process.run(
  'nmcli',
  ['-t', '-f', 'SSID,BSSID,SIGNAL,CHAN,FREQ,SECURITY,BARS',
   'device', 'wifi', 'list'],
  stdoutEncoding: utf8,
  stderrEncoding: utf8,
  environment: _cLocaleEnv,
);
```

**Analiz:** Üç fix bir arada:
1. `stdoutEncoding: utf8` → `result.stdout` garantili `String` (`as String` cast'leri artık güvenli; tip uyumsuzluğu imkânsız).
2. `LANG=C` env → `nmcli` çıktısı her sistemde İngilizce; `_mapNmcliSecurity` hardcoded `WPA2`/`WPA3`/`SAE` token'ları lokalize edilmez.
3. Per-tool error accumulation → kullanıcı/destek hangi aracın hangi exit kodu/stderr ile başarısız olduğunu görür ("nmcli: exit 10: NetworkManager is not running\niwlist: exit 255: Operation not permitted").

### R22. [RESOLVED] ONNX raw Element Type-Safety (F4)
**Dosya:** `lib/features/ai/data/services/onnx_device_classifier_service.dart:93-99`
```dart
if (raw is List<List<double>> && raw.isNotEmpty) {
  logits = raw.first;
} else if (raw is List) {
  // ONNX plugin'i bazen int dönebilir; non-num eleman varsa
  // 0.0 ile doldur — outer fallback yine vendor heuristic'i sağlıyor.
  logits = raw.map((e) => e is num ? e.toDouble() : 0.0).toList();
} else {
  return _vendorHeuristic(host);
}
```
**Analiz:** Önce `(e as num).toDouble()` zorlamasıydı — non-num eleman (string/null/map) `TypeError` fırlatırdı. Şimdi element-wise `is num` check + `0.0` fallback. Outer try-catch yine `_vendorHeuristic` döner; logit boş/bozuksa `decodeOutput` `isEmpty` guard'ı çalışır.

### R23. [RESOLVED] PingStabilizerChannel: is! Map Guard (F5)
**Dosya:** `lib/features/ping_stabilizer/data/datasources/ping_stabilizer_channel.dart:123-127`
```dart
_eventSub ??= _events.receiveBroadcastStream().listen(
  (event) {
    // Native taraf bir Map göndermiyorsa (örn. tip mismatch / protokol drift)
    // sessizce skip — `as Map?` cast'i non-null non-Map'te TypeError fırlatırdı.
    if (event is! Map) return;
    final m = event;
    if (m['stopped'] == true) {
      ...
```
**Analiz:** `(event as Map?) ?? const {}` deseni kaldırıldı. `event` non-null non-Map ise `as Map?` `TypeError` fırlatırdı; `??` fallback sadece null'ı yakalardı. Yeni guard hem null'ı hem yanlış tipi yakalar, sample stream'i `JitterSample.zero` fake data ile kirletmez.

### R24. [RESOLVED] PingStabilizerCubit: Heartbeat Watchdog (F6)
**Dosya:** `lib/features/ping_stabilizer/presentation/bloc/ping_stabilizer_cubit.dart`

**Yeni state alanları (Satır 54-62):**
```dart
/// Watchdog: native tarafın çöktüğünü `tunnelStopped` event'i bize ulaşmadan
/// fark edebilmek için, sample stream'inin sessiz kaldığı süreyi izleriz.
/// Sample'lar normalde ~1 Hz akar; [_silenceThreshold] üst sınırı aşıldığında
/// native tünelin öldüğünü varsayıp [_onNativeStopped] çalıştırırız.
Timer? _healthCheckTimer;
DateTime _lastSampleTime = DateTime.now();
static const Duration _healthCheckInterval = Duration(seconds: 30);
static const Duration _silenceThreshold = Duration(seconds: 35);
```

**startStabilizer içinde Timer kurulumu:**
```dart
_lastSampleTime = DateTime.now();
_healthCheckTimer?.cancel();
_healthCheckTimer = Timer.periodic(_healthCheckInterval, (_) {
  if (isClosed) return;
  final silent = DateTime.now().difference(_lastSampleTime);
  if (silent > _silenceThreshold) {
    AppLogger.w(
      'PingStabilizer: native sample timeout '
      '(${silent.inSeconds}s) — assuming tunnel down',
    );
    _onNativeStopped();
  }
});
```

**_onSample güncellemesi:**
```dart
void _onSample(sample) {
  _lastSampleTime = DateTime.now();
  ...
}
```

**Timer iptali:** `_onNativeStopped`, `stopStabilizer`, `close` üçünde de `_healthCheckTimer?.cancel()`.

**Analiz:** `tunnelStopped` event'i hiç gelmese bile (native crash / EventChannel drop) UI 35 saniye içinde idle'a düşer. 30sn interval + 35sn threshold = en kötü ihtimal ~65sn'lik state desync. AppLogger uyarısı debug için.

### R25. [RESOLVED — already implemented] Android Scan Throttling UI Banner
**Dosya:** `lib/features/wifi_scan/presentation/pages/wifi_scan_page.dart:435-466`
```dart
if (widget.snapshot.isFromCache)
  Container(
    margin: const EdgeInsets.only(bottom: 12),
    ...
    child: Row(children: [
      const Icon(Icons.cached_rounded, size: 16, color: Colors.orange),
      ...
      Text(
        context.l10n.cachedResultsWarning,
        ...
      ),
    ]),
  ),
```
**Localization (l10n):**
```
'Showing cached results — Android limits scan frequency. Wait ~30 s and refresh for live data.'
```
**Datasource flag akışı (`android_wifi_data_source.dart:62-71, 153`):**
```dart
if (canStartScan == CanStartScan.yes) {
  triggeredFreshScan = await _wifiScan.startScan();
}
if (triggeredFreshScan) anyPassTriggeredFreshScan = true;
...
return await _snapshotBuilder.build(
  ...
  isFromCache: !anyPassTriggeredFreshScan,
);
```
**Analiz:** Önceki tur "açık" olarak işaretlemişti ama doğrulamada **tam implement edilmiş** halde bulundu. Datasource → bloc → widget zinciri intact, l10n key tüm dillerde mevcut. Madde yanlış pozitifti.

### R26. [RESOLVED — by design] MonitoringRepositoryImpl: while(true) Cancellation Semantics
**Dosya:** `lib/features/monitoring/data/repositories/monitoring_repository_impl.dart:21-40`
```dart
@override
Stream<Either<Failure, List<WifiNetwork>>> monitorNetworks({
  Duration interval = const Duration(seconds: 5),
}) async* {
  var consecutiveErrors = 0;
  while (true) {
    final result = await _wifiRepository.scanNetworks();
    ...
    await Future<void>.delayed(...);
  }
}
```
**Analiz:** Dart async-generator (`Stream<T> async*`) semantiği gereği subscription cancel olduğunda runtime, generator'ı suspend ettiği `await` noktasında durdurur. `MonitoringBloc.close()` `_networkSubscription?.cancel()` çağırır → generator otomatik biter. Diğer tüketiciler de subscription cancel ettiği sürece "infinite loop" risk değil. Önceki rapor teorik kaygıydı; pratikte by-design çalışıyor. Kod değişikliği gereksiz.

### R27. [RESOLVED] main.dart: SecureStorage Ephemeral Fallback (F9)
**Dosya:** `lib/main.dart:47-69`
```dart
const secureStorage = FlutterSecureStorage(
  iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
);
List<int> hiveKey;
try {
  hiveKey = await const SecureStorageService(
    secureStorage,
  ).getOrCreateHiveBoxKey();
} catch (e, stack) {
  // Keystore tamamen başarısız olursa (örn. Android keychain bozulması,
  // iOS Keychain access denied) uygulamayı çökertmek yerine ephemeral
  // (session-only) anahtarla devam et. Önceki session verisi okunamaz
  // ama uygulama açılır ve kullanıcı yeniden yapılandırabilir.
  AppLogger.e(
    'SecureStorage init failed — using ephemeral Hive key '
    '(previous session data will be unreadable)',
    error: e,
    stackTrace: stack,
  );
  final rng = Random.secure();
  hiveKey = List<int>.generate(32, (_) => rng.nextInt(256));
}
await HiveStorageService.init(hiveKey);
```
**Analiz:** Keychain çağrısı try-catch'e alındı; başarısız olursa `Random.secure()` ile 32-byte AES key üretilir. Önceki session verisi okunamaz (HiveStorageService.init'in mevcut "cipher mismatch → delete & recreate" path'i devreye girer) ama uygulama açılır. Önceki davranış: `PlatformException` runZonedGuarded'a düşer, app crash.

### R28. [RESOLVED] HiveStorageService: Box Getter Defensive Guard (F10) + HeatmapPage Cast Check (F8)

**F10 — HiveStorageService.box (Satır 35-46):**
```dart
Box get box {
  if (!Hive.isBoxOpen(_defaultBoxName)) {
    throw StateError(
      'HiveStorageService.init() not called before accessing storage. '
      'Bootstrap order: SecureStorage → HiveStorageService.init → '
      'configureDependencies.',
    );
  }
  return Hive.box(_defaultBoxName);
}
```

**F8 — heatmap_page.dart:_handleShare (Satır 513-527):**
```dart
final renderObject = _boundaryKey.currentContext?.findRenderObject();
if (renderObject is! RenderRepaintBoundary) {
  if (renderObject != null) {
    AppLogger.w(
      'Heatmap share: expected RenderRepaintBoundary, '
      'got ${renderObject.runtimeType}',
    );
  }
  return;
}
final boundary = renderObject;
```

**Analiz:** İki defansif iyileştirme bir arada:
- HiveStorage: `BoxNotFound` opaque hatası yerine bootstrap sıralaması açıklayan `StateError`. Production'da hiç tetiklenmemeli; test/refactor regression'larında erken sinyal verir.
- HeatmapPage: `as RenderRepaintBoundary?` cast'i kalktı; `is!` ile tip kontrolü + diagnostic log. Tree yapısı değişirse `CastError` yerine açıklayıcı warning.

### R29. [RESOLVED — by design] CyberGridBackground Static ValueNotifier
**Dosya:** `lib/features/security/presentation/widgets/cyber_grid_background.dart:30-32`
```dart
class _CyberGridBackgroundState extends State<CyberGridBackground> {
  static final ValueNotifier<double> scrollVelocity = ValueNotifier<double>(
    0.0,
  );
```
**Tüketici örneği (`classic_grid_background.dart:82-90`):**
```dart
animation: Listenable.merge([_controller, widget.scrollVelocity]),
builder: (context, child) {
  _smoothedVelocity =
      _smoothedVelocity * 0.9 +
      (widget.scrollVelocity.value / 2.0).clamp(0.0, 500.0) * 0.1;
  widget.scrollVelocity.value *= 0.95;
```
**Analiz:** Static ValueNotifier 7 farklı `_*Background` widget'ı tarafından `Listenable.merge` ile dinleniyor (`classic_grid`, `aegis_shield`, `signal_topography`, `holo_sphere`, `aurora_mesh`, `quantum_mesh`, `neural_pulse`). `main.dart` `NotificationListener<ScrollNotification>` global scroll velocity'sini bu notifier'a yazıyor; her arka plan widget'ı kendi smoothing'iyle kullanıyor. Dispose edilirse animasyonlar bozulur. App-lifetime tek singleton (8 byte payload + listener listesi) — gerçek leak değil, **bilinçli tasarım**. Kod değişikliği zararlı olur.

### R30. [RESOLVED] HeatmapCanvas: Centre + Color Cache (F7)
**Dosya:** `lib/features/heatmap/presentation/widgets/heatmap_canvas.dart:367-422`
```dart
void _drawHeatmap(Canvas canvas, List<HeatmapPoint> points) {
  if (points.isEmpty) return;
  final heatmapRadius = (viewport.scale * 1.8).clamp(28.0, 72.0);

  // Tek geçişte centre + signalColor hesapla — ikinci loop'ta tekrar
  // hesaplamamak için cache'le. Paint sıralaması korunmalı: tüm bloom'lar
  // önce, center dot'lar üzerine.
  final centres = <Offset>[];
  final signalColors = <Color>[];
  for (final point in points) {
    centres.add(viewport.worldToCanvas(Offset(point.floorX, point.floorY)));
    signalColors.add(_signalColor(point.rssi));
  }

  for (var i = 0; i < points.length; i++) {
    final centre = centres[i];
    final signalColor = signalColors[i];
    // Core + Bloom (drawCircle calls)
    ...
  }

  // Center dot'lar tüm bloom'ların üstüne — ayrı geçiş bu sıralamayı garanti
  // eder (merge edilirse A'nın dot'u B'nin bloom'unun altında kalabilir).
  final dotPaint = Paint()
    ..color = theme.colorScheme.onSurface.withValues(alpha: 0.8)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);
  for (final centre in centres) {
    canvas.drawCircle(centre, 2.4, dotPaint);
  }
}
```
**Analiz:** Önceki halde `worldToCanvas` ve `_signalColor` her loop'ta tekrar hesaplanıyordu; ikinci loop bunu tekrar yapıyordu (2x). Şimdi tek geçişte cache'lenip iki kez tüketiliyor; `dotPaint` da loop dışında bir kez oluşturulup tüm dot'larda yeniden kullanılıyor. N nokta için worldToCanvas çağrısı 2N → N, Paint allocation N → 1. Görsel çıktı bit-identical (paint sıralaması korunuyor: bloom'lar önce, center dot'lar üzerine).

**Önceki RepaintBoundary mitigasyonu (#6) ile birlikte:** Re-paint sıklığı zaten elimine; ilk paint maliyeti de bu cache ile azaldı. 500+ noktada akıcı; 1000+ için ileride `PictureRecorder`/`toImage` değerlendirilebilir.
