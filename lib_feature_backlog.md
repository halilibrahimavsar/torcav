# Lib Feature Analizi ve Backlog Tabloları

Bu backlog, `lib/features/**` yapısı, README'ler ve mevcut domain/data/presentation katmanları üzerinden çıkarıldı. Hedef: ev kullanıcısının Wi-Fi güvenliği, hacklenmekten korunma ve internet/Wi-Fi performansını iyileştirme ihtiyacı.

Resmi referans çerçevesi:

- [CISA Home Network Security](https://www.cisa.gov/news-events/news/home-network-security)
- [CISA Securing Wireless Networks](https://www.cisa.gov/news-events/news/securing-wireless-networks)
- [NSA Home Network Best Practices](https://www.nsa.gov/Press-Room/Press-Releases-Statements/Press-Release-View/Article/3304674/nsa-releases-best-practices-for-securing-your-home-network/)
- [FTC Public Wi-Fi](https://consumer.ftc.gov/articles/are-public-wi-fi-networks-safe-what-you-need-know)

## Oncelik Tanimi

- `P0`: Hacklenmeye karsi dogrudan koruma veya yanlis/guvensiz kullanim riskini azaltir.
- `P1`: Wi-Fi/internet performansini kullanici icin belirgin iyilestirir.
- `P2`: Raporlama, aciklanabilirlik, guvenilirlik veya profesyonel kaliteyi artirir.
- `P3`: Ileri seviye / nice-to-have / deneysel gelistirme.

## Ana Ozellikler Tablosu

| Oncelik | Eksik Ana Feature | Kullanici Problemi | Neden Gerekli | Uygulamada Su An Karsiligi | Onerilen Kapsam | Ilk Surum Icin Minimum |
|---|---|---|---|---|---|---|
| P0 | Guvenli Router Kurulum Sihirbazi | Kullanici WPA2/WPA3, WPS, admin sifresi, guest network gibi ayarlari bilmiyor. | Hacklenmeye karsi en buyuk pratik kazanim router konfigurasyonundan gelir. | `security`, `wifi_scan`, `settings` parcali uyarilar veriyor; yonlendirilmis sihirbaz yok. | Marka bagimsiz checklist: admin sifresi degistir, WPA3/WPA2-AES kullan, WPS kapat, guest network ac, remote admin kapat. | Router guvenlik skoru + kullaniciya adim adim yapilacaklar listesi. |
| P0 | Public Wi-Fi Guvenlik Modu | Kafe/otel/havaalani Wi-Fi'sinde kullanici riskin ne oldugunu anlamiyor. | Acik ag, captive portal, DNS hijack, evil twin ve VPN ihtiyaci ev kullanicisi icin kritik. | `security` captive portal/DNS testleri var; ayri public Wi-Fi modu yok. | Aga baglaninca "public/private" profili, HTTPS/VPN tavsiyesi, hassas islem uyarisi, otomatik deep-scan kisitlama. | Acik ag algilaninca guvenli kullanim paneli ve VPN/HTTPS/DNS uyarilari. |
| P0 | Ev Cihaz Guven Puani ve IoT Segmentasyon | Kullanici agindaki kamera, TV, yazici gibi cihazlarin riskini bilmiyor. | Zayif IoT cihazlari ev aginda yayilma ve veri sizintisi riski yaratir. | `network_scan`, `ai`, `security` cihaz/port/risk verisi uretiyor ama tek cihaz guven puani yok. | Cihaz bazli risk: acik port, cihaz tipi, vendor, yeni cihaz, kritik servis, guest network onerisi. | Her LAN cihazi icin "Guvenli / Dikkat / Riskli" etiketi ve oneri. |
| P0 | Arka Plan Guvenlik Izleme ve Kritik Bildirimler | Kullanici uygulamayi acmadiginda yeni cihaz veya risk degisimini kaciriyor. | Ev agi guvenligi tek seferlik tarama degil, degisiklik takibi problemidir. | `monitoring` canli izleme var; background notification yok. | Foreground/background policy, yeni cihaz, encryption downgrade, gateway degisimi, DNS hijack suphesi bildirimi. | Uygulama acikken/foreground service ile yeni cihaz ve guvenlik drift bildirimi. |
| P1 | Wi-Fi Hizlandirma / Root-Cause Kocu | Kullanici "internet yavas" der ama sorun Wi-Fi mi ISP mi cihaz mi anlamaz. | Performans cozumu icin RSSI, kanal yogunlugu, latency, jitter, bufferbloat birlikte yorumlanmali. | `wifi_scan`, `performance`, `heatmap`, `monitoring` ayri olcuyor. | Tek teshis akisi: sinyal zayif, kanal kalabalik, router uzak, ISP yavas, bufferbloat, DNS yavas gibi neden siniflandirma. | "Yavasligin muhtemel nedeni" karti + 3 aksiyon onerisi. |
| P1 | Mesh / AP Yerlesim Planlayici | Kullanici router veya mesh node'u nereye koyacagini bilmiyor. | Wi-Fi hizinin buyuk kismi kapsama, duvar, mesafe ve kanal cakismasina bagli. | `heatmap` sinyal haritasi var; yerlesim onerisi ve what-if yok. | Heatmap + RSSI + dead zone ile router/mesh yerlestirme onerisi, oda bazli tavsiye. | Heatmap sonucunda "router'i daha merkezi konuma tasi / mesh ekle" onerisi. |
| P1 | Router Firmware / CVE Takip Merkezi | Kullanici router yaziliminin eski veya riskli oldugunu bilmiyor. | Firmware guncellemeleri guvenlik aciklarini ve performans sorunlarini duzeltir. | `security` statik vulnerable router DB ile sinirli. | Vendor/model tespiti, firmware guncelleme rehberi, CVE/KEV guncellik kontrolu, otomatik guncelleme hatirlatmasi. | Vendor/model eslesirse "firmware kontrol et" rehberi ve risk etiketi. |
| P2 | Gizlilik, Veri Silme ve Guvenli Rapor Merkezi | Kullanici SSID, MAC, hostname, rapor gibi hassas verileri nasil yonetecegini bilmiyor. | Ag verileri kisisel veri olabilir; export ve paylasim riskli. | `reports`, `settings`, storage servisleri var; merkezi privacy hub yok. | Tum veriyi sil, retention ayari, export anonymization, rapor parolalama, MAC/SSID maskeleme. | Settings icinde "Tum yerel veriyi sil" + rapor anonimlestirme default ON. |

## Alt Ozellikler Tablosu

| Mevcut Feature | Var Olan Kabiliyet | Eksik / Iyilestirme | Kullaniciya Etkisi | Onerilen Aksiyon | Oncelik |
|---|---|---|---|---|---|
| `wifi_scan` | Wi-Fi aglarini, kanal, RSSI, security, WPS/PMF, width, standard bilgileriyle tariyor. | 6GHz/Wi-Fi 6E ve DFS kanal farkindaligi eksik. | Yeni routerlarda eksik/yanlis kanal onerisi cikabilir. | 6GHz kanal listesi, ulke/regulasyon profili ve DFS etiketi ekle. | P1 |
| `wifi_scan` | Kanal yogunlugu ve en iyi kanal hesabi var. | Throughput/PHY rate tahmini yok. | Kullanici "hangi kanal daha hizli olur?" sorusuna net cevap alamiyor. | Wi-Fi standardi + channel width + RSSI ile tahmini performans etiketi uret. | P1 |
| `wifi_scan` | Multi-pass snapshot ve karsilastirma var. | Android scan throttling ve tekrar tarama feedback'i zayif. | Kullanici tarama calismadi sanabilir. | "Android tarama limiti, son onbellek kullaniliyor" aciklamasi ve backoff timer goster. | P2 |
| `network_scan` | LAN cihaz kesfi, port scan, mDNS, UPnP, exposure score var. | Cihaz guven puani tek ve anlasilir degil. | Ev kullanicisi hangi cihaz tehlikeli anlayamaz. | Host kartina risk nedeni + "ne yapmaliyim?" onerisi ekle. | P0 |
| `network_scan` | Acik port ve servis banner okuyor. | Rogue DHCP / gateway degisimi tespiti yok. | Sahte gateway veya yanlis DHCP ciddi MITM riski yaratir. | Gateway MAC baseline, DHCP sunucu gozlemi ve degisim uyarisi ekle. | P0 |
| `network_scan` | IPv4 subnet tarama var. | IPv6 destegi yok. | Modern aglarda bazi cihazlar gorunmeyebilir. | IPv6 neighbor discovery / local network kisitlari icin platform bazli destek planla. | P2 |
| `security` | WPA/WPA2/WPA3, WPS, evil twin, DNS, captive portal, ARP spoofing heuristikleri var. | Risk skoru kullanici baglamina gore kalibre degil. | Ev agi, kafe Wi-Fi ve misafir agi ayni agirlikla yorumlanabilir. | Network profile: `home`, `public`, `guest`, `unknown`; skor agirliklarini buna gore ayarla. | P0 |
| `security` | TrustedNetworkProfile ve drift bulgulari var. | Mesru mesh ile evil twin ayrimi zayif. | Yanlis pozitif kullaniciyi gereksiz panige sokar. | Ayni vendor/OUI, RSSI paterni, channel plan ve mesh isimlerini hesaba kat. | P0 |
| `security` | DNS leak/hijack ve captive portal testleri var. | Public Wi-Fi icin sade guvenli kullanim akisi yok. | Kullanici teknik bulgudan aksiyona gecemez. | Acik/public agda VPN, HTTPS, hassas islem, DNS uyari paneli goster. | P0 |
| `security` | Router vulnerability lookup statik JSON ile var. | CVE/veri guncelligi belirsiz. | Eski veriye gore yanlis guven hissi olusabilir. | DB versiyon/tarih etiketi, manuel update yolu, vendor/model guven seviyesi ekle. | P1 |
| `performance` | Latency, jitter, download, upload, loaded latency olcuyor. | Wi-Fi mi ISP mi ayrimi yok. | Kullanici router mi servis saglayici mi sorunlu anlayamaz. | Speed test sonucunu RSSI, kanal yogunlugu ve gateway ping ile birlestir. | P1 |
| `performance` | Cloudflare endpoint ile test var. | Veri tuketimi ve mobil baglanti uyarisi zayif. | Kullanici kotasini tuketebilir. | Test baslamadan tahmini veri kullanimi ve Wi-Fi baglanti kontrolu goster. | P0 |
| `performance` | Loaded latency olculuyor. | Bufferbloat insan-okunur skora cevrilmiyor. | Oyun/video gorusme sorunlari anlasilmaz kalir. | A-F veya "iyi/orta/kotu" bufferbloat etiketi ekle. | P1 |
| `monitoring` | RSSI graph, kanal spektrumu, topoloji ve ping var. | Background monitoring yok. | Sinyal dususu veya yeni cihaz olaylari kacirilir. | Pil dostu foreground service + kritik event notification planla. | P0 |
| `monitoring` | Topoloji grafigi var. | Topoloji L2 dogrulamasi varsayimsal. | Kullanici gercek baglanti haritasi sanabilir. | "Tahmini topoloji" etiketi, evidence aciklamasi ve confidence degeri ekle. | P2 |
| `monitoring` | Canli tarama stream'i var. | Pil/throttling/backoff politikasi zayif. | Surekli tarama bataryayi tuketebilir ve Android limitlerine takilir. | App lifecycle aware polling, exponential backoff ve kullanici interval kontrolu ekle. | P1 |
| `heatmap` | AR/kamera overlay + IMU ile RSSI heatmap uretiyor. | Router/mesh yerlesim onerisi yok. | Harita var ama kullanici ne yapacagini bilemeyebilir. | Dead zone tespitinden otomatik "router'i tasi / mesh ekle" onerisi uret. | P1 |
| `heatmap` | Bagli agin sinyalini haritaliyor. | Floor plan import/export ve coklu kat destegi sinirli. | Buyuk evlerde olcum kullanissizlasir. | Kat/oda etiketleme, oturumlari katlara ayirma, PNG/PDF export entegrasyonu ekle. | P2 |
| `reports` | Wi-Fi snapshot icin JSON/CSV/HTML/PDF export var. | LAN, security, speed test, heatmap raporlari eksik. | Kullanici tam ev agi raporu cikaramaz. | "Ev Agi Saglik Raporu" formati: guvenlik + hiz + cihaz + kapsama. | P1 |
| `reports` | Paylasma/kaydetme var. | Anonimlestirme ve parola/sifreli export yok. | MAC/SSID/hostname disari sizabilir. | SSID/BSSID/MAC maskeleme default ON; PDF parola opsiyonu ekle. | P0 |
| `dashboard` | Ag ozeti, guvenlik skoru, kanal onerisi ve bildirim sheet'i var. | Ilk acilis ve "ne yapmaliyim?" akisi zayif. | Ev kullanicisi feature'lar arasinda kaybolur. | Dashboard'a "Bugun yapilacak 3 guvenlik/hiz aksiyonu" alani ekle. | P1 |
| `dashboard` | Security score gosteriyor. | Skor aciklanabilirligi yok. | Kullanici 68 puanin neden 68 oldugunu anlayamaz. | Skor breakdown bottom sheet: sifreleme, WPS, DNS, cihaz riski, kanal. | P1 |
| `settings` | Tema, dil, scan interval, strict safety, deep scan ayarlari var. | Veri saklama/silme merkezi eksik. | Kullanici tarama gecmisini ve raporlari kontrol edemez. | Retention ayari, tum veriyi sil, feature bazli gecmis silme ekle. | P0 |
| `settings` | Strict safety mode var. | Per-network policy yok. | Evde deep scan acik, public Wi-Fi'de kapali gibi guvenli ayrim yapilamaz. | Ag profiline gore ayar: home/public/guest; public agda agresif tarama kapali. | P0 |
| `ai` | ONNX ile cihaz siniflandirma ve override store var. | Explainability ve dusuk guven fallback'i zayif. | Yanlis cihaz tipi yanlis guvenlik onerisine yol acabilir. | "Neden boyle siniflandirildi?" evidence: vendor, hostname, portlar; dusuk guvense Unknown. | P2 |
| `ai` | Kullanici label override saklanabiliyor. | Model card / veri seti / versiyon belgesi yok. | Kullanici siniflandirmaya ne kadar guvenecegini bilemez. | Model versiyonu, egitim kapsami, bilinen limitler ve confidence kalibrasyonu ekle. | P2 |
| `app_shell` | Dashboard, Discovery, Operations navigasyonu var. | Router guvenlik sihirbazi gibi yonlendirilmis journey yok. | Kullanici tek tek sayfa gezmek zorunda kalir. | Ilk taramadan sonra "Ev agini guvene al" akisi baslat. | P1 |
| `app_shell` | Onboarding izinleri anlatiyor. | "Yalnizca yetkili oldugun agi tara" ve public/private secimi net degil. | Yanlis kullanim ve hukuki/guvenlik riski olusur. | Ilk LAN/security taramasindan once yetki onayi ve ag tipi secimi goster. | P0 |

## Ozet Oncelik

Once `P0` guvenli kullanim, veri gizliligi, public Wi-Fi modu, cihaz guven puani ve router sertlestirme tamamlanmali. Sonra `P1` tarafinda hiz teshis kocu, heatmap yerlesim onerileri, speed/RSSI/kanal korelasyonu ve tam ev agi raporu uygulamanin degerini ciddi artirir.
