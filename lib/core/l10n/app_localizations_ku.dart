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
  String get deviceTypeRouterGateway => 'Router / Dergeh';

  @override
  String get deviceTypeAccessPoint => 'Xala Gihîştinê';

  @override
  String get deviceTypeDesktop => 'Sermasê';

  @override
  String get deviceTypeLaptop => 'Laptop';

  @override
  String get deviceTypeMobileDevice => 'Cîhazê Mobîl';

  @override
  String get deviceTypeTablet => 'Tablet';

  @override
  String get deviceTypeSmartTV => 'TV Aqilmend';

  @override
  String get deviceTypeNASStorage => 'NAS/Cîhê Hilanînê';

  @override
  String get deviceTypeGameConsole => 'Konsola Lîstikê';

  @override
  String get deviceTypeIPCamera => 'Kamera IP';

  @override
  String get deviceTypeSmartSpeaker => 'Deng-bêjê Aqilmend';

  @override
  String get deviceTypeServer => 'Server';

  @override
  String get deviceTypeUnknown => 'Nenas';

  @override
  String get notificationOpenAction => 'Agahdariyê veke';

  @override
  String get quickScan => 'Tarana Bilez';

  @override
  String get deepScan => 'Tarana Kûr';

  @override
  String get scanModesTitle => 'Modên Taranê';

  @override
  String get scanModesInfo =>
      'Tarana bilez guhdariya weşanan dike. Tarana kûr bi awayekî çalak toran diceribîne.';

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
  String get networkLogs => 'LOGÊN TORÊ';

  @override
  String get connectedStatusCaps => 'GIRÊDAYÎ';

  @override
  String get disconnectedStatusCaps => 'QUTKIRÎ';

  @override
  String get ipLabel => 'IP';

  @override
  String get gatewayLabel => 'DERGEH';

  @override
  String get latestSnapshotTitle => 'Wêneyê Dawî ya Torê';

  @override
  String get noSnapshotAvailable => 'Daneyên wêneyê tune...';

  @override
  String get scanComparisonTitle => 'BERAWIRDKIRINA TARANÊ';

  @override
  String get comparisonNeedsTwoScans =>
      'Berawirdkirin herî kêm 2 taranan dixwaze.\n\nJi bo dîtina guhertinan taranek din bike.';

  @override
  String get noChangesDetected =>
      'Di navbera her du taranên dawî de tu guhertin nehatin dîtin.';

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
  String get notAvailable => 'Tune';

  @override
  String get dbmCaps => 'DBM';

  @override
  String get interfaceLabel => 'NAVBER';

  @override
  String bandwidthLabel(int width) {
    return '$width MHz';
  }

  @override
  String get wifiStandardLegacy => 'Wi-Fi (kevn)';

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
  String get deviceTypeWorkstation => 'Îstgeha Kar';

  @override
  String get deviceTypePrinterIoT => 'Çapker/IoT';

  @override
  String get vendorAndroidRestricted => 'Cîhaza Android (Sînordar)';

  @override
  String get vendorAndroidLimited => 'Nenas (Android Sînordar)';

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
  String get gatewayDevice => 'DERGEH';

  @override
  String get mobileDevice => 'MOBÎL';

  @override
  String get deviceLabel => 'AMÛR';

  @override
  String get iotDevice => 'IOT';

  @override
  String get analyzingNode => 'GIRÊK ANALÎZ DIKE';

  @override
  String get topologyGuideTitle => 'REHBERA TOPOLOJIYÊ';

  @override
  String get topologyGuideDesc =>
      'Avahiya torê û girêdana cîhazên xwe fêm bikin.';

  @override
  String get gatewayTitle => 'Dergeh';

  @override
  String get gatewayDesc =>
      'Mêjiyê navendî yê torê we. Hemû tîrafîka derveyî ji vê nodê derbas dibe.';

  @override
  String get deviceLayersTitle => 'Qatên Cîhazan';

  @override
  String get deviceLayersDesc =>
      'Cîhaz li gorî rola xwe têne kategorîzekirin: Bingehîn (Router/AP), Mobîl, û IoT/Periferî.';

  @override
  String get pathwaysTitle => 'Rêyên Girêdanê';

  @override
  String get pathwaysDesc =>
      'Torên nûjen girêdanên bi têl (Ethernet) û bêtêl (Wi-Fi) tevlihev dikin. Xetên rast girêdanên bi têl ên leza bilind nîşan didin, xetên xelekî jî beşên bêtêl nîşan didin.';

  @override
  String get pingAction => 'GECIKIYAYÎ TEST BIKE';

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
  String get settingsAiClassification => 'Dabeşkirina Cîhazê ya bi AI';

  @override
  String get settingsAiClassificationDesc =>
      'Naskirin û dîtina cîhazan bi AI ya herêmî çalak dike.';

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
  String get noIdentifiedNetworks =>
      'Di arşîvên laboratûwarê de torên nasnavkirî tune';

  @override
  String get securityTimeline => 'Rêzika Demê ya Ewlehiyê';

  @override
  String get noSecurityEvents => 'Tu bûyerên ewlehiyê nehatine tomarkirin';

  @override
  String get dnsSecurityTitle => 'TEVAHIYA DNS';

  @override
  String get dnsPerformanceBenchmark => 'PÎVANA PERFORMANSÊ';

  @override
  String get dnsRecommended => 'TÊNE PÊŞNIYARKIRIN';

  @override
  String dnsResultLatency(int ms) {
    return '$ms ms';
  }

  @override
  String get osNetworkDevice => 'Cîhaza Torê (TTL≈255)';

  @override
  String get osWindows => 'Windows (TTL≈128)';

  @override
  String get osLinuxMacOS => 'Linux / macOS (TTL≈64)';

  @override
  String get osUnknown => 'OS Nenas';

  @override
  String get osDetectedLabel => 'OS HAT DÎTIN';

  @override
  String get hostnameLookupAction => 'HOSTNAME LI BER BIGERE';

  @override
  String get osDetectAction => 'OS BIBÎNE';

  @override
  String get portScanAction => 'PORTAN BITARE';

  @override
  String get latencyLabel => 'DERENGÎ';

  @override
  String get hostnameLabel => 'HOSTNAME';

  @override
  String get filterAll => 'HEMÛ';

  @override
  String get filterCore => 'BINGEHÎN';

  @override
  String get filterMobile => 'MOBÎL';

  @override
  String get filterIot => 'IOT';

  @override
  String get filterOther => 'YÊN DIN';

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
    return 'ARMANC: $target';
  }

  @override
  String get dnsStatusPending => 'LI BENDÊ';

  @override
  String get dnsStatusNotAssessed => 'NEHATIYE NIRXANDIN';

  @override
  String get dnsStatusInconsistent => 'NEBIÇEWT';

  @override
  String get dnsStatusEnabled => 'ÇALAK';

  @override
  String get dnsStatusDisabled => 'NEÇALAK';

  @override
  String get notAvailableCaps => 'TUNE';

  @override
  String get evilTwinSignalOuiMismatch =>
      'Her du xala gihîştinê ji hilberînerên cûda ne (pêşengên MAC li hev nayên).';

  @override
  String get evilTwinSignalSecurityDowngrade =>
      'Cot şîfrekirinek cûda diyar dike — mînaka êrîşa daxistinê (mînak: tora rastîn = WPA3, ya sexte = WPA2 an Vekirî).';

  @override
  String get evilTwinSignalSameBandChannelDrift =>
      'Herdu li heman bandê belav dibin lê li ser kanalên gelek cûda — antenên rastîn kêm caran ewqas dûr diçin.';

  @override
  String get evilTwinSignalChannelWidthMismatch =>
      'Ew firehiyên kanalê yên cûda bikar tînin (mînak: 80 MHz li hember 20 MHz). Amûrên xirab ên erzan bi gelemperî ji cîhaza ku kopî dikin teng dixebitin.';

  @override
  String get evilTwinSignalWpsToggleMismatch =>
      'WPS li ser yek xala gihîştinê çalak e lê li ser ya din ne.';

  @override
  String get evilTwinSignalPmfToggleMismatch =>
      'Çarçoveyên Rêveberiyê yên Parastî (802.11w) li ser aliyekî çalak in lê li aliyê din ne.';

  @override
  String get evilTwinSignalHiddenVsVisible =>
      'Yek xala gihîştinê veşartî ye, ya din navê xwe eşkere belav dike.';

  @override
  String get evilTwinSignalSharedMldMac =>
      'Herdu heman MAC ya pir-girêdanê ya Wi-Fi 7 parve dikin — ew bi rastî heman xala gihîştinê ya fîzîkî ne.';

  @override
  String get evilTwinSignalBssidProximity =>
      'Navnîşanên wan ên MAC tenê di reqemên dawî de cûda dibin — hilberîner ev şêwe ji bo antenên li ser heman routerê bikar tînin.';

  @override
  String get evilTwinSignalCrossBandSibling =>
      'Ew li ser bandên cûda yên Wi-Fi ne (2.4 / 5 / 6 GHz) lê heman hilberîner û ewlehiyê parve dikin — şêwaza klasîk a routera du-bandî.';

  @override
  String get evilTwinSignalKnownMeshVendor =>
      'Herdu navnîşanên MAC yên malbateke naskirî ya router-a mesh (Eero, Google Nest, Asus AiMesh, Netgear Orbi, TP-Link Deco, an Linksys Velop) in. Nodên mesh bi qest heman navê Wi-Fi parve dikin.';

  @override
  String get evilTwinSafeHeadline => 'Dişibihe heman router li ser bandên cûda';

  @override
  String get evilTwinSafeWhatIs =>
      'Piraniya routerên malê heman navê Wi-Fi (SSID) li ser 2.4 GHz, 5 GHz û carinan 6 GHz belav dikin. Telefona we wan wek xalên gihîştinê yên cûda dibîne her çend ew yek cîhaz bin jî. Pergalên mesh jî bi heman awayî dixebitin — her nod bi yek navê hevpar.';

  @override
  String get evilTwinSafeWhyItMatters =>
      'Ev cotbûn normal e û tê hêvîkirin — hewce bi tu tiştî nake. Em vê tenê nîşan didin da ku hûn zanibin em kontrol kirin û redkirin.';

  @override
  String get evilTwinSafeAction =>
      'Tiştek nake. Ev heman router e an beşek ji meshê we ye.';

  @override
  String get evilTwinSafePhrase =>
      'Me ev cot kontrol kir û bi şêwaza routereke normal a du-bandî an meshê re li hev tê — ne êrîş e.';

  @override
  String get evilTwinNoPatternHeadline => 'Şêwazek evil-twin nehat dîtin';

  @override
  String get evilTwinNoPatternAction =>
      'Tiştek lezgîn tune. Heke guman dikin tiştek li derdora we guherî ye, tarîkirinê dîsa bimeşînin.';

  @override
  String get evilTwinNoPatternPhrase =>
      'Di navbera xalên gihîştinê yên vî navî de hin cudahiyên piçûk hene, lê ne ewqas ku wek êrîşê xuya bike.';

  @override
  String get evilTwinWhatIs =>
      '\"Evil twin\" torek Wi-Fi ya sexte ye ku navê ya rastîn kopî dike — bi gelemperî tora we ya malê an cihê kar, an hotspoteke qehwexaneyê ya navdar. Armanc ev e ku telefona we li şûna ya rastîn bi routera êrîşkar ve girê bide.';

  @override
  String get evilTwinWhyItMatters =>
      'Gava cîhaza we li ser Wi-Fi ya êrîşkar be, ew dikare tîrafîka neşîfrekirî bixwîne an biguherîne, rûpelên têketina sexte nîşan bide, we ber bi malperên dişibin re bişîne, an şîfreyên ku di sepanên ku HTTPS rast bikar naînin de têne nivîsîn bigire. Bankîng, e-name û peyamnasî armancên adetî ne.';

  @override
  String get evilTwinHighHeadline =>
      'Şêwaza evil-twin ya bihêz — vê torê wek nebawer bihesibînin';

  @override
  String get evilTwinMediumHeadline =>
      'Şêwaza cêwî ya guman — berî girêdanê piştrast bikin';

  @override
  String get evilTwinLowHeadline => 'Sînyala cêwî ya lawaz — çav lê bigerînin';

  @override
  String evilTwinHighPhrase(int pct) {
    return 'Baweriya: %$pct. Gelek cudahiyên bihêz di navbera her du xalên gihîştinê yên vî navî de. Ev şêwaza ku êrîşkarek gava xwe wek Wi-Fiyek dide xuyakirin çêdike ye.';
  }

  @override
  String evilTwinMediumPhrase(int pct) {
    return 'Baweriya: %$pct. Gelek hûrgilî di navbera xalên gihîştinê yên vî navî de li hev nayên. Dibe ku bêzirar be, lê berî bawerî pêkanînê piştrast bikin.';
  }

  @override
  String evilTwinLowPhrase(int pct) {
    return 'Baweriya: %$pct. Çend cudahiyên piçûk hatin dîtin. Bi îhtîmaleke mezin bêzirar e — hatiye nîşankirin da ku hûn ducar kontrol bikin.';
  }

  @override
  String get evilTwinActionPasswords =>
      'Dema bi vê Wi-Fiyê ve girêdayî ne, şîfre, agahiyên dravdanê, an kodên du-faktorî tênexin.';

  @override
  String get evilTwinActionCheckMac =>
      'Heke hûn li malê ne, MAC (BSSID) ya rastîn a li binê routera we hatiye çapkirin bi BSSIDên ku ji bo vê torê têne nîşandan re bidin ber hev.';

  @override
  String get evilTwinActionForgetNetwork =>
      'Torê ji mîhengên Wi-Fi yên telefona xwe jibîr bikin û tenê bi destan bi BSSIDya ku we piştrast kiriye ve girê bidin.';

  @override
  String get evilTwinActionSecurityDowngrade =>
      'Yek ji her du xalên gihîştinê şîfrekirineke lawaztir bikar tîne. Her tim ya bihêztir hilbijêrin (WPA3 li ser WPA2 li ser Vekirî).';

  @override
  String get evilTwinActionDisconnectNow =>
      'Niha ji vê Wi-Fiyê veqetin û heta ku hûn piştrast bikin kîjan BSSID rastîn e, biçin ser daneya mobîl.';

  @override
  String get evilTwinActionHardwareVendor =>
      'Herdu router ji hilberînerên cihêreng in — routera we ya rastîn ne divê nişkave hilberînerê xwe biguherîne.';

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
  String get securityScoreDesc =>
      'Puana ewlehiyê (0–100) nîşan dide ka ev tor çiqas baş tê parastin. Her ku zêde be çêtir e. Cureyê şîfrekirinê, rewşa WPS û taybetmendiyên din ên ewlehiyê li ber çavan digire.';

  @override
  String get networkSecurity => 'Ewlehiya Torê';

  @override
  String get portScanCommonPorts => 'Portên Hevpar';

  @override
  String get portScanCustomRange => 'Rêjeya Taybet';

  @override
  String get portScanAllPorts => 'HEMÛ PORT';

  @override
  String get portScanFullScanWarning =>
      'Skankirina hemû 65.535 portan dê demeke dirêj bikişîne.';

  @override
  String get portScanStartPort => 'Porta Destpêkê';

  @override
  String get portScanEndPort => 'Porta Dawî';

  @override
  String get portScanTooManyPorts =>
      'Hişyarî: Skankirina >1000 portan dikare hêdî bibe';

  @override
  String get portScanSearching =>
      'Li portên vekirî tê gerîn. Dibe ku demekê bikişîne...';

  @override
  String portScanProbing(int port) {
    return 'Porta $port tê skankirin...';
  }

  @override
  String portScanFoundCount(int count) {
    return 'Heta niha $count xizmetên vekirî hatin dîtin.';
  }

  @override
  String get portScanNoPortsProbed =>
      'Hîn tu port nehatine skankirin. Ji bo dîtina xizmetên vekirî skanekê bidin destpêkirin.';

  @override
  String get capabilitiesLabel => 'TAYBETMENDÎ';

  @override
  String get wifi7MldLabel => 'Wi-Fi 7 MLD';

  @override
  String get tagWpa3Desc =>
      'WPA3 standarta herî nû ya ewlehiyê ye — pir ewle ye.';

  @override
  String get tagWpa2Desc =>
      'WPA2 standartek ewlehiyê ya bi hêz e — ji bo karanîna rojane ewle ye.';

  @override
  String get tagWpaDesc =>
      'WPA standartek kevn a ewlehiyê ye ku kêmasiyên wê yên naskirî hene.';

  @override
  String get tagWpsDesc =>
      'Kêmasiyên ewlehiyê yên naskirî di WPS (Wi-Fi Protected Setup) de hene. Dikare rê bide êrîşkaran ku PIN-ê bi brute-force bişkînin û têkevin hundur.';

  @override
  String get tagPmfDesc =>
      'Protected Management Frames (PMF/MFP) li dijî êrîşên deauthentication diparêze.';

  @override
  String get tagEssDesc =>
      'ESS (Extended Service Set) tê wê wateyê ku ev toreke standarta access point e.';

  @override
  String get tagCcmpDesc =>
      'CCMP (AES) şîfrekirineke bi hêz e ku bi WPA2/WPA3 re tê bikaranîn.';

  @override
  String get tagTkipDesc =>
      'TKIP cureyekî şîfrekirinê yê kevn û lawaz e. CCMP/AES tê tercîhkirin.';

  @override
  String get tagUnknownDesc => 'Ala taybetmendiya torê ji beacon frame.';

  @override
  String get scanProfileLabel => 'PROFÎLA TARANÊ';

  @override
  String get infoScanProfileFastDesc =>
      'Bilez: Kontrola ping a bilez — di çirkeyan de amûran dibîne.';

  @override
  String get infoScanProfileBalancedDesc =>
      'Hevseng: Ping + portên hevpar — hûrguliyên zêdetir dibîne.';

  @override
  String get infoScanProfileAggressiveDesc =>
      'Zêde: Tarana portan a tije — ya herî berfireh lê ya herî hêdî ye.';

  @override
  String get activeNodeRecon => 'NASÎNA AKTÎF A NAVENDAN';

  @override
  String get interrogatingSubnet =>
      'Ji bo mêvandarên bersivdar li subnet heyî digere...';

  @override
  String get nodesLabel => 'Navend';

  @override
  String get scanElapsedLabel => 'Dem';

  @override
  String get scanRateLabel => 'Lez';

  @override
  String get riskAvgLabel => 'Navîna Rîskê';

  @override
  String get servicesLabel => 'Xizmet';

  @override
  String get openPortsLabel => 'PORTÊN VEKIRÎ';

  @override
  String get subnetLabel => 'Binter';

  @override
  String get cidrTargetLabel => 'ARMANCA CIDR';

  @override
  String portsCountLabel(int count) {
    return '$count PORT';
  }

  @override
  String get riskLabel => 'RÎSK';

  @override
  String get searchLanPlaceholder =>
      'Bi navê IP, mêvandar an firoşkar bigere...';

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
  String get securitySummarySecure =>
      'Girêdana we baş xuya dike! Ev tor şîfrekirina bi hêz bikar tîne û li dijî êrîşên gelemperî baş tê parastin.';

  @override
  String get securitySummaryModerate =>
      'Ewlehiya vê torê baş e lê hinek xalên lawaz hene. Ji bo bikaranîna rojane ewle ye, lê karên pir hesas nekin.';

  @override
  String get securitySummaryAtRisk =>
      'Di vê torê de pirsgirêkên ewlehiyê hene ku daneyên we dixin metirsiyê. Dema girêdayî bin şîfreyan an agahiyên kesane nenivîsin.';

  @override
  String get securitySummaryCritical =>
      'Hişyarî: Ev tor ne ewle ye. Kesên li nêzîk dikarin trafîka înterneta we bibînin. VPN bikar bînin an torê biguherînin.';

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
  String get riskFactorPmfNotEnforced =>
      'PMF nayê xwestin — xetera deauth heye';

  @override
  String get refresh => 'Nû bike';

  @override
  String get cancel => 'Betal bike';

  @override
  String get save => 'Tomar bike';

  @override
  String get waitingForData => 'Li benda daneyan e...';

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
  String get riskFactorFingerprintDrift =>
      'Veqetîna şopa tiliya SSID hat dîtin';

  @override
  String get riskFactorHoneypotPattern =>
      'SSID bi şêwaza honeypot ya naskirî re li hev tê';

  @override
  String get riskFactorNo5Ghz => 'Bandê 5 GHz nehat dîtin';

  @override
  String get riskFactorKnownVulnerability => 'Qelsiya hardware ya naskirî';

  @override
  String get riskFactorEvilTwinCandidate =>
      'Berendama evil twin a vî SSIDî parve dike';

  @override
  String get riskFactorChannelCongested => 'Kanal pir qelebalix e';

  @override
  String get historyCaps => 'DÎROK';

  @override
  String get consistentlyBestChannel => 'KANALA HERÎ BAŞ A BERDEWAM';

  @override
  String get avgScore => 'Skora Navîn';

  @override
  String get channelBondingTitle => 'Girêdana Kanalan';

  @override
  String get channelBondingDesc =>
      'Girêdana kanalan 2 an zêdetir kanalên cîranê hev dixe yek ku firehiya bandê zêde bibe (40 MHz = 2×, 80 MHz = 4×, 160 MHz = 8×). Kanalên firehtir leza zêdetir didin lê dikarin bandorê li ser torên cîran jî bikin.';

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
  String get noHistoryPlaceholder =>
      'Hîn dîrok tune.\nHer cara ku hûn vê ekranê vedikin, pileya kanalan tê tomarkirin.';

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
  String get channelInterferenceDescription =>
      'Kanalên Wi-Fi wekî stasyonên radyoyê ne. Dema ku gelek tor heman kanalê parve dikin ew hev hêdî dikin - mîna ku her kes di heman demê de diaxive. Veguhestina ser kanalekî kêmtir qelebalix dikare lez û rehetiya we baştir bike.';

  @override
  String securityEventType(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'rogueApSuspected': 'Gumana AP ya Sexte',
      'deauthBurstDetected': 'Êrîşa Qutkirinê Serî Hatiye Dîtin',
      'captivePortalDetected': 'Portala Girtî Hat Dîtin',
      'evilTwinDetected': 'Cêwîyê Xirab Hat Dîtin',
      'deauthAttackSuspected': 'Gumana Êrîşa Qutkirinê',
      'encryptionDowngraded': 'Şîfrekirin Hat Daxistin',
      'unsupportedOperation': 'Kareke Nayê Piştgirîkirin',
      'arpSpoofingDetected': 'Xapandina ARP Hat Dîtin',
      'dnsHijackingDetected': 'Revandina DNS Hat Dîtin',
      'other': '$type',
    });
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
  String get dnsSecurityTest => 'TESTA EWLEHIYA DNS';

  @override
  String get dnsSecure => 'EWLE';

  @override
  String get dnsWarning => 'HIŞYARÎ';

  @override
  String get dnsLeakDetected => 'DERKETIN HAT DÎTIN';

  @override
  String get dnsHijacked => 'HAT REVANDIN';

  @override
  String dnsLastCheck(String hour, String minute) {
    return 'Kontrola dawî: $hour:$minute';
  }

  @override
  String get dnsTestNow => 'NIHA TEST BIKE';

  @override
  String get dnsTesting => 'TÊ TESTKIRIN...';

  @override
  String get dnsCurrentDns => 'DNS YA NIHA';

  @override
  String get dnsIspProvider => 'DABÎNKERÊ ISP';

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
  String get channelCongestionHint =>
      'Kanala we tijî ye. Guherandin dikare lezê baştir bike.';

  @override
  String get evilTwinAlertTitle => 'XALÊ GIHÎŞTINÊ YÊ DEREWÎN HATE DÎTIN';

  @override
  String get evilTwinAlertBody =>
      'Tora xwe wekî xaleke naskirî nîşan dide. Bi torên nenas ve nevekin.';

  @override
  String get wpsWarningTitle => 'WPS VEKIRÎ YE';

  @override
  String get wpsWarningBody =>
      'WPS xeletiyên ewlehiyê hene. Ji mîhengên rûterê xwe neçalak bike.';

  @override
  String get heatmapTutorialTitle => 'NEXŞEYA GERMAHIYÊ ÇAWA BIKAR BÎNIM';

  @override
  String get heatmapTutorialStep1 =>
      'Seansek nû destpê bike, li TOMAR DEST PÊ KE bikirtînin.';

  @override
  String get heatmapTutorialStep2 =>
      'Biçin her quncikek û li cîhê xwe nexşeyê bikirtînin.';

  @override
  String get heatmapTutorialStep3 => 'Sor = nîşan qels. Kesk = nîşan xurt.';

  @override
  String get heatmapTutorialStep4 =>
      'Dema ku hat xulasekirin, RAWEST û SAVE bikirtînin.';

  @override
  String get gotIt => 'FÊHM KIR';

  @override
  String get speedTestHistory => 'DÎROKA TESTÊ';

  @override
  String get noSpeedTestHistory =>
      'Hêj test nehatiye tomar kirin. Testa yekem li jorê dest pê bike.';

  @override
  String get vulnLabTitle => 'LABORATÛWARA QELSIYAN';

  @override
  String get vulnLabSubtitle =>
      'Li dijî torê xwe ya girêdayî testên ewlehiyê bimeşînin';

  @override
  String get vulnLabRunAll => 'HEMÛ TESTAN BIMEŞÎNE';

  @override
  String get vulnLabRunning => 'TÊ TARANDIN...';

  @override
  String get vulnLabNoNetwork =>
      'Ne bi torek Wi-Fi ve girêdayî ye. Berî testê bimeşînin pêşî girê bidin.';

  @override
  String get vulnLabAllClear =>
      'Hemû test derbas bûn. Di vê torê de qelsî nehat dîtin.';

  @override
  String vulnLabFoundCount(int count) {
    return '$count pirsgirêk hat dîtin';
  }

  @override
  String get trustNetwork => 'BI TORÊ BAWER BIKE';

  @override
  String get untrustNetwork => 'BAWERIYÊ RAKE';

  @override
  String get trustedBaselineBadge => 'BINGEHÊN BAWER';

  @override
  String get dnsEvidenceTitle => 'DELÎLÊN DNS';

  @override
  String get dnsProtocol => 'PROTOKOL';

  @override
  String get dnsSsec => 'DNSSEC';

  @override
  String get dnsDohLabel => 'DoH';

  @override
  String get dnsDotLabel => 'DoT';

  @override
  String get dnsReachable => 'Gihîştî';

  @override
  String get dnsBlocked => 'Astengkirî';

  @override
  String get dnsEncryptedBlocked =>
      'Ev tor DNSa şîfrekirî asteng dike — lêgerînên te wek nivîsa zelal têne şandin.';

  @override
  String get dnsInfoHijackingTitle => 'Revandina DNS';

  @override
  String get dnsInfoHijackingDesc =>
      'Gava dabînkerê torê we an kesekî xerab pirsên DNS ya we ber bi serverên xirab ve dizivirîne. Ev dihêle ew çalakiya we bişopînin an hin malperan asteng bikin.';

  @override
  String get dnsInfoLeakTitle => 'Derketina DNS';

  @override
  String get dnsInfoLeakDesc =>
      'Tewra dema hûn VPN bikar tînin jî, pirsên we dikarin ji tunela ewle derbas bibin û biçin serverên ISPya we. Ev dîroka geran a we ji dabînkerê torê re \"derdixe\".';

  @override
  String get dnsInfoEncryptedTitle => 'DNS ya Şîfrekirî (DoH/DoT)';

  @override
  String get dnsInfoEncryptedDesc =>
      'DNS over HTTPS (DoH) û DNS over TLS (DoT) pirsên we di qatek şîfrekirî de dipêçin. Ev daxwazên we ji bo guhdaristiyên herêmî û rêvebirên torê nexwendî dike.';

  @override
  String get dnsInfoDnssecTitle => 'DNSSEC';

  @override
  String get dnsInfoDnssecDesc =>
      'Extensionên Ewlehiya DNS îmzayên kriptografîk li pirsên we zêde dikin. Ev pêşî li \"spoofing\"ê digire, ku serverek navnîşanên IP yên sexte ji bo malperên rewa dişîne.';

  @override
  String get dnsInfoLatencyTitle => 'Gecikîna DNS (RTT)';

  @override
  String get dnsInfoLatencyDesc =>
      'Dema Çûn-Vegerê (RTT) dipîve ka çiqas dem digire ku pirsek here server û vegere. Gecikîna kêmtir tê wateya geran a torê ya zûtir û performansa çêtir.';

  @override
  String get dnsInfoResolverDriftTitle => 'Zivirîna Resolverê DNS';

  @override
  String get dnsInfoResolverDriftDesc =>
      'Gava daxwazên DNS ya we ji hêla dabînkerên cûda ji yên hatine mîhengkirin ve têne bersivandin tê dîtin — dibe ku bi sedema proxyeke şefaf an guherînên rêyê be.';

  @override
  String get netInfoSsidTitle => 'SSID (Nasnavê Koma Xizmetê)';

  @override
  String get netInfoSsidDesc =>
      'Navê giştî yê torê we ya Wi-Fi. Her çend adetî be jî, dikare ji hêla êrîşkaran ve were sexte kirin da ku we bikşîne ber girêdana bi xalek gihîştinê ya xirab.';

  @override
  String get netInfoBssidTitle => 'BSSID (Nasnavê Bingehîn ê Koma Xizmetê)';

  @override
  String get netInfoBssidDesc =>
      'Navnîşana hardware ya bêhempa (MAC) ya routera bêtêl. Ji bo piştrastkirina ku hûn bi hardware ya rewa ve girêdayî ne û ne bi klonek nermalavê re, bikêr e.';

  @override
  String get netInfoGatewayTitle => 'Dergeha Standard';

  @override
  String get netInfoGatewayDesc =>
      'Navnîşana IP ya herêmî ya routera we. Hemû tîrafîka we ji vê xalê derbas dibe. Heke ev nişkave biguhere, dibe ku nîşana êrîşeke Man-in-the-Middle be.';

  @override
  String get dnsReadyStatus => 'AMADE JI BO NIRXANDINÊ';

  @override
  String get dnsIdleDescription =>
      'Ji bo piştrastkirina tevahî û performansa DNS taramekê bimeşînin.';

  @override
  String get netSecInfoTitle => 'Modula Ewlehiya Torê';

  @override
  String get netSecInfoDesc =>
      'Tevahiya torên girêdayî dişopîne, xalên gihîştinê yên xirab dide dîtin, û profîlên Wi-Fi yên baweriya we yên li hember êrîşên Evil Twin diparêze.';

  @override
  String get spectrumOptimizationOpsSubtitle =>
      'Nirxandina kanalê · tevliheviyê';

  @override
  String get aboutSpectrumTitle => 'Optîmîzekirina Spektrumê Çi ye?';

  @override
  String get aboutSpectrumWhatHeader => 'Çi ye?';

  @override
  String get aboutSpectrumWhatBody =>
      'Cîhazên Wi-Fi bi rêya beşên frekansê yên bi navê \"kanal\" diaxivin. Bandê 2.4 GHz tenê 3 kanalên bi rastî ne-li-ser-hev hene (1, 6, 11) û herî gelemperî ye. Bandê 5 GHz pir kanalên zêdetir û tevliheviya kêmtir heye. Bandê herî nû 6 GHz (Wi-Fi 6E/7) di piraniya malan de hema bibêje vala ye.';

  @override
  String get aboutSpectrumWhyHeader => 'Bi kêrî çi tê?';

  @override
  String get aboutSpectrumWhyBody =>
      'Gava gelek tor heman kanalê parve dikin, divê dorê bigirin û her tişt hêdî dibe (Tevliheviya Heman Kanalê). Li 2.4 GHz, kanalên cîran jî li ser hev radikevin û dengê paşxaneyî çêdikin (Tevliheviya Kanalê Cîran). Hilbijartina kanaleke bêdeng rasterast lez, derengî û aramiya girêdanê baştir dike.';

  @override
  String get aboutSpectrumHowHeader => 'Çawa dixebite?';

  @override
  String get aboutSpectrumHowBody =>
      'Ev rûpel hemû torên Wi-Fi yên derdorê dişopîne û her kanalê li gorî hejmara torên hevrik, hêza sînyalê û li-ser-hev-ketina bi cîranan re ji 0 heya 10 puan dide. Kanalek bi rengê kesk (≥8) hilbijêre: ev kanal niha herî kêm gelemperî ye. Tabela Dîrokê nîşan dide ku kanal li ser demê paqij dimîne an na.';

  @override
  String get bandSpectrumTitle => 'Spektruma Kanalê';

  @override
  String get bandSpectrumInfoTitle => 'Spektruma Kanalê';

  @override
  String get bandSpectrumInfoBody =>
      'Her bar yek kanal e. Barên bilind û kesk bêdeng in; barên kurt û sor gelemperî ne. Li barekê bide ku puanê (0-10) bibînî. Her tora ku heman kanalê parve dike 2 puanan kêm dike (Tevliheviya Heman Kanalê); li 2.4 GHz torên kanalên cîran jî kêmtir kêm dikin (Tevliheviya Kanalê Cîran). Torên nêzîk û xurt bêtir tê cezakirin ji yên dûr û qels.';

  @override
  String get recommendationInfoTitle => 'Pêşniyaz Çawa Tê Kirin?';

  @override
  String get recommendationInfoBody =>
      'Her kanal ji 10 puanan dest pê dike. Tora bi heman kanalê her yek 2 puanan (×hêza sînyalê) kêm dike. Torên cîran ên 2.4 GHz li gorî mesafeyê 0.2-1.5 puanan kêm dikin. Kanalên DFS (parve bi radarê) 0.5 puanan winda dikin. Kanala bi puanê herî bilind serketî ye. Di rewşa wekheviyê de kanala bi hejmara biçûktir tê tercîhkirin.';

  @override
  String get consistentChannelInfoTitle => 'Kanala Herî Baş ya Berdewam';

  @override
  String get consistentChannelInfoBody =>
      'Wêneyek anî dikare şaşxistîner be: kanaleke ku niha bêdeng e dikare paşê gelemperî bibe. Em hemû şopandinên berê yên her kanalê navber dikin û ya ku bi awayekî berdewam puanê herî bilind digire diyar dikin. Heke ji pêşniyaza niha cuda be, kanala dîrokî ya aram bi gelemperî hilbijartineke ewletir e ji bo demê dirêj.';

  @override
  String get dfsBadgeLabel => 'DFS';

  @override
  String get dfsBadgeTooltip =>
      'DFS — bi radara hewa/leşkerî re tê parvekirin; routerê dibe ku ji vê kanalê demek kurt derkeve';

  @override
  String get dfsInfoTitle => 'DFS Çi ye?';

  @override
  String get dfsInfoBody =>
      'Kanalên DFS (Dynamic Frequency Selection) di bandê 5 GHz de (52-64 û 100-144) bi awayekî yasayî bi radarên hewa û leşkerî re têne parvekirin. Wi-Fi divê pêşîniyê bide van radaran: heke router lêgerîna radarê tespît bike, divê herî kêm 60 çirkeyan ji kanalê derkeve — cihazên we demek kurt qut dibin û diçin ser kanaleke din. Kanalên DFS bi gelemperî kêm gelemperî ne (loma puanê wan bilind e), lê li nêzîkê balafirgehan, bendergehan an stasyonên hewa dikarin nêbawer bin. Em ji bo nîşandana vê metirsiyê 0.5 puanan kêm dikin. Heke çavkaniya radarê nêzîk tune be wan bikar bînin; an na, ji wan dûr bikevin.';

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
  String get guideStep1Body =>
      'Bişkoja VEKE ya jêr bitikîne — gerokê te yê standard di rûpela rêveberiya routerê de vedibe. (An jî navnîşanê kopî bike û destî bispêre.) Ji bo navnîşan bixebite, divê li vê Wi-Fi ve girêdayî bî; tenê bi daneya mobîl nagihîje.';

  @override
  String get guideOpenInBrowser => 'Veke';

  @override
  String get guideOpenFailedMessage =>
      'Gerokê bixweber venebû — navnîşanê kopî bike û destî bispêre.';

  @override
  String get guideCredentialsHeader => 'Navê bikarhêner û şîfre';

  @override
  String get guideCredentialsBody =>
      'Gava rûpela rêveberiyê ji te têketinê dixwaze:\n\n1. Li binî an pişta routerê binêre — bi gelemperî li wir etîketek heye ku şîfreya Wi-Fi û her wiha agahiyên têketina REVEBERIYÊ jî dinivîse. Têketina rêveberiyê wek \"Admin password\", \"Web password\", \"Modem password\" an \"Şîfreya Rêveberiyê\" tê nîşandan. Ev bi şîfreya Wi-Fi NEYAN E.\n\n2. Heke etîket tune be, van standardên fabrîkayê biceribîne:\n   • admin / admin\n   • admin / password\n   • admin / 1234\n   • root / admin\n   • Navê bikarhêner vala / şîfre admin\n\n3. Heke router ji aliyê pêşkêşkarê înternetê hatibe sazkirin, şîfreya rêveberiyê bi gelemperî 6-8 karakterên dawî yên seriya cihazê ye, ku ew jî li ser etîketê dinivîse. Gelek pêşkêşkar şîfreyek taybet a cihazî çap dikin.\n\n4. Heke tu yek nexebite, kesek berê şîfre guherandî ye. Dikarî bişkoja RESET ya li pişta routerê 10-15 çirkeyan bigirî da ku rewşa fabrîkayê vegere — lê ev navê Wi-Fi û şîfreya wê jî paqij dike, divê ji nû ve saz bikî.\n\n5. Hin routerên nû panela web bi sepanê telefonê re diguherînin (mînak TP-Link Tether, ASUS Router, Mi WiFi, Huawei AI Life). Heke rûpela web te ber bi sazkirina sepanê ve dişîne, sepanê saz bike û ji wir berdewam bike.';

  @override
  String get guideCopyAddress => 'Kopî bike';

  @override
  String get guideAddressCopied =>
      'Navnîşan hate kopîkirin — di gerokê de veke';

  @override
  String get guideStep2 => 'Gav 2 · Menûya Wi-Fi / Wireless bibîne';

  @override
  String get guideStep2Body =>
      'Piştî têketinê li menûyek bi navê Wi-Fi, Wireless an Mîhengên Torê bigere. Marka cuda navên cuda dikin — rêya jêrîn ji bo marka te ye:';

  @override
  String get guideStep3 => 'Gav 3 · Kanalê saz bike û bisepîne';

  @override
  String get guideStep3Body =>
      'Bijareya Channel/Kanal bibîne. Auto-yê biguhêre bo kanala pêşniyazkirî di ekrana berê de. Heke routerê te ji bo 2.4 GHz û 5 GHz cuda nîşan dide, ji bo her bandê kanala xwe ya pêşniyazkirî saz bike. Tê tomarkirin/sepandinê bitikîne. Wi-Fi dê demek kurt ji nû ve dest pê bike.';

  @override
  String get guideMenuPathLabel => 'Riya menûyê';

  @override
  String get guideGenericMenuPath =>
      'Wireless / Wi-Fi → Bingehîn / Pêşkeftî Mîheng → Kanal';

  @override
  String get channelWidthHeader => 'Pehnatiya kanalê — 20 / 40 / 80 / 160 MHz';

  @override
  String get channelWidthBody =>
      'Pehnatiya kanalê wek hejmara şiritan a otoyolê ye:\n• 20 MHz = 1 şirit. Hêdî lê li hember trafîkê bi hêz. Ji bo 2.4 GHz a tijî baştirîn.\n• 40 MHz = 2 şirit. Du qatî leza daneyan, lê bi cîranan re zêdetir li hev radikeve.\n• 80 MHz = 4 şirit. Lez — tenê di 5 GHz/6 GHz de.\n• 160 MHz = 8 şirit. Lezê herî bilind, lê nîvê bandê 5 GHz digire; tenê heke cîran tune be watedar e.\n\nQayîdeya giştî: di 2.4 GHz de 20 MHz; di 5 GHz de 80 MHz; di 6 GHz de heke berdest be 160 MHz.';

  @override
  String get guideRisksHeader => 'Guhertina kanalê ewle ye?';

  @override
  String get guideRisksBody =>
      'Erê — bi tevahî ewle ye. Guhertina kanalê ji bilî qutbûnek 5-10 çirkeyî ya ku dema router radio ji nû ve dest pê dike çêdibe, hîç bandorek ewlehiyê an performansê tune. Navê torê (SSID), şîfre, qaîdeyên port-yönlendirmeyê, kontrolên dêûbavî û her mîhengek din çawa hebû dimîne. Cihazên girêdayî bixweber ji nû ve têne girêdan. Heke paşê tişt xerabtir xuya bike, dikarî ji heman menûyê vegerî ser Auto û router bi xwe kanalek hilbijêre.';

  @override
  String get guideNoConnection =>
      'Bi tora Wi-Fi ve ne girêdayî yî — ji bo dîtina navnîşana rêveberiyê û rêbera taybet a markeyê pêşî girê bide.';

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
  String get currentChannelBannerOptimal =>
      'Tu jixwe li ser kanala pêşniyazkirî yî';

  @override
  String get spectrumOverlapTitle => 'Li-ser-hev-ketina Toran';

  @override
  String get spectrumOverlapInfoTitle => 'Li-ser-hev-ketina Toran';

  @override
  String get spectrumOverlapInfoBody =>
      'Her şeklê rengîn yek tora Wi-Fi ye. Cihê wê li ser axa X frekansa navendê nîşan dide, fireh̥iya wê pehnatiya kanalê (20/40/80/160 MHz), bilindahî jî hêza sînyalê (jor = xurt, jêr = qels). Cihên ku şekl li ser hev radikevin, ew tor heman dema weşanê parve dikin û hev hêdî dikin. Li firehîyek dîkî ku tê de tu şekil tune (an jî tenê yên qels li jêr) bigere — ew kanaleke bêdeng e. Li şeklekê bide ku tora wê bibînî.';

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
  String get channelIllegalTooltip =>
      'Ev kanal li herêma hilbijartî ji bo Wi-Fi yasayî nîne.';

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
  String get hourlyHeatmapInsufficient =>
      'Dîroka bes têrê nake. Vê ekranê di saetên cuda yên rojê de veke ku rêjeya saetan ava bibe.';

  @override
  String get afcInfoTitle => 'Sinifên Hêza 6 GHz (AFC)';

  @override
  String get afcInfoBody =>
      'Wi-Fi 6 GHz dabeşbûyî sê sînifên hêzê ye:\n\n• LPI (Hêza Kêm a Hindurîn) — Pêşbinîn ji bo routerên malê. Heya 30 dBm EIRP, tenê di hindurê de yasayî ye. Koordînasyona cihê ne hewce ye.\n\n• Standard Power (SP) — Derve û hindurê hêza bilind. Heya 36 dBm. AFC (Koordînasyona Frekansa Otomatîk) hewce dike: router cihê GPS xwe ji databasaya rêveberiyê re dişîne û tê gotin ka kîjan kanal ji bikarhênerên niştecîh (uplink satelîtî, lînkên mîkrowave) vala ne.\n\n• VLP (Hêza Pir Kêm) — Bikaranîna mobîl, heya 14 dBm. Koordînasyon ne hewce ye lê dûrahiya wê pir kurt e; piranî ji bo AR/VR û laptopan.\n\nPiraniya torên malê tenê LPI dibînin; eger li derve îşareta xurt a 6 GHz bibînî, mimkun e ku ew SP û bi AFC hatî koordîne kirin be.';

  @override
  String get advancedTopicsHeader => 'Mijarên pêşkeftî';

  @override
  String get advancedMeshTitle => 'Mesh û geştûgeşt (roaming)';

  @override
  String get advancedMeshBody =>
      'Di tora mesh de (Google Nest, Eero, TP-Link Deco hwd.) tu kanalê bi destan hilnabijêrî — kontrolker ji bo her girêkê kanalek hildibijêre û gava cîran diguherin ji nû ve dibalans dike. Hin kontrolker overrideya ji bo girêka îstîsna pêşkêş dikin; lê moda otomatîk bi gelemperî baştir e, ji ber ku sîstem tevliheviya navbera girêkên mesh jî dipîve. Heke pêwîst bibe, radyoya pêş (a aliyê xerîdar) ya girêka sereke saz bike ser kanala pêşniyazkirî û radyoya paş (girêk-girêk) bila otomatîk bimîne.';

  @override
  String get advancedBandSteeringTitle => 'Band steering & yek SSID an du';

  @override
  String get advancedBandSteeringBody =>
      'Routerên nû band-steering pêşkêş dikin: yek SSID ji bo hem 2.4 hem 5 GHz, router cihazên kapasîteyî dixe nav 5 GHz. Erêniyên: hêsan, cihaz bi awayekî otomatîk diguhere. Neyîniyên: hin cihazên IoT (priz, kamera) tenê 2.4 GHz dibînin; gava router wê bandê di dema steeringê de veşêre nikare têkeve. Çareya temerî: SSID-an cuda bike (mînak \"MalaMin\" li ser 5 GHz, \"MalaMin-IoT\" li ser 2.4 GHz) ji bo sazkirinê û paşê heke bixwazî bike yek.';

  @override
  String get advancedWmmTitle => 'WMM / QoS';

  @override
  String get advancedWmmBody =>
      'WMM (Wi-Fi Multimedia) trafîkê dabeş dike li 4 sinifan: deng, vîdyo, normal, paşxane. Ji bo sertîfîkayê Wi-Fi 4+ pêwîst e û divê her dem vekirî bimîne. Vegirtinê leza te tixûb dike li 802.11g (~54 Mbps). Kanal ne dibe ku WMM bandor bike, lê kanaleke paqij hemû 4 sinifan bi hev re baştir dike.';

  @override
  String get dfsCacWarning =>
      '⚠ Kanala DFS: gava router biçe vê kanalê, divê 60 çirkeyan bêdeng guhdarî bike (Channel Availability Check) berî ku weşanê dest pê bike. Di vê demê de Wi-Fi nayê bikaranîn.';

  @override
  String get densityTrendStable => 'Pestoya aram';

  @override
  String densityTrendVolatile(String delta) {
    return 'Herêma guherbar · di saeta dawî de pestoy $delta tor heng kir';
  }

  @override
  String get routerGroupsHeader => 'Routerên nêzîk (du-band)';

  @override
  String get routerGroupsInfoBody =>
      'Gava heman router heman SSID li ser ji yek bandê zêdetir weşan dike (mînak 2.4 GHz CH 6 û 5 GHz CH 36), em wan li vir kom dikin da ku tu her du radyoyan bera ya hev bidî. Bişkokek bandê bide ku biçî wê tabê.';

  @override
  String crossBandSiblingHint(String band, String channel, String rating) {
    return 'Heman router li ser $band CH $channel · $rating/10';
  }

  @override
  String get connectedChannelGuideLabel => 'TU';

  @override
  String get unstableChannelTooltip =>
      'Puanê vê kanalê di rûniştinên dawî de ji 1.5 puanan zêdetir guherî';

  @override
  String get historyHeatmapInfoTitle => 'Nexşeya Germayê Çi ye?';

  @override
  String get historyHeatmapInfoBody =>
      'Her rêz kanalek e û her stûn demek e ku te şopandin kir. Rengê hucreyê puanê wê demê nîşan dide: sor (xirab) → zer (orte) → kesk (zehf baş). Hucreyên vala wateya wê ye ku kanal di wê şopandinê de nediyar bû. Li rêzên temamî kesk bigere — ev ew kanal in ku bi demê re paqij dimînin.';

  @override
  String get clearChannelHistoryTitle => 'DÎROKA KANALÊ PAQIJ BIKE';

  @override
  String get clearChannelHistoryConfirmBody =>
      'Hemû tomarên puanê kanalê werin jêbirin? Ev nayê vegerandin.';

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
  String get onboardingStartScanning => 'TARANDINÊ DEST PÊ BIKE';

  @override
  String get onboardingNext => 'PÊŞ';

  @override
  String get onboardingWelcomeTitle => 'BI XÊR HATIN TORCAVÊ';

  @override
  String get onboardingWelcomeBody =>
      'Analîzkerek Wi-Fi ya cyberpunk ku ji we re dibe alîkar hawîrdora xwe ya bêtêl fêm bikin, kanala herî baş bibînin, û gefên ewlehiyê bibînin.';

  @override
  String get onboardingLocationTitle => 'DESTÛRA CIH';

  @override
  String get onboardingLocationBody =>
      'Android ji bo tarandina torên Wi-Fi destûra Cih hewce dike. Ji bo nîşandana nexşeyên germahiyê yên sînyalê, em senzorên çalakiyê jî bikar tînin. Hemû dane li ser cîhaza we dimîne û qet nayê barkirin. Cihê we tenê ji bo xwendina sînyalên Wi-Fi yên nêzîk tê bikaranîn.';

  @override
  String get onboardingNotificationsTitle => 'HIŞYARÎYÊN EWLEHIYÊ';

  @override
  String get onboardingNotificationsBody =>
      'Gava ku Torcav bûyerek ewlehiyê di tora we de tespît bike agahdar bibin — xalên gihîştinê yên cêwiyê, portên vekirî, revandina DNSê. Hemû hişyarî li ser amûrê têne çêkirin; tu daneyek nayê şandin ser servereke.';

  @override
  String get onboardingNotificationsEnable => 'Hişyariyan çalak bike';

  @override
  String get onboardingNotificationsSkip => 'Niha derbas bike';

  @override
  String get onboardingTourTitle => 'SÊ TAB';

  @override
  String get onboardingTourDashboardLabel => 'Dashboard';

  @override
  String get onboardingTourDashboardDesc =>
      'Nêrîneke zindî ya tenduristiya torê we';

  @override
  String get onboardingTourDiscoveryLabel => 'Vedîtin';

  @override
  String get onboardingTourDiscoveryDesc =>
      'Torên Wi-Fi û cîhazên LAN bitarînin';

  @override
  String get onboardingTourOperationsLabel => 'Operasyon';

  @override
  String get onboardingTourOperationsDesc =>
      'Analîza ewlehiyê, testên leza, raporan';

  @override
  String get onboardingContextTitle => 'HÛN Ê LI KU DERÊ TORCAVÊ BIKAR TÎNIN?';

  @override
  String get onboardingContextBody =>
      'Ev diyar dike ka xala ewlehiyê çiqas tund e gava em bi xwe nizanibin. Hûn dikarin her dem biguherînin, û paşê ji bo her torê veguherandinek bikin.';

  @override
  String get onboardingContextHomeTitle => 'Bi piranî mal / ofîsa min';

  @override
  String get onboardingContextHomeBody =>
      'Nirxandina tund. Her guherîna nediyar a şîfrekirinê an cîhazên nû yên li ser LAN bi dengekî bilind têne nîşankirin.';

  @override
  String get onboardingContextPublicTitle =>
      'Bi piranî qehwexane / otêl / firodgeh';

  @override
  String get onboardingContextPublicBody =>
      'Nirxandina şîfrekirinê nerm e (van torên bi gelemperî vekirî ne) lê hesasiyeta li hember SSIDên xapînok û şêwazên evil-twin bilindtir e. Tarandina LAN ya çalak bi xwerû tê rawestandin.';

  @override
  String get onboardingContextGuestTitle => 'Bi piranî torên mêvan / hevpar';

  @override
  String get onboardingContextGuestBody =>
      'Heman Wi-Fi wek hevalan, malbat, an hevkaran. Guherîn tê hêvîkirin; em ne li ser her cîhazê nû hişyar dikin.';

  @override
  String get onboardingContextUnknownTitle => 'Hê ne diyar';

  @override
  String get onboardingContextUnknownBody =>
      'Standardek bihêz tune. Em ê ji nasnameya her torê texmîn bikin û bihêlin hûn rast bikin.';

  @override
  String get onboardingDoneTitle => 'HEMÛ AMADE YE';

  @override
  String get onboardingDoneBody =>
      'Torcav alîkarek torê ye ku pêşengiyê dide nepenîtiyê. Ew ji bo torên ku xwedî wan in an destûra nirxandina wan hene amûrên teşhîskirinê û tund kirinê yên ewle peyda dike. Ti dane naye berhevkirin an ji derve nayê şandin.';

  @override
  String get onboardingAcceptPrefix => 'Min xwend û qebûl kir ';

  @override
  String get onboardingTosLink => 'Mercên Xizmetê';

  @override
  String get onboardingAcceptAnd => ' û ';

  @override
  String get onboardingPrivacyLink => 'Siyaseta Nepenîtiyê';

  @override
  String get onboardingAcceptSuffix => '.';

  @override
  String get onboardingConfirmPermission =>
      'Ez piştrast dikim ku destûra min ji bo tarandina torên ku ez ê analîz bikim heye.';

  @override
  String get onboardingConfirmAge =>
      'Ez piştrast dikim ku ez 13 salî an mezintir im.';

  @override
  String get appTitle => 'TORCAV';

  @override
  String get ssidLabel => 'SSID';

  @override
  String get noSecurityFindings => 'Tu dîtina ewlehiyê nehat tespîtkirin.';

  @override
  String get resetToInferred => 'Vegere etîketa xweber';

  @override
  String get internetSlowQuestion => 'GELO INTERNET HÊDÎ YE?';

  @override
  String get securityAlertsTitle => 'HIŞYARIYÊN EWLEHIYÊ';

  @override
  String get markAllRead => 'HEMÛYAN WEK XWENDÎ NÎŞAN BIKE';

  @override
  String get clearAll => 'HEMÛYAN PAK BIKE';

  @override
  String get eventsRetentionInfo =>
      'Bûyer 30 rojan têne hilanîn. Ji bo betalkirinê ber bi çepê ve bikişînin.';

  @override
  String get allSystemsClear => 'Hemû pergal pak in';

  @override
  String get heuristicDetectionNote =>
      'Tespîtkirina sezgirî — ne êrîşek piştrastkirî ye. Di hawîrdorên qelebalix de dibe ku encamên çewt derkevin.';

  @override
  String get markAsRead => 'WEK XWENDÎ NÎŞAN BIKE';

  @override
  String get eventTypeRogueAp => 'AP XIRAB';

  @override
  String get eventTypeEvilTwin => 'EVIL TWIN';

  @override
  String get eventTypeDeauthAttack => 'ÊRIŞA DEAUTH';

  @override
  String get eventTypeEncryptionWeakened => 'ŞÎFREKIRIN LAWAZ BÛ';

  @override
  String get eventTypeDeauthBurst => 'PELÎSTOKA DEAUTH';

  @override
  String get eventTypeCaptivePortal => 'PORTALA GIRTÎ';

  @override
  String get eventTypeUnsupported => 'NAYÊ PIŞTGIRIKIRIN';

  @override
  String get eventTypeArpSpoofing => 'XAPANDINA ARP';

  @override
  String get eventTypeDnsHijacking => 'REVANDINA DNS';

  @override
  String get agentId => 'AGENT-01';

  @override
  String cyberneticId(String id) {
    return 'SÎBERNETÎK_ID: $id';
  }

  @override
  String subscriptionLabel(String type) {
    return 'Bendewarî: $type';
  }

  @override
  String deepScanSuppressed(String context) {
    return 'Tarandina kûr hat rawestandin — hûn bi torek $context ve girêdayî ne. Ji bo derbaskirinê parastina ewlehiyê di Mîhengan de bigirin.';
  }

  @override
  String get securityAssessmentFailed => 'NIRXANDINA EWLEHIYÊ ŞKEST';

  @override
  String get retryAnalytics => 'ANALÎZÊ DÎSA BICEHRIBÎNE';

  @override
  String get publicContextLabel => 'giştî';

  @override
  String get guestContextLabel => 'mêvan';

  @override
  String get clearScanHistoryTitle => 'DÎROKA TARANDINÊ PAK BIKE';

  @override
  String get clearScanHistoryBody =>
      'Hemû tomarên tarandina LAN werin jêbirin? Ev nayê vegerandin.';

  @override
  String get cancelLabel => 'BETAL BIKE';

  @override
  String get networkAuditConsentTitle => 'RAZIBÛNA TEFTÎŞA TORÊ';

  @override
  String get networkAuditConsentDesc =>
      'Tarandina torê ya çalak tîrafîkê ji bo naskirina cîhaz û xizmetan çêdike. Ev dibe ku ji hêla pergalên ewlehiyê yên torê ve were nîşankirin.';

  @override
  String get consentScanNodes => 'Torê herêmî ji bo nodên çalak bitarîne';

  @override
  String get consentFingerprint => 'Xizmetên vekirî û OSê nas bike';

  @override
  String get consentIdentifyVulns => 'Qelsiyên gengaz nas bike';

  @override
  String get consentConfirmAuth =>
      'Piştrast bikin ku destûra we ji bo vê torê heye';

  @override
  String get iUnderstand => 'FÊM KIRIM';

  @override
  String get iosLanDiscoveryLimited =>
      'iOS: Vedîtina LAN sînordar e. Gerîna mDNS û gihîştina tabloya ARP dibe ku ji hêla OSê ve were sînorkirin.';

  @override
  String get androidLanVendorLimited =>
      'Android gihîştina MAC ya LAN sînordar dike. Navên hilberîner dibe ku tenê ji bo router/dergehê xuya bibin; cîhazên din bi IP, hostname û xizmetan têne naskirin dema gengaz be.';

  @override
  String get vendorUnavailableAndroid =>
      'Hilberîner tune: Android navnîşana MAC ya LAN ya vê cîhazê ji sepanan re eşkere nake.';

  @override
  String get speedDoctorLongDesc =>
      'Di ~30 saniyeyan de testên sînyal, kanal, lez û DNS dimeşîne û ji we re dibêje kîjan girêdan di zincîrê de asteng e.';

  @override
  String get startDiagnosis => 'TEŞHÎSÊ DEST PÊ BIKE';

  @override
  String get speedDoctorQuotaWarning =>
      'Hişyar bin: testeke rastîn a lezê ~300–500 MB dadixe. Ji bo pergirtina kotaya xwe ya mobîl, Wi-Fi an girêdanek bêsînor bikar bînin.';

  @override
  String get evidenceLabel => 'DELÎL';

  @override
  String get runAgain => 'DÎSA BIMEŞÎNE';

  @override
  String get aboutSpeedDoctorTitle => 'DERBARÊ SPEED DOCTOR';

  @override
  String get sdAboutWhatTitle => 'Ev çi ye?';

  @override
  String get sdAboutWhatBody =>
      'Teşhîseke bi yek-tikandinê ku astengiya muhtemel di navbera we û înternetê de dibîne — bêyî ku hûn hejmaran li ser ekranên cûda bidin ber hev.';

  @override
  String get sdAboutHowTitle => 'Ew çawa dixebite?';

  @override
  String get sdAboutHowBody =>
      'Pênc testên kurt bi dawî ve têne meşandin û encam bi armancên weşandî têne berhevdan:';

  @override
  String get sdAboutHowBullet1 =>
      'Sînyal — RSSI ji xala gihîştinê ya girêdayî dixwîne.';

  @override
  String get sdAboutHowBullet2 =>
      'Kanal — kanala we li hember APên cîran dinirxîne.';

  @override
  String get sdAboutHowBullet3 =>
      'Lez — testek dahatin/derketin a rastîn li dijî Cloudflare dimeşîne.';

  @override
  String get sdAboutHowBullet4 =>
      'Bufferbloat — gecikîna di bin barê de dipîve (Waveform A–F).';

  @override
  String get sdAboutHowBullet5 =>
      'DNS — resolverên giştî bi ya niha ya we re berhev dike.';

  @override
  String get sdAboutCategoriesTitle => 'Kategorî çi wateyê didin?';

  @override
  String get sdAboutCategoriesBullet1 =>
      'Sînyala Lawaz — dûrî û dîwar girêdana Wi-Fi dixin moda hêdî.';

  @override
  String get sdAboutCategoriesBullet2 =>
      'Kanala Qelebalix — APên cîran ên li ser heman kanalê dema hewayê ya we dixwin.';

  @override
  String get sdAboutCategoriesBullet3 =>
      'Bufferbloat — dema girêdan bi tevahî bar be gecikîn zêde dibe; bang û lîstik zehmet dibin.';

  @override
  String get sdAboutCategoriesBullet4 =>
      'ISP Hêdî — Wi-Fi baş e lê pîlana we / jorîn asta jorîn e.';

  @override
  String get sdAboutCategoriesBullet5 =>
      'DNS Hêdî — rûpel hêdî tên barkirin ji ber ku lêgerîna navan pir dem digire.';

  @override
  String get sdAboutEstimateTitle => 'Derbarê texmîna zêdebûna lezê';

  @override
  String get sdAboutEstimateBody =>
      'Her dîtin zêdebûneke texmînî ya bi hişyarî nîşan dide — tiştê ku hûn dikarin piştî sererastkirinê rasteqîn hêvî bikin. Ev sînorekî jêrîn e, ne garantî ye, û bi şert û mercên testê ve girêdayî ye.';

  @override
  String get diagnosisFailed => 'Teşhîs biserneket';

  @override
  String get retryLabel => 'DÎSA BICEHRIBÎNE';

  @override
  String get settingsIncludeHiddenDesc =>
      'Bi çalakî li SSIDên veşartî digere. Bi xwerû girtî ye — tenê li ser torên xwe çalak bikin.';

  @override
  String get autoScanLabel => 'Tarandina Xweber';

  @override
  String autoScanDesc(int seconds) {
    return 'Her ${seconds}s bi xweber taranekê dubare bike';
  }

  @override
  String get deepScanLabel => 'Tarandina Kûr';

  @override
  String get deepScanDesc =>
      'Girtina banner + analîza eşkerebûnê. Tenê li ser torên ku destûra we ya testkirinê heye çalak bikin.';

  @override
  String get restrictDeepScanPublicLabel =>
      'Tarandina Kûr li Wi-Fi ya Giştî Sînordar Bike';

  @override
  String get restrictDeepScanPublicDesc =>
      'Dema bi torek giştî an mêvan ve girêdayî ne, taqîbê çalak rawestîne. Tê pêşniyarkirin — tarandinên çalak li ser torên ku ne yên we ne rîska sereke ya hiqûqî ne.';

  @override
  String get backgroundMonitoringLabel => 'Şopandina Paşxaneyê';

  @override
  String get backgroundMonitoringDesc =>
      'Her 30 xulekan carekê kontrolek Wi-Fi ya bêdeng bimeşîne, tewra sepan girtî be jî. Heke cîhazek nû derkeve, tora girêdayî biguhere, an şîfrekirin biguhere hûn ê agahdariyek bistînin. Tesîra bataryayê hindik e. Piştgiriya iOS sînordar e (nûvekirina ji hêla pergalê ve tê kontrolkirin).';

  @override
  String get portScanTimeoutLabel => 'Dema Rawestandinê ya Tarandina Portê';

  @override
  String get privacyAndDataLabel => 'NEPENÎTÎ Û DANE';

  @override
  String get dataRetentionLabel => 'HILANÎNA DANEYAN';

  @override
  String get scanHistoryRetentionLabel => 'Dîroka Tarandinê';

  @override
  String get speedTestsRetentionLabel => 'Testên Lezê';

  @override
  String get securityEventsRetentionLabel => 'Bûyerên Ewlehiyê';

  @override
  String get replayOnboardingLabel => 'Rêberiyê Dîsa Bibîne';

  @override
  String get replayOnboardingDesc => 'Tûra bi xêrhatinê dîsa bibînin.';

  @override
  String get wipeAllDataLabel => 'Hemû Daneyên Herêmî Jê Bibe';

  @override
  String get wipeAllDataDesc =>
      'Hemû dîroka tarandinê, testên lez, bûyerên ewlehiyê û nirxandinên kanalê ji vê cîhazê jê dibe.';

  @override
  String get aboutLabel => 'DERBARÊ';

  @override
  String get legalDisclaimerTitle => 'Redkirina Hiqûqî';

  @override
  String get legalDisclaimerBody =>
      'This application performs network observation and authorized LAN discovery. Active probing is strictly limited to service identification and security assessment. No brute-force authentication, frame injection, deauthentication packets, ARP poisoning, or credential harvesting are performed.\n\nUse of this application on networks you do not own or are not authorized to test may violate applicable laws (TCK 243/244, EU Directive 2013/40, CFAA). The user is solely responsible for ensuring lawful use.\n\nBu uygulama ağ gözlemi ve yetkili LAN keşfi gerçekleştirir. Aktif sorgulama yalnızca servis tanımlama ve güvenlik değerlendirmesi ile sınırlıdır. Yetkisiz ağlarda kullanım TCK 243/244 kapsamında suç teşkil edebilir.';

  @override
  String get enableDeepScanTitle => 'TARANDINA KÛR ÇALAK BIKE?';

  @override
  String get enableDeepScanBody =>
      'Tarandina kûr girtina banner û analîza eşkerebûna xizmetê pêk tîne. Ev mod tenê divê li ser torên xwedî we an torên ku destûra we ya eşkere ya testkirinê heye were bikaranîn.\n\nBerdewamkirin li ser torên bêdestûr dibe ku qanûnên li ser bandê binpê bike.';

  @override
  String get wifiScanPermissionTitle => 'DESTÛRA TARANDINA WIFI';

  @override
  String get wifiScanPermissionDesc =>
      'Ji bo vedîtina torên Wi-Fi yên nêzîk û analîzkirina hêza sînyalê, Torcavê pêwîstiya gihîştina Cih heye. Ev pêwîstiyeke pergala Android ji bo tarandina Wi-Fi ye.';

  @override
  String get consentScanSsids => 'SSIDên Wi-Fi yên nêzîk bitarîne';

  @override
  String get consentAnalyzeSignal =>
      'Kalîteya sînyal û tevliheviyê analîz bike';

  @override
  String get consentNoTracking => 'Torcav qet cihê we naşopîne an parve nake';

  @override
  String get continueLabel => 'BERDEWAM';

  @override
  String get clearWifiHistoryBody =>
      'Hemû danişînên tarandina Wi-Fi yên tomarkirî werin jêbirin? Ev nayê vegerandin.';

  @override
  String get transparentSignalAnalysisTitle => 'ANALÎZA SÎNYALÊ YA ŞEFAF';

  @override
  String get transparentSignalAnalysisDesc =>
      'Analîza spektrûmê ya pêşketî ji bo teftîşa ewlehiyê. Tenê pêvajokirina herêmî.';

  @override
  String get cachedResultsWarning =>
      'Encamên cache têne nîşandan — Android frekansa tarandinê sînordar dike. ~30 s bisekinin û ji bo daneyên zindî nû bikin.';

  @override
  String get enableDeepScanBodyWifi =>
      'Tarandina Kûr girtina banner û analîza eşkerebûnê pêk tîne. Tenê li ser torên ku destûra we ya tarandinê heye bikar bînin. Bikaranîna bêdestûr dibe ku TCK 243/244 û qanûnên wek wê binpê bike.';

  @override
  String get iAmAuthorized => 'DESTÛRA MIN HEYE';

  @override
  String get iosWifiScanLimited =>
      'iOS: Encamên tarandina Wi-Fi ji hêla APIyên Apple ve sînordar in. Destpêkirina tarandina çalak û hin hûrgiliyên torê ne berdest in.';

  @override
  String get allCategoriesLabel => 'Hemû kategorî (yek pakêt)';

  @override
  String get autoLabel => 'Xweber';

  @override
  String get lightLabel => 'Ronî';

  @override
  String get darkLabel => 'Tarî';

  @override
  String get dismissLabel => 'Bigire';

  @override
  String get applyLabel => 'Bicîh Bîne';

  @override
  String get openSettingsLabel => 'Mîhengan veke';

  @override
  String get privacyPolicyTitle => 'Siyaseta Nepenîtiyê';

  @override
  String get encryptionAndConfigTitle => 'ŞÎFREKIRIN & MÎHENG';

  @override
  String get environmentScanTitle => 'TARANDINA HAWÎRDORÊ';

  @override
  String get dnsTestFailedTitle => 'Testa DNS Biserneket';

  @override
  String get dnsTestFailedDesc =>
      'Nikarî bigihîje serverên testa DNS. Girêdana xwe kontrol bikin.';

  @override
  String get dnsLeakDetectedTitle => 'Derketina DNS Hat Dîtin';

  @override
  String get dnsLeakDetectedDesc =>
      'Pirsên DNS ya we ji resolvera pêşbînîkirî derdikevin, dibe ku çalakiya geriyana we ji ISP an aliyên din re eşkere bike.';

  @override
  String get dnsHijackingDetectedTitle => 'Revandina DNS Hat Dîtin';

  @override
  String get dnsHijackingDetectedDesc =>
      'Bersivên DNS ber bi serverek nediyar ve têne zivirandin. Ev dibe ku nîşana êrîşeke man-in-the-middle an destwerdana ISP be.';

  @override
  String get dnsConfigWarningTitle => 'Hişyariya Mîhengên DNS';

  @override
  String get dnsConfigWarningDesc =>
      'Mîhengên DNS pirsgirêkên gengaz hene ku dikarin bandorê li nepenîtî an ewlehiyê bikin.';

  @override
  String get noIssuesDetected => 'Tu pirsgirêk nehat dîtin';

  @override
  String get retryInternetConnection =>
      'Dema bi înternetê ve girêdayî bin dîsa biceribînin.';

  @override
  String get dnsLeakRecommendation =>
      'Resolvereke DNS ya bawer mîheng bikin (mînak 1.1.1.1 an 9.9.9.9) û DNS-over-HTTPS (DoH) an DNS-over-TLS (DoT) çalak bikin.';

  @override
  String get dnsHijackingRecommendation =>
      'Yekser biçin ser VPNê. Pirsên DNS ya we têne destwerdan.';

  @override
  String get dnsConfigRecommendation =>
      'Mîhengên DNS xwe binirxînin û dabînkerekî DNS ya li ser nepenîtiyê hûr dibe bihesibînin.';

  @override
  String openNetworksNearbyTitle(int count) {
    return '$count Torên Vekirî Nêzîk';
  }

  @override
  String openNetworksNearbyDesc(int count) {
    return '$count tor(ên) neşîfrekirî di rêzê de hatin dîtin. Torên vekirî bi hêsanî têne guhdarîkirin.';
  }

  @override
  String wpsEnabledNearbyTitle(int count) {
    return '$count Tor(ên) bi WPS Çalak';
  }

  @override
  String wpsEnabledNearbyDesc(int count) {
    return 'WPS li ser $count tor(ên) nêzîk çalak e. PINa WPS dikare bi zorê were şikandin, bi tevahî derbasî şîfreya Wi-Fi bibe.';
  }

  @override
  String get wpsRecommendation =>
      'WPS li ser routera xwe neçalak bikin. Heke ev ne torên we ne, bala xwe bidin ku APên nêzîk dibe kêmtir ewle bin.';

  @override
  String get renderingErrorTitle => 'ÇEWTIYA RENDERKIRINÊ';

  @override
  String get renderingErrorBody =>
      'Dema ev rûpel dihat çêkirin çewtiyek çêbû. Ji kerema xwe sepanê ji nû ve bide destpêkirin.';

  @override
  String get dbHealedNotice =>
      'Hin daneyên we ji bo çareserkirina pirsgirêkek bîranînê hatin sifirkirin. Heke pêwîst be, torên xwe yên pêbawer ji nû ve mîheng bikin.';

  @override
  String get pingStabilizerConsentTitle => 'Aramkerê Pingê çalak bike';

  @override
  String get pingStabilizerConsentDesc =>
      'Ji bo pîşkandina jitterê û beralikirina DNSê ji bo lîstik/weşana aram, dê tunelek VPNê ya li ser amûrê were avakirin.';

  @override
  String get pingStabilizerConsentRouting =>
      'Trafîka we li ser amûra we dimîne. Tu daneyek nayê şandin ser servereke dûr.';

  @override
  String get pingStabilizerConsentDns =>
      'Tenê pirsên DNSê têne beralikirin; pakêtên din bê guhertin derbas dibin.';

  @override
  String get pingStabilizerConsentControl =>
      'Hûn dikarin tunelê her gav ji vê ekranê an ji hişyariyê rawestînin.';

  @override
  String get pingStabilizerConsentAction => 'Aramkerê dest pê bike';

  @override
  String get appTitleLong => 'Torcav Analîzkerê Wi-Fi';

  @override
  String get tosTitle => 'MERCÊN XIZMETÊ';

  @override
  String get tosAcceptanceTitle => '1. QEBÛLKIRIN';

  @override
  String get tosAcceptanceBody =>
      'Bi gihîştin an bikaranîna Torcavê, hûn qebûl dikin ku bi van Mercan ve girêdayî bin. Heke qebûl nakin, divê hûn tavilê bikaranîna Sepanê rawestînin.';

  @override
  String get tosAuthorizedTestingTitle => '2. TENÊ TESTA BI DESTÛR';

  @override
  String get tosAuthorizedTestingBody =>
      'Hûn beyan û garantî dikin ku hûn ê Sepanê tenê ji bo analîzkirina torên û cîhazên xwedî we an yên ku destûra we ya eşkere û nivîskî ya testkirinê heye bikar bînin. Gihîştina bêdestûr a torê tam qedexe ye û dibe ku li welatê we neqanûnî be.';

  @override
  String get tosDisclaimerTitle => '3. REDKIRINA GARANTIYAN';

  @override
  String get tosDisclaimerBody =>
      'Sepan \"wek e\" û \"wek berdest e\" tê pêşkêşkirin. Em garantî nakin ku Sepan hemû qelsiyên ewlehiyê nas bike an encamên wê %100 rast bin. Bikaranîn bi rîska we ye.';

  @override
  String get tosLiabilityTitle => '4. SÎNORKIRINA BERPIRSIYARIYÊ';

  @override
  String get tosLiabilityBody =>
      'Bi ti awayî pêşdebir berpirsiyar nabin ji bo zirarên (di nav de, lê bêyî sînorkirin, zirara windakirina daneyan an qezencê, an navberdana karsaziyê) ku ji bikaranîn an nekaranîna Sepanê derdikevin.';

  @override
  String get tosModificationsTitle => '5. GUHERÎN';

  @override
  String get tosModificationsBody =>
      'Em mafê xwe diparêzin ku van mercan her dem biguherînin. Berdewamkirina bikaranîna Sepanê piştî guherînan tê wateya qebûlkirina mercên nû.';

  @override
  String get tosLastUpdated => 'Dawî Hat Nûvekirin: Nîsan 2026';

  @override
  String get legalNoticeTitle => 'AGAHDARIYA HIQÛQÎ';

  @override
  String get legalNoticeBody =>
      'Ev sepan amûrek teftîşa ewlehiyê ye. Bikaranîna xerab a vê nermalavê ji bo gihîştin an şopandina torên bêdestûr tam qedexe ye.';

  @override
  String get privacyTitle => 'SIYASETA NEPENÎTIYÊ';

  @override
  String get privacyIntro =>
      'Torcav li ser prensîba \"Nepenîtî wek Standard\" hatiye avakirin. Hema hemû bayt li ser cîhaza we dimîne — ti hesab, ti senkronîzasyona cloud, ti analytics, ti reklam. Çend taybetmendî bi endpointên teknîkî yên giştî ve girêdayî ne (Cloudflare, proba portala girtî ya Google, resolverên DNS yên giştî) — ew tenê IP ya we dibînin, qet nasnavekî hundirîn ê Torcavê na. Hûn dikarin bi yek tikandinê hemû tomarên hilanîbûyî jê bibin.';

  @override
  String get privacyViewFullGithub => 'SIYASETA TEVAHÎ LI SER GITHUBÊ BIBÎNE';

  @override
  String get privacyFullPolicyDesc =>
      'Lîsteya kartan a li jêr kurteyek e. Siyaseta kanonîk, bi formata KVKK + GDPR, li github.io tê hostkirin.';

  @override
  String get privacyResponsibleTitle => 'KÎ BERPIRSIYAR E';

  @override
  String get privacyIndividualDev => 'Pêşdebirê Takekesî';

  @override
  String privacyDevBody(String email) {
    return 'Torcav ji hêla pêşdebirekî takekesî (Halil İbrahim Avşar) ve tê xebitandin, ne ji hêla şîrketek tomarkirî ve. Hûn dikarin rasterast bi kontrolkerê daneyan re bi $email re têkilî daynin.';
  }

  @override
  String get privacyDataCollectionTitle => 'BERHEVKIRIN Û BIKARANÎNA DANEYAN';

  @override
  String get privacyWifiAnalysisTitle => 'Analîza Wi-Fi û Torê';

  @override
  String get privacyWifiAnalysisBody =>
      'Metadaneyên SSID/BSSID/RSSI yên nêzîk û nîşanên ewlehiyê (WPA2/WPA3/WPS/PMF) ji API ya tarandina pergalê têne xwendin. Ev dane li databaseyeke SQLite ya herêmî û şîfrekirî dimîne. Qet nayê barkirin.';

  @override
  String get privacyLanInventoryTitle => 'Envantera Cîhazên LAN';

  @override
  String get privacyLanInventoryBody =>
      'Dema hûn taranekê LAN bimeşînin, sepan IP/MAC/hostname/hilberîner/portên vekirî yên cîhazên li ser heman torê berhev dike. Ev dibe ku cîhazên aliyên sêyem tê de hebin — anonîmkirin ji bo eksporê bi xwerû çalak e.';

  @override
  String get privacyLocationTitle => 'Destûra Cih (Tenê Wi-Fi)';

  @override
  String get privacyLocationBody =>
      'Android ji bo çalakkirina tarandina Wi-Fi destûra cih hewce dike. Torcav wê tenê ji bo vê armancê bikar tîne — em koordînatên GPS naxwînin û tevgerê naşopînin.';

  @override
  String get privacySensorsTitle => 'Senzor û Nexşeya Germahiyê';

  @override
  String get privacySensorsBody =>
      'Naskirina çalakiyê + IMU/barometer di dema anketên nexşeya germahiyê de têne bikaranîn da ku hêza sînyalê li gorî rêça we ya relatîf (destpêk = destpêka tarandinê) were nexşekirin. GPS nayê bikaranîn.';

  @override
  String get privacyAiTitle => 'AI / Dabeşkirina Herêmî';

  @override
  String get privacyAiBody =>
      'Naskirina cureya cîhazê modelek ONNX ya herêmî bikar tîne. Ti daneyên taybet an hilberîner ji cîhazê dernakevin.';

  @override
  String get privacyExternalEndpointsTitle => 'ENDPOINTÊN DERVEYÎ';

  @override
  String get privacyCloudflareTitle => 'Testa Lezê ya Cloudflare';

  @override
  String get privacyCloudflareBody =>
      'Speed Doctor û rûpela testa lezê ~300-500 MB li dijî speed.cloudflare.com dadixin/hildikişînin. Cloudflare IP ya we dibîne — ti nasnavek an telemetriya Torcavê tê de nine.';

  @override
  String get privacyDnsProbesTitle => 'Probên DNS yên Giştî';

  @override
  String get privacyDnsProbesBody =>
      '1.1.1.1, 8.8.8.8, 9.9.9.9, OpenDNS û AdGuard ji bo pîvana DNS û tespîtkirina derketinê têne pirsîn. Ew pirsên DNS yên standard dibînin (ti nasnavên bikarhêner).';

  @override
  String get privacyCaptivePortalTitle => 'Proba Portala Girtî';

  @override
  String get privacyCaptivePortalBody =>
      'connectivitycheck.gstatic.com daxwazek HEAD a sade distîne da ku portalên girtî bibîne. Ev heman prob e ku Android bi xwe dimeşîne.';

  @override
  String get privacyBreachCheckTitle =>
      'Kontrola Derketina Şîfreyê (Have I Been Pwned)';

  @override
  String get privacyBreachCheckBody =>
      'Kontrola derketinê bi k-anonîmiyê api.pwnedpasswords.com dipirse: şîfre li ser vê cîhazê dibe hasheke SHA-1 û tenê 5 tîpên pêşîn ên hashê tên şandin. Şîfreya tevahî an hasha tevahî tu carî ji telefonê dernakeve; tiştek nayê tomarkirin.';

  @override
  String get privacyNoTrackersTitle => 'Ti Analytics, Ti Şopîner, Ti Reklam';

  @override
  String get privacyNoTrackersBody =>
      'Di v1.0 de sifir SDKên analytics, sifir IDên reklamê, sifir xizmetên raporkirina qezayê hene. Em dema destpêkirina sepanê têkiliyê danayin.';

  @override
  String get privacyRetentionTitle => 'HILANÎN Û JÊBIRIN';

  @override
  String get privacyConfigRetentionTitle => 'Hilanîna Mîhengbar';

  @override
  String get privacyConfigRetentionBody =>
      'Mîheng → Nepenîtî dihêle hûn dema hilanînê (7-365 roj) ji bo dîroka tarandinê, testên lez, û bûyerên ewlehiyê saz bikin. Standard 30 roj e. Tomarên kevn bixweber têne rakirin.';

  @override
  String get privacyWipeLocalDataTitle => 'Hemû Daneyên Herêmî Jê Bibe';

  @override
  String get privacyWipeLocalDataBody =>
      'Bi yek tikandinê di Mîheng → Nepenîtî de hemû tomarên hilanîbûyî têne pakkirin: taran, cîhaz, bûyerên ewlehiyê, danişînên nexşeya germahiyê, dîroka LAN, eksport. Nayê vegerandin.';

  @override
  String get privacyRightsTitle => 'MAFÊN WE';

  @override
  String get privacyKvkkGdprTitle => 'KVKK (Tirkiye) + GDPR (EU/EEA)';

  @override
  String privacyRightsBody(String email) {
    return 'Hûn dikarin daxwaza gihîştin, sererastkirin, jêbirin, an veguhastina daneyên xwe bikin. Ji bo jêbirinê, bişkoja Hemûyan Pak Bike ya di sepanê de rêya herî zû ye. Ji bo daxwazên din, $email e-name bişînin — em di 30 rojan de bersivê didin.';
  }

  @override
  String get privacyChildrenTitle => 'Nepenîtiya Zarokan';

  @override
  String get privacyChildrenBody =>
      'Torcav ne ji bo bikarhênerên di bin 13 salî de ye û texmîn dike bikarhêner bes mezin e ku berpirsiyariya torê ya têne tarandin hilgire.';

  @override
  String get privacyAuthorisedUseTitle => 'Tenê Bikaranîna bi Destûr';

  @override
  String get privacyAuthorisedUseBody =>
      'Torcavê li ser torên xwedî we an yên ku destûra we ya eşkere ya tarandinê heye bikar bînin. Vedîtina LAN ya çalak û tarandina portê li ser torên ku ne yên we ne dibe ku qanûnên Tirk, EU, û US binpê bike.';

  @override
  String get privacyContactLabel => 'TÊKILÎ';

  @override
  String get privacyEffectiveDate =>
      'Ji 08.05.2026 ve derbasdar • Guhertoya 1.0';

  @override
  String get hardeningTitle => 'TUNDKIRINA ROUTERÊ';

  @override
  String get hardeningMarkDone => 'WEK QEDIYAYÎ NÎŞAN BIKE';

  @override
  String get hardeningOpenAdmin => 'PANELA ADMIN VEKE';

  @override
  String get hardeningStepsTitle => 'GAVÊN ÇALAKIYÊ';

  @override
  String get hardeningMenuHintsTitle => 'NAVÊN MENUYÊ YÊN ADETÎ';

  @override
  String get hardeningCriticalBadge => 'KIRÎTÎK';

  @override
  String get hardeningChangeAdminPasswordTitle =>
      'Şîfreya admin a routerê biguherîne';

  @override
  String get hardeningChangeAdminPasswordBody =>
      'Nasnameyên admin ên standard (admin/admin, admin/password) bi giştî hatine belgekirin. Her kesê li Wi-Fiya we dikare panela admin veke û mîhengan ji nû ve binivîse — DNS bidize, tîrafîkê bizivirîne, we asteng bike.';

  @override
  String get hardeningChangeAdminPasswordStep1 =>
      'Li bişkoja mezin a VEKIRINA PANELA ADMIN a li serê vê rûpelê bitikînin. Browsera we rûpela têketina routerê vedike.';

  @override
  String get hardeningChangeAdminPasswordStep2 =>
      'Têkevin. Heke we neguherandiye, \"admin\" wek navê bikarhêner û \"admin\" an \"password\" wek şîfre biceribînin.';

  @override
  String get hardeningChangeAdminPasswordStep3 =>
      'Menuyek bi navê \"Administration\", \"System\", \"Maintenance\" an \"Account\" bibînin.';

  @override
  String get hardeningChangeAdminPasswordStep4 =>
      'Di wê menuyê de li \"Login password\", \"Admin password\" an \"Change password\" bigerin.';

  @override
  String get hardeningChangeAdminPasswordStep5 =>
      'Şîfreyeke NÛ hilbijêrin — bi kêmî 12 tîp, tevlihevî ya tîpên mezin, biçûk, hejmar û sembolekî.';

  @override
  String get hardeningChangeAdminPasswordStep6 =>
      'Tomar bike / Bicîh bîne. Dibe ku router ~30 saniyeyan ji nû ve dest pê bike.';

  @override
  String get hardeningChangeAdminPasswordStep7 =>
      'Şîfreya nû li cihekî ewle binivîsin.';

  @override
  String get hardeningChangeAdminPasswordStep8 =>
      'Piştî tomarkirinê, vegerin vir û li WEK QEDIYAYÎ NÎŞAN BIKE bitikînin.';

  @override
  String get hardeningUseWpa3OrWpa2AesTitle =>
      'WPA3 bikar bînin, li WPA2-AES vegerin';

  @override
  String get hardeningUseWpa3OrWpa2AesBody =>
      'WPA3 standarda şîfrekirina Wi-Fi ya nûjen e. WPA/TKIP û WEP di çend deqeyan de têne şikandin.';

  @override
  String get hardeningDisableWpsTitle => 'WPS neçalak bike';

  @override
  String get hardeningDisableWpsBody =>
      'WPS dihêle êrîşkar di çend demjimêran de şîfreya Wi-Fi ya we derbas bikin. Wê bigirin.';

  @override
  String get hardeningEnablePmfTitle => 'PMF / 802.11w çalak bike';

  @override
  String get hardeningEnablePmfBody =>
      'Çarçoveyên Rêveberiyê yên Parastî pêşî li êrîşkaran digirin ku cîhazên we ji torê derxin.';

  @override
  String get hardeningEnableGuestNetworkTitle => 'Torek mêvan çalak bike';

  @override
  String get hardeningEnableGuestNetworkBody =>
      'SSIDek duyem ji bo mêvan û cîhazên IoT torê we ya taybet ewle dihêle.';

  @override
  String get hardeningDisableRemoteAdminTitle =>
      'Admin a dûr / WAN neçalak bike';

  @override
  String get hardeningDisableRemoteAdminBody =>
      'Heke panela admin ji înternetê were gihîştin, her kes dikare şîfreyên standard biceribîne.';

  @override
  String get hardeningUpdateFirmwareTitle => 'Firmware nû bike';

  @override
  String get hardeningUpdateFirmwareBody =>
      'Piraniya routerên malê qelsiyên ewlehiyê yên naskirî hene ku hilberîner bêdeng sererast dikin.';

  @override
  String get hardeningStrongPassphraseTitle =>
      'Şîfreyeke Wi-Fi ya bihêz bikar bînin';

  @override
  String get hardeningStrongPassphraseBody =>
      '12+ tîp, tevlihevî ya mezin/biçûk, tu carî ji xizmetek din venegerandî.';

  @override
  String gatewayCopyError(String ip) {
    return 'Browser bixweber venebû. IP ya dergehê $ip hate kopîkirin — wê li şerîdê navnîşanê ya browsera xwe pêve bikin.';
  }

  @override
  String gatewayCopied(String ip) {
    return 'IP ya dergehê $ip li clipboardê hate kopîkirin.';
  }

  @override
  String get hardeningConnectWifiHint =>
      'Ji bo şopandina pêşketinê li gorî her routerê bi Wi-Fiya xwe ya malê ve girê bidin. Lîsteya kontrolê bêyî girêdanê jî dixebite.';

  @override
  String get progressLabel => 'PÊŞKETIN';

  @override
  String get tapToCopy => 'ji bo kopîkirinê bitikîne';

  @override
  String get hardeningOpenAdminDesc =>
      'Rûpela têketina routerê di browserê de veke';

  @override
  String get hardeningConnectWifiRequired => 'Pêşî bi Wi-Fiyê ve girê bidin';

  @override
  String get hardeningGatewayHintDisconnected =>
      'Gava girêdayî bin, IP ya dergehê li jorê xuya dibe û bişkok browsera we vedike.';

  @override
  String get hardeningGatewayHintConnected =>
      'Venabe? Li IP ya dergehê ya li jorê bitikînin da ku wê kopî bikin, paşê li şerîdê navnîşanê ya browsera xwe pêve bikin (Chrome, Firefox, hwd.).';

  @override
  String get whyThisMattersLabel => 'EV ÇIMA GIRÎNG E';

  @override
  String get markAsTodoLabel => 'WEK KARÊ MAYÎ NÎŞAN BIKE';

  @override
  String get vpnRecommendation =>
      'Dema bi torên nenas an bêbawer ve girêdayî dibin, VPNeke bawer bikar bînin.';

  @override
  String get exportLocalDataTitle => 'DANEYÊN HERÊMÎ EKSPORT BIKE';

  @override
  String get exportLocalDataDesc =>
      'Daneyên we li ser vê cîhazê, di destê we de. Kategoriyekê hilbijêrin û wek JSON parve bikin an tomar bikin.';

  @override
  String get exportCategoryLabel => 'Kategorî';

  @override
  String get exportFormatLabel => 'Format';

  @override
  String get jsonExportLabel => 'JSON — tevahî, ji hêla makîneyê ve tê xwendin';

  @override
  String get csvExportLabel => 'CSV — di Excel/Sheets de vedibe';

  @override
  String get csvSingleCategoryOnlyLabel => 'CSV — tenê yek kategorî';

  @override
  String get htmlExportLabel => 'HTML — di browserê de tê dîtin';

  @override
  String get anonymizeIdentifiersLabel => 'Nasnavan anonîm bike';

  @override
  String get anonymizeIdentifiersDesc =>
      '3 oktetên dawî yên BSSID/MAC veşêre, SSID û hostname jê bibe.';

  @override
  String get noIdentifiersToMaskDesc =>
      'Vê kategoriyê nasnavên ku werin veşartin tune.';

  @override
  String get exportingLabel => 'TÊ EKSPORTKIRIN…';

  @override
  String exportAsLabel(String format) {
    return 'WEK $format EKSPORT BIKE';
  }

  @override
  String get exportPrivacyNote =>
      'Heta ku hûn parve bikin li ser cîhaza we dimîne. Tiştek ji serverekê re nayê şandin.';

  @override
  String get categoryWifiScanHistory => 'Dîroka tarandina Wi-Fi';

  @override
  String get categorySpeedTestResults => 'Encamên testa lezê';

  @override
  String get categorySecurityEvents => 'Bûyerên ewlehiyê';

  @override
  String get categoryKnownAndTrustedNetworks => 'Torên naskirî + bawer';

  @override
  String get categoryChannelRatingsHistory => 'Dîroka nirxandina kanalan';

  @override
  String get categoryHeatmapSessions => 'Danişînên nexşeya germahiyê';

  @override
  String get categoryLanScanLatest => 'Tarandina LAN (ya dawî)';

  @override
  String get categoryDeviceLabelOverrides => 'Veguherandinên etîketa cîhazan';

  @override
  String get categoryPinnedNetworks => 'Torên pêvekirî';

  @override
  String get categoryScoreHistory => 'Dîroka xala ewlehiyê';

  @override
  String get categoryNetworkContextOverrides => 'Veguherandinên çarçoveya torê';

  @override
  String get categoryRouterHardeningProgress => 'Pêşketina tundkirina routerê';

  @override
  String get macRandomizedLabel => 'MAC Rasthatî';

  @override
  String get notificationsBlockedTitle => 'Agahdarî têne astengkirin';

  @override
  String get notificationsBlockedDesc =>
      'HUD ya pingê ya zindî di şerîda agahdariyê de dijî. Bêyî agahdarî hûn nikarin dema lîstinê pingê bibînin. Li ser MIUI/Xiaomi, herwiha \"Li ser ekrana girtî nîşan bide\" û \"Agahdariyên gemarî\" jî çalak bikin.';

  @override
  String get liveLatencyLabel => 'Gecikîna zindî';

  @override
  String get latencyStatLabel => 'Gecikîn';

  @override
  String get jitterStatLabel => 'Jitter';

  @override
  String get lossStatLabel => 'Windabûn';

  @override
  String baselineLatencyLabel(String ms) {
    return 'Bingeh (berî tunelê): $ms ms';
  }

  @override
  String jitterThresholdLabel(String ms) {
    return 'Asta hişyariya jitterê: $ms ms';
  }

  @override
  String get heatmapSettingsTitle => 'Mîhengên Nexşeya Germahiyê';

  @override
  String get dnsLabel => 'DNS';

  @override
  String get notNowLabel => 'NIHA NA';

  @override
  String get newNetworkLabel => '+ NÛ';

  @override
  String get goneNetworkLabel => 'ÇÛYE';

  @override
  String get hiddenNetworkLabel => '[Veşartî]';

  @override
  String get randomizedMacDetectedLabel => 'MAC ya Rasthatî Hat Dîtin';

  @override
  String get howPingStabilizerWorksTitle => 'Ping Stabilizer çawa dixebite';

  @override
  String get stabilizerExplainerSubtitle =>
      'Li ser cîhazê, bêyî server, belaş.';

  @override
  String get whatItDoesTitle => 'Ew çi dike';

  @override
  String get whatItDoesBullet1 =>
      'Tunelek VPN ya herêmî li ser cîhaza we ava dike — ti tîrafîk ji serverekî aliyê sêyem derbas nabe.';

  @override
  String get whatItDoesBullet2 =>
      'Pirsên DNS ber bi resolvera herî zû (1.1.1.1, 8.8.8.8, 9.9.9.9, …) dizivirîne, bi zindî tê pîvandin.';

  @override
  String get whatItDoesBullet3 =>
      'Her saniyeyê gecikîn/jitterê dişopîne û dema pêketinek berdewam dike hişyar dike, dikare tunelê ji nû ve ava bike da ku rêyeke xerab a sipartî bişkîne.';

  @override
  String get whatItDoesBullet4 =>
      'Fîltera EWMA (nimûneyên nû giranîtir têne hesibandin) bikar tîne da ku ji xirabûna rastîn re bertek nîşan bide, ne ji dengê pakêtekî bi tenê.';

  @override
  String get whatItDoesNotTitle => 'Ew çi NAKE';

  @override
  String get whatItDoesNotBullet1 =>
      'Ew nikare rêya ISPya we ber bi servera lîstikê ve fîzîkî kurttir bike — ti sepana li ser cîhazê nikare vê bike.';

  @override
  String get whatItDoesNotBullet2 =>
      'Ew şûna xizmetek VPN/relay ya dravdayî wek ExitLag an WTFast nagire (ew ji serverên xwe derbas dibin; ev tenê herêmî ye).';

  @override
  String get whatItDoesNotBullet3 =>
      'Şandina \"pêşî-here\" ya pir-rê li ser Wi-Fi + mobîl li ser rêçikê ye (Qonaxa 2) û niha neçalak e.';

  @override
  String get risksAndThingsToKnowTitle =>
      'Rîsk û tiştên ku hûn hewce ne zanibin';

  @override
  String get risksBullet1 =>
      'Dema tunel çalak be Android îkonek mifteyê nîşan dide — ev normal e û ji hêla pergalê ve tê xwestin.';

  @override
  String get risksBullet2 =>
      'Tenê yek VPN bi carekê dikare bimeşe. Heke sepaneke VPN ya din girêdayî be, ev ê red bike ku dest pê bike.';

  @override
  String get risksBullet3 =>
      'Dema tunel dimeşe agahdariyeke zindî ya berdewam (pinga niha + bişkokên Rawestandin / Zivirandin) di şerîdê de dimîne — ev HUD ya we ya di-lîstikê ye; wê meşînin.';

  @override
  String get risksBullet4 =>
      'Li ser Xiaomi/MIUI, OnePlus/OxygenOS û skînên wek wan, dibe ku hûn hewce bikin Torcavê di bin Mîheng → Agahdarî û Mîheng → Bataryayê → Ti sînor de destûr bidin, wekî din OS ê agahdariyê bêdeng vedişêre.';

  @override
  String get risksBullet5 =>
      'Guhertina xweber a DNS dema tunel çalak be dê biguherîne kîjan resolver bersivên we dide. Ew guherîn dema hûn stabilizer rawestînin vedigere.';

  @override
  String get risksBullet6 =>
      'Bikaranîna bataryayê hindik e (~3-5%/saet li gorî testên me) lê ne sifir e — dema qedandina lîstinê wê bigirin.';

  @override
  String get shieldIntegrityLabel => 'TEVAHIYA QEWLÊN PARASTINÊ';

  @override
  String get activeThreatsLabel => 'GEFÊN ÇALAK';

  @override
  String get shieldStatusOptimal => 'BAŞTERÎN';

  @override
  String get shieldStatusWarning => 'HIŞYARÎ';

  @override
  String get shieldStatusCritical => 'KIRÎTÎK';

  @override
  String get securityScoreLabel => 'XALA EWLEHIYÊ';

  @override
  String get systemStatusLabel => 'REWŞA PERGALÊ';

  @override
  String get scanningAllCaps => 'TÊ TARANDIN';

  @override
  String bssidLabel(String bssid) {
    return 'BSSID: $bssid';
  }

  @override
  String gatewayWithIpLabel(String gateway) {
    return 'DERGEH: $gateway';
  }

  @override
  String get trustedBadge => 'BAWER';

  @override
  String get identifiedBadge => 'NASKIRÎ';

  @override
  String authEstablishedLabel(String date) {
    return 'AUTH: HAT AVAKIRIN $date';
  }

  @override
  String get revokeTrustTooltip => 'BAWERIYÊ RAKE';

  @override
  String get apsLabel => 'APs';

  @override
  String get openLabel => 'VEKIRÎ';

  @override
  String get wpsLabel => 'WPS';

  @override
  String get wepLabel => 'WEP';

  @override
  String get publicWifiLabel => 'WI-FI GIŞTÎ';

  @override
  String get guestNetworkLabel => 'TORA MÊVAN';

  @override
  String get publicWifiDesc =>
      'Torek vekirî an bêbawer — texmîn bikin ku tîrafîk dikare were dîtin.';

  @override
  String get guestNetworkDesc =>
      'Hûn li beşa mêvan in. Bi xwerû wek bêbawer bihesibînin.';

  @override
  String get tipVpnTitle => 'VPN bikar bînin';

  @override
  String get tipVpnBody =>
      'Berî tiştekî hesas bişînin, tîrafîkê ji VPNeke bawer derbas bikin. VPN ya OSê ya çêbûyî ji bo piraniya bikarhêneran têrê dike.';

  @override
  String get tipHttpsTitle => 'HTTPS piştrast bikin';

  @override
  String get tipHttpsBody =>
      'Nasnameyan tenê li malperên bi kilîdek girtî têkevin. Hişyariyên sertîfîkayê red bikin — êrîşkar bi vî awayî TLSê radikin.';

  @override
  String get tipSensitiveTitle => 'Çalakiyên hesas paşve bikin';

  @override
  String get tipSensitiveBody =>
      'Heta hûn vegerin torek bawer, ji bankîng, dravdan, ji nû ve mîhengkirina şîfreyê û têketina hesaban dûr bimînin.';

  @override
  String get tipDnsTitle => 'Tenduristiya DNS kontrol bikin';

  @override
  String get tipDnsBody =>
      'Hotspotên giştî dikarin DNS bidizin. Ji vê ekranê testek DNS bimeşînin da ku piştrast bikin bersiv nayên nivîsandin.';

  @override
  String evilTwinPrefix(String confidence) {
    return 'EVIL TWIN · $confidence';
  }

  @override
  String get whatIsEvilTwinTitle => 'Evil-twin çi ye?';

  @override
  String get whyItMattersTitle => 'Ev çima girîng e?';

  @override
  String get whatWeObservedTitle => 'Me çi dît';

  @override
  String get whatLookedLegitimateTitle => 'Çi rewa xuya bû';

  @override
  String get whatYouShouldDoTitle => 'Divê hûn çi bikin';

  @override
  String get hardeningUseWpa3OrWpa2AesStep1 =>
      'Bi bişkoja li serî panela admin veke.';

  @override
  String get hardeningUseWpa3OrWpa2AesStep2 =>
      'Beşa bêtêl bibînin: \"Wireless\", \"Wi-Fi\" an \"WLAN\".';

  @override
  String get hardeningUseWpa3OrWpa2AesStep3 =>
      'Li mîhenga ewlehiyê an şîfrekirinê bigerin — bi gelemperî \"Security mode\", \"Authentication\" an \"Encryption\" tê gotin.';

  @override
  String get hardeningUseWpa3OrWpa2AesStep4 =>
      'Vê rêzê bihilbijêrin: WPA3-Personal > WPA2/WPA3 tevlihev > WPA2-Personal (AES). Ji her tiştê bi navê \"WPA-PSK\", \"TKIP\", \"WEP\" an \"Open\" dûr bimînin — ew ne ewle ne.';

  @override
  String get hardeningUseWpa3OrWpa2AesStep5 =>
      'Heke hûn WPA3-Personal saz bikin û cîhazek kevn (ampûla aqilmend, çapker, telefonek kevn) nesekine, biçin \"WPA2/WPA3 tevlihev\" — ev dihêle amûrên kevn girê bidin dema cîhazên nû hîna WPA3 bikar tînin.';

  @override
  String get hardeningUseWpa3OrWpa2AesStep6 =>
      'Heke mîhengên we yên 2.4 GHz û 5 GHz cûda ne, HERDU bandan biguherînin.';

  @override
  String get hardeningUseWpa3OrWpa2AesStep7 =>
      'Tomar bike / Bicîh bîne. Dibe ku cîhazên we kurt veqetin — dê di çend saniyeyan de dîsa têkevin.';

  @override
  String get hardeningUseWpa3OrWpa2AesStep8 =>
      'Vegerin vir û li WEK QEDIYAYÎ NÎŞAN BIKE bitikînin.';

  @override
  String get hardeningDisableWpsStep1 => 'Panela admin veke.';

  @override
  String get hardeningDisableWpsStep2 => 'Beşa Wireless an Wi-Fi bibînin.';

  @override
  String get hardeningDisableWpsStep3 =>
      'Li binmenuyek bi navê \"WPS\", \"Easy Setup\", \"Quick Connect\" an tabek di Mîhengên Wireless de bi navê WPS bigerin.';

  @override
  String get hardeningDisableWpsStep4 => 'Vebijêrka WPS bibin OFF / Neçalak.';

  @override
  String get hardeningDisableWpsStep5 =>
      'Hin router jî bişkojek fîzîkî ya WPS li ser cîhazê hene — ew jî wê rawestin, ev armanc e.';

  @override
  String get hardeningDisableWpsStep6 => 'Tomar bike / Bicîh bîne.';

  @override
  String get hardeningDisableWpsStep7 =>
      'Ji niha û pê ve, dema cîhazek nû girê didin tenê şîfreya Wi-Fi bi awayê normal binivîsin. 10 saniyeyên din digire, lê rêyeke êrîşê ya cidî radike.';

  @override
  String get hardeningDisableWpsStep8 =>
      'Vegerin vir û li WEK QEDIYAYÎ NÎŞAN BIKE bitikînin.';

  @override
  String get hardeningEnablePmfStep1 => 'Panela admin veke.';

  @override
  String get hardeningEnablePmfStep2 => 'Biçin beşa Wireless / Wi-Fi.';

  @override
  String get hardeningEnablePmfStep3 =>
      'Di \"Advanced\" an \"Wireless Security\" de li mîhengek bi navê \"PMF\", \"802.11w\" an \"Management Frame Protection\" bigerin.';

  @override
  String get hardeningEnablePmfStep4 =>
      'Heke hemû cîhazên we nû bin (~5 salên dawî), wê bikin \"Required\". Heke cîhazên kevn êdî torê nabînin, wê bikin \"Optional / Capable\" — dîsa jî dibe alîkar, tenê kêmtir tund.';

  @override
  String get hardeningEnablePmfStep5 =>
      'Heke hûn vê mîhengê qet nabînin, dibe ku router wê di moda WPA3 de bi xwe re bîne (ku gava 2 ya jorîn wê jixwe vedihewîne). Di vê rewşê de jî li WEK QEDIYAYÎ NÎŞAN BIKE bitikînin.';

  @override
  String get hardeningEnablePmfStep6 => 'Tomar bike / Bicîh bîne.';

  @override
  String get hardeningEnablePmfStep7 =>
      'Vegerin vir û li WEK QEDIYAYÎ NÎŞAN BIKE bitikînin.';

  @override
  String get hardeningEnableGuestNetworkStep1 => 'Panela admin veke.';

  @override
  String get hardeningEnableGuestNetworkStep2 =>
      'Menuyek bi navê \"Guest Network\", \"Guest Wi-Fi\" an \"Multi-SSID\" bibînin.';

  @override
  String get hardeningEnableGuestNetworkStep3 =>
      'Wê çalak bikin. Navek cûda ji Wi-Fiya xwe ya sereke bidin wê — mînak, heke ya we ya sereke \"Home\" e, ya mêvan jê re \"Home-Guest\" bibêjin.';

  @override
  String get hardeningEnableGuestNetworkStep4 =>
      'Şîfreyekê saz bikin. Dikare ji ya sereke hêsantir be (mêvan wê binivîsin), lê dîsa jî 10+ tîp.';

  @override
  String get hardeningEnableGuestNetworkStep5 =>
      'Li mîhengek bi navê \"Client Isolation\", \"AP Isolation\" an \"Guest network isolation\" bigerin. Wê BIKIN ON. Ev pêşî li cîhazên mêvan digire ku bi hev re an bi torê we ya taybet re bipeyivin.';

  @override
  String get hardeningEnableGuestNetworkStep6 =>
      'Cîhazên xwe yên IoT (pirîza aqilmend, kamera, robota paqijiyê, TV aqilmend) bibin ser torê mêvan — bi şîfreya nû girê bidin.';

  @override
  String get hardeningEnableGuestNetworkStep7 => 'Tomar bike / Bicîh bîne.';

  @override
  String get hardeningEnableGuestNetworkStep8 =>
      'Vegerin vir û li WEK QEDIYAYÎ NÎŞAN BIKE bitikînin.';

  @override
  String get hardeningDisableRemoteAdminStep1 => 'Panela admin veke.';

  @override
  String get hardeningDisableRemoteAdminStep2 =>
      'Biçin \"Administration\", \"System Tools\" an \"Security\".';

  @override
  String get hardeningDisableRemoteAdminStep3 =>
      'Mîhengek bi navê \"Remote Management\", \"Web Access from WAN\" an \"Remote admin\" bibînin.';

  @override
  String get hardeningDisableRemoteAdminStep4 => 'Wê bikin OFF / Neçalak.';

  @override
  String get hardeningDisableRemoteAdminStep5 =>
      'Li vir dema hene, herwiha \"Cloud / Remote App access\" jî kontrol bikin (hin marka wê hene — TP-Link Tether, Asus Router app, Mi Wi-Fi). Heke hûn bi çalakî wê sepanê bikar naînin, wê jî bigirin.';

  @override
  String get hardeningDisableRemoteAdminStep6 => 'Tomar bike / Bicîh bîne.';

  @override
  String get hardeningDisableRemoteAdminStep7 =>
      'Hûn hîna jî dikarin routera xwe ji hundirê mala xwe ve bi rê ve bibin — tenê rêya dûr / înternetê ya giştî hatiye girtin.';

  @override
  String get hardeningDisableRemoteAdminStep8 =>
      'Vegerin vir û li WEK QEDIYAYÎ NÎŞAN BIKE bitikînin.';

  @override
  String get hardeningUpdateFirmwareStep1 => 'Panela admin veke.';

  @override
  String get hardeningUpdateFirmwareStep2 =>
      'Menuyek bi navê \"Firmware Update\", \"System Update\", \"Online Upgrade\" an \"Maintenance\" bibînin.';

  @override
  String get hardeningUpdateFirmwareStep3 =>
      'Li \"Check for update\" an \"Online check\" bitikînin. Router li serverê hilberîner li guhertoyeke nûtir digere.';

  @override
  String get hardeningUpdateFirmwareStep4 =>
      'Heke nûvekirinek were pêşkêşkirin, wê saz bikin. Router dê 2-5 xulekan ji nû ve dest pê bike — di dema nûvekirinê de wê ji pêvajokê JIBER NEKIN, wekî din dibe ku bêkêr bibe.';

  @override
  String get hardeningUpdateFirmwareStep5 =>
      'Piştî ku vegeriya, biçin heman menuyê û li \"Auto update\" an \"Automatic upgrade\" bigerin. Heke berdest be wê bikin ON.';

  @override
  String get hardeningUpdateFirmwareStep6 =>
      'Hin routerên kevntir nûvekirina serhêl nikarin. Di vê rewşê de, modela routerê ji stîkera cîhazê binivîsin, malpera hilberîner bigerin, dosyeya firmware ya herî nû dakêşin, û vebijêrka \"Manual upload\" ya di heman menuyê de bikar bînin.';

  @override
  String get hardeningUpdateFirmwareStep7 =>
      'Vegerin vir û li WEK QEDIYAYÎ NÎŞAN BIKE bitikînin.';

  @override
  String get hardeningStrongPassphraseStep1 => 'Panela admin veke.';

  @override
  String get hardeningStrongPassphraseStep2 =>
      'Biçin \"Wireless\", \"Wi-Fi\" an \"WLAN\".';

  @override
  String get hardeningStrongPassphraseStep3 =>
      'Qada şîfreyê bibînin — bi navê \"Wireless password\", \"Pre-Shared Key (PSK)\", \"Wireless Key\" an tenê \"Password\".';

  @override
  String get hardeningStrongPassphraseStep4 =>
      'Wê bi şîfreyeke NÛ biguherînin: bi kêmî 12 tîp, tevlihevî ya tîpên mezin, biçûk, hejmar û sembolekî. Ji peyvên ferhengê û agahiyên şexsî (rojbûn, navên heywanên malê) dûr bimînin.';

  @override
  String get hardeningStrongPassphraseStep5 =>
      'Rêyeke baş: sê peyvên bêpêwendî û hejmarekê hilbijêrin, mînak \"correct-horse-battery-9\". Şîfreyên dirêj ji yên kurt û tevlihev zortir têne şikandin.';

  @override
  String get hardeningStrongPassphraseStep6 =>
      'Heke torên we yên 2.4 GHz û 5 GHz cûda ne, HERDUYAN biguherînin.';

  @override
  String get hardeningStrongPassphraseStep7 =>
      'Tomar bike / Bicîh bîne. Her cîhaz dê veqete — li her yekê şîfreya nû ji nû ve binivîsin.';

  @override
  String get hardeningStrongPassphraseStep8 =>
      'Şîfreyê binivîsin (rêveberê şîfreyan, nivîsareke li ser sarincê ji bo mêvanan, tiştê ku ji we re dixebite).';

  @override
  String get hardeningStrongPassphraseStep9 =>
      'Vegerin vir û li WEK QEDIYAYÎ NÎŞAN BIKE bitikînin.';

  @override
  String get severity_critical => 'KIRÎTÎK';

  @override
  String get severity_high => 'BILIND';

  @override
  String get severity_medium => 'NAVÎN';

  @override
  String get severity_low => 'NIZIM';

  @override
  String get severity_info => 'AGAHDARÎ';

  @override
  String get rule_scan_deep_scan_active_title => 'Taqîba Çalak Çalak e';

  @override
  String get rule_scan_deep_scan_active_desc =>
      'Tarandina kûr çalak e, testên torê yên bêtir destwerdanî pêk tîne.';

  @override
  String get rule_scan_deep_scan_active_rec =>
      'Tenê li ser torên xwedî we an yên ku destûra we ya tarandinê heye bikar bînin.';

  @override
  String get rule_wifi_open_network_title => 'Tora Vekirî';

  @override
  String get rule_wifi_open_network_desc =>
      'Şîfrekirin nehat dîtin. Hemû tîrafîk bi awayê text ê sade dikare were guhdarîkirin.';

  @override
  String get rule_wifi_open_network_rec =>
      'Ji çalakiya hesas dûr bimînin. VPNeke bawer an torek din tercîh bikin.';

  @override
  String get rule_wifi_wep_title => 'Şîfrekirina WEP';

  @override
  String get rule_wifi_wep_desc => 'WEP hatiye betalkirin û zû tê şikandin.';

  @override
  String get rule_wifi_wep_rec => 'APê tavilê bike WPA2 an WPA3.';

  @override
  String get rule_wifi_legacy_wpa_title => 'WPA ya Kevn';

  @override
  String get rule_wifi_legacy_wpa_desc =>
      'WPA/TKIP kevntir û li hember teknîkên êrişê yên nûjen lawaztir e.';

  @override
  String get rule_wifi_legacy_wpa_rec => 'APê û clientan bikin WPA2/WPA3.';

  @override
  String get rule_wifi_hidden_ssid_title => 'SSID ya Veşartî';

  @override
  String get rule_wifi_hidden_ssid_desc =>
      'SSIDên veşartî hîna jî têne dîtin û dibe ku li hevgirtinê zirarê bidin.';

  @override
  String get rule_wifi_hidden_ssid_rec =>
      'Tenê SSID veşartin parastin nîne. Xwe li ser şîfrekirina bihêz bisekinînin.';

  @override
  String get rule_wifi_very_weak_signal_title => 'Sînyala Pir Lawaz';

  @override
  String get rule_wifi_very_weak_signal_desc =>
      'Sînyala lawaz dikare nîşana girêdanên nebiçewt û bêparastina li hember spoofingê be.';

  @override
  String get rule_wifi_very_weak_signal_rec =>
      'Nêzî APê biçin an biçewtiya BSSIDê piştrast bikin.';

  @override
  String get rule_wifi_wps_enabled_title => 'WPS Çalak e';

  @override
  String get rule_wifi_wps_enabled_desc =>
      'Wi-Fi Protected Setup (WPS) çalak e. Moda PINa WPS di demjimêran de dikare bi zorê were şikandin, ji her şîfreyekê derbas dibe.';

  @override
  String get rule_wifi_wps_enabled_rec =>
      'WPS di panela admin a routerê de neçalak bikin. Tenê şîfreya WPA2/WPA3 bikar bînin.';

  @override
  String get rule_wifi_pmf_not_enforced_title =>
      'Çarçoveyên Rêveberiyê Neparastî';

  @override
  String get rule_wifi_pmf_not_enforced_desc =>
      'Ev xala gihîştinê Çarçoveyên Rêveberiyê yên Parastî (PMF / 802.11w) neçespîne, dihêle êrîşên deauthentication.';

  @override
  String get rule_wifi_pmf_not_enforced_rec =>
      'PMF di mîhengên routera xwe de çalak bikin (bi gelemperî \"802.11w\" an \"Management Frame Protection\" tê gotin).';

  @override
  String get rule_wifi_suspicious_sibling_ap_title => 'Evil Twin ya Gengaz';

  @override
  String get rule_wifi_suspicious_sibling_ap_desc =>
      'Xalek gihîştinê ya nêzîk vî SSIDî parve dike lê nasnameya wê li hev nayê — ev şêwaza ku êrîşkar ji bo xwe wek Wi-Fiyeke rastîn nîşan dide bikar tîne.';

  @override
  String get rule_wifi_suspicious_sibling_ap_rec =>
      'Heta hûn BSSIDya li piştê routera xwe piştrast bikin, şîfreyan têxin vê torê nekin.';

  @override
  String get rule_wifi_suspicious_ssid_title => 'Navê Torê yê Guman';

  @override
  String get rule_wifi_suspicious_ssid_desc =>
      'Ev SSID bi şêwazên honeypot/xapandinê yên adetî (mînak \"Free WiFi\") ku êrîşkar ji bo xapandina bikarhêneran bikar tînin re li hev tê.';

  @override
  String get rule_wifi_suspicious_ssid_rec =>
      'Berî girêdanê vê torê ligel xwediyê cîhê piştrast bikin. Heke pêwîst be VPN bikar bînin.';

  @override
  String get rule_wifi_high_channel_congestion_title =>
      'Qelebalixiya Kanalê ya Bilind';

  @override
  String get rule_wifi_high_channel_congestion_desc =>
      'Qelebalixiya giran a li ser vê kanalê performans û pêbaweriya girêdanê xera dike.';

  @override
  String get rule_wifi_high_channel_congestion_rec =>
      'Ji admînê torê bixwazin kanalekî kêmtir qelebalix hilbijêre.';

  @override
  String get rule_wifi_only_24ghz_title => 'Tenê 2.4 GHz';

  @override
  String get rule_wifi_only_24ghz_desc =>
      'Ev tor tenê li ser bandê 2.4 GHz yê qelebalix belav dibe. 5 GHz performansek çêtir peyda dike.';

  @override
  String get rule_wifi_only_24ghz_rec =>
      'Ji bo performansek çêtir bandê 5 GHz li ser routera xwe çalak bikin.';

  @override
  String get rule_trusted_baseline_drift_title => 'Guherîna Bingeha Bawer';

  @override
  String get rule_trusted_baseline_drift_desc =>
      'Ev xala gihîştinê êdî bi nasnameya ku we berê pê bawer kiribû re li hev nayê.';

  @override
  String get rule_trusted_baseline_drift_rec =>
      'Mîhengên routerê ji nû ve piştrast bikin û tenê heke guherîn bi qest bûbe dîsa bawer bikin.';

  @override
  String get rule_hardware_vulnerability_title => 'Hardwarea Qels';

  @override
  String get rule_hardware_vulnerability_desc =>
      'Pêşenga BSSID bi profîlek hardware ya qels a naskirî re li hev tê.';

  @override
  String get rule_hardware_vulnerability_rec =>
      'Ji bo nûvekirinên firmware yên hilberîner ên li ser CVEyên naskirî yên vê modelê kontrol bikin.';

  @override
  String get noLiveScanAvailable => 'TARANDINA ZINDÎ TUNE';

  @override
  String noLiveScanDesc(String ssid) {
    return 'Niha taranek Wi-Fi ya nû ya ku \"$ssid\" tê de heye tune, ji ber vê hûrgiliya sînyalê ya zindî ne berdest e. Ji tabê Vedîtin taranekek nû ya Wi-Fi bimeşînin û vê hişyariyê ji nû ve vekin da ku hemû delîlan bibînin.';
  }

  @override
  String get outOf100Label => '/100';

  @override
  String get networkLabel => 'Tor';

  @override
  String get noActivityYet => 'HÊJ ÇALAKIYEK TUNE';

  @override
  String get runFirstScanDesc =>
      'Ji bo dagirtina demnameyê taranakiya xwe ya yekem bimeşînin.';

  @override
  String get networkContextTitle => 'ÇARÇOVEYA TORÊ';

  @override
  String get networkContextHomeDesc =>
      'Mal, ofîs, an routera we ya naskirî. Standardên tund tên bicîhanîn.';

  @override
  String get networkContextPublicDesc =>
      'Qehwexane, otêl, firodgeh, an hotspoteke vekirî. VPN/HTTPS tê pêşniyarkirin bi tundî.';

  @override
  String get networkContextGuestDesc =>
      'Beşa mêvan a torek naskirî. Guherîna xwezayî tê hêvîkirin.';

  @override
  String get networkContextUnknownDesc =>
      'Bihêlin Torcav ji sînyalên pasîf çarçoveyê texmîn bike.';

  @override
  String scanVia(String backend) {
    return 'Bi $backend taran bike';
  }

  @override
  String get justNow => 'niha';

  @override
  String minutesAgo(int count) {
    return '${count}xul berê';
  }

  @override
  String hoursAgo(int count) {
    return '${count}sd berê';
  }

  @override
  String daysAgo(int count) {
    return '${count}roj berê';
  }

  @override
  String get rogueApSuspected => 'Gumana AP ya sexte';

  @override
  String get deauthActivity => 'Çalakiya deauth';

  @override
  String get captivePortal => 'Portala girtî';

  @override
  String get evilTwinDetected => 'Evil twin hat dîtin';

  @override
  String get encryptionDowngrade => 'Daxistina şîfrekirinê';

  @override
  String get unsupportedOp => 'Operasyona nayê piştgirîkirin';

  @override
  String get arpSpoofing => 'Xapandina ARP';

  @override
  String get dnsHijacking => 'Revandina DNS';

  @override
  String networksWithCount(int count) {
    return 'Tor ($count)';
  }

  @override
  String signalStability(String stability) {
    return 'Aramî $stability';
  }

  @override
  String get metricSignal => 'SÎNYAL';

  @override
  String get metricScoreTrend => 'TENDANSA XALÊ';

  @override
  String get metricChannels => 'KANAL';

  @override
  String get metricNewDevices => 'CÎHAZÊN NÛ';

  @override
  String get metricThreats => 'GEF';

  @override
  String get metricSpeed => 'LEZ';

  @override
  String get severityCrit => 'KIRÎT';

  @override
  String get severityHighShort => 'BILIND';

  @override
  String get severityMedShort => 'NAV';

  @override
  String get severityInfoShort => 'AGH';

  @override
  String get hardenRouterTitle => 'ROUTERÊ TUND BIKE';

  @override
  String get hardenRouterSubtitle => 'Lîsteya kontrolê ya ewlehiyê';

  @override
  String get packetLossLabel => 'WINDABÛNA PAKÊTAN';

  @override
  String get loadedLatencyLabel => 'GECIKÎNA BI BAR';

  @override
  String get clearHistoryTooltip => 'Hemû dîrokê pak bike';

  @override
  String get whatIsThisSection => 'Ev çi ye?';

  @override
  String get whyItMattersSection => 'Ev çima girîng e';

  @override
  String get covShort => 'KAP';

  @override
  String get sigShort => 'SNY';

  @override
  String get motShort => 'TEV';

  @override
  String get wifiShort => 'WIFI';

  @override
  String get camShort => 'KAM';

  @override
  String get discardSurveyTooltip => 'Anketê Jê Bibe';

  @override
  String get finishReviewTooltip => 'Biqedîne û Binirxîne';

  @override
  String get noDataAtLocation => 'LI VÎ CIHÎ DANE TUNE';

  @override
  String get rssiLabel => 'RSSI';

  @override
  String get statusLabel => 'REWŞ';

  @override
  String get floorLabel => 'QAT';

  @override
  String get positionLabel => 'CIH';

  @override
  String get samplesLabel => 'NIMÛNE';

  @override
  String get capturedLabel => 'HATIYE GIRTIN';

  @override
  String get heatmapPermissionsTitle => 'DESTÛRÊN NEXŞEYA GERMAHIYÊ';

  @override
  String get realignCompassTooltip => 'Pusulayê Ji Nû Ve Rêz Bike';

  @override
  String get exportCsvLabel => 'CSV Eksport Bike';

  @override
  String get setDeviceType => 'Cureya Cîhazê Saz Bike';

  @override
  String get resetToAiLabel => 'Vegere etîketa AI';

  @override
  String get gatewayCaps => 'DERGEH';

  @override
  String get identifiedCaps => 'NASKIRÎ';

  @override
  String get unknownMacRestricted => 'MAC NENAS (SÎNORDAR)';

  @override
  String get scanPortsCaps => 'PORTAN BITARE';

  @override
  String get noOpenPortsFound => 'Portek vekirî nehat dîtin';

  @override
  String get criticalCaps => 'KIRÎTÎK';

  @override
  String get wpsActiveCaps => 'WPS ÇALAK E';

  @override
  String get protectPdfTitle => 'PDFê BI ŞÎFREYEKÊ BIPARÊZE';

  @override
  String get pdfLockedHint =>
      'Bijarte. Dosyeya girtî: .torcav-pdf — ji Raporan dîsa veke.';

  @override
  String get pdfLockedLabel =>
      'Dosyeya girtî: .torcav-pdf — ji Raporan dîsa veke.';

  @override
  String get pdfPasswordHint => 'Şîfre (ji bo PDF ya sade vala bihêlin)';

  @override
  String get pdfPasswordWarning =>
      'Hişyar bin: ev veşartineke sivik e, ne şîfrekirina asta bankê ye. Dosyeyê li hember derketinên hêsan (thumbnailên cloud, cache ya emailê) diparêze lê êrîşkarek biryardar ku dosyeyê hebe hîna jî dikare şîfreyeke lawaz bi zorê biceribîne. Şîfreyeke dirêj û bêhempa bikar bînin.';

  @override
  String get understandEnable => 'FÊM KIRIM — ÇALAK BIKE';

  @override
  String get categorySignal => 'Sînyal';

  @override
  String get categoryChannel => 'Kanal';

  @override
  String get categoryBufferbloat => 'Bufferbloat';

  @override
  String get categoryIsp => 'Derbaziya ISPê';

  @override
  String get categoryDns => 'DNS';

  @override
  String get categoryHealthy => 'Tendurist';

  @override
  String get severityHigh => 'BILIND';

  @override
  String get severityMed => 'NAVÎN';

  @override
  String get severityLow => 'NIZIM';

  @override
  String get speedDoctorActionMoveCloser => 'Nêzî routerê biçin';

  @override
  String get speedDoctorActionAddMesh => 'Nodek mesh zêde bikin';

  @override
  String get speedDoctorActionSwitchTo5Ghz => 'Biçin 5 GHz';

  @override
  String get speedDoctorActionChangeChannel => 'Kanala Wi-Fi biguherînin';

  @override
  String get speedDoctorActionMoveTo5Ghz => 'Biçin bandê 5/6 GHz';

  @override
  String get speedDoctorActionEnableQos => 'QoS ya routerê çalak bikin';

  @override
  String get speedDoctorActionUpdateFirmware => 'Firmware ya routerê nû bikin';

  @override
  String get speedDoctorActionCallIsp => 'Bi ISPya xwe re têkilî daynin';

  @override
  String get speedDoctorActionRunWiredTest => 'Bi kablo ji nû ve test bikin';

  @override
  String get speedDoctorActionChangeDns => 'Dabînkerê DNS biguherînin';

  @override
  String get speedDoctorActionEnableDoh => 'DoH / DoT çalak bikin';

  @override
  String get waitingForHistory => 'Li bendê dîrokê ye';

  @override
  String get noScanData => 'Daneyên tarandinê tune';

  @override
  String get mbps => 'Mbps';

  @override
  String get primaryCauseWeakSignalTitle => 'SÎNYALA LAWAZ';

  @override
  String get primaryCauseWeakSignalDesc =>
      'Cîhaza we ji routerê dûr e an gelek dîwar li ber hene. Nêzî biçin an nodek mesh li vê deverê zêde bikin.';

  @override
  String get primaryCauseCrowdedChannelTitle => 'KANALA QELEBALIX';

  @override
  String get primaryCauseCrowdedChannelDesc =>
      'Çend xalên gihîştinê yên cîran kanala we parve dikin. Guherîna kanalekî kêmtir qelebalix — an biçin 5/6 GHz — dê bibe alîkar.';

  @override
  String get primaryCauseBufferbloatTitle => 'BUFFERBLOAT';

  @override
  String get primaryCauseBufferbloatDesc =>
      'Dema girêdan mijûl be gecikîn dijîşe. Ji bo birêvebirina pêketinên tîrafîkê QoS / SQM li ser routera xwe çalak bikin.';

  @override
  String get primaryCauseIspSlowTitle => 'SÎNORA DERBAZIYA ISPÊ';

  @override
  String get primaryCauseIspSlowDesc =>
      'Girêdana we ya Wi-Fi tendurist e lê leza dadanînê kêm e. Asteng bi îhtîmaleke mezin pîlana we ya înternetê an dabînkerê jorîn e.';

  @override
  String get primaryCauseSlowDnsTitle => 'DNS YA HÊDÎ';

  @override
  String get primaryCauseSlowDnsDesc =>
      'Nav pir dem digirin ku werin çareserkirin. Guherîna dabînkerê DNS an çalakkirina DoH/DoT bi gelemperî vê gecikînê radike.';

  @override
  String get primaryCauseHealthyTitle => 'TOR TENDURIST E';

  @override
  String get primaryCauseHealthyDesc =>
      'Ti astengek negihîşt asta hişyariyê. Girêdana we niha baş xuya dike.';

  @override
  String get diagStepReadingSignal => 'Sînyal tê xwendin';

  @override
  String get diagStepAnalysingChannels => 'Kanal têne analîzkirin';

  @override
  String get diagStepMeasuringSpeed => 'Lez tê pîvandin';

  @override
  String get diagStepBenchmarkingDns => 'DNS tê pîvandin';

  @override
  String get hideDetails => 'Hûrgiliyan veşêre';

  @override
  String get whatIsThisHowToFix => 'Ev çi ye? · Çawa tê sererastkirin';

  @override
  String get reviewing => 'NIRXANDIN';

  @override
  String get idle => 'BÊKAR';

  @override
  String get surveyComplete => 'ANKET QEDIYA';

  @override
  String get coverage => 'KAPSAM';

  @override
  String get blindSpots => 'DEVERÊN KOR';

  @override
  String get saveAndFinish => 'TOMAR BIKE Û BIQEDÎNE';

  @override
  String get diagStepFinalizing => 'Teşhîs tê qedandin';

  @override
  String get heatmapPageTitle => 'PLANA MALÊ + NEXŞEYA GERMAHIYÊ YA WIFI';

  @override
  String get heatmapPageSubtitle => 'Sînor, kapsam, û deverên lawaz';

  @override
  String get heatmapHistoryTooltip => 'Anketên tomarkirî veke';

  @override
  String get heatmapThemeToggleTooltip =>
      'Dîmenê biguherîne (Blueprint / Neon)';

  @override
  String get heatmapSamplesShort => 'nimûne';

  @override
  String get heatmapRestartSurvey => 'ANKETÊ JI NÛ VE DEST PÊ BIKE';

  @override
  String get heatmapRenameSurvey => 'ANKETÊ JI NÛ VE NAV LÊ BIKE';

  @override
  String get heatmapShareHeatmap => 'NEXŞEYA GERMAHIYÊ PARVE BIKE';

  @override
  String get heatmapRenameDialogTitle => 'ANKETÊ JI NÛ VE NAV LÊ BIKE';

  @override
  String get heatmapSave => 'Tomar bike';

  @override
  String get heatmapShareSubject => 'Lêgerîna Min a Torcav AR Wi-Fi';

  @override
  String get heatmapShareText =>
      'Min nexşeya Wi-Fi ya mala xwe bi Torcav çêkir! Li xalên mirî binêre. Bibîne çima înterneta te hêdî ye û Torcav daxîne: torcav.com';

  @override
  String get heatmapSamplesLabel => 'NIMÛNE';

  @override
  String get heatmapAvgSignalLabel => 'SÎNYALA NAVÎN';

  @override
  String get heatmapNotAvailable => 'Ne amade';

  @override
  String get heatmapNoSurveyYetTitle => 'Anketekê Dest Pê Bikin';

  @override
  String get heatmapNoSurveyYetBody =>
      'Pêşî gerekî dest pê bikin. Dîmena encamê dê paşê sînor û nexşeya germahiyê bi hev re nîşan bide.';

  @override
  String get heatmapWalkToBeginTitle => 'Meşê Dest Pê Bikin';

  @override
  String get heatmapWalkToBeginBody =>
      'Dema hûn çend gavan di her odeyê de bavêjin, rêça û xalên sînyalê xuya dibin.';

  @override
  String get heatmapStartSurvey => 'ANKETÊ DEST PÊ BIKE';

  @override
  String get heatmapNewSurveyDialogTitle => 'ANKETA NÛ';

  @override
  String heatmapDefaultSessionName(String time) {
    return 'Anket $time';
  }

  @override
  String get heatmapSessionNameField => 'Navê anketê';

  @override
  String get heatmapNewSurveyHint =>
      'Gava anket dest pê dike, dema hûn dilivin nimûneyên sînyalê bixweber têne zêdekirin. Heke sînorekî odeyê yê bihêztir dixwazin biçin AR.';

  @override
  String get heatmapSavedSurveysTitle => 'ANKETÊN TOMARKIRÎ';

  @override
  String get heatmapNoSavedSurveys => 'Hê anketek tomarkirî tune.';

  @override
  String heatmapSavedSurveySubtitle(int samples, int weak, String timestamp) {
    return '$samples nimûne · $weak devera lawaz · $timestamp';
  }

  @override
  String get heatmapDeleteSurveyTooltip => 'Anketê jê bibe';

  @override
  String channelShort(int channel) {
    return 'KN $channel';
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
  String get startNowCaps => 'DEST PÊ BIKE';

  @override
  String get howToFixSection => 'ÇAWA TÊ SERERASTKIRIN';

  @override
  String get endSurveyDialogTitle => 'Anket Biqedîne?';

  @override
  String get endSurveyDialogBody =>
      'Heke hûn wê jê bibin, daneyên anketa we ya niha wê winda bibin. Tomar bike an Jê Bibe?';

  @override
  String get endSurveyReviewBody => 'Nirxandina danişînê bête terikandin?';

  @override
  String get discardAction => 'JÊ BIBE';

  @override
  String get exitAction => 'DERKEVE';

  @override
  String get continueAction => 'BERDEWAM';

  @override
  String get discardSurveyDialogTitle => 'ANKET WERE JÊBIRIN?';

  @override
  String get discardSurveyDialogBody =>
      'Hemû daneyên tomarkirî yên vê danişînê wê ji bo her û her werin jêbirin.';

  @override
  String get autoSamplingDistance => 'Dûrahiya Nimûneya Xweber';

  @override
  String get appearanceLabel => 'Xuyang';

  @override
  String get clearHistoryAction => 'DÎROKÊ PAK BIKE';

  @override
  String get dataUsageWarningTitle => 'HIŞYARIYA BIKARANÎNA DANEYÊ';

  @override
  String get dataUsageWarningBody =>
      'Ev testa lezê ~300–500 MB dane dadixe. Heke hûn li ser girêdanek mobîl/pîvanî ne, ev dibe ku dravdan çêbike an kotaya daneya we bixwe.';

  @override
  String latencyExcellentTitle(String ms) {
    return 'Gecikîn: $ms ms — Berbiçav';
  }

  @override
  String latencyGoodTitle(String ms) {
    return 'Gecikîn: $ms ms — Baş';
  }

  @override
  String latencyAcceptableTitle(String ms) {
    return 'Gecikîn: $ms ms — Qebûlbar';
  }

  @override
  String latencyHighTitle(String ms) {
    return 'Gecikîn: $ms ms — Bilind';
  }

  @override
  String get latencyExcellentBody =>
      'Bersiveke bêhempa zû. Ji bo lîstikê, banga vîdyoyê, û sepanên zindî îdeal e.';

  @override
  String get latencyGoodBody =>
      'Ji bo banga vîdyoyê û stream baş e. Piraniya sepanan dê bertek bidin.';

  @override
  String get latencyAcceptableBody =>
      'Ji bo gerîn û stream baş e, lê banga vîdyoyê dibe ku hinek gecikîn hebe.';

  @override
  String get latencyHighBody =>
      'Gecikîneke berçav. Banga vîdyoyê û lîstik dibe ku hêdî xuya bikin. Nêzî routera xwe biçin.';

  @override
  String jitterStableTitle(String ms) {
    return 'Jitter: $ms ms — Aram';
  }

  @override
  String jitterGoodTitle(String ms) {
    return 'Jitter: $ms ms — Baş';
  }

  @override
  String jitterModerateTitle(String ms) {
    return 'Jitter: $ms ms — Navîn';
  }

  @override
  String jitterUnstableTitle(String ms) {
    return 'Jitter: $ms ms — Nearam';
  }

  @override
  String get jitterStableBody =>
      'Girêdaneke pir domdar. Pakêtên we bi guherîna demjimêrê ya herî kêm têne.';

  @override
  String get jitterGoodBody =>
      'Ji bo bang û stream têra xwe aram e. Guherîna piçûk li ser Wi-Fiyê normal e.';

  @override
  String get jitterModerateBody =>
      'Hinek nearamî hat dîtin. Bangên dengî dibe ku di dema pêketinan de perçe-perçe bên bihîstin.';

  @override
  String get jitterUnstableBody =>
      'Guherîna bilind — bangên deng û vîdyoyê bi îhtîmaleke mezin wê perçe bibin. Ev dibe ku ji tevliheviyê an kanalek qelebalix be.';

  @override
  String downloadFastTitle(String mbps) {
    return 'Dadanîn: $mbps Mbps — Zû';
  }

  @override
  String downloadGoodTitle(String mbps) {
    return 'Dadanîn: $mbps Mbps — Baş';
  }

  @override
  String downloadModerateTitle(String mbps) {
    return 'Dadanîn: $mbps Mbps — Navîn';
  }

  @override
  String downloadSlowTitle(String mbps) {
    return 'Dadanîn: $mbps Mbps — Hêdî';
  }

  @override
  String downloadFastBody(int streams) {
    return 'Bi hêsanî $streams+ streamên HD yên hevdemî digire. Ji bo malên mezin baş e.';
  }

  @override
  String downloadGoodBody(int streams) {
    return '$streams streamên HD yên hevdemî destek dike. Ji bo piraniya malan baş e.';
  }

  @override
  String get downloadModerateBody =>
      'Ji bo gerîn û yek-du streamên SD têrê dike. Dadanînên mezin wê hêdî bin.';

  @override
  String get downloadSlowBody =>
      'Pir sînordar. Nêzî routera xwe biçin an li tevliheviyê kontrol bikin.';

  @override
  String uploadFastTitle(String mbps) {
    return 'Hildakişîn: $mbps Mbps — Zû';
  }

  @override
  String uploadGoodTitle(String mbps) {
    return 'Hildakişîn: $mbps Mbps — Baş';
  }

  @override
  String uploadLimitedTitle(String mbps) {
    return 'Hildakişîn: $mbps Mbps — Sînordar';
  }

  @override
  String uploadSlowTitle(String mbps) {
    return 'Hildakişîn: $mbps Mbps — Hêdî';
  }

  @override
  String get uploadFastBody =>
      'Ji bo konferansa vîdyoyê, paşnusxeya cloud, û stream a zindî pir baş e.';

  @override
  String get uploadGoodBody =>
      'Ji bo banga vîdyoyê û parvekirina dosyeyan baş e. Hildakişînên cloud dê maqûl bin.';

  @override
  String get uploadLimitedBody =>
      'Ji bo bangên vîdyoyê yên bingehîn têrê dike. Hildakişîna dosyeyên mezin dê demê bigire.';

  @override
  String get uploadSlowBody =>
      'Hildakişîna pir hêdî. Vîdyoya zindî û senkronîzasyona cloud dê zehmet bibin.';

  @override
  String get packetLossPerfectTitle => 'Windabûna Pakêtan: %0 — Bêkêmasî';

  @override
  String packetLossMinimalTitle(String pct) {
    return 'Windabûna Pakêtan: %$pct — Hindik';
  }

  @override
  String packetLossHighTitle(String pct) {
    return 'Windabûna Pakêtan: %$pct — Bilind';
  }

  @override
  String get packetLossPerfectBody =>
      'Girêdaneke bihêz. Di dema nirxandinê de ti pakêtên daneyê winda nebûn.';

  @override
  String get packetLossMinimalBody =>
      'Windabûneke pir piçûk. Bi îhtîmaleke mezin ji bo piraniya çalakiyan nayê hîskirin.';

  @override
  String get packetLossHighBody =>
      'Dane têne windakirin. Ev di bang û lîstikan de qutbûnê çêdike. Li tevliheviya Wi-Fiyê kontrol bikin.';

  @override
  String loadedLatencyExcellentTitle(String ms) {
    return 'Gecikîna Bi Bar: $ms ms — Berbiçav';
  }

  @override
  String loadedLatencyGoodTitle(String ms) {
    return 'Gecikîna Bi Bar: $ms ms — Baş';
  }

  @override
  String loadedLatencyFairTitle(String ms) {
    return 'Gecikîna Bi Bar: $ms ms — Navîn';
  }

  @override
  String loadedLatencyPoorTitle(String ms) {
    return 'Gecikîna Bi Bar: $ms ms — Xirab';
  }

  @override
  String get loadedLatencyExcellentBody =>
      'Tora we tewra dema dadanînê jî bertek dide. Kalîteya routerê ya berbiçav.';

  @override
  String get loadedLatencyGoodBody =>
      'Dema bersivê di bin barê de hinekî zêde dibe, lê hîna jî pir kêrhatî ye.';

  @override
  String get loadedLatencyFairBody =>
      'Dema yên din torê bikar tînin gecikîneke berçav heye. Lîstin dema dadanînê dibe ku zehmet be.';

  @override
  String get loadedLatencyPoorBody =>
      'Bufferbloat a bilind. Girêdan di dema dadanînên mezin de bêbersiv dibe. QoS li ser routera xwe çalak bikin.';

  @override
  String get bufferbloatGradeLabel => 'PILEYA BUFFERBLOAT';

  @override
  String get bufferbloatGradeA =>
      'Kontrola bufferbloat a berbiçav. Routera we tewra di bin barê giran de jî gecikînê kêm digire.';

  @override
  String get bufferbloatGradeB =>
      'Bufferbloat a baş. Zêdebûneke piçûk a gecikînê di bin barê de — piraniya bikarhêneran wê hîs nakin.';

  @override
  String get bufferbloatGradeC =>
      'Bufferbloat a navîn. Lîstin û banga vîdyoyê dibe ku gecikî dema yên din dadixin.';

  @override
  String get bufferbloatGradeD =>
      'Bufferbloat a xirab. Girêdan di bin barê de hêdî dibe. QoS li ser routera xwe çalak bikin.';

  @override
  String get bufferbloatGradeE =>
      'Bufferbloat a giran. Sepanên demjimêr-hesas dê di dema dadanînên hevdemî de bişkên.';

  @override
  String get bufferbloatGradeF =>
      'Bufferbloat a kirîtîk. Routera we kûrahiya rêzê kontrol nake. Firmware an hardware nû bikin.';

  @override
  String get speedTestDisclaimer =>
      'Encam lezê ber bi servera Cloudflare ya herî nêzîk nîşan didin û ji Wi-Fi, hardware ya cîhazê, û dûrahiya PoP bandor dibin. Ew pîvana rasterast a leza peymana ISPya we nînin.';

  @override
  String get clearAllHistoryAction => 'HEMÛ DÎROKÊ PAK BIKE';

  @override
  String get deleteAllHistoryConfirm =>
      'Hemû tomarên testa lezê werin jêbirin? Ev nayê vegerandin.';

  @override
  String get deleteAllAction => 'HEMÛYAN JÊ BIBE';

  @override
  String whyIsThisLabel(String level) {
    return 'EV ÇIMA $level E?';
  }

  @override
  String get noSpecificConcerns =>
      'Ji bo vê cîhazê guman nehatiye tomarkirin. Nîşan xala giştî nîşan dide.';

  @override
  String get whatToDoLabel => 'ÇI BÊTE KIRIN';

  @override
  String get trustLevelSafe => 'EWLE';

  @override
  String get trustLevelCaution => 'BALKÊŞÎ';

  @override
  String get trustLevelRisky => 'RÎSKDAR';

  @override
  String get wipeAllDialogTitle => 'HEMÛ DANEYAN JÊ BIBE';

  @override
  String get wipeAllDialogBody =>
      'Ev ê ji bo her û her hemû dîroka tarandina herêmî, tomarên testa lezê, bûyerên ewlehiyê, nirxandinên kanalê û wêneyên di bîrê de jê bibe. Ev çalakî nayê vegerandin.';

  @override
  String get wipeAllAction => 'HEMÛYAN JÊ BIBE';

  @override
  String get allDataWiped => 'Hemû daneyên herêmî hatin jêbirin.';

  @override
  String get systemDefault => 'Standarda Pergalê';

  @override
  String portScanTimeoutMs(int ms) {
    return '$ms ms';
  }

  @override
  String get legendAndNodes => 'ÇÎROK Û NOD';

  @override
  String get legendGateway => 'DERGEH';

  @override
  String get legendGatewayDesc => 'Xala têketina navendî ya torê';

  @override
  String get legendAccessPoint => 'XALA GIHÎŞTINÊ';

  @override
  String get legendAccessPointDesc => 'Belavkerê sînyala WiFi';

  @override
  String get legendMobile => 'MOBÎL';

  @override
  String get legendMobileDesc => 'Cîhazên destan ên şexsî';

  @override
  String get legendIot => 'IOT';

  @override
  String get legendIotDesc => 'Malê aqilmend û senzor';

  @override
  String get legendDevice => 'CÎHAZ';

  @override
  String get legendDeviceDesc => 'Komputer, TV, hwd.';

  @override
  String get surveyStageStandby => 'LI BENDÊ';

  @override
  String get surveyStageInitializing => 'TÊ DEST PÊKIRIN';

  @override
  String get surveyStageSweepRooms => 'ODEYAN BITARE';

  @override
  String get surveyStageWeakZone => 'DEVERA LAWAZ';

  @override
  String get surveyStageWrapUp => 'BIQEDÎNE';

  @override
  String get surveyStageReview => 'NIRXANDIN';

  @override
  String get connectionTypesHeader => 'CUREYÊN GIRÊDANÊ';

  @override
  String get connTypeSolidLineLabel => 'Xeta Rast (Şîn)';

  @override
  String get connTypeSolidLineDesc =>
      'Girêdana Ethernet ya bi têl a leza bilind';

  @override
  String get connTypeGradientLabel => 'Gradient a Ronîkirî (Cyan)';

  @override
  String get connTypeGradientDesc => 'Girêdana WiFi ya bêtêl';

  @override
  String get connTypePulsingLabel => 'Xala Daneyê ya Lêdanê';

  @override
  String get connTypePulsingDesc => 'Li ser girêdanê tîrafîka çalak hat dîtin';

  @override
  String get uploadLabel => 'HILDAKIŞÎN';

  @override
  String get downloadLabel => 'DADANÎN';

  @override
  String get speedTestSemanticsIdle =>
      'Nîşangira testa lezê. Ji bo destpêkirinê bitikîne.';

  @override
  String speedTestSemanticsRunning(String mbps) {
    return 'Testa lezê dimeşe — $mbps Mbps dadanîn. Ji bo rawestandinê bitikîne.';
  }

  @override
  String speedTestSemanticsComplete(String dl, String ul) {
    return 'Testa lezê qediya — $dl Mbps dadanîn, $ul Mbps hildakişîn.';
  }

  @override
  String get measurementLockedTitle => 'PÎVAN GIRTÎ YE';

  @override
  String get measurementLockNoWifi =>
      'Ji bo girtina armanca anketê bi torek Wi-Fi ve girê bidin.';

  @override
  String measurementLockReconnect(String bssid) {
    return 'Ji bo berdewamkirina nimûnegirtinê dîsa bi $bssid ve girê bidin.';
  }

  @override
  String get waitingForSignalTitle => 'LI BENDÊ SÎNYALA NÛ YE';

  @override
  String get waitingForSignalBody =>
      'RSSI ji 3 saniyeyan kevintir e. Kurt bimeşin an cih negirin ji bo taranekek nû.';

  @override
  String get signalDroppedTitle => 'SÎNYAL DAKET';

  @override
  String get signalDroppedBody =>
      'Sînyala Wi-Fi ji -85dBm kêmtir e. Nêzî Xala Gihîştinê biçin.';

  @override
  String get compassDriftTitle => 'GUHERÎNA PUSULAYÊ HAT DÎTIN';

  @override
  String get measurementLockMagnetic =>
      'Tevliheviya magnetîkî hat dîtin. Bi şêwaza 8-ê bimeşin an li Ji Nû Ve Rêzkirinê bitikînin.';

  @override
  String get placeSurveyOriginTitle => 'DESTPÊKA ANKETÊ DANE';

  @override
  String get measurementLockAnchor =>
      'Berî tomarkirina xalan, li rûyekî hatî dîtin bitikînin da ku anketa AR were girêdan.';

  @override
  String get trackingLostTitle => 'ŞOPANDIN WINDA BÛ';

  @override
  String get measurementLockTracking =>
      'Şopandina tevgerê ne berdest e. Hêdî bimeşin heta ku şopandin vegere.';

  @override
  String get readyBannerTapFinish => 'Ji bo qedandina taranê bitikîne';

  @override
  String get ssidChipLock => 'GIRTIN';

  @override
  String get ssidChipHold => 'BIGIRE';

  @override
  String get guidanceStageIdle => 'Bêkar';

  @override
  String get guidanceStageInitializing => 'Tê Destpêkirin';

  @override
  String get guidanceStageMappingSignal => 'Sînyal Tê Nexşekirin';

  @override
  String get guidanceStageScanningWeakZones => 'Deverên Lawaz Têne Tarandin';

  @override
  String get guidanceStageReadyToFinish => 'Amade ji bo Qedandinê';

  @override
  String get guidanceStageReviewing => 'Tê Nirxandin';

  @override
  String get signalProbeHint =>
      'Nêzî xala sînyalê ya girtî bicerbin bitikînin.';

  @override
  String get wifiSecurityOpen => 'VEKIRÎ';

  @override
  String get newSessionPermissionsBody =>
      'Ji bo çêkirina nexşeyên germahiyê yên rast û nexşekirina kapsama torê, Torcavê gihîştina hin taybetmendiyên cîhazê hewce dike:';

  @override
  String get newSessionPermLocation =>
      'Cih (ji bo nexşekirina sînyalê li koordînatan)';

  @override
  String get newSessionPermActivity =>
      'Naskirina Çalakiyê (ji bo şopandina gav û tevgerê)';

  @override
  String get newSessionPermCamera =>
      'Kamera (bijarte, ji bo taybetmendiyên nexşekirina dîtbarî)';

  @override
  String get reportsMacMaskDesc =>
      'Berî eksportê 3 oktetên dawî (XX:XX:XX) vediçêre';

  @override
  String get reportsShareSubject => 'Rapora Tarandina Torcav';

  @override
  String exportNoDataYet(String label) {
    return 'Di \"$label\" de hê dane tune.';
  }

  @override
  String get exportSubject => 'Eksporta daneya herêmî ya Torcav';

  @override
  String exportFailedError(String error) {
    return 'Eksport biserneket: $error';
  }

  @override
  String get tapToStart => 'JI BO DESTPÊKIRINÊ BITIKÎNE';

  @override
  String get tapToStop => 'JI BO RAWESTANDINÊ BITIKÎNE';

  @override
  String get liveWifi => 'WI-FI ZINDÎ';

  @override
  String get signalProbeTitle => 'PROBA SÎNYALÊ';

  @override
  String get statusOptimal => 'BAŞTERÎN';

  @override
  String get statusFair => 'NAVÎN';

  @override
  String get statusCritical => 'KIRÎTÎK';

  @override
  String daysCount(int count) {
    return '${count}r';
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
  String get sdWeakSignalWhatIs =>
      'Hêza sînyalê (RSSI) dipîve ka cîhaza we çiqas bi dengekî bilind routerê dibihîze. Ji ~−70 dBm nizimtir, Wi-Fi neçar dimîne biçe modên hêdîtir û zêdetir dubarekirî da ku pêbawer bimîne.';

  @override
  String get sdWeakSignalWhyItMatters =>
      'Sînyaleke lawaz radyoyê neçar dike moda nirxa nizim. Tewra pîlana înternetê ya we zû be jî, girêdana Wi-Fi bi xwe dibe asta jorîn — dadanîn disekinin, banga vîdyoyê dikeve, û rûpel dem digirin.';

  @override
  String get sdWeakSignalHowToFix1 =>
      'Nêzî routerê an cihekî kêmtir astengkirî biçin.';

  @override
  String get sdWeakSignalHowToFix2 =>
      'Nodek mesh / dirêjkerê Wi-Fi li vê deverê zêde bikin.';

  @override
  String get sdWeakSignalHowToFix3 =>
      'Heke routera we li ser vî SSIDî 5 GHz an 6 GHz destek dike, dema hûn di rêza dîtinê de ne wê bandê bikar bînin.';

  @override
  String get sdWeakSignalHowToFix4 =>
      'Kontrol bikin ku router di nav dolabekî de, li piştî TVyekê, an li kêleka mîkroçalvê nehatiye veşartin.';

  @override
  String sdWeakSignalEstimate(String gain) {
    return 'Zêdebûna texmînî: heta +$gain Mbps dadanîn heke hûn karibin cîhazê nêzî routerê bikin.';
  }

  @override
  String get sdCrowdedChannelWhatIs =>
      'Kanalên Wi-Fi spektrûmek hevpar in. Dema çend xalên gihîştinê yên nêzîk li ser heman kanalê belav dikin, divê ew dorê bigirin — dema hewayê di navbera hemûyan de, ya we jî tê de, tê dabeşkirin.';

  @override
  String get sdCrowdedChannelWhyItMatters =>
      'Li ser kanalek qelebalix derbaziya we dadikeve tewra kesekî li malê torê bikar neyîne jî. Radyo tendurist e, lê divê li benda dora xwe bimîne da ku bipeyive.';

  @override
  String get sdCrowdedChannelHowToFix1 =>
      'Rûpela admin a routerê veke û kanala Wi-Fi bi destan biguherîne (Nirxandina Kanalê ya sepanê ya herî paqij pêşniyar dike).';

  @override
  String get sdCrowdedChannelHowToFix2 =>
      'Li ser 2.4 GHz, kanalên 1 / 6 / 11 tercîh bikin — ew li hev nakevin.';

  @override
  String get sdCrowdedChannelHowToFix3 =>
      'Heke routera we 5 GHz an 6 GHz destek dike, cîhazê bibin wê bandê: gelek kanalên paqij bêtir li wir hene.';

  @override
  String get sdCrowdedChannelHowToFix4 =>
      'Ji bo routerên du-bandî, ji her bandê re SSIDek cûda bidin da ku cîhaz dev ji vegerîna kanalek 2.4 GHz ya qelebalix berdin.';

  @override
  String sdCrowdedChannelEstimate(String gain) {
    return 'Zêdebûna texmînî: heta +$gain Mbps dadanîn piştî guherîna kanalekî hêminetir.';
  }

  @override
  String get sdBufferbloatWhatIs =>
      'Bufferbloat gecikîna ku dema girêdan bi tevahî bar be di bufferên şandinê yên routera we de kom dibe ye — pakêtên adetî divê li pişt bareke tîrafîka mezin li rêzê bisekinin.';

  @override
  String get sdBufferbloatWhyItMatters =>
      'Leza dadanîna we dibe ku dema dosyeyek diçe baş xuya bike, lê bangên dengî jitter dikin, konferansên vîdyoyê disekinin, û lîstik gecikî dibin — her tiştê demjimêr-hesas li pişt rêzê disekine.';

  @override
  String get sdBufferbloatHowToFix1 =>
      'QoS / SQM (carinan \"Smart Queue Management\" an \"Adaptive QoS\" jê re tê gotin) li rûpela admin a routera xwe çalak bikin.';

  @override
  String get sdBufferbloatHowToFix2 =>
      'Firmware ya routerê nû bikin — firmware ya nûjen bi xwerû disîplîneke rêzê ya çêtir peyda dike.';

  @override
  String get sdBufferbloatHowToFix3 =>
      'Heke router gelek sal kevn e û SQM tune, guherandina wê bi modelek nû bi gelemperî tenê çareya rastîn e.';

  @override
  String get sdBufferbloatHowToFix4 =>
      'Firehiya banda hildakişînê di routerê de hinekî ji pîlana we ya rastîn nizimtir bisînorînin (mînak %90) da ku rêz li ser routerê bimîne, ne li ISPê.';

  @override
  String sdBufferbloatEstimate(String reduction) {
    return 'Zêdebûna texmînî: nêzî −$reduction ms gecikîna bi bar. Bang û lîstik tewra di dema dadanînên mezin de jî dê bertek bidin.';
  }

  @override
  String get sdIspSlowWhatIs =>
      'Girêdana we ya Wi-Fi tendurist e û radyo dikare pir zêdetir ji ya ku bi rastî derbas dibe hilgire. Asteng li jorîn a routerê ye.';

  @override
  String get sdIspSlowWhyItMatters =>
      'Ti mîhengkirina router an Wi-Fiyê alîkariyê nake — girêdana ji ISPya we ber bi routerê ve asta jorîn e. Vê wek daneyeke ji bo nûvekirina pîlanê an banga destekê bihesibînin, ne wek pirsgirêkek Wi-Fi.';

  @override
  String get sdIspSlowHowToFix1 =>
      'Testê bi kabloya Ethernet ji nû ve bimeşînin da ku piştrast bikin radyo ne kêmasî ye.';

  @override
  String get sdIspSlowHowToFix2 =>
      'Pîlana ISPê ya ku hûn didin dravê kontrol bikin — encama testê divê di rojeke baş de bi ~%80 li hev bike.';

  @override
  String get sdIspSlowHowToFix3 =>
      'Di demjimêrên cûda yên rojê de biceribînin. Heke tenê êvaran hêdî be, dibe ku beşa ISPê qelebalix be.';

  @override
  String get sdIspSlowHowToFix4 =>
      'Heke encam bi domdarî ji pîlana we pir kêmtir be, bi encama testa lezê bi ISPê re têkilî daynin.';

  @override
  String sdIspSlowEstimate(String phy, String download) {
    return 'Wi-Fiya we dikare heta ~$phy Mbps hilgire; hûn niha $download Mbps distînin. Valahî li jorîn a routerê ye.';
  }

  @override
  String get sdSlowDnsWhatIs =>
      'DNS navên wek example.com dike navnîşanên IP yên ku cîhaza we bi rastî pê ve girê dide. Her barkirina rûpelê çend ji van lêgerînan dişîne berî ku dane biherike.';

  @override
  String get sdSlowDnsWhyItMatters =>
      'DNS ya hêdî leza dadanîna we nizim nake — ew di destpêka her girêdanê de gecikînekê zêde dike. Web tewra dema testên lezê baş xuya dikin jî \"hêdî\" tê hîskirin.';

  @override
  String get sdSlowDnsHowToFix1 =>
      'DNS ya cîhaz an routera xwe bibin resolvereke giştî ya zû — 1.1.1.1 (Cloudflare), 8.8.8.8 (Google), an 9.9.9.9 (Quad9).';

  @override
  String get sdSlowDnsHowToFix2 =>
      'DNS-over-HTTPS (DoH) an DNS-over-TLS (DoT) di OS an browsera xwe de çalak bikin da ku lêgerînan jî bişîfrînin.';

  @override
  String get sdSlowDnsHowToFix3 =>
      'Heke DNSya ISPya we hêdî ye, resolverê li ser routerê saz bikin da ku hemû mal sûd bibîne, ne tenê yek cîhaz.';

  @override
  String sdSlowDnsEstimate(int reduction) {
    return 'Zêdebûna texmînî: nêzî −$reduction ms ji bo her lêgerîna navekî. Barkirina rûpelan bi gelemperî %5–20 zûtir tê hîskirin ji ber ku her rûpel dehan lêgerînan dide destpêkirin.';
  }

  @override
  String get sdHealthyWhatIs =>
      'Speed Doctor pênc tiştan kontrol dike: hêza sînyalê, qelebalixiya kanalê, lez di bin barê de (bufferbloat), derbaziya dadanînê li hember kapasîteya Wi-Fi, û dema çareserkirina DNS.';

  @override
  String get sdHealthyWhyItMatters =>
      'Ti yek ji wan di vê meşê de negihîşt asta hişyariyê. Girêdana we niha di rewşeke baş de ye — heke hûn dest bi hîskirina pirsgirêkekê bikin testê ji nû ve bimeşînin da ku bibînin gelo tiştek guherî.';

  @override
  String sdMetricRssi(int rssi) {
    return 'RSSI: $rssi dBm';
  }

  @override
  String sdThresholdRssi(int healthy, int severe) {
    return 'Tendurist ≥ $healthy dBm · Giran ≤ $severe dBm';
  }

  @override
  String sdMetricChannel(int channel, String score) {
    return 'Kanal $channel · xal $score/10';
  }

  @override
  String sdThresholdChannel(String healthy, String severe) {
    return 'Tendurist ≥ $healthy · Giran ≤ $severe';
  }

  @override
  String sdMetricBufferbloat(String induced, String latency, String loaded) {
    return 'Δ gecikîna bi bar: $induced ms ($latency → $loaded)';
  }

  @override
  String sdThresholdBufferbloat(String healthy, String severe) {
    return 'Tendurist ≤ $healthy ms · Giran ≥ $severe ms';
  }

  @override
  String sdMetricIsp(String download, String phy) {
    return 'Dadanîn: $download Mbps · PHY: $phy Mbps';
  }

  @override
  String sdMetricIspNoPhy(String download) {
    return 'Dadanîn: $download Mbps';
  }

  @override
  String sdThresholdIsp(String healthy) {
    return 'Tendurist ≥ $healthy Mbps dema radyo ne qelebalix e';
  }

  @override
  String sdMetricDns(String name, int latency) {
    return 'Resolvera herî baş: $name · $latency ms';
  }

  @override
  String sdThresholdDns(int healthy, int severe) {
    return 'Tendurist ≤ $healthy ms · Giran ≥ $severe ms';
  }

  @override
  String get networkContextHomeLabel => 'Mal';

  @override
  String get networkContextPublicLabel => 'Giştî';

  @override
  String get networkContextGuestLabel => 'Mêvan';

  @override
  String get networkContextUnknownLabel => 'Nenas';

  @override
  String get noChangeLabel => 'guherîn tune';

  @override
  String get sinceLastScanLabel => 'ji taranê dawî ve';

  @override
  String get allClearLabel => 'hemû pak e';

  @override
  String get tapToTestLabel => 'ji bo testê bitikîne';

  @override
  String get gameProfileLabel => 'Profîla lîstikê';

  @override
  String get profileGeneric => 'Lîstika UDP ya Giştî';

  @override
  String get notificationChannelSecurityCritical => 'Hişyariyên Kirîtîk';

  @override
  String get notificationChannelSecurityHigh => 'Pêşeng a Bilind';

  @override
  String get notificationChannelSecurityMedium => 'Pêşeng a Navîn';

  @override
  String get notificationChannelSecurityWarning => 'Hişyarî';

  @override
  String get notificationChannelSecurityLow => 'Pêşeng a Nizim';

  @override
  String get notificationChannelSecurityInfo => 'Agahdarî';

  @override
  String get notificationChannelSecurityDescription =>
      'Agahdariyên hişyariya ewlehiyê';

  @override
  String wifiChannelQualityDroppedBody(
    int channel,
    String rating,
    int recommendedChannel,
    String recommendedRating,
  ) {
    return 'Kanal $channel niha $rating/10 e. Kanal $recommendedChannel li $recommendedRating/10 e — guherînê bihesibînin.';
  }

  @override
  String get stabilizerJitterSpikeTitle => 'Pêketina jitterê hat dîtin';

  @override
  String get stabilizerFasterDnsTitle => 'DNS ya zûtir berdest e';

  @override
  String get stabilizerPacketLossTitle => 'Windabûna pakêtan a domdar';

  @override
  String stabilizerJitterSpikeBody(String threshold, int window) {
    return 'Jitter ji $threshold ms ji bo $window nimûneyan derbas kir. Zivirandina tunelê dibe ku rêyeke xerab a sipartî bişkîne.';
  }

  @override
  String stabilizerFasterDnsBody(String label) {
    return 'DNSyeke zûtir ($label) berdest e.';
  }

  @override
  String stabilizerPacketLossBody(String loss) {
    return 'Windabûna pakêtan %$loss e. Nûkirina tunelê an derbasbûna toreke bihêztir dikare bibe alîkar.';
  }

  @override
  String get connCompareTitle => 'Berhevdana girêdanan';

  @override
  String get connCompareCellular => 'Mobîl';

  @override
  String get connCompareNoWifi => 'Wi-Fi ne girêdayî ye';

  @override
  String get connCompareNoCell => 'Agahiya sînyala mobîl tune';

  @override
  String get connCompareCellPermission =>
      'Ji bo xwendina sînyala mobîl destûra cihê pêwîst e';

  @override
  String get connCompareWifiStronger => 'Niha Wi-Fi bihêztir xuya dike';

  @override
  String get connCompareCellStronger => 'Niha daneya mobîl bihêztir xuya dike';

  @override
  String get connCompareBothWeak => 'Herdu girêdan qels xuya dikin';

  @override
  String get connCompareEven => 'Girêdan hevseng xuya dikin';

  @override
  String get connCompareInUse => 'ji bo daneyan tê bikaranîn';

  @override
  String stabilizerNativeJitterBody(String jitter, String threshold) {
    return 'Jitter $jitter ms e (sînor $threshold ms). Nûkirina tunelê dikare rêyeke xirab bişkîne.';
  }

  @override
  String get stabilizerDnsSwitchedTitle => 'DNS hate guhertin';

  @override
  String stabilizerDnsSwitchedBody(String dns, String delta) {
    return 'Niha $dns tê bikaranîn — $delta ms zûtir bersiv da.';
  }

  @override
  String get stabilizerAlertChannelName => 'Hişyariyên stabilizer';

  @override
  String get stabilizerAlertChannelDesc =>
      'Pêşniyarên jitter, windabûna pakêtan û DNS ji ping stabilizer.';

  @override
  String get stabilizerHudChannelDesc =>
      'Danezana domdar dema tunela ping stabilizer a li ser cîhazê çalak e.';

  @override
  String get stabilizerHudMeasuring => 'Tê pîvandin…';

  @override
  String stabilizerHudBody(String dns) {
    return 'DNS $dns · ji bo kontrolê bişkokan bikar bîne';
  }

  @override
  String get stabilizerActionCycle => 'Nû bike';

  @override
  String get stabilizerActionStop => 'Rawestîne';

  @override
  String get batteryOptimizationTitle => 'Destûra xebata paşxanê bide';

  @override
  String get batteryOptimizationBody =>
      'Ji bo ku hişyarî dema sepan girtî ye jî bixebitin, divê Torcav ji optimîzasyona bataryayê were derxistin. Wekî din Android dikare çavdêriyê li ser vê cîhazê bêdeng bike.';

  @override
  String get batteryOptimizationAction => 'Destûr bide';

  @override
  String get batteryOptimizationLater => 'Niha na';

  @override
  String get backgroundMonitoringNotifWarning =>
      'Danezan girtî ne — çavdêriya paşxanê dê bixebite lê hişyarî nayên xuyakirin. Ji mîhengên pergalê danezanan veke.';

  @override
  String get monitorChannelName => 'Hişyariyên çavdêriya torê';

  @override
  String get monitorChannelDesc =>
      'Hişyariyên kontrola Wi-Fi ya paşxanê ya periyodîk.';

  @override
  String get monitorBssidChangedTitle =>
      'Xala gihîştinê ya girêdayî hate guhertin';

  @override
  String get monitorBssidChangedBody =>
      'Cîhaza te derbasî xaleke gihîştinê ya cuda bû. Torcav veke da ku piştrast bikî ku hîn tora te ye.';

  @override
  String get monitorEnvironmentChangedTitle => 'Derdora Wi-Fi hate guhertin';

  @override
  String monitorEnvironmentChangedBody(String from, String to) {
    return 'Hejmara torên nêzîk ji $from bû $to. Ji bo vekolînê Torcav veke.';
  }

  @override
  String get lanDiscoveryTitle => 'Cîhazên LAN Hatin Dîtin';

  @override
  String get lanDiscoveryRecommendation =>
      'Piştrast bikin ku hûn hemû cîhazên li ser torê xwe ya herêmî nas dikin.';

  @override
  String get gatewayPortsExposedTitle => 'Portên Dergehê Eşkere ne';

  @override
  String get gatewayPortsExposedRecommendation =>
      'Xizmetên ne pêwîst li ser routera dergehê neçalak bikin û şîfreyên bihêz piştrast bikin.';

  @override
  String get openServiceDetectedTitle => 'Xizmeteke Vekirî Hat Dîtin';

  @override
  String get openServiceDetectedRecommendation =>
      'Piştrast bikin ku armanc ev e ku ev xizmet were gihîştin.';

  @override
  String lanDeviceDiscoveredTitle(String name) {
    return 'Cîhaza LAN: $name';
  }

  @override
  String get lanDeviceDiscoveredRecommendation =>
      'Piştrast bikin ev cîhaz ya we ye. Cîhazên xirab bi gelemperî di LANê de xwe vedişêrin.';

  @override
  String get rule_arp_spoofing_title => 'Xapandina ARP Hat Dîtin';

  @override
  String get rule_arp_spoofing_desc =>
      'Çend navnîşanên MAC heman navnîşana IP dixwazin. Dibe ku êrîşkarek tîrafîka we digire.';

  @override
  String get rule_arp_spoofing_rec =>
      'Biçin torek din an tavilê VPN bikar bînin.';

  @override
  String get rule_dns_hijacking_title => 'Revandina DNS Hat Dîtin';

  @override
  String get rule_dns_hijacking_desc =>
      'Pirsên DNS ya we ber bi serverek nediyar ve têne zivirandin. Ev dihêle êrîşkarek kontrol bike hûn kîjan malperan biçin.';

  @override
  String get rule_dns_hijacking_rec =>
      'Tavilê biçin ser VPNê. Pirsên DNS ya we têne destwerdan.';

  @override
  String channelWithRating(int channel, String rating) {
    return 'KN $channel ($rating)';
  }

  @override
  String lanDiscoveryEvidence(String devices) {
    return 'Hat Dîtin: $devices';
  }

  @override
  String gatewayPortsExposedEvidence(String ports) {
    return 'Portên Vekirî: $ports';
  }

  @override
  String openServiceDetectedEvidence(String ip, int port, String service) {
    return 'Armanc: $ip, Port: $port, Xizmet: $service';
  }

  @override
  String lanDeviceDiscoveredEvidence(String ip, String mac, String vendor) {
    return 'IP: $ip, MAC: $mac, Hilberîner: $vendor';
  }

  @override
  String evidenceNoEncryption(String network) {
    return 'Xala gihîştinê ji bo $network ti şîfrekirinê îlan nake.';
  }

  @override
  String lanDiscoveryDesc(int count) {
    return 'Tarandina çalak $count cîhaz li ser vê torê nas kir.';
  }

  @override
  String gatewayPortsExposedDesc(String ip) {
    return 'Host $ip portên vekirî hene ku dibe ku qels bin.';
  }

  @override
  String openServiceDetectedDesc(String ip, String service, int port) {
    return 'Host $ip li ser portê $port $service dixebitîne.';
  }

  @override
  String get genericErrorMessage => 'Çewtiyek çêbû.';

  @override
  String get networkErrorMessage =>
      'Çewtiya torê — ji kerema xwe girêdana xwe kontrol bike.';

  @override
  String get permissionDeniedMessage => 'Destûr hat redkirin.';

  @override
  String get storageErrorMessage => 'Çewtiya bîrê.';

  @override
  String get securityErrorMessage => 'Kontrola ewlehiyê bi ser neket.';

  @override
  String get recommendedActionsTitle => 'ÇALAKIYÊN TÊNE PÊŞNIYARKIRIN';

  @override
  String get ptsLabel => 'XAL';

  @override
  String get hardenRouterTaskTitle => 'Routerê Xurt Bike';

  @override
  String get hardenRouterTaskDesc =>
      'Routera xwe li hember xalên qels ên belavbûyî biparêze.';

  @override
  String get enableWpa3TaskTitle => 'WPA3 Çalak Bike';

  @override
  String get enableWpa3TaskDesc =>
      'Ji bo şîfrekirina xurttir derbasî WPA3 bibe.';

  @override
  String get disableWpsTaskTitle => 'WPS Bide Sekinandin';

  @override
  String get disableWpsTaskDesc =>
      'WPS rawestîne daku êrîşên şîfreya PIN werin astengkirin.';

  @override
  String get changeDefaultPasswordsTaskTitle => 'Şîfreyên Bingehîn Biguherîne';

  @override
  String get changeDefaultPasswordsTaskDesc =>
      'Agahiyên têketinê yên rêveberiyê biguherîne.';

  @override
  String get runSpeedTestTaskTitle => 'Testa Lezê Bike';

  @override
  String get runSpeedTestTaskDesc =>
      'Kontrol bike ka leza te wekî ya tê xwestin e yan na.';

  @override
  String get optimizeChannelTaskTitle => 'Qanala WiFi Baştir Bike';

  @override
  String get optimizeChannelTaskDesc =>
      'Derbasî qanaleke WiFi ya kêmtir qelebalix bibe.';

  @override
  String get lanViewListLabel => 'Lîste';

  @override
  String get lanViewMapLabel => 'Nexşe';

  @override
  String get speedHubTitle => 'LEZ';

  @override
  String get speedHubCompareSection =>
      'Tê dayîn vs tê stendin · Berawirdkirina Wi-Fi/mobîl';

  @override
  String get speedModeQuickTest => 'Testa Bilez';

  @override
  String get speedModeDiagnose => 'Teşhîs';

  @override
  String get opsGroupSecurity => 'EWLEHÎ';

  @override
  String get opsGroupSpeed => 'LEZ Û GIRÊDAN';

  @override
  String get opsGroupCoverage => 'BERFIREHÎ';

  @override
  String get opsGroupReports => 'RAPOR';

  @override
  String get opsSpeedSubtitle => 'Testa lezê û teşhîsa înterneta hêdî';

  @override
  String get opsSecuritySubtitle => 'Tehdîd, şîfrekirin û vekolîna kûr';

  @override
  String get opsHeatmapSubtitle =>
      'Berfirehiyê nexşe bike, deverên mirî bibîne';

  @override
  String get opsReportsSubtitle => 'Raporta tenduristiya torê derxe';

  @override
  String get breachMonitorTitle => 'Çavdêra Derketinê';

  @override
  String get breachMonitorSubtitle => 'Kontrol bike ka şîfreyek derketiye';

  @override
  String get breachInputLabel => 'Şîfreya ku tê kontrolkirin';

  @override
  String get breachCheckButton => 'Şîfreyê Kontrol Bike';

  @override
  String get breachCheckingButton => 'Tê kontrolkirin...';

  @override
  String get breachResultSafeTitle => 'Nehat dîtin';

  @override
  String get breachResultCompromisedTitle => 'Xeternak';

  @override
  String get breachResultSafe =>
      'Ev şîfre di tu derketina daneyên naskirî de nehat dîtin. Ev garantî nake ku ew bihêz e — şîfreyên dirêj û yekta hilbijêre.';

  @override
  String breachResultCompromised(int count) {
    final intl.NumberFormat countNumberFormat = intl
        .NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Ev şîfre di $countString tomarên derketinê yên naskirî de xuya dibe. Li her derê bikaranîna wê rawestîne û tavilê biguherîne.';
  }

  @override
  String get breachAdvice =>
      'Bi şîfreyek yekta biguherîne û li ser hesabên bandorbûyî pejirandina du-gavî çalak bike.';

  @override
  String get breachError =>
      'Kontrola derketinê biserneket. Girêdana xwe kontrol bike û dîsa biceribîne.';

  @override
  String get breachPrivacyNote =>
      'Tenê pêşgireke hash ya 5-tîpî tê şandin. Şîfreya te qet ji vê cîhazê dernakeve.';

  @override
  String get breachWhatTitle => 'Ev çi ye?';

  @override
  String get breachWhatBody =>
      'Bi salan re gelek malper hatin hakkirin, û milyaran şîfre hatin dizîn û li înternetê belav bûn. Êrîşkar van lîsteyên amade bikar tînin da ku hesaban dest bixin. Ev amûr ji te re dibêje ka şîfreyek ku tu bikar tînî di wan lîsteyên derketinê de heye yan na. Ger hebe, ew şîfre êdî ne ewle ye û divê were guhertin.';

  @override
  String get breachHowTitle => 'Çawa dixebite?';

  @override
  String get breachStep1 =>
      'Şîfreya ku tu dinivîsî li ser vê cîhazê dibe şopek vegernebar (hashek SHA-1).';

  @override
  String get breachStep2 =>
      'Tenê 5 tîpên pêşîn ên wê şopê ji servîsa \'Have I Been Pwned\' re têne şandin. Servîs bi hezaran şopên gengaz ên ku bi wan 5 tîpan dest pê dikin vedigerîne.';

  @override
  String get breachStep3 =>
      'Kîjan şop a şîfreya te ye bi tevahî li ser vê cîhazê tê berhevkirin. Servîs qet nikare fêr bibe ku te kîjan şîfre pirsî.';

  @override
  String get breachSafetyTitle => 'Çima nivîsandina şîfreya te ewle ye';

  @override
  String get breachSafety1 =>
      'Şîfre bi xwe qet ji cîhaza te dernakeve — tenê pêşgireke şopê ya 5-tîpî bi înternetê re tê şandin.';

  @override
  String get breachSafety2 =>
      'Ev pêşgira 5-tîpî bi hezaran şîfreyên cuda re hevpar e; ne nasnameya te ne jî şîfreya te eşkere dike (k-anonîmî).';

  @override
  String get breachSafety3 =>
      'Şîfre qet nayê tomarkirin an qeydkirin, û gava ku kontrol diqede tavilê ji ekranê tê jêbirin.';

  @override
  String get breachTransparencyLabel => 'Tişta tenê ku tê şandin';

  @override
  String get breachTransparencyEmpty =>
      'Şîfreyek binivîse; 5 tîpên ku dê werin şandin dê li vir zindî xuya bibin.';

  @override
  String get breachTransparencyHint =>
      'Ev 5 tîp tenê destpêka şopa şîfreya te ne — şîfre ji wan nayê ji nû ve avakirin.';

  @override
  String get dnsInfoDohTitle => 'DNS over HTTPS (DoH)';

  @override
  String get dnsInfoDohDesc =>
      'DoH lêgerînên DNSê yên ku diyar dikin tu kîjan malperan diçî şîfre dike û wan di nav trafîka tora HTTPS ya asayî de vedişêre. Bi vî awayî peydakerê înternetê yan êrîşkarek di torê de nikare lêgerînên te bibîne yan te biçe malperek sexte. Heke \'Gihîştî\' nivîsî be, ev tor destûrê dide DoH.';

  @override
  String get dnsInfoDotTitle => 'DNS over TLS (DoT)';

  @override
  String get dnsInfoDotDesc =>
      'DoT jî lêgerînên DNSê yên te şîfre dike, lê vê yekê li ser kanalek şîfrekirî ya cuda li portê 853 dike. Armanc heman e: parastina nepenîtiya lêgerînên DNSê. Hin tor portê 853 asteng dikin — wê demê tu \'Astengkirî\' dibînî û cîhaza te dibe ku vegere DNSa neşîfrekirî.';

  @override
  String get dashAdvancedMetrics => 'PÎVANÊN PÊŞKETÎ';

  @override
  String get dashHeroOtherIssues => 'Dîtinên din';

  @override
  String get dashSignalLabel => 'Sînyal';

  @override
  String get dashSsidHidden => 'Navê torê veşartî ye';

  @override
  String get dashGrantLocationHint =>
      'Ji bo dîtina navê torê destûra cihê bide';

  @override
  String get dashConnDetailTitle => 'KITEKITÊN GIRÊDANÊ';

  @override
  String get dashConnDetailCopyHint => 'Ji bo kopîkirinê li nirxekê bide';

  @override
  String dashValueCopied(String label) {
    return '$label hat kopîkirin';
  }

  @override
  String get dashHeroTopAction => 'Gava herî baş a niha';

  @override
  String get dashHeroSeeFullDiagnosis => 'Teşhîsa tevahî bibîne';

  @override
  String get dashHeroDisconnectedHint =>
      'Bi Wi-Fi ve girêbide, ez ê tora te analîz bikim û rewşê ji te re kurt bikim.';

  @override
  String get planSpeedTitle => 'Ya tu didî vs ya tu digirî';

  @override
  String get planSpeedEnterCta => 'Leza plansaziyê binivîse';

  @override
  String get planSpeedSheetHint =>
      'Leza daxistinê ya ku pakêta înternetê ya te soz dide (Mbps). Di peymana te an fatûreya te de nivîsandî ye.';

  @override
  String get planSpeedPlanLabel => 'Pîlan';

  @override
  String get planSpeedMeasuredLabel => 'Navîn';

  @override
  String get planSpeedNoData =>
      'Hîn pîvandin tune — li jêr testeke lezê bimeşîne.';

  @override
  String planSpeedSamples(int count) {
    return 'navîna $count testan';
  }

  @override
  String planSpeedPercentOfPlan(int percent) {
    return '%$percent ya plansaziya te';
  }

  @override
  String get planSpeedVerdictDelivering => 'Tu ya ku tu didî distînî.';

  @override
  String get planSpeedVerdictAcceptable =>
      'Hinekî di bin plansaziya te de — bişopîne.';

  @override
  String get planSpeedVerdictUnder => 'Gelekî di bin ya ku tu didî de.';

  @override
  String get planSpeedReportCta => 'Rapora ISS amade bike';

  @override
  String get ispEvidenceTitle => 'TORCAV — BELGEYA LEZA ÎNTERNETÊ';

  @override
  String get ispEvidenceGeneratedAt => 'Hatî çêkirin';

  @override
  String get ispEvidenceBest => 'Pîvandina herî baş';

  @override
  String get ispEvidenceSamples => 'Pîvandin';

  @override
  String get ispEvidenceDisclaimer =>
      'Nîşe: Bi sepana Torcav li ser Wi-Fi hatiye pîvandin. Encamên yekane li gorî dema rojê û şert û mercên malê diguherin; ya watedar navîna gelek testan e.';

  @override
  String get scheduledSpeedTestLabel => 'Pîvandinên lezê yên plansazkirî';

  @override
  String get scheduledSpeedTestDesc =>
      'Rojê nêzî du caran leza daxistinê dipîve, tenê li ser Wi-Fi û qet li ser daneyên mobîl na (her pîvandin 10 MB). Trenda ya-tu-didî-ya-tu-digirî bixweber ava dike.';
}
