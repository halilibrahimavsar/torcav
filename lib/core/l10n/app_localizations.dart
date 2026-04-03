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

  /// No description provided for @plusNewLabel.
  ///
  /// In en, this message translates to:
  /// **'+ NEW'**
  String get plusNewLabel;

  /// No description provided for @goneLabel.
  ///
  /// In en, this message translates to:
  /// **'GONE'**
  String get goneLabel;

  /// No description provided for @hiddenLabel.
  ///
  /// In en, this message translates to:
  /// **'[Hidden]'**
  String get hiddenLabel;

  /// Wifi channel.
  ///
  /// In en, this message translates to:
  /// **'CH {channel}'**
  String channelLabel(int channel);

  /// No description provided for @securityLabel.
  ///
  /// In en, this message translates to:
  /// **'SECURITY'**
  String get securityLabel;

  /// No description provided for @initiatingSpectrumScan.
  ///
  /// In en, this message translates to:
  /// **'INITIATING SPECTRUM SCAN...'**
  String get initiatingSpectrumScan;

  /// No description provided for @broadcastingProbeRequests.
  ///
  /// In en, this message translates to:
  /// **'BROADCASTING PROBE REQUESTS...'**
  String get broadcastingProbeRequests;

  /// No description provided for @noRadiosInRange.
  ///
  /// In en, this message translates to:
  /// **'No radios in range'**
  String get noRadiosInRange;

  /// No description provided for @noNetworksMatchFilter.
  ///
  /// In en, this message translates to:
  /// **'No networks match your filter'**
  String get noNetworksMatchFilter;

  /// No description provided for @searchSsidBssidVendor.
  ///
  /// In en, this message translates to:
  /// **'Search SSID, BSSID or Vendor...'**
  String get searchSsidBssidVendor;

  /// No description provided for @sortPrefix.
  ///
  /// In en, this message translates to:
  /// **'Sort: {option}'**
  String sortPrefix(String option);

  /// No description provided for @bandAll.
  ///
  /// In en, this message translates to:
  /// **'ALL BANDS'**
  String get bandAll;

  /// No description provided for @sortSignal.
  ///
  /// In en, this message translates to:
  /// **'Signal'**
  String get sortSignal;

  /// No description provided for @sortName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get sortName;

  /// No description provided for @sortChannel.
  ///
  /// In en, this message translates to:
  /// **'Channel'**
  String get sortChannel;

  /// No description provided for @sortSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get sortSecurity;

  /// No description provided for @sortByTitle.
  ///
  /// In en, this message translates to:
  /// **'SORT BY'**
  String get sortByTitle;

  /// No description provided for @recommendationTip.
  ///
  /// In en, this message translates to:
  /// **'Optimum channels on {band}: {channels}'**
  String recommendationTip(String channels, String band);

  /// No description provided for @channelInterferenceTitle.
  ///
  /// In en, this message translates to:
  /// **'Channel Interference'**
  String get channelInterferenceTitle;

  /// No description provided for @networksLabel.
  ///
  /// In en, this message translates to:
  /// **'NETWORKS'**
  String get networksLabel;

  /// No description provided for @openCount.
  ///
  /// In en, this message translates to:
  /// **'{count} OPEN'**
  String openCount(int count);

  /// No description provided for @avgSignalLabel.
  ///
  /// In en, this message translates to:
  /// **'AVG SIGNAL'**
  String get avgSignalLabel;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notAvailable;

  /// No description provided for @dbmCaps.
  ///
  /// In en, this message translates to:
  /// **'DBM'**
  String get dbmCaps;

  /// No description provided for @interfaceLabel.
  ///
  /// In en, this message translates to:
  /// **'INTERFACE'**
  String get interfaceLabel;

  /// No description provided for @frequencyLabel.
  ///
  /// In en, this message translates to:
  /// **'{freq} MHz'**
  String frequencyLabel(int freq);

  /// No description provided for @reportsTitle.
  ///
  /// In en, this message translates to:
  /// **'REPORTS'**
  String get reportsTitle;

  /// No description provided for @saveReportDialog.
  ///
  /// In en, this message translates to:
  /// **'Save Report'**
  String get saveReportDialog;

  /// No description provided for @savedToast.
  ///
  /// In en, this message translates to:
  /// **'Report saved to {path}'**
  String savedToast(String path);

  /// No description provided for @errorLabel.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorLabel;

  /// No description provided for @savePdfReportDialog.
  ///
  /// In en, this message translates to:
  /// **'Save PDF Report'**
  String get savePdfReportDialog;

  /// No description provided for @scanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning...'**
  String get scanning;

  /// No description provided for @shieldActive.
  ///
  /// In en, this message translates to:
  /// **'Shield Active'**
  String get shieldActive;

  /// No description provided for @threatsDetected.
  ///
  /// In en, this message translates to:
  /// **'Threats Detected'**
  String get threatsDetected;

  /// No description provided for @trustedLabel.
  ///
  /// In en, this message translates to:
  /// **'TRUSTED'**
  String get trustedLabel;

  /// No description provided for @securityEventTitle.
  ///
  /// In en, this message translates to:
  /// **'Security Event'**
  String get securityEventTitle;

  /// No description provided for @networkReconTitle.
  ///
  /// In en, this message translates to:
  /// **'NETWORK RECON'**
  String get networkReconTitle;

  /// No description provided for @intelligenceReportTitle.
  ///
  /// In en, this message translates to:
  /// **'INTELLIGENCE REPORT'**
  String get intelligenceReportTitle;

  /// No description provided for @discoveredEndpointsTitle.
  ///
  /// In en, this message translates to:
  /// **'DISCOVERED ENDPOINTS'**
  String get discoveredEndpointsTitle;

  /// No description provided for @newDeviceFound.
  ///
  /// In en, this message translates to:
  /// **'1 new device: {ip}'**
  String newDeviceFound(String ip);

  /// No description provided for @newDevicesFound.
  ///
  /// In en, this message translates to:
  /// **'{count} new devices on your network'**
  String newDevicesFound(int count);

  /// No description provided for @targetIpSubnet.
  ///
  /// In en, this message translates to:
  /// **'Target IP / Subnet'**
  String get targetIpSubnet;

  /// No description provided for @scanProfileFast.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get scanProfileFast;

  /// No description provided for @scanProfileBalanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get scanProfileBalanced;

  /// No description provided for @scanProfileAggressive.
  ///
  /// In en, this message translates to:
  /// **'Aggressive'**
  String get scanProfileAggressive;

  /// No description provided for @scanProfileNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get scanProfileNormal;

  /// No description provided for @scanProfileIntense.
  ///
  /// In en, this message translates to:
  /// **'Intense'**
  String get scanProfileIntense;

  /// No description provided for @vulnOnlyLabel.
  ///
  /// In en, this message translates to:
  /// **'Vulnerabilities Only'**
  String get vulnOnlyLabel;

  /// No description provided for @lanReconTitle.
  ///
  /// In en, this message translates to:
  /// **'LAN RECON'**
  String get lanReconTitle;

  /// No description provided for @targetSubnet.
  ///
  /// In en, this message translates to:
  /// **'Target IP / Subnet'**
  String get targetSubnet;

  /// No description provided for @scanAllCaps.
  ///
  /// In en, this message translates to:
  /// **'SCAN'**
  String get scanAllCaps;

  /// No description provided for @channelRatingTitle.
  ///
  /// In en, this message translates to:
  /// **'CHANNEL RATING'**
  String get channelRatingTitle;

  /// No description provided for @refreshScanTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh Scan'**
  String get refreshScanTooltip;

  /// No description provided for @band24Ghz.
  ///
  /// In en, this message translates to:
  /// **'2.4 GHz'**
  String get band24Ghz;

  /// No description provided for @band5Ghz.
  ///
  /// In en, this message translates to:
  /// **'5 GHz'**
  String get band5Ghz;

  /// No description provided for @band6Ghz.
  ///
  /// In en, this message translates to:
  /// **'6 GHz'**
  String get band6Ghz;

  /// No description provided for @no24GhzChannels.
  ///
  /// In en, this message translates to:
  /// **'No 2.4 GHz channels found.'**
  String get no24GhzChannels;

  /// No description provided for @no5GhzChannels.
  ///
  /// In en, this message translates to:
  /// **'No 5 GHz channels found.'**
  String get no5GhzChannels;

  /// No description provided for @no6GhzChannels.
  ///
  /// In en, this message translates to:
  /// **'No 6 GHz channels found.'**
  String get no6GhzChannels;

  /// No description provided for @analyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing...'**
  String get analyzing;

  /// No description provided for @historyLabel.
  ///
  /// In en, this message translates to:
  /// **'HISTORY'**
  String get historyLabel;

  /// No description provided for @failedLoadTopology.
  ///
  /// In en, this message translates to:
  /// **'Failed to load topology: {error}'**
  String failedLoadTopology(String error);

  /// No description provided for @trafficLabel.
  ///
  /// In en, this message translates to:
  /// **'TRAFFIC'**
  String get trafficLabel;

  /// No description provided for @forceLabel.
  ///
  /// In en, this message translates to:
  /// **'FORCE'**
  String get forceLabel;

  /// No description provided for @normalSpeed.
  ///
  /// In en, this message translates to:
  /// **'NORMAL'**
  String get normalSpeed;

  /// No description provided for @fastSpeed.
  ///
  /// In en, this message translates to:
  /// **'FAST'**
  String get fastSpeed;

  /// No description provided for @overdriveSpeed.
  ///
  /// In en, this message translates to:
  /// **'OVERDRIVE'**
  String get overdriveSpeed;

  /// No description provided for @topologyMapTitle.
  ///
  /// In en, this message translates to:
  /// **'TOPOLOGY MAP'**
  String get topologyMapTitle;

  /// No description provided for @noTopologyData.
  ///
  /// In en, this message translates to:
  /// **'No Topology Data'**
  String get noTopologyData;

  /// No description provided for @runScanFirst.
  ///
  /// In en, this message translates to:
  /// **'Run a scan first to build the network map'**
  String get runScanFirst;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'RETRY'**
  String get retry;

  /// No description provided for @thisDevice.
  ///
  /// In en, this message translates to:
  /// **'THIS DEVICE'**
  String get thisDevice;

  /// No description provided for @gatewayDevice.
  ///
  /// In en, this message translates to:
  /// **'GATEWAY'**
  String get gatewayDevice;

  /// No description provided for @mobileDevice.
  ///
  /// In en, this message translates to:
  /// **'MOBILE'**
  String get mobileDevice;

  /// No description provided for @deviceLabel.
  ///
  /// In en, this message translates to:
  /// **'DEVICE'**
  String get deviceLabel;

  /// No description provided for @iotDevice.
  ///
  /// In en, this message translates to:
  /// **'IOT'**
  String get iotDevice;

  /// No description provided for @analyzingNode.
  ///
  /// In en, this message translates to:
  /// **'ANALYZING NODE'**
  String get analyzingNode;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get settingsTitle;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @settingsScanBehavior.
  ///
  /// In en, this message translates to:
  /// **'Scan Behavior'**
  String get settingsScanBehavior;

  /// No description provided for @settingsDefaultScanPasses.
  ///
  /// In en, this message translates to:
  /// **'Default Scan Passes'**
  String get settingsDefaultScanPasses;

  /// No description provided for @settingsMonitoringInterval.
  ///
  /// In en, this message translates to:
  /// **'Monitoring Interval'**
  String get settingsMonitoringInterval;

  /// No description provided for @settingsBackendPreference.
  ///
  /// In en, this message translates to:
  /// **'Backend Preference'**
  String get settingsBackendPreference;

  /// No description provided for @settingsIncludeHidden.
  ///
  /// In en, this message translates to:
  /// **'Include Hidden SSIDs'**
  String get settingsIncludeHidden;

  /// No description provided for @settingsStrictSafety.
  ///
  /// In en, this message translates to:
  /// **'Strict Safety Mode'**
  String get settingsStrictSafety;

  /// No description provided for @settingsStrictSafetyDesc.
  ///
  /// In en, this message translates to:
  /// **'Restrict dangerous operations'**
  String get settingsStrictSafetyDesc;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemTheme;

  /// No description provided for @sectionStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get sectionStatus;

  /// No description provided for @reportsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Network Scan & Security Intelligence'**
  String get reportsSubtitle;

  /// No description provided for @exportOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'EXPORT OPTIONS'**
  String get exportOptionsTitle;

  /// No description provided for @exportJson.
  ///
  /// In en, this message translates to:
  /// **'Export JSON'**
  String get exportJson;

  /// No description provided for @exportHtml.
  ///
  /// In en, this message translates to:
  /// **'Export HTML'**
  String get exportHtml;

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get exportPdf;

  /// No description provided for @printPdf.
  ///
  /// In en, this message translates to:
  /// **'Print PDF'**
  String get printPdf;

  /// No description provided for @navWifi.
  ///
  /// In en, this message translates to:
  /// **'WIFI'**
  String get navWifi;

  /// No description provided for @backendLabel.
  ///
  /// In en, this message translates to:
  /// **'BACKEND'**
  String get backendLabel;

  /// No description provided for @defenseTitle.
  ///
  /// In en, this message translates to:
  /// **'DEFENSE'**
  String get defenseTitle;

  /// No description provided for @knownNetworks.
  ///
  /// In en, this message translates to:
  /// **'Known Networks'**
  String get knownNetworks;

  /// No description provided for @noKnownNetworksYet.
  ///
  /// In en, this message translates to:
  /// **'No known networks yet'**
  String get noKnownNetworksYet;

  /// No description provided for @securityTimeline.
  ///
  /// In en, this message translates to:
  /// **'Security Timeline'**
  String get securityTimeline;

  /// No description provided for @noSecurityEvents.
  ///
  /// In en, this message translates to:
  /// **'No security events recorded'**
  String get noSecurityEvents;

  /// No description provided for @authLocalSystem.
  ///
  /// In en, this message translates to:
  /// **'AUTH_LOCAL_SYSTEM'**
  String get authLocalSystem;

  /// No description provided for @remoteNodeIdLabel.
  ///
  /// In en, this message translates to:
  /// **'REMOTE_NODE_ID: {id}'**
  String remoteNodeIdLabel(String id);

  /// No description provided for @ipAddrLabel.
  ///
  /// In en, this message translates to:
  /// **'IP_ADDR'**
  String get ipAddrLabel;

  /// No description provided for @macValLabel.
  ///
  /// In en, this message translates to:
  /// **'MAC_VAL'**
  String get macValLabel;

  /// No description provided for @mnfrLabel.
  ///
  /// In en, this message translates to:
  /// **'MNFR'**
  String get mnfrLabel;

  /// No description provided for @hiddenNetwork.
  ///
  /// In en, this message translates to:
  /// **'Hidden Network'**
  String get hiddenNetwork;

  /// No description provided for @signalGraph.
  ///
  /// In en, this message translates to:
  /// **'Signal Graph'**
  String get signalGraph;

  /// No description provided for @riskFactors.
  ///
  /// In en, this message translates to:
  /// **'Risk Factors'**
  String get riskFactors;

  /// No description provided for @vulnerabilities.
  ///
  /// In en, this message translates to:
  /// **'Vulnerabilities'**
  String get vulnerabilities;

  /// No description provided for @bssId.
  ///
  /// In en, this message translates to:
  /// **'BSSID'**
  String get bssId;

  /// No description provided for @channel.
  ///
  /// In en, this message translates to:
  /// **'Channel'**
  String get channel;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @signal.
  ///
  /// In en, this message translates to:
  /// **'Signal'**
  String get signal;

  /// No description provided for @recommendationLabel.
  ///
  /// In en, this message translates to:
  /// **'RECO: {text}'**
  String recommendationLabel(String text);

  /// No description provided for @noVulnerabilities.
  ///
  /// In en, this message translates to:
  /// **'No vulnerabilities detected.'**
  String get noVulnerabilities;

  /// No description provided for @securityScoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Security Score'**
  String get securityScoreTitle;

  /// No description provided for @securityScoreDesc.
  ///
  /// In en, this message translates to:
  /// **'The security score (0–100) rates how well this network is protected. Higher is better. It considers encryption type, WPS status, and other security features.'**
  String get securityScoreDesc;

  /// No description provided for @capabilitiesLabel.
  ///
  /// In en, this message translates to:
  /// **'CAPABILITIES'**
  String get capabilitiesLabel;

  /// No description provided for @wifi7MldLabel.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi 7 MLD'**
  String get wifi7MldLabel;

  /// No description provided for @tagWpa3Desc.
  ///
  /// In en, this message translates to:
  /// **'WPA3 is the latest Wi-Fi security standard — highly secure.'**
  String get tagWpa3Desc;

  /// No description provided for @tagWpa2Desc.
  ///
  /// In en, this message translates to:
  /// **'WPA2 is a strong security standard — safe for everyday use.'**
  String get tagWpa2Desc;

  /// No description provided for @tagWpaDesc.
  ///
  /// In en, this message translates to:
  /// **'WPA is an older security standard with known weaknesses.'**
  String get tagWpaDesc;

  /// No description provided for @tagWpsDesc.
  ///
  /// In en, this message translates to:
  /// **'WPS (Wi-Fi Protected Setup) has known security vulnerabilities. It can allow attackers to brute-force the PIN and gain access.'**
  String get tagWpsDesc;

  /// No description provided for @tagPmfDesc.
  ///
  /// In en, this message translates to:
  /// **'Protected Management Frames (PMF/MFP) protects against deauthentication attacks.'**
  String get tagPmfDesc;

  /// No description provided for @tagEssDesc.
  ///
  /// In en, this message translates to:
  /// **'ESS (Extended Service Set) means this is a standard access point network.'**
  String get tagEssDesc;

  /// No description provided for @tagCcmpDesc.
  ///
  /// In en, this message translates to:
  /// **'CCMP (AES) is a strong encryption cipher used with WPA2/WPA3.'**
  String get tagCcmpDesc;

  /// No description provided for @tagTkipDesc.
  ///
  /// In en, this message translates to:
  /// **'TKIP is an older, weaker encryption cipher. CCMP/AES is preferred.'**
  String get tagTkipDesc;

  /// No description provided for @tagUnknownDesc.
  ///
  /// In en, this message translates to:
  /// **'Network capability flag from the beacon frame.'**
  String get tagUnknownDesc;

  /// No description provided for @scanProfileLabel.
  ///
  /// In en, this message translates to:
  /// **'SCAN PROFILE'**
  String get scanProfileLabel;

  /// No description provided for @infoScanProfilesTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan Profiles'**
  String get infoScanProfilesTitle;

  /// No description provided for @infoScanProfileFastDesc.
  ///
  /// In en, this message translates to:
  /// **'Fast: Quick ping sweep — finds devices in seconds.'**
  String get infoScanProfileFastDesc;

  /// No description provided for @infoScanProfileBalancedDesc.
  ///
  /// In en, this message translates to:
  /// **'Balanced: Ping + common ports — finds more detail.'**
  String get infoScanProfileBalancedDesc;

  /// No description provided for @infoScanProfileAggressiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Aggressive: Full port scan — most thorough but slowest.'**
  String get infoScanProfileAggressiveDesc;

  /// No description provided for @activeNodeRecon.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE NODE RECONNAISSANCE'**
  String get activeNodeRecon;

  /// No description provided for @interrogatingSubnet.
  ///
  /// In en, this message translates to:
  /// **'Interrogating subnet for responsive hosts...'**
  String get interrogatingSubnet;

  /// No description provided for @nodesLabel.
  ///
  /// In en, this message translates to:
  /// **'Nodes'**
  String get nodesLabel;

  /// No description provided for @riskAvgLabel.
  ///
  /// In en, this message translates to:
  /// **'Risk Avg'**
  String get riskAvgLabel;

  /// No description provided for @servicesLabel.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get servicesLabel;

  /// No description provided for @openPortsLabel.
  ///
  /// In en, this message translates to:
  /// **'OPEN PORTS'**
  String get openPortsLabel;

  /// No description provided for @subnetLabel.
  ///
  /// In en, this message translates to:
  /// **'Subnet'**
  String get subnetLabel;

  /// No description provided for @cidrTargetLabel.
  ///
  /// In en, this message translates to:
  /// **'CIDR TARGET'**
  String get cidrTargetLabel;

  /// No description provided for @anonymousNode.
  ///
  /// In en, this message translates to:
  /// **'ANONYMOUS NODE'**
  String get anonymousNode;

  /// No description provided for @portsCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} PORTS'**
  String portsCountLabel(int count);

  /// No description provided for @riskLabel.
  ///
  /// In en, this message translates to:
  /// **'RISK'**
  String get riskLabel;

  /// No description provided for @searchLanPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search by IP, hostname, or vendor...'**
  String get searchLanPlaceholder;

  /// No description provided for @hasVulnerabilitiesLabel.
  ///
  /// In en, this message translates to:
  /// **'Has Vulnerabilities'**
  String get hasVulnerabilitiesLabel;

  /// No description provided for @securityStatusSecure.
  ///
  /// In en, this message translates to:
  /// **'Secure'**
  String get securityStatusSecure;

  /// No description provided for @securityStatusModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get securityStatusModerate;

  /// No description provided for @securityStatusAtRisk.
  ///
  /// In en, this message translates to:
  /// **'At Risk'**
  String get securityStatusAtRisk;

  /// No description provided for @securityStatusCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get securityStatusCritical;

  /// No description provided for @securitySummarySecure.
  ///
  /// In en, this message translates to:
  /// **'Your connection looks good! This network uses strong encryption and is well protected against common attacks.'**
  String get securitySummarySecure;

  /// No description provided for @securitySummaryModerate.
  ///
  /// In en, this message translates to:
  /// **'This network has decent security but some potential weaknesses. It is safe for everyday use, but avoid sensitive transactions.'**
  String get securitySummaryModerate;

  /// No description provided for @securitySummaryAtRisk.
  ///
  /// In en, this message translates to:
  /// **'This network has security issues that put your data at risk. Avoid entering passwords or personal information while connected.'**
  String get securitySummaryAtRisk;

  /// No description provided for @securitySummaryCritical.
  ///
  /// In en, this message translates to:
  /// **'Warning: This network is not secure. Anyone nearby may be able to see your internet traffic. Use a VPN or switch networks.'**
  String get securitySummaryCritical;

  /// No description provided for @vulnerabilityOpenNetworkTitle.
  ///
  /// In en, this message translates to:
  /// **'Open Network'**
  String get vulnerabilityOpenNetworkTitle;

  /// No description provided for @vulnerabilityOpenNetworkDesc.
  ///
  /// In en, this message translates to:
  /// **'No encryption detected. All traffic can be sniffed in plaintext.'**
  String get vulnerabilityOpenNetworkDesc;

  /// No description provided for @vulnerabilityOpenNetworkRec.
  ///
  /// In en, this message translates to:
  /// **'Avoid sensitive activity. Prefer trusted VPN or different network.'**
  String get vulnerabilityOpenNetworkRec;

  /// No description provided for @vulnerabilityWepTitle.
  ///
  /// In en, this message translates to:
  /// **'WEP Encryption'**
  String get vulnerabilityWepTitle;

  /// No description provided for @vulnerabilityWepDesc.
  ///
  /// In en, this message translates to:
  /// **'WEP is deprecated and can be cracked quickly.'**
  String get vulnerabilityWepDesc;

  /// No description provided for @vulnerabilityWepRec.
  ///
  /// In en, this message translates to:
  /// **'Reconfigure AP to WPA2 or WPA3 immediately.'**
  String get vulnerabilityWepRec;

  /// No description provided for @vulnerabilityLegacyWpaTitle.
  ///
  /// In en, this message translates to:
  /// **'Legacy WPA'**
  String get vulnerabilityLegacyWpaTitle;

  /// No description provided for @vulnerabilityLegacyWpaDesc.
  ///
  /// In en, this message translates to:
  /// **'WPA/TKIP is older and weaker against modern attack techniques.'**
  String get vulnerabilityLegacyWpaDesc;

  /// No description provided for @vulnerabilityLegacyWpaRec.
  ///
  /// In en, this message translates to:
  /// **'Upgrade AP and clients to WPA2/WPA3.'**
  String get vulnerabilityLegacyWpaRec;

  /// No description provided for @vulnerabilityHiddenSsidTitle.
  ///
  /// In en, this message translates to:
  /// **'Hidden SSID'**
  String get vulnerabilityHiddenSsidTitle;

  /// No description provided for @vulnerabilityHiddenSsidDesc.
  ///
  /// In en, this message translates to:
  /// **'Hidden SSIDs are still discoverable and may hurt compatibility.'**
  String get vulnerabilityHiddenSsidDesc;

  /// No description provided for @vulnerabilityHiddenSsidRec.
  ///
  /// In en, this message translates to:
  /// **'Hidden SSID alone is not protection. Focus on strong encryption.'**
  String get vulnerabilityHiddenSsidRec;

  /// No description provided for @vulnerabilityWeakSignalTitle.
  ///
  /// In en, this message translates to:
  /// **'Very Weak Signal'**
  String get vulnerabilityWeakSignalTitle;

  /// No description provided for @vulnerabilityWeakSignalDesc.
  ///
  /// In en, this message translates to:
  /// **'Weak signal can indicate unstable links and spoofing susceptibility.'**
  String get vulnerabilityWeakSignalDesc;

  /// No description provided for @vulnerabilityWeakSignalRec.
  ///
  /// In en, this message translates to:
  /// **'Move closer to AP or validate BSSID consistency.'**
  String get vulnerabilityWeakSignalRec;

  /// No description provided for @vulnerabilityWpsTitle.
  ///
  /// In en, this message translates to:
  /// **'WPS Enabled'**
  String get vulnerabilityWpsTitle;

  /// No description provided for @vulnerabilityWpsDesc.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi Protected Setup (WPS) is enabled. The WPS PIN mode can be brute-forced in hours using Pixie Dust attack, effectively bypassing any password.'**
  String get vulnerabilityWpsDesc;

  /// No description provided for @vulnerabilityWpsRec.
  ///
  /// In en, this message translates to:
  /// **'Disable WPS in your router admin panel. Use WPA2/WPA3 passphrase only.'**
  String get vulnerabilityWpsRec;

  /// No description provided for @vulnerabilityPmfTitle.
  ///
  /// In en, this message translates to:
  /// **'Management Frames Unprotected'**
  String get vulnerabilityPmfTitle;

  /// No description provided for @vulnerabilityPmfDesc.
  ///
  /// In en, this message translates to:
  /// **'This access point does not enforce Protected Management Frames (PMF / 802.11w). Unprotected management frames allow an attacker to forge deauthentication packets and disconnect clients.'**
  String get vulnerabilityPmfDesc;

  /// No description provided for @vulnerabilityPmfRec.
  ///
  /// In en, this message translates to:
  /// **'Enable PMF in router settings (often labelled \'802.11w\' or \'Management Frame Protection\'). WPA3 requires PMF by default.'**
  String get vulnerabilityPmfRec;

  /// No description provided for @vulnerabilityEvilTwinTitle.
  ///
  /// In en, this message translates to:
  /// **'Potential Evil Twin'**
  String get vulnerabilityEvilTwinTitle;

  /// No description provided for @vulnerabilityEvilTwinDesc.
  ///
  /// In en, this message translates to:
  /// **'SSID appears with conflicting security/channel fingerprint nearby.'**
  String get vulnerabilityEvilTwinDesc;

  /// No description provided for @vulnerabilityEvilTwinRec.
  ///
  /// In en, this message translates to:
  /// **'Verify BSSID and certificate before authentication or data exchange.'**
  String get vulnerabilityEvilTwinRec;

  /// No description provided for @riskFactorNoEncryption.
  ///
  /// In en, this message translates to:
  /// **'No encryption in use'**
  String get riskFactorNoEncryption;

  /// No description provided for @riskFactorDeprecatedEncryption.
  ///
  /// In en, this message translates to:
  /// **'Deprecated encryption (WEP)'**
  String get riskFactorDeprecatedEncryption;

  /// No description provided for @riskFactorLegacyWpa.
  ///
  /// In en, this message translates to:
  /// **'Legacy WPA in use'**
  String get riskFactorLegacyWpa;

  /// No description provided for @riskFactorHiddenSsid.
  ///
  /// In en, this message translates to:
  /// **'Hidden SSID behavior'**
  String get riskFactorHiddenSsid;

  /// No description provided for @riskFactorWeakSignal.
  ///
  /// In en, this message translates to:
  /// **'Weak signal environment'**
  String get riskFactorWeakSignal;

  /// No description provided for @riskFactorWpsEnabled.
  ///
  /// In en, this message translates to:
  /// **'WPS PIN attack surface exposed'**
  String get riskFactorWpsEnabled;

  /// No description provided for @riskFactorPmfNotEnforced.
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

  /// No description provided for @failedToSaveHeatmapPoint.
  ///
  /// In en, this message translates to:
  /// **'Failed to save heatmap point'**
  String get failedToSaveHeatmapPoint;

  /// No description provided for @signalMonitoringTitle.
  ///
  /// In en, this message translates to:
  /// **'SIGNAL MONITORING: {ssid}'**
  String signalMonitoringTitle(String ssid);

  /// No description provided for @heatmapTooltip.
  ///
  /// In en, this message translates to:
  /// **'Heatmap'**
  String get heatmapTooltip;

  /// No description provided for @tagCurrentPointTooltip.
  ///
  /// In en, this message translates to:
  /// **'Tag current point'**
  String get tagCurrentPointTooltip;

  /// No description provided for @signalCaps.
  ///
  /// In en, this message translates to:
  /// **'SIGNAL'**
  String get signalCaps;

  /// No description provided for @channelCaps.
  ///
  /// In en, this message translates to:
  /// **'CHANNEL'**
  String get channelCaps;

  /// No description provided for @frequencyCaps.
  ///
  /// In en, this message translates to:
  /// **'FREQ'**
  String get frequencyCaps;

  /// No description provided for @heatmapPointAdded.
  ///
  /// In en, this message translates to:
  /// **'Heatmap point added for {zone}'**
  String heatmapPointAdded(String zone);

  /// No description provided for @zoneTagLabel.
  ///
  /// In en, this message translates to:
  /// **'Zone tag (e.g. Kitchen)'**
  String get zoneTagLabel;

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorPrefix(String message);

  /// No description provided for @noHeatmapPointsYet.
  ///
  /// In en, this message translates to:
  /// **'No heatmap points yet for {bssid}'**
  String noHeatmapPointsYet(String bssid);

  /// No description provided for @averageSignalByZone.
  ///
  /// In en, this message translates to:
  /// **'Average signal by zone'**
  String get averageSignalByZone;

  /// No description provided for @bandChannels.
  ///
  /// In en, this message translates to:
  /// **'{band} CHANNELS'**
  String bandChannels(String band);

  /// No description provided for @recommendedChannel.
  ///
  /// In en, this message translates to:
  /// **'RECOMMENDED CHANNEL'**
  String get recommendedChannel;

  /// No description provided for @channelInfo.
  ///
  /// In en, this message translates to:
  /// **'Channel {ch} · {freq} MHz'**
  String channelInfo(int ch, int freq);

  /// No description provided for @riskFactorFingerprintDrift.
  ///
  /// In en, this message translates to:
  /// **'SSID fingerprint drift detected'**
  String get riskFactorFingerprintDrift;

  /// No description provided for @historyCaps.
  ///
  /// In en, this message translates to:
  /// **'HISTORY'**
  String get historyCaps;

  /// No description provided for @consistentlyBestChannel.
  ///
  /// In en, this message translates to:
  /// **'CONSISTENTLY BEST CHANNEL'**
  String get consistentlyBestChannel;

  /// No description provided for @avgScore.
  ///
  /// In en, this message translates to:
  /// **'Avg Score'**
  String get avgScore;

  /// No description provided for @channelBondingTitle.
  ///
  /// In en, this message translates to:
  /// **'Channel Bonding'**
  String get channelBondingTitle;

  /// No description provided for @channelBondingDesc.
  ///
  /// In en, this message translates to:
  /// **'Channel bonding combines 2 or more adjacent channels to increase bandwidth (40 MHz = 2×, 80 MHz = 4×, 160 MHz = 8×). Wider channels deliver faster speeds but may interfere with more neighboring networks.'**
  String get channelBondingDesc;

  /// No description provided for @spectrumOptimizationCaps.
  ///
  /// In en, this message translates to:
  /// **'SPECTRUM OPTIMIZATION'**
  String get spectrumOptimizationCaps;

  /// No description provided for @spectrumOptimizationDesc.
  ///
  /// In en, this message translates to:
  /// **'Analyze channel congestion & interference'**
  String get spectrumOptimizationDesc;

  /// No description provided for @qualityExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get qualityExcellent;

  /// No description provided for @qualityVeryGood.
  ///
  /// In en, this message translates to:
  /// **'Very Good'**
  String get qualityVeryGood;

  /// No description provided for @qualityGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get qualityGood;

  /// No description provided for @qualityFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get qualityFair;

  /// No description provided for @qualityCongested.
  ///
  /// In en, this message translates to:
  /// **'Congested'**
  String get qualityCongested;

  /// No description provided for @channelBondingHeader.
  ///
  /// In en, this message translates to:
  /// **'CHANNEL BONDING ({count} APs)'**
  String channelBondingHeader(int count);

  /// No description provided for @hiddenSsidLabel.
  ///
  /// In en, this message translates to:
  /// **'[Hidden]'**
  String get hiddenSsidLabel;

  /// No description provided for @noHistoryPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'No history yet.\nChannel ratings are recorded each time you open this screen.'**
  String get noHistoryPlaceholder;

  /// No description provided for @currentSessionInfo.
  ///
  /// In en, this message translates to:
  /// **'Current session — higher score = less congested.'**
  String get currentSessionInfo;

  /// No description provided for @historySummaryInfo.
  ///
  /// In en, this message translates to:
  /// **'{sessions} sessions · {samples} samples · higher = less congested'**
  String historySummaryInfo(int sessions, int samples);

  /// No description provided for @scanReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Torcav Wi-Fi Scan Report'**
  String get scanReportTitle;

  /// No description provided for @reportTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get reportTime;

  /// No description provided for @ssidHeader.
  ///
  /// In en, this message translates to:
  /// **'SSID'**
  String get ssidHeader;

  /// No description provided for @bssidHeader.
  ///
  /// In en, this message translates to:
  /// **'BSSID'**
  String get bssidHeader;

  /// No description provided for @dbmHeader.
  ///
  /// In en, this message translates to:
  /// **'dBm'**
  String get dbmHeader;

  /// No description provided for @channelHeader.
  ///
  /// In en, this message translates to:
  /// **'CH'**
  String get channelHeader;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'DASHBOARD'**
  String get navDashboard;

  /// No description provided for @navDiscovery.
  ///
  /// In en, this message translates to:
  /// **'DISCOVERY'**
  String get navDiscovery;

  /// No description provided for @navOperations.
  ///
  /// In en, this message translates to:
  /// **'OPERATIONS'**
  String get navOperations;

  /// No description provided for @navLan.
  ///
  /// In en, this message translates to:
  /// **'LAN'**
  String get navLan;

  /// No description provided for @systemStatus.
  ///
  /// In en, this message translates to:
  /// **'System Status'**
  String get systemStatus;

  /// No description provided for @interfaceTheme.
  ///
  /// In en, this message translates to:
  /// **'Interface Theme'**
  String get interfaceTheme;

  /// No description provided for @speedTestHeader.
  ///
  /// In en, this message translates to:
  /// **'SPEED TEST'**
  String get speedTestHeader;

  /// No description provided for @startTest.
  ///
  /// In en, this message translates to:
  /// **'START TEST'**
  String get startTest;

  /// No description provided for @testAgain.
  ///
  /// In en, this message translates to:
  /// **'TEST AGAIN'**
  String get testAgain;

  /// No description provided for @commandCenters.
  ///
  /// In en, this message translates to:
  /// **'COMMAND CENTERS'**
  String get commandCenters;

  /// No description provided for @activeShielding.
  ///
  /// In en, this message translates to:
  /// **'Active Shielding'**
  String get activeShielding;

  /// No description provided for @logisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'LOGISTICS'**
  String get logisticsTitle;

  /// No description provided for @intelMetrics.
  ///
  /// In en, this message translates to:
  /// **'Intel Metrics'**
  String get intelMetrics;

  /// No description provided for @networkMesh.
  ///
  /// In en, this message translates to:
  /// **'Network Mesh'**
  String get networkMesh;

  /// No description provided for @tuningTitle.
  ///
  /// In en, this message translates to:
  /// **'TUNING'**
  String get tuningTitle;

  /// No description provided for @systemConfig.
  ///
  /// In en, this message translates to:
  /// **'System Config'**
  String get systemConfig;

  /// No description provided for @phasePing.
  ///
  /// In en, this message translates to:
  /// **'PHASE: PING'**
  String get phasePing;

  /// No description provided for @phaseDownload.
  ///
  /// In en, this message translates to:
  /// **'PHASE: DOWNLOAD'**
  String get phaseDownload;

  /// No description provided for @phaseUpload.
  ///
  /// In en, this message translates to:
  /// **'PHASE: UPLOAD'**
  String get phaseUpload;

  /// No description provided for @phaseDone.
  ///
  /// In en, this message translates to:
  /// **'PHASE: DONE'**
  String get phaseDone;

  /// No description provided for @riskScore.
  ///
  /// In en, this message translates to:
  /// **'Risk Score'**
  String get riskScore;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'PROFILE HUB'**
  String get profileTitle;

  /// No description provided for @activeSessionLabel.
  ///
  /// In en, this message translates to:
  /// **'Active Session'**
  String get activeSessionLabel;

  /// No description provided for @networkStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'NETWORK STATUS'**
  String get networkStatusLabel;

  /// No description provided for @ssid.
  ///
  /// In en, this message translates to:
  /// **'SSID'**
  String get ssid;

  /// No description provided for @lastScanTitle.
  ///
  /// In en, this message translates to:
  /// **'LAST SCAN'**
  String get lastScanTitle;

  /// No description provided for @lastSnapshot.
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
