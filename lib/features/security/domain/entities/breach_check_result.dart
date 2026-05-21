import 'package:equatable/equatable.dart';

/// Outcome of a password breach check against the Have I Been Pwned
/// Pwned Passwords range API.
///
/// The check is performed with the k-anonymity model: only the first 5
/// characters of the password's SHA-1 hash ever leave the device, so the
/// password itself is never transmitted.
class BreachCheckResult extends Equatable {
  /// True if the password was found in a known breach corpus.
  final bool isCompromised;

  /// Number of times the password appears across breach datasets.
  /// Zero when [isCompromised] is false.
  final int exposureCount;

  /// When this check was performed.
  final DateTime checkedAt;

  const BreachCheckResult({
    required this.isCompromised,
    required this.exposureCount,
    required this.checkedAt,
  });

  @override
  List<Object?> get props => [isCompromised, exposureCount, checkedAt];
}
