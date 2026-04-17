# Security Feature

Torcav'ın **defansif güvenlik merkezi**: ağ güvenlik skorlaması, WPA2/WPA3 analizi, DNS güvenlik testi, captive portal ve deauth heuristikleri, trust profili ve drift tespiti.

## Bu Feature Ne İşe Yarıyor?

`security` feature, diğer feature'lardan gelen ham veriyi (WiFi beacon, LAN hostları, DNS yanıtları) **insan-okunabilir risk değerlendirmelerine** dönüştürür. Her ağa 0-100 arası bir skor verir, bulguları kategorize eder (wifi config, DNS, LAN exposure, hardware vuln), ve güvenilir profil (baseline) oluşturarak değişiklikleri (drift) raporlar.

Kritik: **aktif saldırı vektörü yoktur** — kimlik doğrulama denemesi, deauth gönderme, ARP zehirleme, credential harvesting yapılmaz. Tüm tespit pasif sinyallerden heuristiktir.

## Yaptıkları Neler?

### Domain entity'leri

- **SecurityAssessment**: ağ başına skor + findings + riskFactors.
- **SecurityFinding**: yapılandırılmış bulgu — `ruleId`, `category` (wifiConfiguration, lanExposure, dnsSecurity, hardwareVulnerability), `severity`, `confidence` (observed/suspected), `evidence`, `recommendation`.
- **Vulnerability**: legacy sadeleştirilmiş bulgu tipi.
- **TrustedNetworkProfile**: bir BSSID için "olması beklenen" profil; drift tespiti için baseline.
- **SecurityDriftFinding**: baseline ↔ mevcut durum farkı (şifrelenmiş WPA2 → WPA2-Enterprise'dan WPA2-PSK'ya düşüş gibi).
- **NetworkFingerprint**: beacon vendor element / WPS pin / OUI tabanlı parmak izi.
- **AssessmentSession**: bir tarama oturumu için agregeler.
- **SecurityEvent**: zaman bazlı olay; Dashboard NotificationSheet'i besler (`deauthBurstDetected`, `arpSpoofingDetected`, `captivePortalDetected`, `evilTwin`, `dnsHijack`).
- **VulnerableRouter**: router firmware CVE listesi — `vulnerability_data_source` JSON asset'inden okunur.

### Use-case'ler

- **SecurityAnalyzer** (545 satır): **ana beyin**. Ağa bakıp;
  - Açık/WEP → kritik (puan -80).
  - WPA/WPA2-Personal → orta (puan -30..-50).
  - WPA3-SAE → hafif (puan -5).
  - Evil-twin ipucu (aynı SSID farklı BSSID + yakın RSSI) → yüksek.
  - WPS açıksa → orta.
  - Hidden SSID → info.
  - Güvenilir profille kıyaslama, drift üretimi.
  - Donanım CVE eşlemesi (vendor+model → known vuln).
- **DeauthDetector**: RSSI sliding window + twin-AP varlığı ile deauth burst **heuristik** çıkarımı (root gerekmez).
- **ArpSpoofingDetector**: `/proc/net/arp` okuyup aynı MAC birden fazla IP'ye bağlıysa ve gateway dahilse *ARP poisoning şüphesi*.
- **CaptivePortalDetector**: Google'ın `connectivitycheck.gstatic.com/generate_204` probe'u; 204 değilse captive portal var.
- **DnsLeakTestUsecase** (+ `DnsDataSource`, 345 satır): Cloudflare, Google, Quad9, OpenDNS, AdGuard gibi resolver'ları kullanıp sistem DNS'ini kimle çözdüğünü (`whoami.akamai.net`, `debug.opendns.com`) tespit eder; DoH/DoT kullanımı ve hijack tespiti.
- **DnsSecurityUsecase**: DoT/DoH dayanım durumunu skorlar.
- **CheckRouterVulnerabilityUsecase**: local JSON DB'den vendor/model eşleşmesi.

### Data

- **SecurityRepositoryImpl** (656 satır): tüm use-case'leri birleştirip bir rapor üretir, SQLite'a yazar.
- **SecurityLocalDataSource** (292 satır): oturum, trust profile, event persistence.
- **VulnerableRouterDto** + `assets/data/` JSON'u: offline CVE lookup.

### Presentation

- **SecurityCenterPage** (173 satır): ana landing — her ağ için özet kart + filtre.
- **VulnerabilityLabPage** (479 satır): tüm testleri bir seferde çalıştıran "lab" modu: encryption + DNS + exposure.
- **WifiDetailsPage** (621 satır): tek ağın derin analiz sayfası.
- **Widgets**: `NetworkSecurityCard`, `DnsSecurityCard` (664 satır), `SecurityStatusRadar`, `SecurityTimelineView`, `ScanOverviewCard`, `SecurityAlerts`, `SecurityHeader`, `CyberGridBackground` (animasyonlu arka plan — `main.dart`'ta global olarak kullanılan).
- **Blocs**: `SecurityBloc`, `WifiDetailsBloc`, `NotificationBloc`.

## Hangi Özellik Eksik?

- **Aktif packet capture yok**: gerçek deauth/beacon flood/rogue DHCP tespiti için monitor mode gerekir — Flutter'dan erişilemiyor. Heuristikler yanlış-negatif riski taşıyor, belge edilmeli.
- **WPA3 derinliği sığ**: SAE transition mode, SUITE-B, OWE saptanıyor mu? entity'de `wpa3` var ama alt modları ayrıştırılmıyor.
- **Zero Trust envanter yok**: cihaz ve kullanıcı bazlı trust puanı, sadece BSSID.
- **MITM canlı test yok**: DNS hijack şüpheli olduğunda kullanıcıya daha güçlü "VPN'i aç" rehberi ve referans DNS kıyaslama flow'u zayıf.
- **Router CVE DB statik**: `assets/data/` içindeki JSON manuel güncelleniyor olmalı; otomatik CVE feed (NVD, CISA KEV) yok.
- **Evil-twin ayırt ediciliği**: aynı SSID farklı BSSID'i evil-twin sayıyor ama meşru mesh (aynı SSID, coordinated BSSID) ile ayrımı zayıf.
- **Certificate transparency / HSTS preload** kontrolü yok.
- **Background monitoring**: uygulama kapalıyken NotificationBloc olay üretmiyor (arka plan izni/foreground service yok).
- **Risk skoru kalibrasyonu**: puanlar sabit düşüşler — bağlama (trusted ağ, ev vs kafe) göre ağırlık ayarlanmıyor.
- **Remediation aksiyonları**: "router ayarlarını aç" gibi deep-link Turkcell/TTNet routerları için yok.
- **Kapsamlı log / SIEM export**: olayları syslog/CEF formatında dışa verme yok.

## Etik / Legal Olarak Neler Eklenebilir?

- **"Pasif gözlem" sözleşmesi**: uygulamanın kod yorumlarında ve Settings > About sayfasında "hiçbir frame enjeksiyonu, kimlik doğrulama denemesi veya aktif saldırı yapılmaz" metni hukuki bir beyan olarak yer almalı. Bu TCK 243/244 ve AB Directive 2013/40 kapsamında kullanıcıyı korur.
- **Deauth heuristik belirsizliği**: "deauthBurstDetected" olayı `severity: high` olarak işaretleniyor; ancak heuristik olduğu için yanlış pozitifler komşuyu haksız yere suçlatabilir. UI'da "bu bir kesin tespit değildir" notu şart; evidence kısmının ham hali kullanıcıya gösterilmeli.
- **ARP Spoofing evidence**: tespit yapıldığında raporda yalnızca **gateway IP + çakışan MAC'in OUI kısmı** görüntülenmeli; tam MAC adresleri (3. taraf cihazların) export edilmemeli.
- **DNS test "whoami" sorgusu**: `whoami.akamai.net` ve `debug.opendns.com` sorguları DNS sağlayıcılarına cihazın olduğunu sinyaller — gizlilik sayfasında açıklanmalı ve opt-out imkanı tanınmalı.
- **Captive portal probe**: `connectivitycheck.gstatic.com` Google'a sinyal gönderir; kullanıcıya "ağ durumu testi Google'a 1 byte istek atıyor" bildirimi.
- **Komşu AP'lere bakış**: security analiz komşu ağları da skorluyor; rapora eklenirken anonymize default. Komşu ağın BSSID'sini üçüncü tarafla paylaşmak GDPR kapsamında veri işleme sayılabilir.
- **Güvenilir profil (trusted profile) verisi**: tüm TrustedNetworkProfile verisi yerel şifrelenmeli (`flutter_secure_storage` 10.0) — çalınırsa ev ağının imzası dışarı sızar.
- **Vulnerability Lab dili**: "Vulnerable" gibi kesin ifadeler yerine "Potentially vulnerable" / "Configuration weakness observed"; yasal feragat ekranda sabit görünür olmalı.
- **Enterprise kullanım reddiyesi**: uygulama "penetration test" aracı değildir — kurumsal ağda kullanımı yöneticinin yazılı onayına tabidir; bu About sayfasında belirtilmeli.
- **Çıktı imzalanması**: security raporunun PDF export'u imzalanarak "kullanıcının gördüğü halinden sonra değiştirilmediği" ispatlanabilir (bkz. Reports feature).

## Hangi Sorunları Çözüyor?

- **Teknik bilgisi olmayanın güvenliğini öğrenmesi**: "WPA2 PSK", "WPS", "DoT" gibi kavramları rapor satırları ile anlaşılır hale getirir.
- **Baseline + drift**: "router'ım dün akşamdan beri farklı davranıyor" gibi algı, objektif drift raporuna dönüşür.
- **Açık ağ uyarısı**: kafe/havaalanı Wi-Fi'sında otomatik kritik uyarı + VPN önerisi.
- **Captive portal farkındalığı**: kullanıcı neden internete çıkamadığını (portal giriş bekliyor) anında görür.
- **DNS merkezli tehditler**: hijack, ISP-injection, güvenilmez resolver — görünmez tehditleri görünür yapar.
- **Ev IoT güvenliği**: LAN exposure + AI cihaz sınıflandırması + router CVE'leri birleştiğinde "odaya yeni taktığım kamera internete açık" gibi sorunları gün yüzüne çıkarır.
- **Rapor oluşturma**: SOC/ISS'e gösterilecek delil.
