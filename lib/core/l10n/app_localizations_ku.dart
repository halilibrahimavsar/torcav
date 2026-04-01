// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kurdish (`ku`).
class AppLocalizationsKu extends AppLocalizations {
  AppLocalizationsKu([String locale = 'ku']) : super(locale);

  @override
  String get activeOperationsBlockedMsg => 'Operasyonên aktîf hatine astengkirin heta ku polîtîka û lîsteya destûrdayînê werin pejirandin.';

  @override
  String get authorizedTargets => 'Hedefên Destûrdayî';

  @override
  String get add => 'Zêde bike';

  @override
  String get noTargetsAllowlisted => 'Hîn ti hedef nehatine destûrdayîn.';

  @override
  String get hiddenNetwork => 'Tora Veşartî';

  @override
  String get remove => 'Rake';

  @override
  String get securityTimeline => 'Dema Ewlekariyê';

  @override
  String get noSecurityEvents => 'Hîn bûyerên ewlekariyê tune.';

  @override
  String get authorizeTarget => 'Hedefê Destûr bide';

  @override
  String get ssid => 'SSID';

  @override
  String get bssid => 'BSSID';

  @override
  String get allowHandshakeCapture => 'Destûr bide girtina destan (handshake)';

  @override
  String get allowActiveDefense => 'Destûr bide testên aktîf/deauth';

  @override
  String get cancel => 'Betal bike';

  @override
  String get save => 'Tomar bike';

  @override
  String get confirm => 'Piştrast bike';

  @override
  String get legalDisclaimerAccepted => 'Daxuyaniya yasayî hate qebûlkirin';

  @override
  String get requiredForActiveOps => 'Ji bo operasyonên aktîf pêwîst e';

  @override
  String get strictAllowlist => 'Lîsteya destûrdayînê ya hişk';

  @override
  String get blockActiveOpsUnknown => 'Operasyonên aktîf ji bo hedefên nenas asteng bike';

  @override
  String get rateLimitActiveOps => 'Sînora lezê navbera operasyonên aktîf';

  @override
  String get selectFromScanned => 'Ji lîsteya taranayî hilbijêre';

  @override
  String get settingsLanguage => 'Ziman';

  @override
  String get settingsScanBehavior => 'Tevgera taranê ya xwerû, stratejiya backend û rewşa ewlekariyê kontrol bike.';

  @override
  String get settingsDefaultScanPasses => 'Derbasbûnên taranê yên xwerû';

  @override
  String get settingsMonitoringInterval => 'Navbera şopandinê (saniye)';

  @override
  String get settingsBackendPreference => 'Terciha backend ya xwerû';

  @override
  String get settingsIncludeHidden => 'SSID-yên veşartî têxe nav';

  @override
  String get settingsStrictSafety => 'Moda ewlekariya hişk';

  @override
  String get settingsStrictSafetyDesc => 'Ji bo operasyonên aktîf destûr û lîsteya destûrdayînê pêwîst e';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navWifi => 'Wi-Fi';

  @override
  String get navLan => 'LAN';

  @override
  String get navDiscovery => 'Vedîtin';

  @override
  String get navOperations => 'Operasyon';

  @override
  String get navMore => 'Zêdetir';

  @override
  String get moreTitle => 'ZÊDETIR';

  @override
  String get sectionTools => 'AMÛR';

  @override
  String get speedTestTitle => 'Testa Lezê & Şopandin';

  @override
  String get speedTestDesc => 'Şopandina berfirehiya bandê, derengî û anomalî';

  @override
  String get securityCenterTitle => 'Navenda Ewlekariyê';

  @override
  String get securityCenterDesc => 'Puanlama rîskê, lîsteyên destûrdayînê û kontrolên polîtîkayê';

  @override
  String get reportsTitle => 'Raport';

  @override
  String get reportsDesc => 'Taranan wek PDF, HTML an JSON derxe';

  @override
  String get sectionPreferences => 'TERCIH';

  @override
  String get settingsTitle => 'Mîheng';

  @override
  String get settingsDesc => 'Tevgera taranê, backend û moda ewlekariyê';

  @override
  String get monitoringTitle => 'Şopandin';

  @override
  String get monitoringSubtitle => 'Berfirehiya bandê, tespîta anomalî û herikîna nexşeya germê.';

  @override
  String get packetsPerSecondLabel => 'Packets Per Second';

  @override
  String get throughputLabel => 'Throughput';

  @override
  String get comingSoon => 'DÊ ZÛ BÊ';

  @override
  String get signalTrends => 'Trendên Sînyalê';

  @override
  String get topologyMesh => 'Topolojî & Mesh';

  @override
  String get anomalyAlerts => 'Hîşyariyên Anomalî';

  @override
  String get speedTestHeader => 'TESTA LEZÊ';

  @override
  String get testConnectionSpeed => 'Leza girêdana xwe test bike';

  @override
  String get testing => 'TEST DIKE…';

  @override
  String get testAgain => 'DISA TEST BIKE';

  @override
  String get startTest => 'TESTÊ DEST PÊ BIKE';

  @override
  String get phasePing => 'PING';

  @override
  String get phaseDownload => 'DAXISTIN';

  @override
  String get phaseUpload => 'BARKIRIN';

  @override
  String get phaseDone => 'TEMAM';

  @override
  String get wifiScanTitle => 'ANALÎZORÊ WI-FI';

  @override
  String get scanSettingsTooltip => 'Mîhengên taranê';

  @override
  String get channelRatingTooltip => 'Puanlama Kanalê';

  @override
  String get refreshScanTooltip => 'Taranê nû bike';

  @override
  String get readyToScan => 'Amade ye ji bo taranê';

  @override
  String get scanButton => 'Taran';

  @override
  String get scanSettingsTitle => 'Mîhengên Taranê';

  @override
  String passes(Object count) {
    return 'Derbasbûn: $count';
  }

  @override
  String get includeHiddenSsids => 'SSID-yên veşartî têxe nav';

  @override
  String get backendPreference => 'Terciha backend';

  @override
  String get apply => 'Pêk bîne';

  @override
  String get noSignalsDetected => 'Sînyal nehatin dîtin';

  @override
  String get lastSnapshot => 'Wêneyê Dawî';

  @override
  String get bandAnalysis => 'Analîza Bandê';

  @override
  String networksCount(Object count) {
    return 'Tor ($count)';
  }

  @override
  String get recommendation => 'Pêşniyar';

  @override
  String get lanReconTitle => 'LAN RECON';

  @override
  String scanFailed(Object message) {
    return 'TARAN TÊK ÇÛ: $message';
  }

  @override
  String get readyToScanAllCaps => 'AMADE YE JI BO TARANÊ';

  @override
  String get targetSubnet => 'Subnet/IP ya hedef';

  @override
  String get profile => 'Profil';

  @override
  String get method => 'Metod';

  @override
  String get scanAllCaps => 'TARAN';

  @override
  String get noHostsFound => 'DIWAR NEHATIN DÎTIN';

  @override
  String get unknownHost => 'Diwarê nenas';

  @override
  String os(Object os) {
    return 'OS: $os';
  }

  @override
  String services(Object services) {
    return 'Xizmet: $services';
  }

  @override
  String vuln(Object vuln) {
    return 'Vuln: $vuln';
  }

  @override
  String get reportsSubtitle => 'Danişîna taranê ya dawî wek JSON, HTML an PDF derxe.';

  @override
  String get noSnapshotAvailable => 'Hîn wêneya taranê tune. Pêşî taranek Wi-Fi pêk bîne.';

  @override
  String latestSnapshot(Object count, Object backend) {
    return 'Wêneyê dawî: $count tor bi rêya $backend';
  }

  @override
  String get exportJson => 'JSON derxe';

  @override
  String get exportHtml => 'HTML derxe';

  @override
  String get exportPdf => 'PDF derxe';

  @override
  String get printPdf => 'PDF çap bike';

  @override
  String get saveReportDialog => 'Raportê tomar bike';

  @override
  String get sectionStatus => 'REWŞ';

  @override
  String get exportOptionsTitle => 'VEBIJARKÊN DERXISTINÊ';

  @override
  String get latestSnapshotTitle => 'WÊNEYÊ HERÎ DAWÎ';

  @override
  String get backendLabel => 'Backend';

  @override
  String get savePdfReportDialog => 'Raporta PDF tomar bike';

  @override
  String savedToast(Object path) {
    return 'Tomar bû: $path';
  }

  @override
  String get handshakeCaptureCheck => 'Kontrola girtina destan';

  @override
  String get activeDefenseReadiness => 'Amadebûna parastina aktîf';

  @override
  String get signalGraph => 'Grafîka Sînyalan';

  @override
  String get riskFactors => 'FAKTORÊN RÎSKÊ';

  @override
  String get vulnerabilities => 'QELISÎ';

  @override
  String recommendationLabel(Object text) {
    return 'PÊŞNIYAR: $text';
  }

  @override
  String get noVulnerabilities => 'Li gorî daneyên taranê yên niha ti qelisî nehatin dîtin.';

  @override
  String get bssId => 'BSSID';

  @override
  String get channel => 'KANAL';

  @override
  String get security => 'EWLEKARÎ';

  @override
  String get signal => 'SÎNYAL';

  @override
  String get channelRatingTitle => 'PUANLAMA KANALÊ';

  @override
  String get band24Ghz => '2.4 GHz';

  @override
  String get band5Ghz => '5 GHz';

  @override
  String get no24GhzChannels => 'Kanalên 2.4 GHz nehatin dîtin.';

  @override
  String get no5GhzChannels => 'Kanalên 5 GHz nehatin dîtin.';

  @override
  String get band6Ghz => '6 GHz';

  @override
  String get no6GhzChannels => 'Kanalên 6 GHz nehatin dîtin.';

  @override
  String get recommendedChannel => 'KANALA PÊŞNIYARKIRÎ';

  @override
  String channelInfo(Object channel, Object frequency) {
    return 'Kan $channel — $frequency MHz';
  }

  @override
  String bandChannels(Object band) {
    return 'Kanalên $band';
  }

  @override
  String get errorLabel => 'Hata';

  @override
  String get loading => 'Bardibe…';

  @override
  String get analyzing => 'Analîz dike…';

  @override
  String get success => 'Serkeftî';

  @override
  String get ok => 'Tamam';

  @override
  String get scannedNetworksTitle => 'Torên Taranayî';

  @override
  String get noNetworksFound => 'Tor nehatin dîtin.';

  @override
  String get retry => 'Disa ceribandin';

  @override
  String get knownNetworks => 'Torên Nas';

  @override
  String get noKnownNetworksYet => 'Hîn torên nas tune.';

  @override
  String opsLabel(Object ops) {
    return 'Op: $ops';
  }

  @override
  String get networkStatusLabel => 'REWŞA TORÊ';

  @override
  String get activeSessionLabel => 'DANIŞÎNA AKTÎF';

  @override
  String get gatewayLabel => 'GATEWAY';

  @override
  String get ipLabel => 'NAVNÎŞANA IP';

  @override
  String get connectedStatusCaps => 'GIRÊDAYÎ';

  @override
  String get disconnectedStatusCaps => 'QUTKIRÎ';

  @override
  String get quickActionsTitle => 'ÇALAKIYÊN BILEZ';

  @override
  String get lastScanTitle => 'TARA DAWÎ';

  @override
  String get viewDetailsAction => 'HÛRGULÎ BIBÎNE';

  @override
  String get scanning => 'TARAN DIKE…';

  @override
  String get secure => 'EWLE';

  @override
  String get blockUnknownAP => 'AP-yên Nenas Asteng Bike';

  @override
  String get automaticBlockMsg => 'Girêdanên bi AP-yên neqanûnî bixweber diqete';

  @override
  String get activeProbingEnabled => 'Testa Aktîf';

  @override
  String get activeProbingMsg => 'AP-ya girêdayî bi rêkûpêk ji bo anomalî tê ceribandin';

  @override
  String get requireConsentForDeauth => 'Destûr Pêwîst e';

  @override
  String get manualAuthorizationMsg => 'Deauth/parastina aktîf bi destan destûr bide';

  @override
  String get defensePolicy => 'Polîtîkaya Parastinê';

  @override
  String get shieldActive => 'Mertal Aktîf';

  @override
  String get activeProtection => 'Parastina Aktîf';

  @override
  String get riskScore => 'Puanê Rîskê';

  @override
  String get securityRadar => 'Radarê Ewlekariyê';

  @override
  String get profileTitle => 'PROFÎLA AJANÊ';

  @override
  String get logout => 'DERKEVE';

  @override
  String get logoutConfirmation => 'DANIŞÎNÊ QEBÛL BIKE';

  @override
  String get logoutConfirmMessage => 'Tu dixwazî danişîna niha biqedînî? Hemû şopandina aktîf dê raweste.';

  @override
  String get livePulse => 'NEBZA ZINDÎ';

  @override
  String get operationsLabel => 'OPERASYON';

  @override
  String get topologyLabel => 'TOPOLOJÎ';

  @override
  String get accessEngine => 'MOTORA GIHÎŞTINÊ';

  @override
  String get networkLogs => 'LOG-YÊTORÊ';

  @override
  String get strictSafetyEnabled => 'MODA EWLEKARIYA HIŞK ÇALAK E';

  @override
  String get activeMonitoringProgress => 'Şopandina aktîf berdewam dike';

  @override
  String get topologyMapTitle => 'NEXŞEYA TOPOLOJIYÊ';

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
  String get noTopologyData => 'Daneyên topolojiyê tune';

  @override
  String get runScanFirst => 'Pêşî taranek Wi-Fi û LAN pêk bîne';

  @override
  String get thisDevice => 'Ev Amûr';

  @override
  String get gatewayDevice => 'Gateway';

  @override
  String get mobileDevice => 'Mobîl';

  @override
  String get deviceLabel => 'Amûr';

  @override
  String get iotDevice => 'IoT';

  @override
  String get analyzingNode => 'GIRÊK ANALÎZ DIKE...';

  @override
  String failedLoadTopology(Object error) {
    return 'Topolojî nayê barkirin: $error';
  }

  @override
  String get neuralCoreTitle => 'NEURAL_CORE_AI';

  @override
  String get activeAnomalies => 'ANOMALIYÊN AKTÎF';

  @override
  String get predictiveHealth => 'TENDURISTIYA PÊŞBÎNÎ';

  @override
  String get aiStrategyReport => 'RAPORTA STRATEJIYA AI';

  @override
  String get engineStability => 'ARAMIYA_MOTORÊ: BAŞ';

  @override
  String get aiStrategyText => 'Topolojiya torê ya niha nîşaneya aram nîşan dide. Di subnet-an de tevgereke horizontî ya tavilê nehat dîtin. Tê pêşniyar kirin ku li xalên gihîştina giştî Moda Veşartî çalak bibe.';

  @override
  String get packetSnifferTitle => 'PAKET_SNIFFER';

  @override
  String get streamPaused => 'HERIKÎN_RAWESTIYAYE';

  @override
  String get filterNone => 'FÎLTER: TUNE';

  @override
  String get totalPackets => 'GIŞTÎ_PAKÊT';

  @override
  String get droppedLabel => 'AVÊTÎ';

  @override
  String get bufferLabel => 'TAMPON';

  @override
  String get latencyLabel => 'DERENGÎ';

  @override
  String get activeMonitoring => 'ŞOPANDINA AKTÎF';

  @override
  String get deactivate => 'NEÇALAK BIKE';

  @override
  String get initializeLink => 'GIRÊDANÊ DESTPÊBIKE';

  @override
  String get commandCenters => 'NAVENDÊN FERMANDEHIYÊ';

  @override
  String get defenseTitle => 'PARASTIN';

  @override
  String get activeShielding => 'Mertalkirina Aktîf';

  @override
  String get logisticsTitle => 'LOJÎSTÎK';

  @override
  String get intelMetrics => 'Intel û Metrîk';

  @override
  String get networkMesh => 'Tora Mesh';

  @override
  String get tuningTitle => 'MÎHENGKIRIN';

  @override
  String get systemConfig => 'Mîhengên Sîstemê';

  @override
  String get technicalTools => 'AMÛRÊN TEKNÎKÎ';

  @override
  String get packetLogs => 'LOG-YÊPAKÊTAN';

  @override
  String get aiInsights => 'TÊGIHÎŞTINÊN AI';

  @override
  String get interactiveSimulation => 'SÎMÛLASYONA_ÎNTERAKTÎF';

  @override
  String get appearance => 'XUYANGÊ';

  @override
  String get theme => 'Tema';

  @override
  String get darkTheme => 'Tarî';

  @override
  String get lightTheme => 'Ronî';

  @override
  String get systemTheme => 'Sîstem';

  @override
  String get systemStatus => 'REWŞA SÎSTEMÊ';
}
