# Monitoring Feature

Canlı sinyal izleme, kanal yoğunluğu grafikleri, ağ topolojisi görselleştirme ve (pasif) deauth olay takibi.

## Bu Feature Ne İşe Yarıyor?

`monitoring` feature, **zamanla değişen** ağ metriklerini izler ve görselleştirir. Tek bir anlık fotoğraf yerine sürekli bir akış izlenir: RSSI zaman grafiği, kanal doluluğu, komşu AP'ler, topoloji (hangi cihaz hangi ağa bağlı), ve pasif olarak yakalanan deauth eventleri.

Bu feature WiFi Scan'in "bir defa bak" yaklaşımını, Dashboard'un "özet" yaklaşımını tamamlayan **canlı gözlem panelidir**.

## Yaptıkları Neler?

### Topology (topoloji)

- **TopologyBuilder** (`domain/services/topology_builder.dart`): Wi-Fi tarama sonuçları (AP'ler) + LAN tarama sonuçları (hostlar) + bağlantı bilgisi (gateway, SSID, BSSID) birleştirilip bir **graf** üretilir.
- **NetworkTopology** entity: `TopologyNode` (router/AP/mobile/lan host) + `TopologyEdge` (wired / wireless / unknown).
- **TopologyBloc**: topoloji durumunu yönetir; ping use-case ile canlı latency.
- **TopologyPage** (1283 satır): custom painter (`topology_graph_painter`, 411 satır) ile animasyonlu düğüm-kenar grafiği çizer; `topology_info_sheet` ile tıklanan düğümün detayı.
- Ping senaryoları: `PingNodeUsecase` ile her düğüme RTT ölçümü.

### Canlı Sinyal / Kanal Analizi

- **MonitoringRepositoryImpl**: `WifiRepository.scanNetworks()`'i belirli aralıkta (default 5sn) tekrar çalıştırarak bir `Stream` üretir.
- **MonitoringBloc**: belirli BSSID veya tüm ağlar için canlı stream sağlar; `ChannelRatingEngine` ve tarihsel best-channel use-case ile zenginleşir.
- **ChannelRatingPage** (772 satır): kanal bazlı yoğunluk / çakışma puanları.
- **SignalGraphPage** (291 satır): zaman eksenli RSSI çizgi grafiği (`fl_chart`).
- **ChannelSpectralChart** + **ChannelHistoryChart** (1134 satır): kanal spektrumu ve geçmiş eğilim görüntüleri.

### Heatmap ve Temporal Heatmap (eski)

- **TemporalHeatmapPage** (108 satır), **presentation/bloc/heatmap_bloc.dart** (100 satır) ve `monitoring/domain/entities/heatmap_point.dart` (18 satır) — bu dosyalar yeni `features/heatmap` feature'ı ile örtüşüyor; **duplication ve temizlik adayı**.

### Deauth olay takibi

- **DeauthEvent** + **DeauthFrame** entity'leri: kötü niyetli deauthentication frame'lerini (yakalanabildiği kadarıyla) raporlamak için veri yapısı var.
- **Not**: Dart/Flutter'dan doğrudan monitor mode'a erişim olmadığı için gerçek yakalama için ayrı bir native plugin / harici cihaz (USB Wi-Fi, Pineapple) gerekir; entity'ler var ama datasource boş görünüyor — pasif-sinyal-tabanlı heuristik (ani RSSI düşüşü + disconnect) ile tahmin yapılabilir.

## Hangi Özellik Eksik?

- **Deauth detection çalışmıyor**: entity'ler var, datasource/plugin yok. Deauth imkânsız yapılıp UI'dan da kaldırılmalı ya da heuristik + native köprü ile tamamlanmalı.
- **Heatmap duplication**: `monitoring/presentation/bloc/heatmap_bloc.dart` ve entity, yeni `features/heatmap` ile karışıyor — bunlardan biri silinmeli (muhtemelen monitoring'deki eski kalıntılar).
- **Throttling yok**: `monitoringRepository.monitorNetworks()` sonsuz `while(true)` döngüsü; cancellation ancak subscription cancel ile olur. Ama uygulama arka plana geçtiğinde tarama devam ediyor → pil tüketimi.
- **Error recovery zayıf**: Bloc içinde `_MonitoringError` var ama exponential backoff yok; geçici izin hatasında sürekli aynı hatayı basabilir.
- **Zaman serisi saklama**: RSSI grafiği sadece o oturum için belleğe alınıyor; kalıcılık yok (SQLite'a yazıp saatler sonra da görüntülemek yok).
- **Topoloji doğrulama**: AP ↔ gateway bağlantısı varsayımsal — gerçek L2 keşfi (CDP/LLDP/LLTD) mevcut değil.
- **MAC randomization**: iOS/Android son sürümlerde MAC adresleri randomize; topoloji'de "aynı cihaz" olarak tekilleştirme zor. Bu durum raporlanmıyor.
- **Background notification**: bir BSSID izlenirken uygulama kapatıldığında kullanıcıya "sinyal düştü" push-notification gelmiyor.
- **Anomali tespiti**: RSSI'nin ani düşüş / kalkmasına dair eşik uyarısı yok.
- **Exportable logs**: `monitoring` verilerini CSV / JSON olarak dışa aktaracak akış yok (Reports feature buna bağlanabilir).

## Etik / Legal Olarak Neler Eklenebilir?

- **Pasif olma vaadi**: kod yorumlarında ve UI'da "bu modül **yalnızca pasif** olarak dinler, hiçbir frame gönderilmez" açıkça yazılmalı. Monitor-mode veya injection olmadığı test edilmeli ve CI'da assertion bulunmalı.
- **Deauth event loglarının içeriği**: eğer gerçekten yakalanırsa, `sourceMac`/`targetMac` alanları 3. tarafa ait cihazların MAC'ini içerir → KVKK'a göre kişisel veri. Yerel tutulmalı, 24 saat sonra otomatik silinmeli (retention policy).
- **Komşu BSSID kaydetme**: topoloji ekranı komşu AP'leri de gösteriyor; bu verinin **paylaşılması** (PDF rapor, Slack) GDPR ve KVKK 6. madde kapsamına girer. Export butonunda "komşu ağlar anonimleştirilsin mi?" onay kutusu.
- **MAC adresi anonimleştirme**: UI'da MAC'in yalnızca OUI kısmını (ilk 3 byte) göstermek varsayılan olmalı; kullanıcı talep ederse tam MAC açılmalı (Settings > Privacy).
- **5651 uyumluluğu**: Türkiye'de genel kullanıma açık Wi-Fi'da trafik loglamak "erişim sağlayıcı" yükümlülüğüdür; uygulama "kişisel kullanım" dışında kullanılırsa yasal yükümlülük doğabilir — Terms of Use'da belirtilmeli.
- **FCC/ETSI uyumluluğu**: "kanal rating" gibi ölçümler zararsız ama kullanıcı sonuçları ticari danışmanlığa çevirirse sertifikalı ölçüm cihazı gerekebilir → "bu veri sertifikalı site-survey yerine geçmez" ibaresi.
- **Şifrelenmiş local storage**: izleme verileri `core/storage` üzerinden `flutter_secure_storage` ile şifrelenmeli (dependency zaten override edilmiş, v10 kullanılıyor).

## Hangi Sorunları Çözüyor?

- **"Ne zaman sinyal düştü?" sorusu**: zaman serisi grafiği ile objektif kayıt.
- **Kanal seçim optimizasyonu**: saat-saat en az çakışan kanalı izleyip *tarihsel* en iyi kanal önermeye yarıyor (peak saatte tercih).
- **Ağ haritası okunabilirliği**: metin listesi yerine düğüm-kenar grafiğiyle "kim neye bağlı" sorusu anlaşılır hale geliyor.
- **Anomaly spotting (manuel)**: kullanıcı kendi ağındaki garip aktiviteleri gözle yakalayabiliyor (örn. bir mobil düğüm gece 3'te ping latency'si yüksek).
- **Teknik kullanıcı için zengin veri**: ev kullanıcısının işine yaramayan ama bir IT uzmanının değer verdiği kanal spektrumu, RSSI geçmişi gibi veriler tek yerde.
