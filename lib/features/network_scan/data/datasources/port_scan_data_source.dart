import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:injectable/injectable.dart';

import '../../domain/entities/service_fingerprint.dart';

@LazySingleton()
class PortScanDataSource {
  static const int _timeoutMs = 500;
  static const int _bannerTimeoutMs = 500;

  /// Expanded list of commonly exploited / vulnerable ports.
  static const Map<int, String> _targetPorts = {
    21: 'ftp',
    22: 'ssh',
    23: 'telnet',
    25: 'smtp',
    53: 'dns',
    80: 'http',
    111: 'rpcbind',
    139: 'smb/tcp-139',
    443: 'https',
    445: 'microsoft-ds', // SMBv1/v2 target
    514: 'syslog',
    548: 'afp',
    631: 'ipp',
    1433: 'ms-sql',
    1521: 'oracle',
    3306: 'mysql',
    3389: 'rdp',
    5000: 'upnp',
    5432: 'postgresql',
    5900: 'vnc',
    6379: 'redis',
    8080: 'http-proxy',
    8443: 'https-alt',
    9100: 'jetdirect', // Printers
    27017: 'mongodb',
  };

  /// Scans the given IP for the target ports, yielding results as they arrive.
  /// 
  /// [timeout] allows adaptive scaling based on network latency.
  Stream<ServiceFingerprint> scanPortsReactive(
    String ip, {
    Duration timeout = const Duration(milliseconds: _timeoutMs),
  }) async* {
    final controller = StreamController<ServiceFingerprint>();
    
    // We use a small batching approach to avoid overwhelming the socket limit
    // while maintaining high performance.
    final ports = _targetPorts.entries.toList();
    const batchSize = 8;

    Future<void> runBatch() async {
      for (var i = 0; i < ports.length; i += batchSize) {
        final end = (i + batchSize < ports.length) ? i + batchSize : ports.length;
        final batch = ports.sublist(i, end);
        
        final futures = batch.map((entry) => _probeAndGrabBanner(
          ip, 
          entry.key, 
          entry.value, 
          timeout,
        ));

        final results = await Future.wait(futures);
        for (final res in results) {
          if (res != null) {
            controller.add(res);
          }
        }
      }
      controller.close();
    }

    runBatch();
    yield* controller.stream;
  }

  /// Legacy one-shot method, now calls the reactive version.
  Future<List<ServiceFingerprint>> scanPorts(String ip) async {
    return scanPortsReactive(ip).toList();
  }

  static Future<ServiceFingerprint?> _probeAndGrabBanner(
    String ip,
    int port,
    String serviceName,
    Duration timeout,
  ) async {
    Socket? socket;
    try {
      socket = await Socket.connect(
        ip,
        port,
        timeout: timeout,
      );
      
      // The rest of the logic remains mostly identical...
      String productInfo = '';
      String versionInfo = '';

      if (port == 21 || port == 22 || port == 23 || port == 80 || port == 8080) {
        if (port == 80 || port == 8080) {
          socket.write("HEAD / HTTP/1.0\r\n\r\n");
        }
        
        try {
          final event = await socket.first.timeout(
            const Duration(milliseconds: _bannerTimeoutMs),
          );
          
          final bannerString = utf8.decode(event, allowMalformed: true).trim();
          
          if (bannerString.isNotEmpty) {
            final lines = bannerString.split('\n');
            if (port == 80 || port == 8080) {
              for (final line in lines) {
                if (line.toUpperCase().startsWith('SERVER:')) {
                  productInfo = line.substring(7).trim();
                  break;
                }
              }
            } else {
              productInfo = lines.first.trim();
              if (productInfo.length > 50) {
                productInfo = productInfo.substring(0, 50);
              }
            }
          }
        } catch (_) {}
      }

      return ServiceFingerprint(
        port: port,
        protocol: 'tcp',
        serviceName: serviceName,
        product: productInfo,
        version: versionInfo,
      );
    } catch (_) {
      return null;
    } finally {
      socket?.destroy();
    }
  }
}
