import 'package:equatable/equatable.dart';

class GamificationTask extends Equatable {
  final String titleKey;
  final int pointValue;
  final String? deepLinkRoute;

  const GamificationTask({
    required this.titleKey,
    required this.pointValue,
    this.deepLinkRoute,
  });

  @override
  List<Object?> get props => [titleKey, pointValue, deepLinkRoute];
}

class NetworkHealthScore extends Equatable {
  final int totalScore;
  final int securityScore;
  final int performanceScore;
  final List<GamificationTask> recommendedTasks;

  const NetworkHealthScore({
    required this.totalScore,
    required this.securityScore,
    required this.performanceScore,
    required this.recommendedTasks,
  });

  @override
  List<Object?> get props =>
      [totalScore, securityScore, performanceScore, recommendedTasks];
}
