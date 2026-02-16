import 'package:equatable/equatable.dart';
import 'vulnerability.dart';

class SecurityReport extends Equatable {
  final int score;
  final List<Vulnerability> vulnerabilities;
  final String overallStatus;

  const SecurityReport({
    required this.score,
    required this.vulnerabilities,
    required this.overallStatus,
  });

  @override
  List<Object?> get props => [score, vulnerabilities, overallStatus];
}
