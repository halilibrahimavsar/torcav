import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../diagnostics/domain/entities/network_health_score.dart';
import '../../../performance/domain/entities/speed_test_result.dart';
import '../../../security/domain/entities/network_context_type.dart';
import '../../../security/domain/entities/security_assessment.dart';
import '../../../security/domain/entities/security_event.dart';
import '../../../wifi_scan/domain/entities/channel_rating.dart';
import '../../../wifi_scan/domain/entities/scan_snapshot.dart';

sealed class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardSuccess extends DashboardState {
  final String ssid;
  final String ip;
  final String gateway;
  final int networkCount;
  final int securityScore;
  final int? signalQualityPct;
  final int threatCount;
  final int newDeviceCount;
  final ChannelRating? bestChannel;
  final int? currentChannel;
  final List<ChannelRating> channelRatings;
  final SecurityAssessment? worstAssessment;
  final NetworkContextType? connectedContext;
  final String? connectedBssid;
  final List<int> scoreHistory;
  final List<int> rssiHistory;
  final List<SecurityEvent> recentEvents;
  final List<ScanSnapshot> recentSnapshots;
  final SpeedTestResult? lastSpeedTest;
  final NetworkHealthScore? networkHealthScore;

  const DashboardSuccess({
    required this.ssid,
    required this.ip,
    required this.gateway,
    required this.networkCount,
    required this.securityScore,
    this.signalQualityPct,
    required this.threatCount,
    required this.newDeviceCount,
    this.bestChannel,
    this.currentChannel,
    required this.channelRatings,
    this.worstAssessment,
    this.connectedContext,
    this.connectedBssid,
    required this.scoreHistory,
    required this.rssiHistory,
    required this.recentEvents,
    required this.recentSnapshots,
    this.lastSpeedTest,
    this.networkHealthScore,
  });

  @override
  List<Object?> get props => [
        ssid,
        ip,
        gateway,
        networkCount,
        securityScore,
        signalQualityPct,
        threatCount,
        newDeviceCount,
        bestChannel,
        currentChannel,
        channelRatings,
        worstAssessment,
        connectedContext,
        connectedBssid,
        scoreHistory,
        rssiHistory,
        recentEvents,
        recentSnapshots,
        lastSpeedTest,
        networkHealthScore,
      ];
}

class DashboardFailure extends DashboardState {
  final Failure failure;

  const DashboardFailure(this.failure);

  @override
  List<Object?> get props => [failure];
}
