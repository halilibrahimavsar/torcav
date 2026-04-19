import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/features/ai/data/services/onnx_device_classifier_service.dart';
import 'package:torcav/features/network_scan/domain/entities/host_scan_result.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OnnxDeviceClassifierService', () {
    late OnnxDeviceClassifierService service;

    setUp(() {
      service = OnnxDeviceClassifierService();
    });

    tearDown(() {
      service.dispose();
    });

    HostScanResult createHost(String vendor, String hostName) {
      return HostScanResult(
        ip: '192.168.1.1',
        mac: '00:00:00:00:00:00',
        vendor: vendor,
        hostName: hostName,
        latency: 10,
        osGuess: '',
        services: const [],
        exposureFindings: const [],
        exposureScore: 0.0,
        deviceType: '',
      );
    }

    test('classify falls back to vendor heuristic for Apple mobile devices', () async {
      final host = createHost('Apple Inc.', 'iPhone-12');
      final result = await service.classify(host);

      expect(result, isNotNull);
      expect(result!.deviceType, 'Mobile Device');
      expect(result.confidence, greaterThanOrEqualTo(0.6));
    });

    test('classify falls back to vendor heuristic for known Routers', () async {
      final host = createHost('Cisco Systems', 'gateway');
      final result = await service.classify(host);

      expect(result, isNotNull);
      expect(result!.deviceType, 'Router/Gateway');
      expect(result.confidence, greaterThanOrEqualTo(0.65));
    });

    test('classify falls back to vendor heuristic for known Printers', () async {
      final host = createHost('Hewlett-Packard', 'HP-Print');
      final result = await service.classify(host);

      expect(result, isNotNull);
      expect(result!.deviceType, 'Printer');
    });

    test('classify falls back to vendor heuristic for Smart TVs', () async {
      final host = createHost('Sony Corporation', 'Bravia-TV');
      final result = await service.classify(host);

      expect(result, isNotNull);
      expect(result!.deviceType, 'Smart TV');
    });

    test('classifyBatch returns empty list for empty input', () async {
      final results = await service.classifyBatch([]);
      expect(results, isEmpty);
    });

    test('classifyBatch processes multiple hosts correctly', () async {
      final hosts = [
        createHost('Synology', 'DiskStation'),
        createHost('Nintendo', 'Switch'),
      ];

      final results = await service.classifyBatch(hosts);

      expect(results.length, 2);
      expect(results[0]?.deviceType, 'NAS/Storage');
      expect(results[1]?.deviceType, 'Game Console');
    });
  });
}
