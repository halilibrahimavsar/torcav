import 'package:equatable/equatable.dart';

import 'stabilization_profile.dart';

class StabilizationSession extends Equatable {
  final String id;
  final DateTime startedAt;
  final StabilizationProfile profile;
  final double? baselineLatencyMs;

  const StabilizationSession({
    required this.id,
    required this.startedAt,
    required this.profile,
    this.baselineLatencyMs,
  });

  @override
  List<Object?> get props => [id, startedAt, profile, baselineLatencyMs];
}
