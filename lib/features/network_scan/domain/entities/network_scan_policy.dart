import 'package:equatable/equatable.dart';

/// Defines security and safety guardrails for network scanning.
class NetworkScanPolicy extends Equatable {
  /// Maximum number of hosts allowed in a single scan.
  final int maxSubnetSize;

  /// Whether mandatory legal consent is required before scanning.
  final bool requireConsent;

  const NetworkScanPolicy({
    this.maxSubnetSize = 256, // Default to /24 (256 addresses)
    this.requireConsent = true,
  });

  /// The standard policy used throughout the app.
  static const standard = NetworkScanPolicy();

  /// Validates if a target string (e.g. "192.168.1.0/24") is safe to scan.
  ///
  /// Returns [true] if the target is within the allowed limits or is a single IP.
  bool isTargetSafe(String target) {
    if (!target.contains('/')) {
      return true; // Single IP is always considered safe
    }

    final parts = target.split('/');
    if (parts.length != 2) return false;

    final mask = int.tryParse(parts[1]);
    if (mask == null) return false;

    // Higher mask = smaller subnet. /32 = 1 host, /24 = 256 hosts, /16 = 65536 hosts.
    final hostCount = _calculateHostCount(mask);
    return hostCount <= maxSubnetSize;
  }

  /// Calculates the number of IP addresses in a subnet defined by [mask].
  int _calculateHostCount(int mask) {
    if (mask < 0 || mask > 32) return 0;
    return 1 << (32 - mask);
  }

  @override
  List<Object?> get props => [maxSubnetSize, requireConsent];
}
