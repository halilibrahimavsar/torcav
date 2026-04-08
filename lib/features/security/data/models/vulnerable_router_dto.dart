import '../../domain/entities/vulnerable_router.dart';

/// Data Transfer Object for [VulnerableRouter].
class VulnerableRouterDto {
  const VulnerableRouterDto({
    required this.prefix,
    required this.model,
    required this.vulnerability,
    required this.severity,
    required this.recommendation,
  });

  /// Factory for JSON deserialization.
  factory VulnerableRouterDto.fromJson(Map<String, dynamic> json) {
    return VulnerableRouterDto(
      prefix: json['prefix'] as String,
      model: json['model'] as String,
      vulnerability: json['vulnerability'] as String,
      severity: json['severity'] as String,
      recommendation: json['recommendation'] as String,
    );
  }

  /// The MAC address prefix (OUI).
  final String prefix;

  /// The hardware model.
  final String model;

  /// Vulnerability description.
  final String vulnerability;

  /// Severity level string.
  final String severity;

  /// User recommendation.
  final String recommendation;

  /// Converts this DTO to its domain entity.
  VulnerableRouter toEntity() {
    return VulnerableRouter(
      prefix: prefix,
      model: model,
      vulnerability: vulnerability,
      severity: severity,
      recommendation: recommendation,
    );
  }

  /// Converts this DTO to JSON.
  Map<String, dynamic> toJson() {
    return {
      'prefix': prefix,
      'model': model,
      'vulnerability': vulnerability,
      'severity': severity,
      'recommendation': recommendation,
    };
  }
}
