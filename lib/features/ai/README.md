# AI Feature

On-device machine learning layer for classifying LAN hosts using an ONNX device classifier.

## Bu Feature Ne İşe Yarıyor?

`ai` feature, ağ taraması sırasında keşfedilen cihazların türünü (router, akıllı TV, kamera, yazıcı, NAS, IoT sensör vb.) **tamamen cihaz üzerinde** çalışan bir sinir ağı ile sınıflandırır. Hiçbir veri dış servise gönderilmez; sınıflandırma `assets/models/device_classifier.onnx` içine gömülü model dosyası ile `onnxruntime` üzerinden çalıştırılır.

Amaç: kullanıcıya ağındaki her cihazın *ne olduğuna* dair etiket üretmek ve bu etiketlerle Dashboard, Reports ve Security feature'larının daha anlamlı içgörü üretmesini sağlamak.

## Yaptıkları Neler?

1. **Feature extraction** (`DeviceFeatureExtractor`):
   - 160 boyutlu sabit uzunlukta özellik vektörü üretir.
   - `[0..63]`: 64 izlenen TCP/UDP portundan hangilerinin açık olduğu (port bitmap).
   - `[64..95]`: MAC vendor adının 32-boyutlu MD5 tabanlı hash'i (multi-hot).
   - `[96..127]`: hostname trigramlarının 32-boyutlu hash'i.
   - `[128..159]`: servis adı (BoW) hash'i.
   - Python eğitim boru hattı ile birebir aynı MD5 tabanlı hash fonksiyonunu kullanır — bağımlılık azaltmak için `crypto` paketi yerine RFC 1321 MD5 elle implemente edilmiştir.
2. **Inference** (`OnnxDeviceClassifierService`):
   - ONNX modelini asset'ten bir kerelik temp dosyasına kopyalar.
   - `lazySingleton` olarak yüklenir, ilk çağrıda başlatılır, aynı session tekrar kullanılır.
   - `classify(host)` tek host, `classifyBatch(hosts)` toplu çalıştırma sağlar.
   - Başlatma başarısız olursa `_initFailed` bayrağı ile sessizce devre dışı kalır — UI akışı bozulmaz.
3. **Output decoding**: Softmax ile logitleri olasılığa çevirir, en yüksek olasılıklı `deviceCategories` etiketini ve `confidence` değerini döner.

### 15 cihaz kategorisi
`Router/Gateway`, `Access Point`, `Desktop`, `Laptop`, `Mobile Device`, `Tablet`, `Smart TV`, `IoT Sensor`, `Printer`, `NAS/Storage`, `Game Console`, `IP Camera`, `Smart Speaker`, `Server`, `Unknown`.

## Hangi Özellik Eksik?

- **Eğitim/versiyonlama belgesi yok**: modelin hangi veri setiyle, hangi metriklerle eğitildiği dokümante edilmemiş. Kartelize bir *model card* eklenmeli.
- **Kalibrasyon yok**: `confidence` değeri ham softmax; gerçek olasılık olarak yorumlanması için sıcaklık (temperature) kalibrasyonu yapılmalı.
- **Feature importance / explainability yok**: "Neden bu cihazı IP Kamera olarak etiketledin?" sorusuna cevap üretilmiyor (SHAP, feature-contribution).
- **Offline-only**: kullanıcı opsiyonel olarak yeni veri ile modeli güncelleyemiyor — federated/on-device fine-tune yolu yok.
- **Düşük güvende fallback yok**: `confidence < eşik` olduğunda `Unknown` yerine heuristik (vendor OUI tablosu, mDNS servis adı) tabanlı kural motoruna düşülmeli.
- **Telemetri/metrik yok**: yanlış sınıflandırmaların kullanıcı tarafından düzeltilmesi ve bu düzeltmelerin toplanması için mekanizma yok.
- **Threading**: `classifyBatch` sıralı çalışır; büyük ağlarda UI iplikini tıkayabilir, isolate'a taşınmalı.
- **Model imzalaması / bütünlük kontrolü**: asset dosyası hash doğrulaması yapılmadan yükleniyor; MITM veya kasıtlı değiştirilme kontrolü yok.

## Etik / Legal Olarak Neler Eklenebilir?

- **Kullanıcı bilgilendirmesi (informed consent)**: ilk taramadan önce "cihazınız üzerindeki bir model MAC vendor, hostname ve açık portları kullanarak cihazınızı sınıflandırır. Veri cihaz dışına çıkmaz." şeklinde açık bir onay diyaloğu.
- **Veri minimizasyonu notu**: README ve uygulama içinde modelin **yalnızca public/observable** veri kullandığı (hostname, MAC OUI, açık port) yazılmalı — payload içeriği, DPI veya credential okunmuyor.
- **"Kendi ağın değilse kullanma" uyarısı**: sınıflandırma sonuçları kişisel veri içerebilir (örn. "Ahmet'in iPhone'u" hostname'i). Komşu ağları tarayıp bu sonuçları dışa aktarmak GDPR/KVKK kapsamında sorun yaratabilir.
- **Model bias belgesi**: `deviceCategories` listesinin Batı pazarına yatkın olması muhtemel; Türk üretici OUI'leri, yerel IoT markaları test edilip belgelenmeli.
- **Right to correct**: kullanıcıya "bu cihaz aslında X" demesi için düzeltme UI'ı eklenmeli; bu düzeltmeler cihazda kalır, uzağa gönderilmez.
- **Log retention**: sınıflandırma sonuçlarının saklanma süresi ve silme mekanizması net olmalı (bkz. `core/logging`).
- **Lisans netliği**: ONNX model dosyasının hangi lisansla dağıtıldığı (MIT, Apache, CC-BY, kendi lisansı?) `assets/models/LICENSE` olarak yer almalı.

## Hangi Sorunları Çözüyor?

- **Manuel etiketleme yükü**: kullanıcı 40+ cihazlık bir ev/ofis ağında hangi IP'nin ne olduğunu tek tek bilmek zorunda kalmıyor.
- **Güvenlik tetikleyicileri için bağlam**: "açık port 23 (telnet)" uyarısı bir *router* üzerinde kritik, bir *akıllı TV* üzerinde farklı risk; kategori, risk skorunu zenginleştirir.
- **Offline çalışma**: bulut tabanlı cihaz tanıma API'lerine (Fingerbank vb.) bağımlılık yok, gizlilik korunuyor.
- **Kıyaslanabilirlik**: ağdaki cihaz karışımını zaman içinde karşılaştırmayı (envanter değişimi, yabancı cihaz tespiti) mümkün kılıyor.
- **Rapor kalitesi**: Reports feature'ının ürettiği PDF çıktısının insan-okunabilir olmasını sağlıyor ("192.168.1.44 — IP Kamera (%87)") yerine ham MAC listesi yerine.
