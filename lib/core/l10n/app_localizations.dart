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
/// import 'l10n/app_localizations.dart';
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

  /// Title for the wifi scan screen.
  ///
  /// In en, this message translates to:
  /// **'WIFI SCAN'**
  String get wifiScanTitle;

  /// Text shown when the search bar is empty.
  ///
  /// In en, this message translates to:
  /// **'SEARCHING NETWORKS...'**
  String get searchingNetworksPlaceholder;

  /// Placeholder for the search input.
  ///
  /// In en, this message translates to:
  /// **'FILTER NETWORKS...'**
  String get filterNetworksPlaceholder;

  /// Passive scan label.
  ///
  /// In en, this message translates to:
  /// **'Quick Scan'**
  String get quickScan;

  /// Active scan label.
  ///
  /// In en, this message translates to:
  /// **'Deep Scan'**
  String get deepScan;

  /// Title for scan mode info.
  ///
  /// In en, this message translates to:
  /// **'Scan Modes'**
  String get scanModesTitle;

  /// Description of scan modes.
  ///
  /// In en, this message translates to:
  /// **'Quick scan listens for broadcasts. Deep scan actively probes for networks.'**
  String get scanModesInfo;

  /// Status when idle.
  ///
  /// In en, this message translates to:
  /// **'Ready to Scan'**
  String get readyToScan;

  /// Empty state for wifi scan.
  ///
  /// In en, this message translates to:
  /// **'No Signals Detected'**
  String get noSignalsDetected;

  /// Comparison button label.
  ///
  /// In en, this message translates to:
  /// **'COMPARE WITH PREVIOUS SCAN'**
  String get compareWithPreviousScan;

  /// Count of networks found.
  ///
  /// In en, this message translates to:
  /// **'{count} NETWORKS'**
  String networksCount(int count);

  /// Count of filtered results.
  ///
  /// In en, this message translates to:
  /// **'{count} OF {total} NETWORKS'**
  String filteredNetworksCount(int count, int total);

  /// Dashboard tooltip.
  ///
  /// In en, this message translates to:
  /// **'View security alerts'**
  String get securityAlertsTooltip;

  /// Dashboard live indicator.
  ///
  /// In en, this message translates to:
  /// **'LIVE PULSE'**
  String get livePulse;

  /// Dashboard section label.
  ///
  /// In en, this message translates to:
  /// **'OPERATIONS'**
  String get operationsLabel;

  /// Dashboard section label.
  ///
  /// In en, this message translates to:
  /// **'TOPOLOGY'**
  String get topologyLabel;

  /// Dashboard logs label.
  ///
  /// In en, this message translates to:
  /// **'NETWORK LOGS'**
  String get networkLogs;

  /// Status connected.
  ///
  /// In en, this message translates to:
  /// **'CONNECTED'**
  String get connectedStatusCaps;

  /// Status disconnected.
  ///
  /// In en, this message translates to:
  /// **'DISCONNECTED'**
  String get disconnectedStatusCaps;

  /// IP label.
  ///
  /// In en, this message translates to:
  /// **'IP'**
  String get ipLabel;

  /// Gateway label.
  ///
  /// In en, this message translates to:
  /// **'GATEWAY'**
  String get gatewayLabel;

  /// Access engine status.
  ///
  /// In en, this message translates to:
  /// **'ACCESS ENGINE'**
  String get accessEngine;

  /// Snapshot section title.
  ///
  /// In en, this message translates to:
  /// **'Latest Network Snapshot'**
  String get latestSnapshotTitle;

  /// No snapshot found.
  ///
  /// In en, this message translates to:
  /// **'No snapshot data available...'**
  String get noSnapshotAvailable;

  /// Safety mode text.
  ///
  /// In en, this message translates to:
  /// **'Strict safety protocols enabled'**
  String get strictSafetyEnabled;

  /// Monitoring status text.
  ///
  /// In en, this message translates to:
  /// **'Active monitoring in progress...'**
  String get activeMonitoringProgress;

  /// Comparison page title.
  ///
  /// In en, this message translates to:
  /// **'SCAN COMPARISON'**
  String get scanComparisonTitle;

  /// Requirement for comparison.
  ///
  /// In en, this message translates to:
  /// **'Comparison requires at least 2 scans.\n\nRun another scan to see changes.'**
  String get comparisonNeedsTwoScans;

  /// Empty comparison result.
  ///
  /// In en, this message translates to:
  /// **'No changes detected between the last two scans.'**
  String get noChangesDetected;

  /// New networks header.
  ///
  /// In en, this message translates to:
  /// **'NEW ({count})'**
  String newNetworksCountLabel(int count);

  /// Removed networks header.
  ///
  /// In en, this message translates to:
  /// **'GONE ({count})'**
  String goneNetworksCountLabel(int count);

  /// Modified networks header.
  ///
  /// In en, this message translates to:
  /// **'CHANGED ({count})'**
  String changedNetworksCountLabel(int count);

  /// Plus New Label
  ///
  /// In en, this message translates to:
  /// **'+ NEW'**
  String get plusNewLabel;

  /// Gone Label
  ///
  /// In en, this message translates to:
  /// **'GONE'**
  String get goneLabel;

  /// Hidden Label
  ///
  /// In en, this message translates to:
  /// **'[Hidden]'**
  String get hiddenLabel;

  /// Wifi channel.
  ///
  /// In en, this message translates to:
  /// **'CH {channel}'**
  String channelLabel(int channel);

  /// Security Label
  ///
  /// In en, this message translates to:
  /// **'SECURITY'**
  String get securityLabel;

  /// Initiating Spectrum Scan
  ///
  /// In en, this message translates to:
  /// **'INITIATING SPECTRUM SCAN...'**
  String get initiatingSpectrumScan;

  /// Broadcasting Probe Requests
  ///
  /// In en, this message translates to:
  /// **'BROADCASTING PROBE REQUESTS...'**
  String get broadcastingProbeRequests;

  /// No Radios In Range
  ///
  /// In en, this message translates to:
  /// **'No radios in range'**
  String get noRadiosInRange;

  /// No Networks Match Filter
  ///
  /// In en, this message translates to:
  /// **'No networks match your filter'**
  String get noNetworksMatchFilter;

  /// Search Ssid Bssid Vendor
  ///
  /// In en, this message translates to:
  /// **'Search SSID, BSSID or Vendor...'**
  String get searchSsidBssidVendor;

  /// Sort Prefix
  ///
  /// In en, this message translates to:
  /// **'Sort: {option}'**
  String sortPrefix(String option);

  /// Band All
  ///
  /// In en, this message translates to:
  /// **'ALL BANDS'**
  String get bandAll;

  /// Sort Signal
  ///
  /// In en, this message translates to:
  /// **'Signal'**
  String get sortSignal;

  /// Sort Name
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get sortName;

  /// Sort Channel
  ///
  /// In en, this message translates to:
  /// **'Channel'**
  String get sortChannel;

  /// Sort Security
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get sortSecurity;

  /// Sort By Title
  ///
  /// In en, this message translates to:
  /// **'SORT BY'**
  String get sortByTitle;

  /// Recommendation Tip
  ///
  /// In en, this message translates to:
  /// **'Optimum channels on {band}: {channels}'**
  String recommendationTip(String channels, String band);

  /// Channel Interference Title
  ///
  /// In en, this message translates to:
  /// **'Channel Interference'**
  String get channelInterferenceTitle;

  /// Networks Label
  ///
  /// In en, this message translates to:
  /// **'NETWORKS'**
  String get networksLabel;

  /// Open Count
  ///
  /// In en, this message translates to:
  /// **'{count} OPEN'**
  String openCount(int count);

  /// Avg Signal Label
  ///
  /// In en, this message translates to:
  /// **'AVG SIGNAL'**
  String get avgSignalLabel;

  /// Not Available
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notAvailable;

  /// Dbm Caps
  ///
  /// In en, this message translates to:
  /// **'DBM'**
  String get dbmCaps;

  /// Interface Label
  ///
  /// In en, this message translates to:
  /// **'INTERFACE'**
  String get interfaceLabel;

  /// Frequency Label
  ///
  /// In en, this message translates to:
  /// **'{freq} MHz'**
  String frequencyLabel(int freq);

  /// Reports Title
  ///
  /// In en, this message translates to:
  /// **'REPORTS'**
  String get reportsTitle;

  /// Save Report Dialog
  ///
  /// In en, this message translates to:
  /// **'Save Report'**
  String get saveReportDialog;

  /// Saved Toast
  ///
  /// In en, this message translates to:
  /// **'Report saved to {path}'**
  String savedToast(String path);

  /// Error Label
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorLabel;

  /// Save Pdf Report Dialog
  ///
  /// In en, this message translates to:
  /// **'Save PDF Report'**
  String get savePdfReportDialog;

  /// Scanning
  ///
  /// In en, this message translates to:
  /// **'Scanning...'**
  String get scanning;

  /// Shield Active
  ///
  /// In en, this message translates to:
  /// **'Shield Active'**
  String get shieldActive;

  /// Threats Detected
  ///
  /// In en, this message translates to:
  /// **'Threats Detected'**
  String get threatsDetected;

  /// Trusted Label
  ///
  /// In en, this message translates to:
  /// **'TRUSTED'**
  String get trustedLabel;

  /// Security Event Title
  ///
  /// In en, this message translates to:
  /// **'Security Event'**
  String get securityEventTitle;

  /// Network Recon Title
  ///
  /// In en, this message translates to:
  /// **'NETWORK RECON'**
  String get networkReconTitle;

  /// Intelligence Report Title
  ///
  /// In en, this message translates to:
  /// **'INTELLIGENCE REPORT'**
  String get intelligenceReportTitle;

  /// Discovered Endpoints Title
  ///
  /// In en, this message translates to:
  /// **'DISCOVERED ENDPOINTS'**
  String get discoveredEndpointsTitle;

  /// New Device Found
  ///
  /// In en, this message translates to:
  /// **'1 new device: {ip}'**
  String newDeviceFound(String ip);

  /// New Devices Found
  ///
  /// In en, this message translates to:
  /// **'{count} new devices on your network'**
  String newDevicesFound(int count);

  /// Target Ip Subnet
  ///
  /// In en, this message translates to:
  /// **'Target IP / Subnet'**
  String get targetIpSubnet;

  /// Scan Profile Fast
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get scanProfileFast;

  /// Scan Profile Balanced
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get scanProfileBalanced;

  /// Scan Profile Aggressive
  ///
  /// In en, this message translates to:
  /// **'Aggressive'**
  String get scanProfileAggressive;

  /// Scan Profile Normal
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get scanProfileNormal;

  /// Scan Profile Intense
  ///
  /// In en, this message translates to:
  /// **'Intense'**
  String get scanProfileIntense;

  /// Vuln Only Label
  ///
  /// In en, this message translates to:
  /// **'Vulnerabilities Only'**
  String get vulnOnlyLabel;

  /// Lan Recon Title
  ///
  /// In en, this message translates to:
  /// **'LAN RECON'**
  String get lanReconTitle;

  /// Target Subnet
  ///
  /// In en, this message translates to:
  /// **'Target IP / Subnet'**
  String get targetSubnet;

  /// Scan All Caps
  ///
  /// In en, this message translates to:
  /// **'SCAN'**
  String get scanAllCaps;

  /// Channel Rating Title
  ///
  /// In en, this message translates to:
  /// **'CHANNEL RATING'**
  String get channelRatingTitle;

  /// Refresh Scan Tooltip
  ///
  /// In en, this message translates to:
  /// **'Refresh Scan'**
  String get refreshScanTooltip;

  /// Band24 Ghz
  ///
  /// In en, this message translates to:
  /// **'2.4 GHz'**
  String get band24Ghz;

  /// Band5 Ghz
  ///
  /// In en, this message translates to:
  /// **'5 GHz'**
  String get band5Ghz;

  /// Band6 Ghz
  ///
  /// In en, this message translates to:
  /// **'6 GHz'**
  String get band6Ghz;

  /// No24 Ghz Channels
  ///
  /// In en, this message translates to:
  /// **'No 2.4 GHz channels found.'**
  String get no24GhzChannels;

  /// No5 Ghz Channels
  ///
  /// In en, this message translates to:
  /// **'No 5 GHz channels found.'**
  String get no5GhzChannels;

  /// No6 Ghz Channels
  ///
  /// In en, this message translates to:
  /// **'No 6 GHz channels found.'**
  String get no6GhzChannels;

  /// Analyzing
  ///
  /// In en, this message translates to:
  /// **'Analyzing...'**
  String get analyzing;

  /// History Label
  ///
  /// In en, this message translates to:
  /// **'HISTORY'**
  String get historyLabel;

  /// Failed Load Topology
  ///
  /// In en, this message translates to:
  /// **'Failed to load topology: {error}'**
  String failedLoadTopology(String error);

  /// Traffic Label
  ///
  /// In en, this message translates to:
  /// **'TRAFFIC'**
  String get trafficLabel;

  /// Force Label
  ///
  /// In en, this message translates to:
  /// **'FORCE'**
  String get forceLabel;

  /// Normal Speed
  ///
  /// In en, this message translates to:
  /// **'NORMAL'**
  String get normalSpeed;

  /// Fast Speed
  ///
  /// In en, this message translates to:
  /// **'FAST'**
  String get fastSpeed;

  /// Overdrive Speed
  ///
  /// In en, this message translates to:
  /// **'OVERDRIVE'**
  String get overdriveSpeed;

  /// Topology Map Title
  ///
  /// In en, this message translates to:
  /// **'TOPOLOGY MAP'**
  String get topologyMapTitle;

  /// No Topology Data
  ///
  /// In en, this message translates to:
  /// **'No Topology Data'**
  String get noTopologyData;

  /// Run Scan First
  ///
  /// In en, this message translates to:
  /// **'Run a scan first to build the network map'**
  String get runScanFirst;

  /// Retry
  ///
  /// In en, this message translates to:
  /// **'RETRY'**
  String get retry;

  /// This Device
  ///
  /// In en, this message translates to:
  /// **'THIS DEVICE'**
  String get thisDevice;

  /// Gateway Device
  ///
  /// In en, this message translates to:
  /// **'GATEWAY'**
  String get gatewayDevice;

  /// Mobile Device
  ///
  /// In en, this message translates to:
  /// **'MOBILE'**
  String get mobileDevice;

  /// Device Label
  ///
  /// In en, this message translates to:
  /// **'DEVICE'**
  String get deviceLabel;

  /// Iot Device
  ///
  /// In en, this message translates to:
  /// **'IOT'**
  String get iotDevice;

  /// Analyzing Node
  ///
  /// In en, this message translates to:
  /// **'ANALYZING NODE'**
  String get analyzingNode;

  /// Settings Title
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get settingsTitle;

  /// Appearance
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Settings Language
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Theme
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Settings Scan Behavior
  ///
  /// In en, this message translates to:
  /// **'Scan Behavior'**
  String get settingsScanBehavior;

  /// Settings Default Scan Passes
  ///
  /// In en, this message translates to:
  /// **'Default Scan Passes'**
  String get settingsDefaultScanPasses;

  /// Settings Monitoring Interval
  ///
  /// In en, this message translates to:
  /// **'Monitoring Interval'**
  String get settingsMonitoringInterval;

  /// Settings Backend Preference
  ///
  /// In en, this message translates to:
  /// **'Backend Preference'**
  String get settingsBackendPreference;

  /// Settings Include Hidden
  ///
  /// In en, this message translates to:
  /// **'Include Hidden SSIDs'**
  String get settingsIncludeHidden;

  /// Settings Strict Safety
  ///
  /// In en, this message translates to:
  /// **'Strict Safety Mode'**
  String get settingsStrictSafety;

  /// Settings Strict Safety Desc
  ///
  /// In en, this message translates to:
  /// **'Restrict dangerous operations'**
  String get settingsStrictSafetyDesc;

  /// Dark Theme
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// Light Theme
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// System Theme
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemTheme;

  /// Section Status
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get sectionStatus;

  /// Reports Subtitle
  ///
  /// In en, this message translates to:
  /// **'Network Scan & Security Intelligence'**
  String get reportsSubtitle;

  /// Export Options Title
  ///
  /// In en, this message translates to:
  /// **'EXPORT OPTIONS'**
  String get exportOptionsTitle;

  /// Export Json
  ///
  /// In en, this message translates to:
  /// **'Export JSON'**
  String get exportJson;

  /// Export Html
  ///
  /// In en, this message translates to:
  /// **'Export HTML'**
  String get exportHtml;

  /// Export Pdf
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get exportPdf;

  /// Print Pdf
  ///
  /// In en, this message translates to:
  /// **'Print PDF'**
  String get printPdf;

  /// Nav Wifi
  ///
  /// In en, this message translates to:
  /// **'WIFI'**
  String get navWifi;

  /// Backend Label
  ///
  /// In en, this message translates to:
  /// **'BACKEND'**
  String get backendLabel;

  /// Defense Title
  ///
  /// In en, this message translates to:
  /// **'DEFENSE'**
  String get defenseTitle;

  /// Known Networks
  ///
  /// In en, this message translates to:
  /// **'Known Networks'**
  String get knownNetworks;

  /// No Known Networks Yet
  ///
  /// In en, this message translates to:
  /// **'No known networks yet'**
  String get noKnownNetworksYet;

  /// Security Timeline
  ///
  /// In en, this message translates to:
  /// **'Security Timeline'**
  String get securityTimeline;

  /// No Security Events
  ///
  /// In en, this message translates to:
  /// **'No security events recorded'**
  String get noSecurityEvents;

  /// Auth Local System
  ///
  /// In en, this message translates to:
  /// **'AUTH_LOCAL_SYSTEM'**
  String get authLocalSystem;

  /// Remote Node Id Label
  ///
  /// In en, this message translates to:
  /// **'REMOTE_NODE_ID: {id}'**
  String remoteNodeIdLabel(String id);

  /// Ip Addr Label
  ///
  /// In en, this message translates to:
  /// **'IP_ADDR'**
  String get ipAddrLabel;

  /// Mac Val Label
  ///
  /// In en, this message translates to:
  /// **'MAC_VAL'**
  String get macValLabel;

  /// Mnfr Label
  ///
  /// In en, this message translates to:
  /// **'MNFR'**
  String get mnfrLabel;

  /// Hidden Network
  ///
  /// In en, this message translates to:
  /// **'Hidden Network'**
  String get hiddenNetwork;

  /// Signal Graph
  ///
  /// In en, this message translates to:
  /// **'Signal Graph'**
  String get signalGraph;

  /// Risk Factors
  ///
  /// In en, this message translates to:
  /// **'Risk Factors'**
  String get riskFactors;

  /// Vulnerabilities
  ///
  /// In en, this message translates to:
  /// **'Vulnerabilities'**
  String get vulnerabilities;

  /// Bss Id
  ///
  /// In en, this message translates to:
  /// **'BSSID'**
  String get bssId;

  /// Channel
  ///
  /// In en, this message translates to:
  /// **'Channel'**
  String get channel;

  /// Security
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// Signal
  ///
  /// In en, this message translates to:
  /// **'Signal'**
  String get signal;

  /// Recommendation Label
  ///
  /// In en, this message translates to:
  /// **'RECO: {text}'**
  String recommendationLabel(String text);

  /// No Vulnerabilities
  ///
  /// In en, this message translates to:
  /// **'No vulnerabilities detected.'**
  String get noVulnerabilities;

  /// Security Score Title
  ///
  /// In en, this message translates to:
  /// **'Security Score'**
  String get securityScoreTitle;

  /// Security Score Desc
  ///
  /// In en, this message translates to:
  /// **'The security score (0–100) rates how well this network is protected. Higher is better. It considers encryption type, WPS status, and other security features.'**
  String get securityScoreDesc;

  /// Capabilities Label
  ///
  /// In en, this message translates to:
  /// **'CAPABILITIES'**
  String get capabilitiesLabel;

  /// Wifi7 Mld Label
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi 7 MLD'**
  String get wifi7MldLabel;

  /// Tag Wpa3 Desc
  ///
  /// In en, this message translates to:
  /// **'WPA3 is the latest Wi-Fi security standard — highly secure.'**
  String get tagWpa3Desc;

  /// Tag Wpa2 Desc
  ///
  /// In en, this message translates to:
  /// **'WPA2 is a strong security standard — safe for everyday use.'**
  String get tagWpa2Desc;

  /// Tag Wpa Desc
  ///
  /// In en, this message translates to:
  /// **'WPA is an older security standard with known weaknesses.'**
  String get tagWpaDesc;

  /// Tag Wps Desc
  ///
  /// In en, this message translates to:
  /// **'WPS (Wi-Fi Protected Setup) has known security vulnerabilities. It can allow attackers to brute-force the PIN and gain access.'**
  String get tagWpsDesc;

  /// Tag Pmf Desc
  ///
  /// In en, this message translates to:
  /// **'Protected Management Frames (PMF/MFP) protects against deauthentication attacks.'**
  String get tagPmfDesc;

  /// Tag Ess Desc
  ///
  /// In en, this message translates to:
  /// **'ESS (Extended Service Set) means this is a standard access point network.'**
  String get tagEssDesc;

  /// Tag Ccmp Desc
  ///
  /// In en, this message translates to:
  /// **'CCMP (AES) is a strong encryption cipher used with WPA2/WPA3.'**
  String get tagCcmpDesc;

  /// Tag Tkip Desc
  ///
  /// In en, this message translates to:
  /// **'TKIP is an older, weaker encryption cipher. CCMP/AES is preferred.'**
  String get tagTkipDesc;

  /// Tag Unknown Desc
  ///
  /// In en, this message translates to:
  /// **'Network capability flag from the beacon frame.'**
  String get tagUnknownDesc;

  /// Scan Profile Label
  ///
  /// In en, this message translates to:
  /// **'SCAN PROFILE'**
  String get scanProfileLabel;

  /// Info Scan Profiles Title
  ///
  /// In en, this message translates to:
  /// **'Scan Profiles'**
  String get infoScanProfilesTitle;

  /// Info Scan Profile Fast Desc
  ///
  /// In en, this message translates to:
  /// **'Fast: Quick ping sweep — finds devices in seconds.'**
  String get infoScanProfileFastDesc;

  /// Info Scan Profile Balanced Desc
  ///
  /// In en, this message translates to:
  /// **'Balanced: Ping + common ports — finds more detail.'**
  String get infoScanProfileBalancedDesc;

  /// Info Scan Profile Aggressive Desc
  ///
  /// In en, this message translates to:
  /// **'Aggressive: Full port scan — most thorough but slowest.'**
  String get infoScanProfileAggressiveDesc;

  /// Active Node Recon
  ///
  /// In en, this message translates to:
  /// **'ACTIVE NODE RECONNAISSANCE'**
  String get activeNodeRecon;

  /// Interrogating Subnet
  ///
  /// In en, this message translates to:
  /// **'Interrogating subnet for responsive hosts...'**
  String get interrogatingSubnet;

  /// Nodes Label
  ///
  /// In en, this message translates to:
  /// **'Nodes'**
  String get nodesLabel;

  /// Risk Avg Label
  ///
  /// In en, this message translates to:
  /// **'Risk Avg'**
  String get riskAvgLabel;

  /// Services Label
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get servicesLabel;

  /// Open Ports Label
  ///
  /// In en, this message translates to:
  /// **'OPEN PORTS'**
  String get openPortsLabel;

  /// Subnet Label
  ///
  /// In en, this message translates to:
  /// **'Subnet'**
  String get subnetLabel;

  /// Cidr Target Label
  ///
  /// In en, this message translates to:
  /// **'CIDR TARGET'**
  String get cidrTargetLabel;

  /// Anonymous Node
  ///
  /// In en, this message translates to:
  /// **'ANONYMOUS NODE'**
  String get anonymousNode;

  /// Ports Count Label
  ///
  /// In en, this message translates to:
  /// **'{count} PORTS'**
  String portsCountLabel(int count);

  /// Risk Label
  ///
  /// In en, this message translates to:
  /// **'RISK'**
  String get riskLabel;

  /// Search Lan Placeholder
  ///
  /// In en, this message translates to:
  /// **'Search by IP, hostname, or vendor...'**
  String get searchLanPlaceholder;

  /// Has Vulnerabilities Label
  ///
  /// In en, this message translates to:
  /// **'Has Vulnerabilities'**
  String get hasVulnerabilitiesLabel;

  /// Security Status Secure
  ///
  /// In en, this message translates to:
  /// **'Secure'**
  String get securityStatusSecure;

  /// Security Status Moderate
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get securityStatusModerate;

  /// Security Status At Risk
  ///
  /// In en, this message translates to:
  /// **'At Risk'**
  String get securityStatusAtRisk;

  /// Security Status Critical
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get securityStatusCritical;

  /// Security Summary Secure
  ///
  /// In en, this message translates to:
  /// **'Your connection looks good! This network uses strong encryption and is well protected against common attacks.'**
  String get securitySummarySecure;

  /// Security Summary Moderate
  ///
  /// In en, this message translates to:
  /// **'This network has decent security but some potential weaknesses. It is safe for everyday use, but avoid sensitive transactions.'**
  String get securitySummaryModerate;

  /// Security Summary At Risk
  ///
  /// In en, this message translates to:
  /// **'This network has security issues that put your data at risk. Avoid entering passwords or personal information while connected.'**
  String get securitySummaryAtRisk;

  /// Security Summary Critical
  ///
  /// In en, this message translates to:
  /// **'Warning: This network is not secure. Anyone nearby may be able to see your internet traffic. Use a VPN or switch networks.'**
  String get securitySummaryCritical;

  /// Vulnerability Open Network Title
  ///
  /// In en, this message translates to:
  /// **'Open Network'**
  String get vulnerabilityOpenNetworkTitle;

  /// Vulnerability Open Network Desc
  ///
  /// In en, this message translates to:
  /// **'No encryption detected. All traffic can be sniffed in plaintext.'**
  String get vulnerabilityOpenNetworkDesc;

  /// Vulnerability Open Network Rec
  ///
  /// In en, this message translates to:
  /// **'Avoid sensitive activity. Prefer trusted VPN or different network.'**
  String get vulnerabilityOpenNetworkRec;

  /// Vulnerability Wep Title
  ///
  /// In en, this message translates to:
  /// **'WEP Encryption'**
  String get vulnerabilityWepTitle;

  /// Vulnerability Wep Desc
  ///
  /// In en, this message translates to:
  /// **'WEP is deprecated and can be cracked quickly.'**
  String get vulnerabilityWepDesc;

  /// Vulnerability Wep Rec
  ///
  /// In en, this message translates to:
  /// **'Reconfigure AP to WPA2 or WPA3 immediately.'**
  String get vulnerabilityWepRec;

  /// Vulnerability Legacy Wpa Title
  ///
  /// In en, this message translates to:
  /// **'Legacy WPA'**
  String get vulnerabilityLegacyWpaTitle;

  /// Vulnerability Legacy Wpa Desc
  ///
  /// In en, this message translates to:
  /// **'WPA/TKIP is older and weaker against modern attack techniques.'**
  String get vulnerabilityLegacyWpaDesc;

  /// Vulnerability Legacy Wpa Rec
  ///
  /// In en, this message translates to:
  /// **'Upgrade AP and clients to WPA2/WPA3.'**
  String get vulnerabilityLegacyWpaRec;

  /// Vulnerability Hidden Ssid Title
  ///
  /// In en, this message translates to:
  /// **'Hidden SSID'**
  String get vulnerabilityHiddenSsidTitle;

  /// Vulnerability Hidden Ssid Desc
  ///
  /// In en, this message translates to:
  /// **'Hidden SSIDs are still discoverable and may hurt compatibility.'**
  String get vulnerabilityHiddenSsidDesc;

  /// Vulnerability Hidden Ssid Rec
  ///
  /// In en, this message translates to:
  /// **'Hidden SSID alone is not protection. Focus on strong encryption.'**
  String get vulnerabilityHiddenSsidRec;

  /// Vulnerability Weak Signal Title
  ///
  /// In en, this message translates to:
  /// **'Very Weak Signal'**
  String get vulnerabilityWeakSignalTitle;

  /// Vulnerability Weak Signal Desc
  ///
  /// In en, this message translates to:
  /// **'Weak signal can indicate unstable links and spoofing susceptibility.'**
  String get vulnerabilityWeakSignalDesc;

  /// Vulnerability Weak Signal Rec
  ///
  /// In en, this message translates to:
  /// **'Move closer to AP or validate BSSID consistency.'**
  String get vulnerabilityWeakSignalRec;

  /// Vulnerability Wps Title
  ///
  /// In en, this message translates to:
  /// **'WPS Enabled'**
  String get vulnerabilityWpsTitle;

  /// Vulnerability Wps Desc
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi Protected Setup (WPS) is enabled. The WPS PIN mode can be brute-forced in hours using Pixie Dust attack, effectively bypassing any password.'**
  String get vulnerabilityWpsDesc;

  /// Vulnerability Wps Rec
  ///
  /// In en, this message translates to:
  /// **'Disable WPS in your router admin panel. Use WPA2/WPA3 passphrase only.'**
  String get vulnerabilityWpsRec;

  /// Vulnerability Pmf Title
  ///
  /// In en, this message translates to:
  /// **'Management Frames Unprotected'**
  String get vulnerabilityPmfTitle;

  /// Vulnerability Pmf Desc
  ///
  /// In en, this message translates to:
  /// **'This access point does not enforce Protected Management Frames (PMF / 802.11w). Unprotected management frames allow an attacker to forge deauthentication packets and disconnect clients.'**
  String get vulnerabilityPmfDesc;

  /// Vulnerability Pmf Rec
  ///
  /// In en, this message translates to:
  /// **'Enable PMF in router settings (often labelled \'802.11w\' or \'Management Frame Protection\'). WPA3 requires PMF by default.'**
  String get vulnerabilityPmfRec;

  /// Vulnerability Evil Twin Title
  ///
  /// In en, this message translates to:
  /// **'Potential Evil Twin'**
  String get vulnerabilityEvilTwinTitle;

  /// Vulnerability Evil Twin Desc
  ///
  /// In en, this message translates to:
  /// **'SSID appears with conflicting security/channel fingerprint nearby.'**
  String get vulnerabilityEvilTwinDesc;

  /// Vulnerability Evil Twin Rec
  ///
  /// In en, this message translates to:
  /// **'Verify BSSID and certificate before authentication or data exchange.'**
  String get vulnerabilityEvilTwinRec;

  /// Risk Factor No Encryption
  ///
  /// In en, this message translates to:
  /// **'No encryption in use'**
  String get riskFactorNoEncryption;

  /// Risk Factor Deprecated Encryption
  ///
  /// In en, this message translates to:
  /// **'Deprecated encryption (WEP)'**
  String get riskFactorDeprecatedEncryption;

  /// Risk Factor Legacy Wpa
  ///
  /// In en, this message translates to:
  /// **'Legacy WPA in use'**
  String get riskFactorLegacyWpa;

  /// Risk Factor Hidden Ssid
  ///
  /// In en, this message translates to:
  /// **'Hidden SSID behavior'**
  String get riskFactorHiddenSsid;

  /// Risk Factor Weak Signal
  ///
  /// In en, this message translates to:
  /// **'Weak signal environment'**
  String get riskFactorWeakSignal;

  /// Risk Factor Wps Enabled
  ///
  /// In en, this message translates to:
  /// **'WPS PIN attack surface exposed'**
  String get riskFactorWpsEnabled;

  /// Risk Factor Pmf Not Enforced
  ///
  /// In en, this message translates to:
  /// **'PMF not enforced — deauth spoofing possible'**
  String get riskFactorPmfNotEnforced;

  /// Label for refresh button.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// Title for adding a zone point.
  ///
  /// In en, this message translates to:
  /// **'Add Zone Point'**
  String get addZonePoint;

  /// Label for cancel button.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Label for save button.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Text shown while waiting for data to load.
  ///
  /// In en, this message translates to:
  /// **'Waiting for data...'**
  String get waitingForData;

  /// Title for the temporal heatmap screen.
  ///
  /// In en, this message translates to:
  /// **'Temporal Heatmap'**
  String get temporalHeatmap;

  /// Failed To Save Heatmap Point
  ///
  /// In en, this message translates to:
  /// **'Failed to save heatmap point'**
  String get failedToSaveHeatmapPoint;

  /// Signal Monitoring Title
  ///
  /// In en, this message translates to:
  /// **'SIGNAL MONITORING: {ssid}'**
  String signalMonitoringTitle(String ssid);

  /// Heatmap Tooltip
  ///
  /// In en, this message translates to:
  /// **'Heatmap'**
  String get heatmapTooltip;

  /// Tag Current Point Tooltip
  ///
  /// In en, this message translates to:
  /// **'Tag current point'**
  String get tagCurrentPointTooltip;

  /// Signal Caps
  ///
  /// In en, this message translates to:
  /// **'SIGNAL'**
  String get signalCaps;

  /// Channel Caps
  ///
  /// In en, this message translates to:
  /// **'CHANNEL'**
  String get channelCaps;

  /// Frequency Caps
  ///
  /// In en, this message translates to:
  /// **'FREQ'**
  String get frequencyCaps;

  /// Heatmap Point Added
  ///
  /// In en, this message translates to:
  /// **'Heatmap point added for {zone}'**
  String heatmapPointAdded(String zone);

  /// Zone Tag Label
  ///
  /// In en, this message translates to:
  /// **'Zone tag (e.g. Kitchen)'**
  String get zoneTagLabel;

  /// Error Prefix
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorPrefix(String message);

  /// No Heatmap Points Yet
  ///
  /// In en, this message translates to:
  /// **'No heatmap points yet for {bssid}'**
  String noHeatmapPointsYet(String bssid);

  /// Average Signal By Zone
  ///
  /// In en, this message translates to:
  /// **'Average signal by zone'**
  String get averageSignalByZone;

  /// Band Channels
  ///
  /// In en, this message translates to:
  /// **'{band} CHANNELS'**
  String bandChannels(String band);

  /// Recommended Channel
  ///
  /// In en, this message translates to:
  /// **'RECOMMENDED CHANNEL'**
  String get recommendedChannel;

  /// Channel Info
  ///
  /// In en, this message translates to:
  /// **'Channel {ch} · {freq} MHz'**
  String channelInfo(int ch, int freq);

  /// Risk Factor Fingerprint Drift
  ///
  /// In en, this message translates to:
  /// **'SSID fingerprint drift detected'**
  String get riskFactorFingerprintDrift;

  /// History Caps
  ///
  /// In en, this message translates to:
  /// **'HISTORY'**
  String get historyCaps;

  /// Consistently Best Channel
  ///
  /// In en, this message translates to:
  /// **'CONSISTENTLY BEST CHANNEL'**
  String get consistentlyBestChannel;

  /// Avg Score
  ///
  /// In en, this message translates to:
  /// **'Avg Score'**
  String get avgScore;

  /// Channel Bonding Title
  ///
  /// In en, this message translates to:
  /// **'Channel Bonding'**
  String get channelBondingTitle;

  /// Channel Bonding Desc
  ///
  /// In en, this message translates to:
  /// **'Channel bonding combines 2 or more adjacent channels to increase bandwidth (40 MHz = 2×, 80 MHz = 4×, 160 MHz = 8×). Wider channels deliver faster speeds but may interfere with more neighboring networks.'**
  String get channelBondingDesc;

  /// Spectrum Optimization Caps
  ///
  /// In en, this message translates to:
  /// **'SPECTRUM OPTIMIZATION'**
  String get spectrumOptimizationCaps;

  /// Spectrum Optimization Desc
  ///
  /// In en, this message translates to:
  /// **'Analyze channel congestion & interference'**
  String get spectrumOptimizationDesc;

  /// Quality Excellent
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get qualityExcellent;

  /// Quality Very Good
  ///
  /// In en, this message translates to:
  /// **'Very Good'**
  String get qualityVeryGood;

  /// Quality Good
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get qualityGood;

  /// Quality Fair
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get qualityFair;

  /// Quality Congested
  ///
  /// In en, this message translates to:
  /// **'Congested'**
  String get qualityCongested;

  /// Channel Bonding Header
  ///
  /// In en, this message translates to:
  /// **'CHANNEL BONDING ({count} APs)'**
  String channelBondingHeader(int count);

  /// Hidden Ssid Label
  ///
  /// In en, this message translates to:
  /// **'[Hidden]'**
  String get hiddenSsidLabel;

  /// No History Placeholder
  ///
  /// In en, this message translates to:
  /// **'No history yet.\nChannel ratings are recorded each time you open this screen.'**
  String get noHistoryPlaceholder;

  /// Current Session Info
  ///
  /// In en, this message translates to:
  /// **'Current session — higher score = less congested.'**
  String get currentSessionInfo;

  /// History Summary Info
  ///
  /// In en, this message translates to:
  /// **'{sessions} sessions · {samples} samples · higher = less congested'**
  String historySummaryInfo(int sessions, int samples);

  /// Scan Report Title
  ///
  /// In en, this message translates to:
  /// **'Torcav Wi-Fi Scan Report'**
  String get scanReportTitle;

  /// Report Time
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get reportTime;

  /// Ssid Header
  ///
  /// In en, this message translates to:
  /// **'SSID'**
  String get ssidHeader;

  /// Bssid Header
  ///
  /// In en, this message translates to:
  /// **'BSSID'**
  String get bssidHeader;

  /// Dbm Header
  ///
  /// In en, this message translates to:
  /// **'dBm'**
  String get dbmHeader;

  /// Channel Header
  ///
  /// In en, this message translates to:
  /// **'CH'**
  String get channelHeader;

  /// Nav Dashboard
  ///
  /// In en, this message translates to:
  /// **'DASHBOARD'**
  String get navDashboard;

  /// Nav Discovery
  ///
  /// In en, this message translates to:
  /// **'DISCOVERY'**
  String get navDiscovery;

  /// Nav Operations
  ///
  /// In en, this message translates to:
  /// **'OPERATIONS'**
  String get navOperations;

  /// Nav Lan
  ///
  /// In en, this message translates to:
  /// **'LAN'**
  String get navLan;

  /// System Status
  ///
  /// In en, this message translates to:
  /// **'System Status'**
  String get systemStatus;

  /// Interface Theme
  ///
  /// In en, this message translates to:
  /// **'Interface Theme'**
  String get interfaceTheme;

  /// Speed Test Header
  ///
  /// In en, this message translates to:
  /// **'SPEED TEST'**
  String get speedTestHeader;

  /// Start Test
  ///
  /// In en, this message translates to:
  /// **'START TEST'**
  String get startTest;

  /// Test Again
  ///
  /// In en, this message translates to:
  /// **'TEST AGAIN'**
  String get testAgain;

  /// Command Centers
  ///
  /// In en, this message translates to:
  /// **'COMMAND CENTERS'**
  String get commandCenters;

  /// Active Shielding
  ///
  /// In en, this message translates to:
  /// **'Active Shielding'**
  String get activeShielding;

  /// Logistics Title
  ///
  /// In en, this message translates to:
  /// **'LOGISTICS'**
  String get logisticsTitle;

  /// Intel Metrics
  ///
  /// In en, this message translates to:
  /// **'Intel Metrics'**
  String get intelMetrics;

  /// Network Mesh
  ///
  /// In en, this message translates to:
  /// **'Network Mesh'**
  String get networkMesh;

  /// Tuning Title
  ///
  /// In en, this message translates to:
  /// **'TUNING'**
  String get tuningTitle;

  /// System Config
  ///
  /// In en, this message translates to:
  /// **'System Config'**
  String get systemConfig;

  /// Phase Ping
  ///
  /// In en, this message translates to:
  /// **'PHASE: PING'**
  String get phasePing;

  /// Phase Download
  ///
  /// In en, this message translates to:
  /// **'PHASE: DOWNLOAD'**
  String get phaseDownload;

  /// Phase Upload
  ///
  /// In en, this message translates to:
  /// **'PHASE: UPLOAD'**
  String get phaseUpload;

  /// Phase Done
  ///
  /// In en, this message translates to:
  /// **'PHASE: DONE'**
  String get phaseDone;

  /// Risk Score
  ///
  /// In en, this message translates to:
  /// **'Risk Score'**
  String get riskScore;

  /// Loading
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Profile Title
  ///
  /// In en, this message translates to:
  /// **'PROFILE HUB'**
  String get profileTitle;

  /// Active Session Label
  ///
  /// In en, this message translates to:
  /// **'Active Session'**
  String get activeSessionLabel;

  /// Network Status Label
  ///
  /// In en, this message translates to:
  /// **'NETWORK STATUS'**
  String get networkStatusLabel;

  /// Ssid
  ///
  /// In en, this message translates to:
  /// **'SSID'**
  String get ssid;

  /// Last Scan Title
  ///
  /// In en, this message translates to:
  /// **'LAST SCAN'**
  String get lastScanTitle;

  /// Last Snapshot
  ///
  /// In en, this message translates to:
  /// **'Last Snapshot'**
  String get lastSnapshot;
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
