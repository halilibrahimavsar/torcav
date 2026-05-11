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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
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
    Locale('tr'),
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

  /// Title for the experimental deep scan toggle in Security Center.
  ///
  /// In en, this message translates to:
  /// **'Deep Scan (Experimental)'**
  String get deepScanExperimentalTitle;

  /// Subtitle for the experimental deep scan toggle in Security Center.
  ///
  /// In en, this message translates to:
  /// **'Actively probe LAN for devices and ports. Increased battery usage.'**
  String get deepScanExperimentalSubtitle;

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

  /// No description provided for @networksCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{no networks} =1{1 network} other{{count} networks}}'**
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

  /// Live indicator label
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get liveLabel;

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

  /// No description provided for @noSnapshotAvailable.
  ///
  /// In en, this message translates to:
  /// **'No scan snapshot is available yet. Run a Wi-Fi scan first.'**
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

  /// Text shown during wifi scan instead of broadcasting probes.
  ///
  /// In en, this message translates to:
  /// **'Analyzing local signal environment...'**
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

  /// Status text when threats are detected
  ///
  /// In en, this message translates to:
  /// **'THREATS DETECTED'**
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

  /// Title for the topology information sheet
  ///
  /// In en, this message translates to:
  /// **'TOPOLOGY GUIDE'**
  String get topologyGuideTitle;

  /// Description for the topology information sheet
  ///
  /// In en, this message translates to:
  /// **'Understand your network structure and device connectivity.'**
  String get topologyGuideDesc;

  /// Gateway title
  ///
  /// In en, this message translates to:
  /// **'The Gateway'**
  String get gatewayTitle;

  /// Gateway description
  ///
  /// In en, this message translates to:
  /// **'The central brain of your network. All external traffic flows through this node.'**
  String get gatewayDesc;

  /// Device layers title
  ///
  /// In en, this message translates to:
  /// **'Device Layers'**
  String get deviceLayersTitle;

  /// Device layers description
  ///
  /// In en, this message translates to:
  /// **'Devices are categorized by their role: Core (Routers/APs), Mobile, and IoT/Peripheral.'**
  String get deviceLayersDesc;

  /// Pathways title
  ///
  /// In en, this message translates to:
  /// **'Pathways'**
  String get pathwaysTitle;

  /// Pathways description
  ///
  /// In en, this message translates to:
  /// **'Modern networks mix wired (Ethernet) and wireless (Wi-Fi) connections. Solid lines indicate high-speed wired links, while dashed lines show wireless segments.'**
  String get pathwaysDesc;

  /// Action to ping a device
  ///
  /// In en, this message translates to:
  /// **'TEST LATENCY'**
  String get pingAction;

  /// Ping success message
  ///
  /// In en, this message translates to:
  /// **'Latency: {ms}ms'**
  String pingSuccess(int ms);

  /// Ping failure message
  ///
  /// In en, this message translates to:
  /// **'Host Unreachable'**
  String get pingFailure;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
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

  /// Label for the background selection setting.
  ///
  /// In en, this message translates to:
  /// **'Background Style'**
  String get settingsBackgroundStyle;

  /// Label for the new shader-based background.
  ///
  /// In en, this message translates to:
  /// **'Neomorphic (High Performance)'**
  String get backgroundNeomorphic;

  /// Label for the original particle grid background.
  ///
  /// In en, this message translates to:
  /// **'Classic Grid'**
  String get backgroundClassic;

  /// Label for the aurora mesh shader background.
  ///
  /// In en, this message translates to:
  /// **'Aurora Mesh (Experimental)'**
  String get backgroundAuroraMesh;

  /// Label for the holographic sphere background.
  ///
  /// In en, this message translates to:
  /// **'Holographic Sphere (3D)'**
  String get backgroundHoloSphere;

  /// Label for the neural pulse background.
  ///
  /// In en, this message translates to:
  /// **'Neural Pulse (Animated)'**
  String get backgroundNeuralPulse;

  /// Info message explaining why background selection is disabled in light mode.
  ///
  /// In en, this message translates to:
  /// **'Cyber grid styles are optimized for dark mode and only available when using the dark theme.'**
  String get backgroundSelectionRestricted;

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

  /// Label for the AI device classification toggle.
  ///
  /// In en, this message translates to:
  /// **'AI Device Classification'**
  String get settingsAiClassification;

  /// Description for the AI device classification toggle.
  ///
  /// In en, this message translates to:
  /// **'Enables local AI-powered device detection and identification.'**
  String get settingsAiClassificationDesc;

  /// Label for the AI badge in device list.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get aiBadgeLabel;

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
  /// **'SECURITY CENTER'**
  String get defenseTitle;

  /// Shield Lab Ready
  ///
  /// In en, this message translates to:
  /// **'Ready for Assessment'**
  String get shieldLabReady;

  /// Deep Scan Running
  ///
  /// In en, this message translates to:
  /// **'Scan in progress...'**
  String get deepScanRunning;

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

  /// No Identified Networks
  ///
  /// In en, this message translates to:
  /// **'No identified networks in laboratory archives'**
  String get noIdentifiedNetworks;

  /// Known Networks Dashboard
  ///
  /// In en, this message translates to:
  /// **'KNOWN NETWORKS ARCHIVE'**
  String get knownNetworksDashboard;

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

  /// Title for DNS Security card
  ///
  /// In en, this message translates to:
  /// **'DNS INTEGRITY'**
  String get dnsSecurityTitle;

  /// Body for DNS Security card
  ///
  /// In en, this message translates to:
  /// **'Verify that your DNS queries are not being hijacked or spoofed.'**
  String get dnsSecurityBody;

  /// DNS Integrity status label
  ///
  /// In en, this message translates to:
  /// **'DNS INTEGRITY'**
  String get dnsIntegrity;

  /// Section title for DNS benchmark
  ///
  /// In en, this message translates to:
  /// **'PERFORMANCE BENCHMARK'**
  String get dnsPerformanceBenchmark;

  /// Label for latency
  ///
  /// In en, this message translates to:
  /// **'LATENCY'**
  String get dnsLatency;

  /// Badge for recommended provider
  ///
  /// In en, this message translates to:
  /// **'RECOMMENDED'**
  String get dnsRecommended;

  /// Label for fastest provider
  ///
  /// In en, this message translates to:
  /// **'FASTEST'**
  String get dnsFastest;

  /// Provider column header
  ///
  /// In en, this message translates to:
  /// **'PROVIDER'**
  String get dnsProvider;

  /// Formatted latency value
  ///
  /// In en, this message translates to:
  /// **'{ms} ms'**
  String dnsResultLatency(int ms);

  /// Label for run test button
  ///
  /// In en, this message translates to:
  /// **'RUN TEST'**
  String get runTest;

  /// Label for integrity check
  ///
  /// In en, this message translates to:
  /// **'INTEGRITY CHECK'**
  String get integrityCheck;

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

  /// Label for the log ID in security timeline.
  ///
  /// In en, this message translates to:
  /// **'LOG_ID: {id}'**
  String logIdLabel(String id);

  /// Label for the target SSID in security timeline.
  ///
  /// In en, this message translates to:
  /// **'TARGET: {target}'**
  String targetLabel(String target);

  /// Label for pending DNS status.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get dnsStatusPending;

  /// Label for not assessed DNS status.
  ///
  /// In en, this message translates to:
  /// **'NOT ASSESSED'**
  String get dnsStatusNotAssessed;

  /// Label for inconsistent DNS status.
  ///
  /// In en, this message translates to:
  /// **'INCONSISTENT'**
  String get dnsStatusInconsistent;

  /// Label for enabled status.
  ///
  /// In en, this message translates to:
  /// **'ENABLED'**
  String get dnsStatusEnabled;

  /// Label for disabled status.
  ///
  /// In en, this message translates to:
  /// **'DISABLED'**
  String get dnsStatusDisabled;

  /// N/A in capital letters.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notAvailableCaps;

  /// No description provided for @evilTwinSignalOuiMismatch.
  ///
  /// In en, this message translates to:
  /// **'The two access points come from different hardware vendors (MAC prefixes don\'t match).'**
  String get evilTwinSignalOuiMismatch;

  /// No description provided for @evilTwinSignalSecurityDowngrade.
  ///
  /// In en, this message translates to:
  /// **'The pair advertises different encryption — typical of a downgrade attack (e.g. real network = WPA3, fake = WPA2 or Open).'**
  String get evilTwinSignalSecurityDowngrade;

  /// No description provided for @evilTwinSignalSameBandChannelDrift.
  ///
  /// In en, this message translates to:
  /// **'Both broadcast on the same frequency band but on very different channels — real radios rarely jump that far.'**
  String get evilTwinSignalSameBandChannelDrift;

  /// No description provided for @evilTwinSignalChannelWidthMismatch.
  ///
  /// In en, this message translates to:
  /// **'They use different channel widths (e.g. 80 MHz vs 20 MHz). Cheap rogue hardware often runs narrower than the device it\'s copying.'**
  String get evilTwinSignalChannelWidthMismatch;

  /// No description provided for @evilTwinSignalWpsToggleMismatch.
  ///
  /// In en, this message translates to:
  /// **'WPS is enabled on one access point but not the other.'**
  String get evilTwinSignalWpsToggleMismatch;

  /// No description provided for @evilTwinSignalPmfToggleMismatch.
  ///
  /// In en, this message translates to:
  /// **'Protected Management Frames (802.11w) are enabled on one side but not the other.'**
  String get evilTwinSignalPmfToggleMismatch;

  /// No description provided for @evilTwinSignalHiddenVsVisible.
  ///
  /// In en, this message translates to:
  /// **'One access point is hidden, the other broadcasts its name openly.'**
  String get evilTwinSignalHiddenVsVisible;

  /// No description provided for @evilTwinSignalSharedMldMac.
  ///
  /// In en, this message translates to:
  /// **'Both share the same Wi-Fi 7 multi-link MAC — they are literally the same physical access point.'**
  String get evilTwinSignalSharedMldMac;

  /// No description provided for @evilTwinSignalBssidProximity.
  ///
  /// In en, this message translates to:
  /// **'Their MAC addresses differ only in the last digits — manufacturers use that pattern for radios on the same router.'**
  String get evilTwinSignalBssidProximity;

  /// No description provided for @evilTwinSignalCrossBandSibling.
  ///
  /// In en, this message translates to:
  /// **'They sit on different Wi-Fi bands (2.4 / 5 / 6 GHz) but share the same vendor and security — classic dual-band router pattern.'**
  String get evilTwinSignalCrossBandSibling;

  /// No description provided for @evilTwinSignalKnownMeshVendor.
  ///
  /// In en, this message translates to:
  /// **'Both MAC addresses belong to a known mesh-router family (Eero, Google Nest, Asus AiMesh, Netgear Orbi, TP-Link Deco, or Linksys Velop). Mesh nodes share the same Wi-Fi name on purpose.'**
  String get evilTwinSignalKnownMeshVendor;

  /// No description provided for @evilTwinSafeHeadline.
  ///
  /// In en, this message translates to:
  /// **'Looks like the same router on different bands'**
  String get evilTwinSafeHeadline;

  /// No description provided for @evilTwinSafeWhatIs.
  ///
  /// In en, this message translates to:
  /// **'Most home routers broadcast the same Wi-Fi name (SSID) over 2.4 GHz, 5 GHz and sometimes 6 GHz. Your phone sees them as separate access points even though they\'re one device. Mesh systems work the same way — every node uses one shared name.'**
  String get evilTwinSafeWhatIs;

  /// No description provided for @evilTwinSafeWhyItMatters.
  ///
  /// In en, this message translates to:
  /// **'This pairing is normal and expected — no action needed. We show this here only so you know we checked and ruled it out.'**
  String get evilTwinSafeWhyItMatters;

  /// No description provided for @evilTwinSafeAction.
  ///
  /// In en, this message translates to:
  /// **'Nothing to do. This is the same router or part of your mesh.'**
  String get evilTwinSafeAction;

  /// No description provided for @evilTwinSafePhrase.
  ///
  /// In en, this message translates to:
  /// **'We checked this pair and it matches the pattern of a normal dual-band router or mesh — not an attack.'**
  String get evilTwinSafePhrase;

  /// No description provided for @evilTwinNoPatternHeadline.
  ///
  /// In en, this message translates to:
  /// **'No evil-twin pattern detected'**
  String get evilTwinNoPatternHeadline;

  /// No description provided for @evilTwinNoPatternAction.
  ///
  /// In en, this message translates to:
  /// **'Nothing urgent. Re-run a scan if you suspect something has changed in your environment.'**
  String get evilTwinNoPatternAction;

  /// No description provided for @evilTwinNoPatternPhrase.
  ///
  /// In en, this message translates to:
  /// **'Some minor differences exist between the access points sharing this name, but not enough to look like an attack.'**
  String get evilTwinNoPatternPhrase;

  /// No description provided for @evilTwinWhatIs.
  ///
  /// In en, this message translates to:
  /// **'An \"evil twin\" is a fake Wi-Fi network that copies the name of a real one — usually your home or workplace network, or a popular café hotspot. The goal is to make your phone connect to the attacker\'s router instead of the real one.'**
  String get evilTwinWhatIs;

  /// No description provided for @evilTwinWhyItMatters.
  ///
  /// In en, this message translates to:
  /// **'Once your device is on the attacker\'s Wi-Fi, they can read or tamper with traffic that isn\'t encrypted, push fake login pages, redirect you to look-alike websites, or capture passwords typed into apps that don\'t use HTTPS properly. Banking, email and messaging are the usual targets.'**
  String get evilTwinWhyItMatters;

  /// No description provided for @evilTwinHighHeadline.
  ///
  /// In en, this message translates to:
  /// **'Strong evil-twin pattern — treat this network as untrusted'**
  String get evilTwinHighHeadline;

  /// No description provided for @evilTwinMediumHeadline.
  ///
  /// In en, this message translates to:
  /// **'Suspicious twin pattern — verify before connecting'**
  String get evilTwinMediumHeadline;

  /// No description provided for @evilTwinLowHeadline.
  ///
  /// In en, this message translates to:
  /// **'Weak twin signal — keep an eye on this'**
  String get evilTwinLowHeadline;

  /// No description provided for @evilTwinHighPhrase.
  ///
  /// In en, this message translates to:
  /// **'Confidence: {pct}%. Multiple strong mismatches between the two access points using this name. This is the pattern an attacker creates when impersonating a Wi-Fi.'**
  String evilTwinHighPhrase(int pct);

  /// No description provided for @evilTwinMediumPhrase.
  ///
  /// In en, this message translates to:
  /// **'Confidence: {pct}%. Several details don\'t line up between the access points sharing this name. It might be benign, but verify before trusting it.'**
  String evilTwinMediumPhrase(int pct);

  /// No description provided for @evilTwinLowPhrase.
  ///
  /// In en, this message translates to:
  /// **'Confidence: {pct}%. A couple of small mismatches noticed. Most likely benign — flagged so you can double-check.'**
  String evilTwinLowPhrase(int pct);

  /// No description provided for @evilTwinActionPasswords.
  ///
  /// In en, this message translates to:
  /// **'Don\'t enter passwords, payment details, or two-factor codes while connected to this Wi-Fi.'**
  String get evilTwinActionPasswords;

  /// No description provided for @evilTwinActionCheckMac.
  ///
  /// In en, this message translates to:
  /// **'If you\'re at home, check the actual MAC (BSSID) printed under your router and compare it with the BSSIDs shown for this network.'**
  String get evilTwinActionCheckMac;

  /// No description provided for @evilTwinActionForgetNetwork.
  ///
  /// In en, this message translates to:
  /// **'Forget the network in your phone\'s Wi-Fi settings and only reconnect by hand to the BSSID you\'ve verified.'**
  String get evilTwinActionForgetNetwork;

  /// No description provided for @evilTwinActionSecurityDowngrade.
  ///
  /// In en, this message translates to:
  /// **'One of the two access points uses weaker encryption than the other. Always pick the stronger one (WPA3 over WPA2 over Open).'**
  String get evilTwinActionSecurityDowngrade;

  /// No description provided for @evilTwinActionDisconnectNow.
  ///
  /// In en, this message translates to:
  /// **'Disconnect from this Wi-Fi now and switch to mobile data until you can verify which BSSID is the real one.'**
  String get evilTwinActionDisconnectNow;

  /// No description provided for @evilTwinActionHardwareVendor.
  ///
  /// In en, this message translates to:
  /// **'The two routers come from different hardware vendors — your real router shouldn\'t suddenly change manufacturer.'**
  String get evilTwinActionHardwareVendor;

  /// No description provided for @evidenceDiscoveredDevices.
  ///
  /// In en, this message translates to:
  /// **'Discovered: {devices}'**
  String evidenceDiscoveredDevices(String devices);

  /// No description provided for @evidenceVulnerablePorts.
  ///
  /// In en, this message translates to:
  /// **'Host {host} has open ports that may be vulnerable.'**
  String evidenceVulnerablePorts(String host);

  /// No description provided for @evidenceNoEncryption.
  ///
  /// In en, this message translates to:
  /// **'The access point advertises no encryption for {network}.'**
  String evidenceNoEncryption(String network);

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

  /// Label for network security section
  ///
  /// In en, this message translates to:
  /// **'Network Security'**
  String get networkSecurity;

  /// Action to scan ports on a device
  ///
  /// In en, this message translates to:
  /// **'PORT SCAN'**
  String get portScanAction;

  /// Action to lookup hostname of a device
  ///
  /// In en, this message translates to:
  /// **'LOOKUP HOSTNAME'**
  String get hostnameLookupAction;

  /// Action to get ARP information for a device
  ///
  /// In en, this message translates to:
  /// **'ARP INFO'**
  String get arpInfoAction;

  /// Label for discovered open ports
  ///
  /// In en, this message translates to:
  /// **'OPEN PORTS'**
  String get portsFoundLabel;

  /// Message shown when no open ports were discovered
  ///
  /// In en, this message translates to:
  /// **'No open ports found'**
  String get noPortsFound;

  /// Label for common ports scanning mode
  ///
  /// In en, this message translates to:
  /// **'COMMON PORTS'**
  String get portScanCommonPorts;

  /// Label for custom port range scanning mode
  ///
  /// In en, this message translates to:
  /// **'CUSTOM RANGE'**
  String get portScanCustomRange;

  /// Label for all ports scanning mode
  ///
  /// In en, this message translates to:
  /// **'ALL PORTS'**
  String get portScanAllPorts;

  /// Warning message for full port scan
  ///
  /// In en, this message translates to:
  /// **'Scanning all 65,535 ports will take considerable time.'**
  String get portScanFullScanWarning;

  /// Label for start port input
  ///
  /// In en, this message translates to:
  /// **'START PORT'**
  String get portScanStartPort;

  /// Label for end port input
  ///
  /// In en, this message translates to:
  /// **'END PORT'**
  String get portScanEndPort;

  /// Error message for invalid port range
  ///
  /// In en, this message translates to:
  /// **'Invalid port range'**
  String get portScanInvalidRange;

  /// Warning for large port range
  ///
  /// In en, this message translates to:
  /// **'Scanning too many ports might be slow'**
  String get portScanTooManyPorts;

  /// Message shown while scanning ports
  ///
  /// In en, this message translates to:
  /// **'Searching for open ports. This may take a moment...'**
  String get portScanSearching;

  /// Port scanning in progress message.
  ///
  /// In en, this message translates to:
  /// **'Probing port {port}...'**
  String portScanProbing(int port);

  /// Message showing count of open services found
  ///
  /// In en, this message translates to:
  /// **'Found {count} open services so far.'**
  String portScanFoundCount(int count);

  /// Message shown when no ports have been scanned yet
  ///
  /// In en, this message translates to:
  /// **'No ports probed yet. Run a port scan to discover open services.'**
  String get portScanNoPortsProbed;

  /// Label for hostname result
  ///
  /// In en, this message translates to:
  /// **'HOSTNAME'**
  String get hostnameLabel;

  /// Label for ARP information
  ///
  /// In en, this message translates to:
  /// **'ARP DATA'**
  String get arpInfoLabel;

  /// Loading title for port scanning
  ///
  /// In en, this message translates to:
  /// **'SCANNING PORTS...'**
  String get scanningPortsTitle;

  /// Loading title for hostname lookup
  ///
  /// In en, this message translates to:
  /// **'LOOKING UP HOSTNAME...'**
  String get lookingUpHostnameTitle;

  /// Loading title for fetching ARP info
  ///
  /// In en, this message translates to:
  /// **'FETCHING ARP DATA...'**
  String get fetchingArpTitle;

  /// Hint for port range input field
  ///
  /// In en, this message translates to:
  /// **'Port range (e.g. 80,443 or 1-1000)'**
  String get portRangeHint;

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

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
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

  /// Risk factor for fingerprint drift
  ///
  /// In en, this message translates to:
  /// **'SSID fingerprint drift detected'**
  String get riskFactorFingerprintDrift;

  /// Risk factor for honeypot pattern
  ///
  /// In en, this message translates to:
  /// **'SSID matches known honeypot pattern'**
  String get riskFactorHoneypotPattern;

  /// Risk factor for missing 5 GHz band
  ///
  /// In en, this message translates to:
  /// **'No 5 GHz band detected'**
  String get riskFactorNo5Ghz;

  /// Risk factor for known hardware vulnerability
  ///
  /// In en, this message translates to:
  /// **'Known hardware vulnerability'**
  String get riskFactorKnownVulnerability;

  /// Risk factor for evil twin candidate
  ///
  /// In en, this message translates to:
  /// **'Evil twin candidate sharing this SSID'**
  String get riskFactorEvilTwinCandidate;

  /// Risk factor for channel congestion
  ///
  /// In en, this message translates to:
  /// **'Channel is heavily congested'**
  String get riskFactorChannelCongested;

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

  /// Explanation of channel interference
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi channels are like radio stations. When many networks share the same channel they slow each other down — like everyone talking at the same time. Switching to a less crowded channel can improve your speed and reliability.'**
  String get channelInterferenceDescription;

  /// Name of security event type
  ///
  /// In en, this message translates to:
  /// **'{type, select, rogueApSuspected{Rogue AP Suspected} deauthBurstDetected{Deauth Burst Detected} handshakeCaptureStarted{Handshake Protocol Analysis} handshakeCaptureCompleted{Handshake Protocol Secured} captivePortalDetected{Captive Portal Detected} evilTwinDetected{Evil Twin Detected} deauthAttackSuspected{Deauth Attack Suspected} encryptionDowngraded{Encryption Downgraded} arpSpoofingDetected{ARP Spoofing Detected} dnsHijackingDetected{DNS Hijacking Detected} unsupportedOperation{Unsupported Operation} other{{type}}}'**
  String securityEventType(String type);

  /// Name of security severity
  ///
  /// In en, this message translates to:
  /// **'{severity, select, low{Low} medium{Medium} info{Info} warning{Warning} high{High} critical{Critical} other{{severity}}}'**
  String securityEventSeverity(String severity);

  /// Evil twin evidence text
  ///
  /// In en, this message translates to:
  /// **'BSSID mismatch! Expected: {expected}, Found: {found}. High probability of an Evil Twin Access Point.'**
  String evilTwinEvidence(String expected, String found);

  /// Rogue AP evidence text
  ///
  /// In en, this message translates to:
  /// **'Randomized/LAA MAC detected on known network! This is highly unusual for legitimate Access Points and may indicate a rogue device.'**
  String get rogueApEvidence;

  /// Downgrade evidence text
  ///
  /// In en, this message translates to:
  /// **'Encryption profile changed from {oldSec} to {newSec}. Possible downgrade attack.'**
  String downgradeEvidence(String oldSec, String newSec);

  /// Label for showing all Wi-Fi bands in history filter.
  ///
  /// In en, this message translates to:
  /// **'ALL'**
  String get historyAllBands;

  /// Label for the best channel stat tile in history view.
  ///
  /// In en, this message translates to:
  /// **'BEST CHANNEL'**
  String get historyBestChannel;

  /// Label for the average rating stat tile in history view.
  ///
  /// In en, this message translates to:
  /// **'AVG RATING'**
  String get historyAvgRating;

  /// Label for the sessions count stat tile in history view.
  ///
  /// In en, this message translates to:
  /// **'SESSIONS'**
  String get historySessions;

  /// Tooltip for switching to line chart mode.
  ///
  /// In en, this message translates to:
  /// **'Line chart'**
  String get historyLineChart;

  /// Tooltip for switching to heatmap mode.
  ///
  /// In en, this message translates to:
  /// **'Heatmap'**
  String get historyHeatmap;

  /// Shown when history filters result in no data.
  ///
  /// In en, this message translates to:
  /// **'No data for selected filter.'**
  String get historyNoDataForFilter;

  /// Section header for channel ratings chart in history.
  ///
  /// In en, this message translates to:
  /// **'Channel Ratings'**
  String get historyChannelRatings;

  /// Title for the DNS security test card
  ///
  /// In en, this message translates to:
  /// **'DNS SECURITY TEST'**
  String get dnsSecurityTest;

  /// Status label for secure DNS
  ///
  /// In en, this message translates to:
  /// **'SECURE'**
  String get dnsSecure;

  /// Status label for DNS with warning
  ///
  /// In en, this message translates to:
  /// **'WARNING'**
  String get dnsWarning;

  /// Status label for DNS leak detected
  ///
  /// In en, this message translates to:
  /// **'LEAK DETECTED'**
  String get dnsLeakDetected;

  /// Status label for hijacked DNS
  ///
  /// In en, this message translates to:
  /// **'HIJACKED'**
  String get dnsHijacked;

  /// Prompt for verifying DNS integrity
  ///
  /// In en, this message translates to:
  /// **'Run a scan to verify DNS integrity'**
  String get dnsVerifyIntegrity;

  /// Last check time for DNS test
  ///
  /// In en, this message translates to:
  /// **'Last check: {hour}:{minute}'**
  String dnsLastCheck(String hour, String minute);

  /// Button label for running DNS test
  ///
  /// In en, this message translates to:
  /// **'TEST NOW'**
  String get dnsTestNow;

  /// Button label when DNS test is running
  ///
  /// In en, this message translates to:
  /// **'TESTING...'**
  String get dnsTesting;

  /// Label for current DNS server
  ///
  /// In en, this message translates to:
  /// **'CURRENT DNS'**
  String get dnsCurrentDns;

  /// Label for ISP provider in DNS test
  ///
  /// In en, this message translates to:
  /// **'ISP PROVIDER'**
  String get dnsIspProvider;

  /// Idle phase label
  ///
  /// In en, this message translates to:
  /// **'READY'**
  String get phaseIdle;

  /// Performance page title
  ///
  /// In en, this message translates to:
  /// **'SPEED TEST'**
  String get performanceTitle;

  /// Start speed test button
  ///
  /// In en, this message translates to:
  /// **'START TEST'**
  String get performanceStart;

  /// Retry speed test button
  ///
  /// In en, this message translates to:
  /// **'RUN AGAIN'**
  String get performanceRetry;

  /// No description provided for @latencyLabel.
  ///
  /// In en, this message translates to:
  /// **'LATENCY'**
  String get latencyLabel;

  /// Jitter stat label
  ///
  /// In en, this message translates to:
  /// **'JITTER'**
  String get jitterLabel;

  /// Interpretation section header
  ///
  /// In en, this message translates to:
  /// **'WHAT THIS MEANS'**
  String get whatThisMeans;

  /// Channel recommendation card header
  ///
  /// In en, this message translates to:
  /// **'CHANNEL RECOMMENDATION'**
  String get channelRecommendation;

  /// Channel switch recommendation
  ///
  /// In en, this message translates to:
  /// **'Switch to Channel {channel}'**
  String switchToChannel(int channel);

  /// Channel congestion hint
  ///
  /// In en, this message translates to:
  /// **'Your current channel is congested. Switching may improve speed.'**
  String get channelCongestionHint;

  /// Evil twin alert title
  ///
  /// In en, this message translates to:
  /// **'CRITICAL: EVIL TWIN DETECTED'**
  String get evilTwinAlertTitle;

  /// Evil twin alert body
  ///
  /// In en, this message translates to:
  /// **'A suspicious access point with a matching SSID but different security parameters has been identified.'**
  String get evilTwinAlertBody;

  /// WPS warning title
  ///
  /// In en, this message translates to:
  /// **'WPS VULNERABILITY DETECTED'**
  String get wpsWarningTitle;

  /// WPS warning body
  ///
  /// In en, this message translates to:
  /// **'One or more nearby networks have WPS active. This can be exploited to gain unauthorized access.'**
  String get wpsWarningBody;

  /// WPS affected networks count
  ///
  /// In en, this message translates to:
  /// **'{count} network(s) with WPS enabled'**
  String wpsAffectedNetworks(int count);

  /// No description provided for @heatmapTutorialTitle.
  ///
  /// In en, this message translates to:
  /// **'HOW TO READ THE HEATMAP'**
  String get heatmapTutorialTitle;

  /// No description provided for @heatmapTutorialStep1.
  ///
  /// In en, this message translates to:
  /// **'Start a new survey. The app collects signal samples automatically as you walk.'**
  String get heatmapTutorialStep1;

  /// No description provided for @heatmapTutorialStep2.
  ///
  /// In en, this message translates to:
  /// **'Walk each room and pass through corridor and corner transitions. That builds the survey trail.'**
  String get heatmapTutorialStep2;

  /// No description provided for @heatmapTutorialStep3.
  ///
  /// In en, this message translates to:
  /// **'If the outline is weak, switch to AR and face the walls. That pass is used to build the home plan.'**
  String get heatmapTutorialStep3;

  /// No description provided for @heatmapTutorialStep4.
  ///
  /// In en, this message translates to:
  /// **'Finish and open the result. The screen will then show the plan, signal, and weak zones together.'**
  String get heatmapTutorialStep4;

  /// Dismiss tutorial button
  ///
  /// In en, this message translates to:
  /// **'GOT IT'**
  String get gotIt;

  /// Speed test history section header
  ///
  /// In en, this message translates to:
  /// **'TEST HISTORY'**
  String get speedTestHistory;

  /// Empty speed test history
  ///
  /// In en, this message translates to:
  /// **'No tests recorded yet. Run your first test above.'**
  String get noSpeedTestHistory;

  /// Security score label on dashboard
  ///
  /// In en, this message translates to:
  /// **'NETWORK SCORE'**
  String get networkScoreLabel;

  /// Vulnerability Lab screen title
  ///
  /// In en, this message translates to:
  /// **'VULNERABILITY LAB'**
  String get vulnLabTitle;

  /// Vulnerability Lab subtitle
  ///
  /// In en, this message translates to:
  /// **'Run security tests against your connected network'**
  String get vulnLabSubtitle;

  /// Button to run all vulnerability tests
  ///
  /// In en, this message translates to:
  /// **'RUN ALL TESTS'**
  String get vulnLabRunAll;

  /// Shown while vulnerability tests are running
  ///
  /// In en, this message translates to:
  /// **'SCANNING...'**
  String get vulnLabRunning;

  /// Shown when no network is connected
  ///
  /// In en, this message translates to:
  /// **'Not connected to a Wi-Fi network. Connect first to run tests.'**
  String get vulnLabNoNetwork;

  /// Shown when no vulnerabilities are found
  ///
  /// In en, this message translates to:
  /// **'All tests passed. No vulnerabilities found on this network.'**
  String get vulnLabAllClear;

  /// Count of vulnerabilities found
  ///
  /// In en, this message translates to:
  /// **'{count} issue(s) found'**
  String vulnLabFoundCount(int count);

  /// Button to trust a network baseline
  ///
  /// In en, this message translates to:
  /// **'TRUST NETWORK'**
  String get trustNetwork;

  /// Button to remove a network from trusted profiles
  ///
  /// In en, this message translates to:
  /// **'UNTRUST NETWORK'**
  String get untrustNetwork;

  /// Badge for a network with an established trusted profile
  ///
  /// In en, this message translates to:
  /// **'TRUSTED BASELINES'**
  String get trustedBaselineBadge;

  /// Title for the DNS diagnostic evidence section
  ///
  /// In en, this message translates to:
  /// **'DNS EVIDENCE'**
  String get dnsEvidenceTitle;

  /// Experimental security testing and analysis title
  ///
  /// In en, this message translates to:
  /// **'SHIELD LABORATORY'**
  String get shieldLabTitle;

  /// Header for LAN devices discovery section
  ///
  /// In en, this message translates to:
  /// **'DISCOVERED DEVICES'**
  String get discoveredDevices;

  /// Header for open ports list
  ///
  /// In en, this message translates to:
  /// **'OPEN PORTS DETECTED'**
  String get openPortsFound;

  /// Badge for experimental features
  ///
  /// In en, this message translates to:
  /// **'EXPERIMENTAL'**
  String get experimentalFeature;

  /// Description for deep scan toggle
  ///
  /// In en, this message translates to:
  /// **'Active port scanning and LAN discovery (May trigger network alerts)'**
  String get deepScanDescription;

  /// Dns protocol
  ///
  /// In en, this message translates to:
  /// **'PROTOCOL'**
  String get dnsProtocol;

  /// Dns ssec
  ///
  /// In en, this message translates to:
  /// **'DNSSEC'**
  String get dnsSsec;

  /// Dns what is that
  ///
  /// In en, this message translates to:
  /// **'What is that?'**
  String get dnsWhatIsThat;

  /// Dns info hijacking title
  ///
  /// In en, this message translates to:
  /// **'DNS Hijacking'**
  String get dnsInfoHijackingTitle;

  /// Dns info hijacking desc
  ///
  /// In en, this message translates to:
  /// **'When your network provider or a malicious actor redirects your DNS queries to rogue servers. This allows them to monitor your activity or block certain websites.'**
  String get dnsInfoHijackingDesc;

  /// Dns info leak title
  ///
  /// In en, this message translates to:
  /// **'DNS Leak'**
  String get dnsInfoLeakTitle;

  /// Dns info leak desc
  ///
  /// In en, this message translates to:
  /// **'Even when using a VPN, your queries might bypass the secure tunnel and go to your ISP\'s servers. This \'leaks\' your browsing history to the network provider.'**
  String get dnsInfoLeakDesc;

  /// Dns info encrypted title
  ///
  /// In en, this message translates to:
  /// **'Encrypted DNS (DoH/DoT)'**
  String get dnsInfoEncryptedTitle;

  /// Dns info encrypted desc
  ///
  /// In en, this message translates to:
  /// **'DNS over HTTPS (DoH) and DNS over TLS (DoT) wrap your queries in an encrypted layer. This makes your requests unreadable to local snoopers and network admins.'**
  String get dnsInfoEncryptedDesc;

  /// Dns info dnssec title
  ///
  /// In en, this message translates to:
  /// **'DNSSEC'**
  String get dnsInfoDnssecTitle;

  /// Dns info dnssec desc
  ///
  /// In en, this message translates to:
  /// **'DNS Security Extensions add cryptographic signatures to your queries. This prevents \'spoofing\' where a server sends you fake IP addresses for legitimate sites.'**
  String get dnsInfoDnssecDesc;

  /// Dns info latency title
  ///
  /// In en, this message translates to:
  /// **'DNS Latency (RTT)'**
  String get dnsInfoLatencyTitle;

  /// Dns info latency desc
  ///
  /// In en, this message translates to:
  /// **'Round Trip Time (RTT) measures how long it takes for a query to travel to the server and back. Lower latency means faster web browsing and better performance.'**
  String get dnsInfoLatencyDesc;

  /// Dns info resolver drift title
  ///
  /// In en, this message translates to:
  /// **'DNS Resolver Drift'**
  String get dnsInfoResolverDriftTitle;

  /// Dns info resolver drift desc
  ///
  /// In en, this message translates to:
  /// **'Detected when your DNS requests are being handled by different providers than configured, possibly due to transparent proxying or routing changes.'**
  String get dnsInfoResolverDriftDesc;

  /// Net info ssid title
  ///
  /// In en, this message translates to:
  /// **'SSID (Service Set Identifier)'**
  String get netInfoSsidTitle;

  /// Net info ssid desc
  ///
  /// In en, this message translates to:
  /// **'The public name of your Wi-Fi network. While common, it can be spoofed by attackers to lure you into connecting to a rogue access point.'**
  String get netInfoSsidDesc;

  /// Net info bssid title
  ///
  /// In en, this message translates to:
  /// **'BSSID (Basic Service Set ID)'**
  String get netInfoBssidTitle;

  /// Net info bssid desc
  ///
  /// In en, this message translates to:
  /// **'The unique hardware address (MAC) of the wireless router. Useful for verifying that you are connected to the legitimate hardware and not a software clone.'**
  String get netInfoBssidDesc;

  /// Net info gateway title
  ///
  /// In en, this message translates to:
  /// **'Default Gateway'**
  String get netInfoGatewayTitle;

  /// Net info gateway desc
  ///
  /// In en, this message translates to:
  /// **'The local IP address of your router. All your traffic passes through this point. If this changes unexpectedly, it could indicate a Man-in-the-Middle attack.'**
  String get netInfoGatewayDesc;

  /// Dns ready status
  ///
  /// In en, this message translates to:
  /// **'READY FOR ASSESSMENT'**
  String get dnsReadyStatus;

  /// Dns idle description
  ///
  /// In en, this message translates to:
  /// **'Run a scan to verify DNS integrity and performance.'**
  String get dnsIdleDescription;

  /// Title for network security info
  ///
  /// In en, this message translates to:
  /// **'Network Security Module'**
  String get netSecInfoTitle;

  /// Description for network security info
  ///
  /// In en, this message translates to:
  /// **'Monitors the integrity of connected networks, detects rogue access points, and manages your trusted Wi-Fi profiles to protect against Evil Twin attacks.'**
  String get netSecInfoDesc;

  /// Operations Hub subtitle for the Spectrum Optimization card
  ///
  /// In en, this message translates to:
  /// **'Channel rating · interference'**
  String get spectrumOptimizationOpsSubtitle;

  /// Title of the about-spectrum expandable info panel
  ///
  /// In en, this message translates to:
  /// **'What is Spectrum Optimization?'**
  String get aboutSpectrumTitle;

  /// Header for the 'What is it' subsection
  ///
  /// In en, this message translates to:
  /// **'What is it?'**
  String get aboutSpectrumWhatHeader;

  /// Body for 'What is it' subsection
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi devices communicate over slices of the radio spectrum called channels. The 2.4 GHz band has only 3 truly non-overlapping channels (1, 6, 11) and is the most crowded. The 5 GHz band has many more channels and less interference. The newest 6 GHz band (Wi-Fi 6E/7) is almost empty in most homes.'**
  String get aboutSpectrumWhatBody;

  /// Header for the 'What it does' subsection
  ///
  /// In en, this message translates to:
  /// **'What is it for?'**
  String get aboutSpectrumWhyHeader;

  /// Body for 'What it does' subsection
  ///
  /// In en, this message translates to:
  /// **'When many networks share the same channel, they take turns talking, which slows everything down (Co-channel Interference). On 2.4 GHz, even nearby channels overlap and create static (Adjacent Channel Interference). Picking a quiet channel directly improves speed, latency and connection stability.'**
  String get aboutSpectrumWhyBody;

  /// Header for the 'How' subsection
  ///
  /// In en, this message translates to:
  /// **'How does it work?'**
  String get aboutSpectrumHowHeader;

  /// Body for 'How' subsection
  ///
  /// In en, this message translates to:
  /// **'This screen scans every Wi-Fi network within range, then scores each channel from 0 to 10 based on the number of competing networks, their signal strength and any overlap with neighbors. Pick a channel marked green (≥8): it is the least crowded right now. The History tab shows whether that channel stays clear over time.'**
  String get aboutSpectrumHowBody;

  /// Header above the per-band spectrum bar chart
  ///
  /// In en, this message translates to:
  /// **'Channel Spectrum'**
  String get bandSpectrumTitle;

  /// Title of the Channel Spectrum info sheet
  ///
  /// In en, this message translates to:
  /// **'Channel Spectrum'**
  String get bandSpectrumInfoTitle;

  /// Body of the Channel Spectrum info sheet
  ///
  /// In en, this message translates to:
  /// **'Each bar is one channel. Taller and greener bars are quieter; shorter red bars are crowded. Tap a bar to see the score (0-10). The score drops by 2 for every Wi-Fi network sharing the channel (Co-channel Interference) and by smaller amounts for networks on neighboring 2.4 GHz channels (Adjacent Channel Interference). Strong nearby networks penalise more than weak distant ones.'**
  String get bandSpectrumInfoBody;

  /// Title of the recommendation info sheet
  ///
  /// In en, this message translates to:
  /// **'How is the Recommendation Made?'**
  String get recommendationInfoTitle;

  /// Body of the recommendation info sheet
  ///
  /// In en, this message translates to:
  /// **'We start every channel at 10 points, then subtract for each interfering network. Co-channel networks take 2 points each (×signal strength). Adjacent 2.4 GHz networks take 0.2-1.5 points based on distance. DFS channels lose 0.5 points (radar-shared). The channel with the highest remaining score wins. If two channels tie, the lower-numbered one is preferred.'**
  String get recommendationInfoBody;

  /// Title of the consistent best channel info sheet
  ///
  /// In en, this message translates to:
  /// **'Consistent Best Channel'**
  String get consistentChannelInfoTitle;

  /// Body of the consistent best channel info sheet
  ///
  /// In en, this message translates to:
  /// **'A snapshot can be misleading: a quiet channel right now may get crowded later. We average all your past scans on each channel and surface the one that consistently scores highest. If this differs from the current snapshot, the historically stable channel is often the safer long-term choice.'**
  String get consistentChannelInfoBody;

  /// Short DFS badge label shown next to channel tiles
  ///
  /// In en, this message translates to:
  /// **'DFS'**
  String get dfsBadgeLabel;

  /// Tooltip explaining DFS badge
  ///
  /// In en, this message translates to:
  /// **'DFS — shared with weather/military radar; your router may briefly switch off this channel'**
  String get dfsBadgeTooltip;

  /// Title of the DFS info sheet
  ///
  /// In en, this message translates to:
  /// **'What is DFS?'**
  String get dfsInfoTitle;

  /// Body of the DFS info sheet
  ///
  /// In en, this message translates to:
  /// **'DFS (Dynamic Frequency Selection) channels in the 5 GHz band (52-64 and 100-144) are legally shared with weather and military radar. Wi-Fi must give priority to those radars: if the router detects a radar pulse, it has to leave the channel for at least 60 seconds — your devices will briefly disconnect and switch to another channel. DFS channels are usually less crowded (so the score is high), but they can be unreliable near airports, harbors or weather stations. We deduct 0.5 points from the score to reflect that risk. Use them if you have no nearby radar source; avoid them otherwise.'**
  String get dfsInfoBody;

  /// Title of the router admin guide section
  ///
  /// In en, this message translates to:
  /// **'How do I change my Wi-Fi channel?'**
  String get howToChangeChannelTitle;

  /// Subtitle of the router admin guide section
  ///
  /// In en, this message translates to:
  /// **'Step-by-step guide for your router'**
  String get howToChangeChannelSubtitle;

  /// Connected SSID label in router guide
  ///
  /// In en, this message translates to:
  /// **'Connected to'**
  String get guideConnectedTo;

  /// Router vendor label
  ///
  /// In en, this message translates to:
  /// **'Router brand'**
  String get guideRouterVendor;

  /// Shown when vendor cannot be identified
  ///
  /// In en, this message translates to:
  /// **'Unknown — generic guide shown'**
  String get guideRouterUnknown;

  /// Router guide step 1 header
  ///
  /// In en, this message translates to:
  /// **'Step 1 · Open the admin panel'**
  String get guideStep1;

  /// Router guide step 1 body
  ///
  /// In en, this message translates to:
  /// **'Tap OPEN below — it launches your default browser at the router\'s admin page. (Or copy the address and paste it manually if you prefer.) You must be on this Wi-Fi for the address to work; mobile data alone won\'t reach it.'**
  String get guideStep1Body;

  /// Open URL in browser button label
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get guideOpenInBrowser;

  /// Shown when url_launcher fails
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the browser automatically — copy the address and paste it manually.'**
  String get guideOpenFailedMessage;

  /// Header for credentials sub-section
  ///
  /// In en, this message translates to:
  /// **'Username & password'**
  String get guideCredentialsHeader;

  /// Detailed credentials body
  ///
  /// In en, this message translates to:
  /// **'When the admin page asks you to sign in:\n\n1. Look at the bottom or back of your router — there\'s usually a sticker with the default Wi-Fi password AND the admin login. The admin login is labeled \"Admin password\", \"Web password\", \"Modem password\" or \"Yönetim şifresi\". This is NOT the same as the Wi-Fi password.\n\n2. If your router has no sticker, try these factory defaults:\n   • admin / admin\n   • admin / password\n   • admin / 1234\n   • root / admin\n   • Username empty / password admin\n\n3. If your ISP installed the router (Türk Telekom, TurkNet, Vodafone, Superonline, etc.), the admin password is often the last 6-8 characters of the device serial number, also on the sticker. Many ISPs ship a unique password printed only on the sticker.\n\n4. If nothing works: someone has changed the password before. You can press and hold the RESET pin on the back of the router for 10-15 seconds to restore factory defaults — but this also wipes your Wi-Fi name and password, so you\'ll have to set them up again.\n\n5. Some modern routers replace the web admin with a phone app (e.g. TP-Link Tether, ASUS Router, Mi WiFi, Huawei AI Life). If the web page redirects you to install an app, install it and continue from there.'**
  String get guideCredentialsBody;

  /// Label for admin URL/IP
  ///
  /// In en, this message translates to:
  /// **'Admin address'**
  String get guideAddressLabel;

  /// Copy button label
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get guideCopyAddress;

  /// Snack message after copying admin address
  ///
  /// In en, this message translates to:
  /// **'Address copied — open it in your browser'**
  String get guideAddressCopied;

  /// Router guide step 2 header
  ///
  /// In en, this message translates to:
  /// **'Step 2 · Find the Wi-Fi / Wireless menu'**
  String get guideStep2;

  /// Router guide step 2 body
  ///
  /// In en, this message translates to:
  /// **'After signing in, look for a menu called Wi-Fi, Wireless or Network Settings. Routers from different brands name it differently — the path below is for your router brand:'**
  String get guideStep2Body;

  /// Router guide step 3 header
  ///
  /// In en, this message translates to:
  /// **'Step 3 · Set the channel and apply'**
  String get guideStep3;

  /// Router guide step 3 body
  ///
  /// In en, this message translates to:
  /// **'Find the Channel option (often labeled Channel, Kanal or Wireless Channel). Change Auto to the recommended channel from the previous screen. If your router shows a separate option for 2.4 GHz and 5 GHz, set each band to its own recommended channel. Click Save / Apply. The router will briefly restart its Wi-Fi.'**
  String get guideStep3Body;

  /// Header for the menu path list
  ///
  /// In en, this message translates to:
  /// **'Menu path'**
  String get guideMenuPathLabel;

  /// Fallback menu path
  ///
  /// In en, this message translates to:
  /// **'Wireless / Wi-Fi → Basic / Advanced Settings → Channel'**
  String get guideGenericMenuPath;

  /// Channel width section header
  ///
  /// In en, this message translates to:
  /// **'Channel width — 20 / 40 / 80 / 160 MHz'**
  String get channelWidthHeader;

  /// Channel width explanation body
  ///
  /// In en, this message translates to:
  /// **'Channel width is like the number of lanes on a highway:\n• 20 MHz = 1 lane. Slow but resilient to traffic. Best for crowded 2.4 GHz.\n• 40 MHz = 2 lanes. Twice the throughput, but overlaps more neighbors.\n• 80 MHz = 4 lanes. Fast — only available on 5 GHz/6 GHz.\n• 160 MHz = 8 lanes. Maximum speed, but uses half the 5 GHz band; only worth it if no neighbors are around.\n\nRule of thumb: 20 MHz on 2.4 GHz; 80 MHz on 5 GHz; 160 MHz on 6 GHz if available.'**
  String get channelWidthBody;

  /// Safety/risk section header
  ///
  /// In en, this message translates to:
  /// **'Is it safe to change the channel?'**
  String get guideRisksHeader;

  /// Safety/risk section body
  ///
  /// In en, this message translates to:
  /// **'Yes — completely safe. Changing the channel has no security or performance side-effects beyond a 5-10 second pause while the router restarts the radio. Your network name (SSID), password, port-forwarding rules, parental controls and every other setting stay exactly the same. Connected devices reconnect automatically. If anything seems worse afterwards, you can return to Auto in the same menu and the router will pick a channel itself.'**
  String get guideRisksBody;

  /// Shown when no Wi-Fi is connected
  ///
  /// In en, this message translates to:
  /// **'Not connected to a Wi-Fi network — connect first to see your router\'s admin address and a tailored guide.'**
  String get guideNoConnection;

  /// Badge label for the currently used channel
  ///
  /// In en, this message translates to:
  /// **'ON NOW'**
  String get currentChannelLabel;

  /// Banner text — current channel
  ///
  /// In en, this message translates to:
  /// **'Currently on {channel}'**
  String currentChannelBannerYouAreOn(String channel);

  /// Banner suggestion when current and recommended differ
  ///
  /// In en, this message translates to:
  /// **'Switch to {channel} for +{delta} points'**
  String currentChannelBannerSwitchTo(String channel, String delta);

  /// Banner when current = recommended
  ///
  /// In en, this message translates to:
  /// **'You\'re already on the recommended channel'**
  String get currentChannelBannerOptimal;

  /// Header for the spectrum analyzer overlap chart
  ///
  /// In en, this message translates to:
  /// **'Network Overlap'**
  String get spectrumOverlapTitle;

  /// Info sheet title
  ///
  /// In en, this message translates to:
  /// **'Network Overlap'**
  String get spectrumOverlapInfoTitle;

  /// Info body
  ///
  /// In en, this message translates to:
  /// **'Each colored shape is a Wi-Fi network. The position on the X-axis is its centre frequency, the width matches the channel width (20/40/80/160 MHz) and the height shows signal strength (top = strong, bottom = weak). Where shapes overlap, those networks share the same airtime and slow each other down. Look for a vertical slice with no shapes (or only weak ones at the bottom) — that\'s a quiet channel. Tap a shape to identify the network.'**
  String get spectrumOverlapInfoBody;

  /// Shown when no networks to draw
  ///
  /// In en, this message translates to:
  /// **'No networks visible on this band'**
  String get spectrumOverlapEmptyHint;

  /// Header when expanding a channel tile
  ///
  /// In en, this message translates to:
  /// **'Networks on this channel'**
  String get channelDrilldownHeader;

  /// Empty drill-down
  ///
  /// In en, this message translates to:
  /// **'No networks broadcasting here'**
  String get channelDrilldownEmpty;

  /// Placeholder for empty SSID
  ///
  /// In en, this message translates to:
  /// **'<hidden network>'**
  String get hiddenSsidPlaceholder;

  /// No description provided for @scanComparisonImproved.
  ///
  /// In en, this message translates to:
  /// **'{delta} pts vs last scan (improved)'**
  String scanComparisonImproved(String delta);

  /// No description provided for @scanComparisonWorsened.
  ///
  /// In en, this message translates to:
  /// **'{delta} pts vs last scan (worsened)'**
  String scanComparisonWorsened(String delta);

  /// No description provided for @scanComparisonStable.
  ///
  /// In en, this message translates to:
  /// **'Stable since last scan'**
  String get scanComparisonStable;

  /// Country selector header
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get countryAllowlistHeader;

  /// Region selector info
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi channels are regulated differently per country. Channels disallowed in your region are dimmed and can\'t be used by your router. Switch the region if you\'re abroad — but the recommendation will only show legal channels for the selected region.'**
  String get countryAllowlistInfoBody;

  /// Badge for region-illegal channels
  ///
  /// In en, this message translates to:
  /// **'NOT ALLOWED'**
  String get channelIllegalBadge;

  /// Tooltip for illegal channel
  ///
  /// In en, this message translates to:
  /// **'This channel is not legal for Wi-Fi use in the selected region.'**
  String get channelIllegalTooltip;

  /// No description provided for @regionUS.
  ///
  /// In en, this message translates to:
  /// **'United States'**
  String get regionUS;

  /// No description provided for @regionEU.
  ///
  /// In en, this message translates to:
  /// **'Europe / Türkiye'**
  String get regionEU;

  /// No description provided for @regionJP.
  ///
  /// In en, this message translates to:
  /// **'Japan'**
  String get regionJP;

  /// No description provided for @regionWorld.
  ///
  /// In en, this message translates to:
  /// **'World (most permissive)'**
  String get regionWorld;

  /// Hour-of-day heatmap title
  ///
  /// In en, this message translates to:
  /// **'Best channel by hour of day'**
  String get hourlyHeatmapTitle;

  /// Insufficient hour-of-day data
  ///
  /// In en, this message translates to:
  /// **'Need more history. Open this screen at different times of day to build the pattern.'**
  String get hourlyHeatmapInsufficient;

  /// AFC info sheet
  ///
  /// In en, this message translates to:
  /// **'6 GHz Power Classes (AFC)'**
  String get afcInfoTitle;

  /// No description provided for @afcInfoBody.
  ///
  /// In en, this message translates to:
  /// **'6 GHz Wi-Fi is divided into three power classes:\n\n• LPI (Low Power Indoor) — Default for home routers. Up to 30 dBm EIRP, only legal indoors. No location coordination needed.\n\n• Standard Power (SP) — Outdoor + high-power indoor. Up to 36 dBm. Requires AFC (Automated Frequency Coordination): the router contacts an FCC/regulator database, supplies its GPS location, and is told which channels are free of incumbent users (satellite uplinks, fixed microwave links).\n\n• VLP (Very Low Power) — Mobile/portable use, up to 14 dBm. No coordination needed but very short range; mainly for AR/VR headsets and laptops.\n\nMost home networks see only LPI; if you spot a 6 GHz AP outdoors with strong signal, it likely runs SP and was AFC-coordinated.'**
  String get afcInfoBody;

  /// No description provided for @advancedTopicsHeader.
  ///
  /// In en, this message translates to:
  /// **'Advanced topics'**
  String get advancedTopicsHeader;

  /// No description provided for @advancedMeshTitle.
  ///
  /// In en, this message translates to:
  /// **'Mesh & roaming'**
  String get advancedMeshTitle;

  /// No description provided for @advancedMeshBody.
  ///
  /// In en, this message translates to:
  /// **'In a mesh network (e.g. Google Nest, Eero, TP-Link Deco) you don\'t pick the channel manually — the controller picks one per node and re-balances when neighbours change. Some controllers expose a per-node channel override, but auto-mode is usually best because the system can detect interference between mesh nodes themselves. If you must override, set the front-haul (client-facing) radio of the main node to the recommended channel and let the back-haul (node-to-node) radio stay on auto.'**
  String get advancedMeshBody;

  /// No description provided for @advancedBandSteeringTitle.
  ///
  /// In en, this message translates to:
  /// **'Band steering & one SSID vs two'**
  String get advancedBandSteeringTitle;

  /// No description provided for @advancedBandSteeringBody.
  ///
  /// In en, this message translates to:
  /// **'Modern routers offer band-steering: one SSID for both 2.4 GHz and 5 GHz, with the router pushing capable devices to 5 GHz. Pros: simple, devices roam automatically. Cons: some IoT devices (smart plugs, cameras) can only see 2.4 GHz and may fail to connect when the router hides it during steering. Workaround: split the SSIDs (e.g. \"MyHome\" on 5 GHz, \"MyHome-IoT\" on 2.4 GHz) for IoT setup and merge later if you wish.'**
  String get advancedBandSteeringBody;

  /// No description provided for @advancedWmmTitle.
  ///
  /// In en, this message translates to:
  /// **'WMM / QoS'**
  String get advancedWmmTitle;

  /// No description provided for @advancedWmmBody.
  ///
  /// In en, this message translates to:
  /// **'WMM (Wi-Fi Multimedia) prioritises traffic into 4 categories: voice, video, best-effort, background. It\'s required for Wi-Fi 4+ certification and should always stay enabled. Disabling it caps your throughput at 802.11g speeds (~54 Mbps). The Channel choice doesn\'t affect WMM, but a clean channel improves all 4 categories simultaneously.'**
  String get advancedWmmBody;

  /// Shown next to recommended-channel banner when channel is DFS
  ///
  /// In en, this message translates to:
  /// **'⚠ DFS channel: when your router moves here it must listen silently for 60 seconds before broadcasting (Channel Availability Check). Wi-Fi will be temporarily unavailable during that window.'**
  String get dfsCacWarning;

  /// No description provided for @densityTrendStable.
  ///
  /// In en, this message translates to:
  /// **'Stable density'**
  String get densityTrendStable;

  /// No description provided for @densityTrendVolatile.
  ///
  /// In en, this message translates to:
  /// **'Volatile area · density swings {delta} APs in last hour'**
  String densityTrendVolatile(String delta);

  /// Header above the cross-band router cards
  ///
  /// In en, this message translates to:
  /// **'Nearby routers (dual-band)'**
  String get routerGroupsHeader;

  /// Info body for the router groups section
  ///
  /// In en, this message translates to:
  /// **'When the same router broadcasts the same SSID on more than one band (e.g. 2.4 GHz CH 6 and 5 GHz CH 36), we group them here so you can compare both radios side by side. Tap a band chip to jump to it.'**
  String get routerGroupsInfoBody;

  /// No description provided for @crossBandSiblingHint.
  ///
  /// In en, this message translates to:
  /// **'Same router on {band} CH {channel} · {rating}/10'**
  String crossBandSiblingHint(String band, String channel, String rating);

  /// Tag for the vertical guide line in the spectrum analyzer pointing at the user's own router
  ///
  /// In en, this message translates to:
  /// **'YOU'**
  String get connectedChannelGuideLabel;

  /// Badge for channels that fluctuate heavily across history
  ///
  /// In en, this message translates to:
  /// **'UNSTABLE'**
  String get unstableChannelLabel;

  /// Tooltip for unstable channel badge
  ///
  /// In en, this message translates to:
  /// **'This channel\'s quality has fluctuated by more than 1.5 points across the last sessions'**
  String get unstableChannelTooltip;

  /// Title of the heatmap info sheet
  ///
  /// In en, this message translates to:
  /// **'What is the Heatmap?'**
  String get historyHeatmapInfoTitle;

  /// Body of the heatmap info sheet
  ///
  /// In en, this message translates to:
  /// **'Each row is a channel and each column is a moment in time when you ran a scan. The cell colour is the channel score at that moment: red (poor) → yellow (ok) → green (excellent). Empty cells mean the channel was not visible in that scan. Look for solid green rows — those are channels that stay clean over time.'**
  String get historyHeatmapInfoBody;

  /// Title of the confirmation dialog when clearing channel rating history
  ///
  /// In en, this message translates to:
  /// **'CLEAR CHANNEL HISTORY'**
  String get clearChannelHistoryTitle;

  /// Body of the confirmation dialog when clearing channel rating history
  ///
  /// In en, this message translates to:
  /// **'Delete all channel rating records? This cannot be undone.'**
  String get clearChannelHistoryConfirmBody;

  /// Label for the destructive confirm button when clearing channel rating history
  ///
  /// In en, this message translates to:
  /// **'DELETE ALL'**
  String get deleteAllLabel;

  /// Badge shown on a channel tile when the user's connected router exposes another radio on this band (the user is not actually using this radio right now)
  ///
  /// In en, this message translates to:
  /// **'DUAL BAND'**
  String get dualBandSiblingLabel;

  /// Banner copy on a band tab when the user is connected to a different band of the same router. {band} is e.g. '2.4 GHz', {channel} is e.g. 'CH 6 · 8.2/10'.
  ///
  /// In en, this message translates to:
  /// **'Your router\'s {band} radio: {channel}'**
  String dualBandSiblingBanner(String band, String channel);

  /// Confirmation button label that closes an info bottom sheet (Topology legend)
  ///
  /// In en, this message translates to:
  /// **'ACKNOWLEDGED'**
  String get acknowledgedLabel;

  /// No description provided for @speedDoctorTitle.
  ///
  /// In en, this message translates to:
  /// **'SPEED DOCTOR'**
  String get speedDoctorTitle;

  /// Speed Doctor subtitle
  ///
  /// In en, this message translates to:
  /// **'Why is the internet slow?'**
  String get speedDoctorTagline;

  /// Operations Hub tile for Speed Doctor
  ///
  /// In en, this message translates to:
  /// **'SPEED DOCTOR'**
  String get speedDoctorOpsTile;

  /// Operations Hub tile subtitle for Speed Doctor
  ///
  /// In en, this message translates to:
  /// **'Why is it slow?'**
  String get speedDoctorOpsSubtitle;

  /// Evil-twin detail page title
  ///
  /// In en, this message translates to:
  /// **'EVIL TWIN DETAIL'**
  String get evilTwinDetailTitle;

  /// Ping Stabilizer feature title
  ///
  /// In en, this message translates to:
  /// **'PING STABILIZER'**
  String get pingStabilizerTitle;

  /// Operations Hub subtitle for Ping Stabilizer
  ///
  /// In en, this message translates to:
  /// **'On-device latency tunnel'**
  String get pingStabilizerSubtitle;

  /// Hint shown on the inactive Ping Stabilizer toggle card
  ///
  /// In en, this message translates to:
  /// **'Tap to stabilize'**
  String get pingStabilizerToggleHint;

  /// Drawer entry label for Ping Stabilizer
  ///
  /// In en, this message translates to:
  /// **'Ping Stabilizer'**
  String get pingStabilizerDrawerLabel;

  /// Button label to finish onboarding.
  ///
  /// In en, this message translates to:
  /// **'START SCANNING'**
  String get onboardingStartScanning;

  /// Button label for next slide.
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get onboardingNext;

  /// Welcome title.
  ///
  /// In en, this message translates to:
  /// **'WELCOME TO TORCAV'**
  String get onboardingWelcomeTitle;

  /// Welcome body text.
  ///
  /// In en, this message translates to:
  /// **'A cyberpunk Wi-Fi analyzer that helps you understand your wireless environment, find the best channel, and detect security threats.'**
  String get onboardingWelcomeBody;

  /// Location permission title.
  ///
  /// In en, this message translates to:
  /// **'LOCATION PERMISSION'**
  String get onboardingLocationTitle;

  /// Location permission explanation.
  ///
  /// In en, this message translates to:
  /// **'Android requires Location permission to scan for Wi-Fi networks. To show signal heatmaps, we also use activity sensors. All data stays on your device and is never uploaded. Your location is only used to read nearby Wi-Fi signals.'**
  String get onboardingLocationBody;

  /// Tour section title.
  ///
  /// In en, this message translates to:
  /// **'THREE TABS'**
  String get onboardingTourTitle;

  /// Dashboard label in tour.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get onboardingTourDashboardLabel;

  /// Dashboard description in tour.
  ///
  /// In en, this message translates to:
  /// **'Live overview of your network health'**
  String get onboardingTourDashboardDesc;

  /// Discovery label in tour.
  ///
  /// In en, this message translates to:
  /// **'Discovery'**
  String get onboardingTourDiscoveryLabel;

  /// Discovery description in tour.
  ///
  /// In en, this message translates to:
  /// **'Scan Wi-Fi networks and LAN devices'**
  String get onboardingTourDiscoveryDesc;

  /// Operations label in tour.
  ///
  /// In en, this message translates to:
  /// **'Operations'**
  String get onboardingTourOperationsLabel;

  /// Operations description in tour.
  ///
  /// In en, this message translates to:
  /// **'Security analysis, speed tests, reports'**
  String get onboardingTourOperationsDesc;

  /// Network context question.
  ///
  /// In en, this message translates to:
  /// **'WHERE WILL YOU USE TORCAV?'**
  String get onboardingContextTitle;

  /// Context explanation.
  ///
  /// In en, this message translates to:
  /// **'This shapes how strict the security score is when we can\'t tell on our own. You can change it any time, and it can be overridden per network later.'**
  String get onboardingContextBody;

  /// Home context title.
  ///
  /// In en, this message translates to:
  /// **'Mostly my own home / office'**
  String get onboardingContextHomeTitle;

  /// Home context description.
  ///
  /// In en, this message translates to:
  /// **'Strict scoring. Any unexpected change in encryption or new devices on the LAN gets flagged loudly.'**
  String get onboardingContextHomeBody;

  /// Public context title.
  ///
  /// In en, this message translates to:
  /// **'Mostly cafés / hotels / airports'**
  String get onboardingContextPublicTitle;

  /// Public context description.
  ///
  /// In en, this message translates to:
  /// **'Relaxed scoring on encryption (these networks are often open) but heightened sensitivity to lure SSIDs and evil-twin patterns. Active LAN scanning is suppressed by default.'**
  String get onboardingContextPublicBody;

  /// Guest context title.
  ///
  /// In en, this message translates to:
  /// **'Mostly guest / shared networks'**
  String get onboardingContextGuestTitle;

  /// Guest context description.
  ///
  /// In en, this message translates to:
  /// **'Same Wi-Fi as friends, family, or coworkers. Drift is expected; we don\'t alert on every new device.'**
  String get onboardingContextGuestBody;

  /// Unknown context title.
  ///
  /// In en, this message translates to:
  /// **'Not sure yet'**
  String get onboardingContextUnknownTitle;

  /// Unknown context description.
  ///
  /// In en, this message translates to:
  /// **'No strong default. We\'ll guess from each network\'s fingerprint and let you correct it.'**
  String get onboardingContextUnknownBody;

  /// Completion title.
  ///
  /// In en, this message translates to:
  /// **'ALL SET'**
  String get onboardingDoneTitle;

  /// Completion body text.
  ///
  /// In en, this message translates to:
  /// **'Torcav is a privacy-first network assistant. It provides safe network diagnostics and hardening tools for networks you own or are authorized to assess. No data is collected or transmitted externally.'**
  String get onboardingDoneBody;

  /// Acceptance prefix.
  ///
  /// In en, this message translates to:
  /// **'I have read and accept the '**
  String get onboardingAcceptPrefix;

  /// TOS link text.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get onboardingTosLink;

  /// Acceptance separator.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get onboardingAcceptAnd;

  /// Privacy link text.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get onboardingPrivacyLink;

  /// Acceptance suffix.
  ///
  /// In en, this message translates to:
  /// **'.'**
  String get onboardingAcceptSuffix;

  /// Permission confirmation checkbox.
  ///
  /// In en, this message translates to:
  /// **'I confirm I have permission to scan the networks I will analyze.'**
  String get onboardingConfirmPermission;

  /// Age confirmation checkbox.
  ///
  /// In en, this message translates to:
  /// **'I confirm I am 13 years of age or older.'**
  String get onboardingConfirmAge;

  /// The application name.
  ///
  /// In en, this message translates to:
  /// **'TORCAV'**
  String get appTitle;

  /// SSID label.
  ///
  /// In en, this message translates to:
  /// **'SSID'**
  String get ssidLabel;

  /// Empty state for security findings.
  ///
  /// In en, this message translates to:
  /// **'No security findings detected.'**
  String get noSecurityFindings;

  /// Button to reset network context.
  ///
  /// In en, this message translates to:
  /// **'Reset to inferred'**
  String get resetToInferred;

  /// Question on the speed doctor tile.
  ///
  /// In en, this message translates to:
  /// **'IS INTERNET SLOW?'**
  String get internetSlowQuestion;

  /// Description on the speed doctor tile.
  ///
  /// In en, this message translates to:
  /// **'Run Speed Doctor — 30-second root-cause diagnostic.'**
  String get runSpeedDoctorDesc;

  /// Title for the security alerts sheet.
  ///
  /// In en, this message translates to:
  /// **'SECURITY ALERTS'**
  String get securityAlertsTitle;

  /// Button to mark all alerts as read.
  ///
  /// In en, this message translates to:
  /// **'MARK ALL READ'**
  String get markAllRead;

  /// Button to clear all alerts.
  ///
  /// In en, this message translates to:
  /// **'CLEAR ALL'**
  String get clearAll;

  /// Information about event retention.
  ///
  /// In en, this message translates to:
  /// **'Events are retained for 30 days. Swipe left to dismiss.'**
  String get eventsRetentionInfo;

  /// Text shown when there are no alerts.
  ///
  /// In en, this message translates to:
  /// **'All systems clear'**
  String get allSystemsClear;

  /// Note about heuristic detection accuracy.
  ///
  /// In en, this message translates to:
  /// **'Heuristic detection — not a confirmed attack. False positives may occur in congested environments.'**
  String get heuristicDetectionNote;

  /// Button to mark a single alert as read.
  ///
  /// In en, this message translates to:
  /// **'MARK AS READ'**
  String get markAsRead;

  /// Security event type: Rogue AP.
  ///
  /// In en, this message translates to:
  /// **'ROGUE AP'**
  String get eventTypeRogueAp;

  /// Security event type: Evil Twin.
  ///
  /// In en, this message translates to:
  /// **'EVIL TWIN'**
  String get eventTypeEvilTwin;

  /// Security event type: Deauth Attack.
  ///
  /// In en, this message translates to:
  /// **'DEAUTH ATTACK'**
  String get eventTypeDeauthAttack;

  /// Security event type: Encryption Weakened.
  ///
  /// In en, this message translates to:
  /// **'ENCRYPTION WEAKENED'**
  String get eventTypeEncryptionWeakened;

  /// Security event type: Deauth Burst.
  ///
  /// In en, this message translates to:
  /// **'DEAUTH BURST'**
  String get eventTypeDeauthBurst;

  /// Security event type: Handshake Analysis.
  ///
  /// In en, this message translates to:
  /// **'HANDSHAKE ANALYSIS'**
  String get eventTypeHandshakeAnalysis;

  /// Security event type: Handshake Secured.
  ///
  /// In en, this message translates to:
  /// **'HANDSHAKE SECURED'**
  String get eventTypeHandshakeSecured;

  /// Security event type: Captive Portal.
  ///
  /// In en, this message translates to:
  /// **'CAPTIVE PORTAL'**
  String get eventTypeCaptivePortal;

  /// Security event type: Unsupported.
  ///
  /// In en, this message translates to:
  /// **'UNSUPPORTED'**
  String get eventTypeUnsupported;

  /// Security event type: Arp Spoofing.
  ///
  /// In en, this message translates to:
  /// **'ARP SPOOFING'**
  String get eventTypeArpSpoofing;

  /// Security event type: Dns Hijacking.
  ///
  /// In en, this message translates to:
  /// **'DNS HIJACKING'**
  String get eventTypeDnsHijacking;

  /// Default agent ID.
  ///
  /// In en, this message translates to:
  /// **'AGENT-01'**
  String get agentId;

  /// Cybernetic ID label.
  ///
  /// In en, this message translates to:
  /// **'CYBERNETIC_ID: {id}'**
  String cyberneticId(String id);

  /// Subscription status label.
  ///
  /// In en, this message translates to:
  /// **'Sub: {type}'**
  String subscriptionLabel(String type);

  /// Message shown when deep scan is skipped for safety.
  ///
  /// In en, this message translates to:
  /// **'Deep scan suppressed — connected to a {context} network. Disable the safety guard in Settings to override.'**
  String deepScanSuppressed(String context);

  /// Error message when security scan fails.
  ///
  /// In en, this message translates to:
  /// **'SECURITY ASSESSMENT FAILED'**
  String get securityAssessmentFailed;

  /// Button to retry security scan.
  ///
  /// In en, this message translates to:
  /// **'RETRY ANALYTICS'**
  String get retryAnalytics;

  /// Label for public network context.
  ///
  /// In en, this message translates to:
  /// **'public'**
  String get publicContextLabel;

  /// Label for guest network context.
  ///
  /// In en, this message translates to:
  /// **'guest'**
  String get guestContextLabel;

  /// Title for clear scan history dialog.
  ///
  /// In en, this message translates to:
  /// **'CLEAR SCAN HISTORY'**
  String get clearScanHistoryTitle;

  /// Body for clear scan history dialog.
  ///
  /// In en, this message translates to:
  /// **'Delete all LAN scan records? This cannot be undone.'**
  String get clearScanHistoryBody;

  /// Cancel button label.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancelLabel;

  /// Title for network audit consent dialog.
  ///
  /// In en, this message translates to:
  /// **'NETWORK AUDIT CONSENT'**
  String get networkAuditConsentTitle;

  /// Description for network audit consent dialog.
  ///
  /// In en, this message translates to:
  /// **'Active network scanning generates traffic to identify devices and services. This may be flagged by network security systems.'**
  String get networkAuditConsentDesc;

  /// Consent point: scan nodes.
  ///
  /// In en, this message translates to:
  /// **'Scan local network for active nodes'**
  String get consentScanNodes;

  /// Consent point: fingerprint.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint open services and OS'**
  String get consentFingerprint;

  /// Consent point: identify vulnerabilities.
  ///
  /// In en, this message translates to:
  /// **'Identify potential vulnerabilities'**
  String get consentIdentifyVulns;

  /// Consent point: confirm authorization.
  ///
  /// In en, this message translates to:
  /// **'Confirm you have authorization for this network'**
  String get consentConfirmAuth;

  /// Action label for consent dialog.
  ///
  /// In en, this message translates to:
  /// **'I UNDERSTAND'**
  String get iUnderstand;

  /// Warning for iOS users about LAN scan limitations.
  ///
  /// In en, this message translates to:
  /// **'iOS: LAN discovery is limited. mDNS browsing and ARP table access may be restricted by the OS.'**
  String get iosLanDiscoveryLimited;

  /// Warning for Android users about LAN vendor detection limitations.
  ///
  /// In en, this message translates to:
  /// **'Android limits LAN MAC access. Vendor names may only appear for the router/gateway; other devices are identified by IP, hostname and services when available.'**
  String get androidLanVendorLimited;

  /// Node inspector hint when Android cannot expose a LAN device MAC/vendor.
  ///
  /// In en, this message translates to:
  /// **'Vendor unavailable: Android does not expose this device\'s LAN MAC address to apps.'**
  String get vendorUnavailableAndroid;

  /// Long description for Speed Doctor.
  ///
  /// In en, this message translates to:
  /// **'Runs signal, channel, speed and DNS probes in ~30 seconds and tells you which link in the chain is the bottleneck.'**
  String get speedDoctorLongDesc;

  /// Button to start speed doctor.
  ///
  /// In en, this message translates to:
  /// **'START DIAGNOSIS'**
  String get startDiagnosis;

  /// Warning about data usage during speed test.
  ///
  /// In en, this message translates to:
  /// **'Heads up: a real speed test downloads ~300–500 MB. Use Wi-Fi or an unmetered connection to avoid burning your mobile quota.'**
  String get speedDoctorQuotaWarning;

  /// Evidence section header.
  ///
  /// In en, this message translates to:
  /// **'EVIDENCE'**
  String get evidenceLabel;

  /// Button to rerun diagnosis.
  ///
  /// In en, this message translates to:
  /// **'RUN AGAIN'**
  String get runAgain;

  /// About section title.
  ///
  /// In en, this message translates to:
  /// **'ABOUT SPEED DOCTOR'**
  String get aboutSpeedDoctorTitle;

  /// No description provided for @sdAboutWhatTitle.
  ///
  /// In en, this message translates to:
  /// **'What is it?'**
  String get sdAboutWhatTitle;

  /// No description provided for @sdAboutWhatBody.
  ///
  /// In en, this message translates to:
  /// **'A one-tap diagnostic that finds the likely bottleneck between you and the internet — without you having to compare numbers across separate screens.'**
  String get sdAboutWhatBody;

  /// No description provided for @sdAboutHowTitle.
  ///
  /// In en, this message translates to:
  /// **'How does it work?'**
  String get sdAboutHowTitle;

  /// No description provided for @sdAboutHowBody.
  ///
  /// In en, this message translates to:
  /// **'Five short probes run end-to-end and the results are compared against published thresholds:'**
  String get sdAboutHowBody;

  /// No description provided for @sdAboutHowBullet1.
  ///
  /// In en, this message translates to:
  /// **'Signal — reads RSSI from the connected access point.'**
  String get sdAboutHowBullet1;

  /// No description provided for @sdAboutHowBullet2.
  ///
  /// In en, this message translates to:
  /// **'Channel — scores your channel against neighbouring APs.'**
  String get sdAboutHowBullet2;

  /// No description provided for @sdAboutHowBullet3.
  ///
  /// In en, this message translates to:
  /// **'Speed — runs a real download/upload test against Cloudflare.'**
  String get sdAboutHowBullet3;

  /// No description provided for @sdAboutHowBullet4.
  ///
  /// In en, this message translates to:
  /// **'Bufferbloat — measures latency under load (Waveform A–F).'**
  String get sdAboutHowBullet4;

  /// No description provided for @sdAboutHowBullet5.
  ///
  /// In en, this message translates to:
  /// **'DNS — benchmarks public resolvers vs. your current one.'**
  String get sdAboutHowBullet5;

  /// No description provided for @sdAboutCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'What do the categories mean?'**
  String get sdAboutCategoriesTitle;

  /// No description provided for @sdAboutCategoriesBullet1.
  ///
  /// In en, this message translates to:
  /// **'Weak Signal — Wi-Fi link forced into slower modes by distance / walls.'**
  String get sdAboutCategoriesBullet1;

  /// No description provided for @sdAboutCategoriesBullet2.
  ///
  /// In en, this message translates to:
  /// **'Crowded Channel — neighbouring APs on the same channel eat your air-time.'**
  String get sdAboutCategoriesBullet2;

  /// No description provided for @sdAboutCategoriesBullet3.
  ///
  /// In en, this message translates to:
  /// **'Bufferbloat — latency balloons when the link is fully loaded; calls and games suffer.'**
  String get sdAboutCategoriesBullet3;

  /// No description provided for @sdAboutCategoriesBullet4.
  ///
  /// In en, this message translates to:
  /// **'ISP Slow — Wi-Fi is fine but your plan / upstream is the ceiling.'**
  String get sdAboutCategoriesBullet4;

  /// No description provided for @sdAboutCategoriesBullet5.
  ///
  /// In en, this message translates to:
  /// **'Slow DNS — page loads feel laggy because name lookups take too long.'**
  String get sdAboutCategoriesBullet5;

  /// No description provided for @sdAboutEstimateTitle.
  ///
  /// In en, this message translates to:
  /// **'About the speed-up estimate'**
  String get sdAboutEstimateTitle;

  /// No description provided for @sdAboutEstimateBody.
  ///
  /// In en, this message translates to:
  /// **'Each finding shows a conservative projected gain — what you can realistically expect after applying the fix. It is a lower bound, not a guarantee, and it depends on the test conditions.'**
  String get sdAboutEstimateBody;

  /// Error message when diagnosis fails.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis failed'**
  String get diagnosisFailed;

  /// Retry button label.
  ///
  /// In en, this message translates to:
  /// **'RETRY'**
  String get retryLabel;

  /// No description provided for @settingsIncludeHiddenDesc.
  ///
  /// In en, this message translates to:
  /// **'Actively probes for hidden SSIDs. Off by default — only enable on networks you own.'**
  String get settingsIncludeHiddenDesc;

  /// No description provided for @autoScanLabel.
  ///
  /// In en, this message translates to:
  /// **'Auto-Scan'**
  String get autoScanLabel;

  /// No description provided for @autoScanDesc.
  ///
  /// In en, this message translates to:
  /// **'Repeat scan every {seconds}s automatically'**
  String autoScanDesc(int seconds);

  /// No description provided for @deepScanLabel.
  ///
  /// In en, this message translates to:
  /// **'Deep Scan'**
  String get deepScanLabel;

  /// No description provided for @deepScanDesc.
  ///
  /// In en, this message translates to:
  /// **'Banner grab + exposure analysis. Only enable on networks you are authorized to test.'**
  String get deepScanDesc;

  /// No description provided for @restrictDeepScanPublicLabel.
  ///
  /// In en, this message translates to:
  /// **'Restrict Deep Scan on Public Wi-Fi'**
  String get restrictDeepScanPublicLabel;

  /// No description provided for @restrictDeepScanPublicDesc.
  ///
  /// In en, this message translates to:
  /// **'Suppress active probing when connected to a public or guest network. Recommended — active scans on networks you do not own are the dominant legal risk.'**
  String get restrictDeepScanPublicDesc;

  /// No description provided for @backgroundMonitoringLabel.
  ///
  /// In en, this message translates to:
  /// **'Background Monitoring'**
  String get backgroundMonitoringLabel;

  /// No description provided for @backgroundMonitoringDesc.
  ///
  /// In en, this message translates to:
  /// **'Run a quiet Wi-Fi check every 30 minutes while the app is closed. You\'ll get a notification if a new device appears, the connected network swaps, or encryption changes. Battery impact is minimal. iOS support is limited (system-controlled refresh).'**
  String get backgroundMonitoringDesc;

  /// No description provided for @portScanTimeoutLabel.
  ///
  /// In en, this message translates to:
  /// **'Port Scan Timeout'**
  String get portScanTimeoutLabel;

  /// No description provided for @privacyAndDataLabel.
  ///
  /// In en, this message translates to:
  /// **'PRIVACY & DATA'**
  String get privacyAndDataLabel;

  /// No description provided for @dataRetentionLabel.
  ///
  /// In en, this message translates to:
  /// **'DATA RETENTION'**
  String get dataRetentionLabel;

  /// No description provided for @scanHistoryRetentionLabel.
  ///
  /// In en, this message translates to:
  /// **'Scan History'**
  String get scanHistoryRetentionLabel;

  /// No description provided for @speedTestsRetentionLabel.
  ///
  /// In en, this message translates to:
  /// **'Speed Tests'**
  String get speedTestsRetentionLabel;

  /// No description provided for @securityEventsRetentionLabel.
  ///
  /// In en, this message translates to:
  /// **'Security Events'**
  String get securityEventsRetentionLabel;

  /// No description provided for @replayOnboardingLabel.
  ///
  /// In en, this message translates to:
  /// **'Replay Onboarding'**
  String get replayOnboardingLabel;

  /// No description provided for @replayOnboardingDesc.
  ///
  /// In en, this message translates to:
  /// **'View the welcome tour again.'**
  String get replayOnboardingDesc;

  /// No description provided for @wipeAllDataLabel.
  ///
  /// In en, this message translates to:
  /// **'Wipe All Local Data'**
  String get wipeAllDataLabel;

  /// No description provided for @wipeAllDataDesc.
  ///
  /// In en, this message translates to:
  /// **'Deletes all scan history, speed tests, security events and channel ratings from this device.'**
  String get wipeAllDataDesc;

  /// No description provided for @aboutLabel.
  ///
  /// In en, this message translates to:
  /// **'ABOUT'**
  String get aboutLabel;

  /// No description provided for @legalDisclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Legal Disclaimer'**
  String get legalDisclaimerTitle;

  /// No description provided for @legalDisclaimerBody.
  ///
  /// In en, this message translates to:
  /// **'This application performs network observation and authorized LAN discovery. Active probing is strictly limited to service identification and security assessment. No brute-force authentication, frame injection, deauthentication packets, ARP poisoning, or credential harvesting are performed.\n\nUse of this application on networks you do not own or are not authorized to test may violate applicable laws (TCK 243/244, EU Directive 2013/40, CFAA). The user is solely responsible for ensuring lawful use.'**
  String get legalDisclaimerBody;

  /// No description provided for @enableDeepScanTitle.
  ///
  /// In en, this message translates to:
  /// **'ENABLE DEEP SCAN?'**
  String get enableDeepScanTitle;

  /// No description provided for @enableDeepScanBody.
  ///
  /// In en, this message translates to:
  /// **'Deep scan performs banner grabbing and service exposure analysis. This mode must only be used on networks you own or are explicitly authorized to test.\n\nProceeding on unauthorized networks may violate applicable laws.'**
  String get enableDeepScanBody;

  /// No description provided for @wifiScanPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'WIFI SCAN PERMISSION'**
  String get wifiScanPermissionTitle;

  /// No description provided for @wifiScanPermissionDesc.
  ///
  /// In en, this message translates to:
  /// **'To discover nearby Wi-Fi networks and analyze signal strength, Torcav requires Location access. This is an Android system requirement for Wi-Fi scanning.'**
  String get wifiScanPermissionDesc;

  /// No description provided for @consentScanSsids.
  ///
  /// In en, this message translates to:
  /// **'Scan nearby Wi-Fi SSIDs'**
  String get consentScanSsids;

  /// No description provided for @consentAnalyzeSignal.
  ///
  /// In en, this message translates to:
  /// **'Analyze signal quality and interference'**
  String get consentAnalyzeSignal;

  /// No description provided for @consentNoTracking.
  ///
  /// In en, this message translates to:
  /// **'Torcav never tracks or shares your location'**
  String get consentNoTracking;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get continueLabel;

  /// No description provided for @clearWifiHistoryBody.
  ///
  /// In en, this message translates to:
  /// **'Delete all saved Wi-Fi scan sessions? This cannot be undone.'**
  String get clearWifiHistoryBody;

  /// No description provided for @transparentSignalAnalysisTitle.
  ///
  /// In en, this message translates to:
  /// **'TRANSPARENT SIGNAL ANALYSIS'**
  String get transparentSignalAnalysisTitle;

  /// No description provided for @transparentSignalAnalysisDesc.
  ///
  /// In en, this message translates to:
  /// **'Advanced spectrum analysis for security auditing. Local processing only.'**
  String get transparentSignalAnalysisDesc;

  /// No description provided for @cachedResultsWarning.
  ///
  /// In en, this message translates to:
  /// **'Showing cached results — Android limits scan frequency. Wait ~30 s and refresh for live data.'**
  String get cachedResultsWarning;

  /// No description provided for @enableDeepScanBodyWifi.
  ///
  /// In en, this message translates to:
  /// **'Deep Scan performs banner grabbing and exposure analysis. Use only on networks you are authorized to scan. Unauthorized use may violate TCK 243/244 and similar laws.'**
  String get enableDeepScanBodyWifi;

  /// No description provided for @iAmAuthorized.
  ///
  /// In en, this message translates to:
  /// **'I AM AUTHORIZED'**
  String get iAmAuthorized;

  /// No description provided for @iosWifiScanLimited.
  ///
  /// In en, this message translates to:
  /// **'iOS: Wi-Fi scan results are limited by Apple APIs. Active scan trigger and some network details are unavailable.'**
  String get iosWifiScanLimited;

  /// No description provided for @allCategoriesLabel.
  ///
  /// In en, this message translates to:
  /// **'All categories (single bundle)'**
  String get allCategoriesLabel;

  /// No description provided for @jsonFormatLabel.
  ///
  /// In en, this message translates to:
  /// **'JSON — full, machine-readable'**
  String get jsonFormatLabel;

  /// No description provided for @htmlFormatLabel.
  ///
  /// In en, this message translates to:
  /// **'HTML — viewable in browser'**
  String get htmlFormatLabel;

  /// No description provided for @autoLabel.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get autoLabel;

  /// No description provided for @lightLabel.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightLabel;

  /// No description provided for @darkLabel.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkLabel;

  /// No description provided for @dismissLabel.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismissLabel;

  /// No description provided for @applyLabel.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get applyLabel;

  /// No description provided for @openSettingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettingsLabel;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @noConnectedNetwork.
  ///
  /// In en, this message translates to:
  /// **'No connected network'**
  String get noConnectedNetwork;

  /// No description provided for @ssidNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'SSID not available'**
  String get ssidNotAvailable;

  /// No description provided for @encryptionAndConfigTitle.
  ///
  /// In en, this message translates to:
  /// **'ENCRYPTION & CONFIG'**
  String get encryptionAndConfigTitle;

  /// No description provided for @environmentScanTitle.
  ///
  /// In en, this message translates to:
  /// **'ENVIRONMENT SCAN'**
  String get environmentScanTitle;

  /// No description provided for @dnsTestFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'DNS Test Failed'**
  String get dnsTestFailedTitle;

  /// No description provided for @dnsTestFailedDesc.
  ///
  /// In en, this message translates to:
  /// **'Could not reach DNS test servers. Check your connection.'**
  String get dnsTestFailedDesc;

  /// No description provided for @dnsLeakDetectedTitle.
  ///
  /// In en, this message translates to:
  /// **'DNS Leak Detected'**
  String get dnsLeakDetectedTitle;

  /// No description provided for @dnsLeakDetectedDesc.
  ///
  /// In en, this message translates to:
  /// **'Your DNS queries are leaking outside the expected resolver, potentially exposing your browsing activity to your ISP or third parties.'**
  String get dnsLeakDetectedDesc;

  /// No description provided for @dnsHijackingDetectedTitle.
  ///
  /// In en, this message translates to:
  /// **'DNS Hijacking Detected'**
  String get dnsHijackingDetectedTitle;

  /// No description provided for @dnsHijackingDetectedDesc.
  ///
  /// In en, this message translates to:
  /// **'DNS responses are being redirected to an unexpected server. This could indicate a man-in-the-middle attack or ISP interception.'**
  String get dnsHijackingDetectedDesc;

  /// No description provided for @dnsConfigWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'DNS Configuration Warning'**
  String get dnsConfigWarningTitle;

  /// No description provided for @dnsConfigWarningDesc.
  ///
  /// In en, this message translates to:
  /// **'DNS configuration has potential issues that could affect privacy or security.'**
  String get dnsConfigWarningDesc;

  /// No description provided for @noIssuesDetected.
  ///
  /// In en, this message translates to:
  /// **'No issues detected'**
  String get noIssuesDetected;

  /// No description provided for @retryInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'Retry when connected to the internet.'**
  String get retryInternetConnection;

  /// No description provided for @dnsLeakRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Configure a trusted DNS resolver (e.g. 1.1.1.1 or 9.9.9.9) and enable DNS-over-HTTPS (DoH) or DNS-over-TLS (DoT).'**
  String get dnsLeakRecommendation;

  /// No description provided for @dnsHijackingRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Switch to a VPN immediately. Your DNS queries are being tampered with.'**
  String get dnsHijackingRecommendation;

  /// No description provided for @dnsConfigRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Review your DNS settings and consider switching to a privacy-focused DNS provider.'**
  String get dnsConfigRecommendation;

  /// No description provided for @openNetworksNearbyTitle.
  ///
  /// In en, this message translates to:
  /// **'{count} Open Network(s) Nearby'**
  String openNetworksNearbyTitle(int count);

  /// No description provided for @openNetworksNearbyDesc.
  ///
  /// In en, this message translates to:
  /// **'Detected {count} unencrypted network(s) in range. Open networks are trivially sniffable.'**
  String openNetworksNearbyDesc(int count);

  /// No description provided for @wpsEnabledNearbyTitle.
  ///
  /// In en, this message translates to:
  /// **'{count} Network(s) with WPS Enabled'**
  String wpsEnabledNearbyTitle(int count);

  /// No description provided for @wpsEnabledNearbyDesc.
  ///
  /// In en, this message translates to:
  /// **'WPS is enabled on {count} nearby network(s). WPS PIN can be brute-forced, bypassing the Wi-Fi password entirely.'**
  String wpsEnabledNearbyDesc(int count);

  /// No description provided for @wpsRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Disable WPS on your router. If these are not your networks, be aware that nearby APs may be less secure.'**
  String get wpsRecommendation;

  /// No description provided for @renderingErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'RENDERING ERROR'**
  String get renderingErrorTitle;

  /// No description provided for @appTitleLong.
  ///
  /// In en, this message translates to:
  /// **'Torcav Wi-Fi Analyzer'**
  String get appTitleLong;

  /// No description provided for @tosTitle.
  ///
  /// In en, this message translates to:
  /// **'TERMS OF SERVICE'**
  String get tosTitle;

  /// No description provided for @tosAcceptanceTitle.
  ///
  /// In en, this message translates to:
  /// **'1. ACCEPTANCE'**
  String get tosAcceptanceTitle;

  /// No description provided for @tosAcceptanceBody.
  ///
  /// In en, this message translates to:
  /// **'By accessing or using Torcav, you agree to be bound by these Terms. If you do not agree, you must immediately cease use of the App.'**
  String get tosAcceptanceBody;

  /// No description provided for @tosAuthorizedTestingTitle.
  ///
  /// In en, this message translates to:
  /// **'2. AUTHORIZED TESTING ONLY'**
  String get tosAuthorizedTestingTitle;

  /// No description provided for @tosAuthorizedTestingBody.
  ///
  /// In en, this message translates to:
  /// **'You represent and warrant that you will only use the App to analyze networks and devices that you own or for which you have received explicit, written authorization to test. Unauthorized access to networks is strictly prohibited and may be illegal in your jurisdiction.'**
  String get tosAuthorizedTestingBody;

  /// No description provided for @tosDisclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'3. DISCLAIMER OF WARRANTIES'**
  String get tosDisclaimerTitle;

  /// No description provided for @tosDisclaimerBody.
  ///
  /// In en, this message translates to:
  /// **'The App is provided \"as is\" and \"as available\". We do not guarantee that the App will identify all security vulnerabilities or that its results are 100% accurate. Use at your own risk.'**
  String get tosDisclaimerBody;

  /// No description provided for @tosLiabilityTitle.
  ///
  /// In en, this message translates to:
  /// **'4. LIMITATION OF LIABILITY'**
  String get tosLiabilityTitle;

  /// No description provided for @tosLiabilityBody.
  ///
  /// In en, this message translates to:
  /// **'In no event shall the developers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the App.'**
  String get tosLiabilityBody;

  /// No description provided for @tosModificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'5. MODIFICATIONS'**
  String get tosModificationsTitle;

  /// No description provided for @tosModificationsBody.
  ///
  /// In en, this message translates to:
  /// **'We reserve the right to modify these terms at any time. Continued use of the App following any changes constitutes acceptance of the new terms.'**
  String get tosModificationsBody;

  /// No description provided for @tosLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last Updated: April 2026'**
  String get tosLastUpdated;

  /// No description provided for @legalNoticeTitle.
  ///
  /// In en, this message translates to:
  /// **'LEGAL NOTICE'**
  String get legalNoticeTitle;

  /// No description provided for @legalNoticeBody.
  ///
  /// In en, this message translates to:
  /// **'This application is a security auditing tool. Misuse of this software to access or monitor networks without permission is strictly prohibited.'**
  String get legalNoticeBody;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'PRIVACY POLICY'**
  String get privacyTitle;

  /// No description provided for @privacyIntro.
  ///
  /// In en, this message translates to:
  /// **'Torcav is built on the principle of \"Privacy by Default\". Almost every byte stays on your device — no accounts, no cloud sync, no analytics, no advertising. A handful of features connect to public technical endpoints (Cloudflare, Google\'s captive-portal probe, public DNS resolvers) — those see only your IP, never any Torcav-internal identifier. You can wipe every persisted record with one tap.'**
  String get privacyIntro;

  /// No description provided for @privacyViewFullGithub.
  ///
  /// In en, this message translates to:
  /// **'VIEW FULL POLICY ON GITHUB'**
  String get privacyViewFullGithub;

  /// No description provided for @privacyFullPolicyDesc.
  ///
  /// In en, this message translates to:
  /// **'The card list below is a summary. The canonical, KVKK + GDPR-formatted policy is hosted at github.io.'**
  String get privacyFullPolicyDesc;

  /// No description provided for @privacyResponsibleTitle.
  ///
  /// In en, this message translates to:
  /// **'WHO IS RESPONSIBLE'**
  String get privacyResponsibleTitle;

  /// No description provided for @privacyIndividualDev.
  ///
  /// In en, this message translates to:
  /// **'Individual Developer'**
  String get privacyIndividualDev;

  /// No description provided for @privacyDevBody.
  ///
  /// In en, this message translates to:
  /// **'Torcav is operated by an individual developer (Halil İbrahim Avşar), not a registered company. You can reach the data controller directly at {email}.'**
  String privacyDevBody(String email);

  /// No description provided for @privacyDataCollectionTitle.
  ///
  /// In en, this message translates to:
  /// **'DATA COLLECTION & USAGE'**
  String get privacyDataCollectionTitle;

  /// No description provided for @privacyWifiAnalysisTitle.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi & Network Analysis'**
  String get privacyWifiAnalysisTitle;

  /// No description provided for @privacyWifiAnalysisBody.
  ///
  /// In en, this message translates to:
  /// **'Nearby SSID/BSSID/RSSI metadata and security flags (WPA2/WPA3/WPS/PMF) are read from the OS scan API. This data stays in a local SQLite database encrypted at rest. It is never uploaded.'**
  String get privacyWifiAnalysisBody;

  /// No description provided for @privacyLanInventoryTitle.
  ///
  /// In en, this message translates to:
  /// **'LAN Device Inventory'**
  String get privacyLanInventoryTitle;

  /// No description provided for @privacyLanInventoryBody.
  ///
  /// In en, this message translates to:
  /// **'When you run a LAN scan, the app collects IP/MAC/hostname/vendor/open ports for devices on the same network. This may include third-party devices — anonymisation is on by default for exports.'**
  String get privacyLanInventoryBody;

  /// No description provided for @privacyLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Location Permission (Wi-Fi only)'**
  String get privacyLocationTitle;

  /// No description provided for @privacyLocationBody.
  ///
  /// In en, this message translates to:
  /// **'Android requires the location permission to enable Wi-Fi scanning. Torcav uses it strictly for that — we do not read GPS coordinates and we do not track movement.'**
  String get privacyLocationBody;

  /// No description provided for @privacySensorsTitle.
  ///
  /// In en, this message translates to:
  /// **'Sensors & Heatmap'**
  String get privacySensorsTitle;

  /// No description provided for @privacySensorsBody.
  ///
  /// In en, this message translates to:
  /// **'Activity recognition + IMU/barometer are used during heatmap surveys to map signal strength to your relative path (origin = scan start). GPS is not used.'**
  String get privacySensorsBody;

  /// No description provided for @privacyAiTitle.
  ///
  /// In en, this message translates to:
  /// **'AI / Local Classification'**
  String get privacyAiTitle;

  /// No description provided for @privacyAiBody.
  ///
  /// In en, this message translates to:
  /// **'Device-type identification uses a local ONNX model. No proprietary or vendor data leaves the device.'**
  String get privacyAiBody;

  /// No description provided for @privacyExternalEndpointsTitle.
  ///
  /// In en, this message translates to:
  /// **'EXTERNAL ENDPOINTS'**
  String get privacyExternalEndpointsTitle;

  /// No description provided for @privacyCloudflareTitle.
  ///
  /// In en, this message translates to:
  /// **'Cloudflare Speed Test'**
  String get privacyCloudflareTitle;

  /// No description provided for @privacyCloudflareBody.
  ///
  /// In en, this message translates to:
  /// **'Speed Doctor and the speed-test page download/upload ~300-500 MB against speed.cloudflare.com. Cloudflare sees your IP — no Torcav identifier or telemetry is attached.'**
  String get privacyCloudflareBody;

  /// No description provided for @privacyDnsProbesTitle.
  ///
  /// In en, this message translates to:
  /// **'Public DNS Probes'**
  String get privacyDnsProbesTitle;

  /// No description provided for @privacyDnsProbesBody.
  ///
  /// In en, this message translates to:
  /// **'1.1.1.1, 8.8.8.8, 9.9.9.9, OpenDNS and AdGuard are queried for DNS benchmark and leak detection. They see standard DNS queries (no user identifiers).'**
  String get privacyDnsProbesBody;

  /// No description provided for @privacyCaptivePortalTitle.
  ///
  /// In en, this message translates to:
  /// **'Captive Portal Probe'**
  String get privacyCaptivePortalTitle;

  /// No description provided for @privacyCaptivePortalBody.
  ///
  /// In en, this message translates to:
  /// **'connectivitycheck.gstatic.com receives a plain HEAD request to detect captive portals. This is the same probe Android itself runs.'**
  String get privacyCaptivePortalBody;

  /// No description provided for @privacyNoTrackersTitle.
  ///
  /// In en, this message translates to:
  /// **'No Analytics, No Trackers, No Ads'**
  String get privacyNoTrackersTitle;

  /// No description provided for @privacyNoTrackersBody.
  ///
  /// In en, this message translates to:
  /// **'There are zero analytics SDKs, zero advertising IDs, zero crash-reporting services in v1.0. We do not phone home on app start.'**
  String get privacyNoTrackersBody;

  /// No description provided for @privacyRetentionTitle.
  ///
  /// In en, this message translates to:
  /// **'RETENTION & DELETION'**
  String get privacyRetentionTitle;

  /// No description provided for @privacyConfigRetentionTitle.
  ///
  /// In en, this message translates to:
  /// **'Configurable Retention'**
  String get privacyConfigRetentionTitle;

  /// No description provided for @privacyConfigRetentionBody.
  ///
  /// In en, this message translates to:
  /// **'Settings → Privacy lets you set retention windows (7-365 days) for scan history, speed tests, and security events. Default is 30 days. Old records prune automatically.'**
  String get privacyConfigRetentionBody;

  /// No description provided for @privacyWipeLocalDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Wipe All Local Data'**
  String get privacyWipeLocalDataTitle;

  /// No description provided for @privacyWipeLocalDataBody.
  ///
  /// In en, this message translates to:
  /// **'A single tap in Settings → Privacy clears every persisted record: scans, devices, security events, heatmap sessions, LAN history, exports. Irreversible.'**
  String get privacyWipeLocalDataBody;

  /// No description provided for @privacyRightsTitle.
  ///
  /// In en, this message translates to:
  /// **'YOUR RIGHTS'**
  String get privacyRightsTitle;

  /// No description provided for @privacyKvkkGdprTitle.
  ///
  /// In en, this message translates to:
  /// **'KVKK (Turkey) + GDPR (EU/EEA)'**
  String get privacyKvkkGdprTitle;

  /// No description provided for @privacyRightsBody.
  ///
  /// In en, this message translates to:
  /// **'You can request access, correction, deletion, or portability of your data. For deletion, the in-app Wipe All button is the fastest path. For other requests, email {email} — we respond within 30 days.'**
  String privacyRightsBody(String email);

  /// No description provided for @privacyChildrenTitle.
  ///
  /// In en, this message translates to:
  /// **'Children\'s Privacy'**
  String get privacyChildrenTitle;

  /// No description provided for @privacyChildrenBody.
  ///
  /// In en, this message translates to:
  /// **'Torcav is not directed at users under 13 and presumes the user is old enough to take responsibility for the network being scanned.'**
  String get privacyChildrenBody;

  /// No description provided for @privacyAuthorisedUseTitle.
  ///
  /// In en, this message translates to:
  /// **'Authorised Use Only'**
  String get privacyAuthorisedUseTitle;

  /// No description provided for @privacyAuthorisedUseBody.
  ///
  /// In en, this message translates to:
  /// **'Use Torcav on networks you own or are explicitly authorised to scan. Active LAN discovery and port scanning on networks you do not own may violate Turkish, EU, and US laws.'**
  String get privacyAuthorisedUseBody;

  /// No description provided for @privacyContactLabel.
  ///
  /// In en, this message translates to:
  /// **'CONTACT'**
  String get privacyContactLabel;

  /// No description provided for @privacyEffectiveDate.
  ///
  /// In en, this message translates to:
  /// **'Effective 2026-05-08 • Version 1.0'**
  String get privacyEffectiveDate;

  /// No description provided for @hardeningTitle.
  ///
  /// In en, this message translates to:
  /// **'ROUTER HARDENING'**
  String get hardeningTitle;

  /// No description provided for @hardeningSubtitle.
  ///
  /// In en, this message translates to:
  /// **'SECURE YOUR GATEWAY'**
  String get hardeningSubtitle;

  /// No description provided for @hardeningMarkDone.
  ///
  /// In en, this message translates to:
  /// **'MARK DONE'**
  String get hardeningMarkDone;

  /// No description provided for @hardeningOpenAdmin.
  ///
  /// In en, this message translates to:
  /// **'OPEN ADMIN PANEL'**
  String get hardeningOpenAdmin;

  /// No description provided for @hardeningStepsTitle.
  ///
  /// In en, this message translates to:
  /// **'ACTION STEPS'**
  String get hardeningStepsTitle;

  /// No description provided for @hardeningMenuHintsTitle.
  ///
  /// In en, this message translates to:
  /// **'COMMON MENU NAMES'**
  String get hardeningMenuHintsTitle;

  /// No description provided for @hardeningCriticalBadge.
  ///
  /// In en, this message translates to:
  /// **'CRITICAL'**
  String get hardeningCriticalBadge;

  /// No description provided for @hardeningChangeAdminPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change router admin password'**
  String get hardeningChangeAdminPasswordTitle;

  /// No description provided for @hardeningChangeAdminPasswordBody.
  ///
  /// In en, this message translates to:
  /// **'Default admin credentials (admin/admin, admin/password) are publicly documented. Anyone on your Wi-Fi can open the admin panel and rewrite settings — DNS hijack, redirect traffic, lock you out.'**
  String get hardeningChangeAdminPasswordBody;

  /// No description provided for @hardeningChangeAdminPasswordStep1.
  ///
  /// In en, this message translates to:
  /// **'Tap the big OPEN ADMIN PANEL button at the top of this page. Your browser will open the router login page.'**
  String get hardeningChangeAdminPasswordStep1;

  /// No description provided for @hardeningChangeAdminPasswordStep2.
  ///
  /// In en, this message translates to:
  /// **'Log in. Try \"admin\" as username and \"admin\" or \"password\" as password if you haven\'t changed it.'**
  String get hardeningChangeAdminPasswordStep2;

  /// No description provided for @hardeningChangeAdminPasswordStep3.
  ///
  /// In en, this message translates to:
  /// **'Find a menu named \"Administration\", \"System\", \"Maintenance\" or \"Account\".'**
  String get hardeningChangeAdminPasswordStep3;

  /// No description provided for @hardeningChangeAdminPasswordStep4.
  ///
  /// In en, this message translates to:
  /// **'Inside that menu look for \"Login password\", \"Admin password\" or \"Change password\".'**
  String get hardeningChangeAdminPasswordStep4;

  /// No description provided for @hardeningChangeAdminPasswordStep5.
  ///
  /// In en, this message translates to:
  /// **'Pick a NEW password — at least 12 characters, mix uppercase, lowercase, numbers and a symbol.'**
  String get hardeningChangeAdminPasswordStep5;

  /// No description provided for @hardeningChangeAdminPasswordStep6.
  ///
  /// In en, this message translates to:
  /// **'Save / Apply. The router may reboot for ~30 seconds.'**
  String get hardeningChangeAdminPasswordStep6;

  /// No description provided for @hardeningChangeAdminPasswordStep7.
  ///
  /// In en, this message translates to:
  /// **'Write the new password down somewhere safe.'**
  String get hardeningChangeAdminPasswordStep7;

  /// No description provided for @hardeningChangeAdminPasswordStep8.
  ///
  /// In en, this message translates to:
  /// **'Once saved, come back here and tap MARK DONE.'**
  String get hardeningChangeAdminPasswordStep8;

  /// No description provided for @hardeningUseWpa3OrWpa2AesTitle.
  ///
  /// In en, this message translates to:
  /// **'Use WPA3, fall back to WPA2-AES'**
  String get hardeningUseWpa3OrWpa2AesTitle;

  /// No description provided for @hardeningUseWpa3OrWpa2AesBody.
  ///
  /// In en, this message translates to:
  /// **'WPA3 is the modern Wi-Fi encryption standard. WPA/TKIP and WEP can be cracked in minutes.'**
  String get hardeningUseWpa3OrWpa2AesBody;

  /// No description provided for @hardeningDisableWpsTitle.
  ///
  /// In en, this message translates to:
  /// **'Disable WPS'**
  String get hardeningDisableWpsTitle;

  /// No description provided for @hardeningDisableWpsBody.
  ///
  /// In en, this message translates to:
  /// **'WPS lets attackers bypass your Wi-Fi password in hours. Turn it off.'**
  String get hardeningDisableWpsBody;

  /// No description provided for @hardeningEnablePmfTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable PMF / 802.11w'**
  String get hardeningEnablePmfTitle;

  /// No description provided for @hardeningEnablePmfBody.
  ///
  /// In en, this message translates to:
  /// **'Protected Management Frames stop attackers from knocking your devices offline.'**
  String get hardeningEnablePmfBody;

  /// No description provided for @hardeningEnableGuestNetworkTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable a guest network'**
  String get hardeningEnableGuestNetworkTitle;

  /// No description provided for @hardeningEnableGuestNetworkBody.
  ///
  /// In en, this message translates to:
  /// **'A second SSID for visitors and IoT devices keeps your private network safe.'**
  String get hardeningEnableGuestNetworkBody;

  /// No description provided for @hardeningDisableRemoteAdminTitle.
  ///
  /// In en, this message translates to:
  /// **'Disable remote / WAN-side admin'**
  String get hardeningDisableRemoteAdminTitle;

  /// No description provided for @hardeningDisableRemoteAdminBody.
  ///
  /// In en, this message translates to:
  /// **'If the admin panel is reachable from the internet, anyone can try default passwords.'**
  String get hardeningDisableRemoteAdminBody;

  /// No description provided for @hardeningUpdateFirmwareTitle.
  ///
  /// In en, this message translates to:
  /// **'Update firmware'**
  String get hardeningUpdateFirmwareTitle;

  /// No description provided for @hardeningUpdateFirmwareBody.
  ///
  /// In en, this message translates to:
  /// **'Most home routers have known security holes that vendors patch quietly.'**
  String get hardeningUpdateFirmwareBody;

  /// No description provided for @hardeningStrongPassphraseTitle.
  ///
  /// In en, this message translates to:
  /// **'Use a strong Wi-Fi passphrase'**
  String get hardeningStrongPassphraseTitle;

  /// No description provided for @hardeningStrongPassphraseBody.
  ///
  /// In en, this message translates to:
  /// **'12+ characters, mixed case, never reused from another service.'**
  String get hardeningStrongPassphraseBody;

  /// No description provided for @gatewayCopyError.
  ///
  /// In en, this message translates to:
  /// **'Could not open the browser automatically. Gateway IP {ip} has been copied — paste it into your browser\'s address bar.'**
  String gatewayCopyError(String ip);

  /// No description provided for @gatewayCopied.
  ///
  /// In en, this message translates to:
  /// **'Gateway IP {ip} copied to clipboard.'**
  String gatewayCopied(String ip);

  /// No description provided for @hardeningConnectWifiHint.
  ///
  /// In en, this message translates to:
  /// **'Connect to your home Wi-Fi to track progress per router. The checklist still works without a connection.'**
  String get hardeningConnectWifiHint;

  /// No description provided for @progressLabel.
  ///
  /// In en, this message translates to:
  /// **'PROGRESS'**
  String get progressLabel;

  /// No description provided for @tapToCopy.
  ///
  /// In en, this message translates to:
  /// **'tap to copy'**
  String get tapToCopy;

  /// No description provided for @hardeningOpenAdminDesc.
  ///
  /// In en, this message translates to:
  /// **'Launch your router login page in the browser'**
  String get hardeningOpenAdminDesc;

  /// No description provided for @hardeningConnectWifiRequired.
  ///
  /// In en, this message translates to:
  /// **'Connect to Wi-Fi first'**
  String get hardeningConnectWifiRequired;

  /// No description provided for @hardeningGatewayHintDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Once connected, the gateway IP appears above and the button will launch your browser.'**
  String get hardeningGatewayHintDisconnected;

  /// No description provided for @hardeningGatewayHintConnected.
  ///
  /// In en, this message translates to:
  /// **'Doesn\'t open? Tap the gateway IP above to copy it, then paste it into your browser\'s address bar (Chrome, Firefox, etc.).'**
  String get hardeningGatewayHintConnected;

  /// No description provided for @whyThisMattersLabel.
  ///
  /// In en, this message translates to:
  /// **'WHY THIS MATTERS'**
  String get whyThisMattersLabel;

  /// No description provided for @markAsTodoLabel.
  ///
  /// In en, this message translates to:
  /// **'MARK AS todo'**
  String get markAsTodoLabel;

  /// No description provided for @vpnRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Use a trusted VPN when connecting to unknown or untrusted networks.'**
  String get vpnRecommendation;

  /// No description provided for @exportLocalDataTitle.
  ///
  /// In en, this message translates to:
  /// **'EXPORT LOCAL DATA'**
  String get exportLocalDataTitle;

  /// No description provided for @exportLocalDataDesc.
  ///
  /// In en, this message translates to:
  /// **'Your data on this device, in your hands. Pick a category and share or save it as JSON.'**
  String get exportLocalDataDesc;

  /// No description provided for @exportCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get exportCategoryLabel;

  /// No description provided for @exportFormatLabel.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get exportFormatLabel;

  /// No description provided for @jsonExportLabel.
  ///
  /// In en, this message translates to:
  /// **'JSON — full, machine-readable'**
  String get jsonExportLabel;

  /// No description provided for @csvExportLabel.
  ///
  /// In en, this message translates to:
  /// **'CSV — opens in Excel/Sheets'**
  String get csvExportLabel;

  /// No description provided for @csvSingleCategoryOnlyLabel.
  ///
  /// In en, this message translates to:
  /// **'CSV — single category only'**
  String get csvSingleCategoryOnlyLabel;

  /// No description provided for @htmlExportLabel.
  ///
  /// In en, this message translates to:
  /// **'HTML — viewable in browser'**
  String get htmlExportLabel;

  /// No description provided for @anonymizeIdentifiersLabel.
  ///
  /// In en, this message translates to:
  /// **'Anonymize identifiers'**
  String get anonymizeIdentifiersLabel;

  /// No description provided for @anonymizeIdentifiersDesc.
  ///
  /// In en, this message translates to:
  /// **'Mask BSSID/MAC last 3 octets, redact SSID and hostname.'**
  String get anonymizeIdentifiersDesc;

  /// No description provided for @noIdentifiersToMaskDesc.
  ///
  /// In en, this message translates to:
  /// **'This category has no identifiers to mask.'**
  String get noIdentifiersToMaskDesc;

  /// No description provided for @exportingLabel.
  ///
  /// In en, this message translates to:
  /// **'EXPORTING…'**
  String get exportingLabel;

  /// No description provided for @exportAsLabel.
  ///
  /// In en, this message translates to:
  /// **'EXPORT AS {format}'**
  String exportAsLabel(String format);

  /// No description provided for @exportPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Stays on your device until you share it. Nothing is sent to any server.'**
  String get exportPrivacyNote;

  /// No description provided for @exportFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportFailedMessage(String error);

  /// No description provided for @noDataInCategoryMessage.
  ///
  /// In en, this message translates to:
  /// **'No data in \"{category}\" yet.'**
  String noDataInCategoryMessage(String category);

  /// No description provided for @categoryWifiScanHistory.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi scan history'**
  String get categoryWifiScanHistory;

  /// No description provided for @categorySpeedTestResults.
  ///
  /// In en, this message translates to:
  /// **'Speed test results'**
  String get categorySpeedTestResults;

  /// No description provided for @categorySecurityEvents.
  ///
  /// In en, this message translates to:
  /// **'Security events'**
  String get categorySecurityEvents;

  /// No description provided for @categoryKnownAndTrustedNetworks.
  ///
  /// In en, this message translates to:
  /// **'Known + trusted networks'**
  String get categoryKnownAndTrustedNetworks;

  /// No description provided for @categoryChannelRatingsHistory.
  ///
  /// In en, this message translates to:
  /// **'Channel ratings history'**
  String get categoryChannelRatingsHistory;

  /// No description provided for @categoryHeatmapSessions.
  ///
  /// In en, this message translates to:
  /// **'Heatmap sessions'**
  String get categoryHeatmapSessions;

  /// No description provided for @categoryLanScanLatest.
  ///
  /// In en, this message translates to:
  /// **'LAN scan (latest)'**
  String get categoryLanScanLatest;

  /// No description provided for @categoryDeviceLabelOverrides.
  ///
  /// In en, this message translates to:
  /// **'Device label overrides'**
  String get categoryDeviceLabelOverrides;

  /// No description provided for @categoryPinnedNetworks.
  ///
  /// In en, this message translates to:
  /// **'Pinned networks'**
  String get categoryPinnedNetworks;

  /// No description provided for @categoryScoreHistory.
  ///
  /// In en, this message translates to:
  /// **'Security score history'**
  String get categoryScoreHistory;

  /// No description provided for @categoryNetworkContextOverrides.
  ///
  /// In en, this message translates to:
  /// **'Network context overrides'**
  String get categoryNetworkContextOverrides;

  /// No description provided for @categoryRouterHardeningProgress.
  ///
  /// In en, this message translates to:
  /// **'Router hardening progress'**
  String get categoryRouterHardeningProgress;

  /// No description provided for @macRandomizedLabel.
  ///
  /// In en, this message translates to:
  /// **'MAC Randomized'**
  String get macRandomizedLabel;

  /// No description provided for @notificationsBlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications are blocked'**
  String get notificationsBlockedTitle;

  /// No description provided for @notificationsBlockedDesc.
  ///
  /// In en, this message translates to:
  /// **'The live ping HUD lives in the notification shade. Without notifications you cannot see ping while gaming. On MIUI/Xiaomi, also enable \"Show on Lock screen\" and \"Floating notifications\".'**
  String get notificationsBlockedDesc;

  /// No description provided for @liveLatencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Live latency'**
  String get liveLatencyLabel;

  /// No description provided for @latencyStatLabel.
  ///
  /// In en, this message translates to:
  /// **'Latency'**
  String get latencyStatLabel;

  /// No description provided for @jitterStatLabel.
  ///
  /// In en, this message translates to:
  /// **'Jitter'**
  String get jitterStatLabel;

  /// No description provided for @lossStatLabel.
  ///
  /// In en, this message translates to:
  /// **'Loss'**
  String get lossStatLabel;

  /// No description provided for @baselineLatencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Baseline (pre-tunnel): {ms} ms'**
  String baselineLatencyLabel(String ms);

  /// No description provided for @jitterThresholdLabel.
  ///
  /// In en, this message translates to:
  /// **'Jitter alarm threshold: {ms} ms'**
  String jitterThresholdLabel(String ms);

  /// No description provided for @heatmapSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Heatmap Settings'**
  String get heatmapSettingsTitle;

  /// No description provided for @dnsLabel.
  ///
  /// In en, this message translates to:
  /// **'DNS'**
  String get dnsLabel;

  /// No description provided for @notNowLabel.
  ///
  /// In en, this message translates to:
  /// **'NOT NOW'**
  String get notNowLabel;

  /// No description provided for @newNetworkLabel.
  ///
  /// In en, this message translates to:
  /// **'+ NEW'**
  String get newNetworkLabel;

  /// No description provided for @goneNetworkLabel.
  ///
  /// In en, this message translates to:
  /// **'GONE'**
  String get goneNetworkLabel;

  /// No description provided for @hiddenNetworkLabel.
  ///
  /// In en, this message translates to:
  /// **'[Hidden]'**
  String get hiddenNetworkLabel;

  /// No description provided for @randomizedMacDetectedLabel.
  ///
  /// In en, this message translates to:
  /// **'Randomized MAC Detected'**
  String get randomizedMacDetectedLabel;

  /// No description provided for @howPingStabilizerWorksTitle.
  ///
  /// In en, this message translates to:
  /// **'How Ping Stabilizer works'**
  String get howPingStabilizerWorksTitle;

  /// No description provided for @stabilizerExplainerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'On-device, no remote servers, free.'**
  String get stabilizerExplainerSubtitle;

  /// No description provided for @whatItDoesTitle.
  ///
  /// In en, this message translates to:
  /// **'What it does'**
  String get whatItDoesTitle;

  /// No description provided for @whatItDoesBullet1.
  ///
  /// In en, this message translates to:
  /// **'Establishes a local VPN tunnel on your device — no traffic leaves through any third-party server.'**
  String get whatItDoesBullet1;

  /// No description provided for @whatItDoesBullet2.
  ///
  /// In en, this message translates to:
  /// **'Routes DNS queries to the fastest resolver (1.1.1.1, 8.8.8.8, 9.9.9.9, …) measured live.'**
  String get whatItDoesBullet2;

  /// No description provided for @whatItDoesBullet3.
  ///
  /// In en, this message translates to:
  /// **'Watches latency / jitter every second and warns you when a spike persists, optionally cycling the tunnel to break a sticky bad path.'**
  String get whatItDoesBullet3;

  /// No description provided for @whatItDoesBullet4.
  ///
  /// In en, this message translates to:
  /// **'Uses an EWMA filter (recent samples weighted heavier) so it reacts to real degradation, not single-packet noise.'**
  String get whatItDoesBullet4;

  /// No description provided for @whatItDoesNotTitle.
  ///
  /// In en, this message translates to:
  /// **'What it does NOT do'**
  String get whatItDoesNotTitle;

  /// No description provided for @whatItDoesNotBullet1.
  ///
  /// In en, this message translates to:
  /// **'It cannot make your ISP\'s route to the game server physically shorter — no on-device app can.'**
  String get whatItDoesNotBullet1;

  /// No description provided for @whatItDoesNotBullet2.
  ///
  /// In en, this message translates to:
  /// **'It does not replace a paid VPN/relay service like ExitLag or WTFast (those route via their own servers; this is local-only).'**
  String get whatItDoesNotBullet2;

  /// No description provided for @whatItDoesNotBullet3.
  ///
  /// In en, this message translates to:
  /// **'Multi-path \"first-wins\" send across Wi-Fi + cellular is on the roadmap (Phase 2) and currently disabled.'**
  String get whatItDoesNotBullet3;

  /// No description provided for @risksAndThingsToKnowTitle.
  ///
  /// In en, this message translates to:
  /// **'Risks & things to know'**
  String get risksAndThingsToKnowTitle;

  /// No description provided for @risksBullet1.
  ///
  /// In en, this message translates to:
  /// **'Android shows a key icon while the tunnel is active — that is normal and required by the system.'**
  String get risksBullet1;

  /// No description provided for @risksBullet2.
  ///
  /// In en, this message translates to:
  /// **'Only one VPN can run at a time. If you have another VPN app connected, this will refuse to start.'**
  String get risksBullet2;

  /// No description provided for @risksBullet3.
  ///
  /// In en, this message translates to:
  /// **'A persistent live notification (current ping + Stop / Cycle buttons) stays in the shade while the tunnel runs — that is your in-game HUD; do not swipe it away.'**
  String get risksBullet3;

  /// No description provided for @risksBullet4.
  ///
  /// In en, this message translates to:
  /// **'On Xiaomi/MIUI, OnePlus/OxygenOS and similar skins, you may need to allow Torcav under Settings → Notifications and Settings → Battery → No restrictions, or the OS will silently hide the notification.'**
  String get risksBullet4;

  /// No description provided for @risksBullet5.
  ///
  /// In en, this message translates to:
  /// **'DNS auto-switch will change which resolver answers your queries while the tunnel is on. That switch reverts when you stop the stabilizer.'**
  String get risksBullet5;

  /// No description provided for @risksBullet6.
  ///
  /// In en, this message translates to:
  /// **'Battery use is small (~3-5%/hr in our tests) but non-zero — turn it off when you\'re done playing.'**
  String get risksBullet6;

  /// No description provided for @shieldIntegrityLabel.
  ///
  /// In en, this message translates to:
  /// **'SHIELD INTEGRITY'**
  String get shieldIntegrityLabel;

  /// No description provided for @activeThreatsLabel.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE THREATS'**
  String get activeThreatsLabel;

  /// No description provided for @shieldStatusOptimal.
  ///
  /// In en, this message translates to:
  /// **'OPTIMAL'**
  String get shieldStatusOptimal;

  /// No description provided for @shieldStatusWarning.
  ///
  /// In en, this message translates to:
  /// **'WARNING'**
  String get shieldStatusWarning;

  /// No description provided for @shieldStatusCritical.
  ///
  /// In en, this message translates to:
  /// **'CRITICAL'**
  String get shieldStatusCritical;

  /// No description provided for @securityScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'SECURITY SCORE'**
  String get securityScoreLabel;

  /// No description provided for @systemStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'SYSTEM STATUS'**
  String get systemStatusLabel;

  /// No description provided for @scanningAllCaps.
  ///
  /// In en, this message translates to:
  /// **'SCANNING'**
  String get scanningAllCaps;

  /// No description provided for @bssidLabel.
  ///
  /// In en, this message translates to:
  /// **'BSSID: {bssid}'**
  String bssidLabel(String bssid);

  /// No description provided for @gatewayWithIpLabel.
  ///
  /// In en, this message translates to:
  /// **'GATEWAY: {gateway}'**
  String gatewayWithIpLabel(String gateway);

  /// No description provided for @trustedBadge.
  ///
  /// In en, this message translates to:
  /// **'TRUSTED'**
  String get trustedBadge;

  /// No description provided for @identifiedBadge.
  ///
  /// In en, this message translates to:
  /// **'IDENTIFIED'**
  String get identifiedBadge;

  /// No description provided for @authEstablishedLabel.
  ///
  /// In en, this message translates to:
  /// **'AUTH: ESTABLISHED {date}'**
  String authEstablishedLabel(String date);

  /// No description provided for @revokeTrustTooltip.
  ///
  /// In en, this message translates to:
  /// **'REVOKE TRUST'**
  String get revokeTrustTooltip;

  /// No description provided for @apsLabel.
  ///
  /// In en, this message translates to:
  /// **'APs'**
  String get apsLabel;

  /// No description provided for @openLabel.
  ///
  /// In en, this message translates to:
  /// **'OPEN'**
  String get openLabel;

  /// No description provided for @wpsLabel.
  ///
  /// In en, this message translates to:
  /// **'WPS'**
  String get wpsLabel;

  /// No description provided for @wepLabel.
  ///
  /// In en, this message translates to:
  /// **'WEP'**
  String get wepLabel;

  /// No description provided for @publicWifiLabel.
  ///
  /// In en, this message translates to:
  /// **'PUBLIC WI-FI'**
  String get publicWifiLabel;

  /// No description provided for @guestNetworkLabel.
  ///
  /// In en, this message translates to:
  /// **'GUEST NETWORK'**
  String get guestNetworkLabel;

  /// No description provided for @publicWifiDesc.
  ///
  /// In en, this message translates to:
  /// **'Open or untrusted network — assume traffic can be observed.'**
  String get publicWifiDesc;

  /// No description provided for @guestNetworkDesc.
  ///
  /// In en, this message translates to:
  /// **'You are on a guest segment. Treat as untrusted by default.'**
  String get guestNetworkDesc;

  /// No description provided for @tipVpnTitle.
  ///
  /// In en, this message translates to:
  /// **'Use a VPN'**
  String get tipVpnTitle;

  /// No description provided for @tipVpnBody.
  ///
  /// In en, this message translates to:
  /// **'Tunnel traffic through a trusted VPN before sending anything sensitive. Built-in OS VPN is fine for most users.'**
  String get tipVpnBody;

  /// No description provided for @tipHttpsTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify HTTPS'**
  String get tipHttpsTitle;

  /// No description provided for @tipHttpsBody.
  ///
  /// In en, this message translates to:
  /// **'Only enter credentials on sites with a locked padlock. Reject certificate warnings — they are how attackers strip TLS.'**
  String get tipHttpsBody;

  /// No description provided for @tipSensitiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Defer sensitive actions'**
  String get tipSensitiveTitle;

  /// No description provided for @tipSensitiveBody.
  ///
  /// In en, this message translates to:
  /// **'Avoid banking, payments, password resets and account logins until you are back on a trusted network.'**
  String get tipSensitiveBody;

  /// No description provided for @tipDnsTitle.
  ///
  /// In en, this message translates to:
  /// **'Check DNS health'**
  String get tipDnsTitle;

  /// No description provided for @tipDnsBody.
  ///
  /// In en, this message translates to:
  /// **'Public hotspots can hijack DNS. Run a DNS test from this screen to confirm responses are not being rewritten.'**
  String get tipDnsBody;

  /// No description provided for @evilTwinPrefix.
  ///
  /// In en, this message translates to:
  /// **'EVIL TWIN · {confidence}'**
  String evilTwinPrefix(String confidence);

  /// No description provided for @whatIsEvilTwinTitle.
  ///
  /// In en, this message translates to:
  /// **'What is an evil-twin?'**
  String get whatIsEvilTwinTitle;

  /// No description provided for @whyItMattersTitle.
  ///
  /// In en, this message translates to:
  /// **'Why does it matter?'**
  String get whyItMattersTitle;

  /// No description provided for @whatWeObservedTitle.
  ///
  /// In en, this message translates to:
  /// **'What we observed'**
  String get whatWeObservedTitle;

  /// No description provided for @whatLookedLegitimateTitle.
  ///
  /// In en, this message translates to:
  /// **'What looked legitimate'**
  String get whatLookedLegitimateTitle;

  /// No description provided for @whatYouShouldDoTitle.
  ///
  /// In en, this message translates to:
  /// **'What you should do'**
  String get whatYouShouldDoTitle;

  /// No description provided for @hardeningUseWpa3OrWpa2AesStep1.
  ///
  /// In en, this message translates to:
  /// **'Open the admin panel using the button at the top.'**
  String get hardeningUseWpa3OrWpa2AesStep1;

  /// No description provided for @hardeningUseWpa3OrWpa2AesStep2.
  ///
  /// In en, this message translates to:
  /// **'Find the wireless section: \"Wireless\", \"Wi-Fi\" or \"WLAN\".'**
  String get hardeningUseWpa3OrWpa2AesStep2;

  /// No description provided for @hardeningUseWpa3OrWpa2AesStep3.
  ///
  /// In en, this message translates to:
  /// **'Look for a security or encryption setting — usually called \"Security mode\", \"Authentication\" or \"Encryption\".'**
  String get hardeningUseWpa3OrWpa2AesStep3;

  /// No description provided for @hardeningUseWpa3OrWpa2AesStep4.
  ///
  /// In en, this message translates to:
  /// **'Choose the strongest option in this order: WPA3-Personal > WPA2/WPA3 mixed > WPA2-Personal (AES). Avoid anything labelled \"WPA-PSK\", \"TKIP\", \"WEP\" or \"Open\" — these are insecure.'**
  String get hardeningUseWpa3OrWpa2AesStep4;

  /// No description provided for @hardeningUseWpa3OrWpa2AesStep5.
  ///
  /// In en, this message translates to:
  /// **'If you set WPA3-Personal and an old device (smart bulb, printer, older phone) stops working, switch to \"WPA2/WPA3 mixed\" — that lets old gear connect while new devices still use WPA3.'**
  String get hardeningUseWpa3OrWpa2AesStep5;

  /// No description provided for @hardeningUseWpa3OrWpa2AesStep6.
  ///
  /// In en, this message translates to:
  /// **'If you have separate 2.4 GHz and 5 GHz settings, change BOTH bands.'**
  String get hardeningUseWpa3OrWpa2AesStep6;

  /// No description provided for @hardeningUseWpa3OrWpa2AesStep7.
  ///
  /// In en, this message translates to:
  /// **'Save / Apply. Your devices may briefly disconnect — they will rejoin in a few seconds.'**
  String get hardeningUseWpa3OrWpa2AesStep7;

  /// No description provided for @hardeningUseWpa3OrWpa2AesStep8.
  ///
  /// In en, this message translates to:
  /// **'Come back here and tap MARK DONE.'**
  String get hardeningUseWpa3OrWpa2AesStep8;

  /// No description provided for @hardeningDisableWpsStep1.
  ///
  /// In en, this message translates to:
  /// **'Open the admin panel.'**
  String get hardeningDisableWpsStep1;

  /// No description provided for @hardeningDisableWpsStep2.
  ///
  /// In en, this message translates to:
  /// **'Find the Wireless or Wi-Fi section.'**
  String get hardeningDisableWpsStep2;

  /// No description provided for @hardeningDisableWpsStep3.
  ///
  /// In en, this message translates to:
  /// **'Look for a sub-menu called \"WPS\", \"Easy Setup\", \"Quick Connect\" or a tab inside Wireless Settings labelled WPS.'**
  String get hardeningDisableWpsStep3;

  /// No description provided for @hardeningDisableWpsStep4.
  ///
  /// In en, this message translates to:
  /// **'Switch the WPS toggle to OFF / Disabled.'**
  String get hardeningDisableWpsStep4;

  /// No description provided for @hardeningDisableWpsStep5.
  ///
  /// In en, this message translates to:
  /// **'Some routers also have a physical WPS button on the device — that will stop working too, which is the goal.'**
  String get hardeningDisableWpsStep5;

  /// No description provided for @hardeningDisableWpsStep6.
  ///
  /// In en, this message translates to:
  /// **'Save / Apply.'**
  String get hardeningDisableWpsStep6;

  /// No description provided for @hardeningDisableWpsStep7.
  ///
  /// In en, this message translates to:
  /// **'From now on, when you connect a new device just type the Wi-Fi password normally. Takes 10 extra seconds, removes a serious attack path.'**
  String get hardeningDisableWpsStep7;

  /// No description provided for @hardeningDisableWpsStep8.
  ///
  /// In en, this message translates to:
  /// **'Come back here and tap MARK DONE.'**
  String get hardeningDisableWpsStep8;

  /// No description provided for @hardeningEnablePmfStep1.
  ///
  /// In en, this message translates to:
  /// **'Open the admin panel.'**
  String get hardeningEnablePmfStep1;

  /// No description provided for @hardeningEnablePmfStep2.
  ///
  /// In en, this message translates to:
  /// **'Go to the Wireless / Wi-Fi section.'**
  String get hardeningEnablePmfStep2;

  /// No description provided for @hardeningEnablePmfStep3.
  ///
  /// In en, this message translates to:
  /// **'Look in \"Advanced\" or \"Wireless Security\" for a setting called \"PMF\", \"802.11w\" or \"Management Frame Protection\".'**
  String get hardeningEnablePmfStep3;

  /// No description provided for @hardeningEnablePmfStep4.
  ///
  /// In en, this message translates to:
  /// **'Set it to \"Required\" if all your devices are recent (last ~5 years). If older devices stop seeing the network, change it to \"Optional / Capable\" — that still helps, just less strictly.'**
  String get hardeningEnablePmfStep4;

  /// No description provided for @hardeningEnablePmfStep5.
  ///
  /// In en, this message translates to:
  /// **'If you cannot find this setting at all, your router may have it baked into WPA3 mode (so completing item 2 above already covers it). In that case, tap MARK DONE here too.'**
  String get hardeningEnablePmfStep5;

  /// No description provided for @hardeningEnablePmfStep6.
  ///
  /// In en, this message translates to:
  /// **'Save / Apply.'**
  String get hardeningEnablePmfStep6;

  /// No description provided for @hardeningEnablePmfStep7.
  ///
  /// In en, this message translates to:
  /// **'Come back here and tap MARK DONE.'**
  String get hardeningEnablePmfStep7;

  /// No description provided for @hardeningEnableGuestNetworkStep1.
  ///
  /// In en, this message translates to:
  /// **'Open the admin panel.'**
  String get hardeningEnableGuestNetworkStep1;

  /// No description provided for @hardeningEnableGuestNetworkStep2.
  ///
  /// In en, this message translates to:
  /// **'Find a menu called \"Guest Network\", \"Guest Wi-Fi\" or \"Multi-SSID\".'**
  String get hardeningEnableGuestNetworkStep2;

  /// No description provided for @hardeningEnableGuestNetworkStep3.
  ///
  /// In en, this message translates to:
  /// **'Enable it. Give it a different name from your main Wi-Fi — for example, if your main is \"Home\", call the guest one \"Home-Guest\".'**
  String get hardeningEnableGuestNetworkStep3;

  /// No description provided for @hardeningEnableGuestNetworkStep4.
  ///
  /// In en, this message translates to:
  /// **'Set a password. It can be simpler than your main one (guests will type it), but still 10+ characters.'**
  String get hardeningEnableGuestNetworkStep4;

  /// No description provided for @hardeningEnableGuestNetworkStep5.
  ///
  /// In en, this message translates to:
  /// **'Look for a setting called \"Client Isolation\", \"AP Isolation\" or \"Guest network isolation\". Turn it ON. This stops guest devices from talking to each other or to your private network.'**
  String get hardeningEnableGuestNetworkStep5;

  /// No description provided for @hardeningEnableGuestNetworkStep6.
  ///
  /// In en, this message translates to:
  /// **'Move your IoT devices (smart plugs, cameras, robot vacuum, smart TV) over to the guest network — connect them with the new password.'**
  String get hardeningEnableGuestNetworkStep6;

  /// No description provided for @hardeningEnableGuestNetworkStep7.
  ///
  /// In en, this message translates to:
  /// **'Save / Apply.'**
  String get hardeningEnableGuestNetworkStep7;

  /// No description provided for @hardeningEnableGuestNetworkStep8.
  ///
  /// In en, this message translates to:
  /// **'Come back here and tap MARK DONE.'**
  String get hardeningEnableGuestNetworkStep8;

  /// No description provided for @hardeningDisableRemoteAdminStep1.
  ///
  /// In en, this message translates to:
  /// **'Open the admin panel.'**
  String get hardeningDisableRemoteAdminStep1;

  /// No description provided for @hardeningDisableRemoteAdminStep2.
  ///
  /// In en, this message translates to:
  /// **'Go to \"Administration\", \"System Tools\" or \"Security\".'**
  String get hardeningDisableRemoteAdminStep2;

  /// No description provided for @hardeningDisableRemoteAdminStep3.
  ///
  /// In en, this message translates to:
  /// **'Find a setting called \"Remote Management\", \"Web Access from WAN\" or \"Remote admin\".'**
  String get hardeningDisableRemoteAdminStep3;

  /// No description provided for @hardeningDisableRemoteAdminStep4.
  ///
  /// In en, this message translates to:
  /// **'Switch it OFF / Disabled.'**
  String get hardeningDisableRemoteAdminStep4;

  /// No description provided for @hardeningDisableRemoteAdminStep5.
  ///
  /// In en, this message translates to:
  /// **'While here, also check for \"Cloud / Remote App access\" (some brands have this — TP-Link Tether, Asus Router app, Mi Wi-Fi). If you do not actively use that app, turn it off too.'**
  String get hardeningDisableRemoteAdminStep5;

  /// No description provided for @hardeningDisableRemoteAdminStep6.
  ///
  /// In en, this message translates to:
  /// **'Save / Apply.'**
  String get hardeningDisableRemoteAdminStep6;

  /// No description provided for @hardeningDisableRemoteAdminStep7.
  ///
  /// In en, this message translates to:
  /// **'You can still manage your router from inside your home — only the remote / public-internet path is closed.'**
  String get hardeningDisableRemoteAdminStep7;

  /// No description provided for @hardeningDisableRemoteAdminStep8.
  ///
  /// In en, this message translates to:
  /// **'Come back here and tap MARK DONE.'**
  String get hardeningDisableRemoteAdminStep8;

  /// No description provided for @hardeningUpdateFirmwareStep1.
  ///
  /// In en, this message translates to:
  /// **'Open the admin panel.'**
  String get hardeningUpdateFirmwareStep1;

  /// No description provided for @hardeningUpdateFirmwareStep2.
  ///
  /// In en, this message translates to:
  /// **'Find a menu called \"Firmware Update\", \"System Update\", \"Online Upgrade\" or \"Maintenance\".'**
  String get hardeningUpdateFirmwareStep2;

  /// No description provided for @hardeningUpdateFirmwareStep3.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Check for update\" or \"Online check\". The router will look for a newer version on the vendor server.'**
  String get hardeningUpdateFirmwareStep3;

  /// No description provided for @hardeningUpdateFirmwareStep4.
  ///
  /// In en, this message translates to:
  /// **'If an update is offered, install it. The router will reboot for 2-5 minutes — do NOT unplug it during the update or it can become a paperweight.'**
  String get hardeningUpdateFirmwareStep4;

  /// No description provided for @hardeningUpdateFirmwareStep5.
  ///
  /// In en, this message translates to:
  /// **'After it comes back, go to the same menu and look for \"Auto update\" or \"Automatic upgrade\". Turn it ON if available.'**
  String get hardeningUpdateFirmwareStep5;

  /// No description provided for @hardeningUpdateFirmwareStep6.
  ///
  /// In en, this message translates to:
  /// **'Some older routers do not have online updates. In that case, note the router model from the device sticker, search the vendor website, download the latest firmware file, and use the \"Manual upload\" option in the same menu.'**
  String get hardeningUpdateFirmwareStep6;

  /// No description provided for @hardeningUpdateFirmwareStep7.
  ///
  /// In en, this message translates to:
  /// **'Come back here and tap MARK DONE.'**
  String get hardeningUpdateFirmwareStep7;

  /// No description provided for @hardeningStrongPassphraseStep1.
  ///
  /// In en, this message translates to:
  /// **'Open the admin panel.'**
  String get hardeningStrongPassphraseStep1;

  /// No description provided for @hardeningStrongPassphraseStep2.
  ///
  /// In en, this message translates to:
  /// **'Go to \"Wireless\", \"Wi-Fi\" or \"WLAN\".'**
  String get hardeningStrongPassphraseStep2;

  /// No description provided for @hardeningStrongPassphraseStep3.
  ///
  /// In en, this message translates to:
  /// **'Find the password field — labelled \"Wireless password\", \"Pre-Shared Key (PSK)\", \"Wireless Key\" or simply \"Password\".'**
  String get hardeningStrongPassphraseStep3;

  /// No description provided for @hardeningStrongPassphraseStep4.
  ///
  /// In en, this message translates to:
  /// **'Replace it with a NEW passphrase: at least 12 characters, with a mix of uppercase, lowercase, numbers and a symbol. Avoid dictionary words and personal info (birthdays, pet names).'**
  String get hardeningStrongPassphraseStep4;

  /// No description provided for @hardeningStrongPassphraseStep5.
  ///
  /// In en, this message translates to:
  /// **'A good trick: pick three unrelated words plus a number, e.g. \"correct-horse-battery-9\". Long passphrases are harder to crack than short complex ones.'**
  String get hardeningStrongPassphraseStep5;

  /// No description provided for @hardeningStrongPassphraseStep6.
  ///
  /// In en, this message translates to:
  /// **'If you have separate 2.4 GHz and 5 GHz networks, change BOTH.'**
  String get hardeningStrongPassphraseStep6;

  /// No description provided for @hardeningStrongPassphraseStep7.
  ///
  /// In en, this message translates to:
  /// **'Save / Apply. Every device will disconnect — re-enter the new password on each one.'**
  String get hardeningStrongPassphraseStep7;

  /// No description provided for @hardeningStrongPassphraseStep8.
  ///
  /// In en, this message translates to:
  /// **'Write the password down (password manager, fridge note for visitors, whatever works for you).'**
  String get hardeningStrongPassphraseStep8;

  /// No description provided for @hardeningStrongPassphraseStep9.
  ///
  /// In en, this message translates to:
  /// **'Come back here and tap MARK DONE.'**
  String get hardeningStrongPassphraseStep9;

  /// No description provided for @severity_critical.
  ///
  /// In en, this message translates to:
  /// **'CRITICAL'**
  String get severity_critical;

  /// No description provided for @severity_high.
  ///
  /// In en, this message translates to:
  /// **'HIGH'**
  String get severity_high;

  /// No description provided for @severity_medium.
  ///
  /// In en, this message translates to:
  /// **'MEDIUM'**
  String get severity_medium;

  /// No description provided for @severity_low.
  ///
  /// In en, this message translates to:
  /// **'LOW'**
  String get severity_low;

  /// No description provided for @severity_info.
  ///
  /// In en, this message translates to:
  /// **'INFO'**
  String get severity_info;

  /// No description provided for @rule_scan_deep_scan_active_title.
  ///
  /// In en, this message translates to:
  /// **'Active Probing Active'**
  String get rule_scan_deep_scan_active_title;

  /// No description provided for @rule_scan_deep_scan_active_desc.
  ///
  /// In en, this message translates to:
  /// **'Deep scan is enabled, performing more intrusive network tests.'**
  String get rule_scan_deep_scan_active_desc;

  /// No description provided for @rule_scan_deep_scan_active_rec.
  ///
  /// In en, this message translates to:
  /// **'Use only on networks you own or have permission to scan.'**
  String get rule_scan_deep_scan_active_rec;

  /// No description provided for @rule_wifi_open_network_title.
  ///
  /// In en, this message translates to:
  /// **'Open Network'**
  String get rule_wifi_open_network_title;

  /// No description provided for @rule_wifi_open_network_desc.
  ///
  /// In en, this message translates to:
  /// **'No encryption detected. All traffic can be sniffed in plaintext.'**
  String get rule_wifi_open_network_desc;

  /// No description provided for @rule_wifi_open_network_rec.
  ///
  /// In en, this message translates to:
  /// **'Avoid sensitive activity. Prefer trusted VPN or different network.'**
  String get rule_wifi_open_network_rec;

  /// No description provided for @rule_wifi_wep_title.
  ///
  /// In en, this message translates to:
  /// **'WEP Encryption'**
  String get rule_wifi_wep_title;

  /// No description provided for @rule_wifi_wep_desc.
  ///
  /// In en, this message translates to:
  /// **'WEP is deprecated and can be cracked quickly.'**
  String get rule_wifi_wep_desc;

  /// No description provided for @rule_wifi_wep_rec.
  ///
  /// In en, this message translates to:
  /// **'Reconfigure AP to WPA2 or WPA3 immediately.'**
  String get rule_wifi_wep_rec;

  /// No description provided for @rule_wifi_legacy_wpa_title.
  ///
  /// In en, this message translates to:
  /// **'Legacy WPA'**
  String get rule_wifi_legacy_wpa_title;

  /// No description provided for @rule_wifi_legacy_wpa_desc.
  ///
  /// In en, this message translates to:
  /// **'WPA/TKIP is older and weaker against modern attack techniques.'**
  String get rule_wifi_legacy_wpa_desc;

  /// No description provided for @rule_wifi_legacy_wpa_rec.
  ///
  /// In en, this message translates to:
  /// **'Upgrade AP and clients to WPA2/WPA3.'**
  String get rule_wifi_legacy_wpa_rec;

  /// No description provided for @rule_wifi_hidden_ssid_title.
  ///
  /// In en, this message translates to:
  /// **'Hidden SSID'**
  String get rule_wifi_hidden_ssid_title;

  /// No description provided for @rule_wifi_hidden_ssid_desc.
  ///
  /// In en, this message translates to:
  /// **'Hidden SSIDs are still discoverable and may hurt compatibility.'**
  String get rule_wifi_hidden_ssid_desc;

  /// No description provided for @rule_wifi_hidden_ssid_rec.
  ///
  /// In en, this message translates to:
  /// **'Hidden SSID alone is not protection. Focus on strong encryption.'**
  String get rule_wifi_hidden_ssid_rec;

  /// No description provided for @rule_wifi_very_weak_signal_title.
  ///
  /// In en, this message translates to:
  /// **'Very Weak Signal'**
  String get rule_wifi_very_weak_signal_title;

  /// No description provided for @rule_wifi_very_weak_signal_desc.
  ///
  /// In en, this message translates to:
  /// **'Weak signal can indicate unstable links and spoofing susceptibility.'**
  String get rule_wifi_very_weak_signal_desc;

  /// No description provided for @rule_wifi_very_weak_signal_rec.
  ///
  /// In en, this message translates to:
  /// **'Move closer to AP or validate BSSID consistency.'**
  String get rule_wifi_very_weak_signal_rec;

  /// No description provided for @rule_wifi_wps_enabled_title.
  ///
  /// In en, this message translates to:
  /// **'WPS Enabled'**
  String get rule_wifi_wps_enabled_title;

  /// No description provided for @rule_wifi_wps_enabled_desc.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi Protected Setup (WPS) is enabled. The WPS PIN mode can be brute-forced in hours, bypassing any password.'**
  String get rule_wifi_wps_enabled_desc;

  /// No description provided for @rule_wifi_wps_enabled_rec.
  ///
  /// In en, this message translates to:
  /// **'Disable WPS in your router admin panel. Use WPA2/WPA3 passphrase only.'**
  String get rule_wifi_wps_enabled_rec;

  /// No description provided for @rule_wifi_pmf_not_enforced_title.
  ///
  /// In en, this message translates to:
  /// **'Management Frames Unprotected'**
  String get rule_wifi_pmf_not_enforced_title;

  /// No description provided for @rule_wifi_pmf_not_enforced_desc.
  ///
  /// In en, this message translates to:
  /// **'This access point does not enforce Protected Management Frames (PMF / 802.11w), allowing deauthentication attacks.'**
  String get rule_wifi_pmf_not_enforced_desc;

  /// No description provided for @rule_wifi_pmf_not_enforced_rec.
  ///
  /// In en, this message translates to:
  /// **'Enable PMF in your router settings (often labelled \"802.11w\" or \"Management Frame Protection\").'**
  String get rule_wifi_pmf_not_enforced_rec;

  /// No description provided for @rule_wifi_suspicious_sibling_ap_title.
  ///
  /// In en, this message translates to:
  /// **'Potential Evil Twin'**
  String get rule_wifi_suspicious_sibling_ap_title;

  /// No description provided for @rule_wifi_suspicious_sibling_ap_desc.
  ///
  /// In en, this message translates to:
  /// **'A nearby access point shares this SSID but its fingerprint doesn\'t match — that\'s the pattern an attacker uses to impersonate a real Wi-Fi.'**
  String get rule_wifi_suspicious_sibling_ap_desc;

  /// No description provided for @rule_wifi_suspicious_sibling_ap_rec.
  ///
  /// In en, this message translates to:
  /// **'Don\'t enter passwords on this network until you\'ve verified the BSSID on the back of your router.'**
  String get rule_wifi_suspicious_sibling_ap_rec;

  /// No description provided for @rule_wifi_suspicious_ssid_title.
  ///
  /// In en, this message translates to:
  /// **'Suspicious Network Name'**
  String get rule_wifi_suspicious_ssid_title;

  /// No description provided for @rule_wifi_suspicious_ssid_desc.
  ///
  /// In en, this message translates to:
  /// **'This SSID matches common honeypot/lure patterns (e.g. \"Free WiFi\") used by attackers to trick users.'**
  String get rule_wifi_suspicious_ssid_desc;

  /// No description provided for @rule_wifi_suspicious_ssid_rec.
  ///
  /// In en, this message translates to:
  /// **'Verify this network with the venue operator before connecting. Use a VPN if you must connect.'**
  String get rule_wifi_suspicious_ssid_rec;

  /// No description provided for @rule_wifi_high_channel_congestion_title.
  ///
  /// In en, this message translates to:
  /// **'High Channel Congestion'**
  String get rule_wifi_high_channel_congestion_title;

  /// No description provided for @rule_wifi_high_channel_congestion_desc.
  ///
  /// In en, this message translates to:
  /// **'Heavy congestion on this channel degrades performance and connection reliability.'**
  String get rule_wifi_high_channel_congestion_desc;

  /// No description provided for @rule_wifi_high_channel_congestion_rec.
  ///
  /// In en, this message translates to:
  /// **'Ask the network admin to switch to a less congested channel.'**
  String get rule_wifi_high_channel_congestion_rec;

  /// No description provided for @rule_wifi_only_24ghz_title.
  ///
  /// In en, this message translates to:
  /// **'2.4 GHz Only'**
  String get rule_wifi_only_24ghz_title;

  /// No description provided for @rule_wifi_only_24ghz_desc.
  ///
  /// In en, this message translates to:
  /// **'This network only broadcasts on the crowded 2.4 GHz band. 5 GHz offers better performance.'**
  String get rule_wifi_only_24ghz_desc;

  /// No description provided for @rule_wifi_only_24ghz_rec.
  ///
  /// In en, this message translates to:
  /// **'Enable 5 GHz band on your router for better performance.'**
  String get rule_wifi_only_24ghz_rec;

  /// No description provided for @rule_trusted_baseline_drift_title.
  ///
  /// In en, this message translates to:
  /// **'Trusted Baseline Drift'**
  String get rule_trusted_baseline_drift_title;

  /// No description provided for @rule_trusted_baseline_drift_desc.
  ///
  /// In en, this message translates to:
  /// **'This access point no longer matches the fingerprint you previously trusted.'**
  String get rule_trusted_baseline_drift_desc;

  /// No description provided for @rule_trusted_baseline_drift_rec.
  ///
  /// In en, this message translates to:
  /// **'Re-validate the router configuration and only re-trust if the change was intentional.'**
  String get rule_trusted_baseline_drift_rec;

  /// No description provided for @rule_hardware_vulnerability_title.
  ///
  /// In en, this message translates to:
  /// **'Vulnerable Hardware'**
  String get rule_hardware_vulnerability_title;

  /// No description provided for @rule_hardware_vulnerability_desc.
  ///
  /// In en, this message translates to:
  /// **'BSSID prefix matches a known vulnerable hardware profile.'**
  String get rule_hardware_vulnerability_desc;

  /// No description provided for @rule_hardware_vulnerability_rec.
  ///
  /// In en, this message translates to:
  /// **'Check for manufacturer firmware updates addressing known CVEs for this model.'**
  String get rule_hardware_vulnerability_rec;

  /// No description provided for @noLiveScanAvailable.
  ///
  /// In en, this message translates to:
  /// **'NO LIVE SCAN AVAILABLE'**
  String get noLiveScanAvailable;

  /// No description provided for @noLiveScanDesc.
  ///
  /// In en, this message translates to:
  /// **'We don\'t have a fresh Wi-Fi scan that includes \"{ssid}\" right now, so the live signal breakdown isn\'t available. Run a new Wi-Fi scan from the Discovery tab and reopen this alert to see the full evidence.'**
  String noLiveScanDesc(String ssid);

  /// No description provided for @outOf100Label.
  ///
  /// In en, this message translates to:
  /// **'/100'**
  String get outOf100Label;

  /// No description provided for @networkLabel.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get networkLabel;

  /// No description provided for @noActivityYet.
  ///
  /// In en, this message translates to:
  /// **'NO ACTIVITY YET'**
  String get noActivityYet;

  /// No description provided for @runFirstScanDesc.
  ///
  /// In en, this message translates to:
  /// **'Run your first scan to populate the timeline.'**
  String get runFirstScanDesc;

  /// No description provided for @networkContextTitle.
  ///
  /// In en, this message translates to:
  /// **'NETWORK CONTEXT'**
  String get networkContextTitle;

  /// No description provided for @networkContextHomeDesc.
  ///
  /// In en, this message translates to:
  /// **'Your home, office, or known router. Strict standards apply.'**
  String get networkContextHomeDesc;

  /// No description provided for @networkContextPublicDesc.
  ///
  /// In en, this message translates to:
  /// **'Café, hotel, airport, or open hotspot. VPN/HTTPS strongly advised.'**
  String get networkContextPublicDesc;

  /// No description provided for @networkContextGuestDesc.
  ///
  /// In en, this message translates to:
  /// **'Guest segment of a known network. Natural drift expected.'**
  String get networkContextGuestDesc;

  /// No description provided for @networkContextUnknownDesc.
  ///
  /// In en, this message translates to:
  /// **'Let Torcav infer the context from passive signals.'**
  String get networkContextUnknownDesc;

  /// No description provided for @scanVia.
  ///
  /// In en, this message translates to:
  /// **'Scan via {backend}'**
  String scanVia(String backend);

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String hoursAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String daysAgo(int count);

  /// No description provided for @rogueApSuspected.
  ///
  /// In en, this message translates to:
  /// **'Rogue AP suspected'**
  String get rogueApSuspected;

  /// No description provided for @deauthActivity.
  ///
  /// In en, this message translates to:
  /// **'Deauth activity'**
  String get deauthActivity;

  /// No description provided for @handshakeCaptureStarted.
  ///
  /// In en, this message translates to:
  /// **'Handshake capture started'**
  String get handshakeCaptureStarted;

  /// No description provided for @handshakeCaptured.
  ///
  /// In en, this message translates to:
  /// **'Handshake captured'**
  String get handshakeCaptured;

  /// No description provided for @captivePortal.
  ///
  /// In en, this message translates to:
  /// **'Captive portal'**
  String get captivePortal;

  /// No description provided for @evilTwinDetected.
  ///
  /// In en, this message translates to:
  /// **'Evil twin detected'**
  String get evilTwinDetected;

  /// No description provided for @encryptionDowngrade.
  ///
  /// In en, this message translates to:
  /// **'Encryption downgrade'**
  String get encryptionDowngrade;

  /// No description provided for @unsupportedOp.
  ///
  /// In en, this message translates to:
  /// **'Unsupported op'**
  String get unsupportedOp;

  /// No description provided for @arpSpoofing.
  ///
  /// In en, this message translates to:
  /// **'ARP spoofing'**
  String get arpSpoofing;

  /// No description provided for @dnsHijacking.
  ///
  /// In en, this message translates to:
  /// **'DNS hijacking'**
  String get dnsHijacking;

  /// No description provided for @speedDoctorDesc.
  ///
  /// In en, this message translates to:
  /// **'Resolve latency and throughput issues.'**
  String get speedDoctorDesc;

  /// No description provided for @bestChannelTitle.
  ///
  /// In en, this message translates to:
  /// **'BEST CHANNEL'**
  String get bestChannelTitle;

  /// No description provided for @bestChannelDesc.
  ///
  /// In en, this message translates to:
  /// **'Switching to channel {channel} could improve quality.'**
  String bestChannelDesc(int channel);

  /// No description provided for @networksWithCount.
  ///
  /// In en, this message translates to:
  /// **'Networks ({count})'**
  String networksWithCount(int count);

  /// No description provided for @throughputMbps.
  ///
  /// In en, this message translates to:
  /// **'{count} Mbps'**
  String throughputMbps(int count);

  /// No description provided for @signalStability.
  ///
  /// In en, this message translates to:
  /// **'Stability {stability}'**
  String signalStability(String stability);

  /// No description provided for @metricSignal.
  ///
  /// In en, this message translates to:
  /// **'SIGNAL'**
  String get metricSignal;

  /// No description provided for @metricScoreTrend.
  ///
  /// In en, this message translates to:
  /// **'SCORE TREND'**
  String get metricScoreTrend;

  /// No description provided for @metricChannels.
  ///
  /// In en, this message translates to:
  /// **'CHANNELS'**
  String get metricChannels;

  /// No description provided for @metricNewDevices.
  ///
  /// In en, this message translates to:
  /// **'NEW DEVICES'**
  String get metricNewDevices;

  /// No description provided for @metricThreats.
  ///
  /// In en, this message translates to:
  /// **'THREATS'**
  String get metricThreats;

  /// No description provided for @metricSpeed.
  ///
  /// In en, this message translates to:
  /// **'SPEED'**
  String get metricSpeed;

  /// No description provided for @severityCrit.
  ///
  /// In en, this message translates to:
  /// **'CRIT'**
  String get severityCrit;

  /// No description provided for @severityHighShort.
  ///
  /// In en, this message translates to:
  /// **'HIGH'**
  String get severityHighShort;

  /// No description provided for @severityMedShort.
  ///
  /// In en, this message translates to:
  /// **'MED'**
  String get severityMedShort;

  /// No description provided for @severityInfoShort.
  ///
  /// In en, this message translates to:
  /// **'INFO'**
  String get severityInfoShort;

  /// No description provided for @hardenRouterTitle.
  ///
  /// In en, this message translates to:
  /// **'HARDEN ROUTER'**
  String get hardenRouterTitle;

  /// No description provided for @hardenRouterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Security checklist'**
  String get hardenRouterSubtitle;

  /// No description provided for @packetLossLabel.
  ///
  /// In en, this message translates to:
  /// **'PACKET LOSS'**
  String get packetLossLabel;

  /// No description provided for @loadedLatencyLabel.
  ///
  /// In en, this message translates to:
  /// **'LOADED LATENCY'**
  String get loadedLatencyLabel;

  /// No description provided for @clearHistoryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear all history'**
  String get clearHistoryTooltip;

  /// No description provided for @whatIsThisSection.
  ///
  /// In en, this message translates to:
  /// **'What is this?'**
  String get whatIsThisSection;

  /// No description provided for @whyItMattersSection.
  ///
  /// In en, this message translates to:
  /// **'Why it matters'**
  String get whyItMattersSection;

  /// No description provided for @covShort.
  ///
  /// In en, this message translates to:
  /// **'COV'**
  String get covShort;

  /// No description provided for @sigShort.
  ///
  /// In en, this message translates to:
  /// **'SIG'**
  String get sigShort;

  /// No description provided for @motShort.
  ///
  /// In en, this message translates to:
  /// **'MOT'**
  String get motShort;

  /// No description provided for @wifiShort.
  ///
  /// In en, this message translates to:
  /// **'WIFI'**
  String get wifiShort;

  /// No description provided for @camShort.
  ///
  /// In en, this message translates to:
  /// **'CAM'**
  String get camShort;

  /// No description provided for @discardSurveyTooltip.
  ///
  /// In en, this message translates to:
  /// **'Discard Survey'**
  String get discardSurveyTooltip;

  /// No description provided for @finishReviewTooltip.
  ///
  /// In en, this message translates to:
  /// **'Finish & Review'**
  String get finishReviewTooltip;

  /// No description provided for @noDataAtLocation.
  ///
  /// In en, this message translates to:
  /// **'NO DATA AT THIS LOCATION'**
  String get noDataAtLocation;

  /// No description provided for @rssiLabel.
  ///
  /// In en, this message translates to:
  /// **'RSSI'**
  String get rssiLabel;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'STATUS'**
  String get statusLabel;

  /// No description provided for @floorLabel.
  ///
  /// In en, this message translates to:
  /// **'FLOOR'**
  String get floorLabel;

  /// No description provided for @positionLabel.
  ///
  /// In en, this message translates to:
  /// **'POSITION'**
  String get positionLabel;

  /// No description provided for @samplesLabel.
  ///
  /// In en, this message translates to:
  /// **'SAMPLES'**
  String get samplesLabel;

  /// No description provided for @capturedLabel.
  ///
  /// In en, this message translates to:
  /// **'CAPTURED'**
  String get capturedLabel;

  /// No description provided for @heatmapPermissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'HEATMAP PERMISSIONS'**
  String get heatmapPermissionsTitle;

  /// No description provided for @realignCompassTooltip.
  ///
  /// In en, this message translates to:
  /// **'Realign Compass'**
  String get realignCompassTooltip;

  /// No description provided for @osDetectLabel.
  ///
  /// In en, this message translates to:
  /// **'OS DETECT'**
  String get osDetectLabel;

  /// No description provided for @exportCsvLabel.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsvLabel;

  /// No description provided for @thisDeviceLabel.
  ///
  /// In en, this message translates to:
  /// **'This Device'**
  String get thisDeviceLabel;

  /// No description provided for @setDeviceType.
  ///
  /// In en, this message translates to:
  /// **'Set Device Type'**
  String get setDeviceType;

  /// No description provided for @resetToAiLabel.
  ///
  /// In en, this message translates to:
  /// **'Reset to AI label'**
  String get resetToAiLabel;

  /// No description provided for @gatewayCaps.
  ///
  /// In en, this message translates to:
  /// **'GATEWAY'**
  String get gatewayCaps;

  /// No description provided for @identifiedCaps.
  ///
  /// In en, this message translates to:
  /// **'IDENTIFIED'**
  String get identifiedCaps;

  /// No description provided for @unknownMacRestricted.
  ///
  /// In en, this message translates to:
  /// **'UNKNOWN MAC (RESTRICTED)'**
  String get unknownMacRestricted;

  /// No description provided for @scanPortsCaps.
  ///
  /// In en, this message translates to:
  /// **'SCAN PORTS'**
  String get scanPortsCaps;

  /// No description provided for @noOpenPortsFound.
  ///
  /// In en, this message translates to:
  /// **'No open ports found'**
  String get noOpenPortsFound;

  /// No description provided for @criticalCaps.
  ///
  /// In en, this message translates to:
  /// **'CRITICAL'**
  String get criticalCaps;

  /// No description provided for @wpsActiveCaps.
  ///
  /// In en, this message translates to:
  /// **'WPS ACTIVE'**
  String get wpsActiveCaps;

  /// No description provided for @osDetectAction.
  ///
  /// In en, this message translates to:
  /// **'OS DETECT'**
  String get osDetectAction;

  /// No description provided for @osDetectedLabel.
  ///
  /// In en, this message translates to:
  /// **'OS DETECTED'**
  String get osDetectedLabel;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'ALL'**
  String get filterAll;

  /// No description provided for @filterCore.
  ///
  /// In en, this message translates to:
  /// **'CORE'**
  String get filterCore;

  /// No description provided for @filterMobile.
  ///
  /// In en, this message translates to:
  /// **'MOBILE'**
  String get filterMobile;

  /// No description provided for @filterIot.
  ///
  /// In en, this message translates to:
  /// **'IOT'**
  String get filterIot;

  /// No description provided for @filterOther.
  ///
  /// In en, this message translates to:
  /// **'OTHER'**
  String get filterOther;

  /// No description provided for @protectPdfTitle.
  ///
  /// In en, this message translates to:
  /// **'PROTECT PDF WITH A PASSWORD'**
  String get protectPdfTitle;

  /// No description provided for @pdfLockedHint.
  ///
  /// In en, this message translates to:
  /// **'Optional. Locked file: .torcav-pdf — open it again from Reports.'**
  String get pdfLockedHint;

  /// No description provided for @pdfLockedLabel.
  ///
  /// In en, this message translates to:
  /// **'Locked file: .torcav-pdf — open it again from Reports.'**
  String get pdfLockedLabel;

  /// No description provided for @pdfPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Password (leave empty for plain PDF)'**
  String get pdfPasswordHint;

  /// No description provided for @pdfPasswordWarning.
  ///
  /// In en, this message translates to:
  /// **'Heads up: this is lightweight obfuscation, not bank-grade encryption. It protects the file against casual leaks (cloud thumbnails, mailbox cache) but a determined attacker who has the file could still attempt to brute-force a weak password. Use a long, unique passphrase.'**
  String get pdfPasswordWarning;

  /// No description provided for @understandEnable.
  ///
  /// In en, this message translates to:
  /// **'I UNDERSTAND — ENABLE'**
  String get understandEnable;

  /// No description provided for @categorySignal.
  ///
  /// In en, this message translates to:
  /// **'Signal'**
  String get categorySignal;

  /// No description provided for @categoryChannel.
  ///
  /// In en, this message translates to:
  /// **'Channel'**
  String get categoryChannel;

  /// No description provided for @categoryBufferbloat.
  ///
  /// In en, this message translates to:
  /// **'Bufferbloat'**
  String get categoryBufferbloat;

  /// No description provided for @categoryIsp.
  ///
  /// In en, this message translates to:
  /// **'ISP throughput'**
  String get categoryIsp;

  /// No description provided for @categoryDns.
  ///
  /// In en, this message translates to:
  /// **'DNS'**
  String get categoryDns;

  /// No description provided for @categoryHealthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get categoryHealthy;

  /// No description provided for @severityHigh.
  ///
  /// In en, this message translates to:
  /// **'HIGH'**
  String get severityHigh;

  /// No description provided for @severityMed.
  ///
  /// In en, this message translates to:
  /// **'MED'**
  String get severityMed;

  /// No description provided for @severityLow.
  ///
  /// In en, this message translates to:
  /// **'LOW'**
  String get severityLow;

  /// No description provided for @speedDoctorActionMoveCloser.
  ///
  /// In en, this message translates to:
  /// **'Move closer to router'**
  String get speedDoctorActionMoveCloser;

  /// No description provided for @speedDoctorActionAddMesh.
  ///
  /// In en, this message translates to:
  /// **'Add a mesh node'**
  String get speedDoctorActionAddMesh;

  /// No description provided for @speedDoctorActionSwitchTo5Ghz.
  ///
  /// In en, this message translates to:
  /// **'Switch to 5 GHz'**
  String get speedDoctorActionSwitchTo5Ghz;

  /// No description provided for @speedDoctorActionChangeChannel.
  ///
  /// In en, this message translates to:
  /// **'Change Wi-Fi channel'**
  String get speedDoctorActionChangeChannel;

  /// No description provided for @speedDoctorActionMoveTo5Ghz.
  ///
  /// In en, this message translates to:
  /// **'Move to 5/6 GHz band'**
  String get speedDoctorActionMoveTo5Ghz;

  /// No description provided for @speedDoctorActionEnableQos.
  ///
  /// In en, this message translates to:
  /// **'Enable router QoS'**
  String get speedDoctorActionEnableQos;

  /// No description provided for @speedDoctorActionUpdateFirmware.
  ///
  /// In en, this message translates to:
  /// **'Update router firmware'**
  String get speedDoctorActionUpdateFirmware;

  /// No description provided for @speedDoctorActionCallIsp.
  ///
  /// In en, this message translates to:
  /// **'Contact your ISP'**
  String get speedDoctorActionCallIsp;

  /// No description provided for @speedDoctorActionRunWiredTest.
  ///
  /// In en, this message translates to:
  /// **'Re-test with cable'**
  String get speedDoctorActionRunWiredTest;

  /// No description provided for @speedDoctorActionChangeDns.
  ///
  /// In en, this message translates to:
  /// **'Change DNS provider'**
  String get speedDoctorActionChangeDns;

  /// No description provided for @speedDoctorActionEnableDoh.
  ///
  /// In en, this message translates to:
  /// **'Enable DoH / DoT'**
  String get speedDoctorActionEnableDoh;

  /// No description provided for @waitingForHistory.
  ///
  /// In en, this message translates to:
  /// **'Waiting for history'**
  String get waitingForHistory;

  /// No description provided for @noScanData.
  ///
  /// In en, this message translates to:
  /// **'No scan data'**
  String get noScanData;

  /// No description provided for @mbps.
  ///
  /// In en, this message translates to:
  /// **'Mbps'**
  String get mbps;

  /// No description provided for @primaryCauseWeakSignalTitle.
  ///
  /// In en, this message translates to:
  /// **'WEAK SIGNAL'**
  String get primaryCauseWeakSignalTitle;

  /// No description provided for @primaryCauseWeakSignalDesc.
  ///
  /// In en, this message translates to:
  /// **'Your device is far from the router or has too many walls in the way. Move closer or add a mesh node in this area.'**
  String get primaryCauseWeakSignalDesc;

  /// No description provided for @primaryCauseCrowdedChannelTitle.
  ///
  /// In en, this message translates to:
  /// **'CROWDED CHANNEL'**
  String get primaryCauseCrowdedChannelTitle;

  /// No description provided for @primaryCauseCrowdedChannelDesc.
  ///
  /// In en, this message translates to:
  /// **'Several neighbouring access points are sharing your channel. Switching to a less crowded channel — or to 5/6 GHz — should help.'**
  String get primaryCauseCrowdedChannelDesc;

  /// No description provided for @primaryCauseBufferbloatTitle.
  ///
  /// In en, this message translates to:
  /// **'BUFFERBLOAT'**
  String get primaryCauseBufferbloatTitle;

  /// No description provided for @primaryCauseBufferbloatDesc.
  ///
  /// In en, this message translates to:
  /// **'Latency spikes when the link is busy. Enable QoS / SQM on your router to manage traffic spikes.'**
  String get primaryCauseBufferbloatDesc;

  /// No description provided for @primaryCauseIspSlowTitle.
  ///
  /// In en, this message translates to:
  /// **'ISP THROUGHPUT LIMIT'**
  String get primaryCauseIspSlowTitle;

  /// No description provided for @primaryCauseIspSlowDesc.
  ///
  /// In en, this message translates to:
  /// **'Your Wi-Fi link is healthy but the download speed is low. The bottleneck is most likely your internet plan or upstream provider.'**
  String get primaryCauseIspSlowDesc;

  /// No description provided for @primaryCauseSlowDnsTitle.
  ///
  /// In en, this message translates to:
  /// **'SLOW DNS'**
  String get primaryCauseSlowDnsTitle;

  /// No description provided for @primaryCauseSlowDnsDesc.
  ///
  /// In en, this message translates to:
  /// **'Names take too long to resolve. Switching DNS provider or enabling DoH/DoT typically removes the delay.'**
  String get primaryCauseSlowDnsDesc;

  /// No description provided for @primaryCauseHealthyTitle.
  ///
  /// In en, this message translates to:
  /// **'NETWORK HEALTHY'**
  String get primaryCauseHealthyTitle;

  /// No description provided for @primaryCauseHealthyDesc.
  ///
  /// In en, this message translates to:
  /// **'No bottleneck reached an alert threshold. Your link looks fine right now.'**
  String get primaryCauseHealthyDesc;

  /// No description provided for @diagStepReadingSignal.
  ///
  /// In en, this message translates to:
  /// **'Reading signal'**
  String get diagStepReadingSignal;

  /// No description provided for @diagStepAnalysingChannels.
  ///
  /// In en, this message translates to:
  /// **'Analysing channels'**
  String get diagStepAnalysingChannels;

  /// No description provided for @diagStepMeasuringSpeed.
  ///
  /// In en, this message translates to:
  /// **'Measuring speed'**
  String get diagStepMeasuringSpeed;

  /// No description provided for @diagStepBenchmarkingDns.
  ///
  /// In en, this message translates to:
  /// **'Benchmarking DNS'**
  String get diagStepBenchmarkingDns;

  /// No description provided for @hideDetails.
  ///
  /// In en, this message translates to:
  /// **'Hide details'**
  String get hideDetails;

  /// No description provided for @whatIsThisHowToFix.
  ///
  /// In en, this message translates to:
  /// **'What is this? · How to fix'**
  String get whatIsThisHowToFix;

  /// No description provided for @homePlanWifiHeatmap.
  ///
  /// In en, this message translates to:
  /// **'HOME PLAN + WIFI HEATMAP'**
  String get homePlanWifiHeatmap;

  /// No description provided for @homePlanWifiHeatmapDesc.
  ///
  /// In en, this message translates to:
  /// **'Outline, coverage, and weak zones'**
  String get homePlanWifiHeatmapDesc;

  /// No description provided for @openSavedSurveys.
  ///
  /// In en, this message translates to:
  /// **'Open saved surveys'**
  String get openSavedSurveys;

  /// No description provided for @toggleViewBlueprintNeon.
  ///
  /// In en, this message translates to:
  /// **'Toggle view (Blueprint / Neon)'**
  String get toggleViewBlueprintNeon;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @recording.
  ///
  /// In en, this message translates to:
  /// **'RECORDING'**
  String get recording;

  /// No description provided for @reviewing.
  ///
  /// In en, this message translates to:
  /// **'REVIEW'**
  String get reviewing;

  /// No description provided for @idle.
  ///
  /// In en, this message translates to:
  /// **'IDLE'**
  String get idle;

  /// No description provided for @surveyComplete.
  ///
  /// In en, this message translates to:
  /// **'SURVEY COMPLETE'**
  String get surveyComplete;

  /// No description provided for @surveyCompleteDesc.
  ///
  /// In en, this message translates to:
  /// **'The survey has been successfully recorded. Plan and signal data are synthesized.'**
  String get surveyCompleteDesc;

  /// No description provided for @coverage.
  ///
  /// In en, this message translates to:
  /// **'COVERAGE'**
  String get coverage;

  /// No description provided for @blindSpots.
  ///
  /// In en, this message translates to:
  /// **'BLIND SPOTS'**
  String get blindSpots;

  /// No description provided for @saveAndFinish.
  ///
  /// In en, this message translates to:
  /// **'SAVE & FINISH'**
  String get saveAndFinish;

  /// No description provided for @diagStepFinalizing.
  ///
  /// In en, this message translates to:
  /// **'Finalising diagnosis'**
  String get diagStepFinalizing;

  /// No description provided for @heatmapPageTitle.
  ///
  /// In en, this message translates to:
  /// **'HOME PLAN + WIFI HEATMAP'**
  String get heatmapPageTitle;

  /// No description provided for @heatmapPageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Outline, coverage, and weak zones'**
  String get heatmapPageSubtitle;

  /// No description provided for @heatmapHistoryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Open saved surveys'**
  String get heatmapHistoryTooltip;

  /// No description provided for @heatmapThemeToggleTooltip.
  ///
  /// In en, this message translates to:
  /// **'Toggle view (Blueprint / Neon)'**
  String get heatmapThemeToggleTooltip;

  /// No description provided for @heatmapSamplesShort.
  ///
  /// In en, this message translates to:
  /// **'samples'**
  String get heatmapSamplesShort;

  /// No description provided for @heatmapWallsShort.
  ///
  /// In en, this message translates to:
  /// **'walls'**
  String get heatmapWallsShort;

  /// No description provided for @heatmapRestartSurvey.
  ///
  /// In en, this message translates to:
  /// **'RESTART SURVEY'**
  String get heatmapRestartSurvey;

  /// No description provided for @heatmapRenameSurvey.
  ///
  /// In en, this message translates to:
  /// **'RENAME SURVEY'**
  String get heatmapRenameSurvey;

  /// No description provided for @heatmapShareHeatmap.
  ///
  /// In en, this message translates to:
  /// **'SHARE HEATMAP'**
  String get heatmapShareHeatmap;

  /// No description provided for @heatmapRenameDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'RENAME SURVEY'**
  String get heatmapRenameDialogTitle;

  /// No description provided for @heatmapSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get heatmapSave;

  /// No description provided for @heatmapShareSubject.
  ///
  /// In en, this message translates to:
  /// **'Torcav WiFi Heatmap'**
  String get heatmapShareSubject;

  /// No description provided for @heatmapShareText.
  ///
  /// In en, this message translates to:
  /// **'Sharing my WiFi heatmap result.'**
  String get heatmapShareText;

  /// No description provided for @heatmapIssueTitle.
  ///
  /// In en, this message translates to:
  /// **'Issue'**
  String get heatmapIssueTitle;

  /// No description provided for @heatmapGenericIssueBody.
  ///
  /// In en, this message translates to:
  /// **'The survey could not finish. Check permissions and device sensors.'**
  String get heatmapGenericIssueBody;

  /// No description provided for @heatmapGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'What This Feature Does'**
  String get heatmapGoalTitle;

  /// No description provided for @heatmapGoalBody.
  ///
  /// In en, this message translates to:
  /// **'It samples Wi-Fi as you walk, captures wall lines in AR, and then shows the home outline together with signal density.'**
  String get heatmapGoalBody;

  /// No description provided for @heatmapWaitingForDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Waiting For Data'**
  String get heatmapWaitingForDataTitle;

  /// No description provided for @heatmapWaitingForDataBody.
  ///
  /// In en, this message translates to:
  /// **'No signal sample has landed yet. Check motion and location permissions, then walk a few steps.'**
  String get heatmapWaitingForDataBody;

  /// No description provided for @heatmapArCaptureTitle.
  ///
  /// In en, this message translates to:
  /// **'AR Mode Active'**
  String get heatmapArCaptureTitle;

  /// No description provided for @heatmapArCaptureBody.
  ///
  /// In en, this message translates to:
  /// **'Point the phone at room edges and door openings. The camera searches for wall lines while signal points are added automatically as you move.'**
  String get heatmapArCaptureBody;

  /// No description provided for @heatmapMapCaptureTitle.
  ///
  /// In en, this message translates to:
  /// **'2D Map Active'**
  String get heatmapMapCaptureTitle;

  /// No description provided for @heatmapMapCaptureBody.
  ///
  /// In en, this message translates to:
  /// **'You are in the clearer 2D view. Samples keep arriving as you walk; if the outline stays weak, switch to AR mode.'**
  String get heatmapMapCaptureBody;

  /// No description provided for @heatmapReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Survey Summary'**
  String get heatmapReviewTitle;

  /// No description provided for @heatmapReviewBodyNoSamples.
  ///
  /// In en, this message translates to:
  /// **'There is a saved survey, but it still lacks meaningful signal samples.'**
  String get heatmapReviewBodyNoSamples;

  /// No description provided for @heatmapReviewBodyReady.
  ///
  /// In en, this message translates to:
  /// **'Coverage is readable. Use the summary below to inspect weak zones.'**
  String get heatmapReviewBodyReady;

  /// No description provided for @heatmapSamplesLabel.
  ///
  /// In en, this message translates to:
  /// **'SAMPLES'**
  String get heatmapSamplesLabel;

  /// No description provided for @heatmapWallsLabel.
  ///
  /// In en, this message translates to:
  /// **'WALLS'**
  String get heatmapWallsLabel;

  /// No description provided for @heatmapCurrentSignalLabel.
  ///
  /// In en, this message translates to:
  /// **'LIVE SIGNAL'**
  String get heatmapCurrentSignalLabel;

  /// No description provided for @heatmapAvgSignalLabel.
  ///
  /// In en, this message translates to:
  /// **'AVG SIGNAL'**
  String get heatmapAvgSignalLabel;

  /// No description provided for @heatmapWeakZonesLabel.
  ///
  /// In en, this message translates to:
  /// **'WEAK ZONES'**
  String get heatmapWeakZonesLabel;

  /// No description provided for @heatmapPlanSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'PLAN SIZE'**
  String get heatmapPlanSizeLabel;

  /// No description provided for @heatmapNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not ready'**
  String get heatmapNotAvailable;

  /// No description provided for @heatmapNoSamplesHelper.
  ///
  /// In en, this message translates to:
  /// **'Fills in as you start walking'**
  String get heatmapNoSamplesHelper;

  /// No description provided for @heatmapSamplesHelper.
  ///
  /// In en, this message translates to:
  /// **'{count} signal samples collected'**
  String heatmapSamplesHelper(int count);

  /// No description provided for @heatmapNoWallsHelper.
  ///
  /// In en, this message translates to:
  /// **'AR pass may be needed for the outline'**
  String get heatmapNoWallsHelper;

  /// No description provided for @heatmapWallsHelper.
  ///
  /// In en, this message translates to:
  /// **'{count} wall segments retained'**
  String heatmapWallsHelper(int count);

  /// No description provided for @heatmapSignalUnavailableHelper.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi reading has not arrived yet'**
  String get heatmapSignalUnavailableHelper;

  /// No description provided for @heatmapSignalStrongHelper.
  ///
  /// In en, this message translates to:
  /// **'Strong coverage'**
  String get heatmapSignalStrongHelper;

  /// No description provided for @heatmapSignalFairHelper.
  ///
  /// In en, this message translates to:
  /// **'Borderline but usable'**
  String get heatmapSignalFairHelper;

  /// No description provided for @heatmapSignalWeakHelper.
  ///
  /// In en, this message translates to:
  /// **'Weak or problematic zone'**
  String get heatmapSignalWeakHelper;

  /// No description provided for @heatmapWeakZoneHelperNone.
  ///
  /// In en, this message translates to:
  /// **'No obvious dead zones'**
  String get heatmapWeakZoneHelperNone;

  /// No description provided for @heatmapWeakZoneHelperOne.
  ///
  /// In en, this message translates to:
  /// **'One problematic area'**
  String get heatmapWeakZoneHelperOne;

  /// No description provided for @heatmapWeakZoneHelperMany.
  ///
  /// In en, this message translates to:
  /// **'{count} weak areas detected'**
  String heatmapWeakZoneHelperMany(int count);

  /// No description provided for @heatmapPlanSizeHelper.
  ///
  /// In en, this message translates to:
  /// **'Estimated span from captured trace'**
  String get heatmapPlanSizeHelper;

  /// No description provided for @heatmapNoSurveyYetTitle.
  ///
  /// In en, this message translates to:
  /// **'Start A Survey'**
  String get heatmapNoSurveyYetTitle;

  /// No description provided for @heatmapNoSurveyYetBody.
  ///
  /// In en, this message translates to:
  /// **'Start a walkthrough first. The result view will then show the outline and heatmap together.'**
  String get heatmapNoSurveyYetBody;

  /// No description provided for @heatmapWalkToBeginTitle.
  ///
  /// In en, this message translates to:
  /// **'Start Walking'**
  String get heatmapWalkToBeginTitle;

  /// No description provided for @heatmapWalkToBeginBody.
  ///
  /// In en, this message translates to:
  /// **'The trail and signal points appear as you take a few steps in each room.'**
  String get heatmapWalkToBeginBody;

  /// No description provided for @heatmapMapViewLabel.
  ///
  /// In en, this message translates to:
  /// **'2D HARITA'**
  String get heatmapMapViewLabel;

  /// No description provided for @heatmapResultViewLabel.
  ///
  /// In en, this message translates to:
  /// **'SONUC GORUNUMU'**
  String get heatmapResultViewLabel;

  /// No description provided for @heatmapFindingsTitle.
  ///
  /// In en, this message translates to:
  /// **'NE ANLATIYOR?'**
  String get heatmapFindingsTitle;

  /// No description provided for @heatmapInsightReady.
  ///
  /// In en, this message translates to:
  /// **'The survey is now dense enough. One last room transition is enough before saving the result.'**
  String get heatmapInsightReady;

  /// No description provided for @heatmapInsightTooEarly.
  ///
  /// In en, this message translates to:
  /// **'It is still too early. After 4-5 samples across a few rooms, the result becomes readable.'**
  String get heatmapInsightTooEarly;

  /// No description provided for @heatmapInsightNoWalls.
  ///
  /// In en, this message translates to:
  /// **'Signal is arriving but the outline is missing. Switch to AR and face the walls during another pass to improve the plan.'**
  String get heatmapInsightNoWalls;

  /// No description provided for @heatmapInsightLive.
  ///
  /// In en, this message translates to:
  /// **'The live result is starting to read well. With {count} samples, weak areas are becoming visible.'**
  String heatmapInsightLive(int count);

  /// No description provided for @heatmapReviewInsightNoSamples.
  ///
  /// In en, this message translates to:
  /// **'This survey has no signal samples. If location or motion permissions are off, the app cannot build the heatmap.'**
  String get heatmapReviewInsightNoSamples;

  /// No description provided for @heatmapReviewInsightNoPlan.
  ///
  /// In en, this message translates to:
  /// **'The heatmap is present but the outline is weak. On the next run, use AR and face room boundaries while walking.'**
  String get heatmapReviewInsightNoPlan;

  /// No description provided for @heatmapReviewInsightStrong.
  ///
  /// In en, this message translates to:
  /// **'Coverage looks strong overall. No clear dead zones are visible, and the outline agrees with the signal trace.'**
  String get heatmapReviewInsightStrong;

  /// No description provided for @heatmapReviewInsightWeak.
  ///
  /// In en, this message translates to:
  /// **'{count} weak zones are visible. Moving the router more centrally or adding another access point may help.'**
  String heatmapReviewInsightWeak(int count);

  /// No description provided for @heatmapReviewInsightBalanced.
  ///
  /// In en, this message translates to:
  /// **'Coverage is reasonably balanced, but it dips in {count} spots. These are often corners, corridor ends, or heavy wall transitions.'**
  String heatmapReviewInsightBalanced(int count);

  /// No description provided for @heatmapCloseReview.
  ///
  /// In en, this message translates to:
  /// **'CLOSE REVIEW'**
  String get heatmapCloseReview;

  /// No description provided for @heatmapNewSurvey.
  ///
  /// In en, this message translates to:
  /// **'NEW SURVEY'**
  String get heatmapNewSurvey;

  /// No description provided for @heatmapFinishAndReview.
  ///
  /// In en, this message translates to:
  /// **'FINISH & REVIEW'**
  String get heatmapFinishAndReview;

  /// No description provided for @heatmapStartSurvey.
  ///
  /// In en, this message translates to:
  /// **'START SURVEY'**
  String get heatmapStartSurvey;

  /// No description provided for @heatmapNewSurveyDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'NEW SURVEY'**
  String get heatmapNewSurveyDialogTitle;

  /// No description provided for @heatmapDefaultSessionName.
  ///
  /// In en, this message translates to:
  /// **'Survey {time}'**
  String heatmapDefaultSessionName(String time);

  /// No description provided for @heatmapSessionNameField.
  ///
  /// In en, this message translates to:
  /// **'Survey name'**
  String get heatmapSessionNameField;

  /// No description provided for @heatmapNewSurveyHint.
  ///
  /// In en, this message translates to:
  /// **'Once the survey starts, signal samples are added automatically as you move. Switch to AR if you want a stronger room outline.'**
  String get heatmapNewSurveyHint;

  /// No description provided for @heatmapSavedSurveysTitle.
  ///
  /// In en, this message translates to:
  /// **'SAVED SURVEYS'**
  String get heatmapSavedSurveysTitle;

  /// No description provided for @heatmapNoSavedSurveys.
  ///
  /// In en, this message translates to:
  /// **'No saved surveys yet.'**
  String get heatmapNoSavedSurveys;

  /// No description provided for @heatmapSavedSurveySubtitle.
  ///
  /// In en, this message translates to:
  /// **'{samples} samples · {weak} weak zones · {timestamp}'**
  String heatmapSavedSurveySubtitle(int samples, int weak, String timestamp);

  /// No description provided for @heatmapDeleteSurveyTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete survey'**
  String get heatmapDeleteSurveyTooltip;

  /// No description provided for @heatmapLegendTitle.
  ///
  /// In en, this message translates to:
  /// **'COLOR GUIDE'**
  String get heatmapLegendTitle;

  /// No description provided for @heatmapLegendStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get heatmapLegendStrong;

  /// No description provided for @heatmapLegendFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get heatmapLegendFair;

  /// No description provided for @heatmapLegendWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get heatmapLegendWeak;

  /// No description provided for @heatmapCameraViewLabel.
  ///
  /// In en, this message translates to:
  /// **'LIVE CAMERA'**
  String get heatmapCameraViewLabel;

  /// No description provided for @heatmapInfoSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'LIVE SURVEY DATA'**
  String get heatmapInfoSheetTitle;

  /// No description provided for @heatmapFeedStatus.
  ///
  /// In en, this message translates to:
  /// **'{label}: {status}'**
  String heatmapFeedStatus(String label, String status);

  /// No description provided for @heatmapActive.
  ///
  /// In en, this message translates to:
  /// **'active'**
  String get heatmapActive;

  /// No description provided for @heatmapInactive.
  ///
  /// In en, this message translates to:
  /// **'inactive'**
  String get heatmapInactive;

  /// No description provided for @heatmapArViewLabel.
  ///
  /// In en, this message translates to:
  /// **'AR VIEW'**
  String get heatmapArViewLabel;

  /// No description provided for @heatmapSwitchToMapHint.
  ///
  /// In en, this message translates to:
  /// **'Return to the clearer 2D map'**
  String get heatmapSwitchToMapHint;

  /// No description provided for @heatmapSwitchToArHint.
  ///
  /// In en, this message translates to:
  /// **'Use AR to strengthen the outline'**
  String get heatmapSwitchToArHint;

  /// No description provided for @heatmapRouteLabel.
  ///
  /// In en, this message translates to:
  /// **'NEXT STEP'**
  String get heatmapRouteLabel;

  /// No description provided for @heatmapPlanConfidenceLabel.
  ///
  /// In en, this message translates to:
  /// **'PLAN CONFIDENCE'**
  String get heatmapPlanConfidenceLabel;

  /// No description provided for @heatmapCoverageConfidenceLabel.
  ///
  /// In en, this message translates to:
  /// **'COVERAGE CONFIDENCE'**
  String get heatmapCoverageConfidenceLabel;

  /// No description provided for @heatmapSignalConfidenceLabel.
  ///
  /// In en, this message translates to:
  /// **'SIGNAL CONFIDENCE'**
  String get heatmapSignalConfidenceLabel;

  /// No description provided for @heatmapMotionFeedLabel.
  ///
  /// In en, this message translates to:
  /// **'Motion'**
  String get heatmapMotionFeedLabel;

  /// No description provided for @heatmapCameraFeedLabel.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get heatmapCameraFeedLabel;

  /// No description provided for @heatmapPlanFeedLabel.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get heatmapPlanFeedLabel;

  /// No description provided for @heatmapGuidanceIdleTitle.
  ///
  /// In en, this message translates to:
  /// **'Survey Setup'**
  String get heatmapGuidanceIdleTitle;

  /// No description provided for @heatmapGuidanceCalibrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Starting Route'**
  String get heatmapGuidanceCalibrationTitle;

  /// No description provided for @heatmapGuidanceSweepTitle.
  ///
  /// In en, this message translates to:
  /// **'Filling Coverage'**
  String get heatmapGuidanceSweepTitle;

  /// No description provided for @heatmapGuidanceWeakCheckTitle.
  ///
  /// In en, this message translates to:
  /// **'Weak Zone Check'**
  String get heatmapGuidanceWeakCheckTitle;

  /// No description provided for @heatmapGuidanceWrapUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready To Save'**
  String get heatmapGuidanceWrapUpTitle;

  /// No description provided for @heatmapGuidanceReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Survey Quality'**
  String get heatmapGuidanceReviewTitle;

  /// No description provided for @heatmapGuidanceIdleBody.
  ///
  /// In en, this message translates to:
  /// **'Start a new survey. The app will combine motion, camera, and Wi-Fi traces into a cleaner floor plan.'**
  String get heatmapGuidanceIdleBody;

  /// No description provided for @heatmapGuidanceCalibrationBody.
  ///
  /// In en, this message translates to:
  /// **'Walk straight for 5-8 steps to establish the first trace. Doorways and corner turns help anchor the layout faster.'**
  String get heatmapGuidanceCalibrationBody;

  /// No description provided for @heatmapGuidanceSweepBody.
  ///
  /// In en, this message translates to:
  /// **'The {region} side of the map is still sparse. Move there and collect 3-4 more samples.'**
  String heatmapGuidanceSweepBody(String region);

  /// No description provided for @heatmapGuidanceWeakCheckBody.
  ///
  /// In en, this message translates to:
  /// **'You are currently in a weak-signal area. Sweep this zone a bit more to confirm whether it is a real dead spot.'**
  String get heatmapGuidanceWeakCheckBody;

  /// No description provided for @heatmapGuidanceWrapUpBody.
  ///
  /// In en, this message translates to:
  /// **'Outline, coverage, and signal density are now strong enough. Save the result and read the plan/heatmap in review.'**
  String get heatmapGuidanceWrapUpBody;

  /// No description provided for @heatmapGuidanceReviewBody.
  ///
  /// In en, this message translates to:
  /// **'This survey is {progress}% complete. With {count} samples, the result is readable.'**
  String heatmapGuidanceReviewBody(int progress, int count);

  /// No description provided for @heatmapRouteFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish survey'**
  String get heatmapRouteFinish;

  /// No description provided for @heatmapRouteStart.
  ///
  /// In en, this message translates to:
  /// **'Start survey'**
  String get heatmapRouteStart;

  /// No description provided for @heatmapRouteWalkForward.
  ///
  /// In en, this message translates to:
  /// **'Walk forward'**
  String get heatmapRouteWalkForward;

  /// No description provided for @heatmapRouteSweepWeak.
  ///
  /// In en, this message translates to:
  /// **'Sweep weak zone'**
  String get heatmapRouteSweepWeak;

  /// No description provided for @heatmapRouteWrapUp.
  ///
  /// In en, this message translates to:
  /// **'Wrap up run'**
  String get heatmapRouteWrapUp;

  /// No description provided for @heatmapRouteReview.
  ///
  /// In en, this message translates to:
  /// **'Review result'**
  String get heatmapRouteReview;

  /// No description provided for @heatmapRegionLeft.
  ///
  /// In en, this message translates to:
  /// **'left wing'**
  String get heatmapRegionLeft;

  /// No description provided for @heatmapRegionRight.
  ///
  /// In en, this message translates to:
  /// **'right wing'**
  String get heatmapRegionRight;

  /// No description provided for @heatmapRegionUpper.
  ///
  /// In en, this message translates to:
  /// **'upper area'**
  String get heatmapRegionUpper;

  /// No description provided for @heatmapRegionLower.
  ///
  /// In en, this message translates to:
  /// **'lower area'**
  String get heatmapRegionLower;

  /// No description provided for @heatmapRegionKeep.
  ///
  /// In en, this message translates to:
  /// **'keep sweeping'**
  String get heatmapRegionKeep;

  /// No description provided for @channelShort.
  ///
  /// In en, this message translates to:
  /// **'CH {channel}'**
  String channelShort(int channel);

  /// No description provided for @langEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @langTurkish.
  ///
  /// In en, this message translates to:
  /// **'Türkçe'**
  String get langTurkish;

  /// No description provided for @langKurdish.
  ///
  /// In en, this message translates to:
  /// **'Kurdî'**
  String get langKurdish;

  /// No description provided for @langGerman.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get langGerman;

  /// No description provided for @startNowCaps.
  ///
  /// In en, this message translates to:
  /// **'START'**
  String get startNowCaps;

  /// Section title for fix instructions in evidence card
  ///
  /// In en, this message translates to:
  /// **'HOW TO FIX'**
  String get howToFixSection;

  /// Title of dialog when user tries to exit an active survey
  ///
  /// In en, this message translates to:
  /// **'End Survey?'**
  String get endSurveyDialogTitle;

  /// Body of end survey dialog when recording
  ///
  /// In en, this message translates to:
  /// **'Your current survey data will be lost if you discard it. Save or Discard?'**
  String get endSurveyDialogBody;

  /// Body of end survey dialog when reviewing
  ///
  /// In en, this message translates to:
  /// **'Exit session review?'**
  String get endSurveyReviewBody;

  /// Button label to discard a survey
  ///
  /// In en, this message translates to:
  /// **'DISCARD'**
  String get discardAction;

  /// Button label to exit review
  ///
  /// In en, this message translates to:
  /// **'EXIT'**
  String get exitAction;

  /// Button label to continue with an action
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get continueAction;

  /// Title of confirm discard dialog in HUD
  ///
  /// In en, this message translates to:
  /// **'DISCARD SURVEY?'**
  String get discardSurveyDialogTitle;

  /// Body text of discard survey confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'All recorded data for this session will be permanently deleted.'**
  String get discardSurveyDialogBody;

  /// Label for the auto-sampling distance slider in heatmap settings
  ///
  /// In en, this message translates to:
  /// **'Auto-sampling Distance'**
  String get autoSamplingDistance;

  /// Label for the appearance section in heatmap settings
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceLabel;

  /// Button label to clear channel scan history
  ///
  /// In en, this message translates to:
  /// **'CLEAR HISTORY'**
  String get clearHistoryAction;

  /// Title of data usage warning dialog before speed test
  ///
  /// In en, this message translates to:
  /// **'DATA USAGE WARNING'**
  String get dataUsageWarningTitle;

  /// Body of data usage warning dialog
  ///
  /// In en, this message translates to:
  /// **'This speed test downloads ~300–500 MB of data. If you are on a mobile/metered connection this may incur charges or consume your data allowance.'**
  String get dataUsageWarningBody;

  /// Interpretation card title for excellent latency
  ///
  /// In en, this message translates to:
  /// **'Latency: {ms} ms — Excellent'**
  String latencyExcellentTitle(String ms);

  /// Interpretation card title for good latency
  ///
  /// In en, this message translates to:
  /// **'Latency: {ms} ms — Good'**
  String latencyGoodTitle(String ms);

  /// Interpretation card title for acceptable latency
  ///
  /// In en, this message translates to:
  /// **'Latency: {ms} ms — Acceptable'**
  String latencyAcceptableTitle(String ms);

  /// Interpretation card title for high latency
  ///
  /// In en, this message translates to:
  /// **'Latency: {ms} ms — High'**
  String latencyHighTitle(String ms);

  /// Interpretation body for excellent latency
  ///
  /// In en, this message translates to:
  /// **'Near-instant response. Ideal for gaming, video calls, and real-time apps.'**
  String get latencyExcellentBody;

  /// Interpretation body for good latency
  ///
  /// In en, this message translates to:
  /// **'Good for video calls and streaming. Most apps will feel responsive.'**
  String get latencyGoodBody;

  /// Interpretation body for acceptable latency
  ///
  /// In en, this message translates to:
  /// **'Fine for browsing and streaming, but video calls may have slight delays.'**
  String get latencyAcceptableBody;

  /// Interpretation body for high latency
  ///
  /// In en, this message translates to:
  /// **'Noticeable lag. Video calls and gaming may feel sluggish. Try moving closer to your router.'**
  String get latencyHighBody;

  /// Interpretation card title for stable jitter
  ///
  /// In en, this message translates to:
  /// **'Jitter: {ms} ms — Stable'**
  String jitterStableTitle(String ms);

  /// Interpretation card title for good jitter
  ///
  /// In en, this message translates to:
  /// **'Jitter: {ms} ms — Good'**
  String jitterGoodTitle(String ms);

  /// Interpretation card title for moderate jitter
  ///
  /// In en, this message translates to:
  /// **'Jitter: {ms} ms — Moderate'**
  String jitterModerateTitle(String ms);

  /// Interpretation card title for unstable jitter
  ///
  /// In en, this message translates to:
  /// **'Jitter: {ms} ms — Unstable'**
  String jitterUnstableTitle(String ms);

  /// Interpretation body for stable jitter
  ///
  /// In en, this message translates to:
  /// **'Very consistent connection. Your packets arrive with minimal timing variation.'**
  String get jitterStableBody;

  /// Interpretation body for good jitter
  ///
  /// In en, this message translates to:
  /// **'Stable enough for calls and streaming. Minor variation is normal on Wi-Fi.'**
  String get jitterGoodBody;

  /// Interpretation body for moderate jitter
  ///
  /// In en, this message translates to:
  /// **'Some inconsistency detected. Voice calls may sound choppy during spikes.'**
  String get jitterModerateBody;

  /// Interpretation body for unstable jitter
  ///
  /// In en, this message translates to:
  /// **'High variation — audio and video calls will likely break up. This can be caused by interference or a congested channel.'**
  String get jitterUnstableBody;

  /// Interpretation card title for fast download
  ///
  /// In en, this message translates to:
  /// **'Download: {mbps} Mbps — Fast'**
  String downloadFastTitle(String mbps);

  /// Interpretation card title for good download
  ///
  /// In en, this message translates to:
  /// **'Download: {mbps} Mbps — Good'**
  String downloadGoodTitle(String mbps);

  /// Interpretation card title for moderate download
  ///
  /// In en, this message translates to:
  /// **'Download: {mbps} Mbps — Moderate'**
  String downloadModerateTitle(String mbps);

  /// Interpretation card title for slow download
  ///
  /// In en, this message translates to:
  /// **'Download: {mbps} Mbps — Slow'**
  String downloadSlowTitle(String mbps);

  /// Interpretation body for fast download
  ///
  /// In en, this message translates to:
  /// **'Handles {streams}+ simultaneous HD streams with ease. Great for large households.'**
  String downloadFastBody(int streams);

  /// Interpretation body for good download
  ///
  /// In en, this message translates to:
  /// **'Supports {streams} simultaneous HD streams. Good for most households.'**
  String downloadGoodBody(int streams);

  /// Interpretation body for moderate download
  ///
  /// In en, this message translates to:
  /// **'Enough for browsing and one or two SD streams. Large downloads will be slow.'**
  String get downloadModerateBody;

  /// Interpretation body for slow download
  ///
  /// In en, this message translates to:
  /// **'Very limited. Consider moving closer to your router or checking for interference.'**
  String get downloadSlowBody;

  /// Interpretation card title for fast upload
  ///
  /// In en, this message translates to:
  /// **'Upload: {mbps} Mbps — Fast'**
  String uploadFastTitle(String mbps);

  /// Interpretation card title for good upload
  ///
  /// In en, this message translates to:
  /// **'Upload: {mbps} Mbps — Good'**
  String uploadGoodTitle(String mbps);

  /// Interpretation card title for limited upload
  ///
  /// In en, this message translates to:
  /// **'Upload: {mbps} Mbps — Limited'**
  String uploadLimitedTitle(String mbps);

  /// Interpretation card title for slow upload
  ///
  /// In en, this message translates to:
  /// **'Upload: {mbps} Mbps — Slow'**
  String uploadSlowTitle(String mbps);

  /// Interpretation body for fast upload
  ///
  /// In en, this message translates to:
  /// **'Excellent for video conferencing, cloud backups, and live streaming.'**
  String get uploadFastBody;

  /// Interpretation body for good upload
  ///
  /// In en, this message translates to:
  /// **'Good for video calls and sharing files. Cloud uploads will be reasonable.'**
  String get uploadGoodBody;

  /// Interpretation body for limited upload
  ///
  /// In en, this message translates to:
  /// **'Enough for basic video calls. Large file uploads will take a while.'**
  String get uploadLimitedBody;

  /// Interpretation body for slow upload
  ///
  /// In en, this message translates to:
  /// **'Very slow upload. Live video and cloud sync will struggle.'**
  String get uploadSlowBody;

  /// Interpretation card title for zero packet loss
  ///
  /// In en, this message translates to:
  /// **'Packet Loss: 0% — Perfect'**
  String get packetLossPerfectTitle;

  /// Interpretation card title for minimal packet loss
  ///
  /// In en, this message translates to:
  /// **'Packet Loss: {pct}% — Minimal'**
  String packetLossMinimalTitle(String pct);

  /// Interpretation card title for high packet loss
  ///
  /// In en, this message translates to:
  /// **'Packet Loss: {pct}% — High'**
  String packetLossHighTitle(String pct);

  /// Interpretation body for zero packet loss
  ///
  /// In en, this message translates to:
  /// **'Solid connection. No data packets were lost during the assessment.'**
  String get packetLossPerfectBody;

  /// Interpretation body for minimal packet loss
  ///
  /// In en, this message translates to:
  /// **'Very minor loss. Likely unnoticeable for most activities.'**
  String get packetLossMinimalBody;

  /// Interpretation body for high packet loss
  ///
  /// In en, this message translates to:
  /// **'Data is being dropped. This causes stuttering in calls and gaming. Check for Wi-Fi interference.'**
  String get packetLossHighBody;

  /// Loaded latency title for excellent grade
  ///
  /// In en, this message translates to:
  /// **'Loaded Latency: {ms} ms — Excellent'**
  String loadedLatencyExcellentTitle(String ms);

  /// Loaded latency title for good grade
  ///
  /// In en, this message translates to:
  /// **'Loaded Latency: {ms} ms — Good'**
  String loadedLatencyGoodTitle(String ms);

  /// Loaded latency title for fair grade
  ///
  /// In en, this message translates to:
  /// **'Loaded Latency: {ms} ms — Fair'**
  String loadedLatencyFairTitle(String ms);

  /// Loaded latency title for poor grade
  ///
  /// In en, this message translates to:
  /// **'Loaded Latency: {ms} ms — Poor'**
  String loadedLatencyPoorTitle(String ms);

  /// Loaded latency body for excellent grade
  ///
  /// In en, this message translates to:
  /// **'Your network stays responsive even when downloading. Excellent router quality.'**
  String get loadedLatencyExcellentBody;

  /// Loaded latency body for good grade
  ///
  /// In en, this message translates to:
  /// **'Response time increases slightly under load, but stays very usable.'**
  String get loadedLatencyGoodBody;

  /// Loaded latency body for fair grade
  ///
  /// In en, this message translates to:
  /// **'Noticeable delay when others are using the network. Gaming while downloading may suffer.'**
  String get loadedLatencyFairBody;

  /// Loaded latency body for poor grade
  ///
  /// In en, this message translates to:
  /// **'High Bufferbloat. Connection becomes unresponsive during large downloads. Consider enabling QoS on your router.'**
  String get loadedLatencyPoorBody;

  /// Label for the bufferbloat grade card
  ///
  /// In en, this message translates to:
  /// **'BUFFERBLOAT GRADE'**
  String get bufferbloatGradeLabel;

  /// Description for bufferbloat grade A
  ///
  /// In en, this message translates to:
  /// **'Excellent bufferbloat control. Your router keeps latency low even under heavy load.'**
  String get bufferbloatGradeA;

  /// Description for bufferbloat grade B
  ///
  /// In en, this message translates to:
  /// **'Good bufferbloat. Minor latency increase under load — most users won\'t notice.'**
  String get bufferbloatGradeB;

  /// Description for bufferbloat grade C
  ///
  /// In en, this message translates to:
  /// **'Moderate bufferbloat. Gaming and video calls may lag when others are downloading.'**
  String get bufferbloatGradeC;

  /// Description for bufferbloat grade D
  ///
  /// In en, this message translates to:
  /// **'Poor bufferbloat. Connection becomes sluggish under load. Enable QoS on your router.'**
  String get bufferbloatGradeD;

  /// Description for bufferbloat grade E
  ///
  /// In en, this message translates to:
  /// **'Severe bufferbloat. Real-time apps will fail during concurrent downloads.'**
  String get bufferbloatGradeE;

  /// Description for bufferbloat grade F
  ///
  /// In en, this message translates to:
  /// **'Critical bufferbloat. Your router does not control queue depth. Upgrade firmware or hardware.'**
  String get bufferbloatGradeF;

  /// Disclaimer shown after speed test results
  ///
  /// In en, this message translates to:
  /// **'Results reflect speed to Cloudflare\'s nearest server and are affected by Wi-Fi, device hardware, and PoP distance. They are not a direct measure of your ISP contract speed.'**
  String get speedTestDisclaimer;

  /// Button label to clear all speed test history
  ///
  /// In en, this message translates to:
  /// **'CLEAR ALL HISTORY'**
  String get clearAllHistoryAction;

  /// Confirmation body for deleting all speed test history
  ///
  /// In en, this message translates to:
  /// **'Delete all speed test records? This cannot be undone.'**
  String get deleteAllHistoryConfirm;

  /// Confirm button label to delete all items
  ///
  /// In en, this message translates to:
  /// **'DELETE ALL'**
  String get deleteAllAction;

  /// Question shown in trust badge sheet explaining why a device has a trust level
  ///
  /// In en, this message translates to:
  /// **'WHY IS THIS {level}?'**
  String whyIsThisLabel(String level);

  /// Shown when a device has no specific trust concerns logged
  ///
  /// In en, this message translates to:
  /// **'No specific concerns logged for this device. The badge reflects an aggregate score.'**
  String get noSpecificConcerns;

  /// Section label for remediation steps in host trust sheet
  ///
  /// In en, this message translates to:
  /// **'WHAT TO DO'**
  String get whatToDoLabel;

  /// Trust level label for safe hosts
  ///
  /// In en, this message translates to:
  /// **'SAFE'**
  String get trustLevelSafe;

  /// Trust level label for hosts that need caution
  ///
  /// In en, this message translates to:
  /// **'CAUTION'**
  String get trustLevelCaution;

  /// Trust level label for risky hosts
  ///
  /// In en, this message translates to:
  /// **'RISKY'**
  String get trustLevelRisky;

  /// Label for CVE database freshness card
  ///
  /// In en, this message translates to:
  /// **'CVE DATABASE — {freshness}'**
  String cveDatabaseLabel(String freshness);

  /// Section title for CVE database update instructions
  ///
  /// In en, this message translates to:
  /// **'HOW TO UPDATE'**
  String get howToUpdateLabel;

  /// Label for fresh vulnerability database
  ///
  /// In en, this message translates to:
  /// **'FRESH'**
  String get vulnDbFreshLabel;

  /// Label for aging vulnerability database
  ///
  /// In en, this message translates to:
  /// **'AGING'**
  String get vulnDbAgingLabel;

  /// Label for stale vulnerability database
  ///
  /// In en, this message translates to:
  /// **'STALE'**
  String get vulnDbStaleLabel;

  /// Message when vulnerability database is fresh
  ///
  /// In en, this message translates to:
  /// **'Vulnerability lookups against this database are up to date.'**
  String get vulnDbFreshMessage;

  /// Message when vulnerability database is aging
  ///
  /// In en, this message translates to:
  /// **'The local vulnerability database is over a month old. A clean scan still has value but consider refreshing soon.'**
  String get vulnDbAgingMessage;

  /// Message when vulnerability database is stale
  ///
  /// In en, this message translates to:
  /// **'This database is more than 90 days old. A \"no findings\" result no longer means the network is safe — many newer CVEs may not be represented here yet.'**
  String get vulnDbStaleMessage;

  /// Info line showing CVE database version and age
  ///
  /// In en, this message translates to:
  /// **'v{version} · {count} entries · {days} days old'**
  String vulnDbEntriesInfo(String version, int count, int days);

  /// Title of wipe all data confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'WIPE ALL DATA'**
  String get wipeAllDialogTitle;

  /// Body of wipe all data confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all local scan history, speed test records, security events, channel ratings and in-memory snapshots. This action cannot be undone.'**
  String get wipeAllDialogBody;

  /// Confirm button label for wipe all data dialog
  ///
  /// In en, this message translates to:
  /// **'WIPE ALL'**
  String get wipeAllAction;

  /// Snackbar message shown after all data is wiped
  ///
  /// In en, this message translates to:
  /// **'All local data wiped.'**
  String get allDataWiped;

  /// Label for system default language option in settings
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// Display value for port scan timeout slider
  ///
  /// In en, this message translates to:
  /// **'{ms} ms'**
  String portScanTimeoutMs(int ms);

  /// Dialog body when recording and user tries to exit
  ///
  /// In en, this message translates to:
  /// **'Your current survey data will be lost if you discard it. Save or Discard?'**
  String get endSurveyDiscardBody;

  /// Section header for the legend panel in topology info sheet
  ///
  /// In en, this message translates to:
  /// **'LEGEND & NODES'**
  String get legendAndNodes;

  /// Legend tile label for gateway/router node
  ///
  /// In en, this message translates to:
  /// **'GATEWAY'**
  String get legendGateway;

  /// Legend tile description for gateway node
  ///
  /// In en, this message translates to:
  /// **'Central network entry point'**
  String get legendGatewayDesc;

  /// Legend tile label for access point node
  ///
  /// In en, this message translates to:
  /// **'ACCESS POINT'**
  String get legendAccessPoint;

  /// Legend tile description for access point node
  ///
  /// In en, this message translates to:
  /// **'WiFi signal distributor'**
  String get legendAccessPointDesc;

  /// Legend tile label for mobile device node
  ///
  /// In en, this message translates to:
  /// **'MOBILE'**
  String get legendMobile;

  /// Legend tile description for mobile device node
  ///
  /// In en, this message translates to:
  /// **'Personal handheld devices'**
  String get legendMobileDesc;

  /// Legend tile label for IoT device node
  ///
  /// In en, this message translates to:
  /// **'IOT'**
  String get legendIot;

  /// Legend tile description for IoT device node
  ///
  /// In en, this message translates to:
  /// **'Smart home & sensors'**
  String get legendIotDesc;

  /// Legend tile label for generic device node
  ///
  /// In en, this message translates to:
  /// **'DEVICE'**
  String get legendDevice;

  /// Legend tile description for generic device node
  ///
  /// In en, this message translates to:
  /// **'Computers, TVs, etc.'**
  String get legendDeviceDesc;

  /// Survey pilot card label for idle stage
  ///
  /// In en, this message translates to:
  /// **'STANDBY'**
  String get surveyStageStandby;

  /// Survey pilot card label for calibration stage
  ///
  /// In en, this message translates to:
  /// **'INITIALIZING'**
  String get surveyStageInitializing;

  /// Survey pilot card label for coverage sweep stage
  ///
  /// In en, this message translates to:
  /// **'SWEEP ROOMS'**
  String get surveyStageSweepRooms;

  /// Survey pilot card label for weak zone review stage
  ///
  /// In en, this message translates to:
  /// **'WEAK ZONE'**
  String get surveyStageWeakZone;

  /// Survey pilot card label for wrap up stage
  ///
  /// In en, this message translates to:
  /// **'WRAP UP'**
  String get surveyStageWrapUp;

  /// Survey pilot card label for review stage
  ///
  /// In en, this message translates to:
  /// **'REVIEW'**
  String get surveyStageReview;

  /// Section header for connection types in topology info sheet
  ///
  /// In en, this message translates to:
  /// **'CONNECTION TYPES'**
  String get connectionTypesHeader;

  /// Connection type label for solid blue line
  ///
  /// In en, this message translates to:
  /// **'Solid Line (Blue)'**
  String get connTypeSolidLineLabel;

  /// Connection type description for solid blue line
  ///
  /// In en, this message translates to:
  /// **'High-speed wired Ethernet connection'**
  String get connTypeSolidLineDesc;

  /// Connection type label for glowing gradient
  ///
  /// In en, this message translates to:
  /// **'Glowing Gradient (Cyan)'**
  String get connTypeGradientLabel;

  /// Connection type description for glowing gradient
  ///
  /// In en, this message translates to:
  /// **'Wireless WiFi connection'**
  String get connTypeGradientDesc;

  /// Connection type label for pulsing data point
  ///
  /// In en, this message translates to:
  /// **'Pulsing Data Point'**
  String get connTypePulsingLabel;

  /// Connection type description for pulsing data point
  ///
  /// In en, this message translates to:
  /// **'Active traffic detected on the link'**
  String get connTypePulsingDesc;

  /// Center label on speedometer arc during upload phase
  ///
  /// In en, this message translates to:
  /// **'UPLOAD'**
  String get uploadLabel;

  /// Center label on speedometer arc during download phase
  ///
  /// In en, this message translates to:
  /// **'DOWNLOAD'**
  String get downloadLabel;

  /// Semantics label for speedometer when idle
  ///
  /// In en, this message translates to:
  /// **'Speed test gauge. Tap to start.'**
  String get speedTestSemanticsIdle;

  /// Semantics label for speedometer while running
  ///
  /// In en, this message translates to:
  /// **'Speed test running — {mbps} Mbps download. Tap to stop.'**
  String speedTestSemanticsRunning(String mbps);

  /// Semantics label for speedometer after completion
  ///
  /// In en, this message translates to:
  /// **'Speed test complete — {dl} Mbps download, {ul} Mbps upload.'**
  String speedTestSemanticsComplete(String dl, String ul);

  /// Banner title when measurement is locked due to no Wi-Fi
  ///
  /// In en, this message translates to:
  /// **'MEASUREMENT LOCKED'**
  String get measurementLockedTitle;

  /// Banner body when no Wi-Fi is connected
  ///
  /// In en, this message translates to:
  /// **'Connect to a Wi-Fi network to lock the survey target.'**
  String get measurementLockNoWifi;

  /// Banner body when disconnected from survey BSSID
  ///
  /// In en, this message translates to:
  /// **'Reconnect to {bssid} to resume sampling.'**
  String measurementLockReconnect(String bssid);

  /// Banner title when RSSI signal is stale
  ///
  /// In en, this message translates to:
  /// **'WAITING FOR FRESH SIGNAL'**
  String get waitingForSignalTitle;

  /// Banner body when RSSI signal is stale
  ///
  /// In en, this message translates to:
  /// **'RSSI is older than 3 seconds. Walk briefly or hold position for a new scan.'**
  String get waitingForSignalBody;

  /// Banner title when signal is below threshold
  ///
  /// In en, this message translates to:
  /// **'SIGNAL DROPPED'**
  String get signalDroppedTitle;

  /// Banner body when signal is below threshold
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi signal is below -85dBm. Move closer to the Access Point.'**
  String get signalDroppedBody;

  /// Banner title when compass drift is detected
  ///
  /// In en, this message translates to:
  /// **'COMPASS DRIFT DETECTED'**
  String get compassDriftTitle;

  /// Banner body for magnetic interference / compass drift
  ///
  /// In en, this message translates to:
  /// **'Magnetic interference found. Walk in a figure-8 or tap Realign.'**
  String get measurementLockMagnetic;

  /// Banner title when AR origin not yet placed
  ///
  /// In en, this message translates to:
  /// **'PLACE SURVEY ORIGIN'**
  String get placeSurveyOriginTitle;

  /// Banner body when AR origin not placed
  ///
  /// In en, this message translates to:
  /// **'Tap a detected plane to anchor the AR survey before recording points.'**
  String get measurementLockAnchor;

  /// Banner title when motion tracking is lost
  ///
  /// In en, this message translates to:
  /// **'TRACKING LOST'**
  String get trackingLostTitle;

  /// Banner body when motion tracking is lost
  ///
  /// In en, this message translates to:
  /// **'Motion tracking is unavailable. Move slowly until tracking returns.'**
  String get measurementLockTracking;

  /// Label shown on the ready banner to finish the scan
  ///
  /// In en, this message translates to:
  /// **'Tap to finish scan'**
  String get readyBannerTapFinish;

  /// SSID chip lock state label
  ///
  /// In en, this message translates to:
  /// **'LOCK'**
  String get ssidChipLock;

  /// SSID chip hold state label
  ///
  /// In en, this message translates to:
  /// **'HOLD'**
  String get ssidChipHold;

  /// Guidance pill stage label for idle
  ///
  /// In en, this message translates to:
  /// **'Idle'**
  String get guidanceStageIdle;

  /// Guidance pill stage label for initializing
  ///
  /// In en, this message translates to:
  /// **'Initializing'**
  String get guidanceStageInitializing;

  /// Guidance pill stage label for coverage sweep
  ///
  /// In en, this message translates to:
  /// **'Mapping Signal'**
  String get guidanceStageMappingSignal;

  /// Guidance pill stage label for weak zone review
  ///
  /// In en, this message translates to:
  /// **'Scanning Weak Zones'**
  String get guidanceStageScanningWeakZones;

  /// Guidance pill stage label for wrap up
  ///
  /// In en, this message translates to:
  /// **'Ready to Finish'**
  String get guidanceStageReadyToFinish;

  /// Guidance pill stage label for review
  ///
  /// In en, this message translates to:
  /// **'Reviewing'**
  String get guidanceStageReviewing;

  /// Hint shown when user taps empty area in signal probe overlay
  ///
  /// In en, this message translates to:
  /// **'Try tapping closer to a captured signal point.'**
  String get signalProbeHint;

  /// Security type label for open (unencrypted) Wi-Fi networks
  ///
  /// In en, this message translates to:
  /// **'OPEN'**
  String get wifiSecurityOpen;

  /// Body text explaining permissions needed for new heatmap session
  ///
  /// In en, this message translates to:
  /// **'To generate accurate heatmaps and map your network coverage, Torcav requires access to certain device features:'**
  String get newSessionPermissionsBody;

  /// Permission item: location access for heatmap
  ///
  /// In en, this message translates to:
  /// **'Location (to map signal to coordinates)'**
  String get newSessionPermLocation;

  /// Permission item: activity recognition for heatmap
  ///
  /// In en, this message translates to:
  /// **'Activity Recognition (to track steps and movement)'**
  String get newSessionPermActivity;

  /// Permission item: camera for heatmap
  ///
  /// In en, this message translates to:
  /// **'Camera (optional, for visual mapping features)'**
  String get newSessionPermCamera;

  /// Description for MAC address masking toggle in reports page
  ///
  /// In en, this message translates to:
  /// **'Masks last 3 octets (XX:XX:XX) before export'**
  String get reportsMacMaskDesc;

  /// Subject/name used when sharing a scan report
  ///
  /// In en, this message translates to:
  /// **'Torcav Scan Report'**
  String get reportsShareSubject;

  /// Message shown when selected export category has no data
  ///
  /// In en, this message translates to:
  /// **'No data in \"{label}\" yet.'**
  String exportNoDataYet(String label);

  /// Email/share subject for local data export
  ///
  /// In en, this message translates to:
  /// **'Torcav local data export'**
  String get exportSubject;

  /// Error message when export fails
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportFailedError(String error);

  /// Speedometer idle state label prompting to start test
  ///
  /// In en, this message translates to:
  /// **'TAP TO START'**
  String get tapToStart;

  /// Speedometer running state label prompting to stop test
  ///
  /// In en, this message translates to:
  /// **'TAP TO STOP'**
  String get tapToStop;

  /// SSID chip fallback label when no SSID is known
  ///
  /// In en, this message translates to:
  /// **'LIVE WI-FI'**
  String get liveWifi;

  /// Title for the signal probe overlay
  ///
  /// In en, this message translates to:
  /// **'SIGNAL PROBE'**
  String get signalProbeTitle;

  /// Signal status: optimal
  ///
  /// In en, this message translates to:
  /// **'OPTIMAL'**
  String get statusOptimal;

  /// Signal status: fair
  ///
  /// In en, this message translates to:
  /// **'FAIR'**
  String get statusFair;

  /// Signal status: critical
  ///
  /// In en, this message translates to:
  /// **'CRITICAL'**
  String get statusCritical;

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{count}d'**
  String daysCount(int count);

  /// No description provided for @secondsCount.
  ///
  /// In en, this message translates to:
  /// **'{count}s'**
  String secondsCount(int count);

  /// No description provided for @millisecondsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} ms'**
  String millisecondsCount(int count);

  /// English language
  ///
  /// In en, this message translates to:
  /// **'English 🇺🇸'**
  String get languageEnglish;

  /// Turkish language
  ///
  /// In en, this message translates to:
  /// **'Türkçe 🇹🇷'**
  String get languageTurkish;

  /// Kurdish language
  ///
  /// In en, this message translates to:
  /// **'Kurdî ☀️'**
  String get languageKurdish;

  /// German language
  ///
  /// In en, this message translates to:
  /// **'Deutsch 🇩🇪'**
  String get languageGerman;

  /// No description provided for @sdWeakSignalWhatIs.
  ///
  /// In en, this message translates to:
  /// **'Signal strength (RSSI) measures how loudly your device hears the router. Below about −70 dBm, Wi-Fi has to drop to slower, more redundant encodings to stay reliable.'**
  String get sdWeakSignalWhatIs;

  /// No description provided for @sdWeakSignalWhyItMatters.
  ///
  /// In en, this message translates to:
  /// **'A weak signal forces the radio into low-rate modes. Even if your internet plan is fast, the Wi-Fi link itself becomes the ceiling — downloads stall, video calls drop, and pages take longer.'**
  String get sdWeakSignalWhyItMatters;

  /// No description provided for @sdWeakSignalHowToFix1.
  ///
  /// In en, this message translates to:
  /// **'Move closer to the router or to a less obstructed spot.'**
  String get sdWeakSignalHowToFix1;

  /// No description provided for @sdWeakSignalHowToFix2.
  ///
  /// In en, this message translates to:
  /// **'Add a mesh node / Wi-Fi extender in this area.'**
  String get sdWeakSignalHowToFix2;

  /// No description provided for @sdWeakSignalHowToFix3.
  ///
  /// In en, this message translates to:
  /// **'If your router supports 5 GHz or 6 GHz on this SSID, use that band when you are in line-of-sight of it.'**
  String get sdWeakSignalHowToFix3;

  /// No description provided for @sdWeakSignalHowToFix4.
  ///
  /// In en, this message translates to:
  /// **'Check that the router is not buried inside a cabinet, behind a TV, or next to a microwave.'**
  String get sdWeakSignalHowToFix4;

  /// No description provided for @sdWeakSignalEstimate.
  ///
  /// In en, this message translates to:
  /// **'Estimated gain: up to +{gain} Mbps download if you can pull the device closer to the router.'**
  String sdWeakSignalEstimate(String gain);

  /// No description provided for @sdCrowdedChannelWhatIs.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi channels are shared spectrum. When several nearby access points transmit on the same channel, they have to take turns — air-time is split between all of them, including yours.'**
  String get sdCrowdedChannelWhatIs;

  /// No description provided for @sdCrowdedChannelWhyItMatters.
  ///
  /// In en, this message translates to:
  /// **'On a crowded channel your throughput drops even when no one in your home is using the network. The radio is healthy, but it has to wait for its turn to talk.'**
  String get sdCrowdedChannelWhyItMatters;

  /// No description provided for @sdCrowdedChannelHowToFix1.
  ///
  /// In en, this message translates to:
  /// **'Open the router admin page and switch the Wi-Fi channel manually (Channel Rating in the app suggests the cleanest one).'**
  String get sdCrowdedChannelHowToFix1;

  /// No description provided for @sdCrowdedChannelHowToFix2.
  ///
  /// In en, this message translates to:
  /// **'On 2.4 GHz, prefer channels 1 / 6 / 11 — they do not overlap.'**
  String get sdCrowdedChannelHowToFix2;

  /// No description provided for @sdCrowdedChannelHowToFix3.
  ///
  /// In en, this message translates to:
  /// **'If your router supports 5 GHz or 6 GHz, move the device to that band: there are far more clean channels available.'**
  String get sdCrowdedChannelHowToFix3;

  /// No description provided for @sdCrowdedChannelHowToFix4.
  ///
  /// In en, this message translates to:
  /// **'For dual-band routers, give each band its own SSID so devices stop flipping back to a crowded 2.4 GHz channel.'**
  String get sdCrowdedChannelHowToFix4;

  /// No description provided for @sdCrowdedChannelEstimate.
  ///
  /// In en, this message translates to:
  /// **'Estimated gain: up to +{gain} Mbps download after switching to a quieter channel.'**
  String sdCrowdedChannelEstimate(String gain);

  /// No description provided for @sdBufferbloatWhatIs.
  ///
  /// In en, this message translates to:
  /// **'Bufferbloat is the latency that builds up inside your router\'s send buffers when the link is fully loaded — typical packets have to queue behind a backlog of bulk traffic.'**
  String get sdBufferbloatWhatIs;

  /// No description provided for @sdBufferbloatWhyItMatters.
  ///
  /// In en, this message translates to:
  /// **'Your download speed can look great while a file is in flight, but voice calls jitter, video conferences freeze, and games lag — anything time-sensitive is held up behind the queue.'**
  String get sdBufferbloatWhyItMatters;

  /// No description provided for @sdBufferbloatHowToFix1.
  ///
  /// In en, this message translates to:
  /// **'Enable QoS / SQM (sometimes called \"Smart Queue Management\" or \"Adaptive QoS\") in your router admin page.'**
  String get sdBufferbloatHowToFix1;

  /// No description provided for @sdBufferbloatHowToFix2.
  ///
  /// In en, this message translates to:
  /// **'Update the router firmware — modern firmware ships better queue discipline by default.'**
  String get sdBufferbloatHowToFix2;

  /// No description provided for @sdBufferbloatHowToFix3.
  ///
  /// In en, this message translates to:
  /// **'If the router is many years old and lacks SQM, replacing it with a recent model is often the only real fix.'**
  String get sdBufferbloatHowToFix3;

  /// No description provided for @sdBufferbloatHowToFix4.
  ///
  /// In en, this message translates to:
  /// **'Cap upload bandwidth in the router slightly below your real plan (e.g. 90%) so the queue lives on the router, not at the ISP.'**
  String get sdBufferbloatHowToFix4;

  /// No description provided for @sdBufferbloatEstimate.
  ///
  /// In en, this message translates to:
  /// **'Estimated gain: about −{reduction} ms loaded latency. Calls and gaming will feel responsive even during large downloads.'**
  String sdBufferbloatEstimate(String reduction);

  /// No description provided for @sdIspSlowWhatIs.
  ///
  /// In en, this message translates to:
  /// **'Your Wi-Fi link is healthy and the radio could carry far more than what is actually flowing through it. The bottleneck sits upstream of the router.'**
  String get sdIspSlowWhatIs;

  /// No description provided for @sdIspSlowWhyItMatters.
  ///
  /// In en, this message translates to:
  /// **'No amount of router or Wi-Fi tuning will help — the link from your ISP to the router is the ceiling. Treat this as data for a plan-upgrade or support call, not as a Wi-Fi problem.'**
  String get sdIspSlowWhyItMatters;

  /// No description provided for @sdIspSlowHowToFix1.
  ///
  /// In en, this message translates to:
  /// **'Re-run the test with a wired Ethernet cable to confirm the radio is not at fault.'**
  String get sdIspSlowHowToFix1;

  /// No description provided for @sdIspSlowHowToFix2.
  ///
  /// In en, this message translates to:
  /// **'Check the ISP plan you are paying for — the test result should match it within ~80% on a good day.'**
  String get sdIspSlowHowToFix2;

  /// No description provided for @sdIspSlowHowToFix3.
  ///
  /// In en, this message translates to:
  /// **'Try at different times of day. If only evenings are slow, the ISP segment may be congested.'**
  String get sdIspSlowHowToFix3;

  /// No description provided for @sdIspSlowHowToFix4.
  ///
  /// In en, this message translates to:
  /// **'If the result is consistently far below your plan, contact the ISP with the speed test output.'**
  String get sdIspSlowHowToFix4;

  /// No description provided for @sdIspSlowEstimate.
  ///
  /// In en, this message translates to:
  /// **'Your Wi-Fi can carry up to ~{phy} Mbps; you are currently getting {download} Mbps. The gap is upstream of the router.'**
  String sdIspSlowEstimate(String phy, String download);

  /// No description provided for @sdSlowDnsWhatIs.
  ///
  /// In en, this message translates to:
  /// **'DNS turns names like example.com into the IP addresses your device actually connects to. Every page load fires off a handful of these lookups before any data flows.'**
  String get sdSlowDnsWhatIs;

  /// No description provided for @sdSlowDnsWhyItMatters.
  ///
  /// In en, this message translates to:
  /// **'Slow DNS does not lower your download speed — it adds a delay at the start of every connection. The web feels \"laggy\" even when speed tests look fine.'**
  String get sdSlowDnsWhyItMatters;

  /// No description provided for @sdSlowDnsHowToFix1.
  ///
  /// In en, this message translates to:
  /// **'Switch your device or router DNS to a fast public resolver — 1.1.1.1 (Cloudflare), 8.8.8.8 (Google), or 9.9.9.9 (Quad9).'**
  String get sdSlowDnsHowToFix1;

  /// No description provided for @sdSlowDnsHowToFix2.
  ///
  /// In en, this message translates to:
  /// **'Enable DNS-over-HTTPS (DoH) or DNS-over-TLS (DoT) in your OS or browser to also encrypt the lookups.'**
  String get sdSlowDnsHowToFix2;

  /// No description provided for @sdSlowDnsHowToFix3.
  ///
  /// In en, this message translates to:
  /// **'If your ISP\'s DNS is slow, set the resolver on the router so the whole household benefits, not just one device.'**
  String get sdSlowDnsHowToFix3;

  /// No description provided for @sdSlowDnsEstimate.
  ///
  /// In en, this message translates to:
  /// **'Estimated gain: about −{reduction} ms per name lookup. Page loads usually feel 5–20% snappier because each page kicks off a dozen lookups.'**
  String sdSlowDnsEstimate(int reduction);

  /// No description provided for @sdHealthyWhatIs.
  ///
  /// In en, this message translates to:
  /// **'Speed Doctor checks five things: signal strength, channel congestion, speed-under-load (bufferbloat), download throughput vs Wi-Fi capacity, and DNS resolution time.'**
  String get sdHealthyWhatIs;

  /// No description provided for @sdHealthyWhyItMatters.
  ///
  /// In en, this message translates to:
  /// **'None of those crossed an alert threshold this run. Your link is in good shape right now — re-run the test if you start noticing a problem to see whether anything shifted.'**
  String get sdHealthyWhyItMatters;

  /// No description provided for @sdMetricRssi.
  ///
  /// In en, this message translates to:
  /// **'RSSI: {rssi} dBm'**
  String sdMetricRssi(int rssi);

  /// No description provided for @sdThresholdRssi.
  ///
  /// In en, this message translates to:
  /// **'Healthy ≥ {healthy} dBm · Severe ≤ {severe} dBm'**
  String sdThresholdRssi(int healthy, int severe);

  /// No description provided for @sdMetricChannel.
  ///
  /// In en, this message translates to:
  /// **'Channel {channel} · score {score}/10'**
  String sdMetricChannel(int channel, String score);

  /// No description provided for @sdThresholdChannel.
  ///
  /// In en, this message translates to:
  /// **'Healthy ≥ {healthy} · Severe ≤ {severe}'**
  String sdThresholdChannel(String healthy, String severe);

  /// No description provided for @sdMetricBufferbloat.
  ///
  /// In en, this message translates to:
  /// **'Loaded latency Δ: {induced} ms ({latency} → {loaded})'**
  String sdMetricBufferbloat(String induced, String latency, String loaded);

  /// No description provided for @sdThresholdBufferbloat.
  ///
  /// In en, this message translates to:
  /// **'Healthy ≤ {healthy} ms · Severe ≥ {severe} ms'**
  String sdThresholdBufferbloat(String healthy, String severe);

  /// No description provided for @sdMetricIsp.
  ///
  /// In en, this message translates to:
  /// **'Download: {download} Mbps · PHY: {phy} Mbps'**
  String sdMetricIsp(String download, String phy);

  /// No description provided for @sdMetricIspNoPhy.
  ///
  /// In en, this message translates to:
  /// **'Download: {download} Mbps'**
  String sdMetricIspNoPhy(String download);

  /// No description provided for @sdThresholdIsp.
  ///
  /// In en, this message translates to:
  /// **'Healthy ≥ {healthy} Mbps when radio is uncongested'**
  String sdThresholdIsp(String healthy);

  /// No description provided for @sdMetricDns.
  ///
  /// In en, this message translates to:
  /// **'Best resolver: {name} · {latency} ms'**
  String sdMetricDns(String name, int latency);

  /// No description provided for @sdThresholdDns.
  ///
  /// In en, this message translates to:
  /// **'Healthy ≤ {healthy} ms · Severe ≥ {severe} ms'**
  String sdThresholdDns(int healthy, int severe);

  /// No description provided for @networkContextHomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get networkContextHomeLabel;

  /// No description provided for @networkContextPublicLabel.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get networkContextPublicLabel;

  /// No description provided for @networkContextGuestLabel.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get networkContextGuestLabel;

  /// No description provided for @networkContextUnknownLabel.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get networkContextUnknownLabel;

  /// No description provided for @noChangeLabel.
  ///
  /// In en, this message translates to:
  /// **'no change'**
  String get noChangeLabel;

  /// No description provided for @sinceLastScanLabel.
  ///
  /// In en, this message translates to:
  /// **'since last scan'**
  String get sinceLastScanLabel;

  /// No description provided for @allClearLabel.
  ///
  /// In en, this message translates to:
  /// **'all clear'**
  String get allClearLabel;

  /// No description provided for @tapToTestLabel.
  ///
  /// In en, this message translates to:
  /// **'tap to test'**
  String get tapToTestLabel;

  /// No description provided for @gameProfileLabel.
  ///
  /// In en, this message translates to:
  /// **'Game profile'**
  String get gameProfileLabel;

  /// No description provided for @profileGeneric.
  ///
  /// In en, this message translates to:
  /// **'Generic UDP Game'**
  String get profileGeneric;

  /// No description provided for @notificationChannelSecurityCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical Alerts'**
  String get notificationChannelSecurityCritical;

  /// No description provided for @notificationChannelSecurityHigh.
  ///
  /// In en, this message translates to:
  /// **'High Priority'**
  String get notificationChannelSecurityHigh;

  /// No description provided for @notificationChannelSecurityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium Priority'**
  String get notificationChannelSecurityMedium;

  /// No description provided for @notificationChannelSecurityWarning.
  ///
  /// In en, this message translates to:
  /// **'Warnings'**
  String get notificationChannelSecurityWarning;

  /// No description provided for @notificationChannelSecurityLow.
  ///
  /// In en, this message translates to:
  /// **'Low Priority'**
  String get notificationChannelSecurityLow;

  /// No description provided for @notificationChannelSecurityInfo.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get notificationChannelSecurityInfo;

  /// No description provided for @notificationChannelSecurityDescription.
  ///
  /// In en, this message translates to:
  /// **'Security alert notifications'**
  String get notificationChannelSecurityDescription;

  /// No description provided for @scanCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan Complete'**
  String get scanCompleteTitle;

  /// No description provided for @scanCompleteBody.
  ///
  /// In en, this message translates to:
  /// **'Found {count} networks in {seconds}s'**
  String scanCompleteBody(int count, int seconds);

  /// No description provided for @wifiChannelQualityDroppedTitle.
  ///
  /// In en, this message translates to:
  /// **'📶 Wi-Fi channel quality dropped'**
  String get wifiChannelQualityDroppedTitle;

  /// No description provided for @wifiChannelQualityDroppedBody.
  ///
  /// In en, this message translates to:
  /// **'Channel {channel} is now {rating}/10. Channel {recommendedChannel} is at {recommendedRating}/10 — consider switching.'**
  String wifiChannelQualityDroppedBody(
    int channel,
    String rating,
    int recommendedChannel,
    String recommendedRating,
  );

  /// No description provided for @attackDetectedTitle.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Attack Detected: {attackType}'**
  String attackDetectedTitle(String attackType);

  /// No description provided for @stabilizerJitterSpikeTitle.
  ///
  /// In en, this message translates to:
  /// **'Jitter spike detected'**
  String get stabilizerJitterSpikeTitle;

  /// No description provided for @stabilizerFasterDnsTitle.
  ///
  /// In en, this message translates to:
  /// **'Faster DNS available'**
  String get stabilizerFasterDnsTitle;

  /// No description provided for @stabilizerPacketLossTitle.
  ///
  /// In en, this message translates to:
  /// **'Persistent packet loss'**
  String get stabilizerPacketLossTitle;

  /// No description provided for @stabilizerJitterSpikeBody.
  ///
  /// In en, this message translates to:
  /// **'Jitter exceeded {threshold} ms for {window} samples. Cycling the tunnel may break a sticky bad path.'**
  String stabilizerJitterSpikeBody(String threshold, int window);

  /// No description provided for @stabilizerFasterDnsBody.
  ///
  /// In en, this message translates to:
  /// **'A faster DNS ({label}) is available.'**
  String stabilizerFasterDnsBody(String label);

  /// No description provided for @stabilizerPacketLossBody.
  ///
  /// In en, this message translates to:
  /// **'Packet loss is {loss}%. Dual-interface send (Wi-Fi + cellular) can mask transient drops.'**
  String stabilizerPacketLossBody(String loss);

  /// No description provided for @lanDiscoveryTitle.
  ///
  /// In en, this message translates to:
  /// **'LAN Devices Discovered'**
  String get lanDiscoveryTitle;

  /// No description provided for @lanDiscoveryDesc.
  ///
  /// In en, this message translates to:
  /// **'Active scanning identified {count} devices on this network.'**
  String lanDiscoveryDesc(int count);

  /// No description provided for @lanDiscoveryEvidence.
  ///
  /// In en, this message translates to:
  /// **'Discovered: {devices}'**
  String lanDiscoveryEvidence(String devices);

  /// No description provided for @lanDiscoveryRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Ensure you recognize all devices on your local network.'**
  String get lanDiscoveryRecommendation;

  /// No description provided for @gatewayPortsExposedTitle.
  ///
  /// In en, this message translates to:
  /// **'Gateway Ports Exposed'**
  String get gatewayPortsExposedTitle;

  /// No description provided for @gatewayPortsExposedDesc.
  ///
  /// In en, this message translates to:
  /// **'Host {ip} has open ports that may be vulnerable.'**
  String gatewayPortsExposedDesc(String ip);

  /// No description provided for @gatewayPortsExposedEvidence.
  ///
  /// In en, this message translates to:
  /// **'Open Ports: {ports}'**
  String gatewayPortsExposedEvidence(String ports);

  /// No description provided for @gatewayPortsExposedRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Disable unnecessary services on the gateway router and ensure strong passwords.'**
  String get gatewayPortsExposedRecommendation;

  /// No description provided for @openServiceDetectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Open Service Detected'**
  String get openServiceDetectedTitle;

  /// No description provided for @openServiceDetectedDesc.
  ///
  /// In en, this message translates to:
  /// **'Host {ip} is running {service} on port {port}.'**
  String openServiceDetectedDesc(String ip, String service, int port);

  /// No description provided for @openServiceDetectedEvidence.
  ///
  /// In en, this message translates to:
  /// **'Target: {ip}, Port: {port}, Service: {service}'**
  String openServiceDetectedEvidence(String ip, int port, String service);

  /// No description provided for @openServiceDetectedRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Ensure this service is intended to be accessible.'**
  String get openServiceDetectedRecommendation;

  /// No description provided for @lanDeviceDiscoveredTitle.
  ///
  /// In en, this message translates to:
  /// **'LAN Device: {name}'**
  String lanDeviceDiscoveredTitle(String name);

  /// No description provided for @lanDeviceDiscoveredEvidence.
  ///
  /// In en, this message translates to:
  /// **'IP: {ip}, MAC: {mac}, Vendor: {vendor}'**
  String lanDeviceDiscoveredEvidence(String ip, String mac, String vendor);

  /// No description provided for @lanDeviceDiscoveredRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Verify this device is yours. Malicious devices often hide in the LAN.'**
  String get lanDeviceDiscoveredRecommendation;

  /// No description provided for @rule_arp_spoofing_title.
  ///
  /// In en, this message translates to:
  /// **'ARP Spoofing Detected'**
  String get rule_arp_spoofing_title;

  /// No description provided for @rule_arp_spoofing_desc.
  ///
  /// In en, this message translates to:
  /// **'Multiple MAC addresses are claiming the same IP address. An attacker may be intercepting your traffic.'**
  String get rule_arp_spoofing_desc;

  /// No description provided for @rule_arp_spoofing_rec.
  ///
  /// In en, this message translates to:
  /// **'Switch to a different network or use a VPN immediately.'**
  String get rule_arp_spoofing_rec;

  /// No description provided for @rule_dns_hijacking_title.
  ///
  /// In en, this message translates to:
  /// **'DNS Hijacking Detected'**
  String get rule_dns_hijacking_title;

  /// No description provided for @rule_dns_hijacking_desc.
  ///
  /// In en, this message translates to:
  /// **'Your DNS queries are being redirected to an unexpected server. This allows an attacker to control which websites you visit.'**
  String get rule_dns_hijacking_desc;

  /// No description provided for @rule_dns_hijacking_rec.
  ///
  /// In en, this message translates to:
  /// **'Switch to a VPN immediately. Your DNS queries are being tampered with.'**
  String get rule_dns_hijacking_rec;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'ku', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'ku':
      return AppLocalizationsKu();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
