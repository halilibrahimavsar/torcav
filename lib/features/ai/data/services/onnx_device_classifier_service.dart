import 'dart:io';
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

  /// Classify a single host. Returns `null` if the model is unavailable.
  Future<DeviceClassification?> classify(HostScanResult host) async {
    final session = await _ensureSession();
    if (session == null) return null;

    final features = DeviceFeatureExtractor.extractFeatures(host);

    final inputOrt = OrtValueTensor.createTensorWithDataList(
      Float32List.fromList(features),
      [1, DeviceFeatureExtractor.featureDim],
    );

    final runOptions = OrtRunOptions();
    try {
      final outputs = session.run(runOptions, {'features': inputOrt});
      inputOrt.release();
      runOptions.release();

      final outputTensor = outputs.first;
      if (outputTensor == null) return null;

      final raw = outputTensor.value;
      outputTensor.release();

      // Output shape is [1, 15] — nested list
      final List<double> logits;
      if (raw is List<List<double>>) {
        logits = raw.first;
      } else if (raw is List) {
        logits = raw.cast<double>();
      } else {
        return null;
      }

      return DeviceFeatureExtractor.decodeOutput(logits);
    } catch (_) {
      inputOrt.release();
      runOptions.release();
      return null;
    }
  }

  /// Classify a batch of hosts.
  Future<List<DeviceClassification?>> classifyBatch(
    List<HostScanResult> hosts,
  ) async {
    final results = <DeviceClassification?>[];
    for (final host in hosts) {
      results.add(await classify(host));
    }
    return results;
  }

  Future<OrtSession?> _ensureSession() async {
    if (_session != null) return _session;
    if (_initFailed) return null;

    try {
      OrtEnv.instance.init();

      // Copy asset to a temp file since OrtSession needs a file path.
      final modelBytes = await rootBundle.load('assets/models/device_classifier.onnx');
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
