import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../domain/entities/floor_reading.dart';

abstract class BarometerDataSource {
  Stream<FloorReading> get floorStream;

  /// Start barometer tracking. Pass [baselinePressureHpa] = 0 to
  /// auto-calibrate from the first sensor reading (recommended).
  void startTracking(double baselinePressureHpa);

  void stopTracking();
}

@LazySingleton(as: BarometerDataSource)
class BarometerDataSourceImpl implements BarometerDataSource {
  // 1 floor ≈ 3 m ≈ 1.05 hPa pressure difference (standard atmosphere).
  static const _hpaPerFloor = 1.05;

  // BUG-12: We need at least this many readings before committing the baseline.
  // The first reading on device pickup is often taken mid-swing, which can
  // introduce a ±0.5 hPa error (~0.5 floors) that persists for the session.
  static const _warmUpSamples = 5;

  double _baseline = 1013.25;
  bool _calibrated = false;
  final List<double> _warmUpBuffer = [];
  final _controller = StreamController<FloorReading>.broadcast();
  StreamSubscription? _sub;

  @override
  Stream<FloorReading> get floorStream => _controller.stream;

  @override
  void startTracking(double baselinePressureHpa) {
    _sub?.cancel();
    _warmUpBuffer.clear();
    _calibrated = baselinePressureHpa > 0;
    _baseline = _calibrated ? baselinePressureHpa : 1013.25;

    try {
      _sub = barometerEventStream().listen(
        (event) {
          if (!_calibrated) {
            // Accumulate warm-up samples and compute an average baseline.
            // This avoids locking onto a stale pressure from mid-swing startup.
            _warmUpBuffer.add(event.pressure);
            if (_warmUpBuffer.length >= _warmUpSamples) {
              final sum = _warmUpBuffer.reduce((a, b) => a + b);
              _baseline = sum / _warmUpBuffer.length;
              _calibrated = true;
              _warmUpBuffer.clear();
            }
            // Emit with the default baseline until calibrated so consumers
            // have a best-effort reading during the warm-up window.
          }
          // Higher floor → lower pressure → positive delta.
          final delta = _baseline - event.pressure;
          final floorIndex = (delta / _hpaPerFloor).round();
          _controller.add(
            FloorReading(floorIndex: floorIndex, pressureHpa: event.pressure),
          );
        },
        onError: (_) {}, // Barometer not available on this device — degrade silently.
        cancelOnError: false,
      );
    } catch (_) {
      // Barometer plugin threw synchronously — degrade silently.
    }
  }

  @override
  void stopTracking() {
    _sub?.cancel();
    _sub = null;
    _calibrated = false;
    _warmUpBuffer.clear();
  }
}
