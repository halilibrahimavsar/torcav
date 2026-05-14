# Torcav Runtime Error Evidence & Proof (Kanıtlar)

Bu dosya, `RUNTİMEERRORS.md` raporundaki iddiaların teknik kanıtlarını ve kod referanslarını içerir.

---

### 1. [HIGH] SecurityRepositoryImpl: Stream.last Exception
**Hata:** Boş bir stream üzerinde `.last` operatörü çağrıldığında `StateError` fırlatılması.
**Dosya:** `lib/features/security/data/repositories/security_repository_impl.dart`
**Kod Parçası:**
```dart
280: final scanStream = _networkScanRepository.scanNetwork(subnet);
281: final scanResult = await scanStream.last; // <--- RISK
...
306: final portScanStream = _networkScanRepository.scanWithProfile(gatewayIp);
309: final portScanResult = await portScanStream.last; // <--- RISK
```
**Analiz:** Eğer ağ taraması (Network Scan) herhangi bir sebeple sonuç üretmeden kapanırsa (empty stream), Dart `StateError: No element` fırlatacaktır. Bu durum "Deep Scan" sırasında tüm güvenlik analizinin yarıda kesilmesine sebep olur. `last` yerine `fold` veya `toList` kullanılıp boşluk kontrolü yapılmalıdır.

---

### 2. [CRITICAL] AppSettingsStore: DI Initialization Crash
**Hata:** Hive box'ı açılmadan (init tamamlanmadan) storage erişimi yapılması.
**Dosya:** `lib/features/settings/domain/services/app_settings_store.dart`
**Kod Parçası:**
```dart
17: AppSettingsStore(this._storage) : _settings = _loadInitialValue(_storage);
...
30: final raw = storage.get<String>(_settingsKey); // <--- BOOM!
```
**Dosya (Altyapı):** `lib/core/storage/hive_storage_service.dart`
```dart
35: Box get box => Hive.box(_defaultBoxName);
43: T? get<T>(String key, {T? defaultValue}) {
44:   return box.get(key, defaultValue: defaultValue) as T?;
45: }
```
**Analiz:** `AppSettingsStore` bir `@lazySingleton`'dır. Eğer uygulama başlangıcında (örneğin UI'da bir tema ayarı okurken) bu servise erişilirse ve `HiveStorageService.init` henüz bitmemişse, `Hive.box()` fırlatacağı "Box not open" hatasıyla uygulamayı henüz `runApp` aşamasına gelmeden çökertecektir. Constructor içinde senkron storage okuması yapmak tehlikelidir.

---

### 3. [HIGH] _NeonErrorWidget: Localization Extension Crash
**Hata:** Localizasyon altyapısı kurulmadan hata ekranında `context.l10n` kullanımı.
**Dosya:** `lib/main.dart`
**Kod Parçası:**
```dart
42: ErrorWidget.builder = (details) => _NeonErrorWidget(details: details);
...
82: Text(context.l10n.renderingErrorTitle, ...) // <--- NULL CHECK ERROR
```
**Analiz:** `ErrorWidget.builder`, Flutter bir render hatası aldığında çağrılır. Eğer hata `MaterialApp` widget'ı ağaca eklenmeden (örneğin DI veya Bootstrap aşamasında) oluşursa, `context` içinde `AppLocalizations` bulunamaz. Bu durumda `context.l10n` (ki bu bir extension'dır ve `AppLocalizations.of(context)!` yapar) `null` döndüğü için uygulama "Null check operator used on a null value" hatasıyla crash loop'a girer. Hata ekranında ham string veya fallback mekanizması kullanılmalıdır.

---

### 4. [HIGH] OnnxDeviceClassifierService: Model Loading Race Condition
**Hata:** Aynı anda birden fazla model yükleme denemesinin dosya sisteminde kilitlenmeye yol açması.
**Dosya:** `lib/features/ai/data/services/onnx_device_classifier_service.dart`
**Kod Parçası:**
```dart
254: Future<OrtSession?> _ensureSession() async {
255:   if (_session != null) return _session;
...
267:   await modelFile.writeAsBytes(modelBytes.buffer.asUint8List(), flush: true);
273:   _session = OrtSession.fromFile(modelFile, sessionOptions);
```
**Analiz:** `_ensureSession` metodunda hiçbir "locking" (kilit) mekanizması yok. Eğer iki farklı cihaz sınıflandırması aynı anda başlarsa, ikisi de aynı `modelFile` yoluna yazmaya çalışacaktır. Biri dosyayı yazarken diğeri açmaya çalışırsa `FileSystemException` fırlatılır ve AI modülü devre dışı kalır. Bir `Completer` veya mutex kullanılmalıdır.

---

### 5. [HIGH] HeatmapCanvas: Matrix Inversion & OOM Risk
**Hata:** Singular matrix inversion ve aşırı çizim yükü.
**Dosya:** `lib/features/heatmap/presentation/widgets/heatmap_canvas.dart`
**Kod Parçası (Inversion):**
```dart
136: final Matrix4 inverse = Matrix4.inverted(matrix); // <--- ARGUMENTERROR
```
**Kod Parçası (Performance):**
```dart
367: for (final point in points) {
377:   ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
385:   ..shader = ui.Gradient.radial(...)
395: }
```
**Analiz:**
1. Zoom seviyesi bir şekilde sıfıra yaklaşırsa `Matrix4.inverted` hata fırlatır. `tryInvert` kullanılmalıdır.
2. `_drawHeatmap` içinde her nokta için bir `MaskFilter.blur` ve bir `RadialGradient` oluşturuluyor. 500+ nokta içeren bir haritada bu, her frame'de binlerce pahalı GPU operasyonu demektir. Düşük donanımlı cihazlarda bellek yetersizliği (OOM) veya "Frame Hang" (ANR) riskini doğurur. Nokta sayısı arttıkça "downsampling" veya "image caching" yapılmalıdır.
