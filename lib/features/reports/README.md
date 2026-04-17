# Reports Feature

Tarama sonuçlarını JSON / CSV / HTML / PDF formatında paylaşılabilir rapora dönüştürür.

## Bu Feature Ne İşe Yarıyor?

`reports` feature, Torcav'ın diğer feature'ları (özellikle `wifi_scan`'in `ScanSnapshot`'ı) tarafından üretilen veriyi **kullanıcının dışa aktarabileceği dokümanlara** çevirir. Hem teknik (JSON), hem hesap tablosu dostu (CSV), hem web (HTML), hem basılı (PDF) formatlar üretir.

Amaç: ölçüm sonuçlarının *uygulama dışında* — e-posta, yazıcı, destek bileti, arşiv — paylaşılabilmesi.

## Yaptıkları Neler?

### Domain

- **GenerateReportUseCase**: `ReportFormat` enum'una göre (`json`, `html`, `pdf`, `csv`) ilgili repository metoduna yönlendirir.
- **ReportLabels**: tüm rapor metinlerinin (başlık, sütun adları, "gizli ağ" gibi çeviriler) çoklu dil desteğiyle taşındığı kap. UI tarafında `AppLocalizations`'dan doldurulur.
- **ReportExportRepository**: soyut sözleşme.

### Data

- **ReportExportRepositoryImpl** (216 satır):
  - **JSON**: `JsonEncoder.withIndent('  ')` ile pretty-print; timestamp, ağlar, kanal istatistikleri, bant istatistikleri.
  - **HTML**: kendi içinde minimal CSS'li koyu temalı (`#0d1117` arka plan) tablo çıktısı.
  - **PDF**: `pdf` paketi (`pw`) ile flutter tarafında sayfa sayfa rendering; tablo, başlık, zaman damgası, kanal/bant bölümleri.
  - **CSV**: SSID, BSSID, dBm, security, channel, frequency... alan ayrılmış.

### Presentation

- **ReportsPage** (593 satır): dosya listesi, format seçici, önizleme, paylaş (`share_plus`), kaydet, sil.
- **ReportsBloc**: seçili snapshot + format → use-case → dosya yolu.
- **Paylaşma**: Android/iOS `share_plus`; yazdırma `printing` paketi.

## Hangi Özellik Eksik?

- **Kapsam dar**: yalnızca `ScanSnapshot` (WiFi) üzerinden üretiliyor. LAN discovery (`network_scan`), speed test history (`performance`), heatmap (`heatmap`) ve security events (`security`) için ayrı export pipeline eksik.
- **Şablon / branding yok**: PDF başlıkta şirket logosu, özel kapak sayfası eklenemiyor.
- **HTML çıktı responsive değil**: masaüstü için uygun, mobilde dar.
- **Yerelleştirilmiş sayısal formatlar**: dBm/MHz/Mbps değerleri `intl` `NumberFormat` ile lokalize edilmiyor; ondalık ayraç varsayılan İngilizce.
- **Şifreli/parolalı export yok**: hassas veri içeren raporlar bare-open paylaşılıyor; PDF parola, encrypted zip seçeneği yok.
- **E-posta entegrasyonu yok**: `mailto:` + attach basit; ama SMTP ile doğrudan gönderim (oauth gmail/IMAP) yok.
- **Batch / zaman serisi rapor**: birden çok snapshot'ı tek PDF'te birleştirme (trend raporu) yok.
- **Signing/notarization**: PDF dijital imzası (ISO 32000 PAdES) yok — raporun "değişmediği"nin ispatı yok.
- **Cloud export kanalları**: Google Drive, iCloud, Dropbox direct upload yok (MCP benzeri auth flow'lar hazır ama entegre değil).
- **İçerik redaksiyonu (redaction) UI yok**: SSID/BSSID/MAC'leri maskelemek için toggle yok.
- **Checksum/hash kaydı**: dış dünyaya gönderilen dosyanın SHA-256'sı loglanmıyor → sonradan "bu benim gönderdiğim dosya" diye ispat zor.

## Etik / Legal Olarak Neler Eklenebilir?

- **Otomatik anonymization opsiyonu (default ON)**: BSSID ve MAC'in son 3 byte'ı, SSID'nin hash'i + ilk karakteri, konum verisi kabaca yuvarlanmış — paylaşımda veri minimizasyonu (KVKK/GDPR "data minimization").
- **Kapak sayfası disclaimer**: her PDF'te 1. sayfada şu metin basılmalı:
  > "Bu rapor yalnızca kullanıcının yetkili olduğu ağ üzerinde yapılan pasif gözlem sonuçlarıdır. Üçüncü tarafların cihaz bilgileri görünüyorsa, rapor paylaşmadan önce KVKK/GDPR açık rıza gereksinimleri değerlendirilmelidir."
- **Audit trail**: her oluşturulan rapor için local-only bir log (`who` — user, `when`, `format`, `sha256`) tutulmalı; kullanıcı kendi kaydını denetleyebilsin.
- **Üçüncü taraf ağ verisi filtresi**: kullanıcı "bu rapora yalnızca bağlı olduğum ağı dahil et" seçeneğini tercih edebilmeli.
- **Çocuk / hassas alan uyarısı**: eğer tarama sonucunda "Baby Monitor", "Playstation-Çocuk-Odası" gibi hostname'ler yer alıyorsa, export onayında kullanıcı uyarılsın.
- **Dil uyumu**: rapor dili kullanıcı cihaz diliyle üretiliyor ama sözleşmesel ifadeler (disclaimer, uyarılar) yasal çeviri gerektirir; Türkçe/İngilizce için hukuki onay alınmış metinler kullanılmalı.
- **Retention UI**: kaç rapor saklanacağı ve otomatik silme kuralı ayarlanabilmeli (Settings > Reports retention: 30 gün).
- **Forensics uyarısı**: rapor hukuki delil olarak kullanılacaksa *chain of custody* sağlanması kullanıcıya ayrıca anlatılmalı; uygulamanın bu konuda garantisi olmadığı belirtilmeli.

## Hangi Sorunları Çözüyor?

- **Paylaşılabilirlik**: "şu anda gördüğüm ağlar" ekran görüntüsünden fazlasını üretir — search edilebilir, yazdırılabilir, arşivlenebilir.
- **Teknik & teknik-olmayan kullanıcı ikisini birden**: JSON geliştiriciler için, PDF yöneticiler için, CSV Excel için.
- **Destek biletine ekleme**: ISS veya ağ sağlayıcısına sorun bildirirken ölçümlerin somut delili.
- **Tarihsel arşiv**: kullanıcı zaman içinde kendi ağının değişimini belgeleyebilir.
- **Compliance altyapısı**: eğer gelecekte kurumsal raporlama (ISO 27001 iç denetim) istenirse, formatlı çıktı mekanizması hazır.
