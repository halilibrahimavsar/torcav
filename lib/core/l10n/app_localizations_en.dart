// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get wifiScanTitle => 'WIFI SCAN';

  @override
  String get searchingNetworksPlaceholder => 'SEARCHING NETWORKS...';

  @override
  String get filterNetworksPlaceholder => 'FILTER NETWORKS...';

  @override
  String get quickScan => 'Quick Scan';

  @override
  String get deepScan => 'Deep Scan';

  @override
  String get scanModesTitle => 'Scan Modes';

  @override
  String get scanModesInfo => 'Quick scan listens for broadcasts. Deep scan actively probes for networks.';

  @override
  String get readyToScan => 'Ready to Scan';

  @override
  String get noSignalsDetected => 'No Signals Detected';

  @override
  String get compareWithPreviousScan => 'COMPARE WITH PREVIOUS SCAN';

  @override
  String networksCount(int count) {
    return '$count NETWORKS';
  }

  @override
  String filteredNetworksCount(int count, int total) {
    return '$count OF $total NETWORKS';
  }

  @override
  String get securityAlertsTooltip => 'View security alerts';

  @override
  String get livePulse => 'LIVE PULSE';

  @override
  String get operationsLabel => 'OPERATIONS';

  @override
  String get topologyLabel => 'TOPOLOGY';

  @override
  String get networkLogs => 'NETWORK LOGS';

  @override
  String get connectedStatusCaps => 'CONNECTED';

  @override
  String get disconnectedStatusCaps => 'DISCONNECTED';

  @override
  String get ipLabel => 'IP';

  @override
  String get gatewayLabel => 'GATEWAY';

  @override
  String get accessEngine => 'ACCESS ENGINE';

  @override
  String get latestSnapshotTitle => 'Latest Network Snapshot';

  @override
  String get noSnapshotAvailable => 'No snapshot data available...';

  @override
  String get strictSafetyEnabled => 'Strict safety protocols enabled';

  @override
  String get activeMonitoringProgress => 'Active monitoring in progress...';

  @override
  String get scanComparisonTitle => 'SCAN COMPARISON';

  @override
  String get comparisonNeedsTwoScans => 'Comparison requires at least 2 scans.\n\nRun another scan to see changes.';

  @override
  String get noChangesDetected => 'No changes detected between the last two scans.';

  @override
  String newNetworksCountLabel(int count) {
    return 'NEW ($count)';
  }

  @override
  String goneNetworksCountLabel(int count) {
    return 'GONE ($count)';
  }

  @override
  String changedNetworksCountLabel(int count) {
    return 'CHANGED ($count)';
  }

  @override
  String get plusNewLabel => '+ NEW';

  @override
  String get goneLabel => 'GONE';

  @override
  String get hiddenLabel => '[Hidden]';

  @override
  String channelLabel(int channel) {
    return 'CH $channel';
  }

  @override
  String get securityLabel => 'SECURITY';

  @override
  String get initiatingSpectrumScan => 'INITIATING SPECTRUM SCAN...';

  @override
  String get broadcastingProbeRequests => 'BROADCASTING PROBE REQUESTS...';

  @override
  String get noRadiosInRange => 'No radios in range';

  @override
  String get noNetworksMatchFilter => 'No networks match your filter';

  @override
  String get searchSsidBssidVendor => 'Search SSID, BSSID or Vendor...';

  @override
  String sortPrefix(String option) {
    return 'Sort: $option';
  }

  @override
  String get bandAll => 'ALL BANDS';

  @override
  String get sortSignal => 'Signal';

  @override
  String get sortName => 'Name';

  @override
  String get sortChannel => 'Channel';

  @override
  String get sortSecurity => 'Security';

  @override
  String get sortByTitle => 'SORT BY';

  @override
  String recommendationTip(String channels, String band) {
    return 'Optimum channels on $band: $channels';
  }

  @override
  String get channelInterferenceTitle => 'Channel Interference';

  @override
  String get networksLabel => 'NETWORKS';

  @override
  String openCount(int count) {
    return '$count OPEN';
  }

  @override
  String get avgSignalLabel => 'AVG SIGNAL';

  @override
  String get notAvailable => 'N/A';

  @override
  String get dbmCaps => 'DBM';

  @override
  String get interfaceLabel => 'INTERFACE';

  @override
  String frequencyLabel(int freq) {
    return '$freq MHz';
  }

  @override
  String get reportsTitle => 'REPORTS';

  @override
  String get saveReportDialog => 'Save Report';

  @override
  String savedToast(String path) {
    return 'Report saved to $path';
  }

  @override
  String get errorLabel => 'Error';

  @override
  String get savePdfReportDialog => 'Save PDF Report';

  @override
  String get scanning => 'Scanning...';

  @override
  String get shieldActive => 'Shield Active';

  @override
  String get threatsDetected => 'THREATS DETECTED';

  @override
  String get trustedLabel => 'TRUSTED';

  @override
  String get securityEventTitle => 'Security Event';

  @override
  String get networkReconTitle => 'NETWORK RECON';

  @override
  String get intelligenceReportTitle => 'INTELLIGENCE REPORT';

  @override
  String get discoveredEndpointsTitle => 'DISCOVERED ENDPOINTS';

  @override
  String newDeviceFound(String ip) {
    return '1 new device: $ip';
  }

  @override
  String newDevicesFound(int count) {
    return '$count new devices on your network';
  }

  @override
  String get targetIpSubnet => 'Target IP / Subnet';

  @override
  String get scanProfileFast => 'Fast';

  @override
  String get scanProfileBalanced => 'Balanced';

  @override
  String get scanProfileAggressive => 'Aggressive';

  @override
  String get scanProfileNormal => 'Normal';

  @override
  String get scanProfileIntense => 'Intense';

  @override
  String get vulnOnlyLabel => 'Vulnerabilities Only';

  @override
  String get lanReconTitle => 'LAN RECON';

  @override
  String get targetSubnet => 'Target IP / Subnet';

  @override
  String get scanAllCaps => 'SCAN';

  @override
  String get channelRatingTitle => 'CHANNEL RATING';

  @override
  String get refreshScanTooltip => 'Refresh Scan';

  @override
  String get band24Ghz => '2.4 GHz';

  @override
  String get band5Ghz => '5 GHz';

  @override
  String get band6Ghz => '6 GHz';

  @override
  String get no24GhzChannels => 'No 2.4 GHz channels found.';

  @override
  String get no5GhzChannels => 'No 5 GHz channels found.';

  @override
  String get no6GhzChannels => 'No 6 GHz channels found.';

  @override
  String get analyzing => 'Analyzing...';

  @override
  String get historyLabel => 'HISTORY';

  @override
  String failedLoadTopology(String error) {
    return 'Failed to load topology: $error';
  }

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
  String get topologyMapTitle => 'TOPOLOGY MAP';

  @override
  String get noTopologyData => 'No Topology Data';

  @override
  String get runScanFirst => 'Run a scan first to build the network map';

  @override
  String get retry => 'RETRY';

  @override
  String get thisDevice => 'THIS DEVICE';

  @override
  String get gatewayDevice => 'GATEWAY';

  @override
  String get mobileDevice => 'MOBILE';

  @override
  String get deviceLabel => 'DEVICE';

  @override
  String get iotDevice => 'IOT';

  @override
  String get analyzingNode => 'ANALYZING NODE';

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
  String get settingsTitle => 'SETTINGS';

  @override
  String get appearance => 'Appearance';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get settingsScanBehavior => 'Scan Behavior';

  @override
  String get settingsDefaultScanPasses => 'Default Scan Passes';

  @override
  String get settingsMonitoringInterval => 'Monitoring Interval';

  @override
  String get settingsBackendPreference => 'Backend Preference';

  @override
  String get settingsIncludeHidden => 'Include Hidden SSIDs';

  @override
  String get settingsStrictSafety => 'Strict Safety Mode';

  @override
  String get settingsStrictSafetyDesc => 'Restrict dangerous operations';

  @override
  String get darkTheme => 'Dark';

  @override
  String get lightTheme => 'Light';

  @override
  String get systemTheme => 'System';

  @override
  String get sectionStatus => 'Status';

  @override
  String get reportsSubtitle => 'Network Scan & Security Intelligence';

  @override
  String get exportOptionsTitle => 'EXPORT OPTIONS';

  @override
  String get exportJson => 'Export JSON';

  @override
  String get exportHtml => 'Export HTML';

  @override
  String get exportPdf => 'Export PDF';

  @override
  String get printPdf => 'Print PDF';

  @override
  String get navWifi => 'WIFI';

  @override
  String get backendLabel => 'BACKEND';

  @override
  String get defenseTitle => 'DEFENSE';

  @override
  String get knownNetworks => 'Known Networks';

  @override
  String get noKnownNetworksYet => 'No known networks yet';

  @override
  String get securityTimeline => 'Security Timeline';

  @override
  String get noSecurityEvents => 'No security events recorded';

  @override
  String get authLocalSystem => 'AUTH_LOCAL_SYSTEM';

  @override
  String remoteNodeIdLabel(String id) {
    return 'REMOTE_NODE_ID: $id';
  }

  @override
  String get ipAddrLabel => 'IP_ADDR';

  @override
  String get macValLabel => 'MAC_VAL';

  @override
  String get mnfrLabel => 'MNFR';

  @override
  String get hiddenNetwork => 'Hidden Network';

  @override
  String get signalGraph => 'Signal Graph';

  @override
  String get riskFactors => 'Risk Factors';

  @override
  String get vulnerabilities => 'Vulnerabilities';

  @override
  String get bssId => 'BSSID';

  @override
  String get channel => 'Channel';

  @override
  String get security => 'Security';

  @override
  String get signal => 'Signal';

  @override
  String recommendationLabel(String text) {
    return 'RECO: $text';
  }

  @override
  String get noVulnerabilities => 'No vulnerabilities detected.';

  @override
  String get securityScoreTitle => 'Security Score';

  @override
  String get securityScoreDesc => 'The security score (0–100) rates how well this network is protected. Higher is better. It considers encryption type, WPS status, and other security features.';

  @override
  String get capabilitiesLabel => 'CAPABILITIES';

  @override
  String get wifi7MldLabel => 'Wi-Fi 7 MLD';

  @override
  String get tagWpa3Desc => 'WPA3 is the latest Wi-Fi security standard — highly secure.';

  @override
  String get tagWpa2Desc => 'WPA2 is a strong security standard — safe for everyday use.';

  @override
  String get tagWpaDesc => 'WPA is an older security standard with known weaknesses.';

  @override
  String get tagWpsDesc => 'WPS (Wi-Fi Protected Setup) has known security vulnerabilities. It can allow attackers to brute-force the PIN and gain access.';

  @override
  String get tagPmfDesc => 'Protected Management Frames (PMF/MFP) protects against deauthentication attacks.';

  @override
  String get tagEssDesc => 'ESS (Extended Service Set) means this is a standard access point network.';

  @override
  String get tagCcmpDesc => 'CCMP (AES) is a strong encryption cipher used with WPA2/WPA3.';

  @override
  String get tagTkipDesc => 'TKIP is an older, weaker encryption cipher. CCMP/AES is preferred.';

  @override
  String get tagUnknownDesc => 'Network capability flag from the beacon frame.';

  @override
  String get scanProfileLabel => 'SCAN PROFILE';

  @override
  String get infoScanProfilesTitle => 'Scan Profiles';

  @override
  String get infoScanProfileFastDesc => 'Fast: Quick ping sweep — finds devices in seconds.';

  @override
  String get infoScanProfileBalancedDesc => 'Balanced: Ping + common ports — finds more detail.';

  @override
  String get infoScanProfileAggressiveDesc => 'Aggressive: Full port scan — most thorough but slowest.';

  @override
  String get activeNodeRecon => 'ACTIVE NODE RECONNAISSANCE';

  @override
  String get interrogatingSubnet => 'Interrogating subnet for responsive hosts...';

  @override
  String get nodesLabel => 'Nodes';

  @override
  String get riskAvgLabel => 'Risk Avg';

  @override
  String get servicesLabel => 'Services';

  @override
  String get openPortsLabel => 'OPEN PORTS';

  @override
  String get subnetLabel => 'Subnet';

  @override
  String get cidrTargetLabel => 'CIDR TARGET';

  @override
  String get anonymousNode => 'ANONYMOUS NODE';

  @override
  String portsCountLabel(int count) {
    return '$count PORTS';
  }

  @override
  String get riskLabel => 'RISK';

  @override
  String get searchLanPlaceholder => 'Search by IP, hostname, or vendor...';

  @override
  String get hasVulnerabilitiesLabel => 'Has Vulnerabilities';

  @override
  String get securityStatusSecure => 'Secure';

  @override
  String get securityStatusModerate => 'Moderate';

  @override
  String get securityStatusAtRisk => 'At Risk';

  @override
  String get securityStatusCritical => 'Critical';

  @override
  String get securitySummarySecure => 'Your connection looks good! This network uses strong encryption and is well protected against common attacks.';

  @override
  String get securitySummaryModerate => 'This network has decent security but some potential weaknesses. It is safe for everyday use, but avoid sensitive transactions.';

  @override
  String get securitySummaryAtRisk => 'This network has security issues that put your data at risk. Avoid entering passwords or personal information while connected.';

  @override
  String get securitySummaryCritical => 'Warning: This network is not secure. Anyone nearby may be able to see your internet traffic. Use a VPN or switch networks.';

  @override
  String get vulnerabilityOpenNetworkTitle => 'Open Network';

  @override
  String get vulnerabilityOpenNetworkDesc => 'No encryption detected. All traffic can be sniffed in plaintext.';

  @override
  String get vulnerabilityOpenNetworkRec => 'Avoid sensitive activity. Prefer trusted VPN or different network.';

  @override
  String get vulnerabilityWepTitle => 'WEP Encryption';

  @override
  String get vulnerabilityWepDesc => 'WEP is deprecated and can be cracked quickly.';

  @override
  String get vulnerabilityWepRec => 'Reconfigure AP to WPA2 or WPA3 immediately.';

  @override
  String get vulnerabilityLegacyWpaTitle => 'Legacy WPA';

  @override
  String get vulnerabilityLegacyWpaDesc => 'WPA/TKIP is older and weaker against modern attack techniques.';

  @override
  String get vulnerabilityLegacyWpaRec => 'Upgrade AP and clients to WPA2/WPA3.';

  @override
  String get vulnerabilityHiddenSsidTitle => 'Hidden SSID';

  @override
  String get vulnerabilityHiddenSsidDesc => 'Hidden SSIDs are still discoverable and may hurt compatibility.';

  @override
  String get vulnerabilityHiddenSsidRec => 'Hidden SSID alone is not protection. Focus on strong encryption.';

  @override
  String get vulnerabilityWeakSignalTitle => 'Very Weak Signal';

  @override
  String get vulnerabilityWeakSignalDesc => 'Weak signal can indicate unstable links and spoofing susceptibility.';

  @override
  String get vulnerabilityWeakSignalRec => 'Move closer to AP or validate BSSID consistency.';

  @override
  String get vulnerabilityWpsTitle => 'WPS Enabled';

  @override
  String get vulnerabilityWpsDesc => 'Wi-Fi Protected Setup (WPS) is enabled. The WPS PIN mode can be brute-forced in hours using Pixie Dust attack, effectively bypassing any password.';

  @override
  String get vulnerabilityWpsRec => 'Disable WPS in your router admin panel. Use WPA2/WPA3 passphrase only.';

  @override
  String get vulnerabilityPmfTitle => 'Management Frames Unprotected';

  @override
  String get vulnerabilityPmfDesc => 'This access point does not enforce Protected Management Frames (PMF / 802.11w). Unprotected management frames allow an attacker to forge deauthentication packets and disconnect clients.';

  @override
  String get vulnerabilityPmfRec => 'Enable PMF in router settings (often labelled \'802.11w\' or \'Management Frame Protection\'). WPA3 requires PMF by default.';

  @override
  String get vulnerabilityEvilTwinTitle => 'Potential Evil Twin';

  @override
  String get vulnerabilityEvilTwinDesc => 'SSID appears with conflicting security/channel fingerprint nearby.';

  @override
  String get vulnerabilityEvilTwinRec => 'Verify BSSID and certificate before authentication or data exchange.';

  @override
  String get riskFactorNoEncryption => 'No encryption in use';

  @override
  String get riskFactorDeprecatedEncryption => 'Deprecated encryption (WEP)';

  @override
  String get riskFactorLegacyWpa => 'Legacy WPA in use';

  @override
  String get riskFactorHiddenSsid => 'Hidden SSID behavior';

  @override
  String get riskFactorWeakSignal => 'Weak signal environment';

  @override
  String get riskFactorWpsEnabled => 'WPS PIN attack surface exposed';

  @override
  String get riskFactorPmfNotEnforced => 'PMF not enforced — deauth spoofing possible';

  @override
  String get refresh => 'Refresh';

  @override
  String get addZonePoint => 'Add Zone Point';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get waitingForData => 'Waiting for data...';

  @override
  String get temporalHeatmap => 'Temporal Heatmap';

  @override
  String get failedToSaveHeatmapPoint => 'Failed to save heatmap point';

  @override
  String signalMonitoringTitle(String ssid) {
    return 'SIGNAL MONITORING: $ssid';
  }

  @override
  String get heatmapTooltip => 'Heatmap';

  @override
  String get tagCurrentPointTooltip => 'Tag current point';

  @override
  String get signalCaps => 'SIGNAL';

  @override
  String get channelCaps => 'CHANNEL';

  @override
  String get frequencyCaps => 'FREQ';

  @override
  String heatmapPointAdded(String zone) {
    return 'Heatmap point added for $zone';
  }

  @override
  String get zoneTagLabel => 'Zone tag (e.g. Kitchen)';

  @override
  String errorPrefix(String message) {
    return 'Error: $message';
  }

  @override
  String noHeatmapPointsYet(String bssid) {
    return 'No heatmap points yet for $bssid';
  }

  @override
  String get averageSignalByZone => 'Average signal by zone';

  @override
  String bandChannels(String band) {
    return '$band CHANNELS';
  }

  @override
  String get recommendedChannel => 'RECOMMENDED CHANNEL';

  @override
  String channelInfo(int ch, int freq) {
    return 'Channel $ch · $freq MHz';
  }

  @override
  String get riskFactorFingerprintDrift => 'SSID fingerprint drift detected';

  @override
  String get historyCaps => 'HISTORY';

  @override
  String get consistentlyBestChannel => 'CONSISTENTLY BEST CHANNEL';

  @override
  String get avgScore => 'Avg Score';

  @override
  String get channelBondingTitle => 'Channel Bonding';

  @override
  String get channelBondingDesc => 'Channel bonding combines 2 or more adjacent channels to increase bandwidth (40 MHz = 2×, 80 MHz = 4×, 160 MHz = 8×). Wider channels deliver faster speeds but may interfere with more neighboring networks.';

  @override
  String get spectrumOptimizationCaps => 'SPECTRUM OPTIMIZATION';

  @override
  String get spectrumOptimizationDesc => 'Analyze channel congestion & interference';

  @override
  String get qualityExcellent => 'Excellent';

  @override
  String get qualityVeryGood => 'Very Good';

  @override
  String get qualityGood => 'Good';

  @override
  String get qualityFair => 'Fair';

  @override
  String get qualityCongested => 'Congested';

  @override
  String channelBondingHeader(int count) {
    return 'CHANNEL BONDING ($count APs)';
  }

  @override
  String get hiddenSsidLabel => '[Hidden]';

  @override
  String get noHistoryPlaceholder => 'No history yet.\nChannel ratings are recorded each time you open this screen.';

  @override
  String get currentSessionInfo => 'Current session — higher score = less congested.';

  @override
  String historySummaryInfo(int sessions, int samples) {
    return '$sessions sessions · $samples samples · higher = less congested';
  }

  @override
  String get scanReportTitle => 'Torcav Wi-Fi Scan Report';

  @override
  String get reportTime => 'Time';

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
  String get navDiscovery => 'DISCOVERY';

  @override
  String get navOperations => 'OPERATIONS';

  @override
  String get navLan => 'LAN';

  @override
  String get systemStatus => 'System Status';

  @override
  String get interfaceTheme => 'Interface Theme';

  @override
  String get speedTestHeader => 'SPEED TEST';

  @override
  String get startTest => 'START TEST';

  @override
  String get testAgain => 'TEST AGAIN';

  @override
  String get commandCenters => 'COMMAND CENTERS';

  @override
  String get activeShielding => 'Active Shielding';

  @override
  String get logisticsTitle => 'LOGISTICS';

  @override
  String get intelMetrics => 'Intel Metrics';

  @override
  String get networkMesh => 'Network Mesh';

  @override
  String get tuningTitle => 'TUNING';

  @override
  String get systemConfig => 'System Config';

  @override
  String get phasePing => 'PHASE: PING';

  @override
  String get phaseDownload => 'PHASE: DOWNLOAD';

  @override
  String get phaseUpload => 'PHASE: UPLOAD';

  @override
  String get phaseDone => 'PHASE: DONE';

  @override
  String get riskScore => 'Risk Score';

  @override
  String get loading => 'Loading...';

  @override
  String get profileTitle => 'PROFILE HUB';

  @override
  String get activeSessionLabel => 'Active Session';

  @override
  String get networkStatusLabel => 'NETWORK STATUS';

  @override
  String get ssid => 'SSID';

  @override
  String get lastScanTitle => 'LAST SCAN';

  @override
  String get lastSnapshot => 'Last Snapshot';

  @override
  String get channelInterferenceDescription => 'Wi-Fi channels are like radio stations. When many networks share the same channel they slow each other down — like everyone talking at the same time. Switching to a less crowded channel can improve your speed and reliability.';

  @override
  String securityEventType(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'rogueApSuspected': 'Rogue AP Suspected',
        'deauthBurstDetected': 'Deauth Burst',
        'handshakeCaptureStarted': 'Handshake Capture Started',
        'handshakeCaptureCompleted': 'Handshake Captured',
        'captivePortalDetected': 'Captive Portal Detected',
        'evilTwinDetected': 'Evil Twin Detected',
        'deauthAttackSuspected': 'Deauth Attack Suspected',
        'encryptionDowngraded': 'Encryption Downgraded',
        'unsupportedOperation': 'Unsupported Operation',
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
        'low': 'Low',
        'medium': 'Medium',
        'info': 'Info',
        'warning': 'Warning',
        'high': 'High',
        'critical': 'Critical',
        'other': '$severity',
      },
    );
    return '$_temp0';
  }

  @override
  String evilTwinEvidence(String expected, String found) {
    return 'BSSID mismatch! Expected: $expected, Found: $found. High probability of an Evil Twin Access Point.';
  }

  @override
  String get rogueApEvidence => 'Randomized/LAA MAC detected on known network! This is highly unusual for legitimate Access Points and may indicate a rogue device.';

  @override
  String downgradeEvidence(String oldSec, String newSec) {
    return 'Encryption profile changed from $oldSec to $newSec. Possible downgrade attack.';
  }

  @override
  String get historyAllBands => 'ALL';

  @override
  String get historyBestChannel => 'BEST CHANNEL';

  @override
  String get historyAvgRating => 'AVG RATING';

  @override
  String get historySessions => 'SESSIONS';

  @override
  String get historyLineChart => 'Line chart';

  @override
  String get historyHeatmap => 'Heatmap';

  @override
  String get historyNoDataForFilter => 'No data for selected filter.';

  @override
  String get historyChannelRatings => 'Channel Ratings';

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
  String get phaseIdle => 'READY';

  @override
  String get performanceTitle => 'SPEED TEST';

  @override
  String get performanceStart => 'START TEST';

  @override
  String get performanceRetry => 'RUN AGAIN';

  @override
  String get latencyLabel => 'LATENCY';

  @override
  String get jitterLabel => 'JITTER';

  @override
  String get whatThisMeans => 'WHAT THIS MEANS';

  @override
  String get channelRecommendation => 'CHANNEL RECOMMENDATION';

  @override
  String switchToChannel(int channel) {
    return 'Switch to Channel $channel';
  }

  @override
  String get channelCongestionHint => 'Your current channel is congested. Switching may improve speed.';

  @override
  String get evilTwinAlertTitle => 'EVIL TWIN DETECTED';

  @override
  String get evilTwinAlertBody => 'A network is impersonating a known access point. Do not connect to unrecognized networks.';

  @override
  String get wpsWarningTitle => 'WPS IS ENABLED';

  @override
  String get wpsWarningBody => 'WPS has known vulnerabilities that allow attackers to crack your Wi-Fi password even on WPA2. Disable it in your router settings.';

  @override
  String wpsAffectedNetworks(int count) {
    return '$count network(s) with WPS enabled';
  }

  @override
  String get heatmapTutorialTitle => 'HOW TO USE THE HEATMAP';

  @override
  String get heatmapTutorialStep1 => 'Tap START RECORDING to begin a new survey session.';

  @override
  String get heatmapTutorialStep2 => 'Walk to each area of your space. Tap the canvas at your current position to record the signal strength at that spot.';

  @override
  String get heatmapTutorialStep3 => 'Red = weak signal. Green = strong signal. Find dead zones and move your router to fix them.';

  @override
  String get heatmapTutorialStep4 => 'Tap STOP & SAVE when done. View past sessions with the history button.';

  @override
  String get gotIt => 'GOT IT';

  @override
  String get speedTestHistory => 'TEST HISTORY';

  @override
  String get noSpeedTestHistory => 'No tests recorded yet. Run your first test above.';

  @override
  String get networkScoreLabel => 'NETWORK SCORE';

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
}
