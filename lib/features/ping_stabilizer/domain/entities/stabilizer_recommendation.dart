import 'package:equatable/equatable.dart';

enum RecommendationType { switchDns, suggestDual, reconnectTunnel }

enum RecommendationSeverity { info, warning, critical }

class StabilizerRecommendation extends Equatable {
  final RecommendationType type;
  final RecommendationSeverity severity;
  final String message;
  final Map<String, Object?> payload;
  final DateTime issuedAt;

  StabilizerRecommendation({
    required this.type,
    required this.severity,
    required this.message,
    this.payload = const {},
    DateTime? issuedAt,
  }) : issuedAt = issuedAt ?? DateTime.now();

  @override
  List<Object?> get props => [type, severity, message, payload, issuedAt];
}
