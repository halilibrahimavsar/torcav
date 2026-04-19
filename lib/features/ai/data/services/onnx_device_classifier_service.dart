import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:onnxruntime/onnxruntime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../../network_scan/domain/entities/host_scan_result.dart';
import '../../domain/services/device_classifier.dart';

/// Runs the device classifier ONNX model on-device.
///
/// Loaded once as a lazy singleton and reused for all classifications.
@lazySingleton
class OnnxDeviceClassifierService {
  OrtSession? _session;
  bool _initFailed = false;

  /// Classify a single host.
  ///
  /// Returns a vendor heuristic result when the model is unavailable or
  /// confidence falls below [_confidenceThreshold].
  Future<DeviceClassification?> classify(HostScanResult host) async {
    final features = DeviceFeatureExtractor.extractFeatures(host);
    return _classifyFeatures(features, host);
  }

  /// Classify a batch of hosts in a background isolate.
  ///
  /// Each host is classified with the ONNX model. If the model is unavailable
  /// or confidence is below [_confidenceThreshold], falls back to a
  /// vendor-name heuristic so callers always get a best-effort label.
  Future<List<DeviceClassification?>> classifyBatch(
    List<HostScanResult> hosts,
  ) async {
    if (hosts.isEmpty) return [];

    // Feature extraction is pure Dart — safe to run in an isolate.
    // ONNX inference must stay on the main isolate (native handle), so we
    // extract features in parallel and run inference sequentially.
    final features = await Isolate.run(() {
      return hosts.map(DeviceFeatureExtractor.extractFeatures).toList();
    });

    final results = <DeviceClassification?>[];
    for (var i = 0; i < hosts.length; i++) {
      final result = await _classifyFeatures(features[i], hosts[i]);
      results.add(result);
    }
    return results;
  }

  /// Confidence below this threshold triggers the vendor heuristic fallback.
  static const double _confidenceThreshold = 0.50;

  /// Classifies a pre-extracted feature vector, falling back to a vendor
  /// heuristic when the model is unavailable or under-confident.
  Future<DeviceClassification?> _classifyFeatures(
    Float32List features,
    HostScanResult host,
  ) async {
    final session = await _ensureSession();
    if (session != null) {
      final inputOrt = OrtValueTensor.createTensorWithDataList(
        features,
        [1, DeviceFeatureExtractor.featureDim],
      );
      final runOptions = OrtRunOptions();
      try {
        final outputs = session.run(runOptions, {'features': inputOrt});
        inputOrt.release();
        runOptions.release();

        final outputTensor = outputs.first;
        if (outputTensor != null) {
          final raw = outputTensor.value;
          outputTensor.release();

          final List<double> logits;
          if (raw is List<List<double>>) {
            logits = raw.first;
          } else if (raw is List) {
            logits = raw.cast<double>();
          } else {
            return _vendorHeuristic(host);
          }

          final result = DeviceFeatureExtractor.decodeOutput(logits);
          if (result.confidence >= _confidenceThreshold) return result;
          // Low-confidence: blend model label with vendor heuristic
          return _vendorHeuristic(host) ?? result;
        }
      } catch (_) {
        inputOrt.release();
        runOptions.release();
      }
    }
    return _vendorHeuristic(host);
  }

  /// OUI/vendor-name heuristic fallback returning a best-effort device type.
  static DeviceClassification? _vendorHeuristic(HostScanResult host) {
    final v = host.vendor.toLowerCase();
    final h = host.hostName.toLowerCase();

    if (_matches(v, h, ['apple', 'iphone', 'ipad'])) {
      return const DeviceClassification(
        deviceType: 'Mobile Device',
        confidence: 0.6,
      );
    }
    if (_matches(v, h, ['samsung', 'huawei', 'xiaomi', 'oppo', 'oneplus'])) {
      return const DeviceClassification(
        deviceType: 'Mobile Device',
        confidence: 0.6,
      );
    }
    if (_matches(v, h, ['cisco', 'netgear', 'tp-link', 'tplink', 'asus', 'dlink', 'linksys', 'ubiquiti', 'mikrotik'])) {
      return const DeviceClassification(
        deviceType: 'Router/Gateway',
        confidence: 0.65,
      );
    }
    if (_matches(v, h, ['hp ', 'hewlett', 'canon', 'epson', 'brother', 'lexmark', 'xerox', 'ricoh'])) {
      return const DeviceClassification(
        deviceType: 'Printer',
        confidence: 0.65,
      );
    }
    if (_matches(v, h, ['synology', 'qnap', 'drobo', 'western digital', 'wd ', 'seagate', 'nas'])) {
      return const DeviceClassification(
        deviceType: 'NAS/Storage',
        confidence: 0.65,
      );
    }
    if (_matches(v, h, ['sony', 'lg ', 'samsung', 'philips', 'panasonic', 'tv', 'bravia', 'vizio'])) {
      if (h.contains('tv') || v.contains('tv') || h.contains('bravia') || h.contains('vizio')) {
        return const DeviceClassification(
          deviceType: 'Smart TV',
          confidence: 0.6,
        );
      }
    }
    if (_matches(v, h, ['hikvision', 'dahua', 'axis', 'camera', 'cam-', 'ipcam'])) {
      return const DeviceClassification(
        deviceType: 'IP Camera',
        confidence: 0.65,
      );
    }
    if (_matches(v, h, ['amazon', 'echo', 'google', 'sonos', 'speaker'])) {
      return const DeviceClassification(
        deviceType: 'Smart Speaker',
        confidence: 0.6,
      );
    }
    if (_matches(v, h, ['raspberry', 'arduino', 'esp32', 'esp8266', 'sensor', 'iot'])) {
      return const DeviceClassification(
        deviceType: 'IoT Sensor',
        confidence: 0.55,
      );
    }
    if (_matches(v, h, ['dell', 'lenovo', 'acer', 'asus', 'msi', 'laptop', 'desktop', 'pc'])) {
      return const DeviceClassification(
        deviceType: 'Desktop',
        confidence: 0.55,
      );
    }
    if (_matches(v, h, ['nintendo', 'playstation', 'xbox', 'valve', 'steam'])) {
      return const DeviceClassification(
        deviceType: 'Game Console',
        confidence: 0.65,
      );
    }
    return null;
  }

  static bool _matches(String vendor, String hostname, List<String> keywords) {
    return keywords.any((k) => vendor.contains(k) || hostname.contains(k));
  }

  Future<OrtSession?> _ensureSession() async {
    if (_session != null) return _session;
    if (_initFailed) return null;

    try {
      OrtEnv.instance.init();

      // Copy asset to a temp file since OrtSession needs a file path.
      final modelBytes = await rootBundle.load(
        'assets/models/device_classifier.onnx',
      );
      final tempDir = await getTemporaryDirectory();
      final modelFile = File(p.join(tempDir.path, 'device_classifier.onnx'));
      await modelFile.writeAsBytes(
        modelBytes.buffer.asUint8List(),
        flush: true,
      );

      final sessionOptions = OrtSessionOptions();
      _session = OrtSession.fromFile(modelFile, sessionOptions);
      sessionOptions.release();
      return _session;
    } catch (_) {
      _initFailed = true;
      return null;
    }
  }

  @disposeMethod
  void dispose() {
    _session?.release();
    _session = null;
  }
}
