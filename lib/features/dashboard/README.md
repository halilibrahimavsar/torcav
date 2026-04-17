# Dashboard Feature

Uygulamanın ana karşılama ekranı: ağ özeti, güvenlik skoru, en iyi kanal önerisi, bildirim merkezi.

## Bu Feature Ne İşe Yarıyor?

`dashboard` feature, kullanıcının uygulamayı açtığında **"şu anda ağımda ne durumda?"** sorusuna 3 saniyede cevap veren özet ekrandır. Diğer feature'ların ürettiği verileri (WiFi Scan, Security Analyzer, Channel Rating Engine) toplayıp tek bir *bento-grid* ekranda sunar.

Sadece UI değil; aynı zamanda **aksiyona yönlendirme merkezi**: her kart, ilgili feature'ın tam sayfasına köprüdür.

## Yaptıkları Neler?

1. **Ağ özet bilgileri** (`dashboard_page.dart`):
   - SSID, IP, Gateway — `network_info_plus` üzerinden okunur ve temizlenir (iOS'un eklediği tırnaklar, `<unknown>` değerleri sıfırlanır).
   - Son tarama sonucundan ağ sayısı (`ScanSessionStore.latest`).
2. **Security Score (0-100)**:
   - `SecurityAnalyzer.assess()` ile her ağ için skor hesaplanır.
   - Dashboard üstünde **en düşük skor** (worst-case) gösterilir — kötü niyetli benchmark'tan ziyade savunmacı bakış.
3. **En iyi kanal önerisi**:
   - `ChannelRatingEngine.calculateRatings()` ile 2.4 GHz ve 5 GHz bandlarında kanal skorları.
   - Bağlı olduğu ağın kanalı ile kıyaslanır; skor farkı 7.0'ın üzerindeyse "kanal X'e geçin" önerisi kartı görünür.
4. **Security Core widget'ı** (`security_core.dart`):
   - Dönen, nabız atan, glow yapan animasyonlu cyber görsel.
   - `TickerProviderStateMixin` ile iki controller (rotation 10s, pulse 2s) repeat ediyor.
   - Renk `statusColor` (yeşil/sarı/kırmızı) ile durumu vurguluyor.
5. **Notification sheet** (`notification_sheet.dart`):
   - Alttan açılan bottom-sheet.
   - `NotificationBloc` içindeki `SecurityEvent`'leri (yeni tehditler, zayıf şifrelemeler, yabancı cihazlar) zaman damgalı liste olarak sunar.
   - Kritik sayısı headerda badge olarak gösteriliyor.
6. **Aksiyon kartları**: tıklandığında `onNavigate('wifi')`, `onNavigate('security')` vb. çağrılarıyla App Shell'deki switch'e iletiliyor.

## Hangi Özellik Eksik?

- **Gerçek zamanlı güncelleme yok**: Dashboard açıkken WiFi Scan'den yeni bir sonuç gelse bile `StreamSubscription` kurulu değil; sadece `initState`'te okuma var. Bir `ScanSessionStore.stream` ile listener gerekli.
- **Pull-to-refresh olmayan yerler**: bazı kartların manuel tazeleme butonu yok.
- **Trend / tarihçe gösterimi yok**: "Güvenlik skorun son 7 günde 82→68'e düştü" gibi mini-grafikler yok (`fl_chart` dependency zaten var).
- **Kart kişiselleştirme yok**: kullanıcı hangi kartı görmek istediğini seçemiyor; gizlilik modu (örn. SSID'yi bulanıklaştır) yok.
- **Widget'lar** (homescreen widget, Android/iOS): dışarıdan hızlı güvenlik skorunu göstermek mümkün değil.
- **Bildirim aksiyonları zayıf**: NotificationSheet içinde "bu uyarıyı kapat" veya "görev oluştur" aksiyonları yok; mark-as-read tek yön.
- **Empty state**: henüz tarama yapılmamışken "Başla" CTA'sı yeterince çağrıştırıcı değil; statik placeholder.
- **Snapshot diffing yok**: "Geçen taramaya göre N yeni cihaz görüldü" farkı gösterilmiyor.
- **Skor açıklanabilirliği**: security score 68 ise neden 68 olduğunu detaylandıran küçük bir bottom-sheet yok (sadece Security Center'a git).

## Etik / Legal Olarak Neler Eklenebilir?

- **SSID/IP gizliliği**: bu sayfa ekran alıntısı (screenshot) ile paylaşıldığında SSID ve Gateway adresi ifşa olur. Kart üstüne `SensitiveContent` / `FLAG_SECURE` eşdeğeri eklenmeli ve toggle (`Settings > Privacy > Mask network identifiers`) sunulmalı.
- **Uyarı metinlerinin dili**: "Ağın güvensiz" gibi kesin ifadeler yerine olasılıksal dil ("Bu konfigürasyon düşük güvenlik profiline sahip görünüyor; kesin bir ihlal beyanı değildir.") — yanlış pozitiflerde hukuki sorumluluk azaltıcı.
- **3. taraf ağ SSID'si göründüğünde**: eğer kullanıcı komşu ağları taratmışsa, Dashboard bu ağların SSID'sini göstermemeli veya hash'leyerek göstermeli (KVKK 6. madde; SSID kişisel veri olarak yorumlanabilir).
- **Bildirim saklanma süresi**: `NotificationSheet`'te gösterilen olayların ne kadar saklandığı açık belirtilmeli; otomatik temizleme politikası eklenmeli (örn. 30 gün sonra sil).
- **Consent banner**: ilk kez "security analyzer" çalıştığında kullanıcıya ne ölçtüğünü ve verinin cihazda kaldığını anlatan küçük bilgi çipi.
- **Renk/simgelerin kültürel tarafsızlığı**: kırmızı = kötü, yeşil = iyi yaklaşımı renk körleri için yetersiz; ikon + etiket ile desteklenmeli (WCAG 1.4.1).
- **Çıktı doğruluğu**: security score algoritmasının açık-kaynaklı ve *reproducible* olması gerek (supply-chain güven) — algoritma versiyonu Dashboard'da minik etiket olarak gösterilebilir.

## Hangi Sorunları Çözüyor?

- **Bilgi aşırı yüklemesi**: 11 feature'ın çıktısını bir sayfada özetleyerek kullanıcının uygulama içinde kaybolmasını engelliyor.
- **Aksiyon tetikleme**: "ne yapmalıyım?" sorusunu "kanal X'e geç", "zayıf WPA2 ağına dikkat" gibi net önerilere dönüştürüyor.
- **İlk intiba**: yeni kullanıcı için görsel olarak ikna edici, profesyonel bir kontrol paneli izlenimi veriyor.
- **Kritik olay görünürlüğü**: Security events arka planda birikir; sheet ile her an erişilebilir.
- **İzleme sürtünmesini azaltma**: en iyi kanal önerisi gibi değer öneren micro-feature'lar sayesinde kullanıcı uygulamayı tekrar tekrar açmak için sebep buluyor.
