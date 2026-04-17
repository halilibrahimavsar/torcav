# Wi-Fi Scan Feature

Torcav'ın **ana sensörü**: çevredeki Wi-Fi ağlarını pasif olarak tarar, kanal doluluğu / bant istatistikleri / geçmiş karşılaştırma üretir.

## Bu Feature Ne İşe Yarıyor?

`wifi_scan` feature, uygulamanın temel veri tedarikçisidir. Platform-spesifik backend'ler (`wifi_scan` Flutter plugin'i, Android native method channel, Linux `iw/nmcli`) üzerinden çevredeki AP'leri toplar; zengin metadata (WPS, PMF, channel width, Wi-Fi standardı) çıkarır; oturum halinde kalıcılaştırır; Dashboard, Security, Heatmap, Monitoring ve Reports feature'larının tamamı bu feature'ın ürettiği `ScanSnapshot`'ı tüketir.

## Yaptıkları Neler?

### Domain

- **WifiNetwork**: SSID, BSSID, dBm, channel, frequency, security (open/wep/wpa/wpa2/wpa3), vendor (OUI), isHidden, channelWidthMhz (20/40/80/160/320), wifiStandard (Wi-Fi 4/5/6/7), hasWps, hasPmf, rawCapabilities, apMldMac (Wi-Fi 7 multi-link).
- **ScanSnapshot**: bir oturumu oluşturan agregeler — networks, channelStats, bandStats, backendUsed, interfaceName, timestamp.
- **ChannelOccupancyStat**: kanal başına yoğunluk, öneri metni.
- **BandAnalysisStat**: 2.4GHz ve 5GHz bandlarının karşılaştırması.
- **ChannelRating** + **ChannelRatingSample**: kanal kalite puanı + zaman serisi örneği.
- **WifiObservation**: tek bir tarama-pass'ındaki ölçüm (sample-level granular).
- **ScanRequest**: pass sayısı, interval, backend preference parametre torbası.

### Data

- **AndroidWifiDataSource** (171 satır): `wifi_scan` plugin + `wifi_extended_channel` (`core/platform/`) native method channel ile extended Android ScanResult alanlarını okur.
  - Android 9+ throttling (4 tarama / 2 dakika) biliyor, cache fallback yapıyor.
  - Permission.location isteniyor (Android WiFi tarama için zorunlu).
- **LinuxWifiDataSource** (264 satır): `iw`, `nmcli`, `wpa_cli` gibi CLI araçlarını çağırarak Linux desktop'ta tarama.
- **ScanSnapshotBuilder** (278 satır): multi-pass sonuçları merge edip stabil snapshot üretir (RSSI ortalaması, std sapması, OUI lookup).
- **WifiScanHistoryLocalDataSource** (239 satır): SQLite tabanlı tarama oturumu saklama.
- **ChannelRatingLocalDataSource**: kanal puanı zaman serisi SQLite.
- **FavoritesStore**: kullanıcının "yıldızladığı" BSSID'ler.

### Servis katmanı

- **ScanSessionStore**: bellekte en son snapshot'ı tutar; diğer feature'lar bu referans üzerinden çalışır.
- **ChannelRatingEngine** (135 satır): 2.4GHz'de 1..13, 5GHz'de 36..165 standard kanallar; ağ yoğunluğu + çakışma (co-channel, adjacent-channel) analizi.
- **ScanComparisonService**: iki snapshot'ı farklaştırır (yeni gelen/yok olan BSSID, RSSI değişimi).

### Use-case'ler

- **ScanWifi**: tarama tetikleyici.
- **GetHistoricalBestChannel**: tarihsel verilere göre en iyi kanal önerisi.

### Presentation

- **WifiScanPage** (410 satır): ana sayfa — radar animasyonu + ağ kartları + filtre.
- **ScanComparisonPage** (267 satır): iki oturum kıyaslama.
- **Widgets**: `WifiNetworkCard`, `WifiScannerRadar` (dönen neon radar), `WifiBentoHeader`, `ScanModeToggle`, `SearchFilterBar`, `RecommendationBanner`, `ChannelRatingLink`, `WifiScanErrorView`.
- **Bloc**: `WifiScanBloc` + event/state ikilisi.

## Hangi Özellik Eksik?

- **iOS platform desteği zayıf**: iOS'ta Wi-Fi tarama API'si yok (Apple kısıtı); yalnızca bağlı SSID okunuyor. README'de netleştirilmeli.
- **6GHz (Wi-Fi 6E) desteği**: kod `_channels5` ile sınırlı; 5.925–7.125 GHz bandı için kanal listesi yok.
- **DFS kanal işleme**: 5GHz DFS kanalları (52-64, 100-140) özel tarama limitlerine sahip; `channel_rating_engine` fark gözetmiyor.
- **Throughput tahmini**: `WifiNetwork` içinde `channelWidth` + `wifiStandard` var ama "tahmini PHY rate" (örn. Wi-Fi 6 + 160MHz + 4x4 = 2.4 Gbps) üretilmiyor.
- **MIMO / spatial streams**: AP'nin antennasayısı okunmuyor.
- **Mesh (802.11s / vendor mesh) tespiti**: Eero, Deco vb. mesh AP'leri ayırt edilmiyor.
- **Live streaming**: `Stream<ScanSnapshot>` paterni var ama `WifiScanBloc` tek-seferlik tarama üzerinde yoğunlaşmış; Monitoring feature kendi polling'ini yazmış.
- **Scan interval auto-back-off**: Android throttling'e rağmen kullanıcı tekrar tekrar tıklarsa belirgin feedback eksik.
- **BSSID randomization uyarısı**: Android 12+ / iOS 14+ sistem WiFi listesinde randomize MAC gösteriyor; kullanıcıya bu durum rapor edilmiyor.
- **OUI DB freshness**: OUI lookup `unified_flutter_features` paketi içinde; güncellik tarihi UI'da yok.
- **Çoklu NIC**: birden fazla WiFi arayüzü varsa seçim UI'da mevcut değil (`interfaceName` ScanSnapshot'ta kayıtlı ama seçilemiyor).
- **DFS radar detection**: radar algılandığında kanal değişimi (çıkarımsal) işaretlenmiyor.

## Etik / Legal Olarak Neler Eklenebilir?

- **Pasif tarama vaadi**: tarama "dinleme" (passive scanning) temelli olmalı; bazı platformlarda aktif probe request gönderebilir (`WiFiScan.startScan`) — bu durum README'de ve UI'da açıklanmalı. Aktif probe kullanıcı konumunu erişilebilir yapabilir.
- **BSSID gizliliği**: komşu ağların BSSID'si kişisel veri (AB WP29 Opinion 13/2011 konum-izlenebilirlik). Export akışlarında varsayılan maskeleme (sadece OUI + rastgele son 3 byte hash) açık olmalı.
- **Hidden SSID tarama**: `includeHiddenSsids` ayarı varsayılan `true`; oysa gizli SSID yayınlamayan ağları zorla probe etmek bazı yorumlara göre "discovery beyond intent" sayılabilir. Default'u `false` yapmak veya uyarı göstermek düşünülmeli.
- **Scan result retention**: SQLite'ta biriken tarama geçmişi süresiz; Settings'te "X gün sonra sil" politikası şart (GDPR "storage limitation").
- **Konum izni açıklaması**: Android WiFi taraması "fine location" iznine bağlı. Onboarding'te kullanıcıya "konum izni, Android'in zorunluluğudur; GPS verisi okunmaz, yalnızca Wi-Fi listesine erişmek için gereklidir" notu eklenmeli.
- **Başka kullanıcılara ait ağlarla ilgili sorumluluk**: komşu AP'lerin bulgularının kullanıcıya *yasal tavsiye* olarak sunulmaması ("komşunun ağında WPS açık" bilgisi kullanıcının kötüye kullanmasına yol açabilir) — Security feature'daki disclaimer burada da geçerli.
- **5G/6GHz regülasyon**: ülkeye göre izinli kanallar değişir (Türkiye ETSI, ABD FCC, Japonya ARIB); kullanıcıya "yasa dışı kanal kullanan AP'ler görebilirsin, bu senin sorumluluğunda değil" notu.
- **Linux CLI kullanımı**: `LinuxWifiDataSource` sudo isteyebilecek `iw dev scan` çağrıları yapıyor — izin matrixi belge edilmeli.

## Hangi Sorunları Çözüyor?

- **Tek çağrıda zengin envanter**: tek tarama ile 40+ alan (Wi-Fi 7 multi-link dahil) elde edilir.
- **Platform-agnostik soyutlama**: Android, Linux (ve ilerde iOS, macOS, Windows) backend'leri `WifiDataSource` arkasında saklı.
- **Kaliteli baseline**: multi-pass + RSSI std sapma sayesinde anlık gürültü yerine güvenilir ağ listesi.
- **Downstream feature'lara tek veri akışı**: Dashboard skor, Security analiz, Heatmap ölçüm, Monitoring trend hepsi aynı `ScanSnapshot`'tan beslenir.
- **Kanal optimizasyonu**: ev kullanıcısı için "hangi kanala geç" gibi net aksiyon.
- **Tarihsel karşılaştırma**: "dün 10 AP görüyordum, bugün 12 var, hangisi yeni?" — rogue AP tespiti için zemin.
