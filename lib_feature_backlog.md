# Lib Feature Analizi ve Backlog Tabloları

> **Baseline commit:** `0fdc47d` · **Doğrulama tarihi:** 2026-05-04
> Her satırın doğruluğu bu commit'te kontrol edildi. Kod değiştikçe `[verified: <sha>]` damgalarını güncelleyin.

Bu backlog, `lib/features/**` yapısı, README'ler ve mevcut domain/data/presentation katmanları üzerinden çıkarıldı. Hedef: ev kullanıcısının Wi-Fi güvenliği, hacklenmekten korunma ve internet/Wi-Fi performansını iyileştirme ihtiyacı.

Resmi referans çerçevesi:

- [CISA Home Network Security](https://www.cisa.gov/news-events/news/home-network-security)
- [CISA Securing Wireless Networks](https://www.cisa.gov/news-events/news/securing-wireless-networks)
- [NSA Home Network Best Practices](https://www.nsa.gov/Press-Room/Press-Releases-Statements/Press-Release-View/Article/3304674/nsa-releases-best-practices-for-securing-your-home-network/)
- [FTC Public Wi-Fi](https://consumer.ftc.gov/articles/are-public-wi-fi-networks-safe-what-you-need-know)

## Oncelik Tanimi

- `P0a` (now): Hacklenmeye karşı doğrudan koruma; mevcut altyapıyla 1-2 sürümde teslim edilebilir.
- `P0b` (next): Aynı güvenlik kategorisinde olup baseline/yeni servis gerektiren, P0a sonrası gelmesi gereken işler.
- `P1`: Wi-Fi/internet performansını kullanıcı için belirgin iyileştirir.
- `P2`: Raporlama, açıklanabilirlik, güvenilirlik veya profesyonel kaliteyi artırır.
- `P3`: İleri seviye / nice-to-have / deneysel geliştirme.

> **Not:** P0 tek seferde uygulanamayacak kadar yüklü olduğundan ikiye bölündü. P0a önce, P0b sonra.

## Ana Ozellikler Tablosu

| Oncelik | Eksik Ana Feature | Kullanici Problemi | Neden Gerekli | Uygulamada Su An Karsiligi | Onerilen Kapsam | Ilk Surum Icin Minimum |
|---|---|---|---|---|---|---|
| P0a | Public Wi-Fi Güvenlik Modu | Kafe/otel/havaalanı Wi-Fi'sinde kullanıcı riskin ne olduğunu anlamıyor. | Açık ağ, captive portal, DNS hijack, evil twin ve VPN ihtiyacı ev kullanıcısı için kritik. Mevcut altyapı (`security_analyzer.dart:263` SSID pattern matching, captive portal/DNS testleri) sadece ipucu veriyor; profil enum'u yok. | Ağa bağlanınca "public/private/guest" profili, HTTPS/VPN tavsiyesi, hassas işlem uyarısı, otomatik deep-scan kısıtlama. Bağımlılık: `NetworkContextType` enum + per-network policy (alt-özellikler). | Açık ağ algılanınca güvenli kullanım paneli ve VPN/HTTPS/DNS uyarıları. |
| P0a | Güvenli Router Kurulum Sihirbazı | Kullanıcı WPA2/WPA3, WPS, admin şifresi, guest network gibi ayarları bilmiyor. | Hacklenmeye karşı en büyük pratik kazanım router konfigürasyonundan gelir. | `security`, `wifi_scan`, `settings` parçalı uyarılar veriyor; yönlendirilmiş sihirbaz yok. | Marka bağımsız checklist: admin şifresi değiştir, WPA3/WPA2-AES kullan, WPS kapat, guest network aç, remote admin kapat. | Router güvenlik skoru + kullanıcıya adım adım yapılacaklar listesi. |
| P0b | Ev Cihaz Güven Puanı ve IoT Segmentasyon | Kullanıcı ağındaki kamera, TV, yazıcı gibi cihazların riskini bilmiyor. | Zayıf IoT cihazları ev ağında yayılma ve veri sızıntısı riski yaratır. | `network_scan` `exposureScore` (tek aggregate) + `ai` device classification var; per-host trust score ve sebep listesi yok. | Cihaz bazlı risk: açık port, cihaz tipi, vendor, yeni cihaz, kritik servis, guest network önerisi. | Her LAN cihazı için "Güvenli / Dikkat / Riskli" etiketi ve öneri. |
| P0b | Arka Plan Güvenlik İzleme ve Kritik Bildirimler | Kullanıcı uygulamayı açmadığında yeni cihaz veya risk değişimini kaçırıyor. | Ev ağı güvenliği tek seferlik tarama değil, değişiklik takibi problemidir. | `monitoring` canlı izleme var; Android/iOS native foreground service / background notification yok (doğrulandı: kod tabanında yok). | Foreground/background policy, yeni cihaz, encryption downgrade, gateway değişimi, DNS hijack şüphesi bildirimi. Bağımlılık: rogue DHCP / gateway baseline (alt-özellik). | Uygulama açıkken/foreground service ile yeni cihaz ve güvenlik drift bildirimi. |
| P1 | Wi-Fi Hizlandirma / Root-Cause Kocu | Kullanici "internet yavas" der ama sorun Wi-Fi mi ISP mi cihaz mi anlamaz. | Performans cozumu icin RSSI, kanal yogunlugu, latency, jitter, bufferbloat birlikte yorumlanmali. | `wifi_scan`, `performance`, `heatmap`, `monitoring` ayri olcuyor. | Tek teshis akisi: sinyal zayif, kanal kalabalik, router uzak, ISP yavas, bufferbloat, DNS yavas gibi neden siniflandirma. | "Yavasligin muhtemel nedeni" karti + 3 aksiyon onerisi. |
| P1 | Mesh / AP Yerlesim Planlayici | Kullanici router veya mesh node'u nereye koyacagini bilmiyor. | Wi-Fi hizinin buyuk kismi kapsama, duvar, mesafe ve kanal cakismasina bagli. | `heatmap` sinyal haritasi var; yerlesim onerisi ve what-if yok. | Heatmap + RSSI + dead zone ile router/mesh yerlestirme onerisi, oda bazli tavsiye. | Heatmap sonucunda "router'i daha merkezi konuma tasi / mesh ekle" onerisi. |
| P1 | Router Firmware / CVE Takip Merkezi | Kullanici router yaziliminin eski veya riskli oldugunu bilmiyor. | Firmware guncellemeleri guvenlik aciklarini ve performans sorunlarini duzeltir. | `security` statik vulnerable router DB ile sinirli. | Vendor/model tespiti, firmware guncelleme rehberi, CVE/KEV guncellik kontrolu, otomatik guncelleme hatirlatmasi. | Vendor/model eslesirse "firmware kontrol et" rehberi ve risk etiketi. |
| P2 | Gizlilik, Veri Silme ve Guvenli Rapor Merkezi | Kullanici SSID, MAC, hostname, rapor gibi hassas verileri nasil yonetecegini bilmiyor. | Ag verileri kisisel veri olabilir; export ve paylasim riskli. | `reports`, `settings`, storage servisleri var; merkezi privacy hub yok. | Tum veriyi sil, retention ayari, export anonymization, rapor parolalama, MAC/SSID maskeleme. | Settings icinde "Tum yerel veriyi sil" + rapor anonimlestirme default ON. |

## Alt Ozellikler Tablosu

| Mevcut Feature | Var Olan Kabiliyet | Eksik / Iyilestirme | Kullaniciya Etkisi | Onerilen Aksiyon | Oncelik |
|---|---|---|---|---|---|
| `wifi_scan` | Wi-Fi aglarini, kanal, RSSI, security, WPS/PMF, width, standard bilgileriyle tariyor. | 6GHz/Wi-Fi 6E ve DFS kanal farkindaligi eksik. | Yeni routerlarda eksik/yanlis kanal onerisi cikabilir. | 6GHz kanal listesi, ulke/regulasyon profili ve DFS etiketi ekle. | P1 |
| `wifi_scan` | Kanal yoğunluğu ve en iyi kanal hesabı var. `estimatedMaxThroughputMbps` field'ı `wifi_network.dart:78`'de tanımlı. | Field UI'ya bağlanmamış; kanal önerisi açıklamasında kullanılmıyor. | Kullanıcı "hangi kanal daha hızlı olur?" sorusuna net cevap alamıyor. | Mevcut throughput tahminini kanal kartına ve dashboard önerisine bağla; "neden bu kanal" açıklamasına ekle. | P1 |
| `wifi_scan` | Multi-pass snapshot ve karsilastirma var. | Android scan throttling ve tekrar tarama feedback'i zayif. | Kullanici tarama calismadi sanabilir. | "Android tarama limiti, son onbellek kullaniliyor" aciklamasi ve backoff timer goster. | P2 |
| `network_scan` | LAN cihaz keşfi, port scan, mDNS, UPnP, `exposureScore` (tek aggregate) var (`host_scan_result.dart:14-16`). | Per-host trust score yok; risk gerekçesi UI'da görünmüyor. | Ev kullanıcısı hangi cihaz tehlikeli anlayamaz. | Host kartına risk nedeni + "ne yapmalıyım?" önerisi ekle. | P0b |
| `network_scan` | Açık port ve servis banner okuyor. `host_scan_result.dart:18` `isGateway` flag'i var ama baseline persistence yok. | Rogue DHCP / gateway değişimi tespiti yok. | Sahte gateway veya yanlış DHCP ciddi MITM riski yaratır. | Gateway MAC baseline, DHCP sunucu gözlemi ve değişim uyarısı ekle. (`TrustedNetworkProfile` altyapısı `trusted_network_profile.dart`'da var — gateway alanı eklenmeli.) | P0b |
| `network_scan` | IPv4 subnet tarama var. | IPv6 destegi yok. | Modern aglarda bazi cihazlar gorunmeyebilir. | IPv6 neighbor discovery / local network kisitlari icin platform bazli destek planla. | P2 |
| `security` | WPA/WPA2/WPA3, WPS, evil twin, DNS, captive portal, ARP spoofing heuristikleri var (`security_analyzer.dart`, `deauth_detector.dart`, `arp_spoofing_detector.dart`). | Risk skoru ağ bağlamına (home/public/guest) göre kalibre değil; profil enum'u yok. | Ev ağı, kafe Wi-Fi ve misafir ağı aynı ağırlıkla yorumlanabilir. | `NetworkContextType` enum (`home`/`public`/`guest`/`unknown`); skor ağırlıklarını buna göre ayarla. Public Wi-Fi modunun temel taşı. | P0a |
| `security` | TrustedNetworkProfile ve drift bulguları var (`trusted_network_profile.dart:5-84`). | Evil twin algısı tek boyutlu: `deauth_detector.dart:70` sadece RSSI swing (`<15 dBm`) + same-SSID/different-BSSID bakıyor. OUI / channel plan / mesh isim paterni hiç kullanılmıyor. | Yanlış pozitif (meşru mesh) kullanıcıyı gereksiz paniğe sokar; gerçek evil twin atlanabilir. | Aynı vendor/OUI, RSSI patern, channel plan ve mesh isimlerini hesaba kat; çok sinyalli skor üret. | P0b |
| `security` | DNS leak/hijack ve captive portal testleri var (`dns_security_usecase.dart`). | Public Wi-Fi için sade güvenli kullanım akışı yok; SSID pattern matching sınırlı (`security_analyzer.dart:263`). | Kullanıcı teknik bulgudan aksiyona geçemez. | Public Wi-Fi modunun (P0a ana özellik) UI tarafı: VPN, HTTPS, hassas işlem, DNS uyarı paneli. | P0a |
| `security` | Router vulnerability lookup statik JSON ile var. | CVE/veri guncelligi belirsiz. | Eski veriye gore yanlis guven hissi olusabilir. | DB versiyon/tarih etiketi, manuel update yolu, vendor/model guven seviyesi ekle. | P1 |
| `performance` | Latency, jitter, download, upload, loaded latency olcuyor. | Wi-Fi mi ISP mi ayrimi yok. | Kullanici router mi servis saglayici mi sorunlu anlayamaz. | Speed test sonucunu RSSI, kanal yogunlugu ve gateway ping ile birlestir. | P1 |
| `performance` | Cloudflare endpoint ile test var. Test başlamadan ~300-500 MB uyarısı + metered connection kontrolü `performance_page.dart:37-85`'te mevcut. | — (zaten yapılmış, takip için tutuluyor) | Kullanıcı kotasını koruyor. | Yalnızca metin/eşik ayarı: çok büyük dosya indiren kullanıcılar için "hızlı test" modu eklenebilir. | P2 |
| `performance` | Loaded latency olculuyor. | Bufferbloat insan-okunur skora cevrilmiyor. | Oyun/video gorusme sorunlari anlasilmaz kalir. | A-F veya "iyi/orta/kotu" bufferbloat etiketi ekle. | P1 |
| `monitoring` | RSSI graph, kanal spektrumu, topoloji ve ping var. | Native foreground service yok (Android/iOS); arka plan tarama imkansız. | Sinyal düşüşü veya yeni cihaz olayları kaçırılır. | Pil dostu foreground service + kritik event notification planla. | P0b |
| `monitoring` | Topoloji grafigi var. | Topoloji L2 dogrulamasi varsayimsal. | Kullanici gercek baglanti haritasi sanabilir. | "Tahmini topoloji" etiketi, evidence aciklamasi ve confidence degeri ekle. | P2 |
| `monitoring` | Canlı tarama stream'i + exponential backoff (60s max) `monitoring_repository_impl.dart:16-39`'da var. | Lifecycle/battery awareness yok; uygulama arkaplanda da aynı sıklıkta tarıyor. | Bataryayı tüketir; Android Doze/throttle'a takılır. | `WidgetsBindingObserver` ile foreground/background polling stratejisi; düşük pilde otomatik yavaşlama; kullanıcı interval'ı zaten var (settings) — buna saygı duy. | P1 |
| `heatmap` | AR/kamera overlay + IMU ile RSSI heatmap uretiyor. | Router/mesh yerlesim onerisi yok. | Harita var ama kullanici ne yapacagini bilemeyebilir. | Dead zone tespitinden otomatik "router'i tasi / mesh ekle" onerisi uret. | P1 |
| `heatmap` | Bağlı ağın sinyalini haritalıyor. `heatmap_point.dart:48` `floor` field'ı (barometre tabanlı) zaten var. | UI yok: oda/kat seçim, filtreleme, çoklu kat görünümü; PNG/PDF export entegrasyonu da yok. | Büyük evlerde ölçüm kullanışsızlaşır. | Mevcut `floor` field'ı üzerine kat/oda etiketleme UI'sı; oturumları katlara ayırma; PNG export. | P2 |
| `reports` | Wi-Fi snapshot icin JSON/CSV/HTML/PDF export var. | LAN, security, speed test, heatmap raporlari eksik. | Kullanici tam ev agi raporu cikaramaz. | "Ev Agi Saglik Raporu" formati: guvenlik + hiz + cihaz + kapsama. | P1 |
| `reports` | Paylaşma/kaydetme var; anonimleştirme toggle'ı `reports_page.dart:239-244` mevcut (`_maybeAnonymize` SSID redact + BSSID son 3 oktet maskeleme). | Anonimleştirme **default OFF**; parola/şifreli export yok. | MAC/SSID/hostname dışarı sızabilir. | Anonimleştirmeyi default ON yap; PDF parola opsiyonu ekle. | P0a |
| `dashboard` | Ag ozeti, guvenlik skoru, kanal onerisi ve bildirim sheet'i var. | Ilk acilis ve "ne yapmaliyim?" akisi zayif. | Ev kullanicisi feature'lar arasinda kaybolur. | Dashboard'a "Bugun yapilacak 3 guvenlik/hiz aksiyonu" alani ekle. | P1 |
| `dashboard` | Security score + `_ScoreExplanationSheet` (`dashboard_page.dart:586-748`) `evidenceFindings` ile severity-renkli pill'lerle açıklama gösteriyor. | İçerik fakir: kanal/cihaz riski/DNS gibi alt-kategoriler henüz `evidenceFindings` listesine eşit ağırlıkla giremiyor. | Mevcut sheet kullanılıyor ama detay boyutu kullanıcıya yeterli olmayabilir. | Mevcut bottom sheet'in evidence kategorilerini genişlet: encryption, WPS, DNS, cihaz riski, kanal kalabalığı için ayrı satırlar; her satıra "Ne yapayım?" linki. | P2 |
| `settings` | Retention slider'ları (scan history / speed test / security event 7-365 gün) `settings_page.dart:501-538`'de; "Wipe All Local Data" 577-609'da; tema/dil/scan interval/strict safety/deep scan toggle'ları mevcut. | — (zaten yapılmış, takip için tutuluyor) | Kullanıcı veri kontrolüne sahip. | Yalnızca per-feature granular silme (sadece heatmap, sadece reports, vb.) eksik. | P2 |
| `settings` | Strict safety mode var. | Per-network policy yok; ayarlar global. | Evde deep scan açık, public Wi-Fi'de kapalı gibi güvenli ayrım yapılamaz. | Ağ profiline göre ayar: home/public/guest; public ağda agresif tarama kapalı. Bağımlılık: `NetworkContextType` enum (P0a security'de). | P0a |
| `ai` | ONNX ile cihaz siniflandirma ve override store var. | Explainability ve dusuk guven fallback'i zayif. | Yanlis cihaz tipi yanlis guvenlik onerisine yol acabilir. | "Neden boyle siniflandirildi?" evidence: vendor, hostname, portlar; dusuk guvense Unknown. | P2 |
| `ai` | Kullanici label override saklanabiliyor. | Model card / veri seti / versiyon belgesi yok. | Kullanici siniflandirmaya ne kadar guvenecegini bilemez. | Model versiyonu, egitim kapsami, bilinen limitler ve confidence kalibrasyonu ekle. | P2 |
| `app_shell` | Dashboard, Discovery, Operations navigasyonu var. | Router guvenlik sihirbazi gibi yonlendirilmis journey yok. | Kullanici tek tek sayfa gezmek zorunda kalir. | Ilk taramadan sonra "Ev agini guvene al" akisi baslat. | P1 |
| `app_shell` | Onboarding izinleri anlatıyor; yetki onay checkbox'ı `onboarding_page.dart:316-393`'te ("I confirm I have permission to scan..."). | Public/private/guest ağ tipi seçimi yok. | Yanlış kullanım ve hukuki/güvenlik riski oluşur; agresif tarama public Wi-Fi'de hassas olabilir. | İlk taramadan önce ağ tipi seçimi ekle (Public Wi-Fi modu P0a'nın bir parçası). | P0a |

## Özet Öncelik

**P0a (now) — bu sürüm hedefleri:**
- Public Wi-Fi modu (security UI + `NetworkContextType` enum)
- Per-network policy (settings, P0a security'ye bağlı)
- Güvenli router kurulum sihirbazı
- Onboarding'de ağ tipi seçimi
- Rapor anonimleştirme default ON + PDF parola

**P0b (next) — bir sonraki sürüm:**
- Cihaz güven puanı UI'sı (`exposureScore`'un üzerine)
- Rogue DHCP / gateway baseline (TrustedNetworkProfile genişletmesi)
- Evil twin OUI/channel/mesh patern doğrulaması
- Native foreground service + kritik bildirimler

**P1:** Hız teşhis koçu, heatmap yerleşim önerisi, throughput tahminini kanal kartına bağlama, lifecycle-aware monitoring polling, tam ev ağı raporu.

**P2 ve sonrası:** Skor breakdown detaylandırma, AI explainability, model card, çoklu kat heatmap UI, IPv6.

## Bağımlılık Notları

- **Public Wi-Fi modu (P0a)** → `NetworkContextType` enum + security skor kalibrasyonu + per-network settings policy + onboarding ağ tipi seçimi. Hepsi birlikte kapatılmalı.
- **Arka plan izleme (P0b)** → rogue DHCP / gateway baseline tamam olmadan etkili çalışmaz; TrustedNetworkProfile gateway alanı önce gelmeli.
- **Cihaz güven puanı (P0b)** → mevcut `exposureScore` aggregate; `network_scan` host kartına UI eklenmeli, `ai` classification confidence ile zenginleştirilebilir.

## Doğrulama Notları

Bu sürümde (baseline `0fdc47d`) düzeltilen iddialar:
- **Dashboard skor açıklanabilirliği:** Backlog "yok" diyordu; `_ScoreExplanationSheet` (`dashboard_page.dart:586-748`) **mevcut**. P1 → P2'ye düşürüldü, kapsam içerik genişletmesine kaydı.
- **Performance veri uyarısı:** Backlog "zayıf" diyordu; ~300-500 MB + metered check (`performance_page.dart:37-85`) **mevcut**. P0 → P2'ye düşürüldü.
- **Monitoring backoff:** Exponential backoff (60s) `monitoring_repository_impl.dart:16-39` **var**; eksik olan **lifecycle/battery awareness**, formülasyon düzeltildi.
- **wifi_scan throughput:** `estimatedMaxThroughputMbps` field'ı `wifi_network.dart:78`'de **var**; eksik olan UI bağlanması, formülasyon düzeltildi.
- **Reports PDF tutarsızlığı (commit 37914d5):** Kaldırılan `spectrum_report_exporter.dart`'tı (monitoring spektrum raporu); Wi-Fi snapshot PDF export hâlâ **canlı ve doğru**. Backlog'da değişiklik gerekmedi.

Backlog yenilendiğinde her satıra `[verified: <commit-sha>]` damgası eklenebilir.
