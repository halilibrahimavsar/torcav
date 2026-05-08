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
  String get deepScanExperimentalTitle => 'Deep Scan (Experimental)';

  @override
  String get deepScanExperimentalSubtitle => 'Actively probe LAN for devices and ports. Increased battery usage.';

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
  String get liveLabel => 'LIVE';

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
  String get broadcastingProbeRequests => 'Analyzing local signal environment...';

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
  String get settingsBackgroundStyle => 'Background Style';

  @override
  String get backgroundNeomorphic => 'Neomorphic (High Performance)';

  @override
  String get backgroundClassic => 'Classic Grid';

  @override
  String get backgroundAuroraMesh => 'Aurora Mesh (Experimental)';

  @override
  String get backgroundHoloSphere => 'Holographic Sphere (3D)';

  @override
  String get backgroundNeuralPulse => 'Neural Pulse (Animated)';

  @override
  String get backgroundSelectionRestricted => 'Cyber grid styles are optimized for dark mode and only available when using the dark theme.';

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
  String get settingsAiClassification => 'AI Device Classification';

  @override
  String get settingsAiClassificationDesc => 'Enables local AI-powered device detection and identification.';

  @override
  String get aiBadgeLabel => 'AI';

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
  String get defenseTitle => 'SECURITY CENTER';

  @override
  String get shieldLabReady => 'Ready for Assessment';

  @override
  String get deepScanRunning => 'Scan in progress...';

  @override
  String get knownNetworks => 'Known Networks';

  @override
  String get noKnownNetworksYet => 'No known networks yet';

  @override
  String get noIdentifiedNetworks => 'No identified networks in laboratory archives';

  @override
  String get knownNetworksDashboard => 'KNOWN NETWORKS ARCHIVE';

  @override
  String get securityTimeline => 'Security Timeline';

  @override
  String get noSecurityEvents => 'No security events recorded';

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
  String get portScanCommonPorts => 'COMMON PORTS';

  @override
  String get portScanCustomRange => 'CUSTOM RANGE';

  @override
  String get portScanAllPorts => 'ALL PORTS';

  @override
  String get portScanFullScanWarning => 'Scanning all 65,535 ports will take considerable time.';

  @override
  String get portScanStartPort => 'START PORT';

  @override
  String get portScanEndPort => 'END PORT';

  @override
  String get portScanInvalidRange => 'Invalid port range';

  @override
  String get portScanTooManyPorts => 'Scanning too many ports might be slow';

  @override
  String get portScanSearching => 'Searching for open ports. This may take a moment...';

  @override
  String portScanProbing(int port) {
    return 'Probing port $port...';
  }

  @override
  String portScanFoundCount(int count) {
    return 'Found $count open services so far.';
  }

  @override
  String get portScanNoPortsProbed => 'No ports probed yet. Run a port scan to discover open services.';

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
        'deauthBurstDetected': 'Deauth Burst Detected',
        'handshakeCaptureStarted': 'Handshake Protocol Analysis',
        'handshakeCaptureCompleted': 'Handshake Protocol Secured',
        'captivePortalDetected': 'Captive Portal Detected',
        'evilTwinDetected': 'Evil Twin Detected',
        'deauthAttackSuspected': 'Deauth Attack Suspected',
        'encryptionDowngraded': 'Encryption Downgraded',
        'arpSpoofingDetected': 'ARP Spoofing Detected',
        'dnsHijackingDetected': 'DNS Hijacking Detected',
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
  String get evilTwinAlertTitle => 'CRITICAL: EVIL TWIN DETECTED';

  @override
  String get evilTwinAlertBody => 'A suspicious access point with a matching SSID but different security parameters has been identified.';

  @override
  String get wpsWarningTitle => 'WPS VULNERABILITY DETECTED';

  @override
  String get wpsWarningBody => 'One or more nearby networks have WPS active. This can be exploited to gain unauthorized access.';

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
  String get spectrumOptimizationOpsSubtitle => 'Channel rating · interference';

  @override
  String get aboutSpectrumTitle => 'What is Spectrum Optimization?';

  @override
  String get aboutSpectrumWhatHeader => 'What is it?';

  @override
  String get aboutSpectrumWhatBody => 'Wi-Fi devices communicate over slices of the radio spectrum called channels. The 2.4 GHz band has only 3 truly non-overlapping channels (1, 6, 11) and is the most crowded. The 5 GHz band has many more channels and less interference. The newest 6 GHz band (Wi-Fi 6E/7) is almost empty in most homes.';

  @override
  String get aboutSpectrumWhyHeader => 'What is it for?';

  @override
  String get aboutSpectrumWhyBody => 'When many networks share the same channel, they take turns talking, which slows everything down (Co-channel Interference). On 2.4 GHz, even nearby channels overlap and create static (Adjacent Channel Interference). Picking a quiet channel directly improves speed, latency and connection stability.';

  @override
  String get aboutSpectrumHowHeader => 'How does it work?';

  @override
  String get aboutSpectrumHowBody => 'This screen scans every Wi-Fi network within range, then scores each channel from 0 to 10 based on the number of competing networks, their signal strength and any overlap with neighbors. Pick a channel marked green (≥8): it is the least crowded right now. The History tab shows whether that channel stays clear over time.';

  @override
  String get bandSpectrumTitle => 'Channel Spectrum';

  @override
  String get bandSpectrumInfoTitle => 'Channel Spectrum';

  @override
  String get bandSpectrumInfoBody => 'Each bar is one channel. Taller and greener bars are quieter; shorter red bars are crowded. Tap a bar to see the score (0-10). The score drops by 2 for every Wi-Fi network sharing the channel (Co-channel Interference) and by smaller amounts for networks on neighboring 2.4 GHz channels (Adjacent Channel Interference). Strong nearby networks penalise more than weak distant ones.';

  @override
  String get recommendationInfoTitle => 'How is the Recommendation Made?';

  @override
  String get recommendationInfoBody => 'We start every channel at 10 points, then subtract for each interfering network. Co-channel networks take 2 points each (×signal strength). Adjacent 2.4 GHz networks take 0.2-1.5 points based on distance. DFS channels lose 0.5 points (radar-shared). The channel with the highest remaining score wins. If two channels tie, the lower-numbered one is preferred.';

  @override
  String get consistentChannelInfoTitle => 'Consistent Best Channel';

  @override
  String get consistentChannelInfoBody => 'A snapshot can be misleading: a quiet channel right now may get crowded later. We average all your past scans on each channel and surface the one that consistently scores highest. If this differs from the current snapshot, the historically stable channel is often the safer long-term choice.';

  @override
  String get dfsBadgeLabel => 'DFS';

  @override
  String get dfsBadgeTooltip => 'DFS — shared with weather/military radar; your router may briefly switch off this channel';

  @override
  String get dfsInfoTitle => 'What is DFS?';

  @override
  String get dfsInfoBody => 'DFS (Dynamic Frequency Selection) channels in the 5 GHz band (52-64 and 100-144) are legally shared with weather and military radar. Wi-Fi must give priority to those radars: if the router detects a radar pulse, it has to leave the channel for at least 60 seconds — your devices will briefly disconnect and switch to another channel. DFS channels are usually less crowded (so the score is high), but they can be unreliable near airports, harbors or weather stations. We deduct 0.5 points from the score to reflect that risk. Use them if you have no nearby radar source; avoid them otherwise.';

  @override
  String get howToChangeChannelTitle => 'How do I change my Wi-Fi channel?';

  @override
  String get howToChangeChannelSubtitle => 'Step-by-step guide for your router';

  @override
  String get guideConnectedTo => 'Connected to';

  @override
  String get guideRouterVendor => 'Router brand';

  @override
  String get guideRouterUnknown => 'Unknown — generic guide shown';

  @override
  String get guideStep1 => 'Step 1 · Open the admin panel';

  @override
  String get guideStep1Body => 'Tap OPEN below — it launches your default browser at the router\'s admin page. (Or copy the address and paste it manually if you prefer.) You must be on this Wi-Fi for the address to work; mobile data alone won\'t reach it.';

  @override
  String get guideOpenInBrowser => 'Open';

  @override
  String get guideOpenFailedMessage => 'Couldn\'t open the browser automatically — copy the address and paste it manually.';

  @override
  String get guideCredentialsHeader => 'Username & password';

  @override
  String get guideCredentialsBody => 'When the admin page asks you to sign in:\n\n1. Look at the bottom or back of your router — there\'s usually a sticker with the default Wi-Fi password AND the admin login. The admin login is labeled \"Admin password\", \"Web password\", \"Modem password\" or \"Yönetim şifresi\". This is NOT the same as the Wi-Fi password.\n\n2. If your router has no sticker, try these factory defaults:\n   • admin / admin\n   • admin / password\n   • admin / 1234\n   • root / admin\n   • Username empty / password admin\n\n3. If your ISP installed the router (Türk Telekom, TurkNet, Vodafone, Superonline, etc.), the admin password is often the last 6-8 characters of the device serial number, also on the sticker. Many ISPs ship a unique password printed only on the sticker.\n\n4. If nothing works: someone has changed the password before. You can press and hold the RESET pin on the back of the router for 10-15 seconds to restore factory defaults — but this also wipes your Wi-Fi name and password, so you\'ll have to set them up again.\n\n5. Some modern routers replace the web admin with a phone app (e.g. TP-Link Tether, ASUS Router, Mi WiFi, Huawei AI Life). If the web page redirects you to install an app, install it and continue from there.';

  @override
  String get guideAddressLabel => 'Admin address';

  @override
  String get guideCopyAddress => 'Copy';

  @override
  String get guideAddressCopied => 'Address copied — open it in your browser';

  @override
  String get guideStep2 => 'Step 2 · Find the Wi-Fi / Wireless menu';

  @override
  String get guideStep2Body => 'After signing in, look for a menu called Wi-Fi, Wireless or Network Settings. Routers from different brands name it differently — the path below is for your router brand:';

  @override
  String get guideStep3 => 'Step 3 · Set the channel and apply';

  @override
  String get guideStep3Body => 'Find the Channel option (often labeled Channel, Kanal or Wireless Channel). Change Auto to the recommended channel from the previous screen. If your router shows a separate option for 2.4 GHz and 5 GHz, set each band to its own recommended channel. Click Save / Apply. The router will briefly restart its Wi-Fi.';

  @override
  String get guideMenuPathLabel => 'Menu path';

  @override
  String get guideGenericMenuPath => 'Wireless / Wi-Fi → Basic / Advanced Settings → Channel';

  @override
  String get channelWidthHeader => 'Channel width — 20 / 40 / 80 / 160 MHz';

  @override
  String get channelWidthBody => 'Channel width is like the number of lanes on a highway:\n• 20 MHz = 1 lane. Slow but resilient to traffic. Best for crowded 2.4 GHz.\n• 40 MHz = 2 lanes. Twice the throughput, but overlaps more neighbors.\n• 80 MHz = 4 lanes. Fast — only available on 5 GHz/6 GHz.\n• 160 MHz = 8 lanes. Maximum speed, but uses half the 5 GHz band; only worth it if no neighbors are around.\n\nRule of thumb: 20 MHz on 2.4 GHz; 80 MHz on 5 GHz; 160 MHz on 6 GHz if available.';

  @override
  String get guideRisksHeader => 'Is it safe to change the channel?';

  @override
  String get guideRisksBody => 'Yes — completely safe. Changing the channel has no security or performance side-effects beyond a 5-10 second pause while the router restarts the radio. Your network name (SSID), password, port-forwarding rules, parental controls and every other setting stay exactly the same. Connected devices reconnect automatically. If anything seems worse afterwards, you can return to Auto in the same menu and the router will pick a channel itself.';

  @override
  String get guideNoConnection => 'Not connected to a Wi-Fi network — connect first to see your router\'s admin address and a tailored guide.';

  @override
  String get currentChannelLabel => 'ON NOW';

  @override
  String currentChannelBannerYouAreOn(String channel) {
    return 'Currently on $channel';
  }

  @override
  String currentChannelBannerSwitchTo(String channel, String delta) {
    return 'Switch to $channel for +$delta points';
  }

  @override
  String get currentChannelBannerOptimal => 'You\'re already on the recommended channel';

  @override
  String get spectrumOverlapTitle => 'Network Overlap';

  @override
  String get spectrumOverlapInfoTitle => 'Network Overlap';

  @override
  String get spectrumOverlapInfoBody => 'Each colored shape is a Wi-Fi network. The position on the X-axis is its centre frequency, the width matches the channel width (20/40/80/160 MHz) and the height shows signal strength (top = strong, bottom = weak). Where shapes overlap, those networks share the same airtime and slow each other down. Look for a vertical slice with no shapes (or only weak ones at the bottom) — that\'s a quiet channel. Tap a shape to identify the network.';

  @override
  String get spectrumOverlapEmptyHint => 'No networks visible on this band';

  @override
  String get channelDrilldownHeader => 'Networks on this channel';

  @override
  String get channelDrilldownEmpty => 'No networks broadcasting here';

  @override
  String get hiddenSsidPlaceholder => '<hidden network>';

  @override
  String scanComparisonImproved(String delta) {
    return '$delta pts vs last scan (improved)';
  }

  @override
  String scanComparisonWorsened(String delta) {
    return '$delta pts vs last scan (worsened)';
  }

  @override
  String get scanComparisonStable => 'Stable since last scan';

  @override
  String get countryAllowlistHeader => 'Region';

  @override
  String get countryAllowlistInfoBody => 'Wi-Fi channels are regulated differently per country. Channels disallowed in your region are dimmed and can\'t be used by your router. Switch the region if you\'re abroad — but the recommendation will only show legal channels for the selected region.';

  @override
  String get channelIllegalBadge => 'NOT ALLOWED';

  @override
  String get channelIllegalTooltip => 'This channel is not legal for Wi-Fi use in the selected region.';

  @override
  String get regionUS => 'United States';

  @override
  String get regionEU => 'Europe / Türkiye';

  @override
  String get regionJP => 'Japan';

  @override
  String get regionWorld => 'World (most permissive)';

  @override
  String get hourlyHeatmapTitle => 'Best channel by hour of day';

  @override
  String get hourlyHeatmapInsufficient => 'Need more history. Open this screen at different times of day to build the pattern.';

  @override
  String get afcInfoTitle => '6 GHz Power Classes (AFC)';

  @override
  String get afcInfoBody => '6 GHz Wi-Fi is divided into three power classes:\n\n• LPI (Low Power Indoor) — Default for home routers. Up to 30 dBm EIRP, only legal indoors. No location coordination needed.\n\n• Standard Power (SP) — Outdoor + high-power indoor. Up to 36 dBm. Requires AFC (Automated Frequency Coordination): the router contacts an FCC/regulator database, supplies its GPS location, and is told which channels are free of incumbent users (satellite uplinks, fixed microwave links).\n\n• VLP (Very Low Power) — Mobile/portable use, up to 14 dBm. No coordination needed but very short range; mainly for AR/VR headsets and laptops.\n\nMost home networks see only LPI; if you spot a 6 GHz AP outdoors with strong signal, it likely runs SP and was AFC-coordinated.';

  @override
  String get advancedTopicsHeader => 'Advanced topics';

  @override
  String get advancedMeshTitle => 'Mesh & roaming';

  @override
  String get advancedMeshBody => 'In a mesh network (e.g. Google Nest, Eero, TP-Link Deco) you don\'t pick the channel manually — the controller picks one per node and re-balances when neighbours change. Some controllers expose a per-node channel override, but auto-mode is usually best because the system can detect interference between mesh nodes themselves. If you must override, set the front-haul (client-facing) radio of the main node to the recommended channel and let the back-haul (node-to-node) radio stay on auto.';

  @override
  String get advancedBandSteeringTitle => 'Band steering & one SSID vs two';

  @override
  String get advancedBandSteeringBody => 'Modern routers offer band-steering: one SSID for both 2.4 GHz and 5 GHz, with the router pushing capable devices to 5 GHz. Pros: simple, devices roam automatically. Cons: some IoT devices (smart plugs, cameras) can only see 2.4 GHz and may fail to connect when the router hides it during steering. Workaround: split the SSIDs (e.g. \"MyHome\" on 5 GHz, \"MyHome-IoT\" on 2.4 GHz) for IoT setup and merge later if you wish.';

  @override
  String get advancedWmmTitle => 'WMM / QoS';

  @override
  String get advancedWmmBody => 'WMM (Wi-Fi Multimedia) prioritises traffic into 4 categories: voice, video, best-effort, background. It\'s required for Wi-Fi 4+ certification and should always stay enabled. Disabling it caps your throughput at 802.11g speeds (~54 Mbps). The Channel choice doesn\'t affect WMM, but a clean channel improves all 4 categories simultaneously.';

  @override
  String get dfsCacWarning => '⚠ DFS channel: when your router moves here it must listen silently for 60 seconds before broadcasting (Channel Availability Check). Wi-Fi will be temporarily unavailable during that window.';

  @override
  String get densityTrendStable => 'Stable density';

  @override
  String densityTrendVolatile(String delta) {
    return 'Volatile area · density swings $delta APs in last hour';
  }

  @override
  String get routerGroupsHeader => 'Nearby routers (dual-band)';

  @override
  String get routerGroupsInfoBody => 'When the same router broadcasts the same SSID on more than one band (e.g. 2.4 GHz CH 6 and 5 GHz CH 36), we group them here so you can compare both radios side by side. Tap a band chip to jump to it.';

  @override
  String crossBandSiblingHint(String band, String channel, String rating) {
    return 'Same router on $band CH $channel · $rating/10';
  }

  @override
  String get connectedChannelGuideLabel => 'YOU';

  @override
  String get unstableChannelLabel => 'UNSTABLE';

  @override
  String get unstableChannelTooltip => 'This channel\'s quality has fluctuated by more than 1.5 points across the last sessions';

  @override
  String get historyHeatmapInfoTitle => 'What is the Heatmap?';

  @override
  String get historyHeatmapInfoBody => 'Each row is a channel and each column is a moment in time when you ran a scan. The cell colour is the channel score at that moment: red (poor) → yellow (ok) → green (excellent). Empty cells mean the channel was not visible in that scan. Look for solid green rows — those are channels that stay clean over time.';

  @override
  String get clearChannelHistoryTitle => 'CLEAR CHANNEL HISTORY';

  @override
  String get clearChannelHistoryConfirmBody => 'Delete all channel rating records? This cannot be undone.';

  @override
  String get deleteAllLabel => 'DELETE ALL';

  @override
  String get dualBandSiblingLabel => 'DUAL BAND';

  @override
  String dualBandSiblingBanner(String band, String channel) {
    return 'Your router\'s $band radio: $channel';
  }

  @override
  String get acknowledgedLabel => 'ACKNOWLEDGED';

  @override
  String get speedDoctorTitle => 'SPEED DOCTOR';

  @override
  String get speedDoctorTagline => 'Why is the internet slow?';

  @override
  String get speedDoctorOpsTile => 'SPEED DOCTOR';

  @override
  String get speedDoctorOpsSubtitle => 'Why is it slow?';

  @override
  String get evilTwinDetailTitle => 'EVIL TWIN DETAIL';

  @override
  String get pingStabilizerTitle => 'PING STABILIZER';

  @override
  String get pingStabilizerSubtitle => 'On-device latency tunnel';

  @override
  String get pingStabilizerToggleHint => 'Tap to stabilize';

  @override
  String get pingStabilizerDrawerLabel => 'Ping Stabilizer';
}
