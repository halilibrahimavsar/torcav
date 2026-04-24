import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:injectable/injectable.dart';

import '../../../../features/settings/domain/services/app_settings_store.dart';
import '../../domain/entities/service_fingerprint.dart';
import '../../domain/entities/port_scan_event.dart';

@LazySingleton()
class PortScanDataSource {
  PortScanDataSource(this._settingsStore);

  final AppSettingsStore _settingsStore;

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
  /// Timeout is read from [AppSettingsStore] so users can tune it in Settings.
  Stream<PortScanEvent> scanPortsReactive(
    String ip, {
    List<int>? ports,
    Duration? timeout,
  }) async* {
    final effectiveTimeout = timeout ??
        Duration(milliseconds: _settingsStore.value.portScanTimeoutMs);
    final controller = StreamController<PortScanEvent>();

    // Prepare the list of (port, serviceName) pairs to scan
    final List<MapEntry<int, String>> targetEntries;
    if (ports != null) {
      targetEntries = ports.map((p) {
        final knownName = _targetPorts[p];
        return MapEntry(p, knownName ?? 'unknown');
      }).toList();
    } else {
      targetEntries = _targetPorts.entries.toList();
    }

    final isStrict = _settingsStore.value.strictSafetyMode;
    final batchSize = isStrict ? 4 : 8;
    final totalCount = targetEntries.length;
    var scannedCount = 0;

    Future<void> runBatch() async {
      for (var i = 0; i < targetEntries.length; i += batchSize) {
        final end = (i + batchSize < targetEntries.length)
            ? i + batchSize
            : targetEntries.length;
        final batch = targetEntries.sublist(i, end);

        final futures = batch.map(
          (entry) => _probeAndGrabBanner(
            ip,
            entry.key,
            entry.value,
            effectiveTimeout,
          ),
        );

        final results = await Future.wait(futures);
        for (var j = 0; j < results.length; j++) {
          scannedCount++;
          final res = results[j];
          final entry = batch[j];
          
          controller.add(PortScanEvent(
            totalCount: totalCount,
            scannedCount: scannedCount,
            currentPort: entry.key,
            discovery: res,
          ));
        }

        // If strict safety mode is on, add a delay between batches to be less aggressive.
        if (isStrict && i + batchSize < targetEntries.length) {
          await Future<void>.delayed(const Duration(seconds: 1));
        }
      }
      controller.close();
    }

    runBatch();
    yield* controller.stream;
  }

  /// Legacy one-shot method, now calls the reactive version and filters for discoveries.
  Future<List<ServiceFingerprint>> scanPorts(String ip) async {
    final events = await scanPortsReactive(ip).toList();
    return events
        .where((e) => e.discovery != null)
        .map((e) => e.discovery!)
        .toList();
  }

  static Future<ServiceFingerprint?> _probeAndGrabBanner(
    String ip,
    int port,
    String serviceName,
    Duration timeout,
  ) async {
    Socket? socket;
    try {
      socket = await Socket.connect(ip, port, timeout: timeout);

      // The rest of the logic remains mostly identical...
      String productInfo = '';
      String versionInfo = '';

      if (port == 21 ||
          port == 22 ||
          port == 23 ||
          port == 80 ||
          port == 8080) {
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
