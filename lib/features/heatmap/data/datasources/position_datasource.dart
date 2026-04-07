import 'dart:async';
import 'dart:math' as math;
import 'package:injectable/injectable.dart';

import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_compass/flutter_compass.dart';

abstract class PositionDataSource {
  Stream<PositionUpdate> get positionStream;
  void startTracking();
  void stopTracking();
  void setStepLength(double meters);
}

class PositionUpdate {
  const PositionUpdate({
    required this.x,
    required this.y,
    required this.heading,
    this.isStep = false,
  });
  final double x;
  final double y;
  final double heading;
  final bool isStep;
}

@LazySingleton(as: PositionDataSource)
class PositionDataSourceImpl implements PositionDataSource {
  double _x = 0;
  double _y = 0;
  double _heading = 0;
  double _stepLength = 0.75;

  // Gyroscope fusion state
  double _gyroHeading = 0.0;
  int _lastGyroTimestamp = 0;
  // Complementary filter weight: gyro handles fast changes, compass corrects drift.
  static const _alpha = 0.98;

  final _controller = StreamController<PositionUpdate>.broadcast();
  StreamSubscription? _accelSub;
  StreamSubscription? _compassSub;
  StreamSubscription? _gyroSub;

  @override
  Stream<PositionUpdate> get positionStream => _controller.stream;

  @override
  void setStepLength(double meters) => _stepLength = meters;

  @override
  void startTracking() {
    _accelSub = accelerometerEventStream().listen((event) {
      final mag = math.sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );
      final now = DateTime.now().millisecondsSinceEpoch;
      if (mag > 12.5 && (now - _lastStepTime > 250)) {
        _lastStepTime = now;
        _onStep();
      }
    });

    // Gyroscope: integrate z-axis (yaw) angular velocity for fast turn detection.
    _gyroSub = gyroscopeEventStream().listen((event) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (_lastGyroTimestamp > 0) {
        final dtSec = (now - _lastGyroTimestamp) / 1000.0;
        final deltaHeadingDeg = event.z * dtSec * (180.0 / math.pi);
        _gyroHeading = (_gyroHeading + deltaHeadingDeg) % 360.0;
      }
      _lastGyroTimestamp = now;
    });

    // Compass: absolute heading for long-term drift correction via complementary filter.
    _compassSub = FlutterCompass.events?.listen((event) {
      final compassHeading = event.heading ?? _heading;
      // Fuse gyro (fast, drifts) with compass (slow, absolute).
      _heading = (_alpha * _gyroHeading + (1.0 - _alpha) * compassHeading) % 360.0;
      // Sync gyro to fused result to prevent unbounded drift.
      _gyroHeading = _heading;
      _controller.add(PositionUpdate(x: _x, y: _y, heading: _heading));
    });
  }

  int _lastStepTime = 0;

  void _onStep() {
    final radians = _heading * (math.pi / 180.0);
    _x += _stepLength * math.cos(radians);
    _y += _stepLength * math.sin(radians);

    _controller.add(PositionUpdate(
      x: _x,
      y: _y,
      heading: _heading,
      isStep: true,
    ));
  }

  @override
  void stopTracking() {
    _accelSub?.cancel();
    _compassSub?.cancel();
    _gyroSub?.cancel();
    _lastGyroTimestamp = 0;
  }
}
