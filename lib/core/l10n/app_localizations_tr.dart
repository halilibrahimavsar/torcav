// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get wifiScanTitle => 'WIFI TARAMA';

  @override
  String get searchingNetworksPlaceholder => 'AĞLAR ARANIYOR...';

  @override
  String get filterNetworksPlaceholder => 'AĞLARI FİLTRELE...';

  @override
  String get quickScan => 'Hızlı Tarama';

  @override
  String get deepScan => 'Derin Tarama';

  @override
  String get deepScanExperimentalTitle => 'Deep Scan (Experimental)';

  @override
  String get deepScanExperimentalSubtitle => 'Actively probe LAN for devices and ports. Increased battery usage.';

  @override
  String get scanModesTitle => 'Tarama Modları';

  @override
  String get scanModesInfo => 'Hızlı tarama yayınları dinler. Derin tarama aktif olarak ağları sorgular.';

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
  String get operationsLabel => 'OPERASYONLAR';

  @override
  String get topologyLabel => 'TOPOLOJİ';

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
  String get accessEngine => 'ERİŞİM MOTORU';

  @override
  String get latestSnapshotTitle => 'Son Ağ Görünümü';

  @override
  String get noSnapshotAvailable => 'Görünüm verisi yok...';

  @override
  String get strictSafetyEnabled => 'Sıkı güvenlik protokolleri etkin';

  @override
  String get activeMonitoringProgress => 'Aktif izleme devam ediyor...';

  @override
  String get scanComparisonTitle => 'TARAMA KARŞILAŞTIRMA';

  @override
  String get comparisonNeedsTwoScans => 'Karşılaştırma için en az 2 tarama gereklidir.\n\nDeğişiklikleri görmek için başka bir tarama yapın.';

  @override
  String get noChangesDetected => 'Son iki tarama arasında değişiklik tespit edilmedi.';

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
  String get plusNewLabel => '+ YENİ';

  @override
  String get goneLabel => 'GİDEN';

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
  String get broadcastingProbeRequests => 'PROBE İSTEKLERİ YAYINLANIYOR...';

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
  String get savePdfReportDialog => 'Save PDF Report';

  @override
  String get scanning => 'Taranıyor...';

  @override
  String get shieldActive => 'Kalkan Aktif';

  @override
  String get threatsDetected => 'TEHDİT TESPİT EDİLDİ';

  @override
  String get trustedLabel => 'GÜVENİLİR';

  @override
  String get securityEventTitle => 'Güvenlik Olayı';

  @override
  String get networkReconTitle => 'AĞ KEŞFİ';

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
  String get targetIpSubnet => 'Hedef IP / Alt Ağ';

  @override
  String get scanProfileFast => 'Hızlı';

  @override
  String get scanProfileBalanced => 'Balanced';

  @override
  String get scanProfileAggressive => 'Aggressive';

  @override
  String get scanProfileNormal => 'Normal';

  @override
  String get scanProfileIntense => 'Yoğun';

  @override
  String get vulnOnlyLabel => 'Sadece Zafiyetler';

  @override
  String get lanReconTitle => 'LAN TARAMASI';

  @override
  String get targetSubnet => 'Hedef IP / Alt Ağ';

  @override
  String get scanAllCaps => 'TARA';

  @override
  String get channelRatingTitle => 'KANAL PUANLAMASI';

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
  String get historyLabel => 'GEÇMİŞ';

  @override
  String failedLoadTopology(String error) {
    return 'Topoloji yüklenemedi: $error';
  }

  @override
  String get trafficLabel => 'TRAFİK';

  @override
  String get forceLabel => 'GÜÇ';

  @override
  String get normalSpeed => 'NORMAL';

  @override
  String get fastSpeed => 'HIZLI';

  @override
  String get overdriveSpeed => 'MAKSİMUM';

  @override
  String get topologyMapTitle => 'TOPOLOJİ HARİTASI';

  @override
  String get noTopologyData => 'Topoloji Verisi Yok';

  @override
  String get runScanFirst => 'Ağ haritasını oluşturmak için önce bir tarama yapın';

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
  String get topologyGuideTitle => 'TOPOLOGY GUIDE';

  @override
  String get topologyGuideDesc => 'Understand your network structure and device connectivity.';

  @override
  String get gatewayTitle => 'The Gateway';

  @override
  String get gatewayDesc => 'The central brain of your network. All external traffic flows through this node.';

  @override
  String get deviceLayersTitle => 'Device Layers';

  @override
  String get deviceLayersDesc => 'Devices are categorized by their role: Core (Routers/APs), Mobile, and IoT/Peripheral.';

  @override
  String get pathwaysTitle => 'Pathways';

  @override
  String get pathwaysDesc => 'Modern networks mix wired (Ethernet) and wireless (Wi-Fi) connections. Solid lines indicate high-speed wired links, while dashed lines show wireless segments.';

  @override
  String get pingAction => 'TEST LATENCY';

  @override
  String pingSuccess(int ms) {
    return 'Latency: ${ms}ms';
  }

  @override
  String get pingFailure => 'Host Unreachable';

  @override
  String get settingsTitle => 'AYARLAR';

  @override
  String get appearance => 'Görünüm';

  @override
  String get settingsLanguage => 'Dil';

  @override
  String get theme => 'Tema';

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
  String get backendLabel => 'BACKEND';

  @override
  String get defenseTitle => 'SAVUNMA';

  @override
  String get shieldLabReady => 'Ready for Assessment';

  @override
  String get deepScanRunning => 'Scan in progress...';

  @override
  String get knownNetworks => 'Bilinen Ağlar';

  @override
  String get noKnownNetworksYet => 'Henüz bilinen ağ yok';

  @override
  String get noIdentifiedNetworks => 'No identified networks in laboratory archives';

  @override
  String get knownNetworksDashboard => 'KNOWN NETWORKS ARCHIVE';

  @override
  String get securityTimeline => 'Güvenlik Zaman Çizelgesi';

  @override
  String get noSecurityEvents => 'Kayıtlı güvenlik olayı yok';

  @override
  String get dnsSecurityTitle => 'DNS INTEGRITY';

  @override
  String get dnsSecurityBody => 'Verify that your DNS queries are not being hijacked or spoofed.';

  @override
  String get dnsIntegrity => 'DNS INTEGRITY';

  @override
  String get runTest => 'RUN TEST';

  @override
  String get integrityCheck => 'INTEGRITY CHECK';

  @override
  String get authLocalSystem => 'YEREL_SİSTEM';

  @override
  String remoteNodeIdLabel(String id) {
    return 'UZAK_DÜĞÜM_İD: $id';
  }

  @override
  String get ipAddrLabel => 'IP_ADRESİ';

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
  String get securityScoreDesc => 'Güvenlik puanı (0-100) bu ağın ne kadar iyi korunduğunu gösterir. Yüksek puan daha iyidir. Şifreleme türü, WPS durumu ve diğer güvenlik özellikleri dikkate alınır.';

  @override
  String get networkSecurity => 'Network Security';

  @override
  String get portScanAction => 'PORT SCAN';

  @override
  String get hostnameLookupAction => 'LOOKUP HOSTNAME';

  @override
  String get arpInfoAction => 'ARP INFO';

  @override
  String get portsFoundLabel => 'OPEN PORTS';

  @override
  String get noPortsFound => 'No open ports found';

  @override
  String get hostnameLabel => 'HOSTNAME';

  @override
  String get arpInfoLabel => 'ARP DATA';

  @override
  String get scanningPortsTitle => 'SCANNING PORTS...';

  @override
  String get lookingUpHostnameTitle => 'LOOKING UP HOSTNAME...';

  @override
  String get fetchingArpTitle => 'FETCHING ARP DATA...';

  @override
  String get portRangeHint => 'Port range (e.g. 80,443 or 1-1000)';

  @override
  String get capabilitiesLabel => 'ÖZELLİKLER';

  @override
  String get wifi7MldLabel => 'Wi-Fi 7 MLD';

  @override
  String get tagWpa3Desc => 'WPA3 en yeni Wi-Fi güvenlik standardıdır — yüksek düzeyde güvenlidir.';

  @override
  String get tagWpa2Desc => 'WPA2 güçlü bir güvenlik standardıdır — günlük kullanım için güvenlidir.';

  @override
  String get tagWpaDesc => 'WPA, bilinen zayıflıkları olan eski bir güvenlik standardıdır.';

  @override
  String get tagWpsDesc => 'WPS (Wi-Fi Korumalı Kurulum) bilinen güvenlik açıklarına sahiptir. Saldırganların PIN\'i kaba kuvvetle ele geçirmesine ve erişim kazanmasına izin verebilir.';

  @override
  String get tagPmfDesc => 'Korumalı Yönetim Çerçeveleri (PMF/MFP), kimlik doğrulama saldırılarına karşı koruma sağlar.';

  @override
  String get tagEssDesc => 'ESS (Genişletilmiş Servis Seti), bunun standart bir erişim noktası ağı olduğu anlamına gelir.';

  @override
  String get tagCcmpDesc => 'CCMP (AES), WPA2/WPA3 ile kullanılan güçlü bir şifreleme yöntemidir.';

  @override
  String get tagTkipDesc => 'TKIP, eski ve daha zayıf bir şifreleme yöntemidir. CCMP/AES tercih edilir.';

  @override
  String get tagUnknownDesc => 'Beacon karelerinden gelen ağ özelliği bayrağı.';

  @override
  String get scanProfileLabel => 'TARAMA PROFİLİ';

  @override
  String get infoScanProfilesTitle => 'Tarama Profilleri';

  @override
  String get infoScanProfileFastDesc => 'Hızlı: Çabuk ping taraması — cihazları saniyeler içinde bulur.';

  @override
  String get infoScanProfileBalancedDesc => 'Dengeli: Ping + ortak portlar — daha fazla detay bulur.';

  @override
  String get infoScanProfileAggressiveDesc => 'Agresif: Tam port taraması — en kapsamlı ama en yavaş.';

  @override
  String get activeNodeRecon => 'AKTİF DÜĞÜM KEŞFİ';

  @override
  String get interrogatingSubnet => 'Alt ağ, yanıt veren ana bilgisayarlar için sorgulanıyor...';

  @override
  String get nodesLabel => 'Düğümler';

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
  String get anonymousNode => 'ANONİM DÜĞÜM';

  @override
  String portsCountLabel(int count) {
    return '$count PORT';
  }

  @override
  String get riskLabel => 'RİSK';

  @override
  String get searchLanPlaceholder => 'IP, ana bilgisayar adı veya satıcıya göre ara...';

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
  String get securitySummarySecure => 'Bağlantınız iyi görünüyor! Bu ağ güçlü şifreleme kullanıyor ve yaygın saldırılara karşı iyi korunuyor.';

  @override
  String get securitySummaryModerate => 'Bu ağın makul bir güvenliği var ancak bazı potansiyel zayıf noktaları bulunuyor. Günlük kullanım için güvenlidir, ancak hassas işlemlerden kaçının.';

  @override
  String get securitySummaryAtRisk => 'Bu ağda verilerinizi riske atan güvenlik sorunları var. Bağlıyken şifre veya kişisel bilgilerinizi girmekten kaçının.';

  @override
  String get securitySummaryCritical => 'Uyarı: Bu ağ güvenli değil. Yakındaki herkes internet trafiğinizi görebilir. Bir VPN kullanın veya ağ değiştirin.';

  @override
  String get vulnerabilityOpenNetworkTitle => 'Açık Ağ';

  @override
  String get vulnerabilityOpenNetworkDesc => 'Şifreleme tespit edilmedi. Tüm trafik düz metin olarak dinlenebilir.';

  @override
  String get vulnerabilityOpenNetworkRec => 'Hassas aktivitelerden kaçının. Güvenilir bir VPN veya farklı bir ağ tercih edin.';

  @override
  String get vulnerabilityWepTitle => 'WEP Şifreleme';

  @override
  String get vulnerabilityWepDesc => 'WEP kullanımdan kaldırılmıştır ve hızla kırılabilir.';

  @override
  String get vulnerabilityWepRec => 'Erişim noktasını derhal WPA2 veya WPA3 olarak yeniden yapılandırın.';

  @override
  String get vulnerabilityLegacyWpaTitle => 'Eski WPA';

  @override
  String get vulnerabilityLegacyWpaDesc => 'WPA/TKIP daha eskidir ve modern saldırı tekniklerine karşı zayıftır.';

  @override
  String get vulnerabilityLegacyWpaRec => 'Erişim noktasını ve istemcileri WPA2/WPA3\'e yükseltin.';

  @override
  String get vulnerabilityHiddenSsidTitle => 'Gizli SSID';

  @override
  String get vulnerabilityHiddenSsidDesc => 'Gizli SSID\'ler hala keşfedilebilir ve uyumluluğa zarar verebilir.';

  @override
  String get vulnerabilityHiddenSsidRec => 'Tek başına gizli SSID koruma sağlamaz. Güçlü şifrelemeye odaklanın.';

  @override
  String get vulnerabilityWeakSignalTitle => 'Çok Zayıf Sinyal';

  @override
  String get vulnerabilityWeakSignalDesc => 'Zayıf sinyal, kararsız bağlantıları ve yanıltma olasılığını gösterebilir.';

  @override
  String get vulnerabilityWeakSignalRec => 'Erişim noktasına yaklaşın veya BSSID tutarlılığını doğrulayın.';

  @override
  String get vulnerabilityWpsTitle => 'WPS Etkin';

  @override
  String get vulnerabilityWpsDesc => 'Wi-Fi Korumalı Kurulum (WPS) etkin. WPS PIN modu, Pixie Dust saldırısı kullanılarak saatler içinde kaba kuvvetle kırılabilir ve şifreyi etkisiz hale getirebilir.';

  @override
  String get vulnerabilityWpsRec => 'Yönlendirici yönetici panelinden WPS\'yi devre dışı bırakın. Sadece WPA2/WPA3 parolası kullanın.';

  @override
  String get vulnerabilityPmfTitle => 'Yönetim Çerçeveleri Korunmuyor';

  @override
  String get vulnerabilityPmfDesc => 'Bu erişim noktası Korumalı Yönetim Çerçevelerini (PMF / 802.11w) zorunlu tutmuyor. Korunmayan yönetim çerçeveleri, bir saldırganın kimlik doğrulama paketleri oluşturmasına ve istemcilerin bağlantısını kesmesine olanak tanır.';

  @override
  String get vulnerabilityPmfRec => 'Yönlendirici ayarlarında PMF\'yi (genellikle \'802.11w\' veya \'Yönetim Çerçevesi Koruması\' olarak adlandırılır) etkinleştirin. WPA3 varsayılan olarak PMF gerektirir.';

  @override
  String get vulnerabilityEvilTwinTitle => 'Potansiyel Kötü İkiz (Evil Twin)';

  @override
  String get vulnerabilityEvilTwinDesc => 'SSID yakında çelişkili güvenlik/kanal parmak iziyle görünüyor.';

  @override
  String get vulnerabilityEvilTwinRec => 'Kimlik doğrulama veya veri alışverişinden önce BSSID ve sertifikayı doğrulayın.';

  @override
  String get riskFactorNoEncryption => 'Şifreleme kullanılmıyor';

  @override
  String get riskFactorDeprecatedEncryption => 'Kullanımdan kaldırılmış şifreleme (WEP)';

  @override
  String get riskFactorLegacyWpa => 'Eski WPA kullanımda';

  @override
  String get riskFactorHiddenSsid => 'Gizli SSID davranışı';

  @override
  String get riskFactorWeakSignal => 'Zayıf sinyal ortamı';

  @override
  String get riskFactorWpsEnabled => 'WPS PIN saldırı yüzeyi açık';

  @override
  String get riskFactorPmfNotEnforced => 'PMF zorunlu değil — deauth yanıltması mümkün';

  @override
  String get refresh => 'Yenile';

  @override
  String get addZonePoint => 'Bölge Noktası Ekle';

  @override
  String get cancel => 'İptal';

  @override
  String get save => 'Kaydet';

  @override
  String get waitingForData => 'Veri bekleniyor...';

  @override
  String get temporalHeatmap => 'Zamansal Isı Haritası';

  @override
  String get failedToSaveHeatmapPoint => 'Isı haritası noktası kaydedilemedi';

  @override
  String signalMonitoringTitle(String ssid) {
    return 'SİNYAL İZLEME: $ssid';
  }

  @override
  String get heatmapTooltip => 'Isı Haritası';

  @override
  String get tagCurrentPointTooltip => 'Mevcut noktayı etiketle';

  @override
  String get signalCaps => 'SİNYAL';

  @override
  String get channelCaps => 'KANAL';

  @override
  String get frequencyCaps => 'FREKANS';

  @override
  String heatmapPointAdded(String zone) {
    return '$zone için ısı haritası noktası eklendi';
  }

  @override
  String get zoneTagLabel => 'Bölge etiketi (örn. Mutfak)';

  @override
  String errorPrefix(String message) {
    return 'Hata: $message';
  }

  @override
  String noHeatmapPointsYet(String bssid) {
    return '$bssid için henüz ısı haritası noktası yok';
  }

  @override
  String get averageSignalByZone => 'Bölgeye göre ortalama sinyal';

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
  String get riskFactorFingerprintDrift => 'SSID parmak izi kayması tespit edildi';

  @override
  String get historyCaps => 'GEÇMİŞ';

  @override
  String get consistentlyBestChannel => 'SÜREKLİ EN İYİ KANAL';

  @override
  String get avgScore => 'Ort. Skor';

  @override
  String get channelBondingTitle => 'Kanal Birleştirme';

  @override
  String get channelBondingDesc => 'Kanal birleştirme, bant genişliğini artırmak için 2 veya daha fazla bitişik kanalı birleştirir (40 MHz = 2×, 80 MHz = 4×, 160 MHz = 8×). Daha geniş kanallar daha yüksek hızlar sağlar ancak daha fazla komşu ağla çakışabilir.';

  @override
  String get spectrumOptimizationCaps => 'SPEKTRUM OPTİMİZASYONU';

  @override
  String get spectrumOptimizationDesc => 'Kanal yoğunluğunu ve paraziti analiz et';

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
  String get noHistoryPlaceholder => 'Henüz geçmiş yok.\nKanal derecelendirmeleri bu ekranı her açtığınızda kaydedilir.';

  @override
  String get currentSessionInfo => 'Mevcut oturum — yüksek puan = daha az yoğun.';

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
  String get speedTestHeader => 'HIZ TESTİ';

  @override
  String get startTest => 'TESTİ BAŞLAT';

  @override
  String get testAgain => 'TEKRAR TEST ET';

  @override
  String get commandCenters => 'KOMUTA MERKEZLERİ';

  @override
  String get activeShielding => 'Aktif Kalkan';

  @override
  String get logisticsTitle => 'LOJİSTİK';

  @override
  String get intelMetrics => 'İstihbarat Metrikleri';

  @override
  String get networkMesh => 'Ağ Örgüsü';

  @override
  String get tuningTitle => 'AYARLAMA';

  @override
  String get systemConfig => 'Sistem Yapılandırması';

  @override
  String get phasePing => 'AŞAMA: PING';

  @override
  String get phaseDownload => 'AŞAMA: İNDİRME';

  @override
  String get phaseUpload => 'AŞAMA: YÜKLEME';

  @override
  String get phaseDone => 'AŞAMA: TAMAMLANDI';

  @override
  String get riskScore => 'Risk Puanı';

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
  String get channelInterferenceDescription => 'Wi-Fi kanalları radyo istasyonları gibidir. Birçok ağ aynı kanalı paylaştığında birbirlerini yavaşlatırlar - herkesin aynı anda konuşması gibi. Daha az kalabalık bir kanala geçmek hızınızı ve güvenilirliğinizi artırabilir.';

  @override
  String securityEventType(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'rogueApSuspected': 'Sahte AP Şüphesi',
        'deauthBurstDetected': 'Ağdan Atma Saldırısı Serisi',
        'handshakeCaptureStarted': 'El Sıkışma Yakalama Başladı',
        'handshakeCaptureCompleted': 'El Sıkışma Yakalandı',
        'captivePortalDetected': 'Tutsak Portalı Algılandı',
        'evilTwinDetected': 'Kötü İkiz Algılandı',
        'deauthAttackSuspected': 'Ağdan Atma Saldırısı Şüphesi',
        'encryptionDowngraded': 'Şifreleme Düşürüldü',
        'unsupportedOperation': 'Desteklenmeyen İşlem',
        'other': '$type',
      },
    );
    return '$_temp0';
  }

  @override
  String securityEventSeverity(String severity) {
    String _temp0 = intl.Intl.selectLogic(
      severity,
      {
        'low': 'Düşük',
        'medium': 'Orta',
        'info': 'Bilgi',
        'warning': 'Uyarı',
        'high': 'Yüksek',
        'critical': 'Kritik',
        'other': '$severity',
      },
    );
    return '$_temp0';
  }

  @override
  String evilTwinEvidence(String expected, String found) {
    return 'BSSID uyuşmazlığı! Beklenen: $expected, Bulunan: $found. Yüksek Evil Twin (Kötü İkiz) Erişim Noktası olasılığı.';
  }

  @override
  String get rogueApEvidence => 'Bilinen ağda Rastgele/LAA MAC algılandı! Bu meşru Erişim Noktaları için oldukça olağandışıdır ve sahte bir cihaza işaret edebilir.';

  @override
  String downgradeEvidence(String oldSec, String newSec) {
    return 'Şifreleme profili $oldSec değerinden $newSec değerine değişti. Olası düşürme (downgrade) saldırısı.';
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
  String get dnsSecurityTest => 'DNS SECURITY TEST';

  @override
  String get dnsSecure => 'SECURE';

  @override
  String get dnsWarning => 'WARNING';

  @override
  String get dnsLeakDetected => 'LEAK DETECTED';

  @override
  String get dnsHijacked => 'HIJACKED';

  @override
  String get dnsVerifyIntegrity => 'Run a scan to verify DNS integrity';

  @override
  String dnsLastCheck(String hour, String minute) {
    return 'Last check: $hour:$minute';
  }

  @override
  String get dnsTestNow => 'TEST NOW';

  @override
  String get dnsTesting => 'TESTING...';

  @override
  String get dnsCurrentDns => 'CURRENT DNS';

  @override
  String get dnsIspProvider => 'ISP PROVIDER';

  @override
  String get phaseIdle => 'HAZIR';

  @override
  String get performanceTitle => 'HIZ TESTİ';

  @override
  String get performanceStart => 'TEST BAŞLAT';

  @override
  String get performanceRetry => 'TEKRAR ÇALIŞTIR';

  @override
  String get latencyLabel => 'GECİKME';

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
  String get channelCongestionHint => 'Mevcut kanalınız kalabalık. Geçiş hızı artırabilir.';

  @override
  String get evilTwinAlertTitle => 'SAHTE AĞNOKTASI TESPİT EDİLDİ';

  @override
  String get evilTwinAlertBody => 'Bir ağ, bilinen bir erişim noktasını taklit ediyor. Tanımadığınız ağlara bağlanmayın.';

  @override
  String get wpsWarningTitle => 'WPS AÇIK';

  @override
  String get wpsWarningBody => 'WPS, WPA2\'de bile şifrenizi kırmaya izin veren güvenlik açıkları içerir. Router ayarlarından devre dışı bırakın.';

  @override
  String wpsAffectedNetworks(int count) {
    return 'WPS etkin $count ağ';
  }

  @override
  String get heatmapTutorialTitle => 'ISISI HARİTASINI NASIL KULLANIRIM';

  @override
  String get heatmapTutorialStep1 => 'Yeni oturum başlatmak için KAYDI BAŞLAT\'a dokunun.';

  @override
  String get heatmapTutorialStep2 => 'Alanınızın her köşesine gidin ve konumunuza haritada dokunun.';

  @override
  String get heatmapTutorialStep3 => 'Kırmızı = zayıf sinyal. Yeşil = güçlü sinyal.';

  @override
  String get heatmapTutorialStep4 => 'Bitince DURDUR & KAYDET\'e dokunun.';

  @override
  String get gotIt => 'ANLADIM';

  @override
  String get speedTestHistory => 'TEST GEÇMİŞİ';

  @override
  String get noSpeedTestHistory => 'Henüz kayıtlı test yok. İlk testi yukarıdan başlatın.';

  @override
  String get networkScoreLabel => 'AĞ PUANI';

  @override
  String get vulnLabTitle => 'VULNERABILITY LAB';

  @override
  String get vulnLabSubtitle => 'Run security tests against your connected network';

  @override
  String get vulnLabRunAll => 'RUN ALL TESTS';

  @override
  String get vulnLabRunning => 'SCANNING...';

  @override
  String get vulnLabNoNetwork => 'Not connected to a Wi-Fi network. Connect first to run tests.';

  @override
  String get vulnLabAllClear => 'All tests passed. No vulnerabilities found on this network.';

  @override
  String vulnLabFoundCount(int count) {
    return '$count issue(s) found';
  }

  @override
  String get trustNetwork => 'TRUST NETWORK';

  @override
  String get untrustNetwork => 'UNTRUST NETWORK';

  @override
  String get trustedBaselineBadge => 'TRUSTED BASELINES';

  @override
  String get dnsEvidenceTitle => 'DNS EVIDENCE';

  @override
  String get shieldLabTitle => 'SHIELD LABORATORY';

  @override
  String get discoveredDevices => 'DISCOVERED DEVICES';

  @override
  String get openPortsFound => 'OPEN PORTS DETECTED';

  @override
  String get experimentalFeature => 'EXPERIMENTAL';

  @override
  String get deepScanDescription => 'Active port scanning and LAN discovery (May trigger network alerts)';
}
