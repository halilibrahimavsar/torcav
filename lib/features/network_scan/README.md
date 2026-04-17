# Network Scan (LAN Discovery) Feature

LAN üzerinde host keşfi, port taraması, servis parmak izi, mDNS/UPnP bulguları ve maruziyet (exposure) skorlaması.

## Bu Feature Ne İşe Yarıyor?

`network_scan` feature, kullanıcının **bağlı olduğu LAN içindeki cihazları bulur** ve her cihazın ne servis yayınladığını tespit eder. Bu, Torcav'ın "kendi ağını tanı" vaadinin ikinci ayağıdır (WiFi tarafını `wifi_scan` yapar; LAN tarafını burası). Keşfedilen hostlar AI feature'ı ile sınıflandırılır, Security feature'ı ile risk skoru atanır, Reports ile PDF'e dönüşür.

## Yaptıkları Neler?

### Veri kaynakları

- **ARP data source** (`arp_data_source.dart`, 244 satır):
  - `/proc/net/arp` (Android), native ARP tablosu okuma — MAC ↔ IP eşlemesi.
  - Ağ sınıfına göre subnet üzerinden ping-sweep.
- **mDNS data source** (`mdns_data_source.dart`): `multicast_dns` paketi ile `_http._tcp`, `_airplay._tcp` vb. servis isimlerini toplar; hostname çıkarır.
- **UPnP data source** (`upnp_data_source.dart`): SSDP `M-SEARCH` ile UPnP cihazlarını (TV, Sonos, kamera) keşfeder.
- **Port scan data source** (`port_scan_data_source.dart`, 127 satır):
  - 25 riskli port için TCP connect scan.
  - `Isolate.run` ile UI bloklanmadan paralel tarar.
  - Banner grabbing (telnet/http/ssh/ftp): ürün/versiyon bilgisini "iyi niyetle" okur, brute force yapmaz.
- **LAN scan history** (`lan_scan_history_local_data_source.dart`): SQLite'ta oturumları saklar.

### Domain

- **HostScanResult**: IP, MAC, vendor, hostname, osGuess, latency, servisler, exposureFindings, exposureScore, deviceType.
- **ServiceFingerprint**: bir host üzerindeki servis (port + ürün + versiyon).
- **LanExposureFinding**: JSON kural tabanlı bulgu (`ruleId`, `risk`, `evidence`, `remediation`).
- **VulnerabilityFinding** (legacy): geri uyumluluk için sadeleştirilmiş bulgu.
- **ArpEntry**, **NetworkDevice**: düşük-seviye veri nesneleri.
- **NetworkScanRepositoryImpl** (149 satır): tüm datasource'ları orkestre ederek `HostScanResult` listesi üretir.
- **NewDeviceDetector**: geçmiş oturumla kıyaslayıp yeni çıkan MAC'leri tespit eder.

### Presentation

- **NetworkScanPage** (1039 satır): radar animasyonlu keşif ekranı, host kartları, filter/sort.
- **NetworkScannerRadar** (149 satır): dönen radar görseli.
- **HostDeviceCard** (397 satır): tek cihazı kart halinde gösterir — vendor badge, açık port ikonları, exposure score renk bandı.

## Hangi Özellik Eksik?

- **SNMP / NetBIOS discovery yok**: Windows domain ortamlarında hostname okumak için NetBIOS, yönetilebilir cihazlar için SNMP useful olur.
- **IPv6 desteği yok**: sadece IPv4 subnet taranıyor.
- **DHCP sunucu tespiti** yok: ağda ikinci bir DHCP (rogue) var mı kontrolü yapılmıyor.
- **OS fingerprinting sığ**: `osGuess` basit TTL/banner heuristik; TCP/IP fingerprint (nmap -O benzeri) yok.
- **Scan iptali ve ilerleme**: 25 port × N host + mDNS + UPnP paralel çalışıyor, ancak iptal butonu davranışı ve partial-result gösterimi tam ergonomik değil.
- **Port timeout konfigürasyonu**: `_timeoutMs = 500` sabit; yavaş ağlarda false-negative'e sebep.
- **Rate limiting**: çok agresif tarama router'larda IDS tetikleyebilir; adaptif hız kontrolü yok.
- **Servis sürüm eşleştirme veritabanı** yok: banner'dan okunan "OpenSSH 7.2" → CVE eşleşmesine Vulnerability Lab dışında bağlantı yok.
- **PCAP kaydetme** yok: troubleshooting için traffic dump desteklemiyor.
- **Platform uyumluluğu**: `/proc/net/arp` iOS'ta yok; iOS için LAN tarama sınırlı (Apple Local Network privacy).
- **Hostname önbellekleme**: her oturumda aynı mDNS cevapları baştan çözülüyor, cache yok.
- **Offline vendor DB**: MAC OUI → vendor lookup (IEEE OUI) nerede? Dependency `unified_flutter_features` içinde varsayımlı; README'de kaynağı netleşmeli.

## Etik / Legal Olarak Neler Eklenebilir?

- **"Yalnızca kendi ağında kullan" uyarısı** (kritik): LAN discovery ve port taraması Türk Ceza Kanunu **243** (bilişim sistemine girme), 244 (verileri engelleme) ve ABD CFAA / AB NIS2 kapsamında **açık yetki olmadan yapıldığında yasa dışıdır**. Sayfa açılırken kullanıcı onay kutusuna "bu ağı taramaya yetkim var" onayı vermeli; onay yoksa tarama başlamamalı.
- **Banner grabbing etik not**: uygulama banner'ları okuyor ancak hiçbir şekilde authentication denemiyor; bu kod yorumlarında ve README'de vurgulanmalı ve CI'da regression testi olmalı.
- **MAC ve hostname gizlilik**: başka kullanıcılara ait cihazların (ev içinde bile) MAC ve hostname (örn. "Ayşe'nin iPhone'u") kişisel veri sayılır. Export/report akışında otomatik anonymize seçeneği default açık olmalı.
- **Port scan mesafesi**: yalnızca /24 subnet ile sınırlı kalmalı; kullanıcı /16 veya public IP girerse tarama reddedilmeli (guardrail).
- **IDS tetiklemesinden sorumluluk**: kurumsal ağda tarama başlatılırsa SOC alarm verir; "kurumsal ağda kullanma" uyarısı.
- **Rate limiter**: ağ cihazlarını doldurmamak için saniyede maksimum bağlantı sayısı sınırı + kullanıcıya açıklama.
- **Veri minimizasyonu**: geçmiş oturumlarda servis banner'larının tamamı saklanmamalı; yalnızca "ürün adı + versiyon" (gerekli-yeterli).
- **GDPR/KVKK data subject rights**: "tüm tarama geçmişimi sil" butonu Settings içinde olmalı (wipe API zaten datasource'larda mevcut mu, doğrulanmalı).
- **Yasal feragat (disclaimer) metni**: Rapor üstüne ve ilk tarama öncesinde gösterilmeli.

## Hangi Sorunları Çözüyor?

- **Envanter görünürlüğü**: "ağımda hangi cihazlar var?" sorusuna tam, canlı bir cevap.
- **Yabancı cihaz tespiti**: `NewDeviceDetector` ile önceki oturumda olmayan bir MAC görünürse haberdar olma (rogue device).
- **Exposure skorlaması**: cihaz başına kural tabanlı bulgu (telnet açık, SMB v1, VNC internetten erişilebilir) ve remediation önerileri.
- **Downstream zenginleştirme**: çıktısı AI device classifier, Security analyzer ve Reports feature'ları için temel veri.
- **Basit troubleshooting**: "yazıcı görünmüyor" gibi problem tespiti (mDNS/UPnP keşfi).
- **Eğitim değeri**: kullanıcıya IoT cihazlarının neyi yayınladığını görme fırsatı vererek farkındalık yaratıyor.
