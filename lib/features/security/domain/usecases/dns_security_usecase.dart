import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../data/datasources/network_probe_data_source.dart';
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

/// Resolves a host name. Non-empty means resolved, empty means NXDOMAIN,
/// null means the lookup could not run. Backed by [NetworkProbeDataSource];
/// tests substitute it to drive each [DnsCheckStatus] deterministically.
typedef DnsLookup = Future<List<String>?> Function(String host);

@lazySingleton
class DnsSecurityUseCase {
  /// Production constructor — the one `injectable` wires.
  DnsSecurityUseCase(NetworkProbeDataSource probes) : _lookup = probes.lookup;

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
    final List<String>? nxResult;
    try {
      nxResult = await _lookup(nonExistentDomain).timeout(_lookupTimeout);
    } catch (_) {
      return (status: DnsCheckStatus.unavailable, event: null);
    }
    if (nxResult == null) {
      return (status: DnsCheckStatus.unavailable, event: null);
    }
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
              'NXDOMAIN hijacking detected. Non-existent domain resolved to ${nxResult.join(", ")}. This is common for ISP ad-injection or captive portals.',
        ),
      );
    }

    // 2. A domain that must resolve should resolve.
    final List<String>? canaryIps;
    try {
      canaryIps = await _lookup(canaryDomain).timeout(_lookupTimeout);
    } catch (_) {
      return (status: DnsCheckStatus.unavailable, event: null);
    }
    // A failing canary lookup is ambiguous: the device may simply be offline.
    // Reporting a hijack would be a false positive and reporting "clean" a
    // false negative — so report neither.
    if (canaryIps == null) {
      return (status: DnsCheckStatus.unavailable, event: null);
    }
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

    return (status: DnsCheckStatus.clean, event: null);
  }
}
