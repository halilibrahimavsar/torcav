// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get activeOperationsBlockedMsg => 'Active operations are blocked unless policy and allowlist conditions pass.';

  @override
  String get authorizedTargets => 'Authorized Targets';

  @override
  String get add => 'Add';

  @override
  String get noTargetsAllowlisted => 'No targets allowlisted yet.';

  @override
  String get hiddenNetwork => 'Hidden Network';

  @override
  String get remove => 'Remove';

  @override
  String get securityTimeline => 'Security Timeline';

  @override
  String get noSecurityEvents => 'No security events yet.';

  @override
  String get authorizeTarget => 'Authorize Target';

  @override
  String get ssid => 'SSID';

  @override
  String get bssid => 'BSSID';

  @override
  String get allowHandshakeCapture => 'Allow handshake capture';

  @override
  String get allowActiveDefense => 'Allow active defense/deauth tests';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get legalDisclaimerAccepted => 'Legal disclaimer accepted';

  @override
  String get requiredForActiveOps => 'Required for active operations';

  @override
  String get strictAllowlist => 'Strict allowlist';

  @override
  String get blockActiveOpsUnknown => 'Block active operations for unknown targets';

  @override
  String get rateLimitActiveOps => 'Rate limit between active ops';

  @override
  String get selectFromScanned => 'Select from scanned list';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsScanBehavior => 'Control default scan behavior, backend strategy, and safety posture.';

  @override
  String get settingsDefaultScanPasses => 'Default scan passes';

  @override
  String get settingsMonitoringInterval => 'Monitoring interval (seconds)';

  @override
  String get settingsBackendPreference => 'Default backend preference';

  @override
  String get settingsIncludeHidden => 'Include hidden SSIDs by default';

  @override
  String get settingsStrictSafety => 'Strict safety mode';

  @override
  String get settingsStrictSafetyDesc => 'Require consent + allowlist for active ops';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navWifi => 'Wi-Fi';

  @override
  String get navLan => 'LAN';

  @override
  String get navMore => 'More';

  @override
  String get moreTitle => 'MORE';

  @override
  String get sectionTools => 'TOOLS';

  @override
  String get speedTestTitle => 'Speed Test & Monitoring';

  @override
  String get speedTestDesc => 'Bandwidth, latency, and anomaly tracking';

  @override
  String get securityCenterTitle => 'Security Center';

  @override
  String get securityCenterDesc => 'Risk scoring, allowlists, and policy controls';

  @override
  String get reportsTitle => 'Reports';

  @override
  String get reportsDesc => 'Export scans as PDF, HTML, or JSON';

  @override
  String get sectionPreferences => 'PREFERENCES';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsDesc => 'Scan behavior, backends, and safety mode';

  @override
  String get monitoringTitle => 'Monitoring';

  @override
  String get monitoringSubtitle => 'Bandwidth, anomaly detection, and heatmap streams.';

  @override
  String get comingSoon => 'COMING SOON';

  @override
  String get signalTrends => 'Signal Trends';

  @override
  String get topologyMesh => 'Topology & Mesh';

  @override
  String get anomalyAlerts => 'Anomaly Alerts';

  @override
  String get speedTestHeader => 'SPEED TEST';

  @override
  String get testConnectionSpeed => 'Test your connection speed';

  @override
  String get testing => 'TESTING…';

  @override
  String get testAgain => 'TEST AGAIN';

  @override
  String get startTest => 'START TEST';

  @override
  String get phasePing => 'PING';

  @override
  String get phaseDownload => 'DOWNLOAD';

  @override
  String get phaseUpload => 'UPLOAD';

  @override
  String get phaseDone => 'DONE';

  @override
  String get wifiScanTitle => 'WI-FI ANALYZER';

  @override
  String get scanSettingsTooltip => 'Scan settings';

  @override
  String get channelRatingTooltip => 'Channel rating';

  @override
  String get refreshScanTooltip => 'Refresh scan';

  @override
  String get readyToScan => 'Ready to scan';

  @override
  String get scanButton => 'Scan';

  @override
  String get scanSettingsTitle => 'Scan Settings';

  @override
  String passes(Object count) {
    return 'Passes: $count';
  }

  @override
  String get includeHiddenSsids => 'Include hidden SSIDs';

  @override
  String get backendPreference => 'Backend preference';

  @override
  String get apply => 'Apply';

  @override
  String get noSignalsDetected => 'No signals detected';

  @override
  String get lastSnapshot => 'Last Snapshot';

  @override
  String get bandAnalysis => 'Band Analysis';

  @override
  String networksCount(Object count) {
    return 'Networks ($count)';
  }

  @override
  String get recommendation => 'Recommendation';

  @override
  String get lanReconTitle => 'LAN RECON';

  @override
  String scanFailed(Object message) {
    return 'SCAN FAILED: $message';
  }

  @override
  String get readyToScanAllCaps => 'READY TO SCAN';

  @override
  String get targetSubnet => 'Target subnet/IP';

  @override
  String get profile => 'Profile';

  @override
  String get method => 'Method';

  @override
  String get scanAllCaps => 'SCAN';

  @override
  String get noHostsFound => 'NO HOSTS FOUND';

  @override
  String get unknownHost => 'Unknown host';

  @override
  String os(Object os) {
    return 'OS: $os';
  }

  @override
  String services(Object services) {
    return 'Services: $services';
  }

  @override
  String vuln(Object vuln) {
    return 'Vuln: $vuln';
  }

  @override
  String get reportsSubtitle => 'Export the latest scan session as JSON, HTML, or PDF.';

  @override
  String get noSnapshotAvailable => 'No scan snapshot is available yet. Run a Wi-Fi scan first.';

  @override
  String latestSnapshot(Object backend, Object count) {
    return 'Latest snapshot: $count networks via $backend';
  }

  @override
  String get exportJson => 'Export JSON';

  @override
  String get exportHtml => 'Export HTML';

  @override
  String get exportPdf => 'Export PDF';

  @override
  String get printPdf => 'Print PDF';

  @override
  String get saveReportDialog => 'Save report';

  @override
  String get savePdfReportDialog => 'Save PDF report';

  @override
  String savedToast(Object path) {
    return 'Saved: $path';
  }

  @override
  String get handshakeCaptureCheck => 'Handshake capture check';

  @override
  String get activeDefenseReadiness => 'Active defense readiness';

  @override
  String get signalGraph => 'Signal Graph';

  @override
  String get riskFactors => 'RISK FACTORS';

  @override
  String get vulnerabilities => 'VULNERABILITIES';

  @override
  String recommendationLabel(Object text) {
    return 'RECOMMENDATION: $text';
  }

  @override
  String get noVulnerabilities => 'No known vulnerabilities detected based on current scan data.';

  @override
  String get bssId => 'BSSID';

  @override
  String get channel => 'CHANNEL';

  @override
  String get security => 'SECURITY';

  @override
  String get signal => 'SIGNAL';

  @override
  String get channelRatingTitle => 'CHANNEL RATING';

  @override
  String get band24Ghz => '2.4 GHz';

  @override
  String get band5Ghz => '5 GHz';

  @override
  String get no24GhzChannels => 'No 2.4 GHz channels detected.';

  @override
  String get no5GhzChannels => 'No 5 GHz channels detected.';

  @override
  String get recommendedChannel => 'RECOMMENDED CHANNEL';

  @override
  String channelInfo(Object channel, Object frequency) {
    return 'Ch $channel — $frequency MHz';
  }

  @override
  String bandChannels(Object band) {
    return '$band Channels';
  }

  @override
  String get errorLabel => 'Error';

  @override
  String get loading => 'Loading…';

  @override
  String get analyzing => 'Analyzing…';

  @override
  String get success => 'Success';

  @override
  String get ok => 'OK';

  @override
  String get scannedNetworksTitle => 'Scanned Networks';

  @override
  String get noNetworksFound => 'No networks found.';

  @override
  String get retry => 'Retry';

  @override
  String get knownNetworks => 'Known Networks';

  @override
  String get noKnownNetworksYet => 'No known networks yet.';

  @override
  String opsLabel(Object ops) {
    return 'Ops: $ops';
  }
}
