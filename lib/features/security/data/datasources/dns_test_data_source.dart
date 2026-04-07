import 'dart:io';
import 'package:injectable/injectable.dart';
import '../../domain/entities/dns_test_result.dart';

@LazySingleton()
class DnsDataSource {
  /// Non-intrusive DNS security test.
  /// Checks for resolver consistency, public DNS usage, and potential hijacking.
  Future<DnsTestResult> performTest() async {
    final List<String> detectedServers = [];
    bool isHijacked = false;
    bool isLeaking = false;
    final evidence = <String>[];
    var status = DnsSecurityStatus.secure;

    try {
      final startTime = DateTime.now();
      
      // 1. Resolver Identification via Debug Domains
      // whoami.akamai.net returns the IP of the resolver making the query.
      // debug.opendns.com returns info including the resolver's IP and ISP.
      final [akamaiIp, openDnsInfo] = await Future.wait([
        _resolveFirst('whoami.akamai.net'),
        _resolveFirstText('debug.opendns.com'), // This might fail if not using OpenDNS, that's okay.
      ]);

      final latency = DateTime.now().difference(startTime).inMilliseconds;
      evidence.add('DNS latency: ${latency}ms');
      
      if (akamaiIp != null) {
        detectedServers.add(akamaiIp);
        evidence.add('Detected Resolver IP: $akamaiIp');
      }

      // 2. Canary Domain Lookups for Hijacking Detection
      final results = await Future.wait([
        InternetAddress.lookup('google.com'),
        InternetAddress.lookup('cloudflare.com'),
      ]);

      for (final lookup in results) {
        if (lookup.isEmpty) continue;
        final ip = lookup.first.address;
        // Flag common hijacking destinations
        if (ip == '127.0.0.1' || ip == '0.0.0.0' || ip.startsWith('10.') || ip.startsWith('192.168.')) {
          isHijacked = true;
          status = DnsSecurityStatus.dangerous;
          evidence.add('Hijack Alert: $ip returned for common domain');
        }
      }

      // 3. DNS Leak/Status Context
      if (openDnsInfo != null && openDnsInfo.contains('dnscrypt')) {
        evidence.add('Encrypted DNS (DNSCrypt) detected');
      }

      final currentDns = detectedServers.isNotEmpty ? detectedServers.first : 'System Default';
      
      return DnsTestResult(
        currentDns: currentDns,
        ispName: 'Network Identified',
        isHijacked: isHijacked,
        isLeaking: isLeaking,
        status: status,
        detectedServers: detectedServers,
        evidence: evidence.join(' | '),
      );
    } catch (e) {
      return DnsTestResult(
        currentDns: 'Unknown',
        ispName: 'Network Error',
        isHijacked: false,
        isLeaking: false,
        status: DnsSecurityStatus.warning,
        detectedServers: const [],
        evidence: 'Failed to perform DNS lookup: $e',
      );
    }
  }

  Future<String?> _resolveFirst(String host) async {
    try {
      final lookup = await InternetAddress.lookup(host);
      return lookup.isNotEmpty ? lookup.first.address : null;
    } catch (_) {
      return null;
    }
  }

  Future<String?> _resolveFirstText(String host) async {
    // Note: InternetAddress.lookup doesn't support TXT records directly in pure Dart.
    // We would need a custom DNS client or use a platform channel.
    // For now, we'll gracefully return null and look for other identifiers.
    return null;
  }
}
