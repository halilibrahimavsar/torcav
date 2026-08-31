// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'TORCAV';

  @override
  String get subscriptionPremium => 'Premium';

  @override
  String get deviceTypeRouterGateway => 'Yönlendirici / Ağ Geçidi';

  @override
  String get deviceTypeAccessPoint => 'Erişim Noktası';

  @override
  String get deviceTypeDesktop => 'Masaüstü';

  @override
  String get deviceTypeLaptop => 'Dizüstü';

  @override
  String get deviceTypeMobileDevice => 'Mobil Cihaz';

  @override
  String get deviceTypeTablet => 'Tablet';

  @override
  String get deviceTypeSmartTV => 'Akıllı TV';

  @override
  String get deviceTypeNASStorage => 'NAS / Depolama';

  @override
  String get deviceTypeGameConsole => 'Oyun Konsolu';

  @override
  String get deviceTypeIPCamera => 'IP Kamera';

  @override
  String get deviceTypeSmartSpeaker => 'Akıllı Hoparlör';

  @override
  String get deviceTypeServer => 'Sunucu';

  @override
  String get deviceTypeUnknown => 'Bilinmiyor';

  @override
  String get notificationOpenAction => 'Bildirimi aç';

  @override
  String get quickScan => 'Hızlı Tarama';

  @override
  String get deepScan => 'Derin Tarama';

  @override
  String get scanModesTitle => 'Tarama Modları';

  @override
  String get scanModesInfo =>
      'Hızlı tarama yayınları dinler. Derin tarama aktif olarak ağları sorgular.';

  @override
  String get readyToScan => 'Taramaya Hazır';

  @override
  String get noSignalsDetected => 'Sinyal Tespit Edilmedi';

  @override
  String get compareWithPreviousScan => 'ÖNCEKİ TARAMA İLE KARŞILAŞTIR';

  @override
  String networksCount(int count) {
    return '$count AĞ';
  }

  @override
  String filteredNetworksCount(int count, int total) {
    return '$total AĞDAN $count TANESİ';
  }

  @override
  String get securityAlertsTooltip => 'Güvenlik uyarılarını görüntüle';

  @override
  String get livePulse => 'CANLI VERİ';

  @override
  String get liveLabel => 'CANLI';

  @override
  String get networkLogs => 'AĞ GÜNLÜKLERİ';

  @override
  String get connectedStatusCaps => 'BAĞLI';

  @override
  String get disconnectedStatusCaps => 'BAĞLANTI YOK';

  @override
  String get ipLabel => 'IP';

  @override
  String get gatewayLabel => 'AĞ GEÇİDİ';

  @override
  String get latestSnapshotTitle => 'Son Ağ Görünümü';

  @override
  String get noSnapshotAvailable => 'Görünüm verisi yok...';

  @override
  String get scanComparisonTitle => 'TARAMA KARŞILAŞTIRMA';

  @override
  String get comparisonNeedsTwoScans =>
      'Karşılaştırma için en az 2 tarama gereklidir.\n\nDeğişiklikleri görmek için başka bir tarama yapın.';

  @override
  String get noChangesDetected =>
      'Son iki tarama arasında değişiklik tespit edilmedi.';

  @override
  String newNetworksCountLabel(int count) {
    return 'YENİ ($count)';
  }

  @override
  String goneNetworksCountLabel(int count) {
    return 'GİDEN ($count)';
  }

  @override
  String changedNetworksCountLabel(int count) {
    return 'DEĞİŞEN ($count)';
  }

  @override
  String get hiddenLabel => '[Gizli]';

  @override
  String channelLabel(int channel) {
    return 'K$channel';
  }

  @override
  String get securityLabel => 'GÜVENLİK';

  @override
  String get initiatingSpectrumScan => 'SPEKTRUM TARAMASI BAŞLATILIYOR...';

  @override
  String get broadcastingProbeRequests =>
      'Yerel sinyal ortamı analiz ediliyor...';

  @override
  String get noRadiosInRange => 'Menzilde radyo bulunamadı';

  @override
  String get noNetworksMatchFilter => 'Filtreye uygun ağ bulunamadı';

  @override
  String get searchSsidBssidVendor => 'SSID, BSSID veya Satıcı Ara...';

  @override
  String sortPrefix(String option) {
    return 'Sırala: $option';
  }

  @override
  String get bandAll => 'TÜM BANTLAR';

  @override
  String get sortSignal => 'Sinyal';

  @override
  String get sortName => 'İsim';

  @override
  String get sortChannel => 'Kanal';

  @override
  String get sortSecurity => 'Güvenlik';

  @override
  String get sortByTitle => 'SIRALA';

  @override
  String recommendationTip(String channels, String band) {
    return '$band bandında en uygun kanallar: $channels';
  }

  @override
  String get channelInterferenceTitle => 'Kanal Girişimi';

  @override
  String get networksLabel => 'AĞLAR';

  @override
  String openCount(int count) {
    return '$count AÇIK';
  }

  @override
  String get avgSignalLabel => 'ORT. SİNYAL';

  @override
  String get notAvailable => 'YOK';

  @override
  String get dbmCaps => 'DBM';

  @override
  String get interfaceLabel => 'ARAYÜZ';

  @override
  String bandwidthLabel(int width) {
    return '$width MHz';
  }

  @override
  String get wifiStandardLegacy => 'Wi-Fi (eski)';

  @override
  String get wifiStandard4 => 'Wi-Fi 4 (802.11n)';

  @override
  String get wifiStandard5 => 'Wi-Fi 5 (802.11ac)';

  @override
  String get wifiStandard6 => 'Wi-Fi 6 (802.11ax)';

  @override
  String get wifiStandard7 => 'Wi-Fi 7 (802.11be)';

  @override
  String throughputLabel(int mbps) {
    return '$mbps Mbps';
  }

  @override
  String get dbmLabel => 'dBm';

  @override
  String signalTransition(int before, int after) {
    return '$before dBm → $after dBm';
  }

  @override
  String get deviceTypeWorkstation => 'İş İstasyonu';

  @override
  String get deviceTypePrinterIoT => 'Yazıcı/IoT';

  @override
  String get vendorAndroidRestricted => 'Android Cihazı (Kısıtlı)';

  @override
  String get vendorAndroidLimited => 'Bilinmiyor (Android Kısıtlı)';

  @override
  String frequencyLabel(int freq) {
    return '$freq MHz';
  }

  @override
  String get reportsTitle => 'RAPORLAR';

  @override
  String get saveReportDialog => 'Raporu Kaydet';

  @override
  String savedToast(String path) {
    return 'Rapor $path konumuna kaydedildi';
  }

  @override
  String get errorLabel => 'Hata';

  @override
  String get savePdfReportDialog => 'PDF Raporu Kaydet';

  @override
  String get scanning => 'Taranıyor...';

  @override
  String get shieldActive => 'Kalkan Aktif';

  @override
  String get threatsDetected => 'TEHDİT TESPİT EDİLDİ';

  @override
  String get intelligenceReportTitle => 'İSTİHBARAT RAPORU';

  @override
  String get discoveredEndpointsTitle => 'TESPİT EDİLEN UÇ NOKTALAR';

  @override
  String newDeviceFound(String ip) {
    return '1 yeni cihaz: $ip';
  }

  @override
  String newDevicesFound(int count) {
    return 'Ağınızda $count yeni cihaz bulundu';
  }

  @override
  String get targetSubnet => 'Hedef IP / Alt Ağ';

  @override
  String get scanAllCaps => 'TARA';

  @override
  String get refreshScanTooltip => 'Taramayı Yenile';

  @override
  String get band24Ghz => '2.4 GHz';

  @override
  String get band5Ghz => '5 GHz';

  @override
  String get band6Ghz => '6 GHz';

  @override
  String get no24GhzChannels => '2.4 GHz kanalı bulunamadı.';

  @override
  String get no5GhzChannels => '5 GHz kanalı bulunamadı.';

  @override
  String get no6GhzChannels => '6 GHz kanalı bulunamadı.';

  @override
  String get analyzing => 'Analiz ediliyor...';

  @override
  String get trafficLabel => 'TRAFİK';

  @override
  String get normalSpeed => 'NORMAL';

  @override
  String get fastSpeed => 'HIZLI';

  @override
  String get overdriveSpeed => 'MAKSİMUM';

  @override
  String get noTopologyData => 'Topoloji Verisi Yok';

  @override
  String get runScanFirst =>
      'Ağ haritasını oluşturmak için önce bir tarama yapın';

  @override
  String get retry => 'TEKRAR DENE';

  @override
  String get thisDevice => 'BU CİHAZ';

  @override
  String get gatewayDevice => 'AĞ GEÇİDİ';

  @override
  String get mobileDevice => 'MOBİL';

  @override
  String get deviceLabel => 'CİHAZ';

  @override
  String get iotDevice => 'NESNELERİN İNTERNETİ';

  @override
  String get analyzingNode => 'DÜĞÜM ANALİZİ';

  @override
  String get topologyGuideTitle => 'TOPOLOJİ REHBERİ';

  @override
  String get topologyGuideDesc =>
      'Ağ yapınızı ve cihaz bağlantılarını anlayın.';

  @override
  String get gatewayTitle => 'Ağ Geçidi';

  @override
  String get gatewayDesc =>
      'Ağınızın merkez beyni. Tüm dış trafik bu düğümden geçer.';

  @override
  String get deviceLayersTitle => 'Cihaz Katmanları';

  @override
  String get deviceLayersDesc =>
      'Cihazlar rollerine göre gruplanır: Çekirdek (Router/AP), Mobil ve IoT/Çevre birimleri.';

  @override
  String get pathwaysTitle => 'Bağlantı Yolları';

  @override
  String get pathwaysDesc =>
      'Modern ağlar kablolu (Ethernet) ve kablosuz (Wi-Fi) bağlantıları bir arada kullanır. Düz çizgiler yüksek hızlı kablolu hatları, kesikli çizgiler kablosuz bölümleri gösterir.';

  @override
  String get pingAction => 'GECİKMEYİ TEST ET';

  @override
  String get settingsTitle => 'AYARLAR';

  @override
  String get appearance => 'Görünüm';

  @override
  String get settingsLanguage => 'Dil';

  @override
  String get theme => 'Tema';

  @override
  String get settingsBackgroundStyle => 'Arka Plan Stili';

  @override
  String get backgroundNeomorphic => 'Neomorfik (Yüksek Performans)';

  @override
  String get backgroundClassic => 'Klasik Izgara';

  @override
  String get backgroundAuroraMesh => 'Aurora Mesh (Deneysel)';

  @override
  String get backgroundHoloSphere => 'Holografik Küre (3D)';

  @override
  String get backgroundNeuralPulse => 'Nöral Nabız (Animasyonlu)';

  @override
  String get backgroundAegisShield => 'Aegis Kalkanı';

  @override
  String get backgroundSignalTopography => 'Sinyal Topografyası';

  @override
  String get backgroundQuantumMesh => 'Kuantum Ağ';

  @override
  String get settingsScanBehavior => 'Tarama Davranışı';

  @override
  String get settingsDefaultScanPasses => 'Varsayılan Tarama Geçişi';

  @override
  String get settingsMonitoringInterval => 'İzleme Aralığı';

  @override
  String get settingsBackendPreference => 'Backend Tercihi';

  @override
  String get settingsIncludeHidden => 'Gizli Ağları Dahil Et';

  @override
  String get settingsStrictSafety => 'Sıkı Güvenlik Modu';

  @override
  String get settingsStrictSafetyDesc => 'Tehlikeli işlemleri kısıtla';

  @override
  String get settingsAiClassification => 'AI Cihaz Sınıflandırma';

  @override
  String get settingsAiClassificationDesc =>
      'Yerel AI destekli cihaz tespiti ve tanımlamayı etkinleştirir.';

  @override
  String get aiBadgeLabel => 'AI';

  @override
  String get darkTheme => 'Koyu';

  @override
  String get lightTheme => 'Açık';

  @override
  String get systemTheme => 'Sistem';

  @override
  String get sectionStatus => 'Durum';

  @override
  String get reportsSubtitle => 'Ağ Tarama ve Güvenlik İstihbaratı';

  @override
  String get exportOptionsTitle => 'DIŞA AKTARMA SEÇENEKLERİ';

  @override
  String get exportJson => 'JSON Olarak Dışa Aktar';

  @override
  String get exportHtml => 'HTML Olarak Dışa Aktar';

  @override
  String get exportPdf => 'PDF Olarak Dışa Aktar';

  @override
  String get printPdf => 'PDF Yazdır';

  @override
  String get navWifi => 'WIFI';

  @override
  String get backendLabel => 'ARKA UÇ';

  @override
  String get defenseTitle => 'SAVUNMA';

  @override
  String get knownNetworks => 'Bilinen Ağlar';

  @override
  String get noIdentifiedNetworks => 'Laboratuvar arşivinde tanımlanmış ağ yok';

  @override
  String get securityTimeline => 'Güvenlik Zaman Çizelgesi';

  @override
  String get noSecurityEvents => 'Kayıtlı güvenlik olayı yok';

  @override
  String get dnsSecurityTitle => 'DNS GÜVENLİĞİ';

  @override
  String get dnsPerformanceBenchmark => 'PERFORMANS TESTİ';

  @override
  String get dnsRecommended => 'ÖNERİLEN';

  @override
  String dnsResultLatency(int ms) {
    return '$ms ms';
  }

  @override
  String get osNetworkDevice => 'Ağ Cihazı (TTL≈255)';

  @override
  String get osWindows => 'Windows (TTL≈128)';

  @override
  String get osLinuxMacOS => 'Linux / macOS (TTL≈64)';

  @override
  String get osUnknown => 'Bilinmeyen İşletim Sistemi';

  @override
  String get osDetectedLabel => 'İŞLETİM SİSTEMİ';

  @override
  String get hostnameLookupAction => 'HOSTNAME SORGULA';

  @override
  String get osDetectAction => 'İŞLETİM SİSTEMİ TESPİT ET';

  @override
  String get portScanAction => 'PORT TARAMASI';

  @override
  String get latencyLabel => 'GECİKME';

  @override
  String get hostnameLabel => 'HOSTNAME';

  @override
  String get filterAll => 'HEPSİ';

  @override
  String get filterCore => 'ÇEKİRDEK';

  @override
  String get filterMobile => 'MOBİL';

  @override
  String get filterIot => 'IOT';

  @override
  String get filterOther => 'DİĞER';

  @override
  String get authLocalSystem => 'YEREL_SİSTEM';

  @override
  String remoteNodeIdLabel(String id) {
    return 'UZAK_DÜĞÜM_KİMLİĞİ: $id';
  }

  @override
  String logIdLabel(String id) {
    return 'GÜNLÜK_KİMLİĞİ: $id';
  }

  @override
  String targetLabel(String target) {
    return 'HEDEF: $target';
  }

  @override
  String get dnsStatusPending => 'BEKLENİYOR';

  @override
  String get dnsStatusNotAssessed => 'DEĞERLENDİRİLMEDİ';

  @override
  String get dnsStatusInconsistent => 'TUTARSIZ';

  @override
  String get dnsStatusEnabled => 'ETKİN';

  @override
  String get dnsStatusDisabled => 'DEVRE DIŞI';

  @override
  String get notAvailableCaps => 'YOK';

  @override
  String get evilTwinSignalOuiMismatch =>
      'İki erişim noktası farklı donanım üreticilerinden geliyor (MAC önekleri eşleşmiyor).';

  @override
  String get evilTwinSignalSecurityDowngrade =>
      'Çift farklı şifreleme sunuyor — tipik bir sürüm düşürme saldırısı (örneğin gerçek ağ = WPA3, sahte = WPA2 veya Açık).';

  @override
  String get evilTwinSignalSameBandChannelDrift =>
      'Her ikisi de aynı frekans bandında ancak çok farklı kanallarda yayın yapıyor — gerçek radyolar nadiren bu kadar uzağa sıçrar.';

  @override
  String get evilTwinSignalChannelWidthMismatch =>
      'Farklı kanal genişlikleri kullanıyorlar (örneğin 80 MHz\'e karşı 20 MHz). Ucuz sahte donanımlar genellikle kopyaladıkları cihazdan daha dar çalışır.';

  @override
  String get evilTwinSignalWpsToggleMismatch =>
      'WPS bir erişim noktasında etkin, diğerinde değil.';

  @override
  String get evilTwinSignalPmfToggleMismatch =>
      'Korumalı Yönetim Çerçeveleri (802.11w) bir tarafta etkin, diğerinde değil.';

  @override
  String get evilTwinSignalHiddenVsVisible =>
      'Bir erişim noktası gizli, diğeri adını açıkça yayınlıyor.';

  @override
  String get evilTwinSignalSharedMldMac =>
      'Her ikisi de aynı Wi-Fi 7 çoklu bağlantı MAC\'ini paylaşıyor — bunlar kelimenin tam anlamıyla aynı fiziksel erişim noktasıdır.';

  @override
  String get evilTwinSignalBssidProximity =>
      'MAC adresleri yalnızca son hanelerde farklılık gösteriyor — üreticiler bu kalıbı aynı yönlendiricideki radyolar için kullanır.';

  @override
  String get evilTwinSignalCrossBandSibling =>
      'Farklı Wi-Fi bantlarında (2.4 / 5 / 6 GHz) bulunuyorlar ancak aynı üreticiyi ve güvenliği paylaşıyorlar — klasik çift bantlı yönlendirici kalıbı.';

  @override
  String get evilTwinSignalKnownMeshVendor =>
      'Her iki MAC adresi de bilinen bir mesh yönlendirici ailesine aittir (Eero, Google Nest, Asus AiMesh, Netgear Orbi, TP-Link Deco veya Linksys Velop). Mesh düğümleri aynı Wi-Fi adını bilerek paylaşır.';

  @override
  String get evilTwinSafeHeadline =>
      'Farklı bantlarda aynı yönlendirici gibi görünüyor';

  @override
  String get evilTwinSafeWhatIs =>
      'Çoğu ev yönlendiricisi aynı Wi-Fi adını (SSID) 2.4 GHz, 5 GHz ve bazen 6 GHz üzerinden yayınlar. Telefonunuz bunları tek bir cihaz olsalar bile ayrı erişim noktaları olarak görür. Mesh sistemleri de aynı şekilde çalışır — her düğüm paylaşılan tek bir ad kullanır.';

  @override
  String get evilTwinSafeWhyItMatters =>
      'Bu eşleşme normaldir ve beklenen bir durumdur — işlem yapılmasına gerek yoktur. Bunu burada yalnızca kontrol ettiğimizi ve elediğimizi bilmeniz için gösteriyoruz.';

  @override
  String get evilTwinSafeAction =>
      'Yapılacak bir şey yok. Bu aynı yönlendirici veya mesh sisteminizin bir parçası.';

  @override
  String get evilTwinSafePhrase =>
      'Bu çifti kontrol ettik ve normal bir çift bantlı yönlendirici veya mesh kalıbıyla eşleşiyor — bir saldırı değil.';

  @override
  String get evilTwinNoPatternHeadline => 'Evil-twin kalıbı tespit edilmedi';

  @override
  String get evilTwinNoPatternAction =>
      'Acil bir durum yok. Ortamınızda bir şeylerin değiştiğinden şüpheleniyorsanız taramayı tekrar çalıştırın.';

  @override
  String get evilTwinNoPatternPhrase =>
      'Bu adı paylaşan erişim noktaları arasında bazı küçük farklılıklar var, ancak bir saldırı gibi görünecek kadar değil.';

  @override
  String get evilTwinWhatIs =>
      'Bir \"evil twin\", gerçek bir ağın adını kopyalayan sahte bir Wi-Fi ağıdır — genellikle eviniz veya iş yerinizdeki ağ veya popüler bir kafe erişim noktasıdır. Amaç, telefonunuzun gerçek olan yerine saldırganın yönlendiricisine bağlanmasını sağlamaktır.';

  @override
  String get evilTwinWhyItMatters =>
      'Cihazınız saldırganın Wi-Fi ağına bağlandığında, şifrelenmemiş trafiği okuyabilir veya kurcalayabilir, sahte giriş sayfaları sunabilir, sizi benzer görünümlü web sitelerine yönlendirebilir veya HTTPS\'yi düzgün kullanmayan uygulamalara yazılan şifreleri ele geçirebilirler. Bankacılık, e-posta ve mesajlaşma olağan hedeflerdir.';

  @override
  String get evilTwinHighHeadline =>
      'Güçlü evil-twin kalıbı — bu ağı güvenilmez olarak kabul edin';

  @override
  String get evilTwinMediumHeadline =>
      'Şüpheli twin kalıbı — bağlanmadan önce doğrulayın';

  @override
  String get evilTwinLowHeadline => 'Zayıf twin sinyali — buna dikkat edin';

  @override
  String evilTwinHighPhrase(int pct) {
    return 'Güven: %$pct. Bu adı kullanan iki erişim noktası arasında birden fazla güçlü uyumsuzluk var. Bu, bir saldırganın bir Wi-Fi\'yi taklit ederken oluşturduğu kalıptır.';
  }

  @override
  String evilTwinMediumPhrase(int pct) {
    return 'Güven: %$pct. Bu adı paylaşan erişim noktaları arasında birkaç ayrıntı örtüşmüyor. İyi niyetli olabilir, ancak güvenmeden önce doğrulayın.';
  }

  @override
  String evilTwinLowPhrase(int pct) {
    return 'Güven: %$pct. Birkaç küçük uyumsuzluk fark edildi. Büyük olasılıkla iyi niyetli — tekrar kontrol edebilmeniz için işaretlendi.';
  }

  @override
  String get evilTwinActionPasswords =>
      'Bu Wi-Fi\'ye bağlıyken şifre, ödeme ayrıntıları veya iki faktörlü kodlar girmeyin.';

  @override
  String get evilTwinActionCheckMac =>
      'Evdeyseniz, yönlendiricinizin altında yazan gerçek MAC\'i (BSSID) kontrol edin ve bu ağ için gösterilen BSSID\'lerle karşılaştırın.';

  @override
  String get evilTwinActionForgetNetwork =>
      'Telefonunuzun Wi-Fi ayarlarından ağı unutun ve yalnızca doğruladığınız BSSID\'ye manuel olarak tekrar bağlanın.';

  @override
  String get evilTwinActionSecurityDowngrade =>
      'İki erişim noktasından biri diğerinden daha zayıf şifreleme kullanıyor. Her zaman daha güçlü olanı seçin (WPA3 > WPA2 > Açık).';

  @override
  String get evilTwinActionDisconnectNow =>
      'Şimdi bu Wi-Fi bağlantısını kesin ve hangi BSSID\'nin gerçek olduğunu doğrulayana kadar mobil veriye geçin.';

  @override
  String get evilTwinActionHardwareVendor =>
      'İki yönlendirici farklı donanım üreticilerinden geliyor — gerçek yönlendiriciniz aniden üretici değiştirmemelidir.';

  @override
  String get ipAddrLabel => 'IP_ADRESI';

  @override
  String get macValLabel => 'MAC_DEĞERİ';

  @override
  String get mnfrLabel => 'SATICI';

  @override
  String get hiddenNetwork => 'Gizli Ağ';

  @override
  String get signalGraph => 'Sinyal Grafiği';

  @override
  String get riskFactors => 'Risk Faktörleri';

  @override
  String get vulnerabilities => 'Zafiyetler';

  @override
  String get bssId => 'BSSID';

  @override
  String get channel => 'Kanal';

  @override
  String get security => 'Güvenlik';

  @override
  String get signal => 'Sinyal';

  @override
  String recommendationLabel(String text) {
    return 'ÖNERİ: $text';
  }

  @override
  String get noVulnerabilities => 'Hiçbir zafiyet tespit edilmedi.';

  @override
  String get securityScoreTitle => 'Güvenlik Puanı';

  @override
  String get securityScoreDesc =>
      'Güvenlik puanı (0-100) bu ağın ne kadar iyi korunduğunu gösterir. Yüksek puan daha iyidir. Şifreleme türü, WPS durumu ve diğer güvenlik özellikleri dikkate alınır.';

  @override
  String get networkSecurity => 'Ağ Güvenliği';

  @override
  String get portScanCommonPorts => 'Ortak Portlar';

  @override
  String get portScanCustomRange => 'Özel Aralık';

  @override
  String get portScanAllPorts => 'BÜTÜN PORTLAR';

  @override
  String get portScanFullScanWarning =>
      '65.535 portun tamamını taramak uzun zaman alacaktır.';

  @override
  String get portScanStartPort => 'Başlangıç Portu';

  @override
  String get portScanEndPort => 'Bitiş Portu';

  @override
  String get portScanTooManyPorts =>
      'Uyarı: 1000\'den fazla portu taramak yavaş olabilir';

  @override
  String get portScanSearching =>
      'Açık portlar aranıyor. Bu işlem biraz zaman alabilir...';

  @override
  String portScanProbing(int port) {
    return 'Port $port taranıyor...';
  }

  @override
  String portScanFoundCount(int count) {
    return 'Şu ana kadar $count açık servis bulundu.';
  }

  @override
  String get portScanNoPortsProbed =>
      'Henüz taranmış port yok. Açık servisleri keşfetmek için bir port taraması çalıştırın.';

  @override
  String get capabilitiesLabel => 'ÖZELLİKLER';

  @override
  String get wifi7MldLabel => 'Wi-Fi 7 MLD';

  @override
  String get tagWpa3Desc =>
      'WPA3 en yeni Wi-Fi güvenlik standardıdır — yüksek düzeyde güvenlidir.';

  @override
  String get tagWpa2Desc =>
      'WPA2 güçlü bir güvenlik standardıdır — günlük kullanım için güvenlidir.';

  @override
  String get tagWpaDesc =>
      'WPA, bilinen zayıflıkları olan eski bir güvenlik standardıdır.';

  @override
  String get tagWpsDesc =>
      'WPS (Wi-Fi Korumalı Kurulum) bilinen güvenlik açıklarına sahiptir. Saldırganların PIN\'i kaba kuvvetle ele geçirmesine ve erişim kazanmasına izin verebilir.';

  @override
  String get tagPmfDesc =>
      'Korumalı Yönetim Çerçeveleri (PMF/MFP), kimlik doğrulama saldırılarına karşı koruma sağlar.';

  @override
  String get tagEssDesc =>
      'ESS (Genişletilmiş Servis Seti), bunun standart bir erişim noktası ağı olduğu anlamına gelir.';

  @override
  String get tagCcmpDesc =>
      'CCMP (AES), WPA2/WPA3 ile kullanılan güçlü bir şifreleme yöntemidir.';

  @override
  String get tagTkipDesc =>
      'TKIP, eski ve daha zayıf bir şifreleme yöntemidir. CCMP/AES tercih edilir.';

  @override
  String get tagUnknownDesc => 'Beacon karelerinden gelen ağ özelliği bayrağı.';

  @override
  String get scanProfileLabel => 'TARAMA PROFİLİ';

  @override
  String get infoScanProfileFastDesc =>
      'Hızlı: Çabuk ping taraması — cihazları saniyeler içinde bulur.';

  @override
  String get infoScanProfileBalancedDesc =>
      'Dengeli: Ping + ortak portlar — daha fazla detay bulur.';

  @override
  String get infoScanProfileAggressiveDesc =>
      'Agresif: Tam port taraması — en kapsamlı ama en yavaş.';

  @override
  String get activeNodeRecon => 'AKTİF DÜĞÜM KEŞFİ';

  @override
  String get interrogatingSubnet =>
      'Alt ağ, yanıt veren ana bilgisayarlar için sorgulanıyor...';

  @override
  String get nodesLabel => 'Düğümler';

  @override
  String get scanElapsedLabel => 'Süre';

  @override
  String get scanRateLabel => 'Hız';

  @override
  String get riskAvgLabel => 'Risk Ort.';

  @override
  String get servicesLabel => 'Servisler';

  @override
  String get openPortsLabel => 'AÇIK PORTLAR';

  @override
  String get subnetLabel => 'Alt Ağ';

  @override
  String get cidrTargetLabel => 'CIDR HEDEFİ';

  @override
  String portsCountLabel(int count) {
    return '$count PORT';
  }

  @override
  String get riskLabel => 'RİSK';

  @override
  String get searchLanPlaceholder =>
      'IP, ana bilgisayar adı veya satıcıya göre ara...';

  @override
  String get hasVulnerabilitiesLabel => 'Zafiyetleri Olanlar';

  @override
  String get securityStatusSecure => 'Güvenli';

  @override
  String get securityStatusModerate => 'Orta Derece';

  @override
  String get securityStatusAtRisk => 'Risk Altında';

  @override
  String get securityStatusCritical => 'Kritik';

  @override
  String get securitySummarySecure =>
      'Bağlantınız iyi görünüyor! Bu ağ güçlü şifreleme kullanıyor ve yaygın saldırılara karşı iyi korunuyor.';

  @override
  String get securitySummaryModerate =>
      'Bu ağın makul bir güvenliği var ancak bazı potansiyel zayıf noktaları bulunuyor. Günlük kullanım için güvenlidir, ancak hassas işlemlerden kaçının.';

  @override
  String get securitySummaryAtRisk =>
      'Bu ağda verilerinizi riske atan güvenlik sorunları var. Bağlıyken şifre veya kişisel bilgilerinizi girmekten kaçının.';

  @override
  String get securitySummaryCritical =>
      'Uyarı: Bu ağ güvenli değil. Yakındaki herkes internet trafiğinizi görebilir. Bir VPN kullanın veya ağ değiştirin.';

  @override
  String get riskFactorNoEncryption => 'Şifreleme kullanılmıyor';

  @override
  String get riskFactorDeprecatedEncryption =>
      'Kullanımdan kaldırılmış şifreleme (WEP)';

  @override
  String get riskFactorLegacyWpa => 'Eski WPA kullanımda';

  @override
  String get riskFactorHiddenSsid => 'Gizli SSID davranışı';

  @override
  String get riskFactorWeakSignal => 'Zayıf sinyal ortamı';

  @override
  String get riskFactorWpsEnabled => 'WPS PIN saldırı yüzeyi açık';

  @override
  String get riskFactorPmfNotEnforced =>
      'PMF zorunlu değil — deauth yanıltması mümkün';

  @override
  String get refresh => 'Yenile';

  @override
  String get cancel => 'İptal';

  @override
  String get save => 'Kaydet';

  @override
  String get waitingForData => 'Veri bekleniyor...';

  @override
  String signalMonitoringTitle(String ssid) {
    return 'SİNYAL İZLEME: $ssid';
  }

  @override
  String get heatmapTooltip => 'Isı Haritası';

  @override
  String get signalCaps => 'SİNYAL';

  @override
  String get channelCaps => 'KANAL';

  @override
  String get frequencyCaps => 'FREKANS';

  @override
  String errorPrefix(String message) {
    return 'Hata: $message';
  }

  @override
  String bandChannels(String band) {
    return '$band KANALLARI';
  }

  @override
  String get recommendedChannel => 'ÖNERİLEN KANAL';

  @override
  String channelInfo(int ch, int freq) {
    return 'Kanal $ch · $freq MHz';
  }

  @override
  String get riskFactorFingerprintDrift =>
      'SSID parmak izi kayması tespit edildi';

  @override
  String get riskFactorHoneypotPattern =>
      'SSID bilinen tuzak (honeypot) desenleriyle eşleşiyor';

  @override
  String get riskFactorNo5Ghz => '5 GHz bandı tespit edilemedi';

  @override
  String get riskFactorKnownVulnerability => 'Bilinen donanım güvenlik açığı';

  @override
  String get riskFactorEvilTwinCandidate =>
      'Bu SSID\'yi paylaşan Evil Twin adayı';

  @override
  String get riskFactorChannelCongested => 'Kanalda yoğun sıkışıklık var';

  @override
  String get historyCaps => 'GEÇMİŞ';

  @override
  String get consistentlyBestChannel => 'SÜREKLİ EN İYİ KANAL';

  @override
  String get avgScore => 'Ort. Skor';

  @override
  String get channelBondingTitle => 'Kanal Birleştirme';

  @override
  String get channelBondingDesc =>
      'Kanal birleştirme, bant genişliğini artırmak için 2 veya daha fazla bitişik kanalı birleştirir (40 MHz = 2×, 80 MHz = 4×, 160 MHz = 8×). Daha geniş kanallar daha yüksek hızlar sağlar ancak daha fazla komşu ağla çakışabilir.';

  @override
  String get spectrumOptimizationCaps => 'SPEKTRUM OPTİMİZASYONU';

  @override
  String get qualityExcellent => 'Mükemmel';

  @override
  String get qualityVeryGood => 'Çok İyi';

  @override
  String get qualityGood => 'İyi';

  @override
  String get qualityFair => 'Orta';

  @override
  String get qualityCongested => 'Yoğun';

  @override
  String channelBondingHeader(int count) {
    return 'KANAL BİRLEŞTİRME ($count AP)';
  }

  @override
  String get hiddenSsidLabel => '[Gizli]';

  @override
  String get noHistoryPlaceholder =>
      'Henüz geçmiş yok.\nKanal derecelendirmeleri bu ekranı her açtığınızda kaydedilir.';

  @override
  String historySummaryInfo(int sessions, int samples) {
    return '$sessions oturum · $samples örnek · yüksek = daha az yoğun';
  }

  @override
  String get scanReportTitle => 'Torcav Wi-Fi Tarama Raporu';

  @override
  String get reportTime => 'Zaman';

  @override
  String get ssidHeader => 'SSID';

  @override
  String get bssidHeader => 'BSSID';

  @override
  String get dbmHeader => 'dBm';

  @override
  String get channelHeader => 'CH';

  @override
  String get navDashboard => 'KONTROL PANELİ';

  @override
  String get navDiscovery => 'KEŞİF';

  @override
  String get navOperations => 'OPERASYONLAR';

  @override
  String get navLan => 'LAN';

  @override
  String get systemStatus => 'Sistem Durumu';

  @override
  String get interfaceTheme => 'Arayüz Teması';

  @override
  String get phasePing => 'AŞAMA: PING';

  @override
  String get phaseDownload => 'AŞAMA: İNDİRME';

  @override
  String get phaseUpload => 'AŞAMA: YÜKLEME';

  @override
  String get phaseDone => 'AŞAMA: TAMAMLANDI';

  @override
  String get loading => 'Yükleniyor...';

  @override
  String get profileTitle => 'PROFİL MERKEZİ';

  @override
  String get activeSessionLabel => 'Aktif Oturum';

  @override
  String get networkStatusLabel => 'AĞ DURUMU';

  @override
  String get ssid => 'SSID';

  @override
  String get lastScanTitle => 'SON TARAMA';

  @override
  String get lastSnapshot => 'Son Anlık Görüntü';

  @override
  String get channelInterferenceDescription =>
      'Wi-Fi kanalları radyo istasyonları gibidir. Birçok ağ aynı kanalı paylaştığında birbirlerini yavaşlatırlar - herkesin aynı anda konuşması gibi. Daha az kalabalık bir kanala geçmek hızınızı ve güvenilirliğinizi artırabilir.';

  @override
  String securityEventType(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'rogueApSuspected': 'Şüpheli AP Tespiti',
      'deauthBurstDetected': 'Deauth Patlaması Tespiti',
      'captivePortalDetected': 'Captive Portal Tespiti',
      'evilTwinDetected': 'Evil Twin Tespiti',
      'deauthAttackSuspected': 'Şüpheli Deauth Saldırısı',
      'encryptionDowngraded': 'Şifreleme Düzeyi Düşürüldü',
      'unsupportedOperation': 'Desteklenmeyen İşlem',
      'arpSpoofingDetected': 'ARP Spoofing Tespiti',
      'dnsHijackingDetected': 'DNS Hijacking Tespiti',
      'other': '$type',
    });
    return '$_temp0';
  }

  @override
  String get historyAllBands => 'TÜMÜ';

  @override
  String get historyBestChannel => 'EN İYİ KANAL';

  @override
  String get historyAvgRating => 'ORT. PUAN';

  @override
  String get historySessions => 'OTURUMLAR';

  @override
  String get historyLineChart => 'Çizgi grafik';

  @override
  String get historyHeatmap => 'Isı haritası';

  @override
  String get historyNoDataForFilter => 'Seçili filtre için veri yok.';

  @override
  String get historyChannelRatings => 'Kanal Puanları';

  @override
  String get dnsSecurityTest => 'DNS GÜVENLİK TESTİ';

  @override
  String get dnsSecure => 'GÜVENLİ';

  @override
  String get dnsWarning => 'UYARI';

  @override
  String get dnsLeakDetected => 'SIZI TESPİT EDİLDİ';

  @override
  String get dnsHijacked => 'ELE GEÇİRİLDİ';

  @override
  String dnsLastCheck(String hour, String minute) {
    return 'Son kontrol: $hour:$minute';
  }

  @override
  String get dnsTestNow => 'HEMEN TEST ET';

  @override
  String get dnsTesting => 'TEST EDİLİYOR...';

  @override
  String get dnsCurrentDns => 'MEVCUT DNS';

  @override
  String get dnsIspProvider => 'İSS SAĞLAYICI';

  @override
  String get phaseIdle => 'HAZIR';

  @override
  String get performanceTitle => 'HIZ TESTİ';

  @override
  String get jitterLabel => 'JITTER';

  @override
  String get whatThisMeans => 'BU NE ANLAMA GELİYOR';

  @override
  String get channelRecommendation => 'KANAL ÖNERİSİ';

  @override
  String switchToChannel(int channel) {
    return 'Kanal $channel\'a geç';
  }

  @override
  String get channelCongestionHint =>
      'Mevcut kanalınız kalabalık. Geçiş hızı artırabilir.';

  @override
  String get evilTwinAlertTitle => 'SAHTE AĞNOKTASI TESPİT EDİLDİ';

  @override
  String get evilTwinAlertBody =>
      'Bir ağ, bilinen bir erişim noktasını taklit ediyor. Tanımadığınız ağlara bağlanmayın.';

  @override
  String get wpsWarningTitle => 'WPS AÇIK';

  @override
  String get wpsWarningBody =>
      'WPS, WPA2\'de bile şifrenizi kırmaya izin veren güvenlik açıkları içerir. Router ayarlarından devre dışı bırakın.';

  @override
  String get heatmapTutorialTitle => 'ISISI HARİTASINI NASIL KULLANIRIM';

  @override
  String get heatmapTutorialStep1 =>
      'Yeni oturum başlatmak için KAYDI BAŞLAT\'a dokunun.';

  @override
  String get heatmapTutorialStep2 =>
      'Alanınızın her köşesine gidin ve konumunuza haritada dokunun.';

  @override
  String get heatmapTutorialStep3 =>
      'Kırmızı = zayıf sinyal. Yeşil = güçlü sinyal.';

  @override
  String get heatmapTutorialStep4 => 'Bitince DURDUR & KAYDET\'e dokunun.';

  @override
  String get gotIt => 'ANLADIM';

  @override
  String get speedTestHistory => 'TEST GEÇMİŞİ';

  @override
  String get noSpeedTestHistory =>
      'Henüz kayıtlı test yok. İlk testi yukarıdan başlatın.';

  @override
  String get vulnLabTitle => 'GÜVENLİK LABORATUVARI';

  @override
  String get vulnLabSubtitle => 'Bağlı ağınızda güvenlik testleri yapın';

  @override
  String get vulnLabRunAll => 'TÜM TESTLERİ ÇALIŞTIR';

  @override
  String get vulnLabRunning => 'TARANIYOR...';

  @override
  String get vulnLabNoNetwork =>
      'Bir Wi-Fi ağına bağlı değil. Testleri çalıştırmak için önce bağlanın.';

  @override
  String get vulnLabAllClear =>
      'Tüm testler geçti. Bu ağda herhangi bir zafiyet bulunmadı.';

  @override
  String vulnLabFoundCount(int count) {
    return '$count sorun bulundu';
  }

  @override
  String get trustNetwork => 'AĞA GÜVEN';

  @override
  String get untrustNetwork => 'GÜVENİ KALDIR';

  @override
  String get trustedBaselineBadge => 'GÜVENİLEN TABANLAR';

  @override
  String get dnsEvidenceTitle => 'DNS KANITI';

  @override
  String get dnsProtocol => 'PROTOKOL';

  @override
  String get dnsSsec => 'DNSSEC';

  @override
  String get dnsDohLabel => 'DoH';

  @override
  String get dnsDotLabel => 'DoT';

  @override
  String get dnsReachable => 'Erişilebilir';

  @override
  String get dnsBlocked => 'Engelli';

  @override
  String get dnsEncryptedBlocked =>
      'Bu ağ şifreli DNS\'i engelliyor — sorguların düz metin olarak iletiliyor.';

  @override
  String get dnsInfoHijackingTitle => 'DNS Ele Geçirme (Hijacking)';

  @override
  String get dnsInfoHijackingDesc =>
      'Ağ sağlayıcınızın veya kötü niyetli bir aktörün DNS sorgularınızı sahte sunuculara yönlendirmesidir. Bu, etkinliğinizi izlemelerine veya belirli web sitelerini engellemelerine olanak tanır.';

  @override
  String get dnsInfoLeakTitle => 'DNS Sızıntısı';

  @override
  String get dnsInfoLeakDesc =>
      'Bir VPN kullanırken bile sorgularınız güvenli tüneli baypas ederek ISS\'nizin sunucularına gidebilir. Bu, tarama geçmişinizi ağ sağlayıcısına \'sızdırır\'.';

  @override
  String get dnsInfoEncryptedTitle => 'Şifreli DNS (DoH/DoT)';

  @override
  String get dnsInfoEncryptedDesc =>
      'HTTPS üzerinden DNS (DoH) ve TLS üzerinden DNS (DoT), sorgularınızı şifreli bir katmana sarar. Bu, isteklerinizin yerel izleyiciler ve ağ yöneticileri tarafından okunamaz hale gelmesini sağlar.';

  @override
  String get dnsInfoDnssecTitle => 'DNSSEC';

  @override
  String get dnsInfoDnssecDesc =>
      'DNS Güvenlik Uzantıları, sorgularınıza kriptografik imzalar ekler. Bu, bir sunucunun size meşru siteler için sahte IP adresleri gönderdiği \'spoofing\' saldırılarını önler.';

  @override
  String get dnsInfoLatencyTitle => 'DNS Gecikmesi (RTT)';

  @override
  String get dnsInfoLatencyDesc =>
      'Gecikme (RTT), bir sorgunun sunucuya gidip gelmesi için geçen süreyi ölçer. Daha düşük gecikme, daha hızlı web gezintisi ve daha iyi performans demektir.';

  @override
  String get dnsInfoResolverDriftTitle => 'DNS Çözücü Kayması';

  @override
  String get dnsInfoResolverDriftDesc =>
      'DNS isteklerinizin yapılandırılanlardan farklı sağlayıcılar tarafından işlendiği tespit edildiğinde ortaya çıkar; bu durum şeffaf proxy kullanımı veya yönlendirme değişikliklerinden kaynaklanabilir.';

  @override
  String get netInfoSsidTitle => 'SSID (Ağ Adı)';

  @override
  String get netInfoSsidDesc =>
      'Wi-Fi ağınızın genel adıdır. Yaygın olsa da, saldırganlar tarafından sizi sahte bir erişim noktasına bağlamak için taklit edilebilir.';

  @override
  String get netInfoBssidTitle => 'BSSID (Donanım Adresi)';

  @override
  String get netInfoBssidDesc =>
      'Kablosuz yönlendiricinin benzersiz donanım adresidir (MAC). Meşru donanıma bağlı olduğunuzu ve bir yazılım kopyasına bağlı olmadığınızı doğrulamak için kullanışlıdır.';

  @override
  String get netInfoGatewayTitle => 'Varsayılan Ağ Geçidi';

  @override
  String get netInfoGatewayDesc =>
      'Yönlendiricinizin yerel IP adresidir. Tüm trafiğiniz bu noktadan geçer. Bu adres beklenmedik şekilde değişirse, bir Ortadaki Adam (MitM) saldırısına işaret edebilir.';

  @override
  String get dnsReadyStatus => 'ANALİZE HAZIR';

  @override
  String get dnsIdleDescription =>
      'DNS bütünlüğünü ve performansını doğrulamak için bir tarama başlatın.';

  @override
  String get netSecInfoTitle => 'Ağ Güvenliği Modülü';

  @override
  String get netSecInfoDesc =>
      'Kötü İkiz (Evil Twin) saldırılarına ve sahte ağlara karşı koruma sağlamak için bağlı ağların bütünlüğünü izler ve güvenilir profillerinizi yönetir.';

  @override
  String get spectrumOptimizationOpsSubtitle => 'Kanal puanlama · parazit';

  @override
  String get aboutSpectrumTitle => 'Spektrum Optimizasyonu Nedir?';

  @override
  String get aboutSpectrumWhatHeader => 'Nedir?';

  @override
  String get aboutSpectrumWhatBody =>
      'Wi-Fi cihazları, radyo spektrumunun \"kanal\" denilen dilimleri üzerinden konuşur. 2.4 GHz bandında üst üste binmeyen yalnızca 3 kanal vardır (1, 6, 11) ve bu band en kalabalık olanıdır. 5 GHz bandında çok daha fazla kanal bulunur ve parazit azdır. En yeni 6 GHz bandı (Wi-Fi 6E/7) ise çoğu evde neredeyse boştur.';

  @override
  String get aboutSpectrumWhyHeader => 'Ne işe yarar?';

  @override
  String get aboutSpectrumWhyBody =>
      'Birden fazla ağ aynı kanalı paylaşırsa sırayla konuşmak zorunda kalır ve hız düşer (Aynı Kanal Paraziti). 2.4 GHz\'de yan kanallar bile birbirinin üzerine biner ve cızırtı oluşturur (Komşu Kanal Paraziti). Sessiz bir kanal seçmek; hızı, gecikmeyi ve bağlantı kararlılığını doğrudan iyileştirir.';

  @override
  String get aboutSpectrumHowHeader => 'Nasıl yapılır?';

  @override
  String get aboutSpectrumHowBody =>
      'Bu ekran çevredeki tüm Wi-Fi ağlarını tarar; her kanalı rakip ağ sayısına, sinyal güçlerine ve komşu kanallarla örtüşmeye göre 0-10 arasında puanlar. Yeşil işaretli (≥8) bir kanal seçin: şu an en az kalabalık olan budur. Geçmiş sekmesi, o kanalın zaman içinde temiz kalıp kalmadığını gösterir.';

  @override
  String get bandSpectrumTitle => 'Kanal Spektrumu';

  @override
  String get bandSpectrumInfoTitle => 'Kanal Spektrumu';

  @override
  String get bandSpectrumInfoBody =>
      'Her bar bir kanaldır. Yüksek ve yeşil barlar sessiz; kısa kırmızı barlar kalabalık demektir. Bara dokunarak puanı (0-10) görebilirsiniz. Aynı kanalı paylaşan her ağ puandan 2 düşer (Aynı Kanal Paraziti); 2.4 GHz\'de komşu kanallardaki ağlar daha az puan düşürür (Komşu Kanal Paraziti). Yakın ve güçlü ağlar, uzak ve zayıf ağlardan daha fazla cezalandırılır.';

  @override
  String get recommendationInfoTitle => 'Öneri Nasıl Yapılır?';

  @override
  String get recommendationInfoBody =>
      'Her kanal 10 puandan başlar. Aynı kanalı paylaşan her ağ 2 puan (×sinyal gücü) düşürür. Komşu 2.4 GHz ağları mesafeye göre 0.2-1.5 puan düşürür. DFS kanalları (radar paylaşımlı) 0.5 puan kaybeder. En yüksek puanı alan kanal kazanır. Eşitlik durumunda küçük numaralı kanal tercih edilir.';

  @override
  String get consistentChannelInfoTitle => 'Tutarlı En İyi Kanal';

  @override
  String get consistentChannelInfoBody =>
      'Anlık tarama yanıltıcı olabilir: şu an sessiz olan bir kanal birazdan kalabalıklaşabilir. Geçmiş tüm taramalarınızı her kanal için ortalayıp en yüksek skorla istikrarlı kalan kanalı öne çıkarırız. Anlık öneriden farklıysa, geçmişte istikrarlı olan kanal genellikle uzun vadede daha güvenli seçimdir.';

  @override
  String get dfsBadgeLabel => 'DFS';

  @override
  String get dfsBadgeTooltip =>
      'DFS — meteoroloji/askeri radarla paylaşılır; yönlendiriciniz bu kanaldan kısa süreliğine ayrılabilir';

  @override
  String get dfsInfoTitle => 'DFS Nedir?';

  @override
  String get dfsInfoBody =>
      'DFS (Dynamic Frequency Selection — Dinamik Frekans Seçimi) kanalları, 5 GHz bandının 52-64 ve 100-144 arasındaki kanallarıdır. Bu kanallar yasal olarak hava durumu ve askeri radarlarla paylaşılır. Wi-Fi, bu radarlara öncelik vermek zorundadır: yönlendiriciniz bir radar darbesi algılarsa kanaldan en az 60 saniye boyunca ayrılmak zorundadır — bu süre boyunca cihazlarınız kısa süreliğine bağlantısı kopar ve başka bir kanala geçer. DFS kanalları genelde daha az kalabalık olduğu için yüksek puan alır; ancak havalimanı, liman veya meteoroloji istasyonu yakınlarında istikrarsız olabilir. Bu riski yansıtmak için skordan 0.5 puan düşürürüz. Yakında radar kaynağı yoksa kullanılabilir; aksi takdirde tercih etmemekte fayda vardır.';

  @override
  String get howToChangeChannelTitle => 'Wi-Fi kanalımı nasıl değiştiririm?';

  @override
  String get howToChangeChannelSubtitle =>
      'Yönlendiriciniz için adım adım kılavuz';

  @override
  String get guideConnectedTo => 'Bağlı olduğun ağ';

  @override
  String get guideRouterVendor => 'Yönlendirici markası';

  @override
  String get guideRouterUnknown => 'Tanınmadı — genel kılavuz gösteriliyor';

  @override
  String get guideStep1 => 'Adım 1 · Yönetim panelini aç';

  @override
  String get guideStep1Body =>
      'Aşağıdaki AÇ butonuna dokun — varsayılan tarayıcın yönlendiricinin yönetim sayfasında açılır. (Tercih edersen adresi kopyalayıp tarayıcıya elle yapıştırabilirsin.) Adresin çalışması için bu Wi-Fi\'a bağlı olmalısın; sadece mobil veriyle erişemezsin.';

  @override
  String get guideOpenInBrowser => 'Aç';

  @override
  String get guideOpenFailedMessage =>
      'Tarayıcı otomatik açılamadı — adresi kopyalayıp elle yapıştırabilirsin.';

  @override
  String get guideCredentialsHeader => 'Kullanıcı adı ve şifre';

  @override
  String get guideCredentialsBody =>
      'Yönetim sayfası giriş istediğinde:\n\n1. Yönlendiricinin altına veya arkasına bak — orada genellikle Wi-Fi şifresinin yanında YÖNETİM giriş bilgileri de yazar. Yönetim girişi \"Yönetim şifresi\", \"Web şifresi\", \"Modem şifresi\", \"Admin password\" veya \"Web password\" olarak etiketlenir. Bu, Wi-Fi şifresiyle AYNI DEĞİLDİR.\n\n2. Etiket yoksa şu fabrika varsayılanlarını dene:\n   • admin / admin\n   • admin / password\n   • admin / 1234\n   • root / admin\n   • Kullanıcı adı boş / şifre admin\n\n3. Yönlendiriciyi internet sağlayıcın kurduysa (Türk Telekom, TurkNet, Vodafone, Superonline, vb.) yönetim şifresi genellikle cihazın seri numarasının son 6-8 karakteridir; bu da etikette yazar. Birçok sağlayıcı her cihaza özel rastgele şifre basar.\n\n4. Hiçbiri olmuyorsa: birisi daha önce şifreyi değiştirmiş demektir. Yönlendiricinin arkasındaki RESET deliğine 10-15 saniye basılı tutarak fabrika ayarlarına dönebilirsin — ancak bu Wi-Fi adını ve şifresini de sıfırlar; tekrar baştan kurman gerekir.\n\n5. Bazı yeni yönlendiriciler web yönetim panelini bir telefon uygulamasıyla değiştirir (örn. TP-Link Tether, ASUS Router, Mi WiFi, Huawei AI Life). Web sayfası seni uygulamayı yüklemeye yönlendiriyorsa uygulamayı kurup oradan devam et.';

  @override
  String get guideCopyAddress => 'Kopyala';

  @override
  String get guideAddressCopied => 'Adres kopyalandı — tarayıcında aç';

  @override
  String get guideStep2 => 'Adım 2 · Wi-Fi / Kablosuz menüsünü bul';

  @override
  String get guideStep2Body =>
      'Giriş yaptıktan sonra Wi-Fi, Kablosuz, Wireless veya Ağ Ayarları adlı menüyü ara. Markalara göre isim değişebilir — aşağıda senin yönlendiricinin markasına göre yol verilmiştir:';

  @override
  String get guideStep3 => 'Adım 3 · Kanalı ayarla ve uygula';

  @override
  String get guideStep3Body =>
      'Kanal seçeneğini bul (Channel, Kanal veya Wireless Channel olarak yazabilir). Otomatik (Auto) olan değeri önceki ekranda önerilen kanal numarasına çevir. Yönlendiricin 2.4 GHz ile 5 GHz için ayrı seçenek gösteriyorsa her bandın kendi önerilen kanalını ayarla. Kaydet/Uygula\'ya bas. Yönlendirici Wi-Fi yayınını kısa bir an yeniden başlatacak.';

  @override
  String get guideMenuPathLabel => 'Menü yolu';

  @override
  String get guideGenericMenuPath =>
      'Wireless / Kablosuz → Temel / Gelişmiş Ayarlar → Kanal';

  @override
  String get channelWidthHeader => 'Kanal genişliği — 20 / 40 / 80 / 160 MHz';

  @override
  String get channelWidthBody =>
      'Kanal genişliği bir otoyolun şerit sayısı gibidir:\n• 20 MHz = 1 şerit. Yavaş ama trafiğe karşı dayanıklı. Kalabalık 2.4 GHz için en uygunu.\n• 40 MHz = 2 şerit. İki kat veri akışı, ama yan kanallarla daha çok çakışır.\n• 80 MHz = 4 şerit. Hızlı — yalnızca 5 GHz/6 GHz\'de kullanılabilir.\n• 160 MHz = 8 şerit. En yüksek hız, ama 5 GHz bandının yarısını kaplar; ancak komşu yoksa anlamlı.\n\nGenel kural: 2.4 GHz\'de 20 MHz; 5 GHz\'de 80 MHz; varsa 6 GHz\'de 160 MHz.';

  @override
  String get guideRisksHeader => 'Kanalı değiştirmek güvenli mi?';

  @override
  String get guideRisksBody =>
      'Evet — tamamen güvenli. Kanal değiştirmenin, yönlendirici radyoyu yeniden başlatırken oluşan 5-10 saniyelik kısa bir kesinti dışında hiçbir güvenlik veya performans yan etkisi yoktur. Ağ adın (SSID), şifren, port yönlendirme kuralların, ebeveyn denetimleri ve diğer tüm ayarlar aynen kalır. Bağlı cihazlar otomatik olarak yeniden bağlanır. Sonradan bir şey daha kötü gibi görünürse, aynı menüden Otomatik (Auto) ayarına geri dönebilirsin; yönlendirici kanalı kendisi seçer.';

  @override
  String get guideNoConnection =>
      'Bir Wi-Fi ağına bağlı değilsin — yönetim adresini ve markaya özel kılavuzu görmek için önce bağlan.';

  @override
  String get currentChannelLabel => 'ŞİMDİ';

  @override
  String currentChannelBannerYouAreOn(String channel) {
    return 'Şu an $channel üzerindesin';
  }

  @override
  String currentChannelBannerSwitchTo(String channel, String delta) {
    return '$channel kanalına geçersen +$delta puan kazanırsın';
  }

  @override
  String get currentChannelBannerOptimal => 'Zaten önerilen kanaldasın';

  @override
  String get spectrumOverlapTitle => 'Ağ Çakışması';

  @override
  String get spectrumOverlapInfoTitle => 'Ağ Çakışması';

  @override
  String get spectrumOverlapInfoBody =>
      'Her renkli şekil bir Wi-Fi ağıdır. X eksenindeki konumu merkez frekansını, genişliği kanal genişliğini (20/40/80/160 MHz), yüksekliği ise sinyal gücünü temsil eder (üst = güçlü, alt = zayıf). Şekillerin üst üste bindiği yerlerde, o ağlar aynı yayın süresini paylaşır ve birbirini yavaşlatır. Dikey bir dilim ki içinde hiç şekil olmasın (veya sadece zayıf olanlar altta kalsın) — orası sessiz bir kanaldır. Bir şekle dokunarak hangi ağ olduğunu görebilirsin.';

  @override
  String get spectrumOverlapEmptyHint => 'Bu bandda görünür ağ yok';

  @override
  String get channelDrilldownHeader => 'Bu kanaldaki ağlar';

  @override
  String get channelDrilldownEmpty => 'Burada yayın yapan ağ yok';

  @override
  String get hiddenSsidPlaceholder => '<gizli ağ>';

  @override
  String scanComparisonImproved(String delta) {
    return 'Son taramaya göre $delta puan iyileşti';
  }

  @override
  String scanComparisonWorsened(String delta) {
    return 'Son taramaya göre $delta puan kötüleşti';
  }

  @override
  String get scanComparisonStable => 'Son taramadan beri sabit';

  @override
  String get countryAllowlistHeader => 'Bölge';

  @override
  String get channelIllegalBadge => 'İZİNSİZ';

  @override
  String get channelIllegalTooltip =>
      'Seçilen bölgede bu kanal Wi-Fi için yasal değil.';

  @override
  String get regionUS => 'Amerika Birleşik Devletleri';

  @override
  String get regionEU => 'Avrupa / Türkiye';

  @override
  String get regionJP => 'Japonya';

  @override
  String get regionWorld => 'Dünya (en geniş)';

  @override
  String get hourlyHeatmapTitle => 'Saate göre en iyi kanal';

  @override
  String get hourlyHeatmapInsufficient =>
      'Yeterli geçmiş yok. Bu ekranı günün farklı saatlerinde aç ki desen oluşsun.';

  @override
  String get afcInfoTitle => '6 GHz Güç Sınıfları (AFC)';

  @override
  String get afcInfoBody =>
      '6 GHz Wi-Fi üç güç sınıfına ayrılır:\n\n• LPI (Düşük Güç İç Mekan) — Ev yönlendiricileri için varsayılan. 30 dBm EIRP\'ye kadar, yalnızca iç mekanda yasal. Konum koordinasyonu gerekmez.\n\n• Standard Power (SP) — Dış mekan + yüksek güçlü iç mekan. 36 dBm\'e kadar. AFC (Otomatik Frekans Koordinasyonu) gerektirir: yönlendirici resmi bir veritabanına GPS konumunu gönderir, hangi kanalların yerleşik kullanıcılardan (uydu uplink, sabit mikrodalga linkleri) boş olduğu söylenir.\n\n• VLP (Çok Düşük Güç) — Mobil/taşınabilir kullanım, 14 dBm\'e kadar. Koordinasyon gerekmez ama menzil çok kısa; çoğunlukla AR/VR gözlüklerinde ve dizüstülerde.\n\nÇoğu ev ağı yalnızca LPI görür; dış mekanda güçlü 6 GHz sinyali görüyorsan büyük olasılıkla SP\'dir ve AFC ile koordine edilmiştir.';

  @override
  String get advancedTopicsHeader => 'İleri konular';

  @override
  String get advancedMeshTitle => 'Mesh ve dolaşım (roaming)';

  @override
  String get advancedMeshBody =>
      'Mesh ağda (Google Nest, Eero, TP-Link Deco vb.) kanalı manuel seçmezsin — kontrolör her düğüm için bir kanal seçer ve komşular değişince yeniden dengeler. Bazı kontrolörlerde düğüm bazında kanal geçersiz kılma var; ama otomatik mod genelde en iyisidir, çünkü sistem mesh düğümleri arasındaki çakışmayı da ölçer. Yine de elle ayarlamak istersen, ana düğümün ön-uç (istemciye bakan) radyosunu önerilen kanala al; arka-uç (düğümler arası) radyo otomatik kalsın.';

  @override
  String get advancedBandSteeringTitle => 'Band steering & tek SSID vs ikisi';

  @override
  String get advancedBandSteeringBody =>
      'Modern yönlendiriciler band-steering sunar: tek SSID hem 2.4 hem 5 GHz için, yönlendirici uygun cihazları 5 GHz\'e iter. Artıları: basit, cihazlar otomatik geçiş yapar. Eksileri: bazı IoT cihazlar (akıllı priz, kamera) sadece 2.4 GHz görür; yönlendirici steering sırasında o bandı gizlerse bağlantı kuramaz. Geçici çözüm: SSID\'leri ayır (örn. \"EvWiFi\" 5 GHz\'de, \"EvWiFi-IoT\" 2.4 GHz\'de), kurulumdan sonra istersen birleştir.';

  @override
  String get advancedWmmTitle => 'WMM / QoS';

  @override
  String get advancedWmmBody =>
      'WMM (Wi-Fi Multimedia) trafiği 4 sınıfa ayırır: ses, video, normal, arka plan. Wi-Fi 4+ sertifikası için zorunludur ve daima açık kalmalı. Kapatırsan hızın 802.11g seviyesine (~54 Mbps) düşer. Kanal seçimi WMM\'i etkilemez ama temiz bir kanal 4 sınıfı da aynı anda iyileştirir.';

  @override
  String get dfsCacWarning =>
      '⚠ DFS kanalı: yönlendiricin bu kanala geçtiğinde 60 saniye sessizce dinleme yapması gerekir (Kanal Uygunluk Kontrolü — CAC). O sürede Wi-Fi yayını kesilir.';

  @override
  String get densityTrendStable => 'Yoğunluk sabit';

  @override
  String densityTrendVolatile(String delta) {
    return 'Değişken bölge · son 1 saatte yoğunluk $delta ağ kadar dalgalandı';
  }

  @override
  String get routerGroupsHeader => 'Yakındaki Router\'lar (çift band)';

  @override
  String get routerGroupsInfoBody =>
      'Aynı router\'ın aynı SSID\'i birden fazla bandda yayınladığı (ör. 2.4 GHz CH 6 ve 5 GHz CH 36) durumlarda iki radyoyu yan yana karşılaştırabilmen için burada gruplayıp listeleriz. Bir band chip\'ine dokunarak o sekmeye geç.';

  @override
  String crossBandSiblingHint(String band, String channel, String rating) {
    return 'Aynı router $band CH $channel\'de · $rating/10';
  }

  @override
  String get connectedChannelGuideLabel => 'SİZ';

  @override
  String get unstableChannelTooltip =>
      'Bu kanalın puanı son oturumlarda 1.5 puandan fazla dalgalandı';

  @override
  String get historyHeatmapInfoTitle => 'Isı Haritası Nedir?';

  @override
  String get historyHeatmapInfoBody =>
      'Her satır bir kanal, her sütun ise bir tarama yaptığınız andır. Hücre rengi o anda kanalın aldığı puanı gösterir: kırmızı (kötü) → sarı (orta) → yeşil (mükemmel). Boş hücreler, o taramada kanalın görünmediği anlamına gelir. Tamamen yeşil satırları kollayın — bunlar zamanla temiz kalan kanallardır.';

  @override
  String get clearChannelHistoryTitle => 'KANAL GEÇMİŞİNİ TEMİZLE';

  @override
  String get clearChannelHistoryConfirmBody =>
      'Tüm kanal puanı kayıtları silinsin mi? Bu işlem geri alınamaz.';

  @override
  String get deleteAllLabel => 'TÜMÜNÜ SİL';

  @override
  String get dualBandSiblingLabel => 'AYNI ROUTER';

  @override
  String dualBandSiblingBanner(String band, String channel) {
    return 'Router\'ınızın $band radyosu: $channel';
  }

  @override
  String get acknowledgedLabel => 'ANLAŞILDI';

  @override
  String get speedDoctorTitle => 'HIZ DOKTORU';

  @override
  String get speedDoctorTagline => 'İnternet neden yavaş?';

  @override
  String get evilTwinDetailTitle => 'EVIL TWIN DETAYI';

  @override
  String get pingStabilizerTitle => 'PING STABİLİZATÖR';

  @override
  String get pingStabilizerSubtitle => 'Cihaz üstü gecikme tüneli';

  @override
  String get pingStabilizerToggleHint => 'Stabilize etmek için dokun';

  @override
  String get pingStabilizerDrawerLabel => 'Ping Stabilizatör';

  @override
  String get onboardingStartScanning => 'TARAMAYA BAŞLA';

  @override
  String get onboardingNext => 'İLERİ';

  @override
  String get onboardingWelcomeTitle => 'TORCAV\'A HOŞ GELDİNİZ';

  @override
  String get onboardingWelcomeBody =>
      'Kablosuz çevrenizi anlamanıza, en iyi kanalı bulmanıza ve güvenlik tehditlerini tespit etmenize yardımcı olan siberpunk Wi-Fi analizörü.';

  @override
  String get onboardingLocationTitle => 'KONUM İZNİ';

  @override
  String get onboardingLocationBody =>
      'Android, Wi-Fi ağlarını taramak için Konum izni gerektirir. Sinyal ısı haritalarını göstermek için aktivite sensörlerini de kullanıyoruz. Tüm veriler cihazınızda kalır ve asla yüklenmez. Konumunuz yalnızca yakındaki Wi-Fi sinyallerini okumak için kullanılır.';

  @override
  String get onboardingNotificationsTitle => 'GÜVENLİK UYARILARI';

  @override
  String get onboardingNotificationsBody =>
      'Torcav ağınızda bir güvenlik olayı tespit ettiği an haberdar olun — sahte erişim noktaları, açık portlar, DNS yönlendirme. Tüm bildirimler cihazınızda üretilir; hiçbir veri sunucuya gönderilmez.';

  @override
  String get onboardingNotificationsEnable => 'Bildirimleri etkinleştir';

  @override
  String get onboardingNotificationsSkip => 'Şimdilik geç';

  @override
  String get onboardingTourTitle => 'ÜÇ SEKME';

  @override
  String get onboardingTourDashboardLabel => 'Panel';

  @override
  String get onboardingTourDashboardDesc => 'Ağ durumunuzun canlı özeti';

  @override
  String get onboardingTourDiscoveryLabel => 'Keşif';

  @override
  String get onboardingTourDiscoveryDesc =>
      'Wi-Fi ağlarını ve LAN cihazlarını tara';

  @override
  String get onboardingTourOperationsLabel => 'İşlemler';

  @override
  String get onboardingTourOperationsDesc =>
      'Güvenlik analizi, hız testleri, raporlar';

  @override
  String get onboardingContextTitle => 'TORCAV\'I NEREDE KULLANACAKSINIZ?';

  @override
  String get onboardingContextBody =>
      'Bu, kendi başımıza anlayamadığımızda güvenlik puanının ne kadar katı olacağını belirler. İstediğiniz zaman değiştirebilirsiniz ve daha sonra her ağ için geçersiz kılınabilir.';

  @override
  String get onboardingContextHomeTitle => 'Çoğunlukla evim / ofisim';

  @override
  String get onboardingContextHomeBody =>
      'Katı puanlama. Şifrelemedeki beklenmedik değişiklikler veya LAN\'daki yeni cihazlar yüksek sesle işaretlenir.';

  @override
  String get onboardingContextPublicTitle =>
      'Çoğunlukla kafeler / oteller / havaalanları';

  @override
  String get onboardingContextPublicBody =>
      'Şifreleme konusunda esnek puanlama (bu ağlar genellikle açıktır), ancak sahte SSID\'lere ve \'evil-twin\' kalıplarına karşı yüksek hassasiyet. Aktif LAN taraması varsayılan olarak durdurulur.';

  @override
  String get onboardingContextGuestTitle => 'Çoğunlukla misafir / ortak ağlar';

  @override
  String get onboardingContextGuestBody =>
      'Arkadaşlar, aile veya iş arkadaşlarıyla aynı Wi-Fi. Değişiklik beklenir; her yeni cihazda uyarı vermeyiz.';

  @override
  String get onboardingContextUnknownTitle => 'Henüz emin değilim';

  @override
  String get onboardingContextUnknownBody =>
      'Güçlü bir varsayılan yok. Her ağın parmak izinden tahmin yürüteceğiz ve düzeltmenize izin vereceğiz.';

  @override
  String get onboardingDoneTitle => 'HER ŞEY HAZIR';

  @override
  String get onboardingDoneBody =>
      'Torcav gizlilik odaklı bir ağ asistanıdır. Sahibi olduğunuz veya değerlendirme yetkiniz olan ağlar için güvenli ağ teşhisi ve güçlendirme araçları sağlar. Harici olarak hiçbir veri toplanmaz veya iletilmez.';

  @override
  String get onboardingAcceptPrefix => 'Okudum ve kabul ediyorum: ';

  @override
  String get onboardingTosLink => 'Kullanım Koşulları';

  @override
  String get onboardingAcceptAnd => ' ve ';

  @override
  String get onboardingPrivacyLink => 'Gizlilik Politikası';

  @override
  String get onboardingAcceptSuffix => '.';

  @override
  String get onboardingConfirmPermission =>
      'Analiz edeceğim ağları tarama yetkim olduğunu onaylıyorum.';

  @override
  String get onboardingConfirmAge =>
      '13 yaşında veya daha büyük olduğumu onaylıyorum.';

  @override
  String get appTitle => 'TORCAV';

  @override
  String get ssidLabel => 'SSID';

  @override
  String get noSecurityFindings => 'Güvenlik bulgusu tespit edilmedi.';

  @override
  String get resetToInferred => 'Otomatik etikete dön';

  @override
  String get internetSlowQuestion => 'İNTERNET YAVAŞ MI?';

  @override
  String get securityAlertsTitle => 'GÜVENLİK UYARILARI';

  @override
  String get markAllRead => 'TÜMÜNÜ OKUNDU YAP';

  @override
  String get clearAll => 'TÜMÜNÜ TEMİZLE';

  @override
  String get eventsRetentionInfo =>
      'Olaylar 30 gün saklanır. Kapatmak için sola kaydırın.';

  @override
  String get allSystemsClear => 'Tüm sistemler temiz';

  @override
  String get heuristicDetectionNote =>
      'Sezgisel tespit — doğrulanmış bir saldırı değildir. Kalabalık ortamlarda yanlış pozitif görülebilir.';

  @override
  String get markAsRead => 'OKUNDU YAP';

  @override
  String get eventTypeRogueAp => 'SAHTE AP';

  @override
  String get eventTypeEvilTwin => 'EVIL TWIN';

  @override
  String get eventTypeDeauthAttack => 'DEAUTH SALDIRISI';

  @override
  String get eventTypeEncryptionWeakened => 'ŞİFRELEME ZAYIFLADI';

  @override
  String get eventTypeDeauthBurst => 'DEAUTH PATLAMASI';

  @override
  String get eventTypeCaptivePortal => 'CAPTIVE PORTAL';

  @override
  String get eventTypeUnsupported => 'DESTEKLENMİYOR';

  @override
  String get eventTypeArpSpoofing => 'ARP SPOOFING';

  @override
  String get eventTypeDnsHijacking => 'DNS HIJACKING';

  @override
  String get agentId => 'AGENT-01';

  @override
  String cyberneticId(String id) {
    return 'SİBERNETİK_KİMLİK: $id';
  }

  @override
  String subscriptionLabel(String type) {
    return 'Abonelik: $type';
  }

  @override
  String deepScanSuppressed(String context) {
    return 'Derin tarama bastırıldı — $context bir ağa bağlısınız. Geçersiz kılmak için Ayarlar\'dan güvenlik korumasını kapatın.';
  }

  @override
  String get securityAssessmentFailed => 'GÜVENLİK DEĞERLENDİRMESİ BAŞARISIZ';

  @override
  String get retryAnalytics => 'ANALİZİ YENİDEN DENE';

  @override
  String get publicContextLabel => 'herkese açık';

  @override
  String get guestContextLabel => 'misafir';

  @override
  String get clearScanHistoryTitle => 'TARAMA GEÇMİŞİNİ TEMİZLE';

  @override
  String get clearScanHistoryBody =>
      'Tüm LAN tarama kayıtları silinsin mi? Bu işlem geri alınamaz.';

  @override
  String get cancelLabel => 'İPTAL';

  @override
  String get networkAuditConsentTitle => 'AĞ DENETİMİ ONAYI';

  @override
  String get networkAuditConsentDesc =>
      'Aktif ağ taraması, cihazları ve servisleri tanımlamak için trafik üretir. Bu, ağ güvenlik sistemleri tarafından işaretlenebilir.';

  @override
  String get consentScanNodes => 'Yerel ağı aktif düğümler için tara';

  @override
  String get consentFingerprint =>
      'Açık servislerin ve işletim sisteminin parmak izini çıkar';

  @override
  String get consentIdentifyVulns => 'Olası zafiyetleri tespit et';

  @override
  String get consentConfirmAuth => 'Bu ağ için yetkiniz olduğunu onaylayın';

  @override
  String get iUnderstand => 'ANLADIM';

  @override
  String get iosLanDiscoveryLimited =>
      'iOS: LAN keşfi sınırlıdır. mDNS taraması ve ARP tablosu erişimi işletim sistemi tarafından kısıtlanabilir.';

  @override
  String get androidLanVendorLimited =>
      'Android LAN MAC erişimini sınırlar. Üretici adı genelde yalnızca router/gateway için görünebilir; diğer cihazlar mümkün olduğunda IP, hostname ve servis bilgileriyle tanımlanır.';

  @override
  String get vendorUnavailableAndroid =>
      'Üretici bilgisi yok: Android bu cihazın LAN MAC adresini uygulamalara açmıyor.';

  @override
  String get speedDoctorLongDesc =>
      '~30 saniye içinde sinyal, kanal, hız ve DNS sorguları yaparak zincirdeki hangi halkanın darboğaz olduğunu söyler.';

  @override
  String get startDiagnosis => 'TEŞHİSİ BAŞLAT';

  @override
  String get speedDoctorQuotaWarning =>
      'Dikkat: Gerçek bir hız testi ~300-500 MB indirir. Mobil kotanızı bitirmemek için Wi-Fi veya sınırsız bir bağlantı kullanın.';

  @override
  String get evidenceLabel => 'KANITLAR';

  @override
  String get runAgain => 'TEKRAR ÇALIŞTIR';

  @override
  String get aboutSpeedDoctorTitle => 'SPEED DOCTOR HAKKINDA';

  @override
  String get sdAboutWhatTitle => 'Nedir?';

  @override
  String get sdAboutWhatBody =>
      'Ayrı ekranlardaki rakamları karşılaştırmanıza gerek kalmadan, sizinle internet arasındaki olası darboğazı bulan tek dokunuşluk bir teşhistir.';

  @override
  String get sdAboutHowTitle => 'Nasıl çalışır?';

  @override
  String get sdAboutHowBody =>
      'Beş kısa sorgu uçtan uca çalıştırılır ve sonuçlar yayınlanmış eşik değerlerle karşılaştırılır:';

  @override
  String get sdAboutHowBullet1 =>
      'Sinyal — bağlı erişim noktasından RSSI değerini okur.';

  @override
  String get sdAboutHowBullet2 =>
      'Kanal — kanalınızı komşu erişim noktalarına göre puanlar.';

  @override
  String get sdAboutHowBullet3 =>
      'Hız — Cloudflare\'a karşı gerçek bir indirme/yükleme testi yapar.';

  @override
  String get sdAboutHowBullet4 =>
      'Bufferbloat — yük altında gecikmeyi ölçer (Waveform A–F).';

  @override
  String get sdAboutHowBullet5 =>
      'DNS — genel çözücüleri mevcut olanla karşılaştırır.';

  @override
  String get sdAboutCategoriesTitle => 'Kategoriler ne anlama geliyor?';

  @override
  String get sdAboutCategoriesBullet1 =>
      'Zayıf Sinyal — Wi-Fi bağlantısı mesafe/duvarlar nedeniyle daha yavaş modlara zorlanıyor.';

  @override
  String get sdAboutCategoriesBullet2 =>
      'Kalabalık Kanal — aynı kanaldaki komşu ağlar bant genişliğinizi tüketiyor.';

  @override
  String get sdAboutCategoriesBullet3 =>
      'Bufferbloat — bağlantı tam yüklendiğinde gecikme artar; aramalar ve oyunlar etkilenir.';

  @override
  String get sdAboutCategoriesBullet4 =>
      'Yavaş ISP — Wi-Fi iyi ancak paketiniz / üst yapınız sınırda.';

  @override
  String get sdAboutCategoriesBullet5 =>
      'Yavaş DNS — isim sorgulamaları çok uzun sürdüğü için sayfa yüklemeleri yavaş hissettiriyor.';

  @override
  String get sdAboutEstimateTitle => 'Hızlanma tahmini hakkında';

  @override
  String get sdAboutEstimateBody =>
      'Her bulgu muhafazakar bir öngörülen kazanç gösterir — düzeltmeyi uyguladıktan sonra gerçekçi olarak bekleyebileceğiniz kazanç. Bu bir garanti değil, alt sınırdır ve test koşullarına bağlıdır.';

  @override
  String get diagnosisFailed => 'Teşhis başarısız oldu';

  @override
  String get retryLabel => 'YENİDEN DENE';

  @override
  String get settingsIncludeHiddenDesc =>
      'Gizli SSID\'leri aktif olarak sorgular. Varsayılan olarak kapalıdır — yalnızca sahibi olduğunuz ağlarda etkinleştirin.';

  @override
  String get autoScanLabel => 'Otomatik Tarama';

  @override
  String autoScanDesc(int seconds) {
    return 'Taramayı her $seconds saniyede bir otomatik olarak tekrarla';
  }

  @override
  String get deepScanLabel => 'Derin Tarama';

  @override
  String get deepScanDesc =>
      'Banner yakalama + zafiyet analizi. Sadece test etme yetkiniz olan ağlarda etkinleştirin.';

  @override
  String get restrictDeepScanPublicLabel =>
      'Halka Açık Wi-Fi\'da Derin Taramayı Kısıtla';

  @override
  String get restrictDeepScanPublicDesc =>
      'Halka açık veya misafir ağlara bağlıyken aktif sorgulamayı durdurur. Önerilir — sahibi olmadığınız ağlarda yapılan aktif taramalar temel yasal risk oluşturur.';

  @override
  String get backgroundMonitoringLabel => 'Arka Plan İzleme';

  @override
  String get backgroundMonitoringDesc =>
      'Uygulama kapalıyken her 30 dakikada bir sessiz bir Wi-Fi kontrolü yapar. Yeni bir cihaz belirdiğinde, bağlı ağ değiştiğinde veya şifreleme değiştiğinde bildirim alırsınız. Pil etkisi minimumdur.';

  @override
  String get portScanTimeoutLabel => 'Port Tarama Zaman Aşımı';

  @override
  String get privacyAndDataLabel => 'GİZLİLİK VE VERİ';

  @override
  String get dataRetentionLabel => 'VERİ SAKLAMA';

  @override
  String get scanHistoryRetentionLabel => 'Tarama Geçmişi';

  @override
  String get speedTestsRetentionLabel => 'Hız Testleri';

  @override
  String get securityEventsRetentionLabel => 'Güvenlik Olayları';

  @override
  String get replayOnboardingLabel => 'Tanıtımı Tekrar Oynat';

  @override
  String get replayOnboardingDesc => 'Hoş geldin turunu tekrar görüntüleyin.';

  @override
  String get wipeAllDataLabel => 'Tüm Yerel Verileri Temizle';

  @override
  String get wipeAllDataDesc =>
      'Bu cihazdaki tüm tarama geçmişini, hız testlerini, güvenlik olaylarını ve kanal derecelendirmelerini siler.';

  @override
  String get aboutLabel => 'HAKKINDA';

  @override
  String get legalDisclaimerTitle => 'Yasal Uyarı';

  @override
  String get legalDisclaimerBody =>
      'Bu uygulama ağ gözlemi ve yetkili LAN keşfi gerçekleştirir. Aktif sorgulama yalnızca servis tanımlama ve güvenlik değerlendirmesi ile sınırlıdır. Brute-force kimlik doğrulama, paket enjeksiyonu, ARP zehirlemesi veya kimlik bilgisi toplama işlemleri yapılmaz.\n\nBu uygulamanın sahibi olmadığınız veya test etme yetkiniz olmayan ağlarda kullanılması yürürlükteki yasaları (TCK 243/244, AB Direktifi 2013/40, CFAA) ihlal edebilir. Yasal kullanımın sağlanmasından tamamen kullanıcı sorumludur.';

  @override
  String get enableDeepScanTitle => 'DERİN TARAMA AÇILSIN MI?';

  @override
  String get enableDeepScanBody =>
      'Derin tarama, banner yakalama ve servis zafiyet analizi gerçekleştirir. Bu mod sadece sahibi olduğunuz veya açıkça yetkilendirildiğiniz ağlarda kullanılmalıdır.\n\nYetkisiz ağlarda devam etmek yürürlükteki yasaları ihlal edebilir.';

  @override
  String get wifiScanPermissionTitle => 'WIFI TARAMA İZNİ';

  @override
  String get wifiScanPermissionDesc =>
      'Yakındaki Wi-Fi ağlarını keşfetmek ve sinyal gücünü analiz etmek için Torcav\'ın Konum iznine ihtiyacı var. Bu, Wi-Fi taraması için bir Android sistem gereksinimidir.';

  @override
  String get consentScanSsids => 'Yakındaki Wi-Fi SSID\'lerini tara';

  @override
  String get consentAnalyzeSignal => 'Sinyal kalitesini ve paraziti analiz et';

  @override
  String get consentNoTracking =>
      'Torcav konumunuzu asla izlemez veya paylaşmaz';

  @override
  String get continueLabel => 'DEVAM';

  @override
  String get clearWifiHistoryBody =>
      'Kayıtlı tüm Wi-Fi tarama oturumları silinsin mi? Bu işlem geri alınamaz.';

  @override
  String get transparentSignalAnalysisTitle => 'ŞEFFAF SİNYAL ANALİZİ';

  @override
  String get transparentSignalAnalysisDesc =>
      'Güvenlik denetimi için gelişmiş spektrum analizi. Yalnızca cihaz üzerinde işlenir.';

  @override
  String get cachedResultsWarning =>
      'Önbellek sonuçları gösteriliyor — Android tarama sıklığını sınırlar. ~30 sn bekleyip canlı veri için yenileyin.';

  @override
  String get enableDeepScanBodyWifi =>
      'Derin Tarama, banner yakalama ve zafiyet analizi gerçekleştirir. Sadece tarama yetkiniz olan ağlarda kullanın. Yetkisiz kullanım TCK 243/244 ve benzeri yasaları ihlal edebilir.';

  @override
  String get iAmAuthorized => 'YETKİLİYİM';

  @override
  String get iosWifiScanLimited =>
      'iOS: Wi-Fi tarama sonuçları Apple API\'leri ile sınırlıdır. Aktif tarama tetikleme ve bazı ağ ayrıntıları kullanılamaz.';

  @override
  String get allCategoriesLabel => 'Tüm kategoriler (tek paket)';

  @override
  String get autoLabel => 'Otomatik';

  @override
  String get lightLabel => 'Açık';

  @override
  String get darkLabel => 'Koyu';

  @override
  String get dismissLabel => 'Kapat';

  @override
  String get applyLabel => 'Uygula';

  @override
  String get openSettingsLabel => 'Ayarları aç';

  @override
  String get privacyPolicyTitle => 'Gizlilik Politikası';

  @override
  String get encryptionAndConfigTitle => 'ŞİFRELEME VE YAPILANDIRMA';

  @override
  String get environmentScanTitle => 'ORTAM TARAMASI';

  @override
  String get dnsTestFailedTitle => 'DNS Testi Başarısız';

  @override
  String get dnsTestFailedDesc =>
      'DNS test sunucularına ulaşılamadı. Bağlantınızı kontrol edin.';

  @override
  String get dnsLeakDetectedTitle => 'DNS Sızıntısı Tespit Edildi';

  @override
  String get dnsLeakDetectedDesc =>
      'DNS sorgularınız beklenen çözücünün dışına sızıyor, bu durum internet aktivitenizi servis sağlayıcınıza veya üçüncü taraflara ifşa edebilir.';

  @override
  String get dnsHijackingDetectedTitle => 'DNS Ele Geçirme Tespit Edildi';

  @override
  String get dnsHijackingDetectedDesc =>
      'DNS yanıtları beklenmedik bir sunucuya yönlendiriliyor. Bu durum aradaki adam (man-in-the-middle) saldırısına veya servis sağlayıcı müdahalesine işaret edebilir.';

  @override
  String get dnsConfigWarningTitle => 'DNS Yapılandırma Uyarısı';

  @override
  String get dnsConfigWarningDesc =>
      'DNS yapılandırmasında gizliliği veya güvenliği etkileyebilecek potansiyel sorunlar var.';

  @override
  String get noIssuesDetected => 'Sorun tespit edilmedi';

  @override
  String get retryInternetConnection =>
      'İnternete bağlandığınızda tekrar deneyin.';

  @override
  String get dnsLeakRecommendation =>
      'Güvenilir bir DNS çözücü (örn. 1.1.1.1 veya 9.9.9.9) yapılandırın ve HTTPS üzerinden DNS (DoH) veya TLS üzerinden DNS (DoT) özelliğini etkinleştirin.';

  @override
  String get dnsHijackingRecommendation =>
      'Derhal bir VPN kullanmaya başlayın. DNS sorgularınıza müdahale ediliyor.';

  @override
  String get dnsConfigRecommendation =>
      'DNS ayarlarınızı gözden geçirin ve gizlilik odaklı bir DNS sağlayıcısına geçmeyi düşünün.';

  @override
  String openNetworksNearbyTitle(int count) {
    return 'Yakında $count Açık Ağ Var';
  }

  @override
  String openNetworksNearbyDesc(int count) {
    return 'Menzilde $count şifrelenmemiş ağ tespit edildi. Açık ağlar kolayca dinlenebilir.';
  }

  @override
  String wpsEnabledNearbyTitle(int count) {
    return 'Yakında WPS Etkin $count Ağ Var';
  }

  @override
  String wpsEnabledNearbyDesc(int count) {
    return 'Yakındaki $count ağda WPS etkin. WPS PINi kaba kuvvetle (brute-force) ele geçirilebilir ve Wi-Fi şifresi tamamen devre dışı bırakılabilir.';
  }

  @override
  String get wpsRecommendation =>
      'Yönlendiricinizde WPSi devre dışı bırakın. Eğer bunlar sizin ağınız değilse, yakındaki erişim noktalarının daha az güvenli olabileceğini unutmayın.';

  @override
  String get renderingErrorTitle => 'GÖRSELLEŞTİRME HATASI';

  @override
  String get renderingErrorBody =>
      'Bu ekran çizilirken bir sorun oluştu. Lütfen uygulamayı yeniden başlatın.';

  @override
  String get dbHealedNotice =>
      'Bir depolama sorununu gidermek için bazı verileriniz sıfırlandı. Güvendiğiniz ağları yeniden ayarlamanız gerekebilir.';

  @override
  String get pingStabilizerConsentTitle => 'Ping Stabilizer\'ı Etkinleştir';

  @override
  String get pingStabilizerConsentDesc =>
      'Jitter ölçmek ve DNS\'i yönlendirmek için cihazınızda yerel bir VPN tüneli kurulacak. Oyun/yayında daha kararlı bağlantı için.';

  @override
  String get pingStabilizerConsentRouting =>
      'Trafiğiniz cihazınızda kalır. Uzak bir sunucuya hiçbir veri gönderilmez.';

  @override
  String get pingStabilizerConsentDns =>
      'Yalnızca DNS sorguları yönlendirilir; diğer paketler değiştirilmeden geçer.';

  @override
  String get pingStabilizerConsentControl =>
      'Tüneli istediğiniz anda bu ekrandan veya bildirimden durdurabilirsiniz.';

  @override
  String get pingStabilizerConsentAction => 'Stabilizer\'ı başlat';

  @override
  String get appTitleLong => 'Torcav Wi-Fi Analizörü';

  @override
  String get tosTitle => 'KULLANIM KOŞULLARI';

  @override
  String get tosAcceptanceTitle => '1. KABUL';

  @override
  String get tosAcceptanceBody =>
      'Torcav\'a erişerek veya onu kullanarak bu Koşullara bağlı olmayı kabul edersiniz. Kabul etmiyorsanız Uygulamayı kullanmayı derhal bırakmalısınız.';

  @override
  String get tosAuthorizedTestingTitle => '2. YALNIZCA YETKİLİ TEST';

  @override
  String get tosAuthorizedTestingBody =>
      'Uygulamayı yalnızca sahibi olduğunuz veya test etmek için açık, yazılı yetki aldığınız ağları ve cihazları analiz etmek için kullanacağınızı beyan ve taahhüt edersiniz. Ağlara yetkisiz erişim kesinlikle yasaktır ve bulunduğunuz ülkede yasa dışı olabilir.';

  @override
  String get tosDisclaimerTitle => '3. GARANTİ REDDİ';

  @override
  String get tosDisclaimerBody =>
      'Uygulama \"olduğu gibi\" ve \"mevcut haliyle\" sunulur. Uygulamanın tüm güvenlik zafiyetlerini tespit edeceğini veya sonuçlarının %100 doğru olduğunu garanti etmiyoruz. Kullanım riski size aittir.';

  @override
  String get tosLiabilityTitle => '4. SORUMLULUĞUN SINIRLANDIRILMASI';

  @override
  String get tosLiabilityBody =>
      'Geliştiriciler, Uygulamanın kullanımından veya kullanılamamasından doğan hiçbir zarardan (veri veya kâr kaybı ya da iş kesintisi dahil ancak bunlarla sınırlı olmamak üzere) hiçbir durumda sorumlu tutulamaz.';

  @override
  String get tosModificationsTitle => '5. DEĞİŞİKLİKLER';

  @override
  String get tosModificationsBody =>
      'Bu koşulları herhangi bir zamanda değiştirme hakkımız saklıdır. Değişikliklerden sonra Uygulamayı kullanmaya devam etmeniz yeni koşulları kabul ettiğiniz anlamına gelir.';

  @override
  String get tosLastUpdated => 'Son Güncelleme: Nisan 2026';

  @override
  String get legalNoticeTitle => 'YASAL UYARI';

  @override
  String get legalNoticeBody =>
      'Bu uygulama bir güvenlik denetim aracıdır. Bu yazılımın izinsiz ağlara erişmek veya onları izlemek için kötüye kullanılması kesinlikle yasaktır.';

  @override
  String get privacyTitle => 'GİZLİLİK POLİTİKASI';

  @override
  String get privacyIntro =>
      'Torcav \"Varsayılan Olarak Gizlilik\" ilkesi üzerine inşa edilmiştir. Neredeyse her bayt cihazınızda kalır — hesap yok, bulut senkronizasyonu yok, analiz yok, reklam yok. Birkaç özellik genel teknik uç noktalara (Cloudflare, Google\'ın captive-portal sorgusu, genel DNS çözücüleri) bağlanır — bunlar yalnızca IP\'nizi görür, asla herhangi bir Torcav dahili kimliğini görmez. Kaydedilen her kaydı tek bir dokunuşla silebilirsiniz.';

  @override
  String get privacyViewFullGithub => 'TÜM POLİTİKAYI GITHUB\'DA GÖRÜNTÜLE';

  @override
  String get privacyFullPolicyDesc =>
      'Aşağıdaki kart listesi bir özettir. Kanonik, KVKK + GDPR formatındaki politika github.io adresinde barındırılmaktadır.';

  @override
  String get privacyResponsibleTitle => 'KİM SORUMLU';

  @override
  String get privacyIndividualDev => 'Bireysel Geliştirici';

  @override
  String privacyDevBody(String email) {
    return 'Torcav, kayıtlı bir şirket değil, bireysel bir geliştirici (Halil İbrahim Avşar) tarafından işletilmektedir. Veri sorumlusuna doğrudan $email adresinden ulaşabilirsiniz.';
  }

  @override
  String get privacyDataCollectionTitle => 'VERİ TOPLAMA VE KULLANIM';

  @override
  String get privacyWifiAnalysisTitle => 'Wi-Fi ve Ağ Analizi';

  @override
  String get privacyWifiAnalysisBody =>
      'Yakındaki SSID/BSSID/RSSI meta verileri ve güvenlik bayrakları (WPA2/WPA3/WPS/PMF) işletim sistemi tarama API\'sinden okunur. Bu veriler yerel bir SQLite veritabanında şifrelenmiş olarak saklanır. Asla sunucuya yüklenmez.';

  @override
  String get privacyLanInventoryTitle => 'LAN Cihaz Envanteri';

  @override
  String get privacyLanInventoryBody =>
      'Bir LAN taraması çalıştırdığınızda uygulama, aynı ağdaki cihazlar için IP/MAC/ana bilgisayar adı/üretici/açık portları toplar. Bu, üçüncü taraf cihazları içerebilir — dışa aktarmalar için anonimleştirme varsayılan olarak açıktır.';

  @override
  String get privacyLocationTitle => 'Konum İzni (Yalnızca Wi-Fi)';

  @override
  String get privacyLocationBody =>
      'Android, Wi-Fi taramasını etkinleştirmek için konum izni gerektirir. Torcav bunu kesinlikle bunun için kullanır — GPS koordinatlarını okumayız ve hareketi izlemeyiz.';

  @override
  String get privacySensorsTitle => 'Sensörler ve Isı Haritası';

  @override
  String get privacySensorsBody =>
      'Isı haritası anketleri sırasında sinyal gücünü göreli yolunuza (başlangıç = tarama başlangıcı) eşlemek için etkinlik tanıma + IMU/barometer kullanılır. GPS kullanılmaz.';

  @override
  String get privacyAiTitle => 'AI / Yerel Sınıflandırma';

  @override
  String get privacyAiBody =>
      'Cihaz tipi tanımlama, yerel bir ONNX modeli kullanır. Hiçbir tescilli veya satıcı verisi cihazdan ayrılmaz.';

  @override
  String get privacyExternalEndpointsTitle => 'DIŞ UÇ NOKTALAR';

  @override
  String get privacyCloudflareTitle => 'Cloudflare Hız Testi';

  @override
  String get privacyCloudflareBody =>
      'Speed Doctor ve hız testi sayfası speed.cloudflare.com\'a karşı ~300-500 MB indirme/yükleme yapar. Cloudflare IP\'nizi görür — hiçbir Torcav kimliği veya telemetrisi eklenmez.';

  @override
  String get privacyDnsProbesTitle => 'Genel DNS Sorguları';

  @override
  String get privacyDnsProbesBody =>
      'DNS karşılaştırması ve sızıntı tespiti için 1.1.1.1, 8.8.8.8, 9.9.9.9, OpenDNS ve AdGuard sorgulanır. Standart DNS sorgularını görürler (kullanıcı kimliği yok).';

  @override
  String get privacyCaptivePortalTitle => 'Captive Portal Sorgusu';

  @override
  String get privacyCaptivePortalBody =>
      'connectivitycheck.gstatic.com, captive portal\'ları tespit etmek için düz bir HEAD isteği alır. Bu, Android\'in kendisinin çalıştırdığı sorgunun aynısıdır.';

  @override
  String get privacyBreachCheckTitle =>
      'Parola Sızıntı Kontrolü (Have I Been Pwned)';

  @override
  String get privacyBreachCheckBody =>
      'Sızıntı kontrolü api.pwnedpasswords.com\'u k-anonimlik ile sorgular: parola bu cihazda SHA-1 özetine çevrilir ve özetin yalnızca ilk 5 karakteri gönderilir. Parolanın tamamı veya tam özeti telefondan asla çıkmaz; hiçbir şey kaydedilmez.';

  @override
  String get privacyNoTrackersTitle => 'Analiz Yok, İzleyici Yok, Reklam Yok';

  @override
  String get privacyNoTrackersBody =>
      'v1.0\'da sıfır analiz SDK\'sı, sıfır reklam kimliği, sıfır kilitlenme raporlama hizmeti vardır. Uygulama başlangıcında merkeze bildirim yapmayız.';

  @override
  String get privacyRetentionTitle => 'SAKLAMA VE SİLME';

  @override
  String get privacyConfigRetentionTitle => 'Yapılandırılabilir Saklama';

  @override
  String get privacyConfigRetentionBody =>
      'Ayarlar → Gizlilik, tarama geçmişi, hız testleri ve güvenlik olayları için saklama pencereleri (7-365 gün) ayarlamanıza olanak tanır. Varsayılan değer 30 gündür. Eski kayıtlar otomatik olarak budanır.';

  @override
  String get privacyWipeLocalDataTitle => 'Tüm Yerel Verileri Temizle';

  @override
  String get privacyWipeLocalDataBody =>
      'Ayarlar → Gizlilik\'te tek bir dokunuşla tüm kayıtlı verileri temizler: taramalar, cihazlar, güvenlik olayları, ısı haritası oturumları, LAN geçmişi, dışa aktarmalar. Geri alınamaz.';

  @override
  String get privacyRightsTitle => 'HAKLARINIZ';

  @override
  String get privacyKvkkGdprTitle => 'KVKK (Türkiye) + GDPR (AB/AEA)';

  @override
  String privacyRightsBody(String email) {
    return 'Verilerinize erişim, düzeltme, silme veya taşınabilirlik talebinde bulunabilirsiniz. Silme işlemi için uygulama içi Tümünü Sil düğmesi en hızlı yoldur. Diğer talepler için $email adresine e-posta gönderin — 30 gün içinde yanıt veririz.';
  }

  @override
  String get privacyChildrenTitle => 'Çocukların Gizliliği';

  @override
  String get privacyChildrenBody =>
      'Torcav 13 yaşın altındaki kullanıcılara yönelik değildir ve kullanıcının taranan ağın sorumluluğunu alacak kadar büyük olduğunu varsayar.';

  @override
  String get privacyAuthorisedUseTitle => 'Yalnızca Yetkili Kullanım';

  @override
  String get privacyAuthorisedUseBody =>
      'Torcav\'ı sahibi olduğunuz veya açıkça tarama yetkiniz olan ağlarda kullanın. Sahibi olmadığınız ağlarda aktif LAN keşfi ve port tarama yapmak Türk, AB ve ABD yasalarını ihlal edebilir.';

  @override
  String get privacyContactLabel => 'İLETİŞİM';

  @override
  String get privacyEffectiveDate =>
      'Yürürlük Tarihi: 08.05.2026 • Versiyon 1.0';

  @override
  String get hardeningTitle => 'YÖNLENDİRİCİ GÜÇLENDİRME';

  @override
  String get hardeningMarkDone => 'TAMAMLANDI İŞARETLE';

  @override
  String get hardeningOpenAdmin => 'YÖNETİCİ PANELİNİ AÇ';

  @override
  String get hardeningStepsTitle => 'İŞLEM ADIMLARI';

  @override
  String get hardeningMenuHintsTitle => 'YAYGIN MENÜ İSİMLERİ';

  @override
  String get hardeningCriticalBadge => 'KRİTİK';

  @override
  String get hardeningChangeAdminPasswordTitle =>
      'Yönlendirici yönetici şifresini değiştirin';

  @override
  String get hardeningChangeAdminPasswordBody =>
      'Varsayılan yönetici kimlik bilgileri (admin/admin, admin/password) herkese açık olarak belgelenmiştir. Wi-Fi ağınızdaki herhangi biri yönetici panelini açabilir ve ayarları değiştirebilir — DNS\'i ele geçirebilir, trafiği yönlendirebilir, sizi dışarıda bırakabilir.';

  @override
  String get hardeningChangeAdminPasswordStep1 =>
      'Bu sayfanın üst kısmındaki büyük YÖNETİCİ PANELİNİ AÇ düğmesine dokunun. Tarayıcınız yönlendirici giriş sayfasını açacaktır.';

  @override
  String get hardeningChangeAdminPasswordStep2 =>
      'Giriş yapın. Değiştirmediyseniz kullanıcı adı olarak \"admin\" ve şifre olarak \"admin\" veya \"password\" deneyin.';

  @override
  String get hardeningChangeAdminPasswordStep3 =>
      '\"Administration\", \"System\", \"Maintenance\" veya \"Account\" adında bir menü bulun.';

  @override
  String get hardeningChangeAdminPasswordStep4 =>
      'Bu menünün içinde \"Login password\", \"Admin password\" veya \"Change password\" arayın.';

  @override
  String get hardeningChangeAdminPasswordStep5 =>
      'YENİ bir şifre seçin — en az 12 karakter, büyük harf, küçük harf, rakam ve sembol karıştırın.';

  @override
  String get hardeningChangeAdminPasswordStep6 =>
      'Kaydet / Uygula. Yönlendirici yaklaşık 30 saniyeliğine yeniden başlayabilir.';

  @override
  String get hardeningChangeAdminPasswordStep7 =>
      'Yeni şifreyi güvenli bir yere not edin.';

  @override
  String get hardeningChangeAdminPasswordStep8 =>
      'Kaydedildikten sonra, buraya geri dönün ve TAMAMLANDI İŞARETLE\'ye dokunun.';

  @override
  String get hardeningUseWpa3OrWpa2AesTitle =>
      'WPA3 kullanın, WPA2-AES\'e geri dönün';

  @override
  String get hardeningUseWpa3OrWpa2AesBody =>
      'WPA3 modern Wi-Fi şifreleme standardıdır. WPA/TKIP ve WEP dakikalar içinde kırılabilir.';

  @override
  String get hardeningDisableWpsTitle => 'WPS\'i devre dışı bırakın';

  @override
  String get hardeningDisableWpsBody =>
      'WPS, saldırganların saatler içinde Wi-Fi şifrenizi atlamasını sağlar. Kapatın.';

  @override
  String get hardeningEnablePmfTitle => 'PMF / 802.11w\'yi etkinleştirin';

  @override
  String get hardeningEnablePmfBody =>
      'Korumalı Yönetim Çerçeveleri (PMF), saldırganların cihazlarınızı çevrimdışı bırakmasını engeller.';

  @override
  String get hardeningEnableGuestNetworkTitle =>
      'Bir misafir ağı etkinleştirin';

  @override
  String get hardeningEnableGuestNetworkBody =>
      'Ziyaretçiler ve IoT cihazları için ikinci bir SSID, özel ağınızı güvende tutar.';

  @override
  String get hardeningDisableRemoteAdminTitle =>
      'Uzaktan / WAN tarafı yönetimi devre dışı bırakın';

  @override
  String get hardeningDisableRemoteAdminBody =>
      'Yönetici paneline internetten ulaşılabiliyorsa, herkes varsayılan şifreleri deneyebilir.';

  @override
  String get hardeningUpdateFirmwareTitle =>
      'Aygıt yazılımını (Firmware) güncelleyin';

  @override
  String get hardeningUpdateFirmwareBody =>
      'Çoğu ev yönlendiricisinin, üreticilerin sessizce yamaladığı bilinen güvenlik açıkları vardır.';

  @override
  String get hardeningStrongPassphraseTitle =>
      'Güçlü bir Wi-Fi parolası kullanın';

  @override
  String get hardeningStrongPassphraseBody =>
      '12+ karakter, büyük/küçük harf karışık, başka bir servisten asla tekrar kullanılmamış.';

  @override
  String gatewayCopyError(String ip) {
    return 'Tarayıcı otomatik olarak açılamadı. Ağ geçidi IP\'si $ip kopyalandı — tarayıcınızın adres çubuğuna yapıştırın.';
  }

  @override
  String gatewayCopied(String ip) {
    return 'Ağ geçidi IP\'si $ip panoya kopyalandı.';
  }

  @override
  String get hardeningConnectWifiHint =>
      'İlerlemeyi yönlendirici bazında takip etmek için ev Wi-Fi ağınıza bağlanın. Kontrol listesi bağlantı olmadan da çalışır.';

  @override
  String get progressLabel => 'İLERLEME';

  @override
  String get tapToCopy => 'kopyalamak için dokunun';

  @override
  String get hardeningOpenAdminDesc =>
      'Tarayıcıda yönlendirici giriş sayfanızı açın';

  @override
  String get hardeningConnectWifiRequired => 'Önce Wi-Fi\'ye bağlanın';

  @override
  String get hardeningGatewayHintDisconnected =>
      'Bağlandıktan sonra ağ geçidi IP\'si yukarıda görünür ve düğme tarayıcınızı başlatır.';

  @override
  String get hardeningGatewayHintConnected =>
      'Açılmıyor mu? Kopyalamak için yukarıdaki ağ geçidi IP\'sine dokunun, ardından tarayıcınızın adres çubuğuna (Chrome, Firefox vb.) yapıştırın.';

  @override
  String get whyThisMattersLabel => 'BU NEDEN ÖNEMLİ';

  @override
  String get markAsTodoLabel => 'YAPILACAK OLARAK İŞARETLE';

  @override
  String get vpnRecommendation =>
      'Bilinmeyen veya güvenilmeyen ağlara bağlanırken güvenilir bir VPN kullanın.';

  @override
  String get exportLocalDataTitle => 'YEREL VERİYİ DIŞA AKTAR';

  @override
  String get exportLocalDataDesc =>
      'Bu cihazdaki verileriniz, sizin elinizde. Bir kategori seçin; JSON olarak paylaşın veya kaydedin.';

  @override
  String get exportCategoryLabel => 'Kategori';

  @override
  String get exportFormatLabel => 'Biçim';

  @override
  String get jsonExportLabel => 'JSON — eksiksiz, makine tarafından okunabilir';

  @override
  String get csvExportLabel => 'CSV — Excel/Sheets ile açılır';

  @override
  String get csvSingleCategoryOnlyLabel => 'CSV — yalnızca tek kategori';

  @override
  String get htmlExportLabel => 'HTML — tarayıcıda görüntülenebilir';

  @override
  String get anonymizeIdentifiersLabel => 'Tanımlayıcıları anonimleştir';

  @override
  String get anonymizeIdentifiersDesc =>
      'BSSID/MAC\'in son 3 oktetini maskele, SSID ve hostname\'i gizle.';

  @override
  String get noIdentifiersToMaskDesc =>
      'Bu kategoride maskelenecek tanımlayıcı yok.';

  @override
  String get exportingLabel => 'DIŞA AKTARILIYOR…';

  @override
  String exportAsLabel(String format) {
    return '$format OLARAK AKTAR';
  }

  @override
  String get exportPrivacyNote =>
      'Siz paylaşana kadar cihazınızda kalır. Hiçbir sunucuya gönderilmez.';

  @override
  String get categoryWifiScanHistory => 'Wi-Fi tarama geçmişi';

  @override
  String get categorySpeedTestResults => 'Hız testi sonuçları';

  @override
  String get categorySecurityEvents => 'Güvenlik olayları';

  @override
  String get categoryKnownAndTrustedNetworks => 'Bilinen + güvenilen ağlar';

  @override
  String get categoryChannelRatingsHistory => 'Kanal puanı geçmişi';

  @override
  String get categoryHeatmapSessions => 'Isı haritası oturumları';

  @override
  String get categoryLanScanLatest => 'LAN taraması (en son)';

  @override
  String get categoryDeviceLabelOverrides => 'Cihaz etiketi değişiklikleri';

  @override
  String get categoryPinnedNetworks => 'Sabitlenmiş ağlar';

  @override
  String get categoryScoreHistory => 'Güvenlik puanı geçmişi';

  @override
  String get categoryNetworkContextOverrides => 'Ağ bağlamı değişiklikleri';

  @override
  String get categoryRouterHardeningProgress =>
      'Router sıkılaştırma ilerlemesi';

  @override
  String get macRandomizedLabel => 'MAC Rastgeleleştirilmiş';

  @override
  String get notificationsBlockedTitle => 'Bildirimler engelli';

  @override
  String get notificationsBlockedDesc =>
      'Canlı ping göstergesi bildirim panelinde yaşar. Bildirimler olmadan oyun sırasında ping\'i göremezsiniz. MIUI/Xiaomi\'de ayrıca \"Kilit ekranında göster\" ve \"Kayan bildirimler\"i etkinleştirin.';

  @override
  String get liveLatencyLabel => 'Canlı gecikme';

  @override
  String get latencyStatLabel => 'Gecikme';

  @override
  String get jitterStatLabel => 'Jitter';

  @override
  String get lossStatLabel => 'Kayıp';

  @override
  String baselineLatencyLabel(String ms) {
    return 'Taban (tünel öncesi): $ms ms';
  }

  @override
  String jitterThresholdLabel(String ms) {
    return 'Jitter alarm eşiği: $ms ms';
  }

  @override
  String get heatmapSettingsTitle => 'Isı Haritası Ayarları';

  @override
  String get dnsLabel => 'DNS';

  @override
  String get notNowLabel => 'ŞİMDİ DEĞİL';

  @override
  String get newNetworkLabel => '+ YENİ';

  @override
  String get goneNetworkLabel => 'KAYIP';

  @override
  String get hiddenNetworkLabel => '[Gizli]';

  @override
  String get randomizedMacDetectedLabel => 'Rastgele MAC Tespit Edildi';

  @override
  String get howPingStabilizerWorksTitle => 'Ping Sabitleyici Nasıl Çalışır';

  @override
  String get stabilizerExplainerSubtitle =>
      'Cihaz üzerinde, uzak sunucu yok, ücretsiz.';

  @override
  String get whatItDoesTitle => 'Ne Yapar';

  @override
  String get whatItDoesBullet1 =>
      'Cihazınızda yerel bir VPN tüneli kurar — hiçbir trafik üçüncü taraf bir sunucudan geçmez.';

  @override
  String get whatItDoesBullet2 =>
      'DNS sorgularını canlı olarak ölçülen en hızlı çözücüye (1.1.1.1, 8.8.8.8, 9.9.9.9, …) yönlendirir.';

  @override
  String get whatItDoesBullet3 =>
      'Gecikme ve jitter değerlerini saniye saniye izler; ani bir artış olduğunda sizi uyarır veya kötüleşen yolu düzeltmek için tüneli yenileyebilir.';

  @override
  String get whatItDoesBullet4 =>
      'Gerçek performans kaybını ayırt etmek için EWMA filtresi kullanır, böylece anlık paket gürültülerine değil gerçek sorunlara tepki verir.';

  @override
  String get whatItDoesNotTitle => 'Ne Yapmaz';

  @override
  String get whatItDoesNotBullet1 =>
      'Servis sağlayıcınızın (ISP) oyun sunucusuna olan fiziksel yolunu kısaltamaz — hiçbir uygulama bunu yapamaz.';

  @override
  String get whatItDoesNotBullet2 =>
      'ExitLag veya WTFast gibi ücretli VPN/relay servislerinin yerini tutmaz (onlar kendi sunucuları üzerinden yönlendirme yapar; bu ise yereldir).';

  @override
  String get whatItDoesNotBullet3 =>
      'Wi-Fi + Mobil veri üzerinden eşzamanlı gönderim (Phase 2) geliştirme aşamasındadır ve şu an devre dışıdır.';

  @override
  String get risksAndThingsToKnowTitle => 'Riskler ve Bilinmesi Gerekenler';

  @override
  String get risksBullet1 =>
      'Tünel aktifken Android\'de anahtar simgesi görünür — bu normaldir ve sistem gereksinimidir.';

  @override
  String get risksBullet2 =>
      'Aynı anda sadece bir VPN çalışabilir. Başka bir VPN bağlıysa, bu özellik başlamayı reddedecektir.';

  @override
  String get risksBullet3 =>
      'Tünel çalışırken bildirim panelinde kalıcı bir bildirim (güncel ping + Durdur / Yenile butonları) kalır — bu sizin oyun içi panelinizdir; kapatmayın.';

  @override
  String get risksBullet4 =>
      'Xiaomi/MIUI, OnePlus/OxygenOS ve benzeri arayüzlerde, Torcav\'ı Ayarlar → Bildirimler ve Ayarlar → Pil → Kısıtlama yok altında izin vermeniz gerekebilir; aksi takdirde sistem bildirimi gizleyebilir.';

  @override
  String get risksBullet5 =>
      'DNS otomatik geçişi, tünel açıkken sorgularınızı cevaplayan çözücüyü değiştirir. Sabitleyici durduğunda bu değişiklik geri alınır.';

  @override
  String get risksBullet6 =>
      'Pil kullanımı düşüktür (testlerimizde ~%3-5/saat) ancak sıfır değildir — oyununuz bittiğinde kapatmayı unutmayın.';

  @override
  String get shieldIntegrityLabel => 'KALKAN BÜTÜNLÜĞÜ';

  @override
  String get activeThreatsLabel => 'AKTİF TEHDİTLER';

  @override
  String get shieldStatusOptimal => 'OPTİMAL';

  @override
  String get shieldStatusWarning => 'UYARI';

  @override
  String get shieldStatusCritical => 'KRİTİK';

  @override
  String get securityScoreLabel => 'GÜVENLİK PUANI';

  @override
  String get systemStatusLabel => 'SİSTEM DURUMU';

  @override
  String get scanningAllCaps => 'TARIYOR...';

  @override
  String bssidLabel(String bssid) {
    return 'BSSID: $bssid';
  }

  @override
  String gatewayWithIpLabel(String gateway) {
    return 'AĞ GEÇİDİ: $gateway';
  }

  @override
  String get trustedBadge => 'GÜVENİLİR';

  @override
  String get identifiedBadge => 'TANIMLANDI';

  @override
  String authEstablishedLabel(String date) {
    return 'YETKİLİ BAĞLANTI: $date';
  }

  @override
  String get revokeTrustTooltip => 'GÜVENİ GERİ AL';

  @override
  String get apsLabel => 'Erişim Noktaları';

  @override
  String get openLabel => 'Açık';

  @override
  String get wpsLabel => 'WPS';

  @override
  String get wepLabel => 'WEP';

  @override
  String get publicWifiLabel => 'Halka Açık Wi-Fi';

  @override
  String get guestNetworkLabel => 'Misafir Ağı';

  @override
  String get publicWifiDesc =>
      'Açık veya güvenilmeyen ağ — trafiğin izlenebileceğini varsayın.';

  @override
  String get guestNetworkDesc =>
      'Misafir segmentindesiniz. Varsayılan olarak güvenilmez kabul edin.';

  @override
  String get tipVpnTitle => 'VPN kullanın';

  @override
  String get tipVpnBody =>
      'Hassas bir şey göndermeden önce trafiği güvendiğiniz bir VPN\'den tünelleyin. Çoğu kullanıcı için işletim sisteminin yerleşik VPN\'i yeterlidir.';

  @override
  String get tipHttpsTitle => 'HTTPS\'i doğrulayın';

  @override
  String get tipHttpsBody =>
      'Kimlik bilgilerini yalnızca kilitli asma kilit görünen sitelere girin. Sertifika uyarılarını reddedin — saldırganlar TLS\'i böyle soyar.';

  @override
  String get tipSensitiveTitle => 'Hassas işlemleri erteleyin';

  @override
  String get tipSensitiveBody =>
      'Güvendiğiniz bir ağa dönene kadar bankacılık, ödeme, parola sıfırlama ve hesap girişlerinden kaçının.';

  @override
  String get tipDnsTitle => 'DNS sağlığını kontrol edin';

  @override
  String get tipDnsBody =>
      'Halka açık erişim noktaları DNS\'i ele geçirebilir. Yanıtların değiştirilmediğini doğrulamak için bu ekrandan bir DNS testi çalıştırın.';

  @override
  String evilTwinPrefix(String confidence) {
    return 'KÖTÜ İKİZ · $confidence';
  }

  @override
  String get whatIsEvilTwinTitle => 'BU NEDİR?';

  @override
  String get whyItMattersTitle => 'NEDEN ÖNEMLİ?';

  @override
  String get whatWeObservedTitle => 'NELER GÖZLEMLEDİK?';

  @override
  String get whatLookedLegitimateTitle => 'NELER MEŞRU GÖRÜNÜYOR?';

  @override
  String get whatYouShouldDoTitle => 'NELER YAPMALISINIZ?';

  @override
  String get hardeningUseWpa3OrWpa2AesStep1 =>
      'Üstteki düğmeyi kullanarak yönetici panelini açın.';

  @override
  String get hardeningUseWpa3OrWpa2AesStep2 =>
      'Kablosuz (Wireless) bölümünü bulun: \"Wireless\", \"Wi-Fi\" veya \"WLAN\".';

  @override
  String get hardeningUseWpa3OrWpa2AesStep3 =>
      'Bir güvenlik veya şifreleme ayarı arayın — genellikle \"Security mode\", \"Authentication\" veya \"Encryption\" olarak adlandırılır.';

  @override
  String get hardeningUseWpa3OrWpa2AesStep4 =>
      'Şu sırayla en güçlü seçeneği belirleyin: WPA3-Personal > WPA2/WPA3 mixed > WPA2-Personal (AES). \"WPA-PSK\", \"TKIP\", \"WEP\" veya \"Open\" etiketli olanlardan kaçının — bunlar güvensizdir.';

  @override
  String get hardeningUseWpa3OrWpa2AesStep5 =>
      'WPA3-Personal ayarlarsanız ve eski bir cihaz (akıllı ampul, yazıcı, eski telefon) çalışmayı durdurursa, \"WPA2/WPA3 mixed\" seçeneğine geçin — bu, eski donanımların bağlanmasına izin verirken yeni cihazların hala WPA3 kullanmasını sağlar.';

  @override
  String get hardeningUseWpa3OrWpa2AesStep6 =>
      'Ayrı 2.4 GHz ve 5 GHz ayarlarınız varsa, HER İKİ bandı da değiştirin.';

  @override
  String get hardeningUseWpa3OrWpa2AesStep7 =>
      'Kaydet / Uygula. Cihazlarınızın bağlantısı kısa bir süreliğine kesilebilir — birkaç saniye içinde yeniden bağlanacaklardır.';

  @override
  String get hardeningUseWpa3OrWpa2AesStep8 =>
      'Buraya geri dönün ve TAMAMLANDI İŞARETLE\'ye dokunun.';

  @override
  String get hardeningDisableWpsStep1 => 'Yönetici panelini açın.';

  @override
  String get hardeningDisableWpsStep2 =>
      'Kablosuz (Wireless) veya Wi-Fi bölümünü bulun.';

  @override
  String get hardeningDisableWpsStep3 =>
      '\"WPS\", \"Easy Setup\", \"Quick Connect\" adında bir alt menü veya Kablosuz Ayarlarında WPS etiketli bir sekme arayın.';

  @override
  String get hardeningDisableWpsStep4 =>
      'WPS anahtarını OFF / Disabled (Kapalı) konumuna getirin.';

  @override
  String get hardeningDisableWpsStep5 =>
      'Bazı yönlendiricilerin üzerinde fiziksel bir WPS düğmesi de bulunur — bu da çalışmayı durduracaktır ki amaç da budur.';

  @override
  String get hardeningDisableWpsStep6 => 'Kaydet / Uygula.';

  @override
  String get hardeningDisableWpsStep7 =>
      'Şu andan itibaren, yeni bir cihaz bağladığınızda sadece normal şekilde Wi-Fi şifresini yazın. Ekstra 10 saniye sürer, ciddi bir saldırı yolunu ortadan kaldırır.';

  @override
  String get hardeningDisableWpsStep8 =>
      'Buraya geri dönün ve TAMAMLANDI İŞARETLE\'ye dokunun.';

  @override
  String get hardeningEnablePmfStep1 => 'Yönetici panelini açın.';

  @override
  String get hardeningEnablePmfStep2 =>
      'Kablosuz (Wireless) / Wi-Fi bölümüne gidin.';

  @override
  String get hardeningEnablePmfStep3 =>
      '\"Advanced\" veya \"Wireless Security\" altında \"PMF\", \"802.11w\" veya \"Management Frame Protection\" adlı bir ayar arayın.';

  @override
  String get hardeningEnablePmfStep4 =>
      'Tüm cihazlarınız yeni ise (son ~5 yıl) \"Required\" (Gerekli) olarak ayarlayın. Eski cihazlar ağı görmemeye başlarsa, bunu \"Optional / Capable\" (İsteğe Bağlı) olarak değiştirin — bu yine de yardımcı olur, sadece daha az kısıtlayıcıdır.';

  @override
  String get hardeningEnablePmfStep5 =>
      'Bu ayarı hiçbir yerde bulamıyorsanız, yönlendiriciniz bunu WPA3 moduna entegre etmiş olabilir (bu nedenle yukarıdaki 2. adımı tamamlamak zaten kapsar). Bu durumda, buradaki TAMAMLANDI İŞARETLE\'ye de dokunun.';

  @override
  String get hardeningEnablePmfStep6 => 'Kaydet / Uygula.';

  @override
  String get hardeningEnablePmfStep7 =>
      'Buraya geri dönün ve TAMAMLANDI İŞARETLE\'ye dokunun.';

  @override
  String get hardeningEnableGuestNetworkStep1 => 'Yönetici panelini açın.';

  @override
  String get hardeningEnableGuestNetworkStep2 =>
      '\"Guest Network\", \"Guest Wi-Fi\" veya \"Multi-SSID\" adında bir menü bulun.';

  @override
  String get hardeningEnableGuestNetworkStep3 =>
      'Etkinleştirin. Ana Wi-Fi ağınızdan farklı bir isim verin — örneğin, ana ağınız \"Ev\" ise misafir ağına \"Ev-Misafir\" deyin.';

  @override
  String get hardeningEnableGuestNetworkStep4 =>
      'Bir şifre belirleyin. Ana şifrenizden daha basit olabilir (misafirler yazacaktır), ancak yine de 10+ karakter olmalıdır.';

  @override
  String get hardeningEnableGuestNetworkStep5 =>
      '\"Client Isolation\", \"AP Isolation\" veya \"Guest network isolation\" adında bir ayar arayın. Açık (ON) duruma getirin. Bu, misafir cihazların birbirleriyle veya özel ağınızla konuşmasını engeller.';

  @override
  String get hardeningEnableGuestNetworkStep6 =>
      'IoT cihazlarınızı (akıllı prizler, kameralar, robot süpürge, akıllı TV vb.) misafir ağına taşıyın — onları yeni şifreyle bağlayın.';

  @override
  String get hardeningEnableGuestNetworkStep7 => 'Kaydet / Uygula.';

  @override
  String get hardeningEnableGuestNetworkStep8 =>
      'Buraya geri dönün ve TAMAMLANDI İŞARETLE\'ye dokunun.';

  @override
  String get hardeningDisableRemoteAdminStep1 => 'Yönetici panelini açın.';

  @override
  String get hardeningDisableRemoteAdminStep2 =>
      '\"Administration\", \"System Tools\" veya \"Security\" bölümüne gidin.';

  @override
  String get hardeningDisableRemoteAdminStep3 =>
      '\"Remote Management\", \"Web Access from WAN\" veya \"Remote admin\" adlı bir ayar bulun.';

  @override
  String get hardeningDisableRemoteAdminStep4 =>
      'Bunu OFF / Disabled (Kapalı) konumuna getirin.';

  @override
  String get hardeningDisableRemoteAdminStep5 =>
      'Buradayken, \"Cloud / Remote App access\" ayarını da kontrol edin (bazı markalarda bu vardır — TP-Link Tether, Asus Router app, Mi Wi-Fi). Bu uygulamayı aktif olarak kullanmıyorsanız, onu da kapatın.';

  @override
  String get hardeningDisableRemoteAdminStep6 => 'Kaydet / Uygula.';

  @override
  String get hardeningDisableRemoteAdminStep7 =>
      'Yönlendiricinizi hala evinizin içinden yönetebilirsiniz — sadece uzaktan / genel internet yolu kapatılmıştır.';

  @override
  String get hardeningDisableRemoteAdminStep8 =>
      'Buraya geri dönün ve TAMAMLANDI İŞARETLE\'ye dokunun.';

  @override
  String get hardeningUpdateFirmwareStep1 => 'Yönetici panelini açın.';

  @override
  String get hardeningUpdateFirmwareStep2 =>
      '\"Firmware Update\", \"System Update\", \"Online Upgrade\" veya \"Maintenance\" adında bir menü bulun.';

  @override
  String get hardeningUpdateFirmwareStep3 =>
      '\"Check for update\" veya \"Online check\" seçeneğine dokunun. Yönlendirici üretici sunucusunda daha yeni bir sürüm arayacaktır.';

  @override
  String get hardeningUpdateFirmwareStep4 =>
      'Bir güncelleme teklif edilirse kurun. Yönlendirici 2-5 dakika boyunca yeniden başlayacaktır — güncelleme sırasında cihazın FİŞİNİ ÇEKMEYİN, aksi takdirde cihaz kullanılamaz hale gelebilir.';

  @override
  String get hardeningUpdateFirmwareStep5 =>
      'Cihaz geri geldikten sonra aynı menüye gidin ve \"Auto update\" veya \"Automatic upgrade\" arayın. Varsa ON (Açık) konumuna getirin.';

  @override
  String get hardeningUpdateFirmwareStep6 =>
      'Bazı eski yönlendiricilerde çevrimiçi güncelleme bulunmaz. Bu durumda cihaz etiketinden yönlendirici modelini not edin, üretici web sitesinde arayın, en son aygıt yazılımı dosyasını indirin ve aynı menüdeki \"Manual upload\" seçeneğini kullanın.';

  @override
  String get hardeningUpdateFirmwareStep7 =>
      'Buraya geri dönün ve TAMAMLANDI İŞARETLE\'ye dokunun.';

  @override
  String get hardeningStrongPassphraseStep1 => 'Yönetici panelini açın.';

  @override
  String get hardeningStrongPassphraseStep2 =>
      '\"Wireless\", \"Wi-Fi\" veya \"WLAN\" bölümüne gidin.';

  @override
  String get hardeningStrongPassphraseStep3 =>
      'Şifre alanını bulun — \"Wireless password\", \"Pre-Shared Key (PSK)\", \"Wireless Key\" veya sadece \"Password\" olarak etiketlenmiştir.';

  @override
  String get hardeningStrongPassphraseStep4 =>
      'YENİ bir parola ile değiştirin: en az 12 karakter; büyük harf, küçük harf, rakam ve sembol karışımı olmalıdır. Sözlük kelimelerinden ve kişisel bilgilerden (doğum günleri, evcil hayvan adları) kaçının.';

  @override
  String get hardeningStrongPassphraseStep5 =>
      'İyi bir taktik: birbiriyle ilgisiz üç kelime artı bir sayı seçin, örn. \"dogru-at-batarya-9\". Uzun parolaları kırmak, kısa ama karmaşık olanları kırmaktan daha zordur.';

  @override
  String get hardeningStrongPassphraseStep6 =>
      'Ayrı 2.4 GHz ve 5 GHz ağlarınız varsa, HER İKİSİNİ de değiştirin.';

  @override
  String get hardeningStrongPassphraseStep7 =>
      'Kaydet / Uygula. Her cihazın bağlantısı kesilecektir — her birine yeni şifreyi tekrar girin.';

  @override
  String get hardeningStrongPassphraseStep8 =>
      'Şifreyi bir yere not edin (şifre yöneticisi, ziyaretçiler için buzdolabı notu, vb. hangisi size uyuyorsa).';

  @override
  String get hardeningStrongPassphraseStep9 =>
      'Buraya geri dönün ve TAMAMLANDI İŞARETLE\'ye dokunun.';

  @override
  String get severity_critical => 'KRİTİK';

  @override
  String get severity_high => 'YÜKSEK';

  @override
  String get severity_medium => 'ORTA';

  @override
  String get severity_low => 'DÜŞÜK';

  @override
  String get severity_info => 'BİLGİ';

  @override
  String get rule_scan_deep_scan_active_title => 'Derin Tarama Etkin';

  @override
  String get rule_scan_deep_scan_active_desc =>
      'Derin tarama etkinleştirildi, daha kapsamlı ağ testleri yapılıyor.';

  @override
  String get rule_scan_deep_scan_active_rec =>
      'Yalnızca sahibi olduğunuz veya tarama izniniz olan ağlarda kullanın.';

  @override
  String get rule_wifi_open_network_title => 'Açık Ağ Tespit Edildi';

  @override
  String get rule_wifi_open_network_desc =>
      'Şifreleme tespit edilmedi. Tüm trafik açık metin olarak izlenebilir.';

  @override
  String get rule_wifi_open_network_rec =>
      'Hassas aktivitelerden kaçının. Güvenilir bir VPN veya farklı bir ağ tercih edin.';

  @override
  String get rule_wifi_wep_title => 'WEP Şifreleme Tespit Edildi';

  @override
  String get rule_wifi_wep_desc =>
      'WEP artık güvenli değil ve kısa sürede kırılabilir.';

  @override
  String get rule_wifi_wep_rec =>
      'Erişim noktasını derhal WPA2 veya WPA3 olarak yeniden yapılandırın.';

  @override
  String get rule_wifi_legacy_wpa_title => 'Eski WPA Şifreleme';

  @override
  String get rule_wifi_legacy_wpa_desc =>
      'WPA/TKIP eski bir teknolojidir ve modern saldırı tekniklerine karşı zayıftır.';

  @override
  String get rule_wifi_legacy_wpa_rec =>
      'Erişim noktasını ve istemcileri WPA2/WPA3\'e yükseltin.';

  @override
  String get rule_wifi_hidden_ssid_title => 'Gizli SSID';

  @override
  String get rule_wifi_hidden_ssid_desc =>
      'Gizli SSID\'ler hala keşfedilebilir durumdadır ve uyumluluk sorunlarına yol açabilir.';

  @override
  String get rule_wifi_hidden_ssid_rec =>
      'Gizli SSID tek başına bir koruma değildir. Güçlü şifrelemeye odaklanın.';

  @override
  String get rule_wifi_very_weak_signal_title => 'Çok Zayıf Sinyal';

  @override
  String get rule_wifi_very_weak_signal_desc =>
      'Zayıf sinyal kararsız bağlantılara ve sahte erişim noktası saldırılarına karşı duyarlılığa işaret edebilir.';

  @override
  String get rule_wifi_very_weak_signal_rec =>
      'Erişim noktasına yaklaşın veya BSSID tutarlılığını doğrulayın.';

  @override
  String get rule_wifi_wps_enabled_title => 'WPS Etkin';

  @override
  String get rule_wifi_wps_enabled_desc =>
      'Wi-Fi Korumalı Kurulum (WPS) etkin. WPS PIN modu saatler içinde kaba kuvvetle kırılabilir.';

  @override
  String get rule_wifi_wps_enabled_rec =>
      'Yönlendirici yönetim panelinden WPS\'i devre dışı bırakın. Yalnızca WPA2/WPA3 parolası kullanın.';

  @override
  String get rule_wifi_pmf_not_enforced_title => 'PMF Zorunlu Değil';

  @override
  String get rule_wifi_pmf_not_enforced_desc =>
      'Bu erişim noktası Korumalı Yönetim Çerçevelerini (PMF / 802.11w) zorunlu kılmıyor, bu da bağlantı kesme saldırılarına izin verebilir.';

  @override
  String get rule_wifi_pmf_not_enforced_rec =>
      'Yönlendirici ayarlarından PMF\'yi etkinleştirin (genellikle \'802.11w\' veya \'Yönetim Çerçevesi Koruması\' olarak adlandırılır).';

  @override
  String get rule_wifi_suspicious_sibling_ap_title => 'Şüpheli Kardeş AP';

  @override
  String get rule_wifi_suspicious_sibling_ap_desc =>
      'Yakındaki bir erişim noktası bu SSID\'yi paylaşıyor ancak parmak izi uyuşmuyor; bu, bir saldırganın gerçek bir Wi-Fi\'yi taklit etmek için kullandığı bir yöntemdir.';

  @override
  String get rule_wifi_suspicious_sibling_ap_rec =>
      'Yönlendiricinizin arkasındaki BSSID\'yi doğrulamadan bu ağa şifre girmeyin.';

  @override
  String get rule_wifi_suspicious_ssid_title => 'Şüpheli SSID';

  @override
  String get rule_wifi_suspicious_ssid_desc =>
      'Bu SSID, saldırganlar tarafından kullanıcıları kandırmak için kullanılan yaygın \'bal küpü\' (honeypot) desenleriyle eşleşiyor (örn. \'Free WiFi\').';

  @override
  String get rule_wifi_suspicious_ssid_rec =>
      'Bağlanmadan önce ağın doğruluğunu işletme yetkilisiyle teyit edin. Bağlanmanız gerekiyorsa mutlaka VPN kullanın.';

  @override
  String get rule_wifi_high_channel_congestion_title =>
      'Yüksek Kanal Yoğunluğu';

  @override
  String get rule_wifi_high_channel_congestion_desc =>
      'Bu kanaldaki aşırı yoğunluk performansı ve bağlantı güvenilirliğini düşürür.';

  @override
  String get rule_wifi_high_channel_congestion_rec =>
      'Ağ yöneticisinden daha az yoğun bir kanala geçmesini isteyin.';

  @override
  String get rule_wifi_only_24ghz_title => 'Yalnızca 2.4 GHz';

  @override
  String get rule_wifi_only_24ghz_desc =>
      'Bu ağ yalnızca kalabalık 2.4 GHz bandında yayın yapıyor. 5 GHz daha iyi performans sunar.';

  @override
  String get rule_wifi_only_24ghz_rec =>
      'Daha iyi performans için yönlendiricinizde 5 GHz bandını etkinleştirin.';

  @override
  String get rule_trusted_baseline_drift_title => 'Güvenilir Temel Hat Sapması';

  @override
  String get rule_trusted_baseline_drift_desc =>
      'Bu erişim noktası artık daha önce güvendiğiniz parmak iziyle eşleşmiyor.';

  @override
  String get rule_trusted_baseline_drift_rec =>
      'Yönlendirici yapılandırmasını yeniden doğrulayın ve değişikliğin kasıtlı olduğundan eminseniz yeniden güvenin.';

  @override
  String get rule_hardware_vulnerability_title => 'Donanım Zafiyeti';

  @override
  String get rule_hardware_vulnerability_desc =>
      'BSSID öneki bilinen zayıf bir donanım profiliyle eşleşyor.';

  @override
  String get rule_hardware_vulnerability_rec =>
      'Bu model için bilinen güvenlik açıklarını (CVE) gideren üretici aygıt yazılımı güncellemelerini kontrol edin.';

  @override
  String get noLiveScanAvailable => 'CANLI TARAMA YOK';

  @override
  String noLiveScanDesc(String ssid) {
    return 'Şu anda \"$ssid\" ağını içeren güncel bir Wi-Fi taraması yok; bu yüzden canlı sinyal dökümü gösterilemiyor. Keşif sekmesinden yeni bir Wi-Fi taraması çalıştırın ve tüm kanıtı görmek için bu uyarıyı yeniden açın.';
  }

  @override
  String get outOf100Label => '/ 100';

  @override
  String get networkLabel => 'Ağ';

  @override
  String get noActivityYet => 'HENÜZ ETKİNLİK YOK';

  @override
  String get runFirstScanDesc =>
      'Zaman çizelgesini doldurmak için ilk taramanızı çalıştırın.';

  @override
  String get networkContextTitle => 'AĞ BAĞLAMI';

  @override
  String get networkContextHomeDesc =>
      'Eviniz, ofisiniz veya bildiğiniz yönlendirici. Sıkı standartlar uygulanır.';

  @override
  String get networkContextPublicDesc =>
      'Kafe, otel, havaalanı veya açık bağlantı noktası. VPN/HTTPS şiddetle tavsiye edilir.';

  @override
  String get networkContextGuestDesc =>
      'Bilinen bir ağın misafir segmenti. Doğal sapmalar beklenebilir.';

  @override
  String get networkContextUnknownDesc =>
      'Torcav\'ın bağlamı pasif sinyallerden çıkarmasına izin verin.';

  @override
  String scanVia(String backend) {
    return '$backend ile tarama';
  }

  @override
  String get justNow => 'az önce';

  @override
  String minutesAgo(int count) {
    return '$count dk önce';
  }

  @override
  String hoursAgo(int count) {
    return '$count sa önce';
  }

  @override
  String daysAgo(int count) {
    return '$count gün önce';
  }

  @override
  String get rogueApSuspected => 'Sahte AP şüphesi';

  @override
  String get deauthActivity => 'Deauth etkinliği';

  @override
  String get captivePortal => 'Captive portal';

  @override
  String get evilTwinDetected => 'Evil twin tespit edildi';

  @override
  String get encryptionDowngrade => 'Şifreleme düşürme';

  @override
  String get unsupportedOp => 'Desteklenmeyen işlem';

  @override
  String get arpSpoofing => 'ARP spoofing';

  @override
  String get dnsHijacking => 'DNS hijacking';

  @override
  String networksWithCount(int count) {
    return 'Ağlar ($count)';
  }

  @override
  String signalStability(String stability) {
    return 'Kararlılık $stability';
  }

  @override
  String get metricSignal => 'SİNYAL';

  @override
  String get metricScoreTrend => 'PUAN TRENDİ';

  @override
  String get metricChannels => 'KANALLAR';

  @override
  String get metricNewDevices => 'YENİ CİHAZLAR';

  @override
  String get metricThreats => 'TEHDİTLER';

  @override
  String get metricSpeed => 'HIZ';

  @override
  String get severityCrit => 'KRİT';

  @override
  String get severityHighShort => 'YÜKSEK';

  @override
  String get severityMedShort => 'ORTA';

  @override
  String get severityInfoShort => 'BİLGİ';

  @override
  String get hardenRouterTitle => 'ROUTER\'I SIKILAŞTIR';

  @override
  String get hardenRouterSubtitle => 'Güvenlik kontrol listesi';

  @override
  String get packetLossLabel => 'PAKET KAYBI';

  @override
  String get loadedLatencyLabel => 'YÜK ALTINDA GECİKME';

  @override
  String get clearHistoryTooltip => 'Tüm geçmişi temizle';

  @override
  String get whatIsThisSection => 'Bu nedir?';

  @override
  String get whyItMattersSection => 'Neden önemli?';

  @override
  String get covShort => 'KAP';

  @override
  String get sigShort => 'SNY';

  @override
  String get motShort => 'HRK';

  @override
  String get wifiShort => 'WIFI';

  @override
  String get camShort => 'KAM';

  @override
  String get discardSurveyTooltip => 'Keşfi Sil';

  @override
  String get finishReviewTooltip => 'Bitir ve İncele';

  @override
  String get noDataAtLocation => 'BU KONUMDA VERİ YOK';

  @override
  String get rssiLabel => 'RSSI';

  @override
  String get statusLabel => 'DURUM';

  @override
  String get floorLabel => 'KAT';

  @override
  String get positionLabel => 'KONUM';

  @override
  String get samplesLabel => 'ÖRNEKLER';

  @override
  String get capturedLabel => 'KAYDEDİLDİ';

  @override
  String get heatmapPermissionsTitle => 'ISI HARİTASI İZİNLERİ';

  @override
  String get realignCompassTooltip => 'Pusulayı Yeniden Hizala';

  @override
  String get exportCsvLabel => 'CSV Dışa Aktar';

  @override
  String get setDeviceType => 'Cihaz Türünü Ayarla';

  @override
  String get resetToAiLabel => 'AI etiketine dön';

  @override
  String get gatewayCaps => 'AĞ GEÇİDİ';

  @override
  String get identifiedCaps => 'TANIMLANDI';

  @override
  String get unknownMacRestricted => 'BİLİNMEYEN MAC (KISITLI)';

  @override
  String get scanPortsCaps => 'PORTLARI TARA';

  @override
  String get noOpenPortsFound => 'Açık port bulunamadı';

  @override
  String get criticalCaps => 'KRİTİK';

  @override
  String get wpsActiveCaps => 'WPS AKTİF';

  @override
  String get protectPdfTitle => 'PDF\'İ PAROLAYLA KORU';

  @override
  String get pdfLockedHint =>
      'İsteğe bağlı. Kilitli dosya: .torcav-pdf — tekrar açmak için Raporlar\'ı kullanın.';

  @override
  String get pdfLockedLabel =>
      'Kilitli dosya: .torcav-pdf — tekrar açmak için Raporlar\'ı kullanın.';

  @override
  String get pdfPasswordHint => 'Parola (düz PDF için boş bırakın)';

  @override
  String get pdfPasswordWarning =>
      'Dikkat: bu hafif bir gizlemedir, banka düzeyi şifreleme değildir. Dosyayı sıradan sızıntılara (bulut küçük resimleri, posta kutusu önbelleği) karşı korur; ancak dosyaya sahip kararlı bir saldırgan zayıf bir parolayı kaba kuvvetle kırmayı deneyebilir. Uzun ve benzersiz bir parola cümlesi kullanın.';

  @override
  String get openLockedReport => 'Kilitli raporu aç';

  @override
  String get unlockDialogBody =>
      'Bu dosyayı kilitlerken kullandığınız parolayı girin.';

  @override
  String get unlockPasswordHint => 'Parola';

  @override
  String get unlockFailed =>
      'Parola yanlış veya bu dosya Torcav ile kilitlenmemiş.';

  @override
  String unlockedToast(String path) {
    return 'Rapor açıldı: $path';
  }

  @override
  String get understandEnable => 'ANLADIM — ETKİNLEŞTİR';

  @override
  String get categorySignal => 'Sinyal';

  @override
  String get categoryChannel => 'Kanal';

  @override
  String get categoryBufferbloat => 'Bufferbloat';

  @override
  String get categoryIsp => 'ISS Bant Genişliği';

  @override
  String get categoryDns => 'DNS';

  @override
  String get categoryHealthy => 'Sağlıklı';

  @override
  String get severityHigh => 'YÜKSEK';

  @override
  String get severityMed => 'ORTA';

  @override
  String get severityLow => 'DÜŞÜK';

  @override
  String get speedDoctorActionMoveCloser => 'Daha yakına taşı';

  @override
  String get speedDoctorActionAddMesh => 'Mesh düğümü ekle';

  @override
  String get speedDoctorActionSwitchTo5Ghz => '5 GHz\'e geç';

  @override
  String get speedDoctorActionChangeChannel => 'Kanalı değiştir';

  @override
  String get speedDoctorActionMoveTo5Ghz => '5 GHz\'e taşı';

  @override
  String get speedDoctorActionEnableQos => 'QoS / SQM etkinleştir';

  @override
  String get speedDoctorActionUpdateFirmware => 'Yazılımı güncelle';

  @override
  String get speedDoctorActionCallIsp => 'Servis sağlayıcıyı ara';

  @override
  String get speedDoctorActionRunWiredTest => 'Kablolu test yap';

  @override
  String get speedDoctorActionChangeDns => 'DNS değiştir';

  @override
  String get speedDoctorActionEnableDoh => 'DoH etkinleştir';

  @override
  String get waitingForHistory => 'Geçmiş veriler bekleniyor';

  @override
  String get noScanData => 'Tarama verisi yok';

  @override
  String get mbps => 'Mbps';

  @override
  String get primaryCauseWeakSignalTitle => 'ZAYIF SİNYAL';

  @override
  String get primaryCauseWeakSignalDesc =>
      'Cihazınız yönlendiriciden çok uzakta veya arada çok fazla duvar var. Daha yakına taşıyın veya bu alana bir mesh düğümü ekleyin.';

  @override
  String get primaryCauseCrowdedChannelTitle => 'KALABALIK KANAL';

  @override
  String get primaryCauseCrowdedChannelDesc =>
      'Çevredeki birkaç erişim noktası kanalınızı paylaşıyor. Daha az kalabalık bir kanala veya 5/6 GHz\'e geçmek yardımcı olacaktır.';

  @override
  String get primaryCauseBufferbloatTitle => 'BUFFERBLOAT';

  @override
  String get primaryCauseBufferbloatDesc =>
      'Bağlantı meşgul olduğunda gecikme artıyor. Trafik dalgalanmalarını yönetmek için yönlendiricinizde QoS / SQM özelliğini etkinleştirin.';

  @override
  String get primaryCauseIspSlowTitle => 'ISS HIZ SINIRI';

  @override
  String get primaryCauseIspSlowDesc =>
      'Wi-Fi bağlantınız sağlıklı ancak indirme hızı düşük. Darboğaz büyük olasılıkla internet planınızdan veya servis sağlayıcınızdan kaynaklanıyor.';

  @override
  String get primaryCauseSlowDnsTitle => 'YAVAŞ DNS';

  @override
  String get primaryCauseSlowDnsDesc =>
      'İsimlerin çözümlenmesi çok uzun sürüyor. DNS sağlayıcısını değiştirmek veya DoH/DoT özelliğini etkinleştirmek genellikle gecikmeyi ortadan kaldırır.';

  @override
  String get primaryCauseHealthyTitle => 'AĞ SAĞLIKLI';

  @override
  String get primaryCauseHealthyDesc =>
      'Hiçbir darboğaz uyarı eşiğine ulaşmadı. Bağlantınız şu an iyi görünüyor.';

  @override
  String get diagStepReadingSignal => 'Sinyal okunuyor';

  @override
  String get diagStepAnalysingChannels => 'Kanallar analiz ediliyor';

  @override
  String get diagStepMeasuringSpeed => 'Hız ölçülüyor';

  @override
  String get diagStepBenchmarkingDns => 'DNS kıyaslanıyor';

  @override
  String get hideDetails => 'Detayları gizle';

  @override
  String get whatIsThisHowToFix => 'Bu nedir? · Nasıl düzeltilir';

  @override
  String get reviewing => 'İNCELEME';

  @override
  String get idle => 'BOŞTA';

  @override
  String get surveyComplete => 'KEŞİF TAMAMLANDI';

  @override
  String get coverage => 'KAPSAMA';

  @override
  String get blindSpots => 'KÖR NOKTALAR';

  @override
  String get saveAndFinish => 'KAYDET VE BİTİR';

  @override
  String get diagStepFinalizing => 'Teşhis tamamlanıyor';

  @override
  String get heatmapPageTitle => 'EV PLANI + WIFI ISI HARİTASI';

  @override
  String get heatmapPageSubtitle => 'Kontur, kapsama ve zayıf bölgeler';

  @override
  String get heatmapHistoryTooltip => 'Kayıtlı keşifleri aç';

  @override
  String get heatmapThemeToggleTooltip =>
      'Görünümü değiştir (Blueprint / Neon)';

  @override
  String get heatmapSamplesShort => 'örnek';

  @override
  String get heatmapRestartSurvey => 'KEŞFİ YENİDEN BAŞLAT';

  @override
  String get heatmapRenameSurvey => 'KEŞFİ YENİDEN ADLANDIR';

  @override
  String get heatmapShareHeatmap => 'ISI HARİTASINI PAYLAŞ';

  @override
  String get heatmapRenameDialogTitle => 'KEŞFİ YENİDEN ADLANDIR';

  @override
  String get heatmapSave => 'Kaydet';

  @override
  String get heatmapShareSubject => 'Torcav AR Wi-Fi Taramam';

  @override
  String get heatmapShareText =>
      'Torcav ile evimin Wi-Fi haritasını çıkardım ve ölü noktaları buldum! Sizin internetiniz neden yavaş? Torcav\'ı indirin ve keşfedin: torcav.com';

  @override
  String get heatmapSamplesLabel => 'ÖRNEKLER';

  @override
  String get heatmapAvgSignalLabel => 'ORT. SİNYAL';

  @override
  String get heatmapNotAvailable => 'Hazır değil';

  @override
  String get heatmapNoSurveyYetTitle => 'Bir Keşif Başlatın';

  @override
  String get heatmapNoSurveyYetBody =>
      'Önce bir yürüyüş turu başlatın. Sonuç görünümü, kontur ve ısı haritasını birlikte gösterecek.';

  @override
  String get heatmapWalkToBeginTitle => 'Yürümeye Başlayın';

  @override
  String get heatmapWalkToBeginBody =>
      'Her odada birkaç adım attıkça iz ve sinyal noktaları görünür.';

  @override
  String get heatmapStartSurvey => 'KEŞFE BAŞLA';

  @override
  String get heatmapNewSurveyDialogTitle => 'YENİ KEŞİF';

  @override
  String heatmapDefaultSessionName(String time) {
    return 'Keşif $time';
  }

  @override
  String get heatmapSessionNameField => 'Keşif adı';

  @override
  String get heatmapNewSurveyHint =>
      'Keşif başladığında, siz hareket ettikçe sinyal örnekleri otomatik eklenir. Daha güçlü bir oda konturu isterseniz AR\'a geçin.';

  @override
  String get heatmapSavedSurveysTitle => 'KAYITLI KEŞİFLER';

  @override
  String get heatmapNoSavedSurveys => 'Henüz kayıtlı keşif yok.';

  @override
  String heatmapSavedSurveySubtitle(int samples, int weak, String timestamp) {
    return '$samples örnek · $weak zayıf bölge · $timestamp';
  }

  @override
  String get heatmapDeleteSurveyTooltip => 'Keşfi sil';

  @override
  String channelShort(int channel) {
    return 'CH $channel';
  }

  @override
  String get langEnglish => 'English';

  @override
  String get langTurkish => 'Türkçe';

  @override
  String get langKurdish => 'Kurdî';

  @override
  String get langGerman => 'Deutsch';

  @override
  String get startNowCaps => 'BAŞLAT';

  @override
  String get howToFixSection => 'NASIL DÜZELTİLİR';

  @override
  String get endSurveyDialogTitle => 'Anketi Bitir?';

  @override
  String get endSurveyDialogBody =>
      'Anketi iptal ederseniz mevcut verileriniz kaybolacak. Kaydet veya İptal Et?';

  @override
  String get endSurveyReviewBody => 'Oturum incelemesinden çıkılsın mı?';

  @override
  String get discardAction => 'İPTAL ET';

  @override
  String get exitAction => 'ÇIKIŞ';

  @override
  String get continueAction => 'DEVAM';

  @override
  String get discardSurveyDialogTitle => 'ANKETİ İPTAL ET?';

  @override
  String get discardSurveyDialogBody =>
      'Bu oturum için kaydedilen tüm veriler kalıcı olarak silinecek.';

  @override
  String get autoSamplingDistance => 'Otomatik Örnekleme Mesafesi';

  @override
  String get appearanceLabel => 'Görünüm';

  @override
  String get clearHistoryAction => 'GEÇMİŞİ TEMİZLE';

  @override
  String get dataUsageWarningTitle => 'VERİ KULLANIMI UYARISI';

  @override
  String get dataUsageWarningBody =>
      'Bu hız testi ~300–500 MB veri indirir. Mobil/ölçümlü bir bağlantıdaysanız ücret oluşabilir veya veri limitiniz tükenebilir.';

  @override
  String latencyExcellentTitle(String ms) {
    return 'Gecikme: $ms ms — Mükemmel';
  }

  @override
  String latencyGoodTitle(String ms) {
    return 'Gecikme: $ms ms — İyi';
  }

  @override
  String latencyAcceptableTitle(String ms) {
    return 'Gecikme: $ms ms — Kabul Edilebilir';
  }

  @override
  String latencyHighTitle(String ms) {
    return 'Gecikme: $ms ms — Yüksek';
  }

  @override
  String get latencyExcellentBody =>
      'Neredeyse anlık yanıt. Oyun, video görüşme ve gerçek zamanlı uygulamalar için ideal.';

  @override
  String get latencyGoodBody =>
      'Video görüşme ve akış için iyi. Çoğu uygulama duyarlı hissettiri.';

  @override
  String get latencyAcceptableBody =>
      'Tarama ve akış için uygun, ancak video görüşmelerinde hafif gecikmeler olabilir.';

  @override
  String get latencyHighBody =>
      'Belirgin gecikme. Video görüşmeler ve oyunlar yavaş hissedebilir. Routerınıza daha yakın olmayı deneyin.';

  @override
  String jitterStableTitle(String ms) {
    return 'Titreşim: $ms ms — Kararlı';
  }

  @override
  String jitterGoodTitle(String ms) {
    return 'Titreşim: $ms ms — İyi';
  }

  @override
  String jitterModerateTitle(String ms) {
    return 'Titreşim: $ms ms — Orta';
  }

  @override
  String jitterUnstableTitle(String ms) {
    return 'Titreşim: $ms ms — Kararsız';
  }

  @override
  String get jitterStableBody =>
      'Çok tutarlı bağlantı. Paketleriniz minimum zamanlama farkıyla ulaşıyor.';

  @override
  String get jitterGoodBody =>
      'Görüşme ve akış için yeterince kararlı. Wi-Fi\'da küçük dalgalanma normaldir.';

  @override
  String get jitterModerateBody =>
      'Bazı tutarsızlıklar tespit edildi. Anlık artışlarda sesli görüşmeler bozulabilir.';

  @override
  String get jitterUnstableBody =>
      'Yüksek dalgalanma — ses ve video görüşmeleri muhtemelen kopacak. Bunun nedeni parazit veya kalabalık kanal olabilir.';

  @override
  String downloadFastTitle(String mbps) {
    return 'İndirme: $mbps Mbps — Hızlı';
  }

  @override
  String downloadGoodTitle(String mbps) {
    return 'İndirme: $mbps Mbps — İyi';
  }

  @override
  String downloadModerateTitle(String mbps) {
    return 'İndirme: $mbps Mbps — Orta';
  }

  @override
  String downloadSlowTitle(String mbps) {
    return 'İndirme: $mbps Mbps — Yavaş';
  }

  @override
  String downloadFastBody(int streams) {
    return 'Kolayca $streams+ eş zamanlı HD akışı kaldırır. Büyük haneler için harika.';
  }

  @override
  String downloadGoodBody(int streams) {
    return '$streams eş zamanlı HD akışı destekler. Çoğu hane için iyi.';
  }

  @override
  String get downloadModerateBody =>
      'Gezinti ve bir veya iki SD akış için yeterli. Büyük indirmeler yavaş olacak.';

  @override
  String get downloadSlowBody =>
      'Çok sınırlı. Routerınıza yaklaşmayı veya parazit kontrolü yapmayı düşünün.';

  @override
  String uploadFastTitle(String mbps) {
    return 'Yükleme: $mbps Mbps — Hızlı';
  }

  @override
  String uploadGoodTitle(String mbps) {
    return 'Yükleme: $mbps Mbps — İyi';
  }

  @override
  String uploadLimitedTitle(String mbps) {
    return 'Yükleme: $mbps Mbps — Sınırlı';
  }

  @override
  String uploadSlowTitle(String mbps) {
    return 'Yükleme: $mbps Mbps — Yavaş';
  }

  @override
  String get uploadFastBody =>
      'Video konferans, bulut yedeklemesi ve canlı yayın için mükemmel.';

  @override
  String get uploadGoodBody =>
      'Video görüşmeler ve dosya paylaşımı için iyi. Bulut yüklemeleri makul hızda olacak.';

  @override
  String get uploadLimitedBody =>
      'Temel video görüşmeler için yeterli. Büyük dosya yüklemeleri zaman alacak.';

  @override
  String get uploadSlowBody =>
      'Çok yavaş yükleme. Canlı video ve bulut eşitleme güçlük çekecek.';

  @override
  String get packetLossPerfectTitle => 'Paket Kaybı: %0 — Mükemmel';

  @override
  String packetLossMinimalTitle(String pct) {
    return 'Paket Kaybı: %$pct — Minimal';
  }

  @override
  String packetLossHighTitle(String pct) {
    return 'Paket Kaybı: %$pct — Yüksek';
  }

  @override
  String get packetLossPerfectBody =>
      'Sağlam bağlantı. Değerlendirme sırasında hiçbir veri paketi kaybolmadı.';

  @override
  String get packetLossMinimalBody =>
      'Çok az kayıp. Çoğu aktivite için muhtemelen fark edilmez.';

  @override
  String get packetLossHighBody =>
      'Veriler düşüyor. Bu, görüşme ve oyunlarda takılmalara neden olur. Wi-Fi paraziti kontrol edin.';

  @override
  String loadedLatencyExcellentTitle(String ms) {
    return 'Yüklü Gecikme: $ms ms — Mükemmel';
  }

  @override
  String loadedLatencyGoodTitle(String ms) {
    return 'Yüklü Gecikme: $ms ms — İyi';
  }

  @override
  String loadedLatencyFairTitle(String ms) {
    return 'Yüklü Gecikme: $ms ms — Orta';
  }

  @override
  String loadedLatencyPoorTitle(String ms) {
    return 'Yüklü Gecikme: $ms ms — Kötü';
  }

  @override
  String get loadedLatencyExcellentBody =>
      'İndirme sırasında bile ağınız duyarlı kalıyor. Mükemmel router kalitesi.';

  @override
  String get loadedLatencyGoodBody =>
      'Yanıt süresi yük altında hafifçe artıyor ama çok kullanılabilir.';

  @override
  String get loadedLatencyFairBody =>
      'Başkaları ağı kullanırken belirgin gecikme. İndirirken oyun oynamak etkilenebilir.';

  @override
  String get loadedLatencyPoorBody =>
      'Yüksek Bufferbloat. Büyük indirmeler sırasında bağlantı yanıt veremiyor. Router\'ınızda QoS etkinleştirmeyi düşünün.';

  @override
  String get bufferbloatGradeLabel => 'BUFFERBLOAT DERECESİ';

  @override
  String get bufferbloatGradeA =>
      'Mükemmel bufferbloat kontrolü. Router\'ınız ağır yük altında bile gecikmeyi düşük tutuyor.';

  @override
  String get bufferbloatGradeB =>
      'İyi bufferbloat. Yük altında küçük gecikme artışı — çoğu kullanıcı fark etmez.';

  @override
  String get bufferbloatGradeC =>
      'Orta bufferbloat. Başkaları indirirken oyun ve video görüşmeleri gecikebilir.';

  @override
  String get bufferbloatGradeD =>
      'Zayıf bufferbloat. Yük altında bağlantı yavaşlıyor. Router\'ınızda QoS etkinleştirin.';

  @override
  String get bufferbloatGradeE =>
      'Şiddetli bufferbloat. Eş zamanlı indirmeler sırasında gerçek zamanlı uygulamalar başarısız olur.';

  @override
  String get bufferbloatGradeF =>
      'Kritik bufferbloat. Router\'ınız kuyruk derinliğini kontrol etmiyor. Ürün yazılımını veya donanımı yükseltin.';

  @override
  String get speedTestDisclaimer =>
      'Sonuçlar Cloudflare\'ın en yakın sunucusuna hızı yansıtır ve Wi-Fi, cihaz donanımı ve PoP mesafesinden etkilenir. ISP sözleşme hızınızın doğrudan bir ölçümü değildir.';

  @override
  String get clearAllHistoryAction => 'TÜM GEÇMİŞİ TEMİZLE';

  @override
  String get deleteAllHistoryConfirm =>
      'Tüm hız testi kayıtları silinsin mi? Bu işlem geri alınamaz.';

  @override
  String get deleteAllAction => 'TÜMÜNÜ SİL';

  @override
  String whyIsThisLabel(String level) {
    return 'BU NEDEN $level?';
  }

  @override
  String get noSpecificConcerns =>
      'Bu cihaz için belirli bir endişe kaydedilmedi. Rozet toplu bir puanı yansıtır.';

  @override
  String get whatToDoLabel => 'NE YAPILMALI';

  @override
  String get trustLevelSafe => 'GÜVENLİ';

  @override
  String get trustLevelCaution => 'DİKKAT';

  @override
  String get trustLevelRisky => 'RİSKLİ';

  @override
  String get wipeAllDialogTitle => 'TÜM VERİYİ SİL';

  @override
  String get wipeAllDialogBody =>
      'Tüm yerel tarama geçmişi, hız testi kayıtları, güvenlik olayları, kanal derecelendirmeleri ve bellek içi anlık görüntüler kalıcı olarak silinecek. Bu işlem geri alınamaz.';

  @override
  String get wipeAllAction => 'TÜMÜNÜ SİL';

  @override
  String get allDataWiped => 'Tüm yerel veriler silindi.';

  @override
  String get systemDefault => 'Sistem Varsayılanı';

  @override
  String portScanTimeoutMs(int ms) {
    return '$ms ms';
  }

  @override
  String get legendAndNodes => 'EFSANE & DÜĞÜMLER';

  @override
  String get legendGateway => 'AĞ GEÇİDİ';

  @override
  String get legendGatewayDesc => 'Merkezi ağ giriş noktası';

  @override
  String get legendAccessPoint => 'ERİŞİM NOKTASI';

  @override
  String get legendAccessPointDesc => 'Wi-Fi sinyal dağıtıcı';

  @override
  String get legendMobile => 'MOBİL';

  @override
  String get legendMobileDesc => 'Kişisel taşınabilir cihazlar';

  @override
  String get legendIot => 'IOT';

  @override
  String get legendIotDesc => 'Akıllı ev ve sensörler';

  @override
  String get legendDevice => 'CİHAZ';

  @override
  String get legendDeviceDesc => 'Bilgisayarlar, TV\'ler vb.';

  @override
  String get surveyStageStandby => 'BEKLEME';

  @override
  String get surveyStageInitializing => 'BAŞLATILIYOR';

  @override
  String get surveyStageSweepRooms => 'ODA TARAMASI';

  @override
  String get surveyStageWeakZone => 'ZAYIF BÖLGE';

  @override
  String get surveyStageWrapUp => 'TAMAMLANIYOR';

  @override
  String get surveyStageReview => 'İNCELEME';

  @override
  String get connectionTypesHeader => 'BAĞLANTI TÜRLERİ';

  @override
  String get connTypeSolidLineLabel => 'Düz Çizgi (Mavi)';

  @override
  String get connTypeSolidLineDesc =>
      'Yüksek hızlı kablolu Ethernet bağlantısı';

  @override
  String get connTypeGradientLabel => 'Parlayan Gradyan (Camgöbeği)';

  @override
  String get connTypeGradientDesc => 'Kablosuz Wi-Fi bağlantısı';

  @override
  String get connTypePulsingLabel => 'Nabız Atan Veri Noktası';

  @override
  String get connTypePulsingDesc => 'Bağlantıda aktif trafik tespit edildi';

  @override
  String get uploadLabel => 'YÜKLEME';

  @override
  String get downloadLabel => 'İNDİRME';

  @override
  String get speedTestSemanticsIdle =>
      'Hız testi göstergesi. Başlatmak için dokun.';

  @override
  String speedTestSemanticsRunning(String mbps) {
    return 'Hız testi çalışıyor — $mbps Mbps indirme. Durdurmak için dokun.';
  }

  @override
  String speedTestSemanticsComplete(String dl, String ul) {
    return 'Hız testi tamamlandı — $dl Mbps indirme, $ul Mbps yükleme.';
  }

  @override
  String get measurementLockedTitle => 'ÖLÇÜM KİLİTLENDİ';

  @override
  String get measurementLockNoWifi =>
      'Anket hedefini kilitlemek için bir Wi-Fi ağına bağlanın.';

  @override
  String measurementLockReconnect(String bssid) {
    return 'Örneklemeye devam etmek için $bssid ile yeniden bağlanın.';
  }

  @override
  String get waitingForSignalTitle => 'TAZE SİNYAL BEKLENİYOR';

  @override
  String get waitingForSignalBody =>
      'RSSI 3 saniyeden eski. Yeni tarama için kısa süre yürüyün veya pozisyonu koruyun.';

  @override
  String get signalDroppedTitle => 'SİNYAL DÜŞTÜ';

  @override
  String get signalDroppedBody =>
      'Wi-Fi sinyali -85dBm\'nin altında. Erişim noktasına yaklaşın.';

  @override
  String get compassDriftTitle => 'PUSULA KAYMASI TESPİT EDİLDİ';

  @override
  String get measurementLockMagnetic =>
      'Manyetik parazit bulundu. Sekiz çizin veya Hizala\'ya dokunun.';

  @override
  String get placeSurveyOriginTitle => 'ANKET KÖKENİNİ YERLEŞTİRİN';

  @override
  String get measurementLockAnchor =>
      'Noktaları kaydetmeden önce AR anketini sabitlemek için algılanan bir düzleme dokunun.';

  @override
  String get trackingLostTitle => 'İZLEME KAYBOLDU';

  @override
  String get measurementLockTracking =>
      'Hareket takibi kullanılamıyor. İzleme geri gelene kadar yavaşça hareket edin.';

  @override
  String get readyBannerTapFinish => 'Taramayı bitirmek için dokun';

  @override
  String get ssidChipLock => 'KİLİT';

  @override
  String get ssidChipHold => 'BEKLE';

  @override
  String get guidanceStageIdle => 'Bekleme';

  @override
  String get guidanceStageInitializing => 'Başlatılıyor';

  @override
  String get guidanceStageMappingSignal => 'Sinyal Haritalanıyor';

  @override
  String get guidanceStageScanningWeakZones => 'Zayıf Bölgeler Taranıyor';

  @override
  String get guidanceStageReadyToFinish => 'Bitirmeye Hazır';

  @override
  String get guidanceStageReviewing => 'İnceleniyor';

  @override
  String get signalProbeHint =>
      'Yakalanan bir sinyal noktasına daha yakın dokunmayı deneyin.';

  @override
  String get wifiSecurityOpen => 'AÇIK';

  @override
  String get newSessionPermissionsBody =>
      'Doğru ısı haritaları oluşturmak ve ağ kapsamınızı haritalamak için Torcav belirli cihaz özelliklerine erişim gerektirir:';

  @override
  String get newSessionPermLocation =>
      'Konum (sinyali koordinatlara eşlemek için)';

  @override
  String get newSessionPermCamera =>
      'Kamera (isteğe bağlı, görsel haritalama özellikleri için)';

  @override
  String get reportsMacMaskDesc =>
      'Dışa aktarmadan önce son 3 sekizliyi maskeler (XX:XX:XX)';

  @override
  String get reportsShareSubject => 'Torcav Tarama Raporu';

  @override
  String exportNoDataYet(String label) {
    return '\"$label\" için henüz veri yok.';
  }

  @override
  String get exportSubject => 'Torcav yerel veri dışa aktarma';

  @override
  String exportFailedError(String error) {
    return 'Dışa aktarma başarısız: $error';
  }

  @override
  String get tapToStart => 'BAŞLATMAK İÇİN DOKUN';

  @override
  String get tapToStop => 'DURDURMAK İÇİN DOKUN';

  @override
  String get liveWifi => 'CANLI WI-FI';

  @override
  String get signalProbeTitle => 'SİNYAL SONDASI';

  @override
  String get statusOptimal => 'EN UYGUN';

  @override
  String get statusFair => 'ORTA';

  @override
  String get statusCritical => 'KRİTİK';

  @override
  String daysCount(int count) {
    return '$count g';
  }

  @override
  String secondsCount(int count) {
    return '$count sn';
  }

  @override
  String millisecondsCount(int count) {
    return '$count ms';
  }

  @override
  String get languageEnglish => 'İngilizce 🇺🇸';

  @override
  String get languageTurkish => 'Türkçe 🇹🇷';

  @override
  String get languageKurdish => 'Kürtçe ☀️';

  @override
  String get languageGerman => 'Almanca 🇩🇪';

  @override
  String get sdWeakSignalWhatIs =>
      'Sinyal gücü (RSSI), cihazınızın yönlendiriciyi ne kadar yüksek sesle duyduğunu ölçer. Yaklaşık −70 dBm\'nin altında, Wi-Fi\'ın güvenilir kalması için daha yavaş, daha yedekli kodlamalara geçmesi gerekir.';

  @override
  String get sdWeakSignalWhyItMatters =>
      'Zayıf bir sinyal, radyoyu düşük hız modlarına zorlar. İnternet paketiniz hızlı olsa bile, Wi-Fi bağlantısının kendisi tavan haline gelir — indirmeler durur, görüntülü aramalar kesilir ve sayfaların yüklenmesi daha uzun sürer.';

  @override
  String get sdWeakSignalHowToFix1 =>
      'Yönlendiriciye daha yakın bir yere veya daha az engelli bir noktaya geçin.';

  @override
  String get sdWeakSignalHowToFix2 =>
      'Bu bölgeye bir mesh düğümü / Wi-Fi genişletici ekleyin.';

  @override
  String get sdWeakSignalHowToFix3 =>
      'Yönlendiriciniz bu SSID\'de 5 GHz veya 6 GHz\'i destekliyorsa, yönlendiriciyi görüş alanınızdayken bu bandı kullanın.';

  @override
  String get sdWeakSignalHowToFix4 =>
      'Yönlendiricinin bir kabinin içine, TV\'nin arkasına veya bir mikrodalga fırının yanına gömülmediğinden emin olun.';

  @override
  String sdWeakSignalEstimate(String gain) {
    return 'Tahmini kazanç: Cihazı yönlendiriciye yaklaştırabilirseniz indirme hızında +$gain Mbps\'ye kadar artış.';
  }

  @override
  String get sdCrowdedChannelWhatIs =>
      'Wi-Fi kanalları paylaşılan bir spektrumdur. Yakındaki birkaç erişim noktası aynı kanalda iletim yaptığında, sırayla hareket etmeleri gerekir — hava süresi sizinki de dahil olmak üzere hepsi arasında bölünür.';

  @override
  String get sdCrowdedChannelWhyItMatters =>
      'Kalabalık bir kanalda, evinizde kimse ağı kullanmasa bile veri akış hızınız düşer. Radyo donanımı sağlıklıdır ancak konuşmak için sırasını beklemek zorundadır.';

  @override
  String get sdCrowdedChannelHowToFix1 =>
      'Yönlendirici yönetici sayfasını açın ve Wi-Fi kanalını manuel olarak değiştirin (Uygulamadaki Kanal Puanlaması en temiz kanalı önerir).';

  @override
  String get sdCrowdedChannelHowToFix2 =>
      '2.4 GHz\'de, 1 / 6 / 11 numaralı kanalları tercih edin — bunlar birbiriyle çakışmaz.';

  @override
  String get sdCrowdedChannelHowToFix3 =>
      'Yönlendiriciniz 5 GHz veya 6 GHz\'i destekliyorsa cihazı o banda taşıyın: Orada çok daha fazla temiz kanal mevcuttur.';

  @override
  String get sdCrowdedChannelHowToFix4 =>
      'Çift bantlı yönlendiriciler için her banda kendi SSID\'sini verin, böylece cihazlar kalabalık bir 2.4 GHz kanalına geri dönmeyi bırakır.';

  @override
  String sdCrowdedChannelEstimate(String gain) {
    return 'Tahmini kazanç: Daha sessiz bir kanala geçtikten sonra indirme hızında +$gain Mbps\'ye kadar artış.';
  }

  @override
  String get sdBufferbloatWhatIs =>
      'Bufferbloat, bağlantı tam yüklendiğinde yönlendiricinizin gönderim tamponlarında biriken gecikmedir — tipik paketler yığın trafiğin arkasında kuyruğa girmek zorunda kalır.';

  @override
  String get sdBufferbloatWhyItMatters =>
      'Bir dosya indirilirken indirme hızınız harika görünebilir, ancak sesli aramalar titrer, video konferanslar donar ve oyunlar gecikir — zamana duyarlı her şey kuyruğun arkasında bekletilir.';

  @override
  String get sdBufferbloatHowToFix1 =>
      'Yönlendirici yönetici sayfanızda QoS / SQM\'yi (bazen \"Akıllı Kuyruk Yönetimi\" veya \"Uyarlanabilir QoS\" olarak adlandırılır) etkinleştirin.';

  @override
  String get sdBufferbloatHowToFix2 =>
      'Yönlendirici yazılımını güncelleyin — modern yazılımlar varsayılan olarak daha iyi kuyruk disiplini ile gelir.';

  @override
  String get sdBufferbloatHowToFix3 =>
      'Yönlendirici çok eskiyse ve SQM özelliği yoksa, onu yeni bir modelle değiştirmek genellikle tek gerçek çözümdür.';

  @override
  String get sdBufferbloatHowToFix4 =>
      'Yönlendiricideki yükleme bant genişliğini gerçek paketinizin biraz altında (örneğin %90) sınırlayın, böylece kuyruk ISP\'de değil yönlendiricide oluşur.';

  @override
  String sdBufferbloatEstimate(String reduction) {
    return 'Tahmini kazanç: Yaklaşık −$reduction ms yüklü gecikme. Aramalar ve oyunlar büyük indirmeler sırasında bile akıcı hissettirecek.';
  }

  @override
  String get sdIspSlowWhatIs =>
      'Wi-Fi bağlantınız sağlıklı ve radyo, şu anda içinden akandan çok daha fazlasını taşıyabilir. Darboğaz yönlendiricinin üst akışındadır (servis sağlayıcı tarafında).';

  @override
  String get sdIspSlowWhyItMatters =>
      'Hiçbir yönlendirici veya Wi-Fi ayarı yardımcı olmayacaktır — ISP\'nizden yönlendiriciye gelen bağlantı tavan noktasıdır. Bunu bir Wi-Fi sorunu olarak değil, paket yükseltme veya destek çağrısı verisi olarak değerlendirin.';

  @override
  String get sdIspSlowHowToFix1 =>
      'Radyonun hatalı olmadığını doğrulamak için testi kablolu bir Ethernet kablosuyla yeniden çalıştırın.';

  @override
  String get sdIspSlowHowToFix2 =>
      'Ödediğiniz ISP paketini kontrol edin — test sonucu iyi bir günde paketinizin yaklaşık %80\'i ile eşleşmelidir.';

  @override
  String get sdIspSlowHowToFix3 =>
      'Günün farklı saatlerinde deneyin. Sadece akşamları yavaşsa, ISP segmenti yoğun olabilir.';

  @override
  String get sdIspSlowHowToFix4 =>
      'Sonuç sürekli olarak paketinizin çok altındaysa, hız testi çıktısıyla birlikte ISP ile iletişime geçin.';

  @override
  String sdIspSlowEstimate(String phy, String download) {
    return 'Wi-Fi\'ınız ~$phy Mbps\'ye kadar taşıyabilir; şu anda $download Mbps alıyorsunuz. Boşluk yönlendiricinin üst akışındadır.';
  }

  @override
  String get sdSlowDnsWhatIs =>
      'DNS, example.com gibi isimleri cihazınızın gerçekte bağlandığı IP adreslerine dönüştürür. Her sayfa yüklemesi, herhangi bir veri akışından önce bir avuç bu sorgulardan başlatır.';

  @override
  String get sdSlowDnsWhyItMatters =>
      'Yavaş DNS indirme hızınızı düşürmez — her bağlantının başında bir gecikme ekler. Hız testleri iyi görünse bile web \"yavaş\" hissettirir.';

  @override
  String get sdSlowDnsHowToFix1 =>
      'Cihazınızın veya yönlendiricinizin DNS\'ini hızlı bir genel çözücüye geçirin — 1.1.1.1 (Cloudflare), 8.8.8.8 (Google) veya 9.9.9.9 (Quad9).';

  @override
  String get sdSlowDnsHowToFix2 =>
      'Sorguları şifrelemek için işletim sisteminizde veya tarayıcınızda HTTPS üzerinden DNS (DoH) veya TLS üzerinden DNS (DoT) özelliğini etkinleştirin.';

  @override
  String get sdSlowDnsHowToFix3 =>
      'ISP\'nizin DNS\'i yavaşsa, çözücüyü yönlendirici üzerinde ayarlayın, böylece sadece bir cihaz değil tüm ev faydalansın.';

  @override
  String sdSlowDnsEstimate(int reduction) {
    return 'Tahmini kazanç: İsim sorgusu başına yaklaşık −$reduction ms. Her sayfa bir düzine sorgu başlattığı için sayfa yüklemeleri genellikle %5–20 daha hızlı hissettirir.';
  }

  @override
  String get sdHealthyWhatIs =>
      'Speed Doctor beş şeyi kontrol eder: sinyal gücü, kanal yoğunluğu, yük altında hız (bufferbloat), Wi-Fi kapasitesine karşı indirme hızı ve DNS çözümleme süresi.';

  @override
  String get sdHealthyWhyItMatters =>
      'Bu çalışma sırasında bunlardan hiçbiri bir uyarı eşiğini geçmedi. Bağlantınız şu anda iyi durumda — herhangi bir sorun fark etmeye başlarsanız bir şeylerin değişip değişmediğini görmek için testi yeniden çalıştırın.';

  @override
  String sdMetricRssi(int rssi) {
    return 'RSSI: $rssi dBm';
  }

  @override
  String sdThresholdRssi(int healthy, int severe) {
    return 'Sağlıklı ≥ $healthy dBm · Kritik ≤ $severe dBm';
  }

  @override
  String sdMetricChannel(int channel, String score) {
    return 'Kanal $channel · puan $score/10';
  }

  @override
  String sdThresholdChannel(String healthy, String severe) {
    return 'Sağlıklı ≥ $healthy · Kritik ≤ $severe';
  }

  @override
  String sdMetricBufferbloat(String induced, String latency, String loaded) {
    return 'Yüklü gecikme Δ: $induced ms ($latency → $loaded)';
  }

  @override
  String sdThresholdBufferbloat(String healthy, String severe) {
    return 'Sağlıklı ≤ $healthy ms · Kritik ≥ $severe ms';
  }

  @override
  String sdMetricIsp(String download, String phy) {
    return 'İndirme: $download Mbps · PHY: $phy Mbps';
  }

  @override
  String sdMetricIspNoPhy(String download) {
    return 'İndirme: $download Mbps';
  }

  @override
  String sdThresholdIsp(String healthy) {
    return 'Radyo yoğunluğu yokken sağlıklı ≥ $healthy Mbps';
  }

  @override
  String sdMetricDns(String name, int latency) {
    return 'En iyi çözücü: $name · $latency ms';
  }

  @override
  String sdThresholdDns(int healthy, int severe) {
    return 'Sağlıklı ≤ $healthy ms · Kritik ≥ $severe ms';
  }

  @override
  String get networkContextHomeLabel => 'Ev';

  @override
  String get networkContextPublicLabel => 'Halka Açık';

  @override
  String get networkContextGuestLabel => 'Misafir';

  @override
  String get networkContextUnknownLabel => 'Bilinmiyor';

  @override
  String get noChangeLabel => 'değişim yok';

  @override
  String get sinceLastScanLabel => 'son taramadan beri';

  @override
  String get allClearLabel => 'her şey yolunda';

  @override
  String get tapToTestLabel => 'test et';

  @override
  String get gameProfileLabel => 'Oyun profili';

  @override
  String get profileGeneric => 'Genel UDP Oyun';

  @override
  String get notificationChannelSecurityCritical => 'Kritik Uyarılar';

  @override
  String get notificationChannelSecurityHigh => 'Yüksek Öncelikli';

  @override
  String get notificationChannelSecurityMedium => 'Orta Öncelikli';

  @override
  String get notificationChannelSecurityWarning => 'Uyarılar';

  @override
  String get notificationChannelSecurityLow => 'Düşük Öncelikli';

  @override
  String get notificationChannelSecurityInfo => 'Bilgilendirme';

  @override
  String get notificationChannelSecurityDescription =>
      'Güvenlik uyarısı bildirimleri';

  @override
  String wifiChannelQualityDroppedBody(
    int channel,
    String rating,
    int recommendedChannel,
    String recommendedRating,
  ) {
    return 'Kanal $channel şu an $rating/10. Kanal $recommendedChannel $recommendedRating/10 seviyesinde — geçiş yapmayı düşünün.';
  }

  @override
  String get stabilizerJitterSpikeTitle => 'Jitter sıçraması tespit edildi';

  @override
  String get stabilizerFasterDnsTitle => 'Daha hızlı DNS mevcut';

  @override
  String get stabilizerPacketLossTitle => 'Sürekli paket kaybı';

  @override
  String stabilizerJitterSpikeBody(String threshold, int window) {
    return 'Jitter $window örnek için $threshold ms\'yi aştı. Tüneli yenilemek sorunlu yolu düzeltebilir.';
  }

  @override
  String stabilizerFasterDnsBody(String label) {
    return 'Daha hızlı bir DNS ($label) mevcut.';
  }

  @override
  String stabilizerPacketLossBody(String loss) {
    return 'Paket kaybı %$loss. Tüneli yenilemek veya daha güçlü bir ağa geçmek yardımcı olabilir.';
  }

  @override
  String get connCompareTitle => 'Bağlantı karşılaştırması';

  @override
  String get connCompareCellular => 'Mobil';

  @override
  String get connCompareNoWifi => 'Wi-Fi bağlı değil';

  @override
  String get connCompareNoCell => 'Mobil sinyal bilgisi yok';

  @override
  String get connCompareCellPermission =>
      'Mobil sinyali okumak için konum izni gerekli';

  @override
  String get connCompareWifiStronger => 'Şu an Wi-Fi daha güçlü görünüyor';

  @override
  String get connCompareCellStronger => 'Şu an mobil veri daha güçlü görünüyor';

  @override
  String get connCompareBothWeak => 'Her iki bağlantı da zayıf görünüyor';

  @override
  String get connCompareEven => 'Bağlantılar dengeli görünüyor';

  @override
  String get connCompareInUse => 'veri için kullanımda';

  @override
  String stabilizerNativeJitterBody(String jitter, String threshold) {
    return 'Jitter $jitter ms (eşik $threshold ms). Tüneli yenilemek kötü rotayı kırabilir.';
  }

  @override
  String get stabilizerDnsSwitchedTitle => 'DNS değiştirildi';

  @override
  String stabilizerDnsSwitchedBody(String dns, String delta) {
    return 'Artık $dns kullanılıyor — $delta ms daha hızlı yanıt verdi.';
  }

  @override
  String get stabilizerAlertChannelName => 'Stabilizer uyarıları';

  @override
  String get stabilizerAlertChannelDesc =>
      'Ping stabilizer\'dan jitter, paket kaybı ve DNS önerileri.';

  @override
  String get stabilizerHudChannelDesc =>
      'Cihaz üstü ping stabilizer tüneli etkinken görünen kalıcı bildirim.';

  @override
  String get stabilizerHudMeasuring => 'Ölçülüyor…';

  @override
  String stabilizerHudBody(String dns) {
    return 'DNS $dns · kontrol için düğmelere dokunun';
  }

  @override
  String get stabilizerActionCycle => 'Yenile';

  @override
  String get stabilizerActionStop => 'Durdur';

  @override
  String get batteryOptimizationTitle => 'Arka planda çalışmaya izin ver';

  @override
  String get batteryOptimizationBody =>
      'Uygulama kapalıyken uyarıların çalışmaya devam etmesi için Torcav\'ın pil optimizasyonundan muaf tutulması gerekiyor. Aksi halde Android bu cihazda izlemeyi susturabilir.';

  @override
  String get batteryOptimizationAction => 'İzin ver';

  @override
  String get batteryOptimizationLater => 'Şimdi değil';

  @override
  String get backgroundMonitoringNotifWarning =>
      'Bildirimler kapalı — arka plan izleme çalışacak ancak uyarılar görünmeyecek. Sistem ayarlarından bildirimleri açın.';

  @override
  String get monitorChannelName => 'Ağ nöbetçisi uyarıları';

  @override
  String get monitorChannelDesc =>
      'Periyodik arka plan Wi-Fi denetiminden gelen uyarılar.';

  @override
  String get monitorBssidChangedTitle => 'Bağlı erişim noktası değişti';

  @override
  String get monitorBssidChangedBody =>
      'Cihazınız farklı bir erişim noktasına geçti. Hâlâ sizin ağınız olduğunu doğrulamak için Torcav\'ı açın.';

  @override
  String get monitorEnvironmentChangedTitle => 'Wi-Fi ortamı değişti';

  @override
  String monitorEnvironmentChangedBody(String from, String to) {
    return 'Yakındaki ağ sayısı $from → $to oldu. İncelemek için Torcav\'ı açın.';
  }

  @override
  String get lanDiscoveryTitle => 'LAN Cihazları Tespit Edildi';

  @override
  String get lanDiscoveryRecommendation =>
      'Yerel ağınızdaki tüm cihazları tanıdığınızdan emin olun.';

  @override
  String get gatewayPortsExposedTitle => 'Ağ Geçidi Portları Açık';

  @override
  String get gatewayPortsExposedRecommendation =>
      'Ağ geçidi yönlendiricisindeki gereksiz servisleri devre dışı bırakın ve güçlü şifreler kullandığınızdan emin olun.';

  @override
  String get openServiceDetectedTitle => 'Açık Servis Tespit Edildi';

  @override
  String get openServiceDetectedRecommendation =>
      'Bu servisin erişilebilir olmasının amaçlandığından emin olun.';

  @override
  String lanDeviceDiscoveredTitle(String name) {
    return 'LAN Cihazı: $name';
  }

  @override
  String get lanDeviceDiscoveredRecommendation =>
      'Bu cihazın size ait olduğunu doğrulayın. Kötü niyetli cihazlar genellikle LAN içinde gizlenir.';

  @override
  String get rule_arp_spoofing_title => 'ARP Spoofing Tespit Edildi';

  @override
  String get rule_arp_spoofing_desc =>
      'Birden fazla MAC adresi aynı IP adresini sahipleniyor. Bir saldırgan trafiğinizi kesiyor olabilir.';

  @override
  String get rule_arp_spoofing_rec =>
      'Derhal farklı bir ağa geçin veya bir VPN kullanın.';

  @override
  String get rule_dns_hijacking_title => 'DNS Ele Geçirme Tespit Edildi';

  @override
  String get rule_dns_hijacking_desc =>
      'DNS sorgularınız beklenmedik bir sunucuya yönlendiriliyor. Bu, bir saldırganın hangi web sitelerini ziyaret ettiğinizi kontrol etmesine olanak tanır.';

  @override
  String get rule_dns_hijacking_rec =>
      'Derhal bir VPNe geçin. DNS sorgularınıza müdahale ediliyor.';

  @override
  String get rule_dns_check_unavailable_title => 'DNS Kontrolü Çalıştırılamadı';

  @override
  String get rule_dns_check_unavailable_desc =>
      'DNS bütünlük testi tamamlanamadı; bu ağ DNS ele geçirme açısından kontrol edilmedi. Bu, ağınızla ilgili bir bulgu değil — bakamadığımız anlamına geliyor.';

  @override
  String get rule_dns_check_unavailable_rec =>
      'Bağlantınız kararlı hale gelince taramayı yeniden çalıştırın.';

  @override
  String channelWithRating(int channel, String rating) {
    return 'KN $channel ($rating)';
  }

  @override
  String lanDiscoveryEvidence(String devices) {
    return 'Tespit edilen: $devices';
  }

  @override
  String gatewayPortsExposedEvidence(String ports) {
    return 'Açık Portlar: $ports';
  }

  @override
  String openServiceDetectedEvidence(String ip, int port, String service) {
    return 'Hedef: $ip, Port: $port, Servis: $service';
  }

  @override
  String lanDeviceDiscoveredEvidence(String ip, String mac, String vendor) {
    return 'IP: $ip, MAC: $mac, Satıcı: $vendor';
  }

  @override
  String evidenceNoEncryption(String network) {
    return 'Erişim noktası $network için şifreleme sunmuyor.';
  }

  @override
  String lanDiscoveryDesc(int count) {
    return 'Aktif tarama bu ağda $count cihaz belirledi.';
  }

  @override
  String gatewayPortsExposedDesc(String ip) {
    return 'Host $ip, savunmasız olabilecek açık portlara sahip.';
  }

  @override
  String openServiceDetectedDesc(String ip, String service, int port) {
    return 'Host $ip, $port portunda $service çalıştırıyor.';
  }

  @override
  String get genericErrorMessage => 'Bir hata oluştu.';

  @override
  String get networkErrorMessage => 'Ağ hatası — bağlantınızı kontrol edin.';

  @override
  String get permissionDeniedMessage => 'İzin reddedildi.';

  @override
  String get storageErrorMessage => 'Depolama hatası.';

  @override
  String get securityErrorMessage => 'Güvenlik kontrolü başarısız.';

  @override
  String get recommendedActionsTitle => 'ÖNERİLEN EYLEMLER';

  @override
  String get ptsLabel => 'PUAN';

  @override
  String get hardenRouterTaskTitle => 'Yönlendiriciyi Güçlendir';

  @override
  String get hardenRouterTaskDesc =>
      'Yönlendiricinizi yaygın güvenlik açıklarına karşı güvenceye alın.';

  @override
  String get enableWpa3TaskTitle => 'WPA3\'ü Etkinleştir';

  @override
  String get enableWpa3TaskDesc =>
      'Daha güçlü şifreleme için WPA3\'e yükseltin.';

  @override
  String get disableWpsTaskTitle => 'WPS\'i Devre Dışı Bırak';

  @override
  String get disableWpsTaskDesc =>
      'Kaba kuvvet PIN saldırılarını önlemek için WPS\'i devre dışı bırakın.';

  @override
  String get changeDefaultPasswordsTaskTitle => 'Varsayılan Şifreleri Değiştir';

  @override
  String get changeDefaultPasswordsTaskDesc =>
      'Varsayılan yönetici kimlik bilgilerini değiştirin.';

  @override
  String get runSpeedTestTaskTitle => 'Hız Testi Çalıştır';

  @override
  String get runSpeedTestTaskDesc =>
      'Ödediğiniz hızı alıp almadığınızı kontrol edin.';

  @override
  String get optimizeChannelTaskTitle => 'WiFi Kanalını Optimize Et';

  @override
  String get optimizeChannelTaskDesc =>
      'Daha az sıkışık bir WiFi kanalına geçiş yapın.';

  @override
  String get lanViewListLabel => 'Liste';

  @override
  String get lanViewMapLabel => 'Harita';

  @override
  String get speedHubTitle => 'HIZ';

  @override
  String get speedHubCompareSection =>
      'Ödediğin vs aldığın · Wi-Fi/Mobil karşılaştırma';

  @override
  String get speedModeQuickTest => 'Hızlı Test';

  @override
  String get speedModeDiagnose => 'Teşhis';

  @override
  String get opsGroupSecurity => 'GÜVENLİK';

  @override
  String get opsGroupSpeed => 'HIZ VE BAĞLANTI';

  @override
  String get opsGroupCoverage => 'KAPSAMA';

  @override
  String get opsGroupReports => 'RAPORLAR';

  @override
  String get opsSpeedSubtitle => 'Hız testi ve yavaş internet teşhisi';

  @override
  String get opsSecuritySubtitle => 'Tehditler, şifreleme ve derin denetim';

  @override
  String get opsHeatmapSubtitle => 'Kapsamı haritalayın, ölü bölgeleri bulun';

  @override
  String get opsReportsSubtitle => 'Ağ sağlık raporunu dışa aktarın';

  @override
  String get breachMonitorTitle => 'Sızıntı Monitörü';

  @override
  String get breachMonitorSubtitle => 'Bir parola sızmış mı kontrol et';

  @override
  String get breachInputLabel => 'Kontrol edilecek parola';

  @override
  String get breachCheckButton => 'Parolayı Kontrol Et';

  @override
  String get breachCheckingButton => 'Kontrol ediliyor...';

  @override
  String get breachResultSafeTitle => 'Bulunamadı';

  @override
  String get breachResultCompromisedTitle => 'Ele Geçirilmiş';

  @override
  String get breachResultSafe =>
      'Bu parola bilinen hiçbir veri sızıntısında bulunamadı. Bu, güçlü olduğunu garanti etmez — uzun ve benzersiz parolalar seçin.';

  @override
  String breachResultCompromised(int count) {
    final intl.NumberFormat countNumberFormat = intl
        .NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Bu parola, bilinen $countString sızıntı kaydında görünüyor. Her yerde kullanmayı bırakın ve hemen değiştirin.';
  }

  @override
  String get breachAdvice =>
      'Benzersiz bir parolayla değiştirin ve etkilenen hesaplarda iki adımlı doğrulamayı etkinleştirin.';

  @override
  String get breachError =>
      'Sızıntı kontrolü başarısız. Bağlantınızı kontrol edip tekrar deneyin.';

  @override
  String get breachPrivacyNote =>
      'Yalnızca 5 karakterlik hash öneki gönderilir. Parolanız bu cihazdan asla çıkmaz.';

  @override
  String get breachWhatTitle => 'Bu nedir?';

  @override
  String get breachWhatBody =>
      'Yıllar içinde sayısız web sitesi saldırıya uğradı; milyarlarca parola çalınarak internete sızdırıldı. Saldırganlar bu hazır listeleri kullanarak hesapları ele geçiriyor. Bu araç, kullandığın bir parolanın o sızıntı listelerinde olup olmadığını söyler. Listedeyse, o parola artık güvenli değildir ve değiştirilmelidir.';

  @override
  String get breachHowTitle => 'Nasıl çalışıyor?';

  @override
  String get breachStep1 =>
      'Girdiğin parola bu cihazda geri döndürülemez bir parmak izine (SHA-1 özeti) çevrilir.';

  @override
  String get breachStep2 =>
      'Bu parmak izinin yalnızca ilk 5 karakteri \'Have I Been Pwned\' servisine gönderilir. Servis, o 5 karakterle başlayan binlerce olası parmak izini geri yollar.';

  @override
  String get breachStep3 =>
      'Hangi parmak izinin senin parolana ait olduğu tamamen bu cihazda karşılaştırılır. Servis, hangi parolayı sorduğunu asla öğrenemez.';

  @override
  String get breachSafetyTitle => 'Parolanı neden güvenle girebilirsin';

  @override
  String get breachSafety1 =>
      'Parolanın kendisi cihazından asla çıkmaz — internete yalnızca 5 karakterlik bir parmak izi öneki gider.';

  @override
  String get breachSafety2 =>
      'Bu 5 karakterlik önek binlerce farklı parolayla ortaktır; ne kimliğini ne de parolanı ele verir (k-anonimlik).';

  @override
  String get breachSafety3 =>
      'Parola hiçbir yere kaydedilmez, kayıt altına alınmaz ve kontrol biter bitmez ekrandan silinir.';

  @override
  String get breachTransparencyLabel => 'İnternete gönderilen tek şey';

  @override
  String get breachTransparencyEmpty =>
      'Bir parola yaz; gönderilecek 5 karakter burada canlı olarak görünecek.';

  @override
  String get breachTransparencyHint =>
      'Bu 5 karakter, parolanın parmak izinin yalnızca başlangıcıdır — parola bunlardan geri elde edilemez.';

  @override
  String get dnsInfoDohTitle => 'DNS over HTTPS (DoH)';

  @override
  String get dnsInfoDohDesc =>
      'DoH, hangi siteleri ziyaret ettiğini belirleyen DNS sorgularını sıradan HTTPS web trafiğinin içine gizleyerek şifreler. Böylece internet sağlayıcın ya da ağdaki bir saldırgan sorgularını göremez veya seni sahte bir siteye yönlendiremez. \'Erişilebilir\' yazıyorsa bu ağ DoH\'a izin veriyor demektir.';

  @override
  String get dnsInfoDotTitle => 'DNS over TLS (DoT)';

  @override
  String get dnsInfoDotDesc =>
      'DoT da DNS sorgularını şifreler, ancak bunu 853 portu üzerinden ayrı bir şifreli kanaldan yapar. Amaç aynıdır: DNS sorgularının gizliliği. Bazı ağlar 853 portunu engeller — o zaman \'Engelli\' görürsün ve cihazın şifresiz DNS\'e geri düşebilir.';

  @override
  String get dashAdvancedMetrics => 'GELİŞMİŞ METRİKLER';

  @override
  String get dashHeroOtherIssues => 'Diğer tespitler';

  @override
  String get dashSignalLabel => 'Sinyal';

  @override
  String get dashSsidHidden => 'Ağ adı gizli';

  @override
  String get dashGrantLocationHint => 'Ağ adını görmek için konum iznine dokun';

  @override
  String get dashConnDetailTitle => 'BAĞLANTI DETAYI';

  @override
  String get dashConnDetailCopyHint => 'Kopyalamak için bir değere dokun';

  @override
  String dashValueCopied(String label) {
    return '$label kopyalandı';
  }

  @override
  String get dashHeroTopAction => 'Şimdi yapılacak en iyi hamle';

  @override
  String get dashHeroSeeFullDiagnosis => 'Tam tanıyı gör';

  @override
  String get dashHeroDisconnectedHint =>
      'Wi-Fi\'a bağlandığında ağını analiz edip durumu sana özetlerim.';

  @override
  String get planSpeedTitle => 'Ödediğin vs aldığın';

  @override
  String get planSpeedEnterCta => 'Taahhüt hızını gir';

  @override
  String get planSpeedSheetHint =>
      'İnternet paketinin taahhüt ettiği indirme hızı (Mbps). Sözleşmende veya faturanda yazar.';

  @override
  String get planSpeedPlanLabel => 'Taahhüt';

  @override
  String get planSpeedMeasuredLabel => 'Ortalama';

  @override
  String get planSpeedNoData =>
      'Henüz ölçüm yok — aşağıdan bir hız testi çalıştır.';

  @override
  String planSpeedSamples(int count) {
    return '$count testin ortalaması';
  }

  @override
  String planSpeedPercentOfPlan(int percent) {
    return 'taahhüdünün %$percent\'i';
  }

  @override
  String get planSpeedVerdictDelivering => 'Ödediğinin karşılığını alıyorsun.';

  @override
  String get planSpeedVerdictAcceptable =>
      'Taahhüdünün biraz altında — takipte kal.';

  @override
  String get planSpeedVerdictUnder => 'Ödediğinin çok altında.';

  @override
  String get planSpeedReportCta => 'ISS raporu hazırla';

  @override
  String get ispEvidenceTitle => 'TORCAV — İNTERNET HIZI KANIT RAPORU';

  @override
  String get ispEvidenceGeneratedAt => 'Oluşturulma';

  @override
  String get ispEvidenceBest => 'En iyi ölçüm';

  @override
  String get ispEvidenceSamples => 'Ölçümler';

  @override
  String get ispEvidenceDisclaimer =>
      'Not: Ölçümler Torcav uygulamasıyla Wi-Fi üzerinden alınmıştır. Tekil sonuçlar günün saatine ve ev içi koşullara göre değişir; anlamlı olan çok sayıda testin ortalamasıdır.';

  @override
  String get scheduledSpeedTestLabel => 'Zamanlanmış hız ölçümleri';

  @override
  String get scheduledSpeedTestDesc =>
      'Günde yaklaşık iki kez, yalnızca Wi-Fi\'da indirme hızını ölçer — mobil veride asla çalışmaz (her ölçüm 10 MB). Ödediğin-aldığın trendini kendiliğinden oluşturur.';

  @override
  String get reviewLanDevicesTaskTitle => 'Ağındaki cihazları gözden geçir';

  @override
  String get reviewLanDevicesTaskDesc =>
      'LAN listesini aç; her cihazı ve dışa açık her servisi tanıdığından emin ol.';

  @override
  String get reviewTrustedNetworkTaskTitle =>
      'Bu güvenilir ağı yeniden kontrol et';

  @override
  String get reviewTrustedNetworkTaskDesc =>
      'Güvendiğinden bu yana parmak izi değişti. Hâlâ sandığın ağ olduğunu doğrula.';

  @override
  String get leaveNetworkTaskTitle => 'Bu ağdan ayrıl';

  @override
  String get leaveNetworkTaskDesc =>
      'Buradaki trafik dinleniyor olabilir. Bunu düzelten bir modem ayarı yok — bağlantıyı kes, mobil veriyi veya güvendiğin bir ağı kullan.';

  @override
  String a11yHealthScore(int score) {
    return 'Ağ sağlığı 100 üzerinden $score. Ayrıntı için çift dokunun.';
  }

  @override
  String a11ySignalQuality(int percent) {
    return 'Sinyal kalitesi yüzde $percent. Kanal görünümü için çift dokunun.';
  }

  @override
  String get a11ySignalQualityUnknown =>
      'Sinyal kalitesi bilinmiyor. Kanal görünümü için çift dokunun.';

  @override
  String a11yThreatCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count etkin güvenlik uyarısı',
      one: '1 etkin güvenlik uyarısı',
      zero: 'Etkin güvenlik uyarısı yok',
    );
    return '$_temp0. İncelemek için çift dokunun.';
  }

  @override
  String a11yDeviceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ağda $count cihaz',
      one: 'Ağda 1 cihaz',
      zero: 'Cihaz bulunamadı',
    );
    return '$_temp0. Listeyi görmek için çift dokunun.';
  }

  @override
  String a11yNetworkStatus(String status, String ssid) {
    return 'Ağ durumu: $status, $ssid. Tam değerlendirme için çift dokunun.';
  }

  @override
  String get openMenuTooltip => 'Menüyü aç';

  @override
  String get closeTooltip => 'Kapat';

  @override
  String get showPasswordTooltip => 'Parolayı göster';

  @override
  String get hidePasswordTooltip => 'Parolayı gizle';

  @override
  String get placementTitle => 'Modemini nereye koymalısın';

  @override
  String get placementNoSurvey =>
      'Anket açıkken evin içinde dolaş ki modemini nereye koyacağını söyleyebilelim.';

  @override
  String get placementGoodCoverage =>
      'Kapsama iyi görünüyor — dolaştığın alanın %5\'inden azında sinyal zayıftı.';

  @override
  String get placementGoodCoverageDetail =>
      'Modemi taşımana gerek yok. Modemin yerini değiştirirsen ya da yeni duvar veya mobilya eklersen anketi tekrarla.';

  @override
  String get placementRelocate =>
      'Zayıf noktalar bir arada toplanmış — modemi o bölgeye doğru taşımayı dene.';

  @override
  String get placementRelocateDetail =>
      'Modemin şu anki yeri ile ölü bölgenin merkezi arasında kabaca yarı yolu hedefle; büyük metal eşyalardan (televizyon, mikrodalga, buzdolabı) uzak dur.';

  @override
  String get placementAddMesh =>
      'Zayıf noktalar birden fazla odaya yayılmış; modemi taşımak tek başına çözmez.';

  @override
  String get placementAddMeshDetail =>
      'Ölü bölgenin merkezine yakın, mevcut modemi görecek bir yere mesh ünitesi ekle. Dağınık zayıf bölgeleri iki erişim noktası, yer değiştirmenin çözemeyeceği biçimde çözer.';

  @override
  String placementDeadZoneCount(int dead, int total) {
    return '$total ölçüm noktasının $dead tanesi zayıftı';
  }

  @override
  String get healthReportTitle => 'Ev ağı sağlığı';

  @override
  String get healthDialWifi => 'Wi-Fi';

  @override
  String get healthDialSecurity => 'Güvenlik';

  @override
  String get healthDialInternet => 'İnternet';

  @override
  String get healthDialLan => 'LAN maruziyeti';

  @override
  String get healthHeadlineGreat => 'Ev ağın iyi durumda.';

  @override
  String healthHeadlineFocus(String dial) {
    return 'Odaklanman gereken alan: $dial.';
  }

  @override
  String healthHeadlineAttention(String dial) {
    return '$dial dikkat istiyor — aşağıdaki adımlara bak.';
  }

  @override
  String get healthActionMonthlyRecheck =>
      'Bu raporu ayda bir tekrarla ki bir şey bozulursa fark edesin.';

  @override
  String get healthActionWifi =>
      'Modemi daha yükseğe ve büyük metal eşyalardan uzağa taşı, ya da sinyalin düştüğü yere mesh ünitesi ekle.';

  @override
  String get healthActionSecurity =>
      'Güvenlik merkezini aç ve işaretlenen bulguları çöz — modem sıkılaştırma sihirbazı yaygın olanları adım adım anlatıyor.';

  @override
  String get healthActionInternet =>
      'Kök neden dökümü için Speed Doctor\'ı çalıştır: bufferbloat, kalabalık kanal veya ISS paket sınırı.';

  @override
  String healthActionLanRisky(String ip, String vendor) {
    return '$ip adresindeki cihaz ($vendor) riskli olarak işaretlendi. Nedenini görmek için ağ taramasında kartını aç.';
  }

  @override
  String get healthActionLanCaution =>
      'Birkaç cihazda küçük maruziyet var. Neyin açık olduğunu görmek için ağ taramasındaki her DİKKAT rozetine dokun.';

  @override
  String get healthActionShare =>
      'Bu raporu ağı kim yönetiyorsa onunla paylaş ki aynı tablo kayıtta olsun.';

  @override
  String get healthReportShare => 'Sağlık raporunu paylaş';

  @override
  String get healthReportEmpty =>
      'Önce bir Wi-Fi taraması yap — sağlık raporu diğer araçların ölçtüklerinden üretiliyor.';
}
