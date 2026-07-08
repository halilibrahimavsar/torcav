# Torcav

## Ürün Misyonu

Torcav; ev Wi-Fi/LAN ağını ve bağlı olunan mobil operatör (Vodafone, Turkcell,
Türk Telekom vb.) bağlantısını görünür kılan, sorunların kök nedenini kanıta
dayalı teşhis eden ve kullanıcının bağlantısından ödediği hızın karşılığını
almasına yardım eden; gizlilik-öncelikli, müdahalesiz, cihaz-üstü çalışan
bir Android ağ asistanıdır.

### İki kitle, iki deneyim, tek uygulama

- **Yeni kullanıcı**: Teknik terim bilmez. Tek bakışta "ağım iyi mi?" cevabını;
  sorun varsa sade dille TEK kök neden + kendisinin uygulayabileceği TEK aksiyon
  ister. ("Modemin kanalı kalabalık → şu kanala geç" / "Sorun operatöründe →
  bu raporu ISS'ine gönder")
- **Profesyonel**: Derinlik ister — spektrum, topoloji, canlı RSSI, AR ısı
  haritası, ham metrikler, JSON/CSV/PDF export. Pro derinlik yeni kullanıcının
  ilk ekranını ASLA kalabalıklaştırmaz.

### Kapsam: iki ağ, tek soru

1. **Ev ağı (Wi-Fi + LAN)** — kim bağlı, sinyal/kanal/kapsama nasıl, güvenli mi?
2. **Operatör ağı (hücresel)** — hangi operatör/nesil/sinyal; şu an Wi-Fi mı
   mobil mi daha iyi; ödediğim hızı alıyor muyum?

İkisinde de cevaplanan soru: **"Bağlantım neden yavaş/sorunlu ve BEN ne
yapabilirim?"**

### "Yönetim"in tanımı (kritik sınır)

Torcav hiçbir ağa/cihaza müdahale etmez (pasif-only). Yönetim = görünürlük +
teşhis + kullanıcının kendisinin uyguladığı rehberli aksiyon (sihirbaz,
tek-tık yönlendirme, hazır rapor). Tek istisna: kullanıcının açıkça başlattığı,
yalnızca kendi cihazındaki trafiği etkileyen lokal-VPN iyileştirmeleri
(DNS değişimi, QoS önceliklendirme).

### Başarı ölçütleri

- Yeni kullanıcı 30 saniyede sağlık durumunu ve (varsa) tek aksiyonunu görür.
- Her "internetim yavaş" şikayeti şu üçlüye dönüşür: kök neden + kanıt + aksiyon.
- Kullanıcı taahhüt edilen hız ile ölçülen hızı karşılaştırıp ISS'e sunulabilir
  rapora dönüştürebilir.
- Uygulama kapalıyken de kullanıcıyı korur (native arka plan izleme + bildirim).

### Değişmezler

- **Gizlilik**: Kullanıcı verisi cihazda kalır — hesap yok, bulut depolama yok,
  analytics yok. Kullanıcının başlattığı ölçümler yalnızca şu uçlara
  veri-minimizasyonuyla bağlanır: `speed.cloudflare.com` (hız testi),
  `cloudflare-dns.com` + genel DNS çözücüleri (DNS/DoH doğrulama),
  `connectivitycheck.gstatic.com` (captive portal),
  `api.pwnedpasswords.com` (k-anonimlik ile parola sızıntı kontrolü).
  Yeni bir dış uç eklemek bu listeyi VE uygulamadaki gizlilik politikası
  sayfasını güncellemeyi gerektirir.
- **Pasiflik**: Aktif saldırı/müdahale vektörü (deauth, injection, brute-force)
  asla eklenmez. Kullanıcının kendi ağında başlattığı teşhis ölçümleri
  (ping, port tarama, mDNS, hız testi) müdahale değildir.
- **Dürüstlük**: Yapamadığımız şeyi vaat eden UI metni yazılmaz.
- **Platform**: Android-first; iOS kısıtları kullanıcıya açıkça belirtilir.

## Geliştirme

### Komutlar

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs  # DI kod üretimi
dart analyze        # DİKKAT: `flutter analyze` bu makinede non-ASCII yol
                    # ("Masaüstü") yüzünden çöküyor — `dart analyze` kullan
flutter test        # 425+ test
```

### Mimari

- Feature başına clean architecture: `domain` (entity / usecase / repository
  arayüzü) → `data` (datasource / repository impl) → `presentation`
  (bloc / page / widget). Yeni özellikler bu düzeni izler.
- State: `flutter_bloc`; DI: `get_it` + `injectable` (build_runner üretir).
- Depolama tamamen yerel: SQLite (SQLCipher), Hive, `flutter_secure_storage`.
- Navigasyon: 3 sekme (Dashboard / Keşif / Operasyonlar) —
  `lib/features/app_shell/`. Operations hub soruya göre gruplar: Güvenlik,
  Hız & Bağlantı, Kapsama, Raporlar.
- Native katman (`android/app/src/main/kotlin/dev/halilibrahim/torcav/`):
  `PingStabilizerVpnService` + `StabilizerAlertEngine` (uyarı kuralları native
  çalışır), `MonitoringWorker` (WorkManager arka plan tarama),
  `SpeedProbeWorker` (arka plan hız örneklemesi; yalnız UNMETERED ağda),
  `CellularChannelHandler` (operatör/nesil/sinyal).

### Değişmez kurallar

- Stabilizer bildirim içeriği Dart'tan `updateConfig` ile itilen
  `StabilizerConfig` şablonlarından geçer; monitör bildirimleri
  `MonitoringWorker` prefs string'lerinden okunur. Cubit'lerden öneri
  bildirimi post edilmez — süreç ölünce kaybolur.
- Yeni UI string'leri `AppLocalizations` üzerinden eklenir; arb dosyaları
  `lib/core/l10n/` altında (TR/EN/DE/KU), `flutter gen-l10n` üretir.
- UI metinleri yeteneği abartmaz (bkz. Değişmezler → Dürüstlük).
