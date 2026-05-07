// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kurdish (`ku`).
class AppLocalizationsKu extends AppLocalizations {
  AppLocalizationsKu([String locale = 'ku']) : super(locale);

  @override
  String get wifiScanTitle => 'TARANA WI-FI';

  @override
  String get searchingNetworksPlaceholder => 'TORA DIGERE...';

  @override
  String get filterNetworksPlaceholder => 'TORAN PARZÛN BIKE...';

  @override
  String get quickScan => 'Tarana Bilez';

  @override
  String get deepScan => 'Tarana Kûr';

  @override
  String get deepScanExperimentalTitle => 'Deep Scan (Experimental)';

  @override
  String get deepScanExperimentalSubtitle => 'Actively probe LAN for devices and ports. Increased battery usage.';

  @override
  String get scanModesTitle => 'Modên Taranê';

  @override
  String get scanModesInfo => 'Tarana bilez guhdariya weşanan dike. Tarana kûr bi awayekî çalak toran diceribîne.';

  @override
  String get readyToScan => 'Amade ye ji bo Taranê';

  @override
  String get noSignalsDetected => 'Sînyal Nehatin Tespîtkirin';

  @override
  String get compareWithPreviousScan => 'BI TARANA BERÊ RE BERAWIRD BIKE';

  @override
  String networksCount(int count) {
    return '$count TOR';
  }

  @override
  String filteredNetworksCount(int count, int total) {
    return '$count JI $total TORAN';
  }

  @override
  String get securityAlertsTooltip => 'Hişyariyên ewlehiyê bibîne';

  @override
  String get livePulse => 'NEBZA ZINDÎ';

  @override
  String get liveLabel => 'ZINDÎ';

  @override
  String get operationsLabel => 'OPERASYON';

  @override
  String get topologyLabel => 'TOPOLOJÎ';

  @override
  String get networkLogs => 'LOGÊN TORÊ';

  @override
  String get connectedStatusCaps => 'GIRÊDAYÎ';

  @override
  String get disconnectedStatusCaps => 'QUTKIRÎ';

  @override
  String get ipLabel => 'IP';

  @override
  String get gatewayLabel => 'GATEWAY';

  @override
  String get accessEngine => 'MOTORA GIHÎŞTINÊ';

  @override
  String get latestSnapshotTitle => 'Wêneyê Dawî ya Torê';

  @override
  String get noSnapshotAvailable => 'Daneyên wêneyê tune...';

  @override
  String get strictSafetyEnabled => 'Protokolên ewlehiyê yên hişk çalak in';

  @override
  String get activeMonitoringProgress => 'Şopandina aktîf berdewam dike...';

  @override
  String get scanComparisonTitle => 'BERAWIRDKIRINA TARANÊ';

  @override
  String get comparisonNeedsTwoScans => 'Berawirdkirin herî kêm 2 taranan dixwaze.\n\nJi bo dîtina guhertinan taranek din bike.';

  @override
  String get noChangesDetected => 'Di navbera her du taranên dawî de tu guhertin nehatin dîtin.';

  @override
  String newNetworksCountLabel(int count) {
    return 'NÛ ($count)';
  }

  @override
  String goneNetworksCountLabel(int count) {
    return 'ÇÛYÎ ($count)';
  }

  @override
  String changedNetworksCountLabel(int count) {
    return 'GUHERÎ ($count)';
  }

  @override
  String get plusNewLabel => '+ NÛ';

  @override
  String get goneLabel => 'ÇÛYÎ';

  @override
  String get hiddenLabel => '[Veşartî]';

  @override
  String channelLabel(int channel) {
    return 'K $channel';
  }

  @override
  String get securityLabel => 'EWLEKARÎ';

  @override
  String get initiatingSpectrumScan => 'TARANA SPEKTRUMÊ DEST PÊ DIKE...';

  @override
  String get broadcastingProbeRequests => 'DAXWAZÊN PROBE TÊN WEŞANDIN...';

  @override
  String get noRadiosInRange => 'Di qadê de tu radyo tune ne';

  @override
  String get noNetworksMatchFilter => 'Tu tor bi parzûna we re li hev nakin';

  @override
  String get searchSsidBssidVendor => 'Li SSID, BSSID an Firoşkar bigere...';

  @override
  String sortPrefix(String option) {
    return 'Rêzkirin: $option';
  }

  @override
  String get bandAll => 'HEMÛ BAND';

  @override
  String get sortSignal => 'Sînyal';

  @override
  String get sortName => 'Nav';

  @override
  String get sortChannel => 'Kanal';

  @override
  String get sortSecurity => 'Ewlekarî';

  @override
  String get sortByTitle => 'RÊZKIRIN BI';

  @override
  String recommendationTip(String channels, String band) {
    return 'Kanalên herî baş li ser $band: $channels';
  }

  @override
  String get channelInterferenceTitle => 'Destwerdana Kanalên';

  @override
  String get networksLabel => 'TOR';

  @override
  String openCount(int count) {
    return '$count VEKIRÎ';
  }

  @override
  String get avgSignalLabel => 'SÎNYALA NAVÎN';

  @override
  String get notAvailable => 'N/A';

  @override
  String get dbmCaps => 'DBM';

  @override
  String get interfaceLabel => 'NAVBER';

  @override
  String frequencyLabel(int freq) {
    return '$freq MHz';
  }

  @override
  String get reportsTitle => 'RAPOR';

  @override
  String get saveReportDialog => 'Raporê Tomar Bike';

  @override
  String savedToast(String path) {
    return 'Rapor li $path hate tomarkirin';
  }

  @override
  String get errorLabel => 'Şaşî';

  @override
  String get savePdfReportDialog => 'Rapora PDF Tomar Bike';

  @override
  String get scanning => 'Taran dike...';

  @override
  String get shieldActive => 'Mertal Aktîf e';

  @override
  String get threatsDetected => 'XETER HATIN DÎTIN';

  @override
  String get trustedLabel => 'EWLE';

  @override
  String get securityEventTitle => 'Bûyera Ewlehiyê';

  @override
  String get networkReconTitle => 'KEŞFA TORÊ';

  @override
  String get intelligenceReportTitle => 'RAPORA ÎSTÎXBARATÊ';

  @override
  String get discoveredEndpointsTitle => 'NAVNÎŞANÊN HATINE DÎTIN';

  @override
  String newDeviceFound(String ip) {
    return '1 amûra nû: $ip';
  }

  @override
  String newDevicesFound(int count) {
    return 'Di tora we de $count amûrên nû hatin dîtin';
  }

  @override
  String get targetIpSubnet => 'Target IP / Subnet';

  @override
  String get scanProfileFast => 'Bilez';

  @override
  String get scanProfileBalanced => 'Hevseng';

  @override
  String get scanProfileAggressive => 'Zêde';

  @override
  String get scanProfileNormal => 'Normal';

  @override
  String get scanProfileIntense => 'Giran';

  @override
  String get vulnOnlyLabel => 'Tenê Lawazî';

  @override
  String get lanReconTitle => 'LAN RECON';

  @override
  String get targetSubnet => 'Subnet / IP Target';

  @override
  String get scanAllCaps => 'TARA';

  @override
  String get channelRatingTitle => 'PUANLAMA KANALÊ';

  @override
  String get refreshScanTooltip => 'Taranê Nû Bike';

  @override
  String get band24Ghz => '2.4 GHz';

  @override
  String get band5Ghz => '5 GHz';

  @override
  String get band6Ghz => '6 GHz';

  @override
  String get no24GhzChannels => 'Kanalên 2.4 GHz nehatin dîtin.';

  @override
  String get no5GhzChannels => 'Kanalên 5 GHz nehatin dîtin.';

  @override
  String get no6GhzChannels => 'Kanalên 6 GHz nehatin dîtin.';

  @override
  String get analyzing => 'Analîz dike...';

  @override
  String get historyLabel => 'DÎROK';

  @override
  String failedLoadTopology(String error) {
    return 'Topolojî bar nabe: $error';
  }

  @override
  String get trafficLabel => 'TRAFÎK';

  @override
  String get forceLabel => 'HÊZ';

  @override
  String get normalSpeed => 'NORMAL';

  @override
  String get fastSpeed => 'BILEZ';

  @override
  String get overdriveSpeed => 'OVERDRIVE';

  @override
  String get topologyMapTitle => 'NEXŞEYA TOPOLOJIYÊ';

  @override
  String get noTopologyData => 'Daneyên Topolojiyê Nîn in';

  @override
  String get runScanFirst => 'Pêşî taranek bike ku nexşeya torê were avakirin';

  @override
  String get retry => 'DISA CERIBANDIN';

  @override
  String get thisDevice => 'EV AMÛR';

  @override
  String get gatewayDevice => 'GATEWAY';

  @override
  String get mobileDevice => 'MOBÎL';

  @override
  String get deviceLabel => 'AMÛR';

  @override
  String get iotDevice => 'IOT';

  @override
  String get analyzingNode => 'GIRÊK ANALÎZ DIKE';

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
  String get settingsTitle => 'MÎHENG';

  @override
  String get appearance => 'Xuyang';

  @override
  String get settingsLanguage => 'Ziman';

  @override
  String get theme => 'Tema';

  @override
  String get settingsBackgroundStyle => 'Şêwaza Paşperdeyê';

  @override
  String get backgroundNeomorphic => 'Neomorfîk (Performansa Bilind)';

  @override
  String get backgroundClassic => 'Tora Klasîk';

  @override
  String get backgroundAuroraMesh => 'Aurora Mesh (Ezmûnî)';

  @override
  String get backgroundHoloSphere => 'Gogê Holografîk (3D)';

  @override
  String get backgroundNeuralPulse => 'Pulsê Nöral (Anîmasyonî)';

  @override
  String get backgroundSelectionRestricted => 'Cyber grid styles are optimized for dark mode and only available when using the dark theme.';

  @override
  String get settingsScanBehavior => 'Tevgera Taraneyê';

  @override
  String get settingsDefaultScanPasses => 'Derbasbûnên Taranê';

  @override
  String get settingsMonitoringInterval => 'Navbera Şopandinê';

  @override
  String get settingsBackendPreference => 'Terciha Backend';

  @override
  String get settingsIncludeHidden => 'Torên Veşartî Têxe Nav';

  @override
  String get settingsStrictSafety => 'Moda Ewlekariya Hişk';

  @override
  String get settingsStrictSafetyDesc => 'Operasyonên metirsîdar sînor bike';

  @override
  String get settingsAiClassification => 'AI Device Classification';

  @override
  String get settingsAiClassificationDesc => 'Enables local AI-powered device detection and identification.';

  @override
  String get aiBadgeLabel => 'AI';

  @override
  String get darkTheme => 'Tarî';

  @override
  String get lightTheme => 'Ronî';

  @override
  String get systemTheme => 'Sîstem';

  @override
  String get sectionStatus => 'Rewş';

  @override
  String get reportsSubtitle => 'Tarana Torê û Ewlekariya Îstîxbaratê';

  @override
  String get exportOptionsTitle => 'VEBIJARKÊN DERXISTINÊ';

  @override
  String get exportJson => 'Wek JSON Derxe';

  @override
  String get exportHtml => 'Wek HTML Derxe';

  @override
  String get exportPdf => 'Wek PDF Derxe';

  @override
  String get printPdf => 'PDF Çap Bike';

  @override
  String get navWifi => 'WLAN';

  @override
  String get backendLabel => 'BACKEND';

  @override
  String get defenseTitle => 'PARASTIN';

  @override
  String get shieldLabReady => 'Ready for Assessment';

  @override
  String get deepScanRunning => 'Scan in progress...';

  @override
  String get knownNetworks => 'Torên Nas';

  @override
  String get noKnownNetworksYet => 'Hîn torên nas tune ne';

  @override
  String get noIdentifiedNetworks => 'No identified networks in laboratory archives';

  @override
  String get knownNetworksDashboard => 'KNOWN NETWORKS ARCHIVE';

  @override
  String get securityTimeline => 'Rêzika Demê ya Ewlehiyê';

  @override
  String get noSecurityEvents => 'Tu bûyerên ewlehiyê nehatine tomarkirin';

  @override
  String get dnsSecurityTitle => 'DNS INTEGRITY';

  @override
  String get dnsSecurityBody => 'Verify that your DNS queries are not being hijacked or spoofed.';

  @override
  String get dnsIntegrity => 'DNS INTEGRITY';

  @override
  String get dnsPerformanceBenchmark => 'PERFORMANCE BENCHMARK';

  @override
  String get dnsLatency => 'LATENCY';

  @override
  String get dnsRecommended => 'RECOMMENDED';

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
  String get authLocalSystem => 'AUTH_SÎSTEMA_XWECÎHÎ';

  @override
  String remoteNodeIdLabel(String id) {
    return 'REMOTE_NODE_ID: $id';
  }

  @override
  String get ipAddrLabel => 'NAVNÎŞANA_IP';

  @override
  String get macValLabel => 'NIRXÊ_MAC';

  @override
  String get mnfrLabel => 'FIROŞKAR';

  @override
  String get hiddenNetwork => 'Tora Veşartî';

  @override
  String get signalGraph => 'Grafîka Sînyalan';

  @override
  String get riskFactors => 'Faktorên Rîskê';

  @override
  String get vulnerabilities => 'Lawazî';

  @override
  String get bssId => 'BSSID';

  @override
  String get channel => 'Kanal';

  @override
  String get security => 'Ewlehî';

  @override
  String get signal => 'Sînyal';

  @override
  String recommendationLabel(String text) {
    return 'PÊŞNIYAR: $text';
  }

  @override
  String get noVulnerabilities => 'Tu lawazî nehatin dîtin.';

  @override
  String get securityScoreTitle => 'Puana Ewlehiyê';

  @override
  String get securityScoreDesc => 'Puana ewlehiyê (0–100) nîşan dide ka ev tor çiqas baş tê parastin. Her ku zêde be çêtir e. Cureyê şîfrekirinê, rewşa WPS û taybetmendiyên din ên ewlehiyê li ber çavan digire.';

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
  String get portScanCommonPorts => 'Portên Hevpar';

  @override
  String get portScanCustomRange => 'Rêjeya Taybet';

  @override
  String get portScanAllPorts => 'HEMÛ PORT';

  @override
  String get portScanFullScanWarning => 'Skankirina hemû 65.535 portan dê demeke dirêj bikişîne.';

  @override
  String get portScanStartPort => 'Porta Destpêkê';

  @override
  String get portScanEndPort => 'Porta Dawî';

  @override
  String get portScanInvalidRange => 'Rêzeya portê ya nelihev hat dayîn';

  @override
  String get portScanTooManyPorts => 'Hişyarî: Skankirina >1000 portan dikare hêdî bibe';

  @override
  String get portScanSearching => 'Li portên vekirî tê gerîn. Dibe ku demekê bikişîne...';

  @override
  String portScanProbing(int port) {
    return 'Porta $port tê skankirin...';
  }

  @override
  String portScanFoundCount(int count) {
    return 'Heta niha $count xizmetên vekirî hatin dîtin.';
  }

  @override
  String get portScanNoPortsProbed => 'Hîn tu port nehatine skankirin. Ji bo dîtina xizmetên vekirî skanekê bidin destpêkirin.';

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
  String get capabilitiesLabel => 'TAYBETMENDÎ';

  @override
  String get wifi7MldLabel => 'Wi-Fi 7 MLD';

  @override
  String get tagWpa3Desc => 'WPA3 standarta herî nû ya ewlehiyê ye — pir ewle ye.';

  @override
  String get tagWpa2Desc => 'WPA2 standartek ewlehiyê ya bi hêz e — ji bo karanîna rojane ewle ye.';

  @override
  String get tagWpaDesc => 'WPA standartek kevn a ewlehiyê ye ku kêmasiyên wê yên naskirî hene.';

  @override
  String get tagWpsDesc => 'Kêmasiyên ewlehiyê yên naskirî di WPS (Wi-Fi Protected Setup) de hene. Dikare rê bide êrîşkaran ku PIN-ê bi brute-force bişkînin û têkevin hundur.';

  @override
  String get tagPmfDesc => 'Protected Management Frames (PMF/MFP) li dijî êrîşên deauthentication diparêze.';

  @override
  String get tagEssDesc => 'ESS (Extended Service Set) tê wê wateyê ku ev toreke standarta access point e.';

  @override
  String get tagCcmpDesc => 'CCMP (AES) şîfrekirineke bi hêz e ku bi WPA2/WPA3 re tê bikaranîn.';

  @override
  String get tagTkipDesc => 'TKIP cureyekî şîfrekirinê yê kevn û lawaz e. CCMP/AES tê tercîhkirin.';

  @override
  String get tagUnknownDesc => 'Ala taybetmendiya torê ji beacon frame.';

  @override
  String get scanProfileLabel => 'PROFÎLA TARANÊ';

  @override
  String get infoScanProfilesTitle => 'Profîlên Taranê';

  @override
  String get infoScanProfileFastDesc => 'Bilez: Kontrola ping a bilez — di çirkeyan de amûran dibîne.';

  @override
  String get infoScanProfileBalancedDesc => 'Hevseng: Ping + portên hevpar — hûrguliyên zêdetir dibîne.';

  @override
  String get infoScanProfileAggressiveDesc => 'Zêde: Tarana portan a tije — ya herî berfireh lê ya herî hêdî ye.';

  @override
  String get activeNodeRecon => 'NASÎNA AKTÎF A NAVENDAN';

  @override
  String get interrogatingSubnet => 'Ji bo mêvandarên bersivdar li subnet heyî digere...';

  @override
  String get nodesLabel => 'Navend';

  @override
  String get riskAvgLabel => 'Navîna Rîskê';

  @override
  String get servicesLabel => 'Xizmet';

  @override
  String get openPortsLabel => 'PORTÊN VEKIRÎ';

  @override
  String get subnetLabel => 'Subnet';

  @override
  String get cidrTargetLabel => 'CIDR TARGET';

  @override
  String get anonymousNode => 'NAVENDA NANAV';

  @override
  String portsCountLabel(int count) {
    return '$count PORT';
  }

  @override
  String get riskLabel => 'RÎSK';

  @override
  String get searchLanPlaceholder => 'Bi navê IP, mêvandar an firoşkar bigere...';

  @override
  String get hasVulnerabilitiesLabel => 'Lawazî Hene';

  @override
  String get securityStatusSecure => 'Ewle';

  @override
  String get securityStatusModerate => 'Navîn';

  @override
  String get securityStatusAtRisk => 'Di Rîskê de';

  @override
  String get securityStatusCritical => 'Krîtîk';

  @override
  String get securitySummarySecure => 'Girêdana we baş xuya dike! Ev tor şîfrekirina bi hêz bikar tîne û li dijî êrîşên gelemperî baş tê parastin.';

  @override
  String get securitySummaryModerate => 'Ewlehiya vê torê baş e lê hinek xalên lawaz hene. Ji bo bikaranîna rojane ewle ye, lê karên pir hesas nekin.';

  @override
  String get securitySummaryAtRisk => 'Di vê torê de pirsgirêkên ewlehiyê hene ku daneyên we dixin metirsiyê. Dema girêdayî bin şîfreyan an agahiyên kesane nenivîsin.';

  @override
  String get securitySummaryCritical => 'Hişyarî: Ev tor ne ewle ye. Kesên li nêzîk dikarin trafîka înterneta we bibînin. VPN bikar bînin an torê biguherînin.';

  @override
  String get vulnerabilityOpenNetworkTitle => 'Tora Vekirî';

  @override
  String get vulnerabilityOpenNetworkDesc => 'Şîfrekirin nehat tespîtkirin. Hemû trafîk wekî nivîs dikare were dîtin.';

  @override
  String get vulnerabilityOpenNetworkRec => 'Ji karên hesas dûr bisekin. VPN-ya pêbawer an toreke cuda tercîh bikin.';

  @override
  String get vulnerabilityWepTitle => 'Şîfrekirina WEP';

  @override
  String get vulnerabilityWepDesc => 'WEP nayê pêşniyar kirin û bi hêsanî dikare were şikandin.';

  @override
  String get vulnerabilityWepRec => 'Tavilê mîhengên AP biguherînin WPA2 an WPA3.';

  @override
  String get vulnerabilityLegacyWpaTitle => 'WPA ya Kevn';

  @override
  String get vulnerabilityLegacyWpaDesc => 'WPA/TKIP kevn e û li hember êrîşên nûjen lawaz e.';

  @override
  String get vulnerabilityLegacyWpaRec => 'AP û amûran bikşînin asteke bilind (WPA2/WPA3).';

  @override
  String get vulnerabilityHiddenSsidTitle => 'SSID ya Veşartî';

  @override
  String get vulnerabilityHiddenSsidDesc => 'SSID-yên veşartî hîn jî dikarin werin dîtin û dibe ku lihevhatinê xirab bikin.';

  @override
  String get vulnerabilityHiddenSsidRec => 'SSID-ya veşartî ne parastin e. Bala xwe bidin ser şîfrekirina bi hêz.';

  @override
  String get vulnerabilityWeakSignalTitle => 'Sînyala Gelek Lawaz';

  @override
  String get vulnerabilityWeakSignalDesc => 'Sînyala lawaz dikare girêdanên ne aram û metirsiyan nîşan bide.';

  @override
  String get vulnerabilityWeakSignalRec => 'Nêzîkî AP bibin an BSSID kontrol bikin.';

  @override
  String get vulnerabilityWpsTitle => 'WPS Çalak e';

  @override
  String get vulnerabilityWpsDesc => 'Wi-Fi Korumalı Kurulum (WPS) çalak e. Moda PIN-a WPS dikare bi hêsanî were şikandin û gihîştina şîfreyê bide.';

  @override
  String get vulnerabilityWpsRec => 'Di panela mîhengan a routerê de WPS bigirin. Tenê WPA2/WPA3 bikar bînin.';

  @override
  String get vulnerabilityPmfTitle => 'Çarçoveyên Rêvebiriyê Nehatine Parastin';

  @override
  String get vulnerabilityPmfDesc => 'Ev access point PMF (802.11w) naxwaze. Nivîsên rêvebiriyê yên neparastî rê didin êrîşkaran ku amûran deauth bikin.';

  @override
  String get vulnerabilityPmfRec => 'Di mîhengên routerê de PMF (wek \'802.11w\' jî tê zanîn) çalak bikin. WPA3 jixwe PMF dixwaze.';

  @override
  String get vulnerabilityEvilTwinTitle => 'Evil Twin ya Potansiyel';

  @override
  String get vulnerabilityEvilTwinDesc => 'SSID li nêzîk bi hûrguliyên ewlehiyê yên nakok xuya dike.';

  @override
  String get vulnerabilityEvilTwinRec => 'Beriya nasandinê BSSID û sertîfîkayê kontrol bikin.';

  @override
  String get riskFactorNoEncryption => 'Şîfrekirin nayê bikaranîn';

  @override
  String get riskFactorDeprecatedEncryption => 'Şîfrekirina kevnar (WEP)';

  @override
  String get riskFactorLegacyWpa => 'WPA ya kevn di bikaranînê de ye';

  @override
  String get riskFactorHiddenSsid => 'Tevgera SSID a veşartî';

  @override
  String get riskFactorWeakSignal => 'Hawirdora sînyala lawaz';

  @override
  String get riskFactorWpsEnabled => 'WPS PIN vekirî ye';

  @override
  String get riskFactorPmfNotEnforced => 'PMF nayê xwestin — xetera deauth heye';

  @override
  String get refresh => 'Nû bike';

  @override
  String get addZonePoint => 'Xala Herêmê Zêde Bike';

  @override
  String get cancel => 'Betal bike';

  @override
  String get save => 'Tomar bike';

  @override
  String get waitingForData => 'Li benda daneyan e...';

  @override
  String get temporalHeatmap => 'Nexşeya Germiyê ya Demkî';

  @override
  String get failedToSaveHeatmapPoint => 'Xala nexşeya germiyê nehat tomarkirin';

  @override
  String signalMonitoringTitle(String ssid) {
    return 'ŞOPANDINA SÎNYALÊ: $ssid';
  }

  @override
  String get heatmapTooltip => 'Nexşeya Germiyê';

  @override
  String get tagCurrentPointTooltip => 'Xala heyî nîşan bike';

  @override
  String get signalCaps => 'SÎNYAL';

  @override
  String get channelCaps => 'KANAL';

  @override
  String get frequencyCaps => 'FREKANS';

  @override
  String heatmapPointAdded(String zone) {
    return 'Xala nexşeya germiyê ji bo $zone hat zêdekirin';
  }

  @override
  String get zoneTagLabel => 'Etîketa herêmê (mînak: Metbex)';

  @override
  String errorPrefix(String message) {
    return 'Şaşî: $message';
  }

  @override
  String noHeatmapPointsYet(String bssid) {
    return 'Ji bo $bssid hîn ti xalên nexşeya germiyê tune';
  }

  @override
  String get averageSignalByZone => 'Sînyala navîn li gorî herêman';

  @override
  String bandChannels(String band) {
    return '$band KANAL';
  }

  @override
  String get recommendedChannel => 'KANALA PÊŞNIYARKIRÎ';

  @override
  String channelInfo(int ch, int freq) {
    return 'Kanala $ch · $freq MHz';
  }

  @override
  String get riskFactorFingerprintDrift => 'Veqetîna şopa tiliya SSID hat dîtin';

  @override
  String get historyCaps => 'DÎROK';

  @override
  String get consistentlyBestChannel => 'KANALA HERÎ BAŞ A BERDEWAM';

  @override
  String get avgScore => 'Skora Navîn';

  @override
  String get channelBondingTitle => 'Girêdana Kanalan';

  @override
  String get channelBondingDesc => 'Girêdana kanalan 2 an zêdetir kanalên cîranê hev dixe yek ku firehiya bandê zêde bibe (40 MHz = 2×, 80 MHz = 4×, 160 MHz = 8×). Kanalên firehtir leza zêdetir didin lê dikarin bandorê li ser torên cîran jî bikin.';

  @override
  String get spectrumOptimizationCaps => 'OPTMÎZASYONA SPEKTRUMÊ';

  @override
  String get spectrumOptimizationDesc => 'Qelebalixiya kanalê û parazîtê analîz bike';

  @override
  String get qualityExcellent => 'Zaf Baş';

  @override
  String get qualityVeryGood => 'Gelek Baş';

  @override
  String get qualityGood => 'Baş';

  @override
  String get qualityFair => 'Normal';

  @override
  String get qualityCongested => 'Qelebalix';

  @override
  String channelBondingHeader(int count) {
    return 'GIRÊDANA KANALAN ($count AP)';
  }

  @override
  String get hiddenSsidLabel => '[Veşartî]';

  @override
  String get noHistoryPlaceholder => 'Hîn dîrok tune.\nHer cara ku hûn vê ekranê vedikin, pileya kanalan tê tomarkirin.';

  @override
  String get currentSessionInfo => 'Oturuma heyî — skora bilind = kêmtir qerebalix.';

  @override
  String historySummaryInfo(int sessions, int samples) {
    return '$sessions rûniştin · $samples nimûne · bilindtir = kêmtir qerebalix';
  }

  @override
  String get scanReportTitle => 'Rapora Skana Wi-Fi ya Torcav';

  @override
  String get reportTime => 'Dem';

  @override
  String get ssidHeader => 'SSID';

  @override
  String get bssidHeader => 'BSSID';

  @override
  String get dbmHeader => 'dBm';

  @override
  String get channelHeader => 'CH';

  @override
  String get navDashboard => 'DASHBOARD';

  @override
  String get navDiscovery => 'VEDÎTIN';

  @override
  String get navOperations => 'OPERASYON';

  @override
  String get navLan => 'LAN';

  @override
  String get systemStatus => 'Rewşa Pergalê';

  @override
  String get interfaceTheme => 'Mijara Navrûyê';

  @override
  String get speedTestHeader => 'TESTA LEZÊ';

  @override
  String get startTest => 'DEST PÊ BIKIN';

  @override
  String get testAgain => 'DÎSA TEST BIKIN';

  @override
  String get commandCenters => 'NAVENDA FERMANDARIYÊ';

  @override
  String get activeShielding => 'Mertalê Çalak';

  @override
  String get logisticsTitle => 'LOJÎSTÎK';

  @override
  String get intelMetrics => 'Metrîkên Veqetandî';

  @override
  String get networkMesh => 'Tora Qatî';

  @override
  String get tuningTitle => 'VERASTKIRIN';

  @override
  String get systemConfig => 'Veavakirina Pergalê';

  @override
  String get phasePing => 'QONAX: PING';

  @override
  String get phaseDownload => 'QONAX: DAXISTIN';

  @override
  String get phaseUpload => 'QONAX: BARKIRIN';

  @override
  String get phaseDone => 'QONAX: TEMAM';

  @override
  String get riskScore => 'Pûana Rîskê';

  @override
  String get loading => 'Tê barkirin...';

  @override
  String get profileTitle => 'NAVENDA PROFILÊ';

  @override
  String get activeSessionLabel => 'Danişîna Çalak';

  @override
  String get networkStatusLabel => 'REWŞA TORÊ';

  @override
  String get ssid => 'SSID';

  @override
  String get lastScanTitle => 'SKANA DAWÎ';

  @override
  String get lastSnapshot => 'Veqetandina Dawî';

  @override
  String get channelInterferenceDescription => 'Kanalên Wi-Fi wekî stasyonên radyoyê ne. Dema ku gelek tor heman kanalê parve dikin ew hev hêdî dikin - mîna ku her kes di heman demê de diaxive. Veguhestina ser kanalekî kêmtir qelebalix dikare lez û rehetiya we baştir bike.';

  @override
  String securityEventType(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'rogueApSuspected': 'Gumana AP ya Sexte',
        'deauthBurstDetected': 'Êrîşa Qutkirinê Serî Hatiye Dîtin',
        'handshakeCaptureStarted': 'Guhertina Nasnameya Ewle',
        'handshakeCaptureCompleted': 'Guhertina Nasnameyê Hat Piştrastkirin',
        'captivePortalDetected': 'Portala Girtî Hat Dîtin',
        'evilTwinDetected': 'Cêwîyê Xirab Hat Dîtin',
        'deauthAttackSuspected': 'Gumana Êrîşa Qutkirinê',
        'encryptionDowngraded': 'Şîfrekirin Hat Daxistin',
        'unsupportedOperation': 'Kareke Nayê Piştgirîkirin',
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
        'low': 'Kêm',
        'medium': 'Navîn',
        'info': 'Zanyarî',
        'warning': 'Hişyarî',
        'high': 'Bilind',
        'critical': 'Krîtîk',
        'other': '$severity',
      },
    );
    return '$_temp0';
  }

  @override
  String evilTwinEvidence(String expected, String found) {
    return 'Lihevnehatina BSSID! Ya Tê Çaverêkirin: $expected, Ya Hatî Dîtin: $found. Îhtîmaleke mezin a Xala Gihîştina Cêwîyê Xirab.';
  }

  @override
  String get rogueApEvidence => 'MAC-a Ketober/LAA di tora naskirî de hat dîtin! Ev ji bo Xalên Gihîştina rewa pir neasayî ye û dibe ku nîşan bide ku amûrek sexte heye.';

  @override
  String downgradeEvidence(String oldSec, String newSec) {
    return 'Profîla şîfrekirinê ji $oldSec ber bi $newSec ve hat guhartin. Gumana êrîşa daxistinê.';
  }

  @override
  String get historyAllBands => 'HEMÛ';

  @override
  String get historyBestChannel => 'KANALA HERÎ BAŞ';

  @override
  String get historyAvgRating => 'NAVG. PUAN';

  @override
  String get historySessions => 'DANIŞÎN';

  @override
  String get historyLineChart => 'Grafîka xêzikê';

  @override
  String get historyHeatmap => 'Nexşeya germê';

  @override
  String get historyNoDataForFilter => 'Ji bo fîltera bijartî dane tune.';

  @override
  String get historyChannelRatings => 'Puanên Kanalê';

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
  String get phaseIdle => 'AMADE';

  @override
  String get performanceTitle => 'TESTA LEZÊ';

  @override
  String get performanceStart => 'DEST PÊ KE';

  @override
  String get performanceRetry => 'DU CARÊ';

  @override
  String get latencyLabel => 'DERENGÎ';

  @override
  String get jitterLabel => 'JITTER';

  @override
  String get whatThisMeans => 'ÊVÊ ÇI TÊ WATEYA';

  @override
  String get channelRecommendation => 'PÊŞNIYARA KANALÊ';

  @override
  String switchToChannel(int channel) {
    return 'Biçe Kanala $channel';
  }

  @override
  String get channelCongestionHint => 'Kanala we tijî ye. Guherandin dikare lezê baştir bike.';

  @override
  String get evilTwinAlertTitle => 'XALÊ GIHÎŞTINÊ YÊ DEREWÎN HATE DÎTIN';

  @override
  String get evilTwinAlertBody => 'Tora xwe wekî xaleke naskirî nîşan dide. Bi torên nenas ve nevekin.';

  @override
  String get wpsWarningTitle => 'WPS VEKIRÎ YE';

  @override
  String get wpsWarningBody => 'WPS xeletiyên ewlehiyê hene. Ji mîhengên rûterê xwe neçalak bike.';

  @override
  String wpsAffectedNetworks(int count) {
    return '$count tor bi WPS vekirî';
  }

  @override
  String get heatmapTutorialTitle => 'NEXŞEYA GERMAHIYÊ ÇAWA BIKAR BÎNIM';

  @override
  String get heatmapTutorialStep1 => 'Seansek nû destpê bike, li TOMAR DEST PÊ KE bikirtînin.';

  @override
  String get heatmapTutorialStep2 => 'Biçin her quncikek û li cîhê xwe nexşeyê bikirtînin.';

  @override
  String get heatmapTutorialStep3 => 'Sor = nîşan qels. Kesk = nîşan xurt.';

  @override
  String get heatmapTutorialStep4 => 'Dema ku hat xulasekirin, RAWEST û SAVE bikirtînin.';

  @override
  String get gotIt => 'FÊHM KIR';

  @override
  String get speedTestHistory => 'DÎROKA TESTÊ';

  @override
  String get noSpeedTestHistory => 'Hêj test nehatiye tomar kirin. Testa yekem li jorê dest pê bike.';

  @override
  String get networkScoreLabel => 'PUANA TORÊ';

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

  @override
  String get dnsProtocol => 'PROTOCOL';

  @override
  String get dnsSsec => 'DNSSEC';

  @override
  String get dnsWhatIsThat => 'What is that?';

  @override
  String get dnsInfoHijackingTitle => 'DNS Hijacking';

  @override
  String get dnsInfoHijackingDesc => 'When your network provider or a malicious actor redirects your DNS queries to rogue servers. This allows them to monitor your activity or block certain websites.';

  @override
  String get dnsInfoLeakTitle => 'DNS Leak';

  @override
  String get dnsInfoLeakDesc => 'Even when using a VPN, your queries might bypass the secure tunnel and go to your ISP\'s servers. This \'leaks\' your browsing history to the network provider.';

  @override
  String get dnsInfoEncryptedTitle => 'Encrypted DNS (DoH/DoT)';

  @override
  String get dnsInfoEncryptedDesc => 'DNS over HTTPS (DoH) and DNS over TLS (DoT) wrap your queries in an encrypted layer. This makes your requests unreadable to local snoopers and network admins.';

  @override
  String get dnsInfoDnssecTitle => 'DNSSEC';

  @override
  String get dnsInfoDnssecDesc => 'DNS Security Extensions add cryptographic signatures to your queries. This prevents \'spoofing\' where a server sends you fake IP addresses for legitimate sites.';

  @override
  String get dnsInfoLatencyTitle => 'DNS Latency (RTT)';

  @override
  String get dnsInfoLatencyDesc => 'Round Trip Time (RTT) measures how long it takes for a query to travel to the server and back. Lower latency means faster web browsing and better performance.';

  @override
  String get dnsInfoResolverDriftTitle => 'DNS Resolver Drift';

  @override
  String get dnsInfoResolverDriftDesc => 'Detected when your DNS requests are being handled by different providers than configured, possibly due to transparent proxying or routing changes.';

  @override
  String get netInfoSsidTitle => 'SSID (Service Set Identifier)';

  @override
  String get netInfoSsidDesc => 'The public name of your Wi-Fi network. While common, it can be spoofed by attackers to lure you into connecting to a rogue access point.';

  @override
  String get netInfoBssidTitle => 'BSSID (Basic Service Set ID)';

  @override
  String get netInfoBssidDesc => 'The unique hardware address (MAC) of the wireless router. Useful for verifying that you are connected to the legitimate hardware and not a software clone.';

  @override
  String get netInfoGatewayTitle => 'Default Gateway';

  @override
  String get netInfoGatewayDesc => 'The local IP address of your router. All your traffic passes through this point. If this changes unexpectedly, it could indicate a Man-in-the-Middle attack.';

  @override
  String get dnsReadyStatus => 'READY FOR ASSESSMENT';

  @override
  String get dnsIdleDescription => 'Run a scan to verify DNS integrity and performance.';

  @override
  String get netSecInfoTitle => 'Network Security Module';

  @override
  String get netSecInfoDesc => 'Monitors the integrity of connected networks, detects rogue access points, and manages your trusted Wi-Fi profiles to protect against Evil Twin attacks.';

  @override
  String get spectrumOptimizationOpsSubtitle => 'Nirxandina kanalê · tevliheviyê';

  @override
  String get aboutSpectrumTitle => 'Optîmîzekirina Spektrumê Çi ye?';

  @override
  String get aboutSpectrumWhatHeader => 'Çi ye?';

  @override
  String get aboutSpectrumWhatBody => 'Cîhazên Wi-Fi bi rêya beşên frekansê yên bi navê \"kanal\" diaxivin. Bandê 2.4 GHz tenê 3 kanalên bi rastî ne-li-ser-hev hene (1, 6, 11) û herî gelemperî ye. Bandê 5 GHz pir kanalên zêdetir û tevliheviya kêmtir heye. Bandê herî nû 6 GHz (Wi-Fi 6E/7) di piraniya malan de hema bibêje vala ye.';

  @override
  String get aboutSpectrumWhyHeader => 'Bi kêrî çi tê?';

  @override
  String get aboutSpectrumWhyBody => 'Gava gelek tor heman kanalê parve dikin, divê dorê bigirin û her tişt hêdî dibe (Tevliheviya Heman Kanalê). Li 2.4 GHz, kanalên cîran jî li ser hev radikevin û dengê paşxaneyî çêdikin (Tevliheviya Kanalê Cîran). Hilbijartina kanaleke bêdeng rasterast lez, derengî û aramiya girêdanê baştir dike.';

  @override
  String get aboutSpectrumHowHeader => 'Çawa dixebite?';

  @override
  String get aboutSpectrumHowBody => 'Ev rûpel hemû torên Wi-Fi yên derdorê dişopîne û her kanalê li gorî hejmara torên hevrik, hêza sînyalê û li-ser-hev-ketina bi cîranan re ji 0 heya 10 puan dide. Kanalek bi rengê kesk (≥8) hilbijêre: ev kanal niha herî kêm gelemperî ye. Tabela Dîrokê nîşan dide ku kanal li ser demê paqij dimîne an na.';

  @override
  String get bandSpectrumTitle => 'Spektruma Kanalê';

  @override
  String get bandSpectrumInfoTitle => 'Spektruma Kanalê';

  @override
  String get bandSpectrumInfoBody => 'Her bar yek kanal e. Barên bilind û kesk bêdeng in; barên kurt û sor gelemperî ne. Li barekê bide ku puanê (0-10) bibînî. Her tora ku heman kanalê parve dike 2 puanan kêm dike (Tevliheviya Heman Kanalê); li 2.4 GHz torên kanalên cîran jî kêmtir kêm dikin (Tevliheviya Kanalê Cîran). Torên nêzîk û xurt bêtir tê cezakirin ji yên dûr û qels.';

  @override
  String get recommendationInfoTitle => 'Pêşniyaz Çawa Tê Kirin?';

  @override
  String get recommendationInfoBody => 'Her kanal ji 10 puanan dest pê dike. Tora bi heman kanalê her yek 2 puanan (×hêza sînyalê) kêm dike. Torên cîran ên 2.4 GHz li gorî mesafeyê 0.2-1.5 puanan kêm dikin. Kanalên DFS (parve bi radarê) 0.5 puanan winda dikin. Kanala bi puanê herî bilind serketî ye. Di rewşa wekheviyê de kanala bi hejmara biçûktir tê tercîhkirin.';

  @override
  String get consistentChannelInfoTitle => 'Kanala Herî Baş ya Berdewam';

  @override
  String get consistentChannelInfoBody => 'Wêneyek anî dikare şaşxistîner be: kanaleke ku niha bêdeng e dikare paşê gelemperî bibe. Em hemû şopandinên berê yên her kanalê navber dikin û ya ku bi awayekî berdewam puanê herî bilind digire diyar dikin. Heke ji pêşniyaza niha cuda be, kanala dîrokî ya aram bi gelemperî hilbijartineke ewletir e ji bo demê dirêj.';

  @override
  String get dfsBadgeLabel => 'DFS';

  @override
  String get dfsBadgeTooltip => 'DFS — bi radara hewa/leşkerî re tê parvekirin; routerê dibe ku ji vê kanalê demek kurt derkeve';

  @override
  String get dfsInfoTitle => 'DFS Çi ye?';

  @override
  String get dfsInfoBody => 'Kanalên DFS (Dynamic Frequency Selection) di bandê 5 GHz de (52-64 û 100-144) bi awayekî yasayî bi radarên hewa û leşkerî re têne parvekirin. Wi-Fi divê pêşîniyê bide van radaran: heke router lêgerîna radarê tespît bike, divê herî kêm 60 çirkeyan ji kanalê derkeve — cihazên we demek kurt qut dibin û diçin ser kanaleke din. Kanalên DFS bi gelemperî kêm gelemperî ne (loma puanê wan bilind e), lê li nêzîkê balafirgehan, bendergehan an stasyonên hewa dikarin nêbawer bin. Em ji bo nîşandana vê metirsiyê 0.5 puanan kêm dikin. Heke çavkaniya radarê nêzîk tune be wan bikar bînin; an na, ji wan dûr bikevin.';

  @override
  String get howToChangeChannelTitle => 'Kanalê Wi-Fi çawa biguherînim?';

  @override
  String get howToChangeChannelSubtitle => 'Rêbera gav-bi-gav ji bo routera te';

  @override
  String get guideConnectedTo => 'Tora girêdayî';

  @override
  String get guideRouterVendor => 'Marka routerê';

  @override
  String get guideRouterUnknown => 'Nenas — rêbera giştî tê nîşandan';

  @override
  String get guideStep1 => 'Gav 1 · Panela rêveberiyê veke';

  @override
  String get guideStep1Body => 'Bişkoja VEKE ya jêr bitikîne — gerokê te yê standard di rûpela rêveberiya routerê de vedibe. (An jî navnîşanê kopî bike û destî bispêre.) Ji bo navnîşan bixebite, divê li vê Wi-Fi ve girêdayî bî; tenê bi daneya mobîl nagihîje.';

  @override
  String get guideOpenInBrowser => 'Veke';

  @override
  String get guideOpenFailedMessage => 'Gerokê bixweber venebû — navnîşanê kopî bike û destî bispêre.';

  @override
  String get guideCredentialsHeader => 'Navê bikarhêner û şîfre';

  @override
  String get guideCredentialsBody => 'Gava rûpela rêveberiyê ji te têketinê dixwaze:\n\n1. Li binî an pişta routerê binêre — bi gelemperî li wir etîketek heye ku şîfreya Wi-Fi û her wiha agahiyên têketina REVEBERIYÊ jî dinivîse. Têketina rêveberiyê wek \"Admin password\", \"Web password\", \"Modem password\" an \"Şîfreya Rêveberiyê\" tê nîşandan. Ev bi şîfreya Wi-Fi NEYAN E.\n\n2. Heke etîket tune be, van standardên fabrîkayê biceribîne:\n   • admin / admin\n   • admin / password\n   • admin / 1234\n   • root / admin\n   • Navê bikarhêner vala / şîfre admin\n\n3. Heke router ji aliyê pêşkêşkarê înternetê hatibe sazkirin, şîfreya rêveberiyê bi gelemperî 6-8 karakterên dawî yên seriya cihazê ye, ku ew jî li ser etîketê dinivîse. Gelek pêşkêşkar şîfreyek taybet a cihazî çap dikin.\n\n4. Heke tu yek nexebite, kesek berê şîfre guherandî ye. Dikarî bişkoja RESET ya li pişta routerê 10-15 çirkeyan bigirî da ku rewşa fabrîkayê vegere — lê ev navê Wi-Fi û şîfreya wê jî paqij dike, divê ji nû ve saz bikî.\n\n5. Hin routerên nû panela web bi sepanê telefonê re diguherînin (mînak TP-Link Tether, ASUS Router, Mi WiFi, Huawei AI Life). Heke rûpela web te ber bi sazkirina sepanê ve dişîne, sepanê saz bike û ji wir berdewam bike.';

  @override
  String get guideAddressLabel => 'Navnîşana rêveberiyê';

  @override
  String get guideCopyAddress => 'Kopî bike';

  @override
  String get guideAddressCopied => 'Navnîşan hate kopîkirin — di gerokê de veke';

  @override
  String get guideStep2 => 'Gav 2 · Menûya Wi-Fi / Wireless bibîne';

  @override
  String get guideStep2Body => 'Piştî têketinê li menûyek bi navê Wi-Fi, Wireless an Mîhengên Torê bigere. Marka cuda navên cuda dikin — rêya jêrîn ji bo marka te ye:';

  @override
  String get guideStep3 => 'Gav 3 · Kanalê saz bike û bisepîne';

  @override
  String get guideStep3Body => 'Bijareya Channel/Kanal bibîne. Auto-yê biguhêre bo kanala pêşniyazkirî di ekrana berê de. Heke routerê te ji bo 2.4 GHz û 5 GHz cuda nîşan dide, ji bo her bandê kanala xwe ya pêşniyazkirî saz bike. Tê tomarkirin/sepandinê bitikîne. Wi-Fi dê demek kurt ji nû ve dest pê bike.';

  @override
  String get guideMenuPathLabel => 'Riya menûyê';

  @override
  String get guideGenericMenuPath => 'Wireless / Wi-Fi → Bingehîn / Pêşkeftî Mîheng → Kanal';

  @override
  String get channelWidthHeader => 'Pehnatiya kanalê — 20 / 40 / 80 / 160 MHz';

  @override
  String get channelWidthBody => 'Pehnatiya kanalê wek hejmara şiritan a otoyolê ye:\n• 20 MHz = 1 şirit. Hêdî lê li hember trafîkê bi hêz. Ji bo 2.4 GHz a tijî baştirîn.\n• 40 MHz = 2 şirit. Du qatî leza daneyan, lê bi cîranan re zêdetir li hev radikeve.\n• 80 MHz = 4 şirit. Lez — tenê di 5 GHz/6 GHz de.\n• 160 MHz = 8 şirit. Lezê herî bilind, lê nîvê bandê 5 GHz digire; tenê heke cîran tune be watedar e.\n\nQayîdeya giştî: di 2.4 GHz de 20 MHz; di 5 GHz de 80 MHz; di 6 GHz de heke berdest be 160 MHz.';

  @override
  String get guideRisksHeader => 'Guhertina kanalê ewle ye?';

  @override
  String get guideRisksBody => 'Erê — bi tevahî ewle ye. Guhertina kanalê ji bilî qutbûnek 5-10 çirkeyî ya ku dema router radio ji nû ve dest pê dike çêdibe, hîç bandorek ewlehiyê an performansê tune. Navê torê (SSID), şîfre, qaîdeyên port-yönlendirmeyê, kontrolên dêûbavî û her mîhengek din çawa hebû dimîne. Cihazên girêdayî bixweber ji nû ve têne girêdan. Heke paşê tişt xerabtir xuya bike, dikarî ji heman menûyê vegerî ser Auto û router bi xwe kanalek hilbijêre.';

  @override
  String get guideNoConnection => 'Bi tora Wi-Fi ve ne girêdayî yî — ji bo dîtina navnîşana rêveberiyê û rêbera taybet a markeyê pêşî girê bide.';

  @override
  String get currentChannelLabel => 'NIHA';

  @override
  String currentChannelBannerYouAreOn(String channel) {
    return 'Niha li ser $channel yî';
  }

  @override
  String currentChannelBannerSwitchTo(String channel, String delta) {
    return 'Ji bo +$delta puan biçe ser $channel';
  }

  @override
  String get currentChannelBannerOptimal => 'Tu jixwe li ser kanala pêşniyazkirî yî';

  @override
  String get spectrumOverlapTitle => 'Li-ser-hev-ketina Toran';

  @override
  String get spectrumOverlapInfoTitle => 'Li-ser-hev-ketina Toran';

  @override
  String get spectrumOverlapInfoBody => 'Her şeklê rengîn yek tora Wi-Fi ye. Cihê wê li ser axa X frekansa navendê nîşan dide, fireh̥iya wê pehnatiya kanalê (20/40/80/160 MHz), bilindahî jî hêza sînyalê (jor = xurt, jêr = qels). Cihên ku şekl li ser hev radikevin, ew tor heman dema weşanê parve dikin û hev hêdî dikin. Li firehîyek dîkî ku tê de tu şekil tune (an jî tenê yên qels li jêr) bigere — ew kanaleke bêdeng e. Li şeklekê bide ku tora wê bibînî.';

  @override
  String get spectrumOverlapEmptyHint => 'Li ser vî bandî tor xuya nake';

  @override
  String get channelDrilldownHeader => 'Torên li ser vê kanalê';

  @override
  String get channelDrilldownEmpty => 'Li vir tor weşanê nake';

  @override
  String get hiddenSsidPlaceholder => '<tora veşartî>';

  @override
  String scanComparisonImproved(String delta) {
    return 'Li gor şopandina dawî $delta puan baştir bûye';
  }

  @override
  String scanComparisonWorsened(String delta) {
    return 'Li gor şopandina dawî $delta puan xirabtir bûye';
  }

  @override
  String get scanComparisonStable => 'Ji şopandina dawî vir ve aram';

  @override
  String get countryAllowlistHeader => 'Herêm';

  @override
  String get countryAllowlistInfoBody => 'Kanalên Wi-Fi li her welatî bi awayekî cuda têne rêvebirin. Kanalên ku li herêma we qedexe ne kêmreng têne nîşandan û ji aliyê routerê we nayên bikaranîn. Heke li derveyê welêt bî, herêmê biguherîne — pêşniyaz tenê kanalên yasayî yên herêma hilbijartî nîşan dide.';

  @override
  String get channelIllegalBadge => 'QEDEXEYÎ';

  @override
  String get channelIllegalTooltip => 'Ev kanal li herêma hilbijartî ji bo Wi-Fi yasayî nîne.';

  @override
  String get regionUS => 'Dewletên Yekgirtî';

  @override
  String get regionEU => 'Ewropa / Tirkiye';

  @override
  String get regionJP => 'Japonya';

  @override
  String get regionWorld => 'Cîhan (kêmtirîn sînor)';

  @override
  String get hourlyHeatmapTitle => 'Kanala herî baş li gor saetê';

  @override
  String get hourlyHeatmapInsufficient => 'Dîroka bes têrê nake. Vê ekranê di saetên cuda yên rojê de veke ku rêjeya saetan ava bibe.';

  @override
  String get afcInfoTitle => 'Sinifên Hêza 6 GHz (AFC)';

  @override
  String get afcInfoBody => 'Wi-Fi 6 GHz dabeşbûyî sê sînifên hêzê ye:\n\n• LPI (Hêza Kêm a Hindurîn) — Pêşbinîn ji bo routerên malê. Heya 30 dBm EIRP, tenê di hindurê de yasayî ye. Koordînasyona cihê ne hewce ye.\n\n• Standard Power (SP) — Derve û hindurê hêza bilind. Heya 36 dBm. AFC (Koordînasyona Frekansa Otomatîk) hewce dike: router cihê GPS xwe ji databasaya rêveberiyê re dişîne û tê gotin ka kîjan kanal ji bikarhênerên niştecîh (uplink satelîtî, lînkên mîkrowave) vala ne.\n\n• VLP (Hêza Pir Kêm) — Bikaranîna mobîl, heya 14 dBm. Koordînasyon ne hewce ye lê dûrahiya wê pir kurt e; piranî ji bo AR/VR û laptopan.\n\nPiraniya torên malê tenê LPI dibînin; eger li derve îşareta xurt a 6 GHz bibînî, mimkun e ku ew SP û bi AFC hatî koordîne kirin be.';

  @override
  String get advancedTopicsHeader => 'Mijarên pêşkeftî';

  @override
  String get advancedMeshTitle => 'Mesh û geştûgeşt (roaming)';

  @override
  String get advancedMeshBody => 'Di tora mesh de (Google Nest, Eero, TP-Link Deco hwd.) tu kanalê bi destan hilnabijêrî — kontrolker ji bo her girêkê kanalek hildibijêre û gava cîran diguherin ji nû ve dibalans dike. Hin kontrolker overrideya ji bo girêka îstîsna pêşkêş dikin; lê moda otomatîk bi gelemperî baştir e, ji ber ku sîstem tevliheviya navbera girêkên mesh jî dipîve. Heke pêwîst bibe, radyoya pêş (a aliyê xerîdar) ya girêka sereke saz bike ser kanala pêşniyazkirî û radyoya paş (girêk-girêk) bila otomatîk bimîne.';

  @override
  String get advancedBandSteeringTitle => 'Band steering & yek SSID an du';

  @override
  String get advancedBandSteeringBody => 'Routerên nû band-steering pêşkêş dikin: yek SSID ji bo hem 2.4 hem 5 GHz, router cihazên kapasîteyî dixe nav 5 GHz. Erêniyên: hêsan, cihaz bi awayekî otomatîk diguhere. Neyîniyên: hin cihazên IoT (priz, kamera) tenê 2.4 GHz dibînin; gava router wê bandê di dema steeringê de veşêre nikare têkeve. Çareya temerî: SSID-an cuda bike (mînak \"MalaMin\" li ser 5 GHz, \"MalaMin-IoT\" li ser 2.4 GHz) ji bo sazkirinê û paşê heke bixwazî bike yek.';

  @override
  String get advancedWmmTitle => 'WMM / QoS';

  @override
  String get advancedWmmBody => 'WMM (Wi-Fi Multimedia) trafîkê dabeş dike li 4 sinifan: deng, vîdyo, normal, paşxane. Ji bo sertîfîkayê Wi-Fi 4+ pêwîst e û divê her dem vekirî bimîne. Vegirtinê leza te tixûb dike li 802.11g (~54 Mbps). Kanal ne dibe ku WMM bandor bike, lê kanaleke paqij hemû 4 sinifan bi hev re baştir dike.';

  @override
  String get dfsCacWarning => '⚠ Kanala DFS: gava router biçe vê kanalê, divê 60 çirkeyan bêdeng guhdarî bike (Channel Availability Check) berî ku weşanê dest pê bike. Di vê demê de Wi-Fi nayê bikaranîn.';

  @override
  String get densityTrendStable => 'Pestoya aram';

  @override
  String densityTrendVolatile(String delta) {
    return 'Herêma guherbar · di saeta dawî de pestoy $delta tor heng kir';
  }

  @override
  String get routerGroupsHeader => 'Routerên nêzîk (du-band)';

  @override
  String get routerGroupsInfoBody => 'Gava heman router heman SSID li ser ji yek bandê zêdetir weşan dike (mînak 2.4 GHz CH 6 û 5 GHz CH 36), em wan li vir kom dikin da ku tu her du radyoyan bera ya hev bidî. Bişkokek bandê bide ku biçî wê tabê.';

  @override
  String crossBandSiblingHint(String band, String channel, String rating) {
    return 'Heman router li ser $band CH $channel · $rating/10';
  }

  @override
  String get connectedChannelGuideLabel => 'TU';

  @override
  String get unstableChannelLabel => 'NEARAM';

  @override
  String get unstableChannelTooltip => 'Puanê vê kanalê di rûniştinên dawî de ji 1.5 puanan zêdetir guherî';

  @override
  String get historyHeatmapInfoTitle => 'Nexşeya Germayê Çi ye?';

  @override
  String get historyHeatmapInfoBody => 'Her rêz kanalek e û her stûn demek e ku te şopandin kir. Rengê hucreyê puanê wê demê nîşan dide: sor (xirab) → zer (orte) → kesk (zehf baş). Hucreyên vala wateya wê ye ku kanal di wê şopandinê de nediyar bû. Li rêzên temamî kesk bigere — ev ew kanal in ku bi demê re paqij dimînin.';

  @override
  String get clearChannelHistoryTitle => 'DÎROKA KANALÊ PAQIJ BIKE';

  @override
  String get clearChannelHistoryConfirmBody => 'Hemû tomarên puanê kanalê werin jêbirin? Ev nayê vegerandin.';

  @override
  String get deleteAllLabel => 'HEMÛ JÊBIBE';

  @override
  String get dualBandSiblingLabel => 'DU-BAND';

  @override
  String dualBandSiblingBanner(String band, String channel) {
    return 'Radyoya $band ya routera te: $channel';
  }

  @override
  String get acknowledgedLabel => 'TÊGEHIŞTÎ';

  @override
  String get speedDoctorTitle => 'DOKTORÊ LEZ';
  @override
  String get speedDoctorTagline => 'Çima înternet hêdî ye?';
  @override
  String get speedDoctorOpsTile => 'DOKTORÊ LEZ';
  @override
  String get speedDoctorOpsSubtitle => 'Çima hêdî ye?';
  @override
  String get evilTwinDetailTitle => 'BÊTIRA EVIL TWIN';
}
