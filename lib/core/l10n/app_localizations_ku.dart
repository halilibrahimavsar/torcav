// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kurdish (`ku`).
class AppLocalizationsKu extends AppLocalizations {
  AppLocalizationsKu([String locale = 'ku']) : super(locale);

  @override
  String get appName => 'TORCAV';

  @override
  String get subscriptionPremium => 'Premium';

  @override
  String get deviceTypeRouterGateway => 'Router/Gateway';

  @override
  String get deviceTypeAccessPoint => 'Access Point';

  @override
  String get deviceTypeDesktop => 'Desktop';

  @override
  String get deviceTypeLaptop => 'Laptop';

  @override
  String get deviceTypeMobileDevice => 'Mobile Device';

  @override
  String get deviceTypeTablet => 'Tablet';

  @override
  String get deviceTypeSmartTV => 'Smart TV';

  @override
  String get deviceTypeNASStorage => 'NAS/Storage';

  @override
  String get deviceTypeGameConsole => 'Game Console';

  @override
  String get deviceTypeIPCamera => 'IP Camera';

  @override
  String get deviceTypeSmartSpeaker => 'Smart Speaker';

  @override
  String get deviceTypeServer => 'Server';

  @override
  String get deviceTypeUnknown => 'Unknown';

  @override
  String get notificationOpenAction => 'Open notification';

  @override
  String get quickScan => 'Tarana Bilez';

  @override
  String get deepScan => 'Tarana Kûr';

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
  String get latestSnapshotTitle => 'Wêneyê Dawî ya Torê';

  @override
  String get noSnapshotAvailable => 'Daneyên wêneyê tune...';

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
  String bandwidthLabel(int width) {
    return '$width MHz';
  }

  @override
  String get wifiStandardLegacy => 'Wi-Fi (legacy)';

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
  String get deviceTypeWorkstation => 'Workstation';

  @override
  String get deviceTypePrinterIoT => 'Printer/IoT';

  @override
  String get vendorAndroidRestricted => 'Android Device (Restricted)';

  @override
  String get vendorAndroidLimited => 'Unknown (Android Limited)';

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
  String get lanReconTitle => 'LAN RECON';

  @override
  String get targetSubnet => 'Subnet / IP Target';

  @override
  String get scanAllCaps => 'TARA';

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
  String get trafficLabel => 'TRAFÎK';

  @override
  String get normalSpeed => 'NORMAL';

  @override
  String get fastSpeed => 'BILEZ';

  @override
  String get overdriveSpeed => 'OVERDRIVE';

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
  String get backgroundAegisShield => 'Mertala Aegis';

  @override
  String get backgroundSignalTopography => 'Topografyaya Sînyalê';

  @override
  String get backgroundQuantumMesh => 'Tora Kuantûmî';

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
  String get knownNetworks => 'Torên Nas';

  @override
  String get noIdentifiedNetworks => 'No identified networks in laboratory archives';

  @override
  String get securityTimeline => 'Rêzika Demê ya Ewlehiyê';

  @override
  String get noSecurityEvents => 'Tu bûyerên ewlehiyê nehatine tomarkirin';

  @override
  String get dnsSecurityTitle => 'DNS INTEGRITY';

  @override
  String get dnsPerformanceBenchmark => 'PERFORMANCE BENCHMARK';

  @override
  String get dnsRecommended => 'RECOMMENDED';

  @override
  String dnsResultLatency(int ms) {
    return '$ms ms';
  }

  @override
  String get osNetworkDevice => 'Network Device (TTL≈255)';

  @override
  String get osWindows => 'Windows (TTL≈128)';

  @override
  String get osLinuxMacOS => 'Linux / macOS (TTL≈64)';

  @override
  String get osUnknown => 'Unknown OS';

  @override
  String get osDetectedLabel => 'OS DETECTED';

  @override
  String portLabel(int port) {
    return 'PORT $port';
  }

  @override
  String get portsFoundLabel => 'OPEN PORTS';

  @override
  String get noPortsFound => 'No open ports found';

  @override
  String get hostnameLookupAction => 'LOOKUP HOSTNAME';

  @override
  String get osDetectAction => 'OS DETECT';

  @override
  String get portScanAction => 'PORT SCAN';

  @override
  String get portRangeHint => 'Port range (e.g. 80,443 or 1-1000)';

  @override
  String get latencyLabel => 'DERENGÎ';

  @override
  String get hostnameLabel => 'HOSTNAME';

  @override
  String get filterAll => 'ALL';

  @override
  String get filterCore => 'CORE';

  @override
  String get filterMobile => 'MOBILE';

  @override
  String get filterIot => 'IOT';

  @override
  String get filterOther => 'OTHER';

  @override
  String get authLocalSystem => 'AUTH_SÎSTEMA_XWECÎHÎ';

  @override
  String remoteNodeIdLabel(String id) {
    return 'REMOTE_NODE_ID: $id';
  }

  @override
  String logIdLabel(String id) {
    return 'LOG_ID: $id';
  }

  @override
  String targetLabel(String target) {
    return 'TARGET: $target';
  }

  @override
  String get dnsStatusPending => 'PENDING';

  @override
  String get dnsStatusNotAssessed => 'NOT ASSESSED';

  @override
  String get dnsStatusInconsistent => 'INCONSISTENT';

  @override
  String get dnsStatusEnabled => 'ENABLED';

  @override
  String get dnsStatusDisabled => 'DISABLED';

  @override
  String get notAvailableCaps => 'N/A';

  @override
  String get evilTwinSignalOuiMismatch => 'The two access points come from different hardware vendors (MAC prefixes don\'t match).';

  @override
  String get evilTwinSignalSecurityDowngrade => 'The pair advertises different encryption — typical of a downgrade attack (e.g. real network = WPA3, fake = WPA2 or Open).';

  @override
  String get evilTwinSignalSameBandChannelDrift => 'Both broadcast on the same frequency band but on very different channels — real radios rarely jump that far.';

  @override
  String get evilTwinSignalChannelWidthMismatch => 'They use different channel widths (e.g. 80 MHz vs 20 MHz). Cheap rogue hardware often runs narrower than the device it\'s copying.';

  @override
  String get evilTwinSignalWpsToggleMismatch => 'WPS is enabled on one access point but not the other.';

  @override
  String get evilTwinSignalPmfToggleMismatch => 'Protected Management Frames (802.11w) are enabled on one side but not the other.';

  @override
  String get evilTwinSignalHiddenVsVisible => 'One access point is hidden, the other broadcasts its name openly.';

  @override
  String get evilTwinSignalSharedMldMac => 'Both share the same Wi-Fi 7 multi-link MAC — they are literally the same physical access point.';

  @override
  String get evilTwinSignalBssidProximity => 'Their MAC addresses differ only in the last digits — manufacturers use that pattern for radios on the same router.';

  @override
  String get evilTwinSignalCrossBandSibling => 'They sit on different Wi-Fi bands (2.4 / 5 / 6 GHz) but share the same vendor and security — classic dual-band router pattern.';

  @override
  String get evilTwinSignalKnownMeshVendor => 'Both MAC addresses belong to a known mesh-router family (Eero, Google Nest, Asus AiMesh, Netgear Orbi, TP-Link Deco, or Linksys Velop). Mesh nodes share the same Wi-Fi name on purpose.';

  @override
  String get evilTwinSafeHeadline => 'Looks like the same router on different bands';

  @override
  String get evilTwinSafeWhatIs => 'Most home routers broadcast the same Wi-Fi name (SSID) over 2.4 GHz, 5 GHz and sometimes 6 GHz. Your phone sees them as separate access points even though they\'re one device. Mesh systems work the same way — every node uses one shared name.';

  @override
  String get evilTwinSafeWhyItMatters => 'This pairing is normal and expected — no action needed. We show this here only so you know we checked and ruled it out.';

  @override
  String get evilTwinSafeAction => 'Nothing to do. This is the same router or part of your mesh.';

  @override
  String get evilTwinSafePhrase => 'We checked this pair and it matches the pattern of a normal dual-band router or mesh — not an attack.';

  @override
  String get evilTwinNoPatternHeadline => 'No evil-twin pattern detected';

  @override
  String get evilTwinNoPatternAction => 'Nothing urgent. Re-run a scan if you suspect something has changed in your environment.';

  @override
  String get evilTwinNoPatternPhrase => 'Some minor differences exist between the access points sharing this name, but not enough to look like an attack.';

  @override
  String get evilTwinWhatIs => 'An \"evil twin\" is a fake Wi-Fi network that copies the name of a real one — usually your home or workplace network, or a popular café hotspot. The goal is to make your phone connect to the attacker\'s router instead of the real one.';

  @override
  String get evilTwinWhyItMatters => 'Once your device is on the attacker\'s Wi-Fi, they can read or tamper with traffic that isn\'t encrypted, push fake login pages, redirect you to look-alike websites, or capture passwords typed into apps that don\'t use HTTPS properly. Banking, email and messaging are the usual targets.';

  @override
  String get evilTwinHighHeadline => 'Strong evil-twin pattern — treat this network as untrusted';

  @override
  String get evilTwinMediumHeadline => 'Suspicious twin pattern — verify before connecting';

  @override
  String get evilTwinLowHeadline => 'Weak twin signal — keep an eye on this';

  @override
  String evilTwinHighPhrase(int pct) {
    return 'Confidence: $pct%. Multiple strong mismatches between the two access points using this name. This is the pattern an attacker creates when impersonating a Wi-Fi.';
  }

  @override
  String evilTwinMediumPhrase(int pct) {
    return 'Confidence: $pct%. Several details don\'t line up between the access points sharing this name. It might be benign, but verify before trusting it.';
  }

  @override
  String evilTwinLowPhrase(int pct) {
    return 'Confidence: $pct%. A couple of small mismatches noticed. Most likely benign — flagged so you can double-check.';
  }

  @override
  String get evilTwinActionPasswords => 'Don\'t enter passwords, payment details, or two-factor codes while connected to this Wi-Fi.';

  @override
  String get evilTwinActionCheckMac => 'If you\'re at home, check the actual MAC (BSSID) printed under your router and compare it with the BSSIDs shown for this network.';

  @override
  String get evilTwinActionForgetNetwork => 'Forget the network in your phone\'s Wi-Fi settings and only reconnect by hand to the BSSID you\'ve verified.';

  @override
  String get evilTwinActionSecurityDowngrade => 'One of the two access points uses weaker encryption than the other. Always pick the stronger one (WPA3 over WPA2 over Open).';

  @override
  String get evilTwinActionDisconnectNow => 'Disconnect from this Wi-Fi now and switch to mobile data until you can verify which BSSID is the real one.';

  @override
  String get evilTwinActionHardwareVendor => 'The two routers come from different hardware vendors — your real router shouldn\'t suddenly change manufacturer.';

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
  String get cancel => 'Betal bike';

  @override
  String get save => 'Tomar bike';

  @override
  String get waitingForData => 'Li benda daneyan e...';

  @override
  String get temporalHeatmap => 'Nexşeya Germiyê ya Demkî';

  @override
  String signalMonitoringTitle(String ssid) {
    return 'ŞOPANDINA SÎNYALÊ: $ssid';
  }

  @override
  String get heatmapTooltip => 'Nexşeya Germiyê';

  @override
  String get signalCaps => 'SÎNYAL';

  @override
  String get channelCaps => 'KANAL';

  @override
  String get frequencyCaps => 'FREKANS';

  @override
  String errorPrefix(String message) {
    return 'Şaşî: $message';
  }

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
  String get riskFactorHoneypotPattern => 'SSID matches known honeypot pattern';

  @override
  String get riskFactorNo5Ghz => 'No 5 GHz band detected';

  @override
  String get riskFactorKnownVulnerability => 'Known hardware vulnerability';

  @override
  String get riskFactorEvilTwinCandidate => 'Evil twin candidate sharing this SSID';

  @override
  String get riskFactorChannelCongested => 'Channel is heavily congested';

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
  String get phasePing => 'QONAX: PING';

  @override
  String get phaseDownload => 'QONAX: DAXISTIN';

  @override
  String get phaseUpload => 'QONAX: BARKIRIN';

  @override
  String get phaseDone => 'QONAX: TEMAM';

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
  String get dnsProtocol => 'PROTOCOL';

  @override
  String get dnsSsec => 'DNSSEC';

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

  @override
  String get pingStabilizerTitle => 'STABÎLÎZATORÊ PING';

  @override
  String get pingStabilizerSubtitle => 'Tunela derengmayînê ya li ser cîhazê';

  @override
  String get pingStabilizerToggleHint => 'Bide bo stabîlîzekirinê';

  @override
  String get pingStabilizerDrawerLabel => 'Stabîlîzatorê Ping';

  @override
  String get onboardingStartScanning => 'START SCANNING';

  @override
  String get onboardingNext => 'NEXT';

  @override
  String get onboardingWelcomeTitle => 'WELCOME TO TORCAV';

  @override
  String get onboardingWelcomeBody => 'A cyberpunk Wi-Fi analyzer that helps you understand your wireless environment, find the best channel, and detect security threats.';

  @override
  String get onboardingLocationTitle => 'LOCATION PERMISSION';

  @override
  String get onboardingLocationBody => 'Android requires Location permission to scan for Wi-Fi networks. To show signal heatmaps, we also use activity sensors. All data stays on your device and is never uploaded. Your location is only used to read nearby Wi-Fi signals.';

  @override
  String get onboardingNotificationsTitle => 'HIŞYARÎYÊN EWLEHIYÊ';

  @override
  String get onboardingNotificationsBody => 'Gava ku Torcav bûyerek ewlehiyê di tora we de tespît bike agahdar bibin — xalên gihîştinê yên cêwiyê, portên vekirî, revandina DNSê. Hemû hişyarî li ser amûrê têne çêkirin; tu daneyek nayê şandin ser servereke.';

  @override
  String get onboardingNotificationsEnable => 'Hişyariyan çalak bike';

  @override
  String get onboardingNotificationsSkip => 'Niha derbas bike';

  @override
  String get onboardingTourTitle => 'THREE TABS';

  @override
  String get onboardingTourDashboardLabel => 'Dashboard';

  @override
  String get onboardingTourDashboardDesc => 'Live overview of your network health';

  @override
  String get onboardingTourDiscoveryLabel => 'Discovery';

  @override
  String get onboardingTourDiscoveryDesc => 'Scan Wi-Fi networks and LAN devices';

  @override
  String get onboardingTourOperationsLabel => 'Operations';

  @override
  String get onboardingTourOperationsDesc => 'Security analysis, speed tests, reports';

  @override
  String get onboardingContextTitle => 'WHERE WILL YOU USE TORCAV?';

  @override
  String get onboardingContextBody => 'This shapes how strict the security score is when we can\'t tell on our own. You can change it any time, and it can be overridden per network later.';

  @override
  String get onboardingContextHomeTitle => 'Mostly my own home / office';

  @override
  String get onboardingContextHomeBody => 'Strict scoring. Any unexpected change in encryption or new devices on the LAN gets flagged loudly.';

  @override
  String get onboardingContextPublicTitle => 'Mostly cafés / hotels / airports';

  @override
  String get onboardingContextPublicBody => 'Relaxed scoring on encryption (these networks are often open) but heightened sensitivity to lure SSIDs and evil-twin patterns. Active LAN scanning is suppressed by default.';

  @override
  String get onboardingContextGuestTitle => 'Mostly guest / shared networks';

  @override
  String get onboardingContextGuestBody => 'Same Wi-Fi as friends, family, or coworkers. Drift is expected; we don\'t alert on every new device.';

  @override
  String get onboardingContextUnknownTitle => 'Not sure yet';

  @override
  String get onboardingContextUnknownBody => 'No strong default. We\'ll guess from each network\'s fingerprint and let you correct it.';

  @override
  String get onboardingDoneTitle => 'ALL SET';

  @override
  String get onboardingDoneBody => 'Torcav is a privacy-first network assistant. It provides safe network diagnostics and hardening tools for networks you own or are authorized to assess. No data is collected or transmitted externally.';

  @override
  String get onboardingAcceptPrefix => 'I have read and accept the ';

  @override
  String get onboardingTosLink => 'Terms of Service';

  @override
  String get onboardingAcceptAnd => ' and ';

  @override
  String get onboardingPrivacyLink => 'Privacy Policy';

  @override
  String get onboardingAcceptSuffix => '.';

  @override
  String get onboardingConfirmPermission => 'I confirm I have permission to scan the networks I will analyze.';

  @override
  String get onboardingConfirmAge => 'I confirm I am 13 years of age or older.';

  @override
  String get appTitle => 'TORCAV';

  @override
  String get ssidLabel => 'SSID';

  @override
  String get noSecurityFindings => 'No security findings detected.';

  @override
  String get resetToInferred => 'Reset to inferred';

  @override
  String get internetSlowQuestion => 'IS INTERNET SLOW?';

  @override
  String get runSpeedDoctorDesc => 'Run Speed Doctor — 30-second root-cause diagnostic.';

  @override
  String get securityAlertsTitle => 'SECURITY ALERTS';

  @override
  String get markAllRead => 'MARK ALL READ';

  @override
  String get clearAll => 'CLEAR ALL';

  @override
  String get eventsRetentionInfo => 'Events are retained for 30 days. Swipe left to dismiss.';

  @override
  String get allSystemsClear => 'All systems clear';

  @override
  String get heuristicDetectionNote => 'Heuristic detection — not a confirmed attack. False positives may occur in congested environments.';

  @override
  String get markAsRead => 'MARK AS READ';

  @override
  String get eventTypeRogueAp => 'ROGUE AP';

  @override
  String get eventTypeEvilTwin => 'EVIL TWIN';

  @override
  String get eventTypeDeauthAttack => 'DEAUTH ATTACK';

  @override
  String get eventTypeEncryptionWeakened => 'ENCRYPTION WEAKENED';

  @override
  String get eventTypeDeauthBurst => 'DEAUTH BURST';

  @override
  String get eventTypeHandshakeAnalysis => 'HANDSHAKE ANALYSIS';

  @override
  String get eventTypeHandshakeSecured => 'HANDSHAKE SECURED';

  @override
  String get eventTypeCaptivePortal => 'CAPTIVE PORTAL';

  @override
  String get eventTypeUnsupported => 'UNSUPPORTED';

  @override
  String get eventTypeArpSpoofing => 'ARP SPOOFING';

  @override
  String get eventTypeDnsHijacking => 'DNS HIJACKING';

  @override
  String get agentId => 'AGENT-01';

  @override
  String cyberneticId(String id) {
    return 'CYBERNETIC_ID: $id';
  }

  @override
  String subscriptionLabel(String type) {
    return 'Sub: $type';
  }

  @override
  String deepScanSuppressed(String context) {
    return 'Deep scan suppressed — connected to a $context network. Disable the safety guard in Settings to override.';
  }

  @override
  String get securityAssessmentFailed => 'SECURITY ASSESSMENT FAILED';

  @override
  String get retryAnalytics => 'RETRY ANALYTICS';

  @override
  String get publicContextLabel => 'public';

  @override
  String get guestContextLabel => 'guest';

  @override
  String get clearScanHistoryTitle => 'CLEAR SCAN HISTORY';

  @override
  String get clearScanHistoryBody => 'Delete all LAN scan records? This cannot be undone.';

  @override
  String get cancelLabel => 'CANCEL';

  @override
  String get networkAuditConsentTitle => 'NETWORK AUDIT CONSENT';

  @override
  String get networkAuditConsentDesc => 'Active network scanning generates traffic to identify devices and services. This may be flagged by network security systems.';

  @override
  String get consentScanNodes => 'Scan local network for active nodes';

  @override
  String get consentFingerprint => 'Fingerprint open services and OS';

  @override
  String get consentIdentifyVulns => 'Identify potential vulnerabilities';

  @override
  String get consentConfirmAuth => 'Confirm you have authorization for this network';

  @override
  String get iUnderstand => 'I UNDERSTAND';

  @override
  String get iosLanDiscoveryLimited => 'iOS: LAN discovery is limited. mDNS browsing and ARP table access may be restricted by the OS.';

  @override
  String get androidLanVendorLimited => 'Android limits LAN MAC access. Vendor names may only appear for the router/gateway; other devices are identified by IP, hostname and services when available.';

  @override
  String get vendorUnavailableAndroid => 'Vendor unavailable: Android does not expose this device\'s LAN MAC address to apps.';

  @override
  String get speedDoctorLongDesc => 'Runs signal, channel, speed and DNS probes in ~30 seconds and tells you which link in the chain is the bottleneck.';

  @override
  String get startDiagnosis => 'START DIAGNOSIS';

  @override
  String get speedDoctorQuotaWarning => 'Heads up: a real speed test downloads ~300–500 MB. Use Wi-Fi or an unmetered connection to avoid burning your mobile quota.';

  @override
  String get evidenceLabel => 'EVIDENCE';

  @override
  String get runAgain => 'RUN AGAIN';

  @override
  String get aboutSpeedDoctorTitle => 'ABOUT SPEED DOCTOR';

  @override
  String get sdAboutWhatTitle => 'What is it?';

  @override
  String get sdAboutWhatBody => 'A one-tap diagnostic that finds the likely bottleneck between you and the internet — without you having to compare numbers across separate screens.';

  @override
  String get sdAboutHowTitle => 'How does it work?';

  @override
  String get sdAboutHowBody => 'Five short probes run end-to-end and the results are compared against published thresholds:';

  @override
  String get sdAboutHowBullet1 => 'Signal — reads RSSI from the connected access point.';

  @override
  String get sdAboutHowBullet2 => 'Channel — scores your channel against neighbouring APs.';

  @override
  String get sdAboutHowBullet3 => 'Speed — runs a real download/upload test against Cloudflare.';

  @override
  String get sdAboutHowBullet4 => 'Bufferbloat — measures latency under load (Waveform A–F).';

  @override
  String get sdAboutHowBullet5 => 'DNS — benchmarks public resolvers vs. your current one.';

  @override
  String get sdAboutCategoriesTitle => 'What do the categories mean?';

  @override
  String get sdAboutCategoriesBullet1 => 'Weak Signal — Wi-Fi link forced into slower modes by distance / walls.';

  @override
  String get sdAboutCategoriesBullet2 => 'Crowded Channel — neighbouring APs on the same channel eat your air-time.';

  @override
  String get sdAboutCategoriesBullet3 => 'Bufferbloat — latency balloons when the link is fully loaded; calls and games suffer.';

  @override
  String get sdAboutCategoriesBullet4 => 'ISP Slow — Wi-Fi is fine but your plan / upstream is the ceiling.';

  @override
  String get sdAboutCategoriesBullet5 => 'Slow DNS — page loads feel laggy because name lookups take too long.';

  @override
  String get sdAboutEstimateTitle => 'About the speed-up estimate';

  @override
  String get sdAboutEstimateBody => 'Each finding shows a conservative projected gain — what you can realistically expect after applying the fix. It is a lower bound, not a guarantee, and it depends on the test conditions.';

  @override
  String get diagnosisFailed => 'Diagnosis failed';

  @override
  String get retryLabel => 'RETRY';

  @override
  String get settingsIncludeHiddenDesc => 'Actively probes for hidden SSIDs. Off by default — only enable on networks you own.';

  @override
  String get autoScanLabel => 'Auto-Scan';

  @override
  String autoScanDesc(int seconds) {
    return 'Repeat scan every ${seconds}s automatically';
  }

  @override
  String get deepScanLabel => 'Deep Scan';

  @override
  String get deepScanDesc => 'Banner grab + exposure analysis. Only enable on networks you are authorized to test.';

  @override
  String get restrictDeepScanPublicLabel => 'Restrict Deep Scan on Public Wi-Fi';

  @override
  String get restrictDeepScanPublicDesc => 'Suppress active probing when connected to a public or guest network. Recommended — active scans on networks you do not own are the dominant legal risk.';

  @override
  String get backgroundMonitoringLabel => 'Background Monitoring';

  @override
  String get backgroundMonitoringDesc => 'Run a quiet Wi-Fi check every 30 minutes while the app is closed. You\'ll get a notification if a new device appears, the connected network swaps, or encryption changes. Battery impact is minimal. iOS support is limited (system-controlled refresh).';

  @override
  String get portScanTimeoutLabel => 'Port Scan Timeout';

  @override
  String get privacyAndDataLabel => 'PRIVACY & DATA';

  @override
  String get dataRetentionLabel => 'DATA RETENTION';

  @override
  String get scanHistoryRetentionLabel => 'Scan History';

  @override
  String get speedTestsRetentionLabel => 'Speed Tests';

  @override
  String get securityEventsRetentionLabel => 'Security Events';

  @override
  String get replayOnboardingLabel => 'Replay Onboarding';

  @override
  String get replayOnboardingDesc => 'View the welcome tour again.';

  @override
  String get wipeAllDataLabel => 'Wipe All Local Data';

  @override
  String get wipeAllDataDesc => 'Deletes all scan history, speed tests, security events and channel ratings from this device.';

  @override
  String get aboutLabel => 'ABOUT';

  @override
  String get legalDisclaimerTitle => 'Legal Disclaimer';

  @override
  String get legalDisclaimerBody => 'This application performs network observation and authorized LAN discovery. Active probing is strictly limited to service identification and security assessment. No brute-force authentication, frame injection, deauthentication packets, ARP poisoning, or credential harvesting are performed.\n\nUse of this application on networks you do not own or are not authorized to test may violate applicable laws (TCK 243/244, EU Directive 2013/40, CFAA). The user is solely responsible for ensuring lawful use.\n\nBu uygulama ağ gözlemi ve yetkili LAN keşfi gerçekleştirir. Aktif sorgulama yalnızca servis tanımlama ve güvenlik değerlendirmesi ile sınırlıdır. Yetkisiz ağlarda kullanım TCK 243/244 kapsamında suç teşkil edebilir.';

  @override
  String get enableDeepScanTitle => 'ENABLE DEEP SCAN?';

  @override
  String get enableDeepScanBody => 'Deep scan performs banner grabbing and service exposure analysis. This mode must only be used on networks you own or are explicitly authorized to test.\n\nProceeding on unauthorized networks may violate applicable laws.';

  @override
  String get wifiScanPermissionTitle => 'WIFI SCAN PERMISSION';

  @override
  String get wifiScanPermissionDesc => 'To discover nearby Wi-Fi networks and analyze signal strength, Torcav requires Location access. This is an Android system requirement for Wi-Fi scanning.';

  @override
  String get consentScanSsids => 'Scan nearby Wi-Fi SSIDs';

  @override
  String get consentAnalyzeSignal => 'Analyze signal quality and interference';

  @override
  String get consentNoTracking => 'Torcav never tracks or shares your location';

  @override
  String get continueLabel => 'CONTINUE';

  @override
  String get clearWifiHistoryBody => 'Delete all saved Wi-Fi scan sessions? This cannot be undone.';

  @override
  String get transparentSignalAnalysisTitle => 'TRANSPARENT SIGNAL ANALYSIS';

  @override
  String get transparentSignalAnalysisDesc => 'Advanced spectrum analysis for security auditing. Local processing only.';

  @override
  String get cachedResultsWarning => 'Showing cached results — Android limits scan frequency. Wait ~30 s and refresh for live data.';

  @override
  String get enableDeepScanBodyWifi => 'Deep Scan performs banner grabbing and exposure analysis. Use only on networks you are authorized to scan. Unauthorized use may violate TCK 243/244 and similar laws.';

  @override
  String get iAmAuthorized => 'I AM AUTHORIZED';

  @override
  String get iosWifiScanLimited => 'iOS: Wi-Fi scan results are limited by Apple APIs. Active scan trigger and some network details are unavailable.';

  @override
  String get allCategoriesLabel => 'All categories (single bundle)';

  @override
  String get autoLabel => 'Auto';

  @override
  String get lightLabel => 'Light';

  @override
  String get darkLabel => 'Dark';

  @override
  String get dismissLabel => 'Dismiss';

  @override
  String get applyLabel => 'Apply';

  @override
  String get openSettingsLabel => 'Open settings';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get encryptionAndConfigTitle => 'ENCRYPTION & CONFIG';

  @override
  String get environmentScanTitle => 'ENVIRONMENT SCAN';

  @override
  String get dnsTestFailedTitle => 'DNS Test Failed';

  @override
  String get dnsTestFailedDesc => 'Could not reach DNS test servers. Check your connection.';

  @override
  String get dnsLeakDetectedTitle => 'DNS Leak Detected';

  @override
  String get dnsLeakDetectedDesc => 'Your DNS queries are leaking outside the expected resolver, potentially exposing your browsing activity to your ISP or third parties.';

  @override
  String get dnsHijackingDetectedTitle => 'DNS Hijacking Detected';

  @override
  String get dnsHijackingDetectedDesc => 'DNS responses are being redirected to an unexpected server. This could indicate a man-in-the-middle attack or ISP interception.';

  @override
  String get dnsConfigWarningTitle => 'DNS Configuration Warning';

  @override
  String get dnsConfigWarningDesc => 'DNS configuration has potential issues that could affect privacy or security.';

  @override
  String get noIssuesDetected => 'No issues detected';

  @override
  String get retryInternetConnection => 'Retry when connected to the internet.';

  @override
  String get dnsLeakRecommendation => 'Configure a trusted DNS resolver (e.g. 1.1.1.1 or 9.9.9.9) and enable DNS-over-HTTPS (DoH) or DNS-over-TLS (DoT).';

  @override
  String get dnsHijackingRecommendation => 'Switch to a VPN immediately. Your DNS queries are being tampered with.';

  @override
  String get dnsConfigRecommendation => 'Review your DNS settings and consider switching to a privacy-focused DNS provider.';

  @override
  String openNetworksNearbyTitle(int count) {
    return '$count Open Network(s) Nearby';
  }

  @override
  String openNetworksNearbyDesc(int count) {
    return 'Detected $count unencrypted network(s) in range. Open networks are trivially sniffable.';
  }

  @override
  String wpsEnabledNearbyTitle(int count) {
    return '$count Network(s) with WPS Enabled';
  }

  @override
  String wpsEnabledNearbyDesc(int count) {
    return 'WPS is enabled on $count nearby network(s). WPS PIN can be brute-forced, bypassing the Wi-Fi password entirely.';
  }

  @override
  String get wpsRecommendation => 'Disable WPS on your router. If these are not your networks, be aware that nearby APs may be less secure.';

  @override
  String get renderingErrorTitle => 'RENDERING ERROR';

  @override
  String get renderingErrorBody => 'Dema ev rûpel dihat çêkirin çewtiyek çêbû. Ji kerema xwe sepanê ji nû ve bide destpêkirin.';

  @override
  String get dbHealedNotice => 'Hin daneyên we ji bo çareserkirina pirsgirêkek bîranînê hatin sifirkirin. Heke pêwîst be, torên xwe yên pêbawer ji nû ve mîheng bikin.';

  @override
  String get pingStabilizerConsentTitle => 'Aramkerê Pingê çalak bike';

  @override
  String get pingStabilizerConsentDesc => 'Ji bo pîşkandina jitterê û beralikirina DNSê ji bo lîstik/weşana aram, dê tunelek VPNê ya li ser amûrê were avakirin.';

  @override
  String get pingStabilizerConsentRouting => 'Trafîka we li ser amûra we dimîne. Tu daneyek nayê şandin ser servereke dûr.';

  @override
  String get pingStabilizerConsentDns => 'Tenê pirsên DNSê têne beralikirin; pakêtên din bê guhertin derbas dibin.';

  @override
  String get pingStabilizerConsentControl => 'Hûn dikarin tunelê her gav ji vê ekranê an ji hişyariyê rawestînin.';

  @override
  String get pingStabilizerConsentAction => 'Aramkerê dest pê bike';

  @override
  String get appTitleLong => 'Torcav Wi-Fi Analyzer';

  @override
  String get tosTitle => 'TERMS OF SERVICE';

  @override
  String get tosAcceptanceTitle => '1. ACCEPTANCE';

  @override
  String get tosAcceptanceBody => 'By accessing or using Torcav, you agree to be bound by these Terms. If you do not agree, you must immediately cease use of the App.';

  @override
  String get tosAuthorizedTestingTitle => '2. AUTHORIZED TESTING ONLY';

  @override
  String get tosAuthorizedTestingBody => 'You represent and warrant that you will only use the App to analyze networks and devices that you own or for which you have received explicit, written authorization to test. Unauthorized access to networks is strictly prohibited and may be illegal in your jurisdiction.';

  @override
  String get tosDisclaimerTitle => '3. DISCLAIMER OF WARRANTIES';

  @override
  String get tosDisclaimerBody => 'The App is provided \"as is\" and \"as available\". We do not guarantee that the App will identify all security vulnerabilities or that its results are 100% accurate. Use at your own risk.';

  @override
  String get tosLiabilityTitle => '4. LIMITATION OF LIABILITY';

  @override
  String get tosLiabilityBody => 'In no event shall the developers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the App.';

  @override
  String get tosModificationsTitle => '5. MODIFICATIONS';

  @override
  String get tosModificationsBody => 'We reserve the right to modify these terms at any time. Continued use of the App following any changes constitutes acceptance of the new terms.';

  @override
  String get tosLastUpdated => 'Last Updated: April 2026';

  @override
  String get legalNoticeTitle => 'LEGAL NOTICE';

  @override
  String get legalNoticeBody => 'This application is a security auditing tool. Misuse of this software to access or monitor networks without permission is strictly prohibited.';

  @override
  String get privacyTitle => 'PRIVACY POLICY';

  @override
  String get privacyIntro => 'Torcav is built on the principle of \"Privacy by Default\". Almost every byte stays on your device — no accounts, no cloud sync, no analytics, no advertising. A handful of features connect to public technical endpoints (Cloudflare, Google\'s captive-portal probe, public DNS resolvers) — those see only your IP, never any Torcav-internal identifier. You can wipe every persisted record with one tap.';

  @override
  String get privacyViewFullGithub => 'VIEW FULL POLICY ON GITHUB';

  @override
  String get privacyFullPolicyDesc => 'The card list below is a summary. The canonical, KVKK + GDPR-formatted policy is hosted at github.io.';

  @override
  String get privacyResponsibleTitle => 'WHO IS RESPONSIBLE';

  @override
  String get privacyIndividualDev => 'Individual Developer';

  @override
  String privacyDevBody(String email) {
    return 'Torcav is operated by an individual developer (Halil İbrahim Avşar), not a registered company. You can reach the data controller directly at $email.';
  }

  @override
  String get privacyDataCollectionTitle => 'DATA COLLECTION & USAGE';

  @override
  String get privacyWifiAnalysisTitle => 'Wi-Fi & Network Analysis';

  @override
  String get privacyWifiAnalysisBody => 'Nearby SSID/BSSID/RSSI metadata and security flags (WPA2/WPA3/WPS/PMF) are read from the OS scan API. This data stays in a local SQLite database encrypted at rest. It is never uploaded.';

  @override
  String get privacyLanInventoryTitle => 'LAN Device Inventory';

  @override
  String get privacyLanInventoryBody => 'When you run a LAN scan, the app collects IP/MAC/hostname/vendor/open ports for devices on the same network. This may include third-party devices — anonymisation is on by default for exports.';

  @override
  String get privacyLocationTitle => 'Location Permission (Wi-Fi only)';

  @override
  String get privacyLocationBody => 'Android requires the location permission to enable Wi-Fi scanning. Torcav uses it strictly for that — we do not read GPS coordinates and we do not track movement.';

  @override
  String get privacySensorsTitle => 'Sensors & Heatmap';

  @override
  String get privacySensorsBody => 'Activity recognition + IMU/barometer are used during heatmap surveys to map signal strength to your relative path (origin = scan start). GPS is not used.';

  @override
  String get privacyAiTitle => 'AI / Local Classification';

  @override
  String get privacyAiBody => 'Device-type identification uses a local ONNX model. No proprietary or vendor data leaves the device.';

  @override
  String get privacyExternalEndpointsTitle => 'EXTERNAL ENDPOINTS';

  @override
  String get privacyCloudflareTitle => 'Cloudflare Speed Test';

  @override
  String get privacyCloudflareBody => 'Speed Doctor and the speed-test page download/upload ~300-500 MB against speed.cloudflare.com. Cloudflare sees your IP — no Torcav identifier or telemetry is attached.';

  @override
  String get privacyDnsProbesTitle => 'Public DNS Probes';

  @override
  String get privacyDnsProbesBody => '1.1.1.1, 8.8.8.8, 9.9.9.9, OpenDNS and AdGuard are queried for DNS benchmark and leak detection. They see standard DNS queries (no user identifiers).';

  @override
  String get privacyCaptivePortalTitle => 'Captive Portal Probe';

  @override
  String get privacyCaptivePortalBody => 'connectivitycheck.gstatic.com receives a plain HEAD request to detect captive portals. This is the same probe Android itself runs.';

  @override
  String get privacyNoTrackersTitle => 'No Analytics, No Trackers, No Ads';

  @override
  String get privacyNoTrackersBody => 'There are zero analytics SDKs, zero advertising IDs, zero crash-reporting services in v1.0. We do not phone home on app start.';

  @override
  String get privacyRetentionTitle => 'RETENTION & DELETION';

  @override
  String get privacyConfigRetentionTitle => 'Configurable Retention';

  @override
  String get privacyConfigRetentionBody => 'Settings → Privacy lets you set retention windows (7-365 days) for scan history, speed tests, and security events. Default is 30 days. Old records prune automatically.';

  @override
  String get privacyWipeLocalDataTitle => 'Wipe All Local Data';

  @override
  String get privacyWipeLocalDataBody => 'A single tap in Settings → Privacy clears every persisted record: scans, devices, security events, heatmap sessions, LAN history, exports. Irreversible.';

  @override
  String get privacyRightsTitle => 'YOUR RIGHTS';

  @override
  String get privacyKvkkGdprTitle => 'KVKK (Turkey) + GDPR (EU/EEA)';

  @override
  String privacyRightsBody(String email) {
    return 'You can request access, correction, deletion, or portability of your data. For deletion, the in-app Wipe All button is the fastest path. For other requests, email $email — we respond within 30 days.';
  }

  @override
  String get privacyChildrenTitle => 'Children\'s Privacy';

  @override
  String get privacyChildrenBody => 'Torcav is not directed at users under 13 and presumes the user is old enough to take responsibility for the network being scanned.';

  @override
  String get privacyAuthorisedUseTitle => 'Authorised Use Only';

  @override
  String get privacyAuthorisedUseBody => 'Use Torcav on networks you own or are explicitly authorised to scan. Active LAN discovery and port scanning on networks you do not own may violate Turkish, EU, and US laws.';

  @override
  String get privacyContactLabel => 'CONTACT';

  @override
  String get privacyEffectiveDate => 'Effective 2026-05-08 • Version 1.0';

  @override
  String get hardeningTitle => 'ROUTER HARDENING';

  @override
  String get hardeningMarkDone => 'MARK DONE';

  @override
  String get hardeningOpenAdmin => 'OPEN ADMIN PANEL';

  @override
  String get hardeningStepsTitle => 'ACTION STEPS';

  @override
  String get hardeningMenuHintsTitle => 'COMMON MENU NAMES';

  @override
  String get hardeningCriticalBadge => 'CRITICAL';

  @override
  String get hardeningChangeAdminPasswordTitle => 'Change router admin password';

  @override
  String get hardeningChangeAdminPasswordBody => 'Default admin credentials (admin/admin, admin/password) are publicly documented. Anyone on your Wi-Fi can open the admin panel and rewrite settings — DNS hijack, redirect traffic, lock you out.';

  @override
  String get hardeningChangeAdminPasswordStep1 => 'Tap the big OPEN ADMIN PANEL button at the top of this page. Your browser will open the router login page.';

  @override
  String get hardeningChangeAdminPasswordStep2 => 'Log in. Try \"admin\" as username and \"admin\" or \"password\" as password if you haven\'t changed it.';

  @override
  String get hardeningChangeAdminPasswordStep3 => 'Find a menu named \"Administration\", \"System\", \"Maintenance\" or \"Account\".';

  @override
  String get hardeningChangeAdminPasswordStep4 => 'Inside that menu look for \"Login password\", \"Admin password\" or \"Change password\".';

  @override
  String get hardeningChangeAdminPasswordStep5 => 'Pick a NEW password — at least 12 characters, mix uppercase, lowercase, numbers and a symbol.';

  @override
  String get hardeningChangeAdminPasswordStep6 => 'Save / Apply. The router may reboot for ~30 seconds.';

  @override
  String get hardeningChangeAdminPasswordStep7 => 'Write the new password down somewhere safe.';

  @override
  String get hardeningChangeAdminPasswordStep8 => 'Once saved, come back here and tap MARK DONE.';

  @override
  String get hardeningUseWpa3OrWpa2AesTitle => 'Use WPA3, fall back to WPA2-AES';

  @override
  String get hardeningUseWpa3OrWpa2AesBody => 'WPA3 is the modern Wi-Fi encryption standard. WPA/TKIP and WEP can be cracked in minutes.';

  @override
  String get hardeningDisableWpsTitle => 'Disable WPS';

  @override
  String get hardeningDisableWpsBody => 'WPS lets attackers bypass your Wi-Fi password in hours. Turn it off.';

  @override
  String get hardeningEnablePmfTitle => 'Enable PMF / 802.11w';

  @override
  String get hardeningEnablePmfBody => 'Protected Management Frames stop attackers from knocking your devices offline.';

  @override
  String get hardeningEnableGuestNetworkTitle => 'Enable a guest network';

  @override
  String get hardeningEnableGuestNetworkBody => 'A second SSID for visitors and IoT devices keeps your private network safe.';

  @override
  String get hardeningDisableRemoteAdminTitle => 'Disable remote / WAN-side admin';

  @override
  String get hardeningDisableRemoteAdminBody => 'If the admin panel is reachable from the internet, anyone can try default passwords.';

  @override
  String get hardeningUpdateFirmwareTitle => 'Update firmware';

  @override
  String get hardeningUpdateFirmwareBody => 'Most home routers have known security holes that vendors patch quietly.';

  @override
  String get hardeningStrongPassphraseTitle => 'Use a strong Wi-Fi passphrase';

  @override
  String get hardeningStrongPassphraseBody => '12+ characters, mixed case, never reused from another service.';

  @override
  String gatewayCopyError(String ip) {
    return 'Could not open the browser automatically. Gateway IP $ip has been copied — paste it into your browser\'s address bar.';
  }

  @override
  String gatewayCopied(String ip) {
    return 'Gateway IP $ip copied to clipboard.';
  }

  @override
  String get hardeningConnectWifiHint => 'Connect to your home Wi-Fi to track progress per router. The checklist still works without a connection.';

  @override
  String get progressLabel => 'PROGRESS';

  @override
  String get tapToCopy => 'tap to copy';

  @override
  String get hardeningOpenAdminDesc => 'Launch your router login page in the browser';

  @override
  String get hardeningConnectWifiRequired => 'Connect to Wi-Fi first';

  @override
  String get hardeningGatewayHintDisconnected => 'Once connected, the gateway IP appears above and the button will launch your browser.';

  @override
  String get hardeningGatewayHintConnected => 'Doesn\'t open? Tap the gateway IP above to copy it, then paste it into your browser\'s address bar (Chrome, Firefox, etc.).';

  @override
  String get whyThisMattersLabel => 'WHY THIS MATTERS';

  @override
  String get markAsTodoLabel => 'MARK AS todo';

  @override
  String get vpnRecommendation => 'Use a trusted VPN when connecting to unknown or untrusted networks.';

  @override
  String get exportLocalDataTitle => 'EXPORT LOCAL DATA';

  @override
  String get exportLocalDataDesc => 'Your data on this device, in your hands. Pick a category and share or save it as JSON.';

  @override
  String get exportCategoryLabel => 'Category';

  @override
  String get exportFormatLabel => 'Format';

  @override
  String get jsonExportLabel => 'JSON — full, machine-readable';

  @override
  String get csvExportLabel => 'CSV — opens in Excel/Sheets';

  @override
  String get csvSingleCategoryOnlyLabel => 'CSV — single category only';

  @override
  String get htmlExportLabel => 'HTML — viewable in browser';

  @override
  String get anonymizeIdentifiersLabel => 'Anonymize identifiers';

  @override
  String get anonymizeIdentifiersDesc => 'Mask BSSID/MAC last 3 octets, redact SSID and hostname.';

  @override
  String get noIdentifiersToMaskDesc => 'This category has no identifiers to mask.';

  @override
  String get exportingLabel => 'EXPORTING…';

  @override
  String exportAsLabel(String format) {
    return 'EXPORT AS $format';
  }

  @override
  String get exportPrivacyNote => 'Stays on your device until you share it. Nothing is sent to any server.';

  @override
  String get categoryWifiScanHistory => 'Wi-Fi scan history';

  @override
  String get categorySpeedTestResults => 'Speed test results';

  @override
  String get categorySecurityEvents => 'Security events';

  @override
  String get categoryKnownAndTrustedNetworks => 'Known + trusted networks';

  @override
  String get categoryChannelRatingsHistory => 'Channel ratings history';

  @override
  String get categoryHeatmapSessions => 'Heatmap sessions';

  @override
  String get categoryLanScanLatest => 'LAN scan (latest)';

  @override
  String get categoryDeviceLabelOverrides => 'Device label overrides';

  @override
  String get categoryPinnedNetworks => 'Pinned networks';

  @override
  String get categoryScoreHistory => 'Security score history';

  @override
  String get categoryNetworkContextOverrides => 'Network context overrides';

  @override
  String get categoryRouterHardeningProgress => 'Router hardening progress';

  @override
  String get macRandomizedLabel => 'MAC Randomized';

  @override
  String get notificationsBlockedTitle => 'Notifications are blocked';

  @override
  String get notificationsBlockedDesc => 'The live ping HUD lives in the notification shade. Without notifications you cannot see ping while gaming. On MIUI/Xiaomi, also enable \"Show on Lock screen\" and \"Floating notifications\".';

  @override
  String get liveLatencyLabel => 'Live latency';

  @override
  String get latencyStatLabel => 'Latency';

  @override
  String get jitterStatLabel => 'Jitter';

  @override
  String get lossStatLabel => 'Loss';

  @override
  String baselineLatencyLabel(String ms) {
    return 'Baseline (pre-tunnel): $ms ms';
  }

  @override
  String jitterThresholdLabel(String ms) {
    return 'Jitter alarm threshold: $ms ms';
  }

  @override
  String get heatmapSettingsTitle => 'Heatmap Settings';

  @override
  String get dnsLabel => 'DNS';

  @override
  String get notNowLabel => 'NOT NOW';

  @override
  String get newNetworkLabel => '+ NEW';

  @override
  String get goneNetworkLabel => 'GONE';

  @override
  String get hiddenNetworkLabel => '[Hidden]';

  @override
  String get randomizedMacDetectedLabel => 'Randomized MAC Detected';

  @override
  String get howPingStabilizerWorksTitle => 'How Ping Stabilizer works';

  @override
  String get stabilizerExplainerSubtitle => 'On-device, no remote servers, free.';

  @override
  String get whatItDoesTitle => 'What it does';

  @override
  String get whatItDoesBullet1 => 'Establishes a local VPN tunnel on your device — no traffic leaves through any third-party server.';

  @override
  String get whatItDoesBullet2 => 'Routes DNS queries to the fastest resolver (1.1.1.1, 8.8.8.8, 9.9.9.9, …) measured live.';

  @override
  String get whatItDoesBullet3 => 'Watches latency / jitter every second and warns you when a spike persists, optionally cycling the tunnel to break a sticky bad path.';

  @override
  String get whatItDoesBullet4 => 'Uses an EWMA filter (recent samples weighted heavier) so it reacts to real degradation, not single-packet noise.';

  @override
  String get whatItDoesNotTitle => 'What it does NOT do';

  @override
  String get whatItDoesNotBullet1 => 'It cannot make your ISP\'s route to the game server physically shorter — no on-device app can.';

  @override
  String get whatItDoesNotBullet2 => 'It does not replace a paid VPN/relay service like ExitLag or WTFast (those route via their own servers; this is local-only).';

  @override
  String get whatItDoesNotBullet3 => 'Multi-path \"first-wins\" send across Wi-Fi + cellular is on the roadmap (Phase 2) and currently disabled.';

  @override
  String get risksAndThingsToKnowTitle => 'Risks & things to know';

  @override
  String get risksBullet1 => 'Android shows a key icon while the tunnel is active — that is normal and required by the system.';

  @override
  String get risksBullet2 => 'Only one VPN can run at a time. If you have another VPN app connected, this will refuse to start.';

  @override
  String get risksBullet3 => 'A persistent live notification (current ping + Stop / Cycle buttons) stays in the shade while the tunnel runs — that is your in-game HUD; do not swipe it away.';

  @override
  String get risksBullet4 => 'On Xiaomi/MIUI, OnePlus/OxygenOS and similar skins, you may need to allow Torcav under Settings → Notifications and Settings → Battery → No restrictions, or the OS will silently hide the notification.';

  @override
  String get risksBullet5 => 'DNS auto-switch will change which resolver answers your queries while the tunnel is on. That switch reverts when you stop the stabilizer.';

  @override
  String get risksBullet6 => 'Battery use is small (~3-5%/hr in our tests) but non-zero — turn it off when you\'re done playing.';

  @override
  String get shieldIntegrityLabel => 'SHIELD INTEGRITY';

  @override
  String get activeThreatsLabel => 'ACTIVE THREATS';

  @override
  String get shieldStatusOptimal => 'OPTIMAL';

  @override
  String get shieldStatusWarning => 'WARNING';

  @override
  String get shieldStatusCritical => 'CRITICAL';

  @override
  String get securityScoreLabel => 'SECURITY SCORE';

  @override
  String get systemStatusLabel => 'SYSTEM STATUS';

  @override
  String get scanningAllCaps => 'SCANNING';

  @override
  String bssidLabel(String bssid) {
    return 'BSSID: $bssid';
  }

  @override
  String gatewayWithIpLabel(String gateway) {
    return 'GATEWAY: $gateway';
  }

  @override
  String get trustedBadge => 'TRUSTED';

  @override
  String get identifiedBadge => 'IDENTIFIED';

  @override
  String authEstablishedLabel(String date) {
    return 'AUTH: ESTABLISHED $date';
  }

  @override
  String get revokeTrustTooltip => 'REVOKE TRUST';

  @override
  String get apsLabel => 'APs';

  @override
  String get openLabel => 'OPEN';

  @override
  String get wpsLabel => 'WPS';

  @override
  String get wepLabel => 'WEP';

  @override
  String get publicWifiLabel => 'PUBLIC WI-FI';

  @override
  String get guestNetworkLabel => 'GUEST NETWORK';

  @override
  String get publicWifiDesc => 'Open or untrusted network — assume traffic can be observed.';

  @override
  String get guestNetworkDesc => 'You are on a guest segment. Treat as untrusted by default.';

  @override
  String get tipVpnTitle => 'Use a VPN';

  @override
  String get tipVpnBody => 'Tunnel traffic through a trusted VPN before sending anything sensitive. Built-in OS VPN is fine for most users.';

  @override
  String get tipHttpsTitle => 'Verify HTTPS';

  @override
  String get tipHttpsBody => 'Only enter credentials on sites with a locked padlock. Reject certificate warnings — they are how attackers strip TLS.';

  @override
  String get tipSensitiveTitle => 'Defer sensitive actions';

  @override
  String get tipSensitiveBody => 'Avoid banking, payments, password resets and account logins until you are back on a trusted network.';

  @override
  String get tipDnsTitle => 'Check DNS health';

  @override
  String get tipDnsBody => 'Public hotspots can hijack DNS. Run a DNS test from this screen to confirm responses are not being rewritten.';

  @override
  String evilTwinPrefix(String confidence) {
    return 'EVIL TWIN · $confidence';
  }

  @override
  String get whatIsEvilTwinTitle => 'What is an evil-twin?';

  @override
  String get whyItMattersTitle => 'Why does it matter?';

  @override
  String get whatWeObservedTitle => 'What we observed';

  @override
  String get whatLookedLegitimateTitle => 'What looked legitimate';

  @override
  String get whatYouShouldDoTitle => 'What you should do';

  @override
  String get hardeningUseWpa3OrWpa2AesStep1 => 'Open the admin panel using the button at the top.';

  @override
  String get hardeningUseWpa3OrWpa2AesStep2 => 'Find the wireless section: \"Wireless\", \"Wi-Fi\" or \"WLAN\".';

  @override
  String get hardeningUseWpa3OrWpa2AesStep3 => 'Look for a security or encryption setting — usually called \"Security mode\", \"Authentication\" or \"Encryption\".';

  @override
  String get hardeningUseWpa3OrWpa2AesStep4 => 'Choose the strongest option in this order: WPA3-Personal > WPA2/WPA3 mixed > WPA2-Personal (AES). Avoid anything labelled \"WPA-PSK\", \"TKIP\", \"WEP\" or \"Open\" — these are insecure.';

  @override
  String get hardeningUseWpa3OrWpa2AesStep5 => 'If you set WPA3-Personal and an old device (smart bulb, printer, older phone) stops working, switch to \"WPA2/WPA3 mixed\" — that lets old gear connect while new devices still use WPA3.';

  @override
  String get hardeningUseWpa3OrWpa2AesStep6 => 'If you have separate 2.4 GHz and 5 GHz settings, change BOTH bands.';

  @override
  String get hardeningUseWpa3OrWpa2AesStep7 => 'Save / Apply. Your devices may briefly disconnect — they will rejoin in a few seconds.';

  @override
  String get hardeningUseWpa3OrWpa2AesStep8 => 'Come back here and tap MARK DONE.';

  @override
  String get hardeningDisableWpsStep1 => 'Open the admin panel.';

  @override
  String get hardeningDisableWpsStep2 => 'Find the Wireless or Wi-Fi section.';

  @override
  String get hardeningDisableWpsStep3 => 'Look for a sub-menu called \"WPS\", \"Easy Setup\", \"Quick Connect\" or a tab inside Wireless Settings labelled WPS.';

  @override
  String get hardeningDisableWpsStep4 => 'Switch the WPS toggle to OFF / Disabled.';

  @override
  String get hardeningDisableWpsStep5 => 'Some routers also have a physical WPS button on the device — that will stop working too, which is the goal.';

  @override
  String get hardeningDisableWpsStep6 => 'Save / Apply.';

  @override
  String get hardeningDisableWpsStep7 => 'From now on, when you connect a new device just type the Wi-Fi password normally. Takes 10 extra seconds, removes a serious attack path.';

  @override
  String get hardeningDisableWpsStep8 => 'Come back here and tap MARK DONE.';

  @override
  String get hardeningEnablePmfStep1 => 'Open the admin panel.';

  @override
  String get hardeningEnablePmfStep2 => 'Go to the Wireless / Wi-Fi section.';

  @override
  String get hardeningEnablePmfStep3 => 'Look in \"Advanced\" or \"Wireless Security\" for a setting called \"PMF\", \"802.11w\" or \"Management Frame Protection\".';

  @override
  String get hardeningEnablePmfStep4 => 'Set it to \"Required\" if all your devices are recent (last ~5 years). If older devices stop seeing the network, change it to \"Optional / Capable\" — that still helps, just less strictly.';

  @override
  String get hardeningEnablePmfStep5 => 'If you cannot find this setting at all, your router may have it baked into WPA3 mode (so completing item 2 above already covers it). In that case, tap MARK DONE here too.';

  @override
  String get hardeningEnablePmfStep6 => 'Save / Apply.';

  @override
  String get hardeningEnablePmfStep7 => 'Come back here and tap MARK DONE.';

  @override
  String get hardeningEnableGuestNetworkStep1 => 'Open the admin panel.';

  @override
  String get hardeningEnableGuestNetworkStep2 => 'Find a menu called \"Guest Network\", \"Guest Wi-Fi\" or \"Multi-SSID\".';

  @override
  String get hardeningEnableGuestNetworkStep3 => 'Enable it. Give it a different name from your main Wi-Fi — for example, if your main is \"Home\", call the guest one \"Home-Guest\".';

  @override
  String get hardeningEnableGuestNetworkStep4 => 'Set a password. It can be simpler than your main one (guests will type it), but still 10+ characters.';

  @override
  String get hardeningEnableGuestNetworkStep5 => 'Look for a setting called \"Client Isolation\", \"AP Isolation\" or \"Guest network isolation\". Turn it ON. This stops guest devices from talking to each other or to your private network.';

  @override
  String get hardeningEnableGuestNetworkStep6 => 'Move your IoT devices (smart plugs, cameras, robot vacuum, smart TV) over to the guest network — connect them with the new password.';

  @override
  String get hardeningEnableGuestNetworkStep7 => 'Save / Apply.';

  @override
  String get hardeningEnableGuestNetworkStep8 => 'Come back here and tap MARK DONE.';

  @override
  String get hardeningDisableRemoteAdminStep1 => 'Open the admin panel.';

  @override
  String get hardeningDisableRemoteAdminStep2 => 'Go to \"Administration\", \"System Tools\" or \"Security\".';

  @override
  String get hardeningDisableRemoteAdminStep3 => 'Find a setting called \"Remote Management\", \"Web Access from WAN\" or \"Remote admin\".';

  @override
  String get hardeningDisableRemoteAdminStep4 => 'Switch it OFF / Disabled.';

  @override
  String get hardeningDisableRemoteAdminStep5 => 'While here, also check for \"Cloud / Remote App access\" (some brands have this — TP-Link Tether, Asus Router app, Mi Wi-Fi). If you do not actively use that app, turn it off too.';

  @override
  String get hardeningDisableRemoteAdminStep6 => 'Save / Apply.';

  @override
  String get hardeningDisableRemoteAdminStep7 => 'You can still manage your router from inside your home — only the remote / public-internet path is closed.';

  @override
  String get hardeningDisableRemoteAdminStep8 => 'Come back here and tap MARK DONE.';

  @override
  String get hardeningUpdateFirmwareStep1 => 'Open the admin panel.';

  @override
  String get hardeningUpdateFirmwareStep2 => 'Find a menu called \"Firmware Update\", \"System Update\", \"Online Upgrade\" or \"Maintenance\".';

  @override
  String get hardeningUpdateFirmwareStep3 => 'Tap \"Check for update\" or \"Online check\". The router will look for a newer version on the vendor server.';

  @override
  String get hardeningUpdateFirmwareStep4 => 'If an update is offered, install it. The router will reboot for 2-5 minutes — do NOT unplug it during the update or it can become a paperweight.';

  @override
  String get hardeningUpdateFirmwareStep5 => 'After it comes back, go to the same menu and look for \"Auto update\" or \"Automatic upgrade\". Turn it ON if available.';

  @override
  String get hardeningUpdateFirmwareStep6 => 'Some older routers do not have online updates. In that case, note the router model from the device sticker, search the vendor website, download the latest firmware file, and use the \"Manual upload\" option in the same menu.';

  @override
  String get hardeningUpdateFirmwareStep7 => 'Come back here and tap MARK DONE.';

  @override
  String get hardeningStrongPassphraseStep1 => 'Open the admin panel.';

  @override
  String get hardeningStrongPassphraseStep2 => 'Go to \"Wireless\", \"Wi-Fi\" or \"WLAN\".';

  @override
  String get hardeningStrongPassphraseStep3 => 'Find the password field — labelled \"Wireless password\", \"Pre-Shared Key (PSK)\", \"Wireless Key\" or simply \"Password\".';

  @override
  String get hardeningStrongPassphraseStep4 => 'Replace it with a NEW passphrase: at least 12 characters, with a mix of uppercase, lowercase, numbers and a symbol. Avoid dictionary words and personal info (birthdays, pet names).';

  @override
  String get hardeningStrongPassphraseStep5 => 'A good trick: pick three unrelated words plus a number, e.g. \"correct-horse-battery-9\". Long passphrases are harder to crack than short complex ones.';

  @override
  String get hardeningStrongPassphraseStep6 => 'If you have separate 2.4 GHz and 5 GHz networks, change BOTH.';

  @override
  String get hardeningStrongPassphraseStep7 => 'Save / Apply. Every device will disconnect — re-enter the new password on each one.';

  @override
  String get hardeningStrongPassphraseStep8 => 'Write the password down (password manager, fridge note for visitors, whatever works for you).';

  @override
  String get hardeningStrongPassphraseStep9 => 'Come back here and tap MARK DONE.';

  @override
  String get severity_critical => 'CRITICAL';

  @override
  String get severity_high => 'HIGH';

  @override
  String get severity_medium => 'MEDIUM';

  @override
  String get severity_low => 'LOW';

  @override
  String get severity_info => 'INFO';

  @override
  String get rule_scan_deep_scan_active_title => 'Active Probing Active';

  @override
  String get rule_scan_deep_scan_active_desc => 'Deep scan is enabled, performing more intrusive network tests.';

  @override
  String get rule_scan_deep_scan_active_rec => 'Use only on networks you own or have permission to scan.';

  @override
  String get rule_wifi_open_network_title => 'Open Network';

  @override
  String get rule_wifi_open_network_desc => 'No encryption detected. All traffic can be sniffed in plaintext.';

  @override
  String get rule_wifi_open_network_rec => 'Avoid sensitive activity. Prefer trusted VPN or different network.';

  @override
  String get rule_wifi_wep_title => 'WEP Encryption';

  @override
  String get rule_wifi_wep_desc => 'WEP is deprecated and can be cracked quickly.';

  @override
  String get rule_wifi_wep_rec => 'Reconfigure AP to WPA2 or WPA3 immediately.';

  @override
  String get rule_wifi_legacy_wpa_title => 'Legacy WPA';

  @override
  String get rule_wifi_legacy_wpa_desc => 'WPA/TKIP is older and weaker against modern attack techniques.';

  @override
  String get rule_wifi_legacy_wpa_rec => 'Upgrade AP and clients to WPA2/WPA3.';

  @override
  String get rule_wifi_hidden_ssid_title => 'Hidden SSID';

  @override
  String get rule_wifi_hidden_ssid_desc => 'Hidden SSIDs are still discoverable and may hurt compatibility.';

  @override
  String get rule_wifi_hidden_ssid_rec => 'Hidden SSID alone is not protection. Focus on strong encryption.';

  @override
  String get rule_wifi_very_weak_signal_title => 'Very Weak Signal';

  @override
  String get rule_wifi_very_weak_signal_desc => 'Weak signal can indicate unstable links and spoofing susceptibility.';

  @override
  String get rule_wifi_very_weak_signal_rec => 'Move closer to AP or validate BSSID consistency.';

  @override
  String get rule_wifi_wps_enabled_title => 'WPS Enabled';

  @override
  String get rule_wifi_wps_enabled_desc => 'Wi-Fi Protected Setup (WPS) is enabled. The WPS PIN mode can be brute-forced in hours, bypassing any password.';

  @override
  String get rule_wifi_wps_enabled_rec => 'Disable WPS in your router admin panel. Use WPA2/WPA3 passphrase only.';

  @override
  String get rule_wifi_pmf_not_enforced_title => 'Management Frames Unprotected';

  @override
  String get rule_wifi_pmf_not_enforced_desc => 'This access point does not enforce Protected Management Frames (PMF / 802.11w), allowing deauthentication attacks.';

  @override
  String get rule_wifi_pmf_not_enforced_rec => 'Enable PMF in your router settings (often labelled \"802.11w\" or \"Management Frame Protection\").';

  @override
  String get rule_wifi_suspicious_sibling_ap_title => 'Potential Evil Twin';

  @override
  String get rule_wifi_suspicious_sibling_ap_desc => 'A nearby access point shares this SSID but its fingerprint doesn\'t match — that\'s the pattern an attacker uses to impersonate a real Wi-Fi.';

  @override
  String get rule_wifi_suspicious_sibling_ap_rec => 'Don\'t enter passwords on this network until you\'ve verified the BSSID on the back of your router.';

  @override
  String get rule_wifi_suspicious_ssid_title => 'Suspicious Network Name';

  @override
  String get rule_wifi_suspicious_ssid_desc => 'This SSID matches common honeypot/lure patterns (e.g. \"Free WiFi\") used by attackers to trick users.';

  @override
  String get rule_wifi_suspicious_ssid_rec => 'Verify this network with the venue operator before connecting. Use a VPN if you must connect.';

  @override
  String get rule_wifi_high_channel_congestion_title => 'High Channel Congestion';

  @override
  String get rule_wifi_high_channel_congestion_desc => 'Heavy congestion on this channel degrades performance and connection reliability.';

  @override
  String get rule_wifi_high_channel_congestion_rec => 'Ask the network admin to switch to a less congested channel.';

  @override
  String get rule_wifi_only_24ghz_title => '2.4 GHz Only';

  @override
  String get rule_wifi_only_24ghz_desc => 'This network only broadcasts on the crowded 2.4 GHz band. 5 GHz offers better performance.';

  @override
  String get rule_wifi_only_24ghz_rec => 'Enable 5 GHz band on your router for better performance.';

  @override
  String get rule_trusted_baseline_drift_title => 'Trusted Baseline Drift';

  @override
  String get rule_trusted_baseline_drift_desc => 'This access point no longer matches the fingerprint you previously trusted.';

  @override
  String get rule_trusted_baseline_drift_rec => 'Re-validate the router configuration and only re-trust if the change was intentional.';

  @override
  String get rule_hardware_vulnerability_title => 'Vulnerable Hardware';

  @override
  String get rule_hardware_vulnerability_desc => 'BSSID prefix matches a known vulnerable hardware profile.';

  @override
  String get rule_hardware_vulnerability_rec => 'Check for manufacturer firmware updates addressing known CVEs for this model.';

  @override
  String get noLiveScanAvailable => 'NO LIVE SCAN AVAILABLE';

  @override
  String noLiveScanDesc(String ssid) {
    return 'We don\'t have a fresh Wi-Fi scan that includes \"$ssid\" right now, so the live signal breakdown isn\'t available. Run a new Wi-Fi scan from the Discovery tab and reopen this alert to see the full evidence.';
  }

  @override
  String get outOf100Label => '/100';

  @override
  String get networkLabel => 'Network';

  @override
  String get noActivityYet => 'NO ACTIVITY YET';

  @override
  String get runFirstScanDesc => 'Run your first scan to populate the timeline.';

  @override
  String get networkContextTitle => 'NETWORK CONTEXT';

  @override
  String get networkContextHomeDesc => 'Your home, office, or known router. Strict standards apply.';

  @override
  String get networkContextPublicDesc => 'Café, hotel, airport, or open hotspot. VPN/HTTPS strongly advised.';

  @override
  String get networkContextGuestDesc => 'Guest segment of a known network. Natural drift expected.';

  @override
  String get networkContextUnknownDesc => 'Let Torcav infer the context from passive signals.';

  @override
  String scanVia(String backend) {
    return 'Scan via $backend';
  }

  @override
  String get justNow => 'just now';

  @override
  String minutesAgo(int count) {
    return '${count}m ago';
  }

  @override
  String hoursAgo(int count) {
    return '${count}h ago';
  }

  @override
  String daysAgo(int count) {
    return '${count}d ago';
  }

  @override
  String get rogueApSuspected => 'Rogue AP suspected';

  @override
  String get deauthActivity => 'Deauth activity';

  @override
  String get handshakeCaptureStarted => 'Handshake capture started';

  @override
  String get handshakeCaptured => 'Handshake captured';

  @override
  String get captivePortal => 'Captive portal';

  @override
  String get evilTwinDetected => 'Evil twin detected';

  @override
  String get encryptionDowngrade => 'Encryption downgrade';

  @override
  String get unsupportedOp => 'Unsupported op';

  @override
  String get arpSpoofing => 'ARP spoofing';

  @override
  String get dnsHijacking => 'DNS hijacking';

  @override
  String networksWithCount(int count) {
    return 'Networks ($count)';
  }

  @override
  String signalStability(String stability) {
    return 'Stability $stability';
  }

  @override
  String get metricSignal => 'SIGNAL';

  @override
  String get metricScoreTrend => 'SCORE TREND';

  @override
  String get metricChannels => 'CHANNELS';

  @override
  String get metricNewDevices => 'NEW DEVICES';

  @override
  String get metricThreats => 'THREATS';

  @override
  String get metricSpeed => 'SPEED';

  @override
  String get severityCrit => 'CRIT';

  @override
  String get severityHighShort => 'HIGH';

  @override
  String get severityMedShort => 'MED';

  @override
  String get severityInfoShort => 'INFO';

  @override
  String get hardenRouterTitle => 'HARDEN ROUTER';

  @override
  String get hardenRouterSubtitle => 'Security checklist';

  @override
  String get packetLossLabel => 'PACKET LOSS';

  @override
  String get loadedLatencyLabel => 'LOADED LATENCY';

  @override
  String get clearHistoryTooltip => 'Clear all history';

  @override
  String get whatIsThisSection => 'What is this?';

  @override
  String get whyItMattersSection => 'Why it matters';

  @override
  String get covShort => 'COV';

  @override
  String get sigShort => 'SIG';

  @override
  String get motShort => 'MOT';

  @override
  String get wifiShort => 'WIFI';

  @override
  String get camShort => 'CAM';

  @override
  String get discardSurveyTooltip => 'Discard Survey';

  @override
  String get finishReviewTooltip => 'Finish & Review';

  @override
  String get noDataAtLocation => 'NO DATA AT THIS LOCATION';

  @override
  String get rssiLabel => 'RSSI';

  @override
  String get statusLabel => 'STATUS';

  @override
  String get floorLabel => 'FLOOR';

  @override
  String get positionLabel => 'POSITION';

  @override
  String get samplesLabel => 'SAMPLES';

  @override
  String get capturedLabel => 'CAPTURED';

  @override
  String get heatmapPermissionsTitle => 'HEATMAP PERMISSIONS';

  @override
  String get realignCompassTooltip => 'Realign Compass';

  @override
  String get exportCsvLabel => 'Export CSV';

  @override
  String get setDeviceType => 'Set Device Type';

  @override
  String get resetToAiLabel => 'Reset to AI label';

  @override
  String get gatewayCaps => 'GATEWAY';

  @override
  String get identifiedCaps => 'IDENTIFIED';

  @override
  String get unknownMacRestricted => 'UNKNOWN MAC (RESTRICTED)';

  @override
  String get scanPortsCaps => 'SCAN PORTS';

  @override
  String get noOpenPortsFound => 'No open ports found';

  @override
  String get criticalCaps => 'CRITICAL';

  @override
  String get wpsActiveCaps => 'WPS ACTIVE';

  @override
  String get protectPdfTitle => 'PROTECT PDF WITH A PASSWORD';

  @override
  String get pdfLockedHint => 'Optional. Locked file: .torcav-pdf — open it again from Reports.';

  @override
  String get pdfLockedLabel => 'Locked file: .torcav-pdf — open it again from Reports.';

  @override
  String get pdfPasswordHint => 'Password (leave empty for plain PDF)';

  @override
  String get pdfPasswordWarning => 'Heads up: this is lightweight obfuscation, not bank-grade encryption. It protects the file against casual leaks (cloud thumbnails, mailbox cache) but a determined attacker who has the file could still attempt to brute-force a weak password. Use a long, unique passphrase.';

  @override
  String get understandEnable => 'I UNDERSTAND — ENABLE';

  @override
  String get categorySignal => 'Signal';

  @override
  String get categoryChannel => 'Channel';

  @override
  String get categoryBufferbloat => 'Bufferbloat';

  @override
  String get categoryIsp => 'ISP throughput';

  @override
  String get categoryDns => 'DNS';

  @override
  String get categoryHealthy => 'Healthy';

  @override
  String get severityHigh => 'HIGH';

  @override
  String get severityMed => 'MED';

  @override
  String get severityLow => 'LOW';

  @override
  String get speedDoctorActionMoveCloser => 'Move closer to router';

  @override
  String get speedDoctorActionAddMesh => 'Add a mesh node';

  @override
  String get speedDoctorActionSwitchTo5Ghz => 'Switch to 5 GHz';

  @override
  String get speedDoctorActionChangeChannel => 'Change Wi-Fi channel';

  @override
  String get speedDoctorActionMoveTo5Ghz => 'Move to 5/6 GHz band';

  @override
  String get speedDoctorActionEnableQos => 'Enable router QoS';

  @override
  String get speedDoctorActionUpdateFirmware => 'Update router firmware';

  @override
  String get speedDoctorActionCallIsp => 'Contact your ISP';

  @override
  String get speedDoctorActionRunWiredTest => 'Re-test with cable';

  @override
  String get speedDoctorActionChangeDns => 'Change DNS provider';

  @override
  String get speedDoctorActionEnableDoh => 'Enable DoH / DoT';

  @override
  String get waitingForHistory => 'Waiting for history';

  @override
  String get noScanData => 'No scan data';

  @override
  String get mbps => 'Mbps';

  @override
  String get primaryCauseWeakSignalTitle => 'WEAK SIGNAL';

  @override
  String get primaryCauseWeakSignalDesc => 'Your device is far from the router or has too many walls in the way. Move closer or add a mesh node in this area.';

  @override
  String get primaryCauseCrowdedChannelTitle => 'CROWDED CHANNEL';

  @override
  String get primaryCauseCrowdedChannelDesc => 'Several neighbouring access points are sharing your channel. Switching to a less crowded channel — or to 5/6 GHz — should help.';

  @override
  String get primaryCauseBufferbloatTitle => 'BUFFERBLOAT';

  @override
  String get primaryCauseBufferbloatDesc => 'Latency spikes when the link is busy. Enable QoS / SQM on your router to manage traffic spikes.';

  @override
  String get primaryCauseIspSlowTitle => 'ISP THROUGHPUT LIMIT';

  @override
  String get primaryCauseIspSlowDesc => 'Your Wi-Fi link is healthy but the download speed is low. The bottleneck is most likely your internet plan or upstream provider.';

  @override
  String get primaryCauseSlowDnsTitle => 'SLOW DNS';

  @override
  String get primaryCauseSlowDnsDesc => 'Names take too long to resolve. Switching DNS provider or enabling DoH/DoT typically removes the delay.';

  @override
  String get primaryCauseHealthyTitle => 'NETWORK HEALTHY';

  @override
  String get primaryCauseHealthyDesc => 'No bottleneck reached an alert threshold. Your link looks fine right now.';

  @override
  String get diagStepReadingSignal => 'Reading signal';

  @override
  String get diagStepAnalysingChannels => 'Analysing channels';

  @override
  String get diagStepMeasuringSpeed => 'Measuring speed';

  @override
  String get diagStepBenchmarkingDns => 'Benchmarking DNS';

  @override
  String get hideDetails => 'Hide details';

  @override
  String get whatIsThisHowToFix => 'What is this? · How to fix';

  @override
  String get preview => 'Preview';

  @override
  String get recording => 'RECORDING';

  @override
  String get reviewing => 'REVIEW';

  @override
  String get idle => 'IDLE';

  @override
  String get surveyComplete => 'SURVEY COMPLETE';

  @override
  String get surveyCompleteDesc => 'The survey has been successfully recorded. Plan and signal data are synthesized.';

  @override
  String get coverage => 'COVERAGE';

  @override
  String get blindSpots => 'BLIND SPOTS';

  @override
  String get saveAndFinish => 'SAVE & FINISH';

  @override
  String get diagStepFinalizing => 'Finalising diagnosis';

  @override
  String get heatmapPageTitle => 'HOME PLAN + WIFI HEATMAP';

  @override
  String get heatmapPageSubtitle => 'Outline, coverage, and weak zones';

  @override
  String get heatmapHistoryTooltip => 'Open saved surveys';

  @override
  String get heatmapThemeToggleTooltip => 'Toggle view (Blueprint / Neon)';

  @override
  String get heatmapSamplesShort => 'samples';

  @override
  String get heatmapWallsShort => 'walls';

  @override
  String get heatmapRestartSurvey => 'RESTART SURVEY';

  @override
  String get heatmapRenameSurvey => 'RENAME SURVEY';

  @override
  String get heatmapShareHeatmap => 'SHARE HEATMAP';

  @override
  String get heatmapRenameDialogTitle => 'RENAME SURVEY';

  @override
  String get heatmapSave => 'Save';

  @override
  String get heatmapShareSubject => 'Torcav WiFi Heatmap';

  @override
  String get heatmapShareText => 'Sharing my WiFi heatmap result.';

  @override
  String get heatmapIssueTitle => 'Issue';

  @override
  String get heatmapGenericIssueBody => 'The survey could not finish. Check permissions and device sensors.';

  @override
  String get heatmapGoalTitle => 'What This Feature Does';

  @override
  String get heatmapGoalBody => 'It samples Wi-Fi as you walk, captures wall lines in AR, and then shows the home outline together with signal density.';

  @override
  String get heatmapWaitingForDataTitle => 'Waiting For Data';

  @override
  String get heatmapWaitingForDataBody => 'No signal sample has landed yet. Check motion and location permissions, then walk a few steps.';

  @override
  String get heatmapArCaptureTitle => 'AR Mode Active';

  @override
  String get heatmapArCaptureBody => 'Point the phone at room edges and door openings. The camera searches for wall lines while signal points are added automatically as you move.';

  @override
  String get heatmapMapCaptureTitle => '2D Map Active';

  @override
  String get heatmapMapCaptureBody => 'You are in the clearer 2D view. Samples keep arriving as you walk; if the outline stays weak, switch to AR mode.';

  @override
  String get heatmapReviewTitle => 'Survey Summary';

  @override
  String get heatmapReviewBodyNoSamples => 'There is a saved survey, but it still lacks meaningful signal samples.';

  @override
  String get heatmapReviewBodyReady => 'Coverage is readable. Use the summary below to inspect weak zones.';

  @override
  String get heatmapSamplesLabel => 'SAMPLES';

  @override
  String get heatmapWallsLabel => 'WALLS';

  @override
  String get heatmapCurrentSignalLabel => 'LIVE SIGNAL';

  @override
  String get heatmapAvgSignalLabel => 'AVG SIGNAL';

  @override
  String get heatmapWeakZonesLabel => 'WEAK ZONES';

  @override
  String get heatmapPlanSizeLabel => 'PLAN SIZE';

  @override
  String get heatmapNotAvailable => 'Not ready';

  @override
  String get heatmapNoSamplesHelper => 'Fills in as you start walking';

  @override
  String heatmapSamplesHelper(int count) {
    return '$count signal samples collected';
  }

  @override
  String get heatmapNoWallsHelper => 'AR pass may be needed for the outline';

  @override
  String heatmapWallsHelper(int count) {
    return '$count wall segments retained';
  }

  @override
  String get heatmapSignalUnavailableHelper => 'Wi-Fi reading has not arrived yet';

  @override
  String get heatmapSignalStrongHelper => 'Strong coverage';

  @override
  String get heatmapSignalFairHelper => 'Borderline but usable';

  @override
  String get heatmapSignalWeakHelper => 'Weak or problematic zone';

  @override
  String get heatmapWeakZoneHelperNone => 'No obvious dead zones';

  @override
  String get heatmapWeakZoneHelperOne => 'One problematic area';

  @override
  String heatmapWeakZoneHelperMany(int count) {
    return '$count weak areas detected';
  }

  @override
  String get heatmapPlanSizeHelper => 'Estimated span from captured trace';

  @override
  String get heatmapNoSurveyYetTitle => 'Start A Survey';

  @override
  String get heatmapNoSurveyYetBody => 'Start a walkthrough first. The result view will then show the outline and heatmap together.';

  @override
  String get heatmapWalkToBeginTitle => 'Start Walking';

  @override
  String get heatmapWalkToBeginBody => 'The trail and signal points appear as you take a few steps in each room.';

  @override
  String get heatmapMapViewLabel => '2D HARITA';

  @override
  String get heatmapResultViewLabel => 'SONUC GORUNUMU';

  @override
  String get heatmapFindingsTitle => 'NE ANLATIYOR?';

  @override
  String get heatmapInsightReady => 'The survey is now dense enough. One last room transition is enough before saving the result.';

  @override
  String get heatmapInsightTooEarly => 'It is still too early. After 4-5 samples across a few rooms, the result becomes readable.';

  @override
  String get heatmapInsightNoWalls => 'Signal is arriving but the outline is missing. Switch to AR and face the walls during another pass to improve the plan.';

  @override
  String heatmapInsightLive(int count) {
    return 'The live result is starting to read well. With $count samples, weak areas are becoming visible.';
  }

  @override
  String get heatmapReviewInsightNoSamples => 'This survey has no signal samples. If location or motion permissions are off, the app cannot build the heatmap.';

  @override
  String get heatmapReviewInsightNoPlan => 'The heatmap is present but the outline is weak. On the next run, use AR and face room boundaries while walking.';

  @override
  String get heatmapReviewInsightStrong => 'Coverage looks strong overall. No clear dead zones are visible, and the outline agrees with the signal trace.';

  @override
  String heatmapReviewInsightWeak(int count) {
    return '$count weak zones are visible. Moving the router more centrally or adding another access point may help.';
  }

  @override
  String heatmapReviewInsightBalanced(int count) {
    return 'Coverage is reasonably balanced, but it dips in $count spots. These are often corners, corridor ends, or heavy wall transitions.';
  }

  @override
  String get heatmapCloseReview => 'CLOSE REVIEW';

  @override
  String get heatmapNewSurvey => 'NEW SURVEY';

  @override
  String get heatmapFinishAndReview => 'FINISH & REVIEW';

  @override
  String get heatmapStartSurvey => 'START SURVEY';

  @override
  String get heatmapNewSurveyDialogTitle => 'NEW SURVEY';

  @override
  String heatmapDefaultSessionName(String time) {
    return 'Survey $time';
  }

  @override
  String get heatmapSessionNameField => 'Survey name';

  @override
  String get heatmapNewSurveyHint => 'Once the survey starts, signal samples are added automatically as you move. Switch to AR if you want a stronger room outline.';

  @override
  String get heatmapSavedSurveysTitle => 'SAVED SURVEYS';

  @override
  String get heatmapNoSavedSurveys => 'No saved surveys yet.';

  @override
  String heatmapSavedSurveySubtitle(int samples, int weak, String timestamp) {
    return '$samples samples · $weak weak zones · $timestamp';
  }

  @override
  String get heatmapDeleteSurveyTooltip => 'Delete survey';

  @override
  String get heatmapLegendTitle => 'COLOR GUIDE';

  @override
  String get heatmapLegendStrong => 'Strong';

  @override
  String get heatmapLegendFair => 'Fair';

  @override
  String get heatmapLegendWeak => 'Weak';

  @override
  String get heatmapCameraViewLabel => 'LIVE CAMERA';

  @override
  String get heatmapInfoSheetTitle => 'LIVE SURVEY DATA';

  @override
  String heatmapFeedStatus(String label, String status) {
    return '$label: $status';
  }

  @override
  String get heatmapActive => 'active';

  @override
  String get heatmapInactive => 'inactive';

  @override
  String get heatmapArViewLabel => 'AR VIEW';

  @override
  String get heatmapSwitchToMapHint => 'Return to the clearer 2D map';

  @override
  String get heatmapSwitchToArHint => 'Use AR to strengthen the outline';

  @override
  String get heatmapRouteLabel => 'NEXT STEP';

  @override
  String get heatmapPlanConfidenceLabel => 'PLAN CONFIDENCE';

  @override
  String get heatmapCoverageConfidenceLabel => 'COVERAGE CONFIDENCE';

  @override
  String get heatmapSignalConfidenceLabel => 'SIGNAL CONFIDENCE';

  @override
  String get heatmapMotionFeedLabel => 'Motion';

  @override
  String get heatmapCameraFeedLabel => 'Camera';

  @override
  String get heatmapPlanFeedLabel => 'Plan';

  @override
  String get heatmapGuidanceIdleTitle => 'Survey Setup';

  @override
  String get heatmapGuidanceCalibrationTitle => 'Starting Route';

  @override
  String get heatmapGuidanceSweepTitle => 'Filling Coverage';

  @override
  String get heatmapGuidanceWeakCheckTitle => 'Weak Zone Check';

  @override
  String get heatmapGuidanceWrapUpTitle => 'Ready To Save';

  @override
  String get heatmapGuidanceReviewTitle => 'Survey Quality';

  @override
  String get heatmapGuidanceIdleBody => 'Start a new survey. The app will combine motion, camera, and Wi-Fi traces into a cleaner floor plan.';

  @override
  String get heatmapGuidanceCalibrationBody => 'Walk straight for 5-8 steps to establish the first trace. Doorways and corner turns help anchor the layout faster.';

  @override
  String heatmapGuidanceSweepBody(String region) {
    return 'The $region side of the map is still sparse. Move there and collect 3-4 more samples.';
  }

  @override
  String get heatmapGuidanceWeakCheckBody => 'You are currently in a weak-signal area. Sweep this zone a bit more to confirm whether it is a real dead spot.';

  @override
  String get heatmapGuidanceWrapUpBody => 'Outline, coverage, and signal density are now strong enough. Save the result and read the plan/heatmap in review.';

  @override
  String heatmapGuidanceReviewBody(int progress, int count) {
    return 'This survey is $progress% complete. With $count samples, the result is readable.';
  }

  @override
  String get heatmapRouteFinish => 'Finish survey';

  @override
  String get heatmapRouteStart => 'Start survey';

  @override
  String get heatmapRouteWalkForward => 'Walk forward';

  @override
  String get heatmapRouteSweepWeak => 'Sweep weak zone';

  @override
  String get heatmapRouteWrapUp => 'Wrap up run';

  @override
  String get heatmapRouteReview => 'Review result';

  @override
  String get heatmapRegionLeft => 'left wing';

  @override
  String get heatmapRegionRight => 'right wing';

  @override
  String get heatmapRegionUpper => 'upper area';

  @override
  String get heatmapRegionLower => 'lower area';

  @override
  String get heatmapRegionKeep => 'keep sweeping';

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
  String get startNowCaps => 'START';

  @override
  String get howToFixSection => 'HOW TO FIX';

  @override
  String get endSurveyDialogTitle => 'End Survey?';

  @override
  String get endSurveyDialogBody => 'Your current survey data will be lost if you discard it. Save or Discard?';

  @override
  String get endSurveyReviewBody => 'Exit session review?';

  @override
  String get discardAction => 'DISCARD';

  @override
  String get exitAction => 'EXIT';

  @override
  String get continueAction => 'CONTINUE';

  @override
  String get discardSurveyDialogTitle => 'DISCARD SURVEY?';

  @override
  String get discardSurveyDialogBody => 'All recorded data for this session will be permanently deleted.';

  @override
  String get autoSamplingDistance => 'Auto-sampling Distance';

  @override
  String get appearanceLabel => 'Appearance';

  @override
  String get clearHistoryAction => 'CLEAR HISTORY';

  @override
  String get dataUsageWarningTitle => 'DATA USAGE WARNING';

  @override
  String get dataUsageWarningBody => 'This speed test downloads ~300–500 MB of data. If you are on a mobile/metered connection this may incur charges or consume your data allowance.';

  @override
  String latencyExcellentTitle(String ms) {
    return 'Latency: $ms ms — Excellent';
  }

  @override
  String latencyGoodTitle(String ms) {
    return 'Latency: $ms ms — Good';
  }

  @override
  String latencyAcceptableTitle(String ms) {
    return 'Latency: $ms ms — Acceptable';
  }

  @override
  String latencyHighTitle(String ms) {
    return 'Latency: $ms ms — High';
  }

  @override
  String get latencyExcellentBody => 'Near-instant response. Ideal for gaming, video calls, and real-time apps.';

  @override
  String get latencyGoodBody => 'Good for video calls and streaming. Most apps will feel responsive.';

  @override
  String get latencyAcceptableBody => 'Fine for browsing and streaming, but video calls may have slight delays.';

  @override
  String get latencyHighBody => 'Noticeable lag. Video calls and gaming may feel sluggish. Try moving closer to your router.';

  @override
  String jitterStableTitle(String ms) {
    return 'Jitter: $ms ms — Stable';
  }

  @override
  String jitterGoodTitle(String ms) {
    return 'Jitter: $ms ms — Good';
  }

  @override
  String jitterModerateTitle(String ms) {
    return 'Jitter: $ms ms — Moderate';
  }

  @override
  String jitterUnstableTitle(String ms) {
    return 'Jitter: $ms ms — Unstable';
  }

  @override
  String get jitterStableBody => 'Very consistent connection. Your packets arrive with minimal timing variation.';

  @override
  String get jitterGoodBody => 'Stable enough for calls and streaming. Minor variation is normal on Wi-Fi.';

  @override
  String get jitterModerateBody => 'Some inconsistency detected. Voice calls may sound choppy during spikes.';

  @override
  String get jitterUnstableBody => 'High variation — audio and video calls will likely break up. This can be caused by interference or a congested channel.';

  @override
  String downloadFastTitle(String mbps) {
    return 'Download: $mbps Mbps — Fast';
  }

  @override
  String downloadGoodTitle(String mbps) {
    return 'Download: $mbps Mbps — Good';
  }

  @override
  String downloadModerateTitle(String mbps) {
    return 'Download: $mbps Mbps — Moderate';
  }

  @override
  String downloadSlowTitle(String mbps) {
    return 'Download: $mbps Mbps — Slow';
  }

  @override
  String downloadFastBody(int streams) {
    return 'Handles $streams+ simultaneous HD streams with ease. Great for large households.';
  }

  @override
  String downloadGoodBody(int streams) {
    return 'Supports $streams simultaneous HD streams. Good for most households.';
  }

  @override
  String get downloadModerateBody => 'Enough for browsing and one or two SD streams. Large downloads will be slow.';

  @override
  String get downloadSlowBody => 'Very limited. Consider moving closer to your router or checking for interference.';

  @override
  String uploadFastTitle(String mbps) {
    return 'Upload: $mbps Mbps — Fast';
  }

  @override
  String uploadGoodTitle(String mbps) {
    return 'Upload: $mbps Mbps — Good';
  }

  @override
  String uploadLimitedTitle(String mbps) {
    return 'Upload: $mbps Mbps — Limited';
  }

  @override
  String uploadSlowTitle(String mbps) {
    return 'Upload: $mbps Mbps — Slow';
  }

  @override
  String get uploadFastBody => 'Excellent for video conferencing, cloud backups, and live streaming.';

  @override
  String get uploadGoodBody => 'Good for video calls and sharing files. Cloud uploads will be reasonable.';

  @override
  String get uploadLimitedBody => 'Enough for basic video calls. Large file uploads will take a while.';

  @override
  String get uploadSlowBody => 'Very slow upload. Live video and cloud sync will struggle.';

  @override
  String get packetLossPerfectTitle => 'Packet Loss: 0% — Perfect';

  @override
  String packetLossMinimalTitle(String pct) {
    return 'Packet Loss: $pct% — Minimal';
  }

  @override
  String packetLossHighTitle(String pct) {
    return 'Packet Loss: $pct% — High';
  }

  @override
  String get packetLossPerfectBody => 'Solid connection. No data packets were lost during the assessment.';

  @override
  String get packetLossMinimalBody => 'Very minor loss. Likely unnoticeable for most activities.';

  @override
  String get packetLossHighBody => 'Data is being dropped. This causes stuttering in calls and gaming. Check for Wi-Fi interference.';

  @override
  String loadedLatencyExcellentTitle(String ms) {
    return 'Loaded Latency: $ms ms — Excellent';
  }

  @override
  String loadedLatencyGoodTitle(String ms) {
    return 'Loaded Latency: $ms ms — Good';
  }

  @override
  String loadedLatencyFairTitle(String ms) {
    return 'Loaded Latency: $ms ms — Fair';
  }

  @override
  String loadedLatencyPoorTitle(String ms) {
    return 'Loaded Latency: $ms ms — Poor';
  }

  @override
  String get loadedLatencyExcellentBody => 'Your network stays responsive even when downloading. Excellent router quality.';

  @override
  String get loadedLatencyGoodBody => 'Response time increases slightly under load, but stays very usable.';

  @override
  String get loadedLatencyFairBody => 'Noticeable delay when others are using the network. Gaming while downloading may suffer.';

  @override
  String get loadedLatencyPoorBody => 'High Bufferbloat. Connection becomes unresponsive during large downloads. Consider enabling QoS on your router.';

  @override
  String get bufferbloatGradeLabel => 'BUFFERBLOAT GRADE';

  @override
  String get bufferbloatGradeA => 'Excellent bufferbloat control. Your router keeps latency low even under heavy load.';

  @override
  String get bufferbloatGradeB => 'Good bufferbloat. Minor latency increase under load — most users won\'t notice.';

  @override
  String get bufferbloatGradeC => 'Moderate bufferbloat. Gaming and video calls may lag when others are downloading.';

  @override
  String get bufferbloatGradeD => 'Poor bufferbloat. Connection becomes sluggish under load. Enable QoS on your router.';

  @override
  String get bufferbloatGradeE => 'Severe bufferbloat. Real-time apps will fail during concurrent downloads.';

  @override
  String get bufferbloatGradeF => 'Critical bufferbloat. Your router does not control queue depth. Upgrade firmware or hardware.';

  @override
  String get speedTestDisclaimer => 'Results reflect speed to Cloudflare\'s nearest server and are affected by Wi-Fi, device hardware, and PoP distance. They are not a direct measure of your ISP contract speed.';

  @override
  String get clearAllHistoryAction => 'CLEAR ALL HISTORY';

  @override
  String get deleteAllHistoryConfirm => 'Delete all speed test records? This cannot be undone.';

  @override
  String get deleteAllAction => 'DELETE ALL';

  @override
  String whyIsThisLabel(String level) {
    return 'WHY IS THIS $level?';
  }

  @override
  String get noSpecificConcerns => 'No specific concerns logged for this device. The badge reflects an aggregate score.';

  @override
  String get whatToDoLabel => 'WHAT TO DO';

  @override
  String get trustLevelSafe => 'SAFE';

  @override
  String get trustLevelCaution => 'CAUTION';

  @override
  String get trustLevelRisky => 'RISKY';

  @override
  String cveDatabaseLabel(String freshness) {
    return 'CVE DATABASE — $freshness';
  }

  @override
  String get howToUpdateLabel => 'HOW TO UPDATE';

  @override
  String get vulnDbFreshLabel => 'FRESH';

  @override
  String get vulnDbAgingLabel => 'AGING';

  @override
  String get vulnDbStaleLabel => 'STALE';

  @override
  String get vulnDbFreshMessage => 'Vulnerability lookups against this database are up to date.';

  @override
  String get vulnDbAgingMessage => 'The local vulnerability database is over a month old. A clean scan still has value but consider refreshing soon.';

  @override
  String get vulnDbStaleMessage => 'This database is more than 90 days old. A \"no findings\" result no longer means the network is safe — many newer CVEs may not be represented here yet.';

  @override
  String vulnDbEntriesInfo(String version, int count, int days) {
    return 'v$version · $count entries · $days days old';
  }

  @override
  String get wipeAllDialogTitle => 'WIPE ALL DATA';

  @override
  String get wipeAllDialogBody => 'This will permanently delete all local scan history, speed test records, security events, channel ratings and in-memory snapshots. This action cannot be undone.';

  @override
  String get wipeAllAction => 'WIPE ALL';

  @override
  String get allDataWiped => 'All local data wiped.';

  @override
  String get systemDefault => 'System Default';

  @override
  String portScanTimeoutMs(int ms) {
    return '$ms ms';
  }

  @override
  String get legendAndNodes => 'LEGEND & NODES';

  @override
  String get legendGateway => 'GATEWAY';

  @override
  String get legendGatewayDesc => 'Central network entry point';

  @override
  String get legendAccessPoint => 'ACCESS POINT';

  @override
  String get legendAccessPointDesc => 'WiFi signal distributor';

  @override
  String get legendMobile => 'MOBILE';

  @override
  String get legendMobileDesc => 'Personal handheld devices';

  @override
  String get legendIot => 'IOT';

  @override
  String get legendIotDesc => 'Smart home & sensors';

  @override
  String get legendDevice => 'DEVICE';

  @override
  String get legendDeviceDesc => 'Computers, TVs, etc.';

  @override
  String get surveyStageStandby => 'STANDBY';

  @override
  String get surveyStageInitializing => 'INITIALIZING';

  @override
  String get surveyStageSweepRooms => 'SWEEP ROOMS';

  @override
  String get surveyStageWeakZone => 'WEAK ZONE';

  @override
  String get surveyStageWrapUp => 'WRAP UP';

  @override
  String get surveyStageReview => 'REVIEW';

  @override
  String get connectionTypesHeader => 'CONNECTION TYPES';

  @override
  String get connTypeSolidLineLabel => 'Solid Line (Blue)';

  @override
  String get connTypeSolidLineDesc => 'High-speed wired Ethernet connection';

  @override
  String get connTypeGradientLabel => 'Glowing Gradient (Cyan)';

  @override
  String get connTypeGradientDesc => 'Wireless WiFi connection';

  @override
  String get connTypePulsingLabel => 'Pulsing Data Point';

  @override
  String get connTypePulsingDesc => 'Active traffic detected on the link';

  @override
  String get uploadLabel => 'UPLOAD';

  @override
  String get downloadLabel => 'DOWNLOAD';

  @override
  String get speedTestSemanticsIdle => 'Speed test gauge. Tap to start.';

  @override
  String speedTestSemanticsRunning(String mbps) {
    return 'Speed test running — $mbps Mbps download. Tap to stop.';
  }

  @override
  String speedTestSemanticsComplete(String dl, String ul) {
    return 'Speed test complete — $dl Mbps download, $ul Mbps upload.';
  }

  @override
  String get measurementLockedTitle => 'MEASUREMENT LOCKED';

  @override
  String get measurementLockNoWifi => 'Connect to a Wi-Fi network to lock the survey target.';

  @override
  String measurementLockReconnect(String bssid) {
    return 'Reconnect to $bssid to resume sampling.';
  }

  @override
  String get waitingForSignalTitle => 'WAITING FOR FRESH SIGNAL';

  @override
  String get waitingForSignalBody => 'RSSI is older than 3 seconds. Walk briefly or hold position for a new scan.';

  @override
  String get signalDroppedTitle => 'SIGNAL DROPPED';

  @override
  String get signalDroppedBody => 'Wi-Fi signal is below -85dBm. Move closer to the Access Point.';

  @override
  String get compassDriftTitle => 'COMPASS DRIFT DETECTED';

  @override
  String get measurementLockMagnetic => 'Magnetic interference found. Walk in a figure-8 or tap Realign.';

  @override
  String get placeSurveyOriginTitle => 'PLACE SURVEY ORIGIN';

  @override
  String get measurementLockAnchor => 'Tap a detected plane to anchor the AR survey before recording points.';

  @override
  String get trackingLostTitle => 'TRACKING LOST';

  @override
  String get measurementLockTracking => 'Motion tracking is unavailable. Move slowly until tracking returns.';

  @override
  String get readyBannerTapFinish => 'Tap to finish scan';

  @override
  String get ssidChipLock => 'LOCK';

  @override
  String get ssidChipHold => 'HOLD';

  @override
  String get guidanceStageIdle => 'Idle';

  @override
  String get guidanceStageInitializing => 'Initializing';

  @override
  String get guidanceStageMappingSignal => 'Mapping Signal';

  @override
  String get guidanceStageScanningWeakZones => 'Scanning Weak Zones';

  @override
  String get guidanceStageReadyToFinish => 'Ready to Finish';

  @override
  String get guidanceStageReviewing => 'Reviewing';

  @override
  String get signalProbeHint => 'Try tapping closer to a captured signal point.';

  @override
  String get wifiSecurityOpen => 'OPEN';

  @override
  String get newSessionPermissionsBody => 'To generate accurate heatmaps and map your network coverage, Torcav requires access to certain device features:';

  @override
  String get newSessionPermLocation => 'Location (to map signal to coordinates)';

  @override
  String get newSessionPermActivity => 'Activity Recognition (to track steps and movement)';

  @override
  String get newSessionPermCamera => 'Camera (optional, for visual mapping features)';

  @override
  String get reportsMacMaskDesc => 'Masks last 3 octets (XX:XX:XX) before export';

  @override
  String get reportsShareSubject => 'Torcav Scan Report';

  @override
  String exportNoDataYet(String label) {
    return 'No data in \"$label\" yet.';
  }

  @override
  String get exportSubject => 'Torcav local data export';

  @override
  String exportFailedError(String error) {
    return 'Export failed: $error';
  }

  @override
  String get tapToStart => 'TAP TO START';

  @override
  String get tapToStop => 'TAP TO STOP';

  @override
  String get liveWifi => 'LIVE WI-FI';

  @override
  String get signalProbeTitle => 'SIGNAL PROBE';

  @override
  String get statusOptimal => 'OPTIMAL';

  @override
  String get statusFair => 'FAIR';

  @override
  String get statusCritical => 'CRITICAL';

  @override
  String daysCount(int count) {
    return '${count}d';
  }

  @override
  String secondsCount(int count) {
    return '${count}s';
  }

  @override
  String millisecondsCount(int count) {
    return '$count ms';
  }

  @override
  String get languageEnglish => 'English 🇺🇸';

  @override
  String get languageTurkish => 'Türkçe 🇹🇷';

  @override
  String get languageKurdish => 'Kurdî ☀️';

  @override
  String get languageGerman => 'Deutsch 🇩🇪';

  @override
  String get sdWeakSignalWhatIs => 'Signal strength (RSSI) measures how loudly your device hears the router. Below about −70 dBm, Wi-Fi has to drop to slower, more redundant encodings to stay reliable.';

  @override
  String get sdWeakSignalWhyItMatters => 'A weak signal forces the radio into low-rate modes. Even if your internet plan is fast, the Wi-Fi link itself becomes the ceiling — downloads stall, video calls drop, and pages take longer.';

  @override
  String get sdWeakSignalHowToFix1 => 'Move closer to the router or to a less obstructed spot.';

  @override
  String get sdWeakSignalHowToFix2 => 'Add a mesh node / Wi-Fi extender in this area.';

  @override
  String get sdWeakSignalHowToFix3 => 'If your router supports 5 GHz or 6 GHz on this SSID, use that band when you are in line-of-sight of it.';

  @override
  String get sdWeakSignalHowToFix4 => 'Check that the router is not buried inside a cabinet, behind a TV, or next to a microwave.';

  @override
  String sdWeakSignalEstimate(String gain) {
    return 'Estimated gain: up to +$gain Mbps download if you can pull the device closer to the router.';
  }

  @override
  String get sdCrowdedChannelWhatIs => 'Wi-Fi channels are shared spectrum. When several nearby access points transmit on the same channel, they have to take turns — air-time is split between all of them, including yours.';

  @override
  String get sdCrowdedChannelWhyItMatters => 'On a crowded channel your throughput drops even when no one in your home is using the network. The radio is healthy, but it has to wait for its turn to talk.';

  @override
  String get sdCrowdedChannelHowToFix1 => 'Open the router admin page and switch the Wi-Fi channel manually (Channel Rating in the app suggests the cleanest one).';

  @override
  String get sdCrowdedChannelHowToFix2 => 'On 2.4 GHz, prefer channels 1 / 6 / 11 — they do not overlap.';

  @override
  String get sdCrowdedChannelHowToFix3 => 'If your router supports 5 GHz or 6 GHz, move the device to that band: there are far more clean channels available.';

  @override
  String get sdCrowdedChannelHowToFix4 => 'For dual-band routers, give each band its own SSID so devices stop flipping back to a crowded 2.4 GHz channel.';

  @override
  String sdCrowdedChannelEstimate(String gain) {
    return 'Estimated gain: up to +$gain Mbps download after switching to a quieter channel.';
  }

  @override
  String get sdBufferbloatWhatIs => 'Bufferbloat is the latency that builds up inside your router\'s send buffers when the link is fully loaded — typical packets have to queue behind a backlog of bulk traffic.';

  @override
  String get sdBufferbloatWhyItMatters => 'Your download speed can look great while a file is in flight, but voice calls jitter, video conferences freeze, and games lag — anything time-sensitive is held up behind the queue.';

  @override
  String get sdBufferbloatHowToFix1 => 'Enable QoS / SQM (sometimes called \"Smart Queue Management\" or \"Adaptive QoS\") in your router admin page.';

  @override
  String get sdBufferbloatHowToFix2 => 'Update the router firmware — modern firmware ships better queue discipline by default.';

  @override
  String get sdBufferbloatHowToFix3 => 'If the router is many years old and lacks SQM, replacing it with a recent model is often the only real fix.';

  @override
  String get sdBufferbloatHowToFix4 => 'Cap upload bandwidth in the router slightly below your real plan (e.g. 90%) so the queue lives on the router, not at the ISP.';

  @override
  String sdBufferbloatEstimate(String reduction) {
    return 'Estimated gain: about −$reduction ms loaded latency. Calls and gaming will feel responsive even during large downloads.';
  }

  @override
  String get sdIspSlowWhatIs => 'Your Wi-Fi link is healthy and the radio could carry far more than what is actually flowing through it. The bottleneck sits upstream of the router.';

  @override
  String get sdIspSlowWhyItMatters => 'No amount of router or Wi-Fi tuning will help — the link from your ISP to the router is the ceiling. Treat this as data for a plan-upgrade or support call, not as a Wi-Fi problem.';

  @override
  String get sdIspSlowHowToFix1 => 'Re-run the test with a wired Ethernet cable to confirm the radio is not at fault.';

  @override
  String get sdIspSlowHowToFix2 => 'Check the ISP plan you are paying for — the test result should match it within ~80% on a good day.';

  @override
  String get sdIspSlowHowToFix3 => 'Try at different times of day. If only evenings are slow, the ISP segment may be congested.';

  @override
  String get sdIspSlowHowToFix4 => 'If the result is consistently far below your plan, contact the ISP with the speed test output.';

  @override
  String sdIspSlowEstimate(String phy, String download) {
    return 'Your Wi-Fi can carry up to ~$phy Mbps; you are currently getting $download Mbps. The gap is upstream of the router.';
  }

  @override
  String get sdSlowDnsWhatIs => 'DNS turns names like example.com into the IP addresses your device actually connects to. Every page load fires off a handful of these lookups before any data flows.';

  @override
  String get sdSlowDnsWhyItMatters => 'Slow DNS does not lower your download speed — it adds a delay at the start of every connection. The web feels \"laggy\" even when speed tests look fine.';

  @override
  String get sdSlowDnsHowToFix1 => 'Switch your device or router DNS to a fast public resolver — 1.1.1.1 (Cloudflare), 8.8.8.8 (Google), or 9.9.9.9 (Quad9).';

  @override
  String get sdSlowDnsHowToFix2 => 'Enable DNS-over-HTTPS (DoH) or DNS-over-TLS (DoT) in your OS or browser to also encrypt the lookups.';

  @override
  String get sdSlowDnsHowToFix3 => 'If your ISP\'s DNS is slow, set the resolver on the router so the whole household benefits, not just one device.';

  @override
  String sdSlowDnsEstimate(int reduction) {
    return 'Estimated gain: about −$reduction ms per name lookup. Page loads usually feel 5–20% snappier because each page kicks off a dozen lookups.';
  }

  @override
  String get sdHealthyWhatIs => 'Speed Doctor checks five things: signal strength, channel congestion, speed-under-load (bufferbloat), download throughput vs Wi-Fi capacity, and DNS resolution time.';

  @override
  String get sdHealthyWhyItMatters => 'None of those crossed an alert threshold this run. Your link is in good shape right now — re-run the test if you start noticing a problem to see whether anything shifted.';

  @override
  String sdMetricRssi(int rssi) {
    return 'RSSI: $rssi dBm';
  }

  @override
  String sdThresholdRssi(int healthy, int severe) {
    return 'Healthy ≥ $healthy dBm · Severe ≤ $severe dBm';
  }

  @override
  String sdMetricChannel(int channel, String score) {
    return 'Channel $channel · score $score/10';
  }

  @override
  String sdThresholdChannel(String healthy, String severe) {
    return 'Healthy ≥ $healthy · Severe ≤ $severe';
  }

  @override
  String sdMetricBufferbloat(String induced, String latency, String loaded) {
    return 'Loaded latency Δ: $induced ms ($latency → $loaded)';
  }

  @override
  String sdThresholdBufferbloat(String healthy, String severe) {
    return 'Healthy ≤ $healthy ms · Severe ≥ $severe ms';
  }

  @override
  String sdMetricIsp(String download, String phy) {
    return 'Download: $download Mbps · PHY: $phy Mbps';
  }

  @override
  String sdMetricIspNoPhy(String download) {
    return 'Download: $download Mbps';
  }

  @override
  String sdThresholdIsp(String healthy) {
    return 'Healthy ≥ $healthy Mbps when radio is uncongested';
  }

  @override
  String sdMetricDns(String name, int latency) {
    return 'Best resolver: $name · $latency ms';
  }

  @override
  String sdThresholdDns(int healthy, int severe) {
    return 'Healthy ≤ $healthy ms · Severe ≥ $severe ms';
  }

  @override
  String get networkContextHomeLabel => 'Home';

  @override
  String get networkContextPublicLabel => 'Public';

  @override
  String get networkContextGuestLabel => 'Guest';

  @override
  String get networkContextUnknownLabel => 'Unknown';

  @override
  String get noChangeLabel => 'no change';

  @override
  String get sinceLastScanLabel => 'since last scan';

  @override
  String get allClearLabel => 'all clear';

  @override
  String get tapToTestLabel => 'tap to test';

  @override
  String get gameProfileLabel => 'Game profile';

  @override
  String get profileGeneric => 'Generic UDP Game';

  @override
  String get notificationChannelSecurityCritical => 'Critical Alerts';

  @override
  String get notificationChannelSecurityHigh => 'High Priority';

  @override
  String get notificationChannelSecurityMedium => 'Medium Priority';

  @override
  String get notificationChannelSecurityWarning => 'Warnings';

  @override
  String get notificationChannelSecurityLow => 'Low Priority';

  @override
  String get notificationChannelSecurityInfo => 'Information';

  @override
  String get notificationChannelSecurityDescription => 'Security alert notifications';

  @override
  String get scanCompleteTitle => 'Scan Complete';

  @override
  String scanCompleteBody(int count, int seconds) {
    return 'Found $count networks in ${seconds}s';
  }

  @override
  String get wifiChannelQualityDroppedTitle => '📶 Wi-Fi channel quality dropped';

  @override
  String wifiChannelQualityDroppedBody(int channel, String rating, int recommendedChannel, String recommendedRating) {
    return 'Channel $channel is now $rating/10. Channel $recommendedChannel is at $recommendedRating/10 — consider switching.';
  }

  @override
  String attackDetectedTitle(String attackType) {
    return '⚠️ Attack Detected: $attackType';
  }

  @override
  String get stabilizerJitterSpikeTitle => 'Jitter spike detected';

  @override
  String get stabilizerFasterDnsTitle => 'Faster DNS available';

  @override
  String get stabilizerPacketLossTitle => 'Persistent packet loss';

  @override
  String stabilizerJitterSpikeBody(String threshold, int window) {
    return 'Jitter exceeded $threshold ms for $window samples. Cycling the tunnel may break a sticky bad path.';
  }

  @override
  String stabilizerFasterDnsBody(String label) {
    return 'A faster DNS ($label) is available.';
  }

  @override
  String stabilizerPacketLossBody(String loss) {
    return 'Packet loss is $loss%. Dual-interface send (Wi-Fi + cellular) can mask transient drops.';
  }

  @override
  String get lanDiscoveryTitle => 'LAN Devices Discovered';

  @override
  String get lanDiscoveryRecommendation => 'Ensure you recognize all devices on your local network.';

  @override
  String get gatewayPortsExposedTitle => 'Gateway Ports Exposed';

  @override
  String get gatewayPortsExposedRecommendation => 'Disable unnecessary services on the gateway router and ensure strong passwords.';

  @override
  String get openServiceDetectedTitle => 'Open Service Detected';

  @override
  String get openServiceDetectedRecommendation => 'Ensure this service is intended to be accessible.';

  @override
  String lanDeviceDiscoveredTitle(String name) {
    return 'LAN Device: $name';
  }

  @override
  String get lanDeviceDiscoveredRecommendation => 'Verify this device is yours. Malicious devices often hide in the LAN.';

  @override
  String get rule_arp_spoofing_title => 'ARP Spoofing Detected';

  @override
  String get rule_arp_spoofing_desc => 'Multiple MAC addresses are claiming the same IP address. An attacker may be intercepting your traffic.';

  @override
  String get rule_arp_spoofing_rec => 'Switch to a different network or use a VPN immediately.';

  @override
  String get rule_dns_hijacking_title => 'DNS Hijacking Detected';

  @override
  String get rule_dns_hijacking_desc => 'Your DNS queries are being redirected to an unexpected server. This allows an attacker to control which websites you visit.';

  @override
  String get rule_dns_hijacking_rec => 'Switch to a VPN immediately. Your DNS queries are being tampered with.';

  @override
  String channelWithRating(int channel, String rating) {
    return 'CH $channel ($rating)';
  }

  @override
  String lanDiscoveryEvidence(String devices) {
    return 'Discovered: $devices';
  }

  @override
  String gatewayPortsExposedEvidence(String ports) {
    return 'Open Ports: $ports';
  }

  @override
  String openServiceDetectedEvidence(String ip, int port, String service) {
    return 'Target: $ip, Port: $port, Service: $service';
  }

  @override
  String lanDeviceDiscoveredEvidence(String ip, String mac, String vendor) {
    return 'IP: $ip, MAC: $mac, Vendor: $vendor';
  }

  @override
  String evidenceNoEncryption(String network) {
    return 'The access point advertises no encryption for $network.';
  }

  @override
  String lanDiscoveryDesc(int count) {
    return 'Active scanning identified $count devices on this network.';
  }

  @override
  String gatewayPortsExposedDesc(String ip) {
    return 'Host $ip has open ports that may be vulnerable.';
  }

  @override
  String openServiceDetectedDesc(String ip, String service, int port) {
    return 'Host $ip is running $service on port $port.';
  }
}
