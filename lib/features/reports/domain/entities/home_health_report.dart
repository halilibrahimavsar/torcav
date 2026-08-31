import 'package:equatable/equatable.dart';

/// The four things the home-health report scores.
///
/// An enum rather than the display name it used to switch on: dispatching on
/// `'Wi-Fi'` meant a copy change silently broke the recommendation logic, and
/// it made the report impossible to translate.
enum HealthDial { wifi, security, internet, lanExposure }

/// One recommended action, as a key the presentation layer resolves.
///
/// [deviceIp] and [deviceVendor] are filled only for the LAN action that
/// names a specific device.
class HealthAction extends Equatable {
  const HealthAction(this.key, {this.deviceIp, this.deviceVendor});

  final String key;
  final String? deviceIp;
  final String? deviceVendor;

  @override
  List<Object?> get props => [key, deviceIp, deviceVendor];
}

/// Aggregate one-page summary of the home network: Wi-Fi quality,
/// security posture, internet performance and LAN exposure rolled into
/// four scoring dials plus the underlying counts.
///
/// Designed for a single sharable export (PDF / JSON) that a non-
/// technical user can hand to ISP support, a building manager, or
/// just keep as a snapshot.
class HomeHealthReport extends Equatable {
  /// Generated timestamp.
  final DateTime generatedAt;

  /// Connected SSID (anonymised by the caller if needed).
  final String connectedSsid;

  /// Wi-Fi signal score 0..100 (higher is better). Built from RSSI and
  /// channel cleanliness of the connected radio.
  final int wifiScore;

  /// Security score 0..100 inherited from the security analyzer.
  final int securityScore;

  /// Internet performance score 0..100 from the latest speed test +
  /// bufferbloat grade. 100 means "as fast as the radio can carry".
  final int internetScore;

  /// LAN exposure score 0..100 from the network scan. Lower exposureScore
  /// across hosts maps to a higher health score.
  final int lanScore;

  /// Localization key for the one-line headline.
  final String headlineKey;

  /// The dial that scored worst — what the headline is about.
  final HealthDial worstDial;

  /// Short bullets for the report body, picked from the worst findings.
  final List<HealthAction> topActions;

  /// Raw counts for context (devices found, networks visible, etc.).
  final Map<String, int> stats;

  const HomeHealthReport({
    required this.generatedAt,
    required this.connectedSsid,
    required this.wifiScore,
    required this.securityScore,
    required this.internetScore,
    required this.lanScore,
    required this.headlineKey,
    required this.worstDial,
    required this.topActions,
    required this.stats,
  });

  /// Average of the four dials. Useful for a single "overall" score.
  int get overallScore =>
      ((wifiScore + securityScore + internetScore + lanScore) / 4).round();

  Map<String, dynamic> toJson() => {
    'generatedAt': generatedAt.toIso8601String(),
    'connectedSsid': connectedSsid,
    'overallScore': overallScore,
    'wifiScore': wifiScore,
    'securityScore': securityScore,
    'internetScore': internetScore,
    'lanScore': lanScore,
    'headlineKey': headlineKey,
    'worstDial': worstDial.name,
    'topActions': topActions.map((a) => a.key).toList(),
    'stats': stats,
  };

  @override
  List<Object?> get props => [
    generatedAt,
    connectedSsid,
    wifiScore,
    securityScore,
    internetScore,
    lanScore,
    headlineKey,
    worstDial,
    topActions,
    stats,
  ];
}
