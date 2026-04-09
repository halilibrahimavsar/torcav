import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

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

  /// Scans the given IP for the target ports, grabbing banners when possible.
  Future<List<ServiceFingerprint>> scanPorts(String ip) async {
    // Run in isolate to avoid freezing UI thread with heavy socket calls.
    return Isolate.run(() async {
      final futures = <Future<ServiceFingerprint?>>[];
      
      for (final entry in _targetPorts.entries) {
        futures.add(_probeAndGrabBanner(ip, entry.key, entry.value));
      }

      final results = await Future.wait(futures);
      return results.whereType<ServiceFingerprint>().toList();
    });
  }

  static Future<ServiceFingerprint?> _probeAndGrabBanner(
    String ip,
    int port,
    String serviceName,
  ) async {
    Socket? socket;
    try {
      socket = await Socket.connect(
        ip,
        port,
        timeout: const Duration(milliseconds: _timeoutMs),
      );

      String productInfo = '';
      String versionInfo = '';

      // Try grabbing a banner for text-based protocols
      if (port == 21 || port == 22 || port == 23 || port == 80 || port == 8080) {
        if (port == 80 || port == 8080) {
          // Send a basic HTTP GET to provoke a Server header
          socket.write("HEAD / HTTP/1.0\r\n\r\n");
        }
        
        try {
          // Wait briefly for a response
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
              // SSH/FTP/Telnet often just print standard banners on the first line
              productInfo = lines.first.trim();
              if (productInfo.length > 50) {
                productInfo = productInfo.substring(0, 50); // clamp length
              }
            }
          }
        } catch (e) {
          // Timeout grabbing banner is fine, we still know the port is open.
          // Ignoring the banner grab failure to return the open port info.
        }
      }

      return ServiceFingerprint(
        port: port,
        protocol: 'tcp',
        serviceName: serviceName,
        product: productInfo,
        version: versionInfo,
      );
    } catch (e) {
      // Connection refused or timeout -> port closed
      return null;
    } finally {
      socket?.destroy();
    }
  }
}
