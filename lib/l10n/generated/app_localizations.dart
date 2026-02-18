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

  /// No description provided for @activeOperationsBlockedMsg.
  ///
  /// In en, this message translates to:
  /// **'Active operations are blocked unless policy and allowlist conditions pass.'**
  String get activeOperationsBlockedMsg;

  /// No description provided for @authorizedTargets.
  ///
  /// In en, this message translates to:
  /// **'Authorized Targets'**
  String get authorizedTargets;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @noTargetsAllowlisted.
  ///
  /// In en, this message translates to:
  /// **'No targets allowlisted yet.'**
  String get noTargetsAllowlisted;

  /// No description provided for @hiddenNetwork.
  ///
  /// In en, this message translates to:
  /// **'Hidden Network'**
  String get hiddenNetwork;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @securityTimeline.
  ///
  /// In en, this message translates to:
  /// **'Security Timeline'**
  String get securityTimeline;

  /// No description provided for @noSecurityEvents.
  ///
  /// In en, this message translates to:
  /// **'No security events yet.'**
  String get noSecurityEvents;

  /// No description provided for @authorizeTarget.
  ///
  /// In en, this message translates to:
  /// **'Authorize Target'**
  String get authorizeTarget;

  /// No description provided for @ssid.
  ///
  /// In en, this message translates to:
  /// **'SSID'**
  String get ssid;

  /// No description provided for @bssid.
  ///
  /// In en, this message translates to:
  /// **'BSSID'**
  String get bssid;

  /// No description provided for @allowHandshakeCapture.
  ///
  /// In en, this message translates to:
  /// **'Allow handshake capture'**
  String get allowHandshakeCapture;

  /// No description provided for @allowActiveDefense.
  ///
  /// In en, this message translates to:
  /// **'Allow active defense/deauth tests'**
  String get allowActiveDefense;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @legalDisclaimerAccepted.
  ///
  /// In en, this message translates to:
  /// **'Legal disclaimer accepted'**
  String get legalDisclaimerAccepted;

  /// No description provided for @requiredForActiveOps.
  ///
  /// In en, this message translates to:
  /// **'Required for active operations'**
  String get requiredForActiveOps;

  /// No description provided for @strictAllowlist.
  ///
  /// In en, this message translates to:
  /// **'Strict allowlist'**
  String get strictAllowlist;

  /// No description provided for @blockActiveOpsUnknown.
  ///
  /// In en, this message translates to:
  /// **'Block active operations for unknown targets'**
  String get blockActiveOpsUnknown;

  /// No description provided for @rateLimitActiveOps.
  ///
  /// In en, this message translates to:
  /// **'Rate limit between active ops'**
  String get rateLimitActiveOps;

  /// No description provided for @selectFromScanned.
  ///
  /// In en, this message translates to:
  /// **'Select from scanned list'**
  String get selectFromScanned;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsScanBehavior.
  ///
  /// In en, this message translates to:
  /// **'Control default scan behavior, backend strategy, and safety posture.'**
  String get settingsScanBehavior;

  /// No description provided for @settingsDefaultScanPasses.
  ///
  /// In en, this message translates to:
  /// **'Default scan passes'**
  String get settingsDefaultScanPasses;

  /// No description provided for @settingsMonitoringInterval.
  ///
  /// In en, this message translates to:
  /// **'Monitoring interval (seconds)'**
  String get settingsMonitoringInterval;

  /// No description provided for @settingsBackendPreference.
  ///
  /// In en, this message translates to:
  /// **'Default backend preference'**
  String get settingsBackendPreference;

  /// No description provided for @settingsIncludeHidden.
  ///
  /// In en, this message translates to:
  /// **'Include hidden SSIDs by default'**
  String get settingsIncludeHidden;

  /// No description provided for @settingsStrictSafety.
  ///
  /// In en, this message translates to:
  /// **'Strict safety mode'**
  String get settingsStrictSafety;

  /// No description provided for @settingsStrictSafetyDesc.
  ///
  /// In en, this message translates to:
  /// **'Require consent + allowlist for active ops'**
  String get settingsStrictSafetyDesc;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navWifi.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi'**
  String get navWifi;

  /// No description provided for @navLan.
  ///
  /// In en, this message translates to:
  /// **'LAN'**
  String get navLan;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @moreTitle.
  ///
  /// In en, this message translates to:
  /// **'MORE'**
  String get moreTitle;

  /// No description provided for @sectionTools.
  ///
  /// In en, this message translates to:
  /// **'TOOLS'**
  String get sectionTools;

  /// No description provided for @speedTestTitle.
  ///
  /// In en, this message translates to:
  /// **'Speed Test & Monitoring'**
  String get speedTestTitle;

  /// No description provided for @speedTestDesc.
  ///
  /// In en, this message translates to:
  /// **'Bandwidth, latency, and anomaly tracking'**
  String get speedTestDesc;

  /// No description provided for @securityCenterTitle.
  ///
  /// In en, this message translates to:
  /// **'Security Center'**
  String get securityCenterTitle;

  /// No description provided for @securityCenterDesc.
  ///
  /// In en, this message translates to:
  /// **'Risk scoring, allowlists, and policy controls'**
  String get securityCenterDesc;

  /// No description provided for @reportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reportsTitle;

  /// No description provided for @reportsDesc.
  ///
  /// In en, this message translates to:
  /// **'Export scans as PDF, HTML, or JSON'**
  String get reportsDesc;

  /// No description provided for @sectionPreferences.
  ///
  /// In en, this message translates to:
  /// **'PREFERENCES'**
  String get sectionPreferences;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Scan behavior, backends, and safety mode'**
  String get settingsDesc;

  /// No description provided for @monitoringTitle.
  ///
  /// In en, this message translates to:
  /// **'Monitoring'**
  String get monitoringTitle;

  /// No description provided for @monitoringSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Bandwidth, anomaly detection, and heatmap streams.'**
  String get monitoringSubtitle;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'COMING SOON'**
  String get comingSoon;

  /// No description provided for @signalTrends.
  ///
  /// In en, this message translates to:
  /// **'Signal Trends'**
  String get signalTrends;

  /// No description provided for @topologyMesh.
  ///
  /// In en, this message translates to:
  /// **'Topology & Mesh'**
  String get topologyMesh;

  /// No description provided for @anomalyAlerts.
  ///
  /// In en, this message translates to:
  /// **'Anomaly Alerts'**
  String get anomalyAlerts;

  /// No description provided for @speedTestHeader.
  ///
  /// In en, this message translates to:
  /// **'SPEED TEST'**
  String get speedTestHeader;

  /// No description provided for @testConnectionSpeed.
  ///
  /// In en, this message translates to:
  /// **'Test your connection speed'**
  String get testConnectionSpeed;

  /// No description provided for @testing.
  ///
  /// In en, this message translates to:
  /// **'TESTING…'**
  String get testing;

  /// No description provided for @testAgain.
  ///
  /// In en, this message translates to:
  /// **'TEST AGAIN'**
  String get testAgain;

  /// No description provided for @startTest.
  ///
  /// In en, this message translates to:
  /// **'START TEST'**
  String get startTest;

  /// No description provided for @phasePing.
  ///
  /// In en, this message translates to:
  /// **'PING'**
  String get phasePing;

  /// No description provided for @phaseDownload.
  ///
  /// In en, this message translates to:
  /// **'DOWNLOAD'**
  String get phaseDownload;

  /// No description provided for @phaseUpload.
  ///
  /// In en, this message translates to:
  /// **'UPLOAD'**
  String get phaseUpload;

  /// No description provided for @phaseDone.
  ///
  /// In en, this message translates to:
  /// **'DONE'**
  String get phaseDone;

  /// No description provided for @wifiScanTitle.
  ///
  /// In en, this message translates to:
  /// **'WI-FI ANALYZER'**
  String get wifiScanTitle;

  /// No description provided for @scanSettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Scan settings'**
  String get scanSettingsTooltip;

  /// No description provided for @channelRatingTooltip.
  ///
  /// In en, this message translates to:
  /// **'Channel rating'**
  String get channelRatingTooltip;

  /// No description provided for @refreshScanTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh scan'**
  String get refreshScanTooltip;

  /// No description provided for @readyToScan.
  ///
  /// In en, this message translates to:
  /// **'Ready to scan'**
  String get readyToScan;

  /// No description provided for @scanButton.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scanButton;

  /// No description provided for @scanSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan Settings'**
  String get scanSettingsTitle;

  /// No description provided for @passes.
  ///
  /// In en, this message translates to:
  /// **'Passes: {count}'**
  String passes(Object count);

  /// No description provided for @includeHiddenSsids.
  ///
  /// In en, this message translates to:
  /// **'Include hidden SSIDs'**
  String get includeHiddenSsids;

  /// No description provided for @backendPreference.
  ///
  /// In en, this message translates to:
  /// **'Backend preference'**
  String get backendPreference;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @noSignalsDetected.
  ///
  /// In en, this message translates to:
  /// **'No signals detected'**
  String get noSignalsDetected;

  /// No description provided for @lastSnapshot.
  ///
  /// In en, this message translates to:
  /// **'Last Snapshot'**
  String get lastSnapshot;

  /// No description provided for @bandAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Band Analysis'**
  String get bandAnalysis;

  /// No description provided for @networksCount.
  ///
  /// In en, this message translates to:
  /// **'Networks ({count})'**
  String networksCount(Object count);

  /// No description provided for @recommendation.
  ///
  /// In en, this message translates to:
  /// **'Recommendation'**
  String get recommendation;

  /// No description provided for @lanReconTitle.
  ///
  /// In en, this message translates to:
  /// **'LAN RECON'**
  String get lanReconTitle;

  /// No description provided for @scanFailed.
  ///
  /// In en, this message translates to:
  /// **'SCAN FAILED: {message}'**
  String scanFailed(Object message);

  /// No description provided for @readyToScanAllCaps.
  ///
  /// In en, this message translates to:
  /// **'READY TO SCAN'**
  String get readyToScanAllCaps;

  /// No description provided for @targetSubnet.
  ///
  /// In en, this message translates to:
  /// **'Target subnet/IP'**
  String get targetSubnet;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @method.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get method;

  /// No description provided for @scanAllCaps.
  ///
  /// In en, this message translates to:
  /// **'SCAN'**
  String get scanAllCaps;

  /// No description provided for @noHostsFound.
  ///
  /// In en, this message translates to:
  /// **'NO HOSTS FOUND'**
  String get noHostsFound;

  /// No description provided for @unknownHost.
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

  /// No description provided for @reportsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Export the latest scan session as JSON, HTML, or PDF.'**
  String get reportsSubtitle;

  /// No description provided for @noSnapshotAvailable.
  ///
  /// In en, this message translates to:
  /// **'No scan snapshot is available yet. Run a Wi-Fi scan first.'**
  String get noSnapshotAvailable;

  /// No description provided for @latestSnapshot.
  ///
  /// In en, this message translates to:
  /// **'Latest snapshot: {count} networks via {backend}'**
  String latestSnapshot(Object backend, Object count);

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

  /// No description provided for @saveReportDialog.
  ///
  /// In en, this message translates to:
  /// **'Save report'**
  String get saveReportDialog;

  /// No description provided for @savePdfReportDialog.
  ///
  /// In en, this message translates to:
  /// **'Save PDF report'**
  String get savePdfReportDialog;

  /// No description provided for @savedToast.
  ///
  /// In en, this message translates to:
  /// **'Saved: {path}'**
  String savedToast(Object path);

  /// No description provided for @handshakeCaptureCheck.
  ///
  /// In en, this message translates to:
  /// **'Handshake capture check'**
  String get handshakeCaptureCheck;

  /// No description provided for @activeDefenseReadiness.
  ///
  /// In en, this message translates to:
  /// **'Active defense readiness'**
  String get activeDefenseReadiness;

  /// No description provided for @signalGraph.
  ///
  /// In en, this message translates to:
  /// **'Signal Graph'**
  String get signalGraph;

  /// No description provided for @riskFactors.
  ///
  /// In en, this message translates to:
  /// **'RISK FACTORS'**
  String get riskFactors;

  /// No description provided for @vulnerabilities.
  ///
  /// In en, this message translates to:
  /// **'VULNERABILITIES'**
  String get vulnerabilities;

  /// No description provided for @recommendationLabel.
  ///
  /// In en, this message translates to:
  /// **'RECOMMENDATION: {text}'**
  String recommendationLabel(Object text);

  /// No description provided for @noVulnerabilities.
  ///
  /// In en, this message translates to:
  /// **'No known vulnerabilities detected based on current scan data.'**
  String get noVulnerabilities;

  /// No description provided for @bssId.
  ///
  /// In en, this message translates to:
  /// **'BSSID'**
  String get bssId;

  /// No description provided for @channel.
  ///
  /// In en, this message translates to:
  /// **'CHANNEL'**
  String get channel;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'SECURITY'**
  String get security;

  /// No description provided for @signal.
  ///
  /// In en, this message translates to:
  /// **'SIGNAL'**
  String get signal;

  /// No description provided for @channelRatingTitle.
  ///
  /// In en, this message translates to:
  /// **'CHANNEL RATING'**
  String get channelRatingTitle;

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

  /// No description provided for @no24GhzChannels.
  ///
  /// In en, this message translates to:
  /// **'No 2.4 GHz channels detected.'**
  String get no24GhzChannels;

  /// No description provided for @no5GhzChannels.
  ///
  /// In en, this message translates to:
  /// **'No 5 GHz channels detected.'**
  String get no5GhzChannels;

  /// No description provided for @recommendedChannel.
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

  /// No description provided for @errorLabel.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorLabel;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @analyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing…'**
  String get analyzing;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @scannedNetworksTitle.
  ///
  /// In en, this message translates to:
  /// **'Scanned Networks'**
  String get scannedNetworksTitle;

  /// No description provided for @noNetworksFound.
  ///
  /// In en, this message translates to:
  /// **'No networks found.'**
  String get noNetworksFound;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @knownNetworks.
  ///
  /// In en, this message translates to:
  /// **'Known Networks'**
  String get knownNetworks;

  /// No description provided for @noKnownNetworksYet.
  ///
  /// In en, this message translates to:
  /// **'No known networks yet.'**
  String get noKnownNetworksYet;

  /// No description provided for @opsLabel.
  ///
  /// In en, this message translates to:
  /// **'Ops: {ops}'**
  String opsLabel(Object ops);
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
