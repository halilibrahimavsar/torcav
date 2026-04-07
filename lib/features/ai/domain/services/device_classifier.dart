import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import '../../../network_scan/domain/entities/host_scan_result.dart';

/// Result of a device classification inference.
class DeviceClassification {
  final String deviceType;
  final double confidence;

  const DeviceClassification({
    required this.deviceType,
    required this.confidence,
  });
}

/// Extracts features from a [HostScanResult] for the device classifier model.
///
/// The feature vector layout must match the Python training pipeline exactly:
///   [0..63]    port bitmap (64 tracked ports)
///   [64..95]   vendor hash (32 dims, multi-hot)
///   [96..127]  hostname trigram hash (32 dims, multi-hot)
///   [128..159] service name BoW hash (32 dims, multi-hot)
abstract final class DeviceFeatureExtractor {
  static const int featureDim = 160;

  static const int _numPorts = 64;
  static const int _vendorHashDim = 32;
  static const int _hostnameHashDim = 32;
  static const int _serviceBowDim = 32;

  static const List<int> _trackedPorts = [
    20, 21, 22, 23, 25, 53, 67, 68, 69, 80, 110, 119, 123, 135, 137, 139,
    143, 161, 162, 179, 389, 443, 445, 465, 500, 515, 548, 554, 587, 631,
    636, 873, 990, 993, 995, 1080, 1194, 1433, 1723, 1883, 2049, 3000,
    3306, 3389, 4443, 5000, 5060, 5222, 5353, 5432, 5900, 6379, 7547,
    8000, 8008, 8080, 8443, 8883, 8888, 9000, 9090, 9100, 9200, 27017,
  ];

  static final Map<int, int> _portIndex = {
    for (var i = 0; i < _trackedPorts.length; i++) _trackedPorts[i]: i,
  };

  static const List<String> deviceCategories = [
    'Router/Gateway',
    'Access Point',
    'Desktop',
    'Laptop',
    'Mobile Device',
    'Tablet',
    'Smart TV',
    'IoT Sensor',
    'Printer',
    'NAS/Storage',
    'Game Console',
    'IP Camera',
    'Smart Speaker',
    'Server',
    'Unknown',
  ];

  /// Deterministic hash of [value] into [0, dim).
  ///
  /// Uses the same MD5-based hash as the Python training pipeline.
  /// We implement a minimal MD5 to avoid external crypto dependencies.
  static int _hashToBucket(String value, int dim) {
    final bytes = _md5(utf8.encode(value.toLowerCase()));
    // Read first 4 bytes as little-endian uint32
    final v = bytes[0] |
        (bytes[1] << 8) |
        (bytes[2] << 16) |
        (bytes[3] << 24);
    return (v & 0xFFFFFFFF) % dim;
  }

  static List<String> _trigrams(String text) {
    final t = text.toLowerCase().trim();
    if (t.length < 3) return t.isEmpty ? [] : [t];
    return [for (var i = 0; i <= t.length - 3; i++) t.substring(i, i + 3)];
  }

  /// Build the fixed-size feature vector for a single host.
  static Float32List extractFeatures(HostScanResult host) {
    final feat = Float32List(featureDim);

    // 1. Port bitmap
    for (final svc in host.services) {
      final idx = _portIndex[svc.port];
      if (idx != null) feat[idx] = 1.0;
    }

    // 2. Vendor hash (multi-hot)
    final vendorOffset = _numPorts;
    for (final word in host.vendor.toLowerCase().split(' ')) {
      if (word.isEmpty) continue;
      final bucket = _hashToBucket(word, _vendorHashDim);
      feat[vendorOffset + bucket] = 1.0;
    }

    // 3. Hostname trigram hash (multi-hot)
    final hostnameOffset = vendorOffset + _vendorHashDim;
    for (final tri in _trigrams(host.hostName)) {
      final bucket = _hashToBucket(tri, _hostnameHashDim);
      feat[hostnameOffset + bucket] = 1.0;
    }

    // 4. Service name BoW hash (multi-hot)
    final serviceOffset = hostnameOffset + _hostnameHashDim;
    for (final svc in host.services) {
      for (final word in svc.serviceName.toLowerCase().split('-')) {
        if (word.isEmpty) continue;
        final bucket = _hashToBucket(word, _serviceBowDim);
        feat[serviceOffset + bucket] = 1.0;
      }
    }

    return feat;
  }

  /// Decode model output logits into a classification result.
  static DeviceClassification decodeOutput(List<double> logits) {
    // Softmax
    var maxLogit = logits[0];
    for (final l in logits) {
      if (l > maxLogit) maxLogit = l;
    }
    var sumExp = 0.0;
    final probs = List<double>.filled(logits.length, 0.0);
    for (var i = 0; i < logits.length; i++) {
      probs[i] = math.exp(logits[i] - maxLogit);
      sumExp += probs[i];
    }
    for (var i = 0; i < probs.length; i++) {
      probs[i] /= sumExp;
    }

    var bestIdx = 0;
    for (var i = 1; i < probs.length; i++) {
      if (probs[i] > probs[bestIdx]) bestIdx = i;
    }

    return DeviceClassification(
      deviceType: bestIdx < deviceCategories.length
          ? deviceCategories[bestIdx]
          : 'Unknown',
      confidence: probs[bestIdx],
    );
  }

  // -----------------------------------------------------------------------
  // Minimal MD5 implementation (RFC 1321) to avoid crypto package dependency.
  // -----------------------------------------------------------------------

  static Uint8List _md5(List<int> input) {
    var a0 = 0x67452301;
    var b0 = 0xEFCDAB89;
    var c0 = 0x98BADCFE;
    var d0 = 0x10325476;

    final originalLength = input.length;
    final bitLength = originalLength * 8;

    // Padding
    final padded = <int>[...input, 0x80];
    while (padded.length % 64 != 56) {
      padded.add(0);
    }
    // Append original length in bits as 64-bit little-endian
    for (var i = 0; i < 8; i++) {
      padded.add((bitLength >> (i * 8)) & 0xFF);
    }

    const s = <int>[
      7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22,
      5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20,
      4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23,
      6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21,
    ];

    const k = <int>[
      0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee,
      0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
      0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be,
      0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
      0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa,
      0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
      0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed,
      0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
      0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c,
      0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
      0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05,
      0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
      0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039,
      0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
      0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1,
      0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391,
    ];

    // Process each 64-byte chunk
    for (var chunkStart = 0; chunkStart < padded.length; chunkStart += 64) {
      final m = List<int>.filled(16, 0);
      for (var i = 0; i < 16; i++) {
        final j = chunkStart + i * 4;
        m[i] = padded[j] |
            (padded[j + 1] << 8) |
            (padded[j + 2] << 16) |
            (padded[j + 3] << 24);
      }

      var a = a0, b = b0, c = c0, d = d0;

      for (var i = 0; i < 64; i++) {
        int f, g;
        if (i < 16) {
          f = (b & c) | ((~b & 0xFFFFFFFF) & d);
          g = i;
        } else if (i < 32) {
          f = (d & b) | ((~d & 0xFFFFFFFF) & c);
          g = (5 * i + 1) % 16;
        } else if (i < 48) {
          f = b ^ c ^ d;
          g = (3 * i + 5) % 16;
        } else {
          f = c ^ (b | (~d & 0xFFFFFFFF));
          g = (7 * i) % 16;
        }

        f = (f + a + k[i] + m[g]) & 0xFFFFFFFF;
        a = d;
        d = c;
        c = b;
        b = (b + _rotateLeft32(f, s[i])) & 0xFFFFFFFF;
      }

      a0 = (a0 + a) & 0xFFFFFFFF;
      b0 = (b0 + b) & 0xFFFFFFFF;
      c0 = (c0 + c) & 0xFFFFFFFF;
      d0 = (d0 + d) & 0xFFFFFFFF;
    }

    final result = Uint8List(16);
    for (var i = 0; i < 4; i++) {
      result[i] = (a0 >> (i * 8)) & 0xFF;
      result[i + 4] = (b0 >> (i * 8)) & 0xFF;
      result[i + 8] = (c0 >> (i * 8)) & 0xFF;
      result[i + 12] = (d0 >> (i * 8)) & 0xFF;
    }
    return result;
  }

  static int _rotateLeft32(int x, int n) {
    return ((x << n) | (x >> (32 - n))) & 0xFFFFFFFF;
  }
}
