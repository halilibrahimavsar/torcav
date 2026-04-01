import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ku.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('ku'),
    Locale('tr')
  ];

  /// Warning message when policy prevents active operations.
  ///
  /// In en, this message translates to:
  /// **'Active operations are blocked unless policy and allowlist conditions pass.'**
  String get activeOperationsBlockedMsg;

  /// Label for the list of authorized networks.
  ///
  /// In en, this message translates to:
  /// **'Authorized Targets'**
  String get authorizedTargets;

  /// Generic add button label.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Status message when the allowlist is empty.
  ///
  /// In en, this message translates to:
  /// **'No targets allowlisted yet.'**
  String get noTargetsAllowlisted;

  /// Placeholder for a network with an empty SSID.
  ///
  /// In en, this message translates to:
  /// **'Hidden Network'**
  String get hiddenNetwork;

  /// Generic remove button label.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// Title for the history of security events.
  ///
  /// In en, this message translates to:
  /// **'Security Timeline'**
  String get securityTimeline;

  /// Status message when there are no security events logged.
  ///
  /// In en, this message translates to:
  /// **'No security events yet.'**
  String get noSecurityEvents;

  /// Action label to authorize a network.
  ///
  /// In en, this message translates to:
  /// **'Authorize Target'**
  String get authorizeTarget;

  /// Service Set Identifier (Network Name).
  ///
  /// In en, this message translates to:
  /// **'SSID'**
  String get ssid;

  /// Basic Service Set Identifier (MAC Address).
  ///
  /// In en, this message translates to:
  /// **'BSSID'**
  String get bssid;

  /// Checkbox label for handshake capture permission.
  ///
  /// In en, this message translates to:
  /// **'Allow handshake capture'**
  String get allowHandshakeCapture;

  /// Checkbox label for active defense tests permission.
  ///
  /// In en, this message translates to:
  /// **'Allow active defense/deauth tests'**
  String get allowActiveDefense;

  /// Generic cancel button label.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Generic save button label.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Description for confirm
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Label in settings for legal acknowledgement.
  ///
  /// In en, this message translates to:
  /// **'Legal disclaimer accepted'**
  String get legalDisclaimerAccepted;

  /// Instructional text about requirements for active scanning.
  ///
  /// In en, this message translates to:
  /// **'Required for active operations'**
  String get requiredForActiveOps;

  /// Toggle label for strict allowlist enforcement.
  ///
  /// In en, this message translates to:
  /// **'Strict allowlist'**
  String get strictAllowlist;

  /// Setting label to block ops on non-allowlisted targets.
  ///
  /// In en, this message translates to:
  /// **'Block active operations for unknown targets'**
  String get blockActiveOpsUnknown;

  /// Setting label for operational rate limiting.
  ///
  /// In en, this message translates to:
  /// **'Rate limit between active ops'**
  String get rateLimitActiveOps;

  /// Button label to pick a target from results.
  ///
  /// In en, this message translates to:
  /// **'Select from scanned list'**
  String get selectFromScanned;

  /// Label for language selection setting.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Description of the scan behavior settings section.
  ///
  /// In en, this message translates to:
  /// **'Control default scan behavior, backend strategy, and safety posture.'**
  String get settingsScanBehavior;

  /// Label for the default number of scan passes.
  ///
  /// In en, this message translates to:
  /// **'Default scan passes'**
  String get settingsDefaultScanPasses;

  /// Label for the monitoring frequency setting.
  ///
  /// In en, this message translates to:
  /// **'Monitoring interval (seconds)'**
  String get settingsMonitoringInterval;

  /// Label for choosing the scanning backend (e.g., nmcli, iw).
  ///
  /// In en, this message translates to:
  /// **'Default backend preference'**
  String get settingsBackendPreference;

  /// Label for hidden SSID inclusion setting.
  ///
  /// In en, this message translates to:
  /// **'Include hidden SSIDs by default'**
  String get settingsIncludeHidden;

  /// Label for strict safety mode toggle.
  ///
  /// In en, this message translates to:
  /// **'Strict safety mode'**
  String get settingsStrictSafety;

  /// Explanation of strict safety requirements.
  ///
  /// In en, this message translates to:
  /// **'Require consent + allowlist for active ops'**
  String get settingsStrictSafetyDesc;

  /// Bottom navigation label for Dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// Bottom navigation label for Wi-Fi Analyzer.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi'**
  String get navWifi;

  /// Bottom navigation label for LAN Recon.
  ///
  /// In en, this message translates to:
  /// **'LAN'**
  String get navLan;

  /// Description for navDiscovery
  ///
  /// In en, this message translates to:
  /// **'Discovery'**
  String get navDiscovery;

  /// Description for navOperations
  ///
  /// In en, this message translates to:
  /// **'Operations'**
  String get navOperations;

  /// Bottom navigation label for the More hub.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// Header for the More hub screen.
  ///
  /// In en, this message translates to:
  /// **'MORE'**
  String get moreTitle;

  /// Section header for utility tools.
  ///
  /// In en, this message translates to:
  /// **'TOOLS'**
  String get sectionTools;

  /// Title for the Speed Test feature.
  ///
  /// In en, this message translates to:
  /// **'Speed Test & Monitoring'**
  String get speedTestTitle;

  /// Brief description of the speed test tool.
  ///
  /// In en, this message translates to:
  /// **'Bandwidth, latency, and anomaly tracking'**
  String get speedTestDesc;

  /// Title for the Security Center feature.
  ///
  /// In en, this message translates to:
  /// **'Security Center'**
  String get securityCenterTitle;

  /// Brief description of the security feature.
  ///
  /// In en, this message translates to:
  /// **'Risk scoring, allowlists, and policy controls'**
  String get securityCenterDesc;

  /// Title for the Reports feature.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reportsTitle;

  /// Brief description of the reporting tool.
  ///
  /// In en, this message translates to:
  /// **'Export scans as PDF, HTML, or JSON'**
  String get reportsDesc;

  /// Section header for app preferences.
  ///
  /// In en, this message translates to:
  /// **'PREFERENCES'**
  String get sectionPreferences;

  /// Title for the Settings screen.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Brief description of the settings page.
  ///
  /// In en, this message translates to:
  /// **'Scan behavior, backends, and safety mode'**
  String get settingsDesc;

  /// Header for the network monitoring section.
  ///
  /// In en, this message translates to:
  /// **'Monitoring'**
  String get monitoringTitle;

  /// Subtitle for monitoring feature set.
  ///
  /// In en, this message translates to:
  /// **'Bandwidth, anomaly detection, and heatmap streams.'**
  String get monitoringSubtitle;

  /// Label for real-time packets per second metric.
  ///
  /// In en, this message translates to:
  /// **'Packets Per Second'**
  String get packetsPerSecondLabel;

  /// Label for real-time throughput metric.
  ///
  /// In en, this message translates to:
  /// **'Throughput'**
  String get throughputLabel;

  /// Label for features under development.
  ///
  /// In en, this message translates to:
  /// **'COMING SOON'**
  String get comingSoon;

  /// Title for signal history graphing.
  ///
  /// In en, this message translates to:
  /// **'Signal Trends'**
  String get signalTrends;

  /// Title for network topology visualization.
  ///
  /// In en, this message translates to:
  /// **'Topology & Mesh'**
  String get topologyMesh;

  /// Title for anomaly detection alerts.
  ///
  /// In en, this message translates to:
  /// **'Anomaly Alerts'**
  String get anomalyAlerts;

  /// Header in the speed test UI.
  ///
  /// In en, this message translates to:
  /// **'SPEED TEST'**
  String get speedTestHeader;

  /// Prompt to start a speed test.
  ///
  /// In en, this message translates to:
  /// **'Test your connection speed'**
  String get testConnectionSpeed;

  /// Status text while a test is active.
  ///
  /// In en, this message translates to:
  /// **'TESTING…'**
  String get testing;

  /// Button label to restart a test.
  ///
  /// In en, this message translates to:
  /// **'TEST AGAIN'**
  String get testAgain;

  /// Button label to initiate a test.
  ///
  /// In en, this message translates to:
  /// **'START TEST'**
  String get startTest;

  /// Latency test phase label.
  ///
  /// In en, this message translates to:
  /// **'PING'**
  String get phasePing;

  /// Download speed test phase label.
  ///
  /// In en, this message translates to:
  /// **'DOWNLOAD'**
  String get phaseDownload;

  /// Upload speed test phase label.
  ///
  /// In en, this message translates to:
  /// **'UPLOAD'**
  String get phaseUpload;

  /// Completed test phase status.
  ///
  /// In en, this message translates to:
  /// **'DONE'**
  String get phaseDone;

  /// Main title for the Wi-Fi Analyzer screen.
  ///
  /// In en, this message translates to:
  /// **'WI-FI ANALYZER'**
  String get wifiScanTitle;

  /// Tooltip for scan customization button.
  ///
  /// In en, this message translates to:
  /// **'Scan settings'**
  String get scanSettingsTooltip;

  /// Tooltip for channel rating view button.
  ///
  /// In en, this message translates to:
  /// **'Channel rating'**
  String get channelRatingTooltip;

  /// Tooltip for scan refresh button.
  ///
  /// In en, this message translates to:
  /// **'Refresh scan'**
  String get refreshScanTooltip;

  /// Status text when system is idle.
  ///
  /// In en, this message translates to:
  /// **'Ready to scan'**
  String get readyToScan;

  /// Label for the main scan action.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scanButton;

  /// Header for scan settings dialog.
  ///
  /// In en, this message translates to:
  /// **'Scan Settings'**
  String get scanSettingsTitle;

  /// No description provided for @passes.
  ///
  /// In en, this message translates to:
  /// **'Passes: {count}'**
  String passes(Object count);

  /// Checkbox label for hidden networks.
  ///
  /// In en, this message translates to:
  /// **'Include hidden SSIDs'**
  String get includeHiddenSsids;

  /// Label for scanning strategy selection.
  ///
  /// In en, this message translates to:
  /// **'Backend preference'**
  String get backendPreference;

  /// Generic apply button label.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// Status when no networks are found.
  ///
  /// In en, this message translates to:
  /// **'No signals detected'**
  String get noSignalsDetected;

  /// Header for the most recent scan data.
  ///
  /// In en, this message translates to:
  /// **'Last Snapshot'**
  String get lastSnapshot;

  /// Title for per-band network breakdown.
  ///
  /// In en, this message translates to:
  /// **'Band Analysis'**
  String get bandAnalysis;

  /// No description provided for @networksCount.
  ///
  /// In en, this message translates to:
  /// **'Networks ({count})'**
  String networksCount(Object count);

  /// Label for the automated network recommendation.
  ///
  /// In en, this message translates to:
  /// **'Recommendation'**
  String get recommendation;

  /// Main title for the LAN Reconnaissance screen.
  ///
  /// In en, this message translates to:
  /// **'LAN RECON'**
  String get lanReconTitle;

  /// No description provided for @scanFailed.
  ///
  /// In en, this message translates to:
  /// **'SCAN FAILED: {message}'**
  String scanFailed(Object message);

  /// Uppercase status label for readiness.
  ///
  /// In en, this message translates to:
  /// **'READY TO SCAN'**
  String get readyToScanAllCaps;

  /// Input label for the network range to scan.
  ///
  /// In en, this message translates to:
  /// **'Target subnet/IP'**
  String get targetSubnet;

  /// Label for Nmap scan profile selection.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Label for discovery method selection.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get method;

  /// Uppercase label for the scan button.
  ///
  /// In en, this message translates to:
  /// **'SCAN'**
  String get scanAllCaps;

  /// Status when no hosts respond on the LAN.
  ///
  /// In en, this message translates to:
  /// **'NO HOSTS FOUND'**
  String get noHostsFound;

  /// Label for a host with no hostname/SSID.
  ///
  /// In en, this message translates to:
  /// **'Unknown host'**
  String get unknownHost;

  /// No description provided for @os.
  ///
  /// In en, this message translates to:
  /// **'OS: {os}'**
  String os(Object os);

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services: {services}'**
  String services(Object services);

  /// No description provided for @vuln.
  ///
  /// In en, this message translates to:
  /// **'Vuln: {vuln}'**
  String vuln(Object vuln);

  /// Instructional text on the reports screen.
  ///
  /// In en, this message translates to:
  /// **'Export the latest scan session as JSON, HTML, or PDF.'**
  String get reportsSubtitle;

  /// Error when trying to report without data.
  ///
  /// In en, this message translates to:
  /// **'No scan snapshot is available yet. Run a Wi-Fi scan first.'**
  String get noSnapshotAvailable;

  /// No description provided for @latestSnapshot.
  ///
  /// In en, this message translates to:
  /// **'Latest snapshot: {count} networks via {backend}'**
  String latestSnapshot(Object count, Object backend);

  /// Action label for JSON export.
  ///
  /// In en, this message translates to:
  /// **'Export JSON'**
  String get exportJson;

  /// Action label for HTML export.
  ///
  /// In en, this message translates to:
  /// **'Export HTML'**
  String get exportHtml;

  /// Action label for PDF export.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get exportPdf;

  /// Action label to invoke the print dialog.
  ///
  /// In en, this message translates to:
  /// **'Print PDF'**
  String get printPdf;

  /// Title for report save dialog.
  ///
  /// In en, this message translates to:
  /// **'Save report'**
  String get saveReportDialog;

  /// Description for sectionStatus
  ///
  /// In en, this message translates to:
  /// **'STATUS'**
  String get sectionStatus;

  /// Description for exportOptionsTitle
  ///
  /// In en, this message translates to:
  /// **'EXPORT OPTIONS'**
  String get exportOptionsTitle;

  /// Description for latestSnapshotTitle
  ///
  /// In en, this message translates to:
  /// **'LATEST SNAPSHOT'**
  String get latestSnapshotTitle;

  /// Description for backendLabel
  ///
  /// In en, this message translates to:
  /// **'Backend'**
  String get backendLabel;

  /// Title for PDF specific save dialog.
  ///
  /// In en, this message translates to:
  /// **'Save PDF report'**
  String get savePdfReportDialog;

  /// No description provided for @savedToast.
  ///
  /// In en, this message translates to:
  /// **'Saved: {path}'**
  String savedToast(Object path);

  /// Title of the security check for handshakes.
  ///
  /// In en, this message translates to:
  /// **'Handshake capture check'**
  String get handshakeCaptureCheck;

  /// Title of the readiness check for active defense.
  ///
  /// In en, this message translates to:
  /// **'Active defense readiness'**
  String get activeDefenseReadiness;

  /// Header for the spectral visualization.
  ///
  /// In en, this message translates to:
  /// **'Signal Graph'**
  String get signalGraph;

  /// Section header for security risk list.
  ///
  /// In en, this message translates to:
  /// **'RISK FACTORS'**
  String get riskFactors;

  /// Header for detected vulnerabilities.
  ///
  /// In en, this message translates to:
  /// **'VULNERABILITIES'**
  String get vulnerabilities;

  /// No description provided for @recommendationLabel.
  ///
  /// In en, this message translates to:
  /// **'RECOMMENDATION: {text}'**
  String recommendationLabel(Object text);

  /// Message when no vulnerabilities are found.
  ///
  /// In en, this message translates to:
  /// **'No known vulnerabilities detected based on current scan data.'**
  String get noVulnerabilities;

  /// MAC address label (BSSID).
  ///
  /// In en, this message translates to:
  /// **'BSSID'**
  String get bssId;

  /// Wireless channel number label.
  ///
  /// In en, this message translates to:
  /// **'CHANNEL'**
  String get channel;

  /// Encryption/Security type label.
  ///
  /// In en, this message translates to:
  /// **'SECURITY'**
  String get security;

  /// Signal strength label (RSSI).
  ///
  /// In en, this message translates to:
  /// **'SIGNAL'**
  String get signal;

  /// Header for the channel evaluation screen.
  ///
  /// In en, this message translates to:
  /// **'CHANNEL RATING'**
  String get channelRatingTitle;

  /// The 2.4 GHz frequency band.
  ///
  /// In en, this message translates to:
  /// **'2.4 GHz'**
  String get band24Ghz;

  /// The 5 GHz frequency band.
  ///
  /// In en, this message translates to:
  /// **'5 GHz'**
  String get band5Ghz;

  /// Status when no 2.4 GHz signals exist.
  ///
  /// In en, this message translates to:
  /// **'No 2.4 GHz channels detected.'**
  String get no24GhzChannels;

  /// Status when no 5 GHz signals exist.
  ///
  /// In en, this message translates to:
  /// **'No 5 GHz channels detected.'**
  String get no5GhzChannels;

  /// The 6 GHz frequency band.
  ///
  /// In en, this message translates to:
  /// **'6 GHz'**
  String get band6Ghz;

  /// Status when no 6 GHz signals exist.
  ///
  /// In en, this message translates to:
  /// **'No 6 GHz channels detected.'**
  String get no6GhzChannels;

  /// Header for the best suggested channel.
  ///
  /// In en, this message translates to:
  /// **'RECOMMENDED CHANNEL'**
  String get recommendedChannel;

  /// No description provided for @channelInfo.
  ///
  /// In en, this message translates to:
  /// **'Ch {channel} — {frequency} MHz'**
  String channelInfo(Object channel, Object frequency);

  /// No description provided for @bandChannels.
  ///
  /// In en, this message translates to:
  /// **'{band} Channels'**
  String bandChannels(Object band);

  /// Prefix for error messages.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorLabel;

  /// Generic loading state indicator.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// Generic processing state indicator.
  ///
  /// In en, this message translates to:
  /// **'Analyzing…'**
  String get analyzing;

  /// Generic success indicator.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// Generic acceptance button label.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Title for list of discovered networks.
  ///
  /// In en, this message translates to:
  /// **'Scanned Networks'**
  String get scannedNetworksTitle;

  /// Status when scanning results are empty.
  ///
  /// In en, this message translates to:
  /// **'No networks found.'**
  String get noNetworksFound;

  /// Generic retry button label.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Title for the list of previously seen networks.
  ///
  /// In en, this message translates to:
  /// **'Known Networks'**
  String get knownNetworks;

  /// Status when the local database is empty.
  ///
  /// In en, this message translates to:
  /// **'No known networks yet.'**
  String get noKnownNetworksYet;

  /// No description provided for @opsLabel.
  ///
  /// In en, this message translates to:
  /// **'Ops: {ops}'**
  String opsLabel(Object ops);

  /// Description for networkStatusLabel
  ///
  /// In en, this message translates to:
  /// **'NETWORK STATUS'**
  String get networkStatusLabel;

  /// Description for activeSessionLabel
  ///
  /// In en, this message translates to:
  /// **'ACTIVE SESSION'**
  String get activeSessionLabel;

  /// Description for gatewayLabel
  ///
  /// In en, this message translates to:
  /// **'GATEWAY'**
  String get gatewayLabel;

  /// Description for ipLabel
  ///
  /// In en, this message translates to:
  /// **'IP ADDRESS'**
  String get ipLabel;

  /// Description for connectedStatusCaps
  ///
  /// In en, this message translates to:
  /// **'CONNECTED'**
  String get connectedStatusCaps;

  /// Description for disconnectedStatusCaps
  ///
  /// In en, this message translates to:
  /// **'DISCONNECTED'**
  String get disconnectedStatusCaps;

  /// Description for quickActionsTitle
  ///
  /// In en, this message translates to:
  /// **'QUICK ACTIONS'**
  String get quickActionsTitle;

  /// Description for lastScanTitle
  ///
  /// In en, this message translates to:
  /// **'LAST SCAN'**
  String get lastScanTitle;

  /// Description for viewDetailsAction
  ///
  /// In en, this message translates to:
  /// **'VIEW DETAILS'**
  String get viewDetailsAction;

  /// Description for scanning
  ///
  /// In en, this message translates to:
  /// **'SCANNING…'**
  String get scanning;

  /// Description for secure
  ///
  /// In en, this message translates to:
  /// **'SECURE'**
  String get secure;

  /// Description for blockUnknownAP
  ///
  /// In en, this message translates to:
  /// **'Block Unknown APs'**
  String get blockUnknownAP;

  /// Description for automaticBlockMsg
  ///
  /// In en, this message translates to:
  /// **'Automatically drops connections to rogue APs'**
  String get automaticBlockMsg;

  /// Description for activeProbingEnabled
  ///
  /// In en, this message translates to:
  /// **'Active Probing'**
  String get activeProbingEnabled;

  /// Description for activeProbingMsg
  ///
  /// In en, this message translates to:
  /// **'Periodically tests connected AP for anomalies'**
  String get activeProbingMsg;

  /// Description for requireConsentForDeauth
  ///
  /// In en, this message translates to:
  /// **'Require Consent'**
  String get requireConsentForDeauth;

  /// Description for manualAuthorizationMsg
  ///
  /// In en, this message translates to:
  /// **'Manually authorize deauth/active defense'**
  String get manualAuthorizationMsg;

  /// Description for defensePolicy
  ///
  /// In en, this message translates to:
  /// **'Defense Policy'**
  String get defensePolicy;

  /// Description for shieldActive
  ///
  /// In en, this message translates to:
  /// **'Shield Active'**
  String get shieldActive;

  /// Description for activeProtection
  ///
  /// In en, this message translates to:
  /// **'Active Protection'**
  String get activeProtection;

  /// Description for riskScore
  ///
  /// In en, this message translates to:
  /// **'Risk Score'**
  String get riskScore;

  /// Description for securityRadar
  ///
  /// In en, this message translates to:
  /// **'Security Radar'**
  String get securityRadar;

  /// Description for profileTitle
  ///
  /// In en, this message translates to:
  /// **'AGENT PROFILE'**
  String get profileTitle;

  /// Description for logout
  ///
  /// In en, this message translates to:
  /// **'LOGOUT'**
  String get logout;

  /// Description for logoutConfirmation
  ///
  /// In en, this message translates to:
  /// **'DISCONNECT SESSION'**
  String get logoutConfirmation;

  /// Description for logoutConfirmMessage
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to terminate the current session? All active monitoring will be paused.'**
  String get logoutConfirmMessage;

  /// Description for livePulse
  ///
  /// In en, this message translates to:
  /// **'LIVE PULSE'**
  String get livePulse;

  /// Description for operationsLabel
  ///
  /// In en, this message translates to:
  /// **'OPERATIONS'**
  String get operationsLabel;

  /// Description for topologyLabel
  ///
  /// In en, this message translates to:
  /// **'TOPOLOGY'**
  String get topologyLabel;

  /// Description for accessEngine
  ///
  /// In en, this message translates to:
  /// **'ACCESS ENGINE'**
  String get accessEngine;

  /// Description for networkLogs
  ///
  /// In en, this message translates to:
  /// **'NETWORK LOGS'**
  String get networkLogs;

  /// Description for strictSafetyEnabled
  ///
  /// In en, this message translates to:
  /// **'STRICT SAFETY ENABLED'**
  String get strictSafetyEnabled;

  /// Description for activeMonitoringProgress
  ///
  /// In en, this message translates to:
  /// **'Active monitoring in progress'**
  String get activeMonitoringProgress;

  /// Description for topologyMapTitle
  ///
  /// In en, this message translates to:
  /// **'TOPOLOGY MAP'**
  String get topologyMapTitle;

  /// Description for trafficLabel
  ///
  /// In en, this message translates to:
  /// **'TRAFFIC'**
  String get trafficLabel;

  /// Description for forceLabel
  ///
  /// In en, this message translates to:
  /// **'FORCE'**
  String get forceLabel;

  /// Description for normalSpeed
  ///
  /// In en, this message translates to:
  /// **'NORMAL'**
  String get normalSpeed;

  /// Description for fastSpeed
  ///
  /// In en, this message translates to:
  /// **'FAST'**
  String get fastSpeed;

  /// Description for overdriveSpeed
  ///
  /// In en, this message translates to:
  /// **'OVERDRIVE'**
  String get overdriveSpeed;

  /// Description for noTopologyData
  ///
  /// In en, this message translates to:
  /// **'No topology data'**
  String get noTopologyData;

  /// Description for runScanFirst
  ///
  /// In en, this message translates to:
  /// **'Run a Wi-Fi and LAN scan first'**
  String get runScanFirst;

  /// Description for thisDevice
  ///
  /// In en, this message translates to:
  /// **'This Device'**
  String get thisDevice;

  /// Description for gatewayDevice
  ///
  /// In en, this message translates to:
  /// **'Gateway'**
  String get gatewayDevice;

  /// Description for mobileDevice
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get mobileDevice;

  /// Description for deviceLabel
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get deviceLabel;

  /// Description for iotDevice
  ///
  /// In en, this message translates to:
  /// **'IoT'**
  String get iotDevice;

  /// Description for analyzingNode
  ///
  /// In en, this message translates to:
  /// **'ANALYZING NODE...'**
  String get analyzingNode;

  /// No description provided for @failedLoadTopology.
  ///
  /// In en, this message translates to:
  /// **'Failed to load topology: {error}'**
  String failedLoadTopology(Object error);

  /// Description for neuralCoreTitle
  ///
  /// In en, this message translates to:
  /// **'NEURAL_CORE_AI'**
  String get neuralCoreTitle;

  /// Description for activeAnomalies
  ///
  /// In en, this message translates to:
  /// **'ACTIVE ANOMALIES'**
  String get activeAnomalies;

  /// Description for predictiveHealth
  ///
  /// In en, this message translates to:
  /// **'PREDICTIVE HEALTH'**
  String get predictiveHealth;

  /// Description for aiStrategyReport
  ///
  /// In en, this message translates to:
  /// **'AI STRATEGY REPORT'**
  String get aiStrategyReport;

  /// Description for engineStability
  ///
  /// In en, this message translates to:
  /// **'ENGINE_STABILITY: OPTIMAL'**
  String get engineStability;

  /// Description for aiStrategyText
  ///
  /// In en, this message translates to:
  /// **'Current network topology suggests a stable signature. No immediate horizontal movement detected in subnets. Recommend enabling Stealth Mode on public access points to mitigate passive node discovery.'**
  String get aiStrategyText;

  /// Description for packetSnifferTitle
  ///
  /// In en, this message translates to:
  /// **'PACKET_SNIFFER'**
  String get packetSnifferTitle;

  /// Description for streamPaused
  ///
  /// In en, this message translates to:
  /// **'STREAM_PAUSED'**
  String get streamPaused;

  /// Description for filterNone
  ///
  /// In en, this message translates to:
  /// **'FILTER: NONE'**
  String get filterNone;

  /// Description for totalPackets
  ///
  /// In en, this message translates to:
  /// **'TOTAL_PKTS'**
  String get totalPackets;

  /// Description for droppedLabel
  ///
  /// In en, this message translates to:
  /// **'DROPPED'**
  String get droppedLabel;

  /// Description for bufferLabel
  ///
  /// In en, this message translates to:
  /// **'BUFFER'**
  String get bufferLabel;

  /// Description for latencyLabel
  ///
  /// In en, this message translates to:
  /// **'LATENCY'**
  String get latencyLabel;

  /// Description for activeMonitoring
  ///
  /// In en, this message translates to:
  /// **'ACTIVE MONITORING'**
  String get activeMonitoring;

  /// Description for deactivate
  ///
  /// In en, this message translates to:
  /// **'DEACTIVATE'**
  String get deactivate;

  /// Description for initializeLink
  ///
  /// In en, this message translates to:
  /// **'INITIALIZE LINK'**
  String get initializeLink;

  /// Description for commandCenters
  ///
  /// In en, this message translates to:
  /// **'COMMAND CENTERS'**
  String get commandCenters;

  /// Description for defenseTitle
  ///
  /// In en, this message translates to:
  /// **'DEFENSE'**
  String get defenseTitle;

  /// Description for activeShielding
  ///
  /// In en, this message translates to:
  /// **'Active Shielding'**
  String get activeShielding;

  /// Description for logisticsTitle
  ///
  /// In en, this message translates to:
  /// **'LOGISTICS'**
  String get logisticsTitle;

  /// Description for intelMetrics
  ///
  /// In en, this message translates to:
  /// **'Intel & Metrics'**
  String get intelMetrics;

  /// Description for networkMesh
  ///
  /// In en, this message translates to:
  /// **'Network Mesh'**
  String get networkMesh;

  /// Description for tuningTitle
  ///
  /// In en, this message translates to:
  /// **'TUNING'**
  String get tuningTitle;

  /// Description for systemConfig
  ///
  /// In en, this message translates to:
  /// **'System Config'**
  String get systemConfig;

  /// Description for technicalTools
  ///
  /// In en, this message translates to:
  /// **'TECHNICAL TOOLS'**
  String get technicalTools;

  /// Description for packetLogs
  ///
  /// In en, this message translates to:
  /// **'PACKET LOGS'**
  String get packetLogs;

  /// Description for aiInsights
  ///
  /// In en, this message translates to:
  /// **'AI INSIGHTS'**
  String get aiInsights;

  /// Description for interactiveSimulation
  ///
  /// In en, this message translates to:
  /// **'INTERACTIVE_SIMULATION'**
  String get interactiveSimulation;

  /// Description for appearance
  ///
  /// In en, this message translates to:
  /// **'APPEARANCE'**
  String get appearance;

  /// Description for theme
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Description for darkTheme
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// Description for lightTheme
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// Description for systemTheme
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemTheme;

  /// Description for systemStatus
  ///
  /// In en, this message translates to:
  /// **'SYSTEM STATUS'**
  String get systemStatus;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'ku', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'ku': return AppLocalizationsKu();
    case 'tr': return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
