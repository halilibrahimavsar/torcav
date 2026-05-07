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
  String get liveLabel => 'CANLI';

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
  String get broadcastingProbeRequests => 'Yerel sinyal ortamı analiz ediliyor...';

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
  String get backgroundSelectionRestricted => 'Siber ızgara stilleri karanlık mod için optimize edilmiştir ve yalnızca karanlık tema kullanılırken seçilebilir.';

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
  String get settingsAiClassificationDesc => 'Yerel AI destekli cihaz tespiti ve tanımlamayı etkinleştirir.';

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
  String get dnsPerformanceBenchmark => 'PERFORMANS TESTİ';

  @override
  String get dnsLatency => 'LATENCY';

  @override
  String get dnsRecommended => 'ÖNERİLEN';

  @override
  String get dnsFastest => 'FASTEST';

  @override
  String get dnsProvider => 'PROVIDER';

  @override
  String dnsResultLatency(int ms) {
    return '$ms ms';
  }

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
  String get networkSecurity => 'Ağ Güvenliği';

  @override
  String get portScanAction => 'PORT TARAMASI';

  @override
  String get hostnameLookupAction => 'LOOKUP HOSTNAME';

  @override
  String get arpInfoAction => 'ARP INFO';

  @override
  String get portsFoundLabel => 'OPEN PORTS';

  @override
  String get noPortsFound => 'No open ports found';

  @override
  String get portScanCommonPorts => 'Ortak Portlar';

  @override
  String get portScanCustomRange => 'Özel Aralık';

  @override
  String get portScanAllPorts => 'BÜTÜN PORTLAR';

  @override
  String get portScanFullScanWarning => '65.535 portun tamamını taramak uzun zaman alacaktır.';

  @override
  String get portScanStartPort => 'Başlangıç Portu';

  @override
  String get portScanEndPort => 'Bitiş Portu';

  @override
  String get portScanInvalidRange => 'Geçersiz port aralığı';

  @override
  String get portScanTooManyPorts => 'Uyarı: 1000\'den fazla portu taramak yavaş olabilir';

  @override
  String get portScanSearching => 'Açık portlar aranıyor. Bu işlem biraz zaman alabilir...';

  @override
  String portScanProbing(int port) {
    return 'Port $port taranıyor...';
  }

  @override
  String portScanFoundCount(int count) {
    return 'Şu ana kadar $count açık servis bulundu.';
  }

  @override
  String get portScanNoPortsProbed => 'Henüz taranmış port yok. Açık servisleri keşfetmek için bir port taraması çalıştırın.';

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
        'rogueApSuspected': 'Şüpheli AP Tespiti',
        'deauthBurstDetected': 'Deauth Patlaması Tespiti',
        'handshakeCaptureStarted': 'Handshake Protokol Analizi',
        'handshakeCaptureCompleted': 'Handshake Protokolü Doğrulandı',
        'captivePortalDetected': 'Captive Portal Tespiti',
        'evilTwinDetected': 'Evil Twin Tespiti',
        'deauthAttackSuspected': 'Şüpheli Deauth Saldırısı',
        'encryptionDowngraded': 'Şifreleme Düzeyi Düşürüldü',
        'unsupportedOperation': 'Desteklenmeyen İşlem',
        'arpSpoofingDetected': 'ARP Spoofing Tespiti',
        'dnsHijackingDetected': 'DNS Hijacking Tespiti',
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
  String get dnsVerifyIntegrity => 'DNS bütünlüğünü doğrulamak için tara';

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
  String get dnsEvidenceTitle => 'DNS KANITI';

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

  @override
  String get dnsProtocol => 'PROTOKOL';

  @override
  String get dnsSsec => 'DNSSEC';

  @override
  String get dnsWhatIsThat => 'Bu nedir?';

  @override
  String get dnsInfoHijackingTitle => 'DNS Ele Geçirme (Hijacking)';

  @override
  String get dnsInfoHijackingDesc => 'Ağ sağlayıcınızın veya kötü niyetli bir aktörün DNS sorgularınızı sahte sunuculara yönlendirmesidir. Bu, etkinliğinizi izlemelerine veya belirli web sitelerini engellemelerine olanak tanır.';

  @override
  String get dnsInfoLeakTitle => 'DNS Sızıntısı';

  @override
  String get dnsInfoLeakDesc => 'Bir VPN kullanırken bile sorgularınız güvenli tüneli baypas ederek ISS\'nizin sunucularına gidebilir. Bu, tarama geçmişinizi ağ sağlayıcısına \'sızdırır\'.';

  @override
  String get dnsInfoEncryptedTitle => 'Şifreli DNS (DoH/DoT)';

  @override
  String get dnsInfoEncryptedDesc => 'HTTPS üzerinden DNS (DoH) ve TLS üzerinden DNS (DoT), sorgularınızı şifreli bir katmana sarar. Bu, isteklerinizin yerel izleyiciler ve ağ yöneticileri tarafından okunamaz hale gelmesini sağlar.';

  @override
  String get dnsInfoDnssecTitle => 'DNSSEC';

  @override
  String get dnsInfoDnssecDesc => 'DNS Güvenlik Uzantıları, sorgularınıza kriptografik imzalar ekler. Bu, bir sunucunun size meşru siteler için sahte IP adresleri gönderdiği \'spoofing\' saldırılarını önler.';

  @override
  String get dnsInfoLatencyTitle => 'DNS Gecikmesi (RTT)';

  @override
  String get dnsInfoLatencyDesc => 'Gecikme (RTT), bir sorgunun sunucuya gidip gelmesi için geçen süreyi ölçer. Daha düşük gecikme, daha hızlı web gezintisi ve daha iyi performans demektir.';

  @override
  String get dnsInfoResolverDriftTitle => 'DNS Çözücü Kayması';

  @override
  String get dnsInfoResolverDriftDesc => 'DNS isteklerinizin yapılandırılanlardan farklı sağlayıcılar tarafından işlendiği tespit edildiğinde ortaya çıkar; bu durum şeffaf proxy kullanımı veya yönlendirme değişikliklerinden kaynaklanabilir.';

  @override
  String get netInfoSsidTitle => 'SSID (Ağ Adı)';

  @override
  String get netInfoSsidDesc => 'Wi-Fi ağınızın genel adıdır. Yaygın olsa da, saldırganlar tarafından sizi sahte bir erişim noktasına bağlamak için taklit edilebilir.';

  @override
  String get netInfoBssidTitle => 'BSSID (Donanım Adresi)';

  @override
  String get netInfoBssidDesc => 'Kablosuz yönlendiricinin benzersiz donanım adresidir (MAC). Meşru donanıma bağlı olduğunuzu ve bir yazılım kopyasına bağlı olmadığınızı doğrulamak için kullanışlıdır.';

  @override
  String get netInfoGatewayTitle => 'Varsayılan Ağ Geçidi';

  @override
  String get netInfoGatewayDesc => 'Yönlendiricinizin yerel IP adresidir. Tüm trafiğiniz bu noktadan geçer. Bu adres beklenmedik şekilde değişirse, bir Ortadaki Adam (MitM) saldırısına işaret edebilir.';

  @override
  String get dnsReadyStatus => 'ANALİZE HAZIR';

  @override
  String get dnsIdleDescription => 'DNS bütünlüğünü ve performansını doğrulamak için bir tarama başlatın.';

  @override
  String get netSecInfoTitle => 'Ağ Güvenliği Modülü';

  @override
  String get netSecInfoDesc => 'Kötü İkiz (Evil Twin) saldırılarına ve sahte ağlara karşı koruma sağlamak için bağlı ağların bütünlüğünü izler ve güvenilir profillerinizi yönetir.';

  @override
  String get spectrumOptimizationOpsSubtitle => 'Kanal puanlama · parazit';

  @override
  String get aboutSpectrumTitle => 'Spektrum Optimizasyonu Nedir?';

  @override
  String get aboutSpectrumWhatHeader => 'Nedir?';

  @override
  String get aboutSpectrumWhatBody => 'Wi-Fi cihazları, radyo spektrumunun \"kanal\" denilen dilimleri üzerinden konuşur. 2.4 GHz bandında üst üste binmeyen yalnızca 3 kanal vardır (1, 6, 11) ve bu band en kalabalık olanıdır. 5 GHz bandında çok daha fazla kanal bulunur ve parazit azdır. En yeni 6 GHz bandı (Wi-Fi 6E/7) ise çoğu evde neredeyse boştur.';

  @override
  String get aboutSpectrumWhyHeader => 'Ne işe yarar?';

  @override
  String get aboutSpectrumWhyBody => 'Birden fazla ağ aynı kanalı paylaşırsa sırayla konuşmak zorunda kalır ve hız düşer (Aynı Kanal Paraziti). 2.4 GHz\'de yan kanallar bile birbirinin üzerine biner ve cızırtı oluşturur (Komşu Kanal Paraziti). Sessiz bir kanal seçmek; hızı, gecikmeyi ve bağlantı kararlılığını doğrudan iyileştirir.';

  @override
  String get aboutSpectrumHowHeader => 'Nasıl yapılır?';

  @override
  String get aboutSpectrumHowBody => 'Bu ekran çevredeki tüm Wi-Fi ağlarını tarar; her kanalı rakip ağ sayısına, sinyal güçlerine ve komşu kanallarla örtüşmeye göre 0-10 arasında puanlar. Yeşil işaretli (≥8) bir kanal seçin: şu an en az kalabalık olan budur. Geçmiş sekmesi, o kanalın zaman içinde temiz kalıp kalmadığını gösterir.';

  @override
  String get bandSpectrumTitle => 'Kanal Spektrumu';

  @override
  String get bandSpectrumInfoTitle => 'Kanal Spektrumu';

  @override
  String get bandSpectrumInfoBody => 'Her bar bir kanaldır. Yüksek ve yeşil barlar sessiz; kısa kırmızı barlar kalabalık demektir. Bara dokunarak puanı (0-10) görebilirsiniz. Aynı kanalı paylaşan her ağ puandan 2 düşer (Aynı Kanal Paraziti); 2.4 GHz\'de komşu kanallardaki ağlar daha az puan düşürür (Komşu Kanal Paraziti). Yakın ve güçlü ağlar, uzak ve zayıf ağlardan daha fazla cezalandırılır.';

  @override
  String get recommendationInfoTitle => 'Öneri Nasıl Yapılır?';

  @override
  String get recommendationInfoBody => 'Her kanal 10 puandan başlar. Aynı kanalı paylaşan her ağ 2 puan (×sinyal gücü) düşürür. Komşu 2.4 GHz ağları mesafeye göre 0.2-1.5 puan düşürür. DFS kanalları (radar paylaşımlı) 0.5 puan kaybeder. En yüksek puanı alan kanal kazanır. Eşitlik durumunda küçük numaralı kanal tercih edilir.';

  @override
  String get consistentChannelInfoTitle => 'Tutarlı En İyi Kanal';

  @override
  String get consistentChannelInfoBody => 'Anlık tarama yanıltıcı olabilir: şu an sessiz olan bir kanal birazdan kalabalıklaşabilir. Geçmiş tüm taramalarınızı her kanal için ortalayıp en yüksek skorla istikrarlı kalan kanalı öne çıkarırız. Anlık öneriden farklıysa, geçmişte istikrarlı olan kanal genellikle uzun vadede daha güvenli seçimdir.';

  @override
  String get dfsBadgeLabel => 'DFS';

  @override
  String get dfsBadgeTooltip => 'DFS — meteoroloji/askeri radarla paylaşılır; yönlendiriciniz bu kanaldan kısa süreliğine ayrılabilir';

  @override
  String get dfsInfoTitle => 'DFS Nedir?';

  @override
  String get dfsInfoBody => 'DFS (Dynamic Frequency Selection — Dinamik Frekans Seçimi) kanalları, 5 GHz bandının 52-64 ve 100-144 arasındaki kanallarıdır. Bu kanallar yasal olarak hava durumu ve askeri radarlarla paylaşılır. Wi-Fi, bu radarlara öncelik vermek zorundadır: yönlendiriciniz bir radar darbesi algılarsa kanaldan en az 60 saniye boyunca ayrılmak zorundadır — bu süre boyunca cihazlarınız kısa süreliğine bağlantısı kopar ve başka bir kanala geçer. DFS kanalları genelde daha az kalabalık olduğu için yüksek puan alır; ancak havalimanı, liman veya meteoroloji istasyonu yakınlarında istikrarsız olabilir. Bu riski yansıtmak için skordan 0.5 puan düşürürüz. Yakında radar kaynağı yoksa kullanılabilir; aksi takdirde tercih etmemekte fayda vardır.';

  @override
  String get howToChangeChannelTitle => 'Wi-Fi kanalımı nasıl değiştiririm?';

  @override
  String get howToChangeChannelSubtitle => 'Yönlendiriciniz için adım adım kılavuz';

  @override
  String get guideConnectedTo => 'Bağlı olduğun ağ';

  @override
  String get guideRouterVendor => 'Yönlendirici markası';

  @override
  String get guideRouterUnknown => 'Tanınmadı — genel kılavuz gösteriliyor';

  @override
  String get guideStep1 => 'Adım 1 · Yönetim panelini aç';

  @override
  String get guideStep1Body => 'Aşağıdaki AÇ butonuna dokun — varsayılan tarayıcın yönlendiricinin yönetim sayfasında açılır. (Tercih edersen adresi kopyalayıp tarayıcıya elle yapıştırabilirsin.) Adresin çalışması için bu Wi-Fi\'a bağlı olmalısın; sadece mobil veriyle erişemezsin.';

  @override
  String get guideOpenInBrowser => 'Aç';

  @override
  String get guideOpenFailedMessage => 'Tarayıcı otomatik açılamadı — adresi kopyalayıp elle yapıştırabilirsin.';

  @override
  String get guideCredentialsHeader => 'Kullanıcı adı ve şifre';

  @override
  String get guideCredentialsBody => 'Yönetim sayfası giriş istediğinde:\n\n1. Yönlendiricinin altına veya arkasına bak — orada genellikle Wi-Fi şifresinin yanında YÖNETİM giriş bilgileri de yazar. Yönetim girişi \"Yönetim şifresi\", \"Web şifresi\", \"Modem şifresi\", \"Admin password\" veya \"Web password\" olarak etiketlenir. Bu, Wi-Fi şifresiyle AYNI DEĞİLDİR.\n\n2. Etiket yoksa şu fabrika varsayılanlarını dene:\n   • admin / admin\n   • admin / password\n   • admin / 1234\n   • root / admin\n   • Kullanıcı adı boş / şifre admin\n\n3. Yönlendiriciyi internet sağlayıcın kurduysa (Türk Telekom, TurkNet, Vodafone, Superonline, vb.) yönetim şifresi genellikle cihazın seri numarasının son 6-8 karakteridir; bu da etikette yazar. Birçok sağlayıcı her cihaza özel rastgele şifre basar.\n\n4. Hiçbiri olmuyorsa: birisi daha önce şifreyi değiştirmiş demektir. Yönlendiricinin arkasındaki RESET deliğine 10-15 saniye basılı tutarak fabrika ayarlarına dönebilirsin — ancak bu Wi-Fi adını ve şifresini de sıfırlar; tekrar baştan kurman gerekir.\n\n5. Bazı yeni yönlendiriciler web yönetim panelini bir telefon uygulamasıyla değiştirir (örn. TP-Link Tether, ASUS Router, Mi WiFi, Huawei AI Life). Web sayfası seni uygulamayı yüklemeye yönlendiriyorsa uygulamayı kurup oradan devam et.';

  @override
  String get guideAddressLabel => 'Yönetim adresi';

  @override
  String get guideCopyAddress => 'Kopyala';

  @override
  String get guideAddressCopied => 'Adres kopyalandı — tarayıcında aç';

  @override
  String get guideStep2 => 'Adım 2 · Wi-Fi / Kablosuz menüsünü bul';

  @override
  String get guideStep2Body => 'Giriş yaptıktan sonra Wi-Fi, Kablosuz, Wireless veya Ağ Ayarları adlı menüyü ara. Markalara göre isim değişebilir — aşağıda senin yönlendiricinin markasına göre yol verilmiştir:';

  @override
  String get guideStep3 => 'Adım 3 · Kanalı ayarla ve uygula';

  @override
  String get guideStep3Body => 'Kanal seçeneğini bul (Channel, Kanal veya Wireless Channel olarak yazabilir). Otomatik (Auto) olan değeri önceki ekranda önerilen kanal numarasına çevir. Yönlendiricin 2.4 GHz ile 5 GHz için ayrı seçenek gösteriyorsa her bandın kendi önerilen kanalını ayarla. Kaydet/Uygula\'ya bas. Yönlendirici Wi-Fi yayınını kısa bir an yeniden başlatacak.';

  @override
  String get guideMenuPathLabel => 'Menü yolu';

  @override
  String get guideGenericMenuPath => 'Wireless / Kablosuz → Temel / Gelişmiş Ayarlar → Kanal';

  @override
  String get channelWidthHeader => 'Kanal genişliği — 20 / 40 / 80 / 160 MHz';

  @override
  String get channelWidthBody => 'Kanal genişliği bir otoyolun şerit sayısı gibidir:\n• 20 MHz = 1 şerit. Yavaş ama trafiğe karşı dayanıklı. Kalabalık 2.4 GHz için en uygunu.\n• 40 MHz = 2 şerit. İki kat veri akışı, ama yan kanallarla daha çok çakışır.\n• 80 MHz = 4 şerit. Hızlı — yalnızca 5 GHz/6 GHz\'de kullanılabilir.\n• 160 MHz = 8 şerit. En yüksek hız, ama 5 GHz bandının yarısını kaplar; ancak komşu yoksa anlamlı.\n\nGenel kural: 2.4 GHz\'de 20 MHz; 5 GHz\'de 80 MHz; varsa 6 GHz\'de 160 MHz.';

  @override
  String get guideRisksHeader => 'Kanalı değiştirmek güvenli mi?';

  @override
  String get guideRisksBody => 'Evet — tamamen güvenli. Kanal değiştirmenin, yönlendirici radyoyu yeniden başlatırken oluşan 5-10 saniyelik kısa bir kesinti dışında hiçbir güvenlik veya performans yan etkisi yoktur. Ağ adın (SSID), şifren, port yönlendirme kuralların, ebeveyn denetimleri ve diğer tüm ayarlar aynen kalır. Bağlı cihazlar otomatik olarak yeniden bağlanır. Sonradan bir şey daha kötü gibi görünürse, aynı menüden Otomatik (Auto) ayarına geri dönebilirsin; yönlendirici kanalı kendisi seçer.';

  @override
  String get guideNoConnection => 'Bir Wi-Fi ağına bağlı değilsin — yönetim adresini ve markaya özel kılavuzu görmek için önce bağlan.';

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
  String get spectrumOverlapInfoBody => 'Her renkli şekil bir Wi-Fi ağıdır. X eksenindeki konumu merkez frekansını, genişliği kanal genişliğini (20/40/80/160 MHz), yüksekliği ise sinyal gücünü temsil eder (üst = güçlü, alt = zayıf). Şekillerin üst üste bindiği yerlerde, o ağlar aynı yayın süresini paylaşır ve birbirini yavaşlatır. Dikey bir dilim ki içinde hiç şekil olmasın (veya sadece zayıf olanlar altta kalsın) — orası sessiz bir kanaldır. Bir şekle dokunarak hangi ağ olduğunu görebilirsin.';

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
  String get countryAllowlistInfoBody => 'Wi-Fi kanalları her ülkede farklı düzenlenir. Bölgenizde yasak olan kanallar soluk gösterilir ve yönlendiricinizde kullanılamaz. Yurt dışındaysanız bölgeyi değiştirebilirsiniz; öneri yalnızca seçilen bölge için yasal kanallar arasından yapılır.';

  @override
  String get channelIllegalBadge => 'İZİNSİZ';

  @override
  String get channelIllegalTooltip => 'Seçilen bölgede bu kanal Wi-Fi için yasal değil.';

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
  String get hourlyHeatmapInsufficient => 'Yeterli geçmiş yok. Bu ekranı günün farklı saatlerinde aç ki desen oluşsun.';

  @override
  String get afcInfoTitle => '6 GHz Güç Sınıfları (AFC)';

  @override
  String get afcInfoBody => '6 GHz Wi-Fi üç güç sınıfına ayrılır:\n\n• LPI (Düşük Güç İç Mekan) — Ev yönlendiricileri için varsayılan. 30 dBm EIRP\'ye kadar, yalnızca iç mekanda yasal. Konum koordinasyonu gerekmez.\n\n• Standard Power (SP) — Dış mekan + yüksek güçlü iç mekan. 36 dBm\'e kadar. AFC (Otomatik Frekans Koordinasyonu) gerektirir: yönlendirici resmi bir veritabanına GPS konumunu gönderir, hangi kanalların yerleşik kullanıcılardan (uydu uplink, sabit mikrodalga linkleri) boş olduğu söylenir.\n\n• VLP (Çok Düşük Güç) — Mobil/taşınabilir kullanım, 14 dBm\'e kadar. Koordinasyon gerekmez ama menzil çok kısa; çoğunlukla AR/VR gözlüklerinde ve dizüstülerde.\n\nÇoğu ev ağı yalnızca LPI görür; dış mekanda güçlü 6 GHz sinyali görüyorsan büyük olasılıkla SP\'dir ve AFC ile koordine edilmiştir.';

  @override
  String get advancedTopicsHeader => 'İleri konular';

  @override
  String get advancedMeshTitle => 'Mesh ve dolaşım (roaming)';

  @override
  String get advancedMeshBody => 'Mesh ağda (Google Nest, Eero, TP-Link Deco vb.) kanalı manuel seçmezsin — kontrolör her düğüm için bir kanal seçer ve komşular değişince yeniden dengeler. Bazı kontrolörlerde düğüm bazında kanal geçersiz kılma var; ama otomatik mod genelde en iyisidir, çünkü sistem mesh düğümleri arasındaki çakışmayı da ölçer. Yine de elle ayarlamak istersen, ana düğümün ön-uç (istemciye bakan) radyosunu önerilen kanala al; arka-uç (düğümler arası) radyo otomatik kalsın.';

  @override
  String get advancedBandSteeringTitle => 'Band steering & tek SSID vs ikisi';

  @override
  String get advancedBandSteeringBody => 'Modern yönlendiriciler band-steering sunar: tek SSID hem 2.4 hem 5 GHz için, yönlendirici uygun cihazları 5 GHz\'e iter. Artıları: basit, cihazlar otomatik geçiş yapar. Eksileri: bazı IoT cihazlar (akıllı priz, kamera) sadece 2.4 GHz görür; yönlendirici steering sırasında o bandı gizlerse bağlantı kuramaz. Geçici çözüm: SSID\'leri ayır (örn. \"EvWiFi\" 5 GHz\'de, \"EvWiFi-IoT\" 2.4 GHz\'de), kurulumdan sonra istersen birleştir.';

  @override
  String get advancedWmmTitle => 'WMM / QoS';

  @override
  String get advancedWmmBody => 'WMM (Wi-Fi Multimedia) trafiği 4 sınıfa ayırır: ses, video, normal, arka plan. Wi-Fi 4+ sertifikası için zorunludur ve daima açık kalmalı. Kapatırsan hızın 802.11g seviyesine (~54 Mbps) düşer. Kanal seçimi WMM\'i etkilemez ama temiz bir kanal 4 sınıfı da aynı anda iyileştirir.';

  @override
  String get dfsCacWarning => '⚠ DFS kanalı: yönlendiricin bu kanala geçtiğinde 60 saniye sessizce dinleme yapması gerekir (Kanal Uygunluk Kontrolü — CAC). O sürede Wi-Fi yayını kesilir.';

  @override
  String get densityTrendStable => 'Yoğunluk sabit';

  @override
  String densityTrendVolatile(String delta) {
    return 'Değişken bölge · son 1 saatte yoğunluk $delta ağ kadar dalgalandı';
  }

  @override
  String get routerGroupsHeader => 'Yakındaki Router\'lar (çift band)';

  @override
  String get routerGroupsInfoBody => 'Aynı router\'ın aynı SSID\'i birden fazla bandda yayınladığı (ör. 2.4 GHz CH 6 ve 5 GHz CH 36) durumlarda iki radyoyu yan yana karşılaştırabilmen için burada gruplayıp listeleriz. Bir band chip\'ine dokunarak o sekmeye geç.';

  @override
  String crossBandSiblingHint(String band, String channel, String rating) {
    return 'Aynı router $band CH $channel\'de · $rating/10';
  }

  @override
  String get connectedChannelGuideLabel => 'SİZ';

  @override
  String get unstableChannelLabel => 'DENGESİZ';

  @override
  String get unstableChannelTooltip => 'Bu kanalın puanı son oturumlarda 1.5 puandan fazla dalgalandı';

  @override
  String get historyHeatmapInfoTitle => 'Isı Haritası Nedir?';

  @override
  String get historyHeatmapInfoBody => 'Her satır bir kanal, her sütun ise bir tarama yaptığınız andır. Hücre rengi o anda kanalın aldığı puanı gösterir: kırmızı (kötü) → sarı (orta) → yeşil (mükemmel). Boş hücreler, o taramada kanalın görünmediği anlamına gelir. Tamamen yeşil satırları kollayın — bunlar zamanla temiz kalan kanallardır.';

  @override
  String get clearChannelHistoryTitle => 'KANAL GEÇMİŞİNİ TEMİZLE';

  @override
  String get clearChannelHistoryConfirmBody => 'Tüm kanal puanı kayıtları silinsin mi? Bu işlem geri alınamaz.';

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
  String get speedDoctorOpsTile => 'HIZ DOKTORU';
  @override
  String get speedDoctorOpsSubtitle => 'Niye yavaş?';
  @override
  String get evilTwinDetailTitle => 'EVIL TWIN DETAYI';
}
