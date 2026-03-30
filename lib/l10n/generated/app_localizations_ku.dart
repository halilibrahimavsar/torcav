// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kurdish (`ku`).
class AppLocalizationsKu extends AppLocalizations {
  AppLocalizationsKu([String locale = 'ku']) : super(locale);

  @override
  String get activeOperationsBlockedMsg =>
      'Operasyonên aktîf hatine astengkirin heta ku polîtîka û lîsteya destûrdayînê werin pejirandin.';

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
  String get confirm => 'Confirm';

  @override
  String get legalDisclaimerAccepted => 'Daxuyaniya yasayî hate qebûlkirin';

  @override
  String get requiredForActiveOps => 'Ji bo operasyonên aktîf pêwîst e';

  @override
  String get strictAllowlist => 'Lîsteya destûrdayînê ya hişk';

  @override
  String get blockActiveOpsUnknown =>
      'Operasyonên aktîf ji bo hedefên nenas asteng bike';

  @override
  String get rateLimitActiveOps => 'Sînora lezê navbera operasyonên aktîf';

  @override
  String get selectFromScanned => 'Ji lîsteya taranayî hilbijêre';

  @override
  String get settingsLanguage => 'Ziman';

  @override
  String get settingsScanBehavior =>
      'Tevgera taranê ya xwerû, stratejiya backend û rewşa ewlekariyê kontrol bike.';

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
  String get settingsStrictSafetyDesc =>
      'Ji bo operasyonên aktîf destûr û lîsteya destûrdayînê pêwîst e';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navWifi => 'Wi-Fi';

  @override
  String get navLan => 'LAN';

  @override
  String get navDiscovery => 'Discovery';

  @override
  String get navOperations => 'Operations';

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
  String get securityCenterDesc =>
      'Puanlama rîskê, lîsteyên destûrdayînê û kontrolên polîtîkayê';

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
  String get monitoringSubtitle =>
      'Berfirehiya bandê, tespîta anomalî û herikîna nexşeya germê.';

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
  String get reportsSubtitle =>
      'Danişîna taranê ya dawî wek JSON, HTML an PDF derxe.';

  @override
  String get noSnapshotAvailable =>
      'Hîn wêneya taranê tune. Pêşî taranek Wi-Fi pêk bîne.';

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
  String get sectionStatus => 'STATUS';

  @override
  String get exportOptionsTitle => 'EXPORT OPTIONS';

  @override
  String get latestSnapshotTitle => 'LATEST SNAPSHOT';

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
  String get noVulnerabilities =>
      'Li gorî daneyên taranê yên niha ti qelisî nehatin dîtin.';

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
  String get networkStatusLabel => 'NETWORK STATUS';

  @override
  String get activeSessionLabel => 'ACTIVE SESSION';

  @override
  String get gatewayLabel => 'GATEWAY';

  @override
  String get ipLabel => 'IP ADDRESS';

  @override
  String get connectedStatusCaps => 'CONNECTED';

  @override
  String get disconnectedStatusCaps => 'DISCONNECTED';

  @override
  String get quickActionsTitle => 'QUICK ACTIONS';

  @override
  String get lastScanTitle => 'LAST SCAN';

  @override
  String get viewDetailsAction => 'VIEW DETAILS';

  @override
  String get scanning => 'SCANNING…';

  @override
  String get secure => 'SECURE';

  @override
  String get blockUnknownAP => 'Block Unknown APs';

  @override
  String get automaticBlockMsg =>
      'Automatically drops connections to rogue APs';

  @override
  String get activeProbingEnabled => 'Active Probing';

  @override
  String get activeProbingMsg =>
      'Periodically tests connected AP for anomalies';

  @override
  String get requireConsentForDeauth => 'Require Consent';

  @override
  String get manualAuthorizationMsg =>
      'Manually authorize deauth/active defense';

  @override
  String get defensePolicy => 'Defense Policy';

  @override
  String get shieldActive => 'Shield Active';

  @override
  String get activeProtection => 'Active Protection';

  @override
  String get riskScore => 'Risk Score';

  @override
  String get securityRadar => 'Security Radar';

  @override
  String get profileTitle => 'AGENT PROFILE';

  @override
  String agentId(Object id) {
    return 'AGENT_ID: $id';
  }

  @override
  String get sessionInformation => 'SESSION INFORMATION';

  @override
  String get subscriptionStatus => 'SUBSCRIPTION STATUS';

  @override
  String get activeSession => 'ACTIVE SESSION';

  @override
  String get logout => 'LOGOUT';

  @override
  String get logoutConfirmation => 'DISCONNECT SESSION';

  @override
  String get logoutConfirmMessage =>
      'Are you sure you want to terminate the current session? All active monitoring will be paused.';

  @override
  String get livePulse => 'LIVE PULSE';

  @override
  String get operationsLabel => 'OPERATIONS';

  @override
  String get topologyLabel => 'TOPOLOGY';

  @override
  String get accessEngine => 'ACCESS ENGINE';

  @override
  String get networkLogs => 'NETWORK LOGS';

  @override
  String get strictSafetyEnabled => 'STRICT SAFETY ENABLED';

  @override
  String get activeMonitoringProgress => 'Active monitoring in progress';

  @override
  String get topologyMapTitle => 'TOPOLOGY MAP';

  @override
  String get trafficLabel => 'TRAFFIC';

  @override
  String get forceLabel => 'FORCE';

  @override
  String get normalSpeed => 'NORMAL';

  @override
  String get fastSpeed => 'FAST';

  @override
  String get overdriveSpeed => 'OVERDRIVE';

  @override
  String get noTopologyData => 'No topology data';

  @override
  String get runScanFirst => 'Run a Wi-Fi and LAN scan first';

  @override
  String get thisDevice => 'This Device';

  @override
  String get gatewayDevice => 'Gateway';

  @override
  String get mobileDevice => 'Mobile';

  @override
  String get deviceLabel => 'Device';

  @override
  String get iotDevice => 'IoT';

  @override
  String get analyzingNode => 'ANALYZING NODE...';

  @override
  String failedLoadTopology(Object error) {
    return 'Failed to load topology: $error';
  }

  @override
  String get neuralCoreTitle => 'NEURAL_CORE_AI';

  @override
  String get simulatedLabel => 'SIMULATED';

  @override
  String get activeAnomalies => 'ACTIVE ANOMALIES';

  @override
  String get predictiveHealth => 'PREDICTIVE HEALTH';

  @override
  String get aiStrategyReport => 'AI STRATEGY REPORT';

  @override
  String get engineStability => 'ENGINE_STABILITY: OPTIMAL';

  @override
  String get aiStrategyText =>
      'Current network topology suggests a stable signature. No immediate horizontal movement detected in subnets. Recommend enabling Stealth Mode on public access points to mitigate passive node discovery.';

  @override
  String get packetSnifferTitle => 'PACKET_SNIFFER';

  @override
  String get simulatedLogStream => 'SIMULATED_LOG_STREAM';

  @override
  String get streamPaused => 'STREAM_PAUSED';

  @override
  String get filterNone => 'FILTER: NONE';

  @override
  String get totalPackets => 'TOTAL_PKTS';

  @override
  String get droppedLabel => 'DROPPED';

  @override
  String get bufferLabel => 'BUFFER';

  @override
  String get latencyLabel => 'LATENCY';

  @override
  String get activeMonitoring => 'ACTIVE MONITORING';

  @override
  String get deactivate => 'DEACTIVATE';

  @override
  String get initializeLink => 'INITIALIZE LINK';

  @override
  String get commandCenters => 'COMMAND CENTERS';

  @override
  String get defenseTitle => 'DEFENSE';

  @override
  String get activeShielding => 'Active Shielding';

  @override
  String get logisticsTitle => 'LOGISTICS';

  @override
  String get intelMetrics => 'Intel & Metrics';

  @override
  String get networkMesh => 'Network Mesh';

  @override
  String get tuningTitle => 'TUNING';

  @override
  String get systemConfig => 'System Config';

  @override
  String get technicalTools => 'TECHNICAL TOOLS';

  @override
  String get packetLogs => 'PACKET LOGS';

  @override
  String get aiInsights => 'AI INSIGHTS';

  @override
  String get interactiveSimulation => 'INTERACTIVE_SIMULATION';

  @override
  String get appearance => 'APPEARANCE';

  @override
  String get theme => 'Theme';

  @override
  String get darkTheme => 'Dark';

  @override
  String get lightTheme => 'Light';

  @override
  String get systemTheme => 'System';

  @override
  String get biometricData => 'BIOMETRIC DATA';

  @override
  String get neuralSync => 'Neural Sync';

  @override
  String get encryptionKey => 'Encryption Key';

  @override
  String get systemStatus => 'SYSTEM STATUS';
}
