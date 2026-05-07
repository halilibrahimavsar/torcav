import 'package:equatable/equatable.dart';

/// Three buckets the user sees on a LAN device card. Maps directly to the
/// green / amber / red badge in the UI.
enum HostTrustLevel {
  /// No issues observed. Default device, expected services, no critical
  /// exposure findings.
  safe,

  /// One or more medium-severity findings, an unexpected device or a
  /// service that *can* be misconfigured. Worth a glance.
  caution,

  /// At least one high or critical finding — open service that should
  /// not be exposed, gateway in an unsafe configuration, etc.
  risky,
}

/// One-line reason that contributed to the assessment (open port,
/// gateway exposure, suspicious vendor, etc.). Short, plain language.
class HostTrustReason extends Equatable {
  final String summary;
  final String? remediation;

  const HostTrustReason({required this.summary, this.remediation});

  @override
  List<Object?> get props => [summary, remediation];
}

class HostTrustAssessment extends Equatable {
  final HostTrustLevel level;
  final List<HostTrustReason> reasons;

  /// Highest-priority single sentence shown next to the badge.
  final String headline;

  const HostTrustAssessment({
    required this.level,
    required this.headline,
    required this.reasons,
  });

  @override
  List<Object?> get props => [level, headline, reasons];
}
