import 'package:equatable/equatable.dart';

import 'host_scan_result.dart';

class LanScanSession extends Equatable {
  const LanScanSession({
    required this.sessionKey,
    required this.createdAt,
    required this.target,
    required this.profile,
    required this.hosts,
  });

  final String sessionKey;
  final DateTime createdAt;
  final String target;
  final String profile;
  final List<HostScanResult> hosts;

  @override
  List<Object?> get props => [sessionKey, createdAt, target, profile, hosts];
}
