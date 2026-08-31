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

  /// Whether [target] — a single IP or a CIDR range — is safe to scan.
  ///
  /// Two conditions, both required:
  ///
  ///  1. **It is a private address.** CLAUDE.md's passivity exception covers
  ///     diagnostics the user starts *on their own network*; probing a public
  ///     host is outside it. Today the UI only ever passes hosts discovered on
  ///     the local subnet, so this is defence in depth — but the method was
  ///     named `isTargetSafe` while checking only size, which is a guarantee
  ///     it did not actually give.
  ///  2. **The range is small enough.** A /24 at most, so a mistyped mask
  ///     cannot turn into a 65k-host sweep.
  bool isTargetSafe(String target) {
    final slash = target.indexOf('/');
    final host = slash == -1 ? target : target.substring(0, slash);

    if (!isPrivateAddress(host)) return false;
    if (slash == -1) return true;

    final mask = int.tryParse(target.substring(slash + 1));
    if (mask == null) return false;

    // Higher mask = smaller subnet. /32 = 1 host, /24 = 256, /16 = 65536.
    final hosts = _calculateHostCount(mask);
    return hosts != null && hosts <= maxSubnetSize;
  }

  /// RFC1918 private space plus link-local, which is what a home or office
  /// LAN uses. Anything else is somebody else's network.
  static bool isPrivateAddress(String ip) {
    final parts = ip.split('.');
    if (parts.length != 4) return false;

    final octets = <int>[];
    for (final part in parts) {
      final value = int.tryParse(part);
      if (value == null || value < 0 || value > 255) return false;
      octets.add(value);
    }

    // 10.0.0.0/8
    if (octets[0] == 10) return true;
    // 172.16.0.0/12
    if (octets[0] == 172 && octets[1] >= 16 && octets[1] <= 31) return true;
    // 192.168.0.0/16
    if (octets[0] == 192 && octets[1] == 168) return true;
    // 169.254.0.0/16 — link-local, used when DHCP fails
    if (octets[0] == 169 && octets[1] == 254) return true;
    return false;
  }

  /// Number of addresses in a subnet with [mask] bits, or null when [mask]
  /// is not a valid prefix length.
  ///
  /// Null rather than 0: a malformed mask used to yield 0, which compared
  /// under the limit and read as "safe". Unparseable input is refused, not
  /// waved through — the same reasoning as the private-address check.
  int? _calculateHostCount(int mask) {
    if (mask < 0 || mask > 32) return null;
    return 1 << (32 - mask);
  }

  @override
  List<Object?> get props => [maxSubnetSize, requireConsent];
}
