// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

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
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count networks',
      one: '1 network',
      zero: 'no networks',
    );
    return '$_temp0';
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
  String get latestSnapshotTitle => 'Latest Network Snapshot';

  @override
  String get noSnapshotAvailable => 'No scan snapshot is available yet. Run a Wi-Fi scan first.';

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
  String get lanReconTitle => 'LAN RECON';

  @override
  String get targetSubnet => 'Target IP / Subnet';

  @override
  String get scanAllCaps => 'SCAN';

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
  String get trafficLabel => 'TRAFFIC';

  @override
  String get normalSpeed => 'NORMAL';

  @override
  String get fastSpeed => 'FAST';

  @override
  String get overdriveSpeed => 'OVERDRIVE';

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
  String get settingsTitle => 'Settings';

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
  String get knownNetworks => 'Known Networks';

  @override
  String get noIdentifiedNetworks => 'No identified networks in laboratory archives';

  @override
  String get securityTimeline => 'Security Timeline';

  @override
  String get noSecurityEvents => 'No security events recorded';

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
  String get latencyLabel => 'LATENCY';

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
  String get authLocalSystem => 'AUTH_LOCAL_SYSTEM';

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
  String get cancel => 'CANCEL';

  @override
  String get save => 'Save';

  @override
  String get waitingForData => 'Waiting for data...';

  @override
  String get temporalHeatmap => 'Temporal Heatmap';

  @override
  String signalMonitoringTitle(String ssid) {
    return 'SIGNAL MONITORING: $ssid';
  }

  @override
  String get heatmapTooltip => 'Heatmap';

  @override
  String get signalCaps => 'SIGNAL';

  @override
  String get channelCaps => 'CHANNEL';

  @override
  String get frequencyCaps => 'FREQ';

  @override
  String errorPrefix(String message) {
    return 'Error: $message';
  }

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
  String get phasePing => 'PHASE: PING';

  @override
  String get phaseDownload => 'PHASE: DOWNLOAD';

  @override
  String get phaseUpload => 'PHASE: UPLOAD';

  @override
  String get phaseDone => 'PHASE: DONE';

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
  String get heatmapTutorialTitle => 'HOW TO READ THE HEATMAP';

  @override
  String get heatmapTutorialStep1 => 'Start a new survey. The app collects signal samples automatically as you walk.';

  @override
  String get heatmapTutorialStep2 => 'Walk each room and pass through corridor and corner transitions. That builds the survey trail.';

  @override
  String get heatmapTutorialStep3 => 'If the outline is weak, switch to AR and face the walls. That pass is used to build the home plan.';

  @override
  String get heatmapTutorialStep4 => 'Finish and open the result. The screen will then show the plan, signal, and weak zones together.';

  @override
  String get gotIt => 'GOT IT';

  @override
  String get speedTestHistory => 'TEST HISTORY';

  @override
  String get noSpeedTestHistory => 'No tests recorded yet. Run your first test above.';

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
  String get legalDisclaimerBody => 'This application performs network observation and authorized LAN discovery. Active probing is strictly limited to service identification and security assessment. No brute-force authentication, frame injection, deauthentication packets, ARP poisoning, or credential harvesting are performed.\n\nUse of this application on networks you do not own or are not authorized to test may violate applicable laws (TCK 243/244, EU Directive 2013/40, CFAA). The user is solely responsible for ensuring lawful use.';

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
  String get renderingErrorBody => 'Something went wrong while drawing this screen. Please restart the app.';

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
