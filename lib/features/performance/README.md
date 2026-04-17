# Performance (Speed Test) Feature

HTTP tabanlı hız ölçümü: latency, jitter, download, upload ve "loaded latency" (buffer bloat).

## Bu Feature Ne İşe Yarıyor?

`performance` feature, kullanıcının internet bağlantısının **hızını ve kalitesini** ölçer. Speedtest.net / Fast.com benzerleriyle aynı ruhtadır ama Cloudflare'ın açık `speed.cloudflare.com` endpoint'lerini kullanır. Sonuçlar tarihçeye yazılır, Reports feature'ına beslenir.

Amaç: "yavaş internet" şikayetini ispata dönüştürmek ve sağlayıcı (ISP) ile pazarlık için zaman serisi delil üretmek.

## Yaptıkları Neler?

### Domain

- **SpeedTestProgress** entity: canlı ilerleme (phase, latency, jitter, packetLoss, downloadMbps, uploadMbps, loadedLatencyMs).
- **SpeedTestResult** entity: nihai snapshot (DB'ye kaydedilir).
- **SpeedTestPhase** enum: `latency` → `download` → `upload` → `done`.
- **RunSpeedTestUsecase**: Bloc'un tetiklediği ana giriş.

### Data

- **SpeedTestRepositoryImpl** (322 satır):
  - Saf `dart:io HttpClient` tabanlı, 3. parti SDK yok.
  - **Latency**: 1 warmup + 7 timed ping → ortalama + jitter.
  - **Download**: 20 MB chunk'ları 10 saniye boyunca tekrar tekrar çek.
  - **Upload**: 2 MB chunk'ları 10 saniye boyunca gönder.
  - **Loaded latency**: download sırasında paralel ping ile bufferbloat ölçer.
  - Toplam süre ≈ 21-22 saniye (bağlantı hızından bağımsız zamana dayalı).
- **SpeedTestHistoryRepositoryImpl**: SQLite tablosu ile geçmiş sonuçlar.

### Presentation

- **PerformanceBloc**: `runSpeedTest()` stream'ini dinler, state transition'lar.
- **PerformancePage** (761 satır): büyük gauge + aşama göstergesi + tarihçe.
- **SpeedometerArc** (430 satır): custom painter ile glow'lu hızölçer arcı, animasyonlu ibre.

## Hangi Özellik Eksik?

- **Server-side seçimi yok**: her zaman Cloudflare `speed.cloudflare.com` — bazı ISP'ler peering nedeniyle farklı sonuç gösterebilir; Netflix Fast, M-Lab, Ookla seçeneği opsiyonel olabilir.
- **IPv4/IPv6 split**: hangi stack ile ölçüm yapıldığı gösterilmiyor; ikisi ayrı ayrı ölçülmüyor.
- **Sabit test süresi**: 10+10 sn download/upload çok yavaş (1 Mbps) bağlantıda yetersiz; adaptif süre yok.
- **DNS çözümleme zamanı ayrı ölçülmüyor**: latency'nin ne kadarı DNS, ne kadarı TCP handshake, ne kadarı TLS — ayrışmıyor.
- **Parallel connection**: tek connection kullanılıyor; çok hızlı bağlantılarda (gigabit) throughput tavanına çarpar — eş zamanlı çoklu stream gerek.
- **Bufferbloat skoru (A-F)**: loadedLatencyMs hesaplanıyor ama Waveform standardı (A/B/C/D/F) gibi insan-okunabilir skor yok.
- **Ağa göre gruplama**: her SSID için ayrı tarihçe/ortalama yok (ofis vs ev kıyaslama).
- **Scheduled tests**: periyodik otomatik test (örn. her gün 20:00) yok.
- **Veri kullanım uyarısı**: mobil veri üzerinde ~400-500 MB tüketir (gigabit bağlantıda); kullanıcı uyarılmıyor.
- **Cancellation zayıf**: test başladıktan sonra iptal edip partial sonuçları kaydetme UX'i net değil.
- **Accuracy claim**: Cloudflare'a en yakın PoP'a gidiyor; "gerçek ISP hızı" iddiasının limitleri belgelenmeli.

## Etik / Legal Olarak Neler Eklenebilir?

- **Veri tüketim uyarısı**: testin yaklaşık 300-500 MB veri kullanacağı uyarısı mobil bağlantıda ZORUNLU olmalı (tüketici hakları — yanıltıcı hizmet sayılmaması için).
- **Sonuç net ölçüm değil bilgisi**: "bu değer ISS sözleşmenizdeki üst hız ile birebir karşılaştırılabilir değildir; Wi-Fi, cihaz performansı, Cloudflare PoP mesafesi etkiler" feragati sonuç ekranında.
- **Third-party data flow**: `speed.cloudflare.com` hedefine bağlanıldığı ve Cloudflare'ın IP'yi log'layabileceği gizlilik sayfasında belirtilmeli.
- **Tarihçe silme butonu**: `SpeedTestHistoryRepository`'nin `clear()` metoduna Settings'ten erişim (GDPR/KVKK data subject right).
- **Benchmark olarak resmi kabul edilmemesi**: ISS'e şikayet veya hukuki delil üretmek için kullanıcı, test yöntemi ve referans ölçümü (örn. cablolu test) birlikte belgelemesi gerektiği konusunda bilgilendirilmeli.
- **Bant genişliği politikası**: kullanıcı mobil veri paketinde sınırlıysa, "WiFi'de çalıştır" önerisi aktif olmalı.
- **Erişilebilirlik**: sesli okuma (screen reader) ile hızölçer ibresi yerine "downloadMbps: X" açık metin aktarımı.

## Hangi Sorunları Çözüyor?

- **Objektif ölçüm**: "internetim yavaş" → sayısal veri.
- **Trend**: tarihçe ile günün saatine göre değişimi görünür kılmak.
- **Bufferbloat awareness**: sadece peak throughput değil, "yüklüyken gecikme" de ölçülüyor — oyun/video konferans kalitesine dair bilgi.
- **Ücretsiz ve reklamsız**: Speedtest.net uygulamasındaki reklam/kayıt gereksinimi yok.
- **Reports entegrasyonu**: tarihçe PDF raporunda zaman serisi grafiği olarak kullanılıyor.
- **ISP pazarlık gücü**: "sözleşmemde 100 Mbps var ama 7 gün boyunca ortalama 28 Mbps ölçtüm" gibi kanıtlı veriye yaslanan destek talepleri.
