import 'dart:async';
import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart';
import '../entities/security_event.dart';

/// Outcome of a DNS integrity probe.
///
/// [clean] and [unavailable] must stay distinguishable: the probe answering
/// "nothing wrong" and the probe never running look identical from the
/// outside, and collapsing them tells the user their DNS is fine when we
/// simply could not look.
enum DnsCheckStatus {
  /// The probe ran and found no hijacking signature.
  clean,

  /// The probe ran and found something; the accompanying event describes it.
  finding,

  /// The probe could not run — no connectivity, resolver timeout, or a
  /// platform error. We learned nothing about this network's DNS.
  unavailable,
}

/// Resolves [host] to its addresses. Defaults to [InternetAddress.lookup];
/// tests substitute it to drive each [DnsCheckStatus] deterministically.
typedef DnsLookup = Future<List<InternetAddress>> Function(String host);

@lazySingleton
class DnsSecurityUseCase {
  /// Production constructor — the one `injectable` wires. Kept parameterless
  /// so the generator does not try to resolve [DnsLookup] from the container.
  DnsSecurityUseCase() : _lookup = InternetAddress.lookup;

  /// Substitutes the resolver so each [DnsCheckStatus] can be driven
  /// deterministically without a network.
  @visibleForTesting
  const DnsSecurityUseCase.withLookup(this._lookup);

  final DnsLookup _lookup;

  /// A resolver that never answers must not hang the security scan.
  static const _lookupTimeout = Duration(seconds: 5);

  /// Analyzes DNS query results for hijacking signatures.
  ///
  /// 1. NXDOMAIN hijacking — a domain that cannot exist still resolves,
  ///    which is how ISP ad-injection and captive portals behave.
  /// 2. Canary resolution — a domain that must resolve does not.
  ///
  /// Returns the probe [DnsCheckStatus] alongside the [SecurityEvent] when
  /// one was raised. `event` is non-null exactly when the status is
  /// [DnsCheckStatus.finding].
  Future<({DnsCheckStatus status, SecurityEvent? event})> check() async {
    const canaryDomain = 'google.com';
    final nonExistentDomain =
        'this-should-nxdomain-torcav-${DateTime.now().millisecondsSinceEpoch}.com';

    // 1. A domain that cannot exist should not resolve.
    try {
      final nxResult = await _lookup(nonExistentDomain).timeout(_lookupTimeout);
      if (nxResult.isNotEmpty) {
        return (
          status: DnsCheckStatus.finding,
          event: SecurityEvent(
            type: SecurityEventType.dnsHijackingDetected,
            severity: SecurityEventSeverity.medium,
            ssid: '',
            bssid: '',
            timestamp: DateTime.now(),
            evidence:
                'NXDOMAIN hijacking detected. Non-existent domain resolved to ${nxResult.map((a) => a.address).join(", ")}. This is common for ISP ad-injection or captive portals.',
          ),
        );
      }
    } on SocketException {
      // Expected: the domain genuinely does not resolve. Keep probing.
    } on TimeoutException {
      return (status: DnsCheckStatus.unavailable, event: null);
    } catch (_) {
      return (status: DnsCheckStatus.unavailable, event: null);
    }

    // 2. A domain that must resolve should resolve.
    try {
      final canaryIps = await _lookup(canaryDomain).timeout(_lookupTimeout);
      if (canaryIps.isEmpty) {
        return (
          status: DnsCheckStatus.finding,
          event: SecurityEvent(
            type: SecurityEventType.dnsHijackingDetected,
            severity: SecurityEventSeverity.high,
            ssid: '',
            bssid: '',
            timestamp: DateTime.now(),
            evidence:
                'DNS resolution returned no address for $canaryDomain. Possible network obstruction or DNS failure.',
          ),
        );
      }
    } catch (_) {
      // A failing canary lookup is ambiguous: the device may simply be
      // offline. Reporting a hijack here would be a false positive, and
      // reporting "clean" would be a false negative — so report neither.
      return (status: DnsCheckStatus.unavailable, event: null);
    }

    return (status: DnsCheckStatus.clean, event: null);
  }
}
