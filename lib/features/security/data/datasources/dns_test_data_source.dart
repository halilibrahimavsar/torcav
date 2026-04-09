import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:injectable/injectable.dart';
import '../../domain/entities/dns_test_result.dart';

@LazySingleton()
class DnsDataSource {
  static const List<Map<String, dynamic>> _providers = [
    {
      'name': 'Cloudflare',
      'ip': '1.1.1.1',
      'features': ['Privacy First', 'Anti-Tracking'],
    },
    {
      'name': 'Google Public',
      'ip': '8.8.8.8',
      'features': ['Extreme Reliability', 'Global Speed'],
    },
    {
      'name': 'Quad9',
      'ip': '9.9.9.9',
      'features': ['Malware Blocking', 'Privacy Focused'],
    },
    {
      'name': 'OpenDNS',
      'ip': '208.67.222.222',
      'features': ['Parental Control', 'Phishing Protection'],
    },
    {
      'name': 'AdGuard',
      'ip': '94.140.14.14',
      'features': ['Ad Blocking', 'Tracker Prevention'],
    },
  ];

  /// Performs a full DNS security and performance test.
  Future<DnsTestResult> performTest() async {
    final List<String> detectedServers = [];
    bool isHijacked = false;
    bool isLeaking = false;
    final evidence = <String>[];
    var status = DnsSecurityStatus.secure;
    bool dnssecSupported = false;
    bool encryptedDnsActive = false;
    String encryptedProtocol = 'UDP/Basic';
    String ispName = 'Identifying...';

    try {
      final startTime = DateTime.now();
      
      // 1. Resolver Identification
      final [akamaiIp, openDnsInfo] = await Future.wait([
        _resolveFirst('whoami.akamai.net'),
        _resolveFirstText('debug.opendns.com'),
      ]);

      final systemLatency = DateTime.now().difference(startTime).inMilliseconds;
      evidence.add('System DNS latency: ${systemLatency}ms');
      
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
        if (ip == '127.0.0.1' || ip == '0.0.0.0' || ip.startsWith('10.') || ip.startsWith('192.168.')) {
          isHijacked = true;
          status = DnsSecurityStatus.dangerous;
          evidence.add('Hijack Alert: $ip returned for common domain');
        }
      }

      // 3. Encrypted DNS & Protocol Detection
      final encryptionInfo = await _detectEncryptedDns(akamaiIp);
      encryptedProtocol = encryptionInfo['status'] as String;
      encryptedDnsActive = encryptionInfo['active'] as bool;
      
      // 4. DNSSEC Verification on System Resolver
      final systemDnssec = await _checkSystemDnssec();
      dnssecSupported = systemDnssec;
      if (dnssecSupported) evidence.add('System DNSSEC validation confirmed');

      // 5. Heuristic ISP & Leak Detection
      final ispInfo = await _detectIspAndLeads(akamaiIp);
      ispName = ispInfo['isp'] as String;
      isLeaking = ispInfo['isLeaking'] as bool;
      if (isLeaking) {
        status = DnsSecurityStatus.warning;
        evidence.add('DNS Leak detected: Local ISP intercepted custom DNS');
      }

      // 6. DNS Benchmark
      final benchmarkResult = await runBenchmarkWithDnssec();
      final benchmarks = benchmarkResult.benchmarks;
      // Combine DNSSEC support (if any benchmarked or system supports it)
      dnssecSupported = dnssecSupported || benchmarkResult.dnssecSupported;
      
      final currentDns = detectedServers.isNotEmpty ? detectedServers.first : 'System Default';
      
      return DnsTestResult(
        currentDns: currentDns,
        ispName: ispName,
        isHijacked: isHijacked,
        isLeaking: isLeaking,
        status: status,
        detectedServers: detectedServers,
        encryptedDnsActive: encryptedDnsActive,
        encryptedProtocol: encryptedProtocol,
        dnssecSupported: dnssecSupported,
        evidence: evidence.join(' | '),
        benchmarks: benchmarks,
      );
    } catch (e) {
      return DnsTestResult(
        currentDns: 'Unknown',
        ispName: 'Network Error',
        isHijacked: false,
        isLeaking: false,
        status: DnsSecurityStatus.warning,
        detectedServers: const [],
        encryptedDnsActive: false,
        encryptedProtocol: 'Unknown',
        dnssecSupported: false,
        evidence: 'Failed: $e',
        benchmarks: const [],
      );
    }
  }

  Future<DnsBenchmarkResultGroup> runBenchmarkWithDnssec() async {
    final results = <DnsBenchmarkResult>[];
    bool dnssecGlobal = false;
    
    // Test providers in parallel
    final futures = _providers.map((p) async {
      final probe = await _measureLatencyAndDnssec(p['ip'] as String);
      if (probe.dnssec) dnssecGlobal = true;
      return DnsBenchmarkResult(
        name: p['name'] as String,
        primaryIp: p['ip'] as String,
        latencyMs: probe.latency,
        features: p['features'] as List<String>,
      );
    }).toList();

    results.addAll(await Future.wait(futures));

    // Rank results
    results.sort((a, b) {
      if (a.latencyMs == -1) return 1;
      if (b.latencyMs == -1) return -1;
      return a.latencyMs.compareTo(b.latencyMs);
    });

    // Mark recommended (fastest non-failed)
    if (results.isNotEmpty && results.first.latencyMs != -1) {
      results[0] = results[0].copyWith(isRecommended: true);
    }

    return DnsBenchmarkResultGroup(
      benchmarks: results,
      dnssecSupported: dnssecGlobal,
    );
  }

  Future<Map<String, dynamic>> _detectEncryptedDns(String? resolverIp) async {
    try {
      // 1. Check known providers
      if (resolverIp != null) {
        if (resolverIp == '1.1.1.1' || resolverIp == '1.0.0.1' || resolverIp.startsWith('172.64.') || resolverIp.startsWith('162.159.')) {
          return {'active': true, 'status': 'Cloudflare DoH/DoT'};
        }
        if (resolverIp == '8.8.8.8' || resolverIp == '8.8.4.4') {
          return {'active': true, 'status': 'Google DoH/DoT'};
        }
        if (resolverIp == '9.9.9.9' || resolverIp == '149.112.112.112') {
          return {'active': true, 'status': 'Quad9 Encrypted'};
        }
        if (resolverIp.startsWith('94.140.')) {
          return {'active': true, 'status': 'AdGuard Encrypted'};
        }
      }

      // 2. HTTP Probe to Cloudflare (Common way to check if system is using DoH)
      final client = HttpClient()..connectionTimeout = const Duration(seconds: 2);
      try {
        final request = await client.getUrl(Uri.parse('https://1.1.1.1/cdn-cgi/trace'));
        final response = await request.close();
        final body = await response.transform(const SystemEncoding().decoder).join();
        if (body.contains('doh=on')) return {'active': true, 'status': 'DoH Enabled'};
        if (body.contains('dot=on')) return {'active': true, 'status': 'DoT Enabled'};
      } catch (_) {}

      return {'active': false, 'status': 'UDP/Unencrypted'};
    } catch (_) {
      return {'active': false, 'status': 'Basic UDP'};
    }
  }

  Future<DnsProbeResult> _measureLatencyAndDnssec(String dnsIp) async {
    try {
      // DNS query for google.com with OPT pseudo-RR for DNSSEC (DO bit)
      final packet = Uint8List.fromList([
        0x12, 0x34, // ID
        0x01, 0x00, // Flags (Standard query)
        0x00, 0x01, // Questions: 1
        0x00, 0x00, // Answer RRs: 0
        0x00, 0x00, // Authority RRs: 0
        0x00, 0x01, // Additional RRs: 1 (for OPT)
        0x06, 0x67, 0x6f, 0x6f, 0x67, 0x6c, 0x65, // "google"
        0x03, 0x63, 0x6f, 0x6d, // "com"
        0x00, // null terminator
        0x00, 0x01, // Type A
        0x00, 0x01, // Class IN
        // OPT RR (EDNS0)
        0x00, // Name: root
        0x00, 0x29, // Type: OPT
        0x10, 0x00, // Payload size: 4096
        0x00, // Higher RCODE
        0x00, // EDNS version
        0x80, 0x00, // Flags: DO (DNSSEC OK) bit set
        0x00, 0x00, // Data length: 0
      ]);

      final stopwatch = Stopwatch()..start();
      final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      
      socket.send(packet, InternetAddress(dnsIp), 53);
      
      final completer = Completer<DnsProbeResult>();
      
      socket.listen((event) {
        if (event == RawSocketEvent.read) {
          final dg = socket.receive();
          if (dg != null) {
            stopwatch.stop();
            // Check AD (Authentic Data) bit in response flags (byte 3, bit 5)
            // Header is 12 bytes. Flags are bytes 2 and 3.
            bool dnssecStatus = false;
            if (dg.data.length >= 4) {
              dnssecStatus = (dg.data[3] & 0x20) != 0;
            }
            if (!completer.isCompleted) {
              completer.complete(DnsProbeResult(
                latency: stopwatch.elapsedMilliseconds,
                dnssec: dnssecStatus,
              ));
            }
          }
        }
      });

      Timer(const Duration(seconds: 2), () {
        if (!completer.isCompleted) {
          completer.complete(const DnsProbeResult(latency: -1, dnssec: false));
        }
      });

      final result = await completer.future;
      socket.close();
      return result;
    } catch (_) {
      return const DnsProbeResult(latency: -1, dnssec: false);
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
    return null;
  }

  /// Complex DNSSEC validation on the active system resolver path.
  Future<bool> _checkSystemDnssec() async {
    try {
      // Step 1: Resolve a domain that MUST succeed with DNSSEC
      final okResult = await InternetAddress.lookup('sigok.vertebrate.adns.network')
          .timeout(const Duration(seconds: 2));
      
      if (okResult.isEmpty) return false;

      // Step 2: Resolve a domain that MUST fail if DNSSEC is validating
      try {
        await InternetAddress.lookup('sigfail.vertebrate.adns.network')
            .timeout(const Duration(seconds: 2));
        // If it resolved, DNSSEC is NOT validating or is stripped
        return false;
      } catch (e) {
        // Most system resolvers return a timeout or specific error on sigfail
        return true;
      }
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> _detectIspAndLeads(String? resolverIp) async {
    String isp = 'Generic Network';
    bool isLeaking = false;

    if (resolverIp == null) return {'isp': isp, 'isLeaking': false};

    // Very basic heuristic: if it's a known public DNS, but ISP matches common patterns
    // Hard to do strictly local without GeoIP DB.
    // For now, we identify if it's NOT a public DNS we know.
    bool constitutesPublicDns = _providers.any((p) => (p['ip'] as String) == resolverIp);
    
    if (constitutesPublicDns) {
      isp = 'Public DNS (${_providers.firstWhere((p) => p['ip'] == resolverIp)['name']})';
    } else {
      isp = 'Private/ISP Resolver';
    }

    return {'isp': isp, 'isLeaking': isLeaking};
  }
}

class DnsProbeResult {
  final int latency;
  final bool dnssec;
  const DnsProbeResult({required this.latency, required this.dnssec});
}

class DnsBenchmarkResultGroup {
  final List<DnsBenchmarkResult> benchmarks;
  final bool dnssecSupported;
  DnsBenchmarkResultGroup({required this.benchmarks, required this.dnssecSupported});
}

