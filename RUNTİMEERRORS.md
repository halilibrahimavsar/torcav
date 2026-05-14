# Torcav Runtime Error Analysis Report

Bu dosya, projedeki olası çalışma zamanı (runtime) hatalarını, zayıf noktaları ve kilitlenme (crash) risklerini feature bazlı olarak takip etmek için oluşturulmuştur.

---

## 🏗️ Core & Bootstrap (Başlangıç ve Altyapı)
*   **[LOW] Hive Box Race Condition:** `HiveStorageService.box` getter'ı, `init` metodu tamamlanmadan çağrılırsa `HiveError` (Box not open) fırlatır.
*   **[MEDIUM] Hive Type Mismatch:** `HiveStorageService.get<T>` metodunda `as T?` cast işlemi yapılıyor. Kaydedilen veri tipi ile istenen tip uyuşmazsa `TypeError` oluşur.
*   **[LOW] Secure Storage Initialization:** `main.dart` içerisinde `SecureStorageService` doğrudan (DI dışı) ilklendiriliyor. Android keychain sorunlarında bu aşama uygulamayı kilitlenebilir.
*   **[MEDIUM] DI Registration Failure:** `configureDependencies()` içinde bir servis kaydı başarısız olursa veya `getIt<T>` ile erişilen bir servis henüz kayıt edilmemişse `StateError` fırlatılır.

## 🛡️ Security (Güvenlik)
*   **[HIGH] Stream.last Exception:** `SecurityRepositoryImpl` içerisinde `scanStream.last` ve `portScanStream.last` (Satır 281, 309, 462, 481) kullanılıyor. Eğer stream hiç veri yaymadan kapanırsa `StateError: No element` hatası alınır ve uygulama kilitlenir.
*   **[MEDIUM] NetworkInfo Plugin Errors:** `NetworkInfo` sınıfı repository içinde manuel `new` ediliyor (Satır 46). Platform bazlı plugin hataları (MissingPluginException) veya izin eksiklikleri burada yakalanmıyor.
*   **[LOW] IP String Parsing:** `ip.substring(0, ip.lastIndexOf('.'))` (Satır 277, 305) kullanımı, IP formatı beklenmedik bir değer dönerse `RangeError` fırlatabilir.
*   **[MEDIUM] Captive Portal Detection:** `_captivePortalDetector.check()` (Satır 398) network timeout durumlarını düzgün yönetemezse asenkron kilitlenmeye (infinite await) yol açabilir.

## 🌐 Network & WiFi Scan (Ağ Tarama)
*   **[MEDIUM] Command Dependency (Linux):** `LinuxWifiDataSource`, `nmcli`, `iwlist` veya `iw` komutlarının sistemde kurulu olmasına bağımlıdır. Herhangi biri eksikse `ScanFailure` fırlatılır; ancak bu hata UI tarafında düzgün yakalanmazsa "Infinite Loading" veya kilitlenmeye sebep olabilir.
*   **[MEDIUM] Process Output Casting:** `result.stdout as String` (Linux Satır 94) kullanımı, eğer süreç beklenmedik bir çıktı (binary veya null) üretirse `TypeError` fırlatır.
*   **[LOW] nmcli Parsing Logic:** `_splitNmcli` (Linux Satır 153) SSID içinde kaçış karakteri olan `:` bulunması durumunda karmaşık bir mantık yürütüyor. Beklenmedik bir çıktı formatı gelirse (örneğin farklı bir locale), parsing kilitlenebilir.
*   **[HIGH] Invalid IP in Reverse DNS:** `InternetAddress(ip)` (NetworkScan Satır 160) geçersiz bir IP stringi ile çağrılırsa `ArgumentError` fırlatır. Mevcut kodda try-catch var ancak `NetworkScanRepositoryImpl` içindeki genel catch (Satır 153) tüm scan işlemini sonlandırabilir.
*   **[MEDIUM] Android Throttling:** Android 9+ cihazlarda 2 dakikada 4 kez tarama sınırı vardır. Kod bu sınırı aşmaya çalışırsa (Satır 65) `startScan()` false döner. Bu bir hata değil platform kısıtlamasıdır ancak UI'da "yeni tarama yapılamadı" uyarısı verilmezse kullanıcı verinin güncelliğinden şüphe edebilir.
*   **[MEDIUM] Native Type Casting:** `AndroidWifiDataSource` (Satır 110, 123 vb.) method channel'dan gelen verileri `as int?` veya `as String?` şeklinde cast ediyor. Native (Kotlin) tarafta bir tip değişikliği olursa runtime crash kaçınılmazdır.

## 🤖 AI Features (Yapay Zeka)
*   **[MEDIUM] Session Run Memory Leak:** `OnnxDeviceClassifierService._classifyFeatures` (Satır 81) içinde `session.run` başarılı olduktan sonra bir exception oluşursa, `outputs` listesi içindeki tensorlar `release()` edilemez. Native memory leak oluşur.
*   **[MEDIUM] Unsafe Logit Casting:** `raw.cast<double>()` (Satır 94) kullanımı, model çıktısında bir tane bile tam sayı (int) dönerse `TypeError` fırlatır. ONNX plugin'i bazen float değerleri int olarak döndürebilir.
*   **[HIGH] Model Loading Race Condition:** `_ensureSession` (Satır 254) metodu senkronizasyon (lock/mutex) mekanizmasına sahip değil. `classifyBatch` içinde birden fazla asenkron çağrı aynı anda temp dosyasına yazmaya çalışabilir, bu da `FileSystemException` (File locked) veya bozuk model yüklemesine yol açar.
*   **[LOW] Softmax Division by Zero:** `DeviceFeatureExtractor.decodeOutput` (Satır 191) içinde `sumExp` 0 olursa division by zero oluşur. Logit'ler çok küçük veya boşsa bu risk vardır.

## 📊 Monitoring & Performance (İzleme ve Performans)
*   **[MEDIUM] Infinite Generator Leak:** `MonitoringRepositoryImpl.monitorNetworks` (Satır 23) `while(true)` döngüsü içeriyor. Eğer bu stream'i dinleyen BLoC kapatılmazsa (dispose), arka planda tarama işlemi sonsuza kadar devam eder ve batarya tüketimine/kaynak sızıntısına yol açar.
*   **[LOW] Backoff Delay Precision:** `Future.delayed` kullanımı işletim sistemi tarafından bazen optimize edilebilir. Çok hassas zamanlama gerektiren monitoring durumlarında kaymalara sebep olabilir.

## 📱 UI & App Shell (Arayüz ve Navigasyon)
*   **[HIGH] Localization Extension Crash:** `_NeonErrorWidget` (main.dart Satır 82) `context.l10n` kullanıyor. Eğer hata `MaterialApp` düzgünce kurulmadan (örneğin DI aşamasında) oluşursa, `AppLocalizations` bulunamaz ve `NullCheckError` ile uygulama tamamen çöker (white screen).
*   **[CRITICAL] DI Initialization Crash:** `AppSettingsStore` (Satır 17) constructor'ı içinde `_loadInitialValue` çağırıyor ve bu da `HiveStorageService.get` kullanıyor. Eğer Hive box'ı henüz açılmamışsa, uygulama daha `runApp` aşamasına gelmeden DI hatasıyla çöker.
*   **[MEDIUM] Shader Performance Crash:** `CyberGridBackground` içinde kullanılan karmaşık shader bazlı arka planlar (Aurora, Quantum vb.), düşük donanımlı Android cihazlarda GPU belleğini tüketerek "Out of Memory" crash'lerine veya ANR (App Not Responding) hatalarına sebep olabilir.
*   **[LOW] ValueNotifier Leak:** `CyberGridBackground` içindeki `static scrollVelocity` (Satır 30) hiçbir zaman dispose edilmez. Statik olduğu için uygulama ömrü boyunca bellekte kalır.

## 🛰️ VPN & Ping Stabilizer
*   **[HIGH] EventChannel TypeError:** `PingStabilizerChannel._ensureListening` (Satır 124) içinde `event as Map?` cast işlemi yapılıyor. Native taraf yanlışlıkla farklı bir tip dönerse uygulama runtime crash alır.
*   **[MEDIUM] VPN State Desync:** Native VPN servisi (VpnService) Android tarafından sistem kaynakları için durdurulursa, Dart tarafındaki BLoC/Cubit'in haberi olmayabilir (e-mail channel gelmezse). Bu durum UI'da "Bağlı" görünüp aslında tünelin kapalı olmasına yol açar.

## 🗺️ Heatmap & AR
*   **[HIGH] Matrix Inversion Error:** `HeatmapCanvas` (Satır 136) içinde `Matrix4.inverted(matrix)` kullanılıyor. Eğer zoom/scale değeri 0 olursa (singular matrix), bu metod bir `ArgumentError` fırlatır ve kilitlenmeye sebep olur.
*   **[HIGH] Painting Performance (OOM Risk):** `_StaticHeatmapPainter._drawHeatmap` (Satır 367) her bir nokta için birden fazla blur ve gradient içeren daire çiziyor. Binlerce nokta içeren uzun survey'lerde GPU overload ve kilitlenme riski yüksektir.
*   **[MEDIUM] GlobalToLocal Race Condition:** Tap işlemleri sırasında `findRenderObject() as RenderBox` (Satır 130) kullanılıyor. Eğer widget o anda ağaçtan çıkıyorsa `null` dönebilir veya geçersiz bir koordinat hesaplayabilir.

---

## 🛠️ Genel Tespitler (Mimari & Pattern)
*   **Null Safety:** Dart 3.x kurallarına uyum.
*   **Error Handling:** `Either<Failure, T>` kullanımı ve eksik `fold` durumları.
*   **DI (GetIt):** Kayıtlı olmayan bağımlılıklara erişim riskleri.
*   **Background Tasks:** Arka plan işlemlerinde olası sızıntılar (leak).
