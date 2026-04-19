import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/features/ai/domain/services/device_classifier.dart';
import 'package:torcav/features/network_scan/domain/entities/host_scan_result.dart';
import 'package:torcav/features/network_scan/domain/entities/service_fingerprint.dart';

void main() {
  group('DeviceFeatureExtractor', () {
    test('extractFeatures returns correctly dimensioned Float32List', () {
      const host = HostScanResult(
        ip: '192.168.1.1',
        mac: '00:11:22:33:44:55',
        vendor: 'Cisco Systems',
        hostName: 'router.local',
        latency: 10,
        osGuess: '',
        services: [],
        exposureFindings: [],
        exposureScore: 0.0,
        deviceType: '',
      );

      final features = DeviceFeatureExtractor.extractFeatures(host);

      expect(features.length, DeviceFeatureExtractor.featureDim);
    });

    test('extractFeatures maps ports accurately', () {
      const host = HostScanResult(
        ip: '192.168.1.5',
        mac: 'AA:BB:CC:DD:EE:FF',
        vendor: 'Unknown',
        hostName: 'webserver',
        latency: 5,
        osGuess: '',
        exposureFindings: [],
        exposureScore: 0.0,
        deviceType: '',
        services: [
          ServiceFingerprint(port: 80, protocol: 'tcp', serviceName: 'http'),
          ServiceFingerprint(port: 443, protocol: 'tcp', serviceName: 'https'),
          ServiceFingerprint(port: 9999, protocol: 'tcp', serviceName: 'unknown'),
        ],
      );

      final features = DeviceFeatureExtractor.extractFeatures(host);

      expect(features[9], 1.0);
      expect(features[21], 1.0);
      
      final portSum = features.sublist(0, 64).reduce((a, b) => a + b);
      expect(portSum, 2.0);
    });

    test('extractFeatures applies deterministic hashing for vendor', () {
      const host1 = HostScanResult(
        ip: '192.168.1.10',
        mac: '...',
        vendor: 'Apple Inc.',
        hostName: '',
        latency: 0,
        osGuess: '',
        services: [],
        exposureFindings: [],
        exposureScore: 0.0,
        deviceType: '',
      );

      const host2 = HostScanResult(
        ip: '192.168.1.11',
        mac: '...',
        vendor: 'Apple Inc.',
        hostName: '',
        latency: 0,
        osGuess: '',
        services: [],
        exposureFindings: [],
        exposureScore: 0.0,
        deviceType: '',
      );

      final f1 = DeviceFeatureExtractor.extractFeatures(host1);
      final f2 = DeviceFeatureExtractor.extractFeatures(host2);

      for (int i = 64; i < 96; i++) {
        expect(f1[i], f2[i]);
      }
    });
    
    test('decodeOutput correctly resolves logits to best category with confidence', () {
      final logits = List.generate(15, (i) => i == 2 ? 10.0 : 0.0);
      final classification = DeviceFeatureExtractor.decodeOutput(logits);
      
      expect(classification.deviceType, 'Desktop');
      expect(classification.confidence, greaterThan(0.99));
    });
  });
}
