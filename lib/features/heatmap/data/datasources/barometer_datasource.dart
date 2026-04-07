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

  double _baseline = 1013.25;
  bool _calibrated = false;
  final _controller = StreamController<FloorReading>.broadcast();
  StreamSubscription? _sub;

  @override
  Stream<FloorReading> get floorStream => _controller.stream;

  @override
  void startTracking(double baselinePressureHpa) {
    _sub?.cancel();
    _calibrated = baselinePressureHpa > 0;
    _baseline = _calibrated ? baselinePressureHpa : 1013.25;

    try {
      _sub = barometerEventStream().listen((event) {
        if (!_calibrated) {
          // Self-calibrate on the first real reading.
          _calibrated = true;
          _baseline = event.pressure;
        }
        // Higher floor → lower pressure → positive delta.
        final delta = _baseline - event.pressure;
        final floorIndex = (delta / _hpaPerFloor).round();
        _controller.add(
          FloorReading(floorIndex: floorIndex, pressureHpa: event.pressure),
        );
      });
    } catch (_) {
      // Barometer not available on this device — degrade silently.
    }
  }

  @override
  void stopTracking() {
    _sub?.cancel();
    _sub = null;
    _calibrated = false;
  }
}
