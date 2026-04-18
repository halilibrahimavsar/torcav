import 'package:equatable/equatable.dart';

/// Represents a known hardware vulnerability match for a router.
class VulnerableRouter extends Equatable {
  const VulnerableRouter({
    required this.prefix,
    required this.model,
    required this.vulnerability,
    required this.severity,
    required this.recommendation,
  });

  /// The MAC address prefix (OUI) that matches this vulnerability.
  final String prefix;

  /// The model or manufacturer name.
  final String model;

  /// Description of the vulnerability.
  final String vulnerability;

  /// Severity level (e.g., critical, high, medium, low).
  final String severity;

  /// Recommended action for the user.
  final String recommendation;

  /// Creates a copy of this entity with updated fields.
  VulnerableRouter copyWith({
    String? prefix,
    String? model,
    String? vulnerability,
    String? severity,
    String? recommendation,
  }) {
    return VulnerableRouter(
      prefix: prefix ?? this.prefix,
      model: model ?? this.model,
      vulnerability: vulnerability ?? this.vulnerability,
      severity: severity ?? this.severity,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  @override
  List<Object?> get props => [
    prefix,
    model,
    vulnerability,
    severity,
    recommendation,
  ];
}
