import 'package:equatable/equatable.dart';

import '../../domain/entities/dns_candidate.dart';
import '../../domain/entities/live_stats.dart';
import '../../domain/entities/stabilization_profile.dart';
import '../../domain/entities/stabilization_session.dart';
import '../../domain/entities/stabilizer_recommendation.dart';

enum StabilizerStatus {
  idle,
  requestingPermission,
  starting,
  active,
  stopping,
  failure,
}

class PingStabilizerState extends Equatable {
  final StabilizerStatus status;
  final StabilizationProfile? profile;
  final List<StabilizationProfile> profiles;
  final StabilizationSession? session;
  final LiveStats stats;
  final List<DnsCandidate> dnsCandidates;
  final DnsCandidate? activeDns;
  final List<StabilizerRecommendation> recommendations;
  final bool autoSwitchDns;
  final double jitterThresholdMs;
  final int? baselineLatencyMs;
  final String? errorMessage;
  final bool notificationsBlocked;

  const PingStabilizerState({
    this.status = StabilizerStatus.idle,
    this.profile,
    this.profiles = const [],
    this.session,
    required this.stats,
    this.dnsCandidates = const [],
    this.activeDns,
    this.recommendations = const [],
    this.autoSwitchDns = false,
    this.jitterThresholdMs = 30,
    this.baselineLatencyMs,
    this.errorMessage,
    this.notificationsBlocked = false,
  });

  factory PingStabilizerState.initial() => PingStabilizerState(
        stats: LiveStats.empty(),
      );

  PingStabilizerState copyWith({
    StabilizerStatus? status,
    StabilizationProfile? profile,
    List<StabilizationProfile>? profiles,
    StabilizationSession? session,
    LiveStats? stats,
    List<DnsCandidate>? dnsCandidates,
    DnsCandidate? activeDns,
    List<StabilizerRecommendation>? recommendations,
    bool? autoSwitchDns,
    double? jitterThresholdMs,
    int? baselineLatencyMs,
    String? errorMessage,
    bool? notificationsBlocked,
    bool clearError = false,
    bool clearSession = false,
  }) {
    return PingStabilizerState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      profiles: profiles ?? this.profiles,
      session: clearSession ? null : (session ?? this.session),
      stats: stats ?? this.stats,
      dnsCandidates: dnsCandidates ?? this.dnsCandidates,
      activeDns: activeDns ?? this.activeDns,
      recommendations: recommendations ?? this.recommendations,
      autoSwitchDns: autoSwitchDns ?? this.autoSwitchDns,
      jitterThresholdMs: jitterThresholdMs ?? this.jitterThresholdMs,
      baselineLatencyMs: baselineLatencyMs ?? this.baselineLatencyMs,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      notificationsBlocked:
          notificationsBlocked ?? this.notificationsBlocked,
    );
  }

  @override
  List<Object?> get props => [
        status,
        profile,
        profiles,
        session,
        stats,
        dnsCandidates,
        activeDns,
        recommendations,
        autoSwitchDns,
        jitterThresholdMs,
        baselineLatencyMs,
        errorMessage,
        notificationsBlocked,
      ];
}
