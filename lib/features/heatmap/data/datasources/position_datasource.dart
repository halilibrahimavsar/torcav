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
  
  final _controller = StreamController<PositionUpdate>.broadcast();
  StreamSubscription? _accelSub;
  StreamSubscription? _compassSub;

  @override
  Stream<PositionUpdate> get positionStream => _controller.stream;

  @override
  void setStepLength(double meters) => _stepLength = meters;

  @override
  void startTracking() {
    _accelSub = accelerometerEvents.listen((event) {
      // Noise filter (low-pass)
      final mag = math.sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      
      final now = DateTime.now().millisecondsSinceEpoch;
      // Simple peak detection with debounce (min 250ms between steps)
      if (mag > 12.5 && (now - _lastStepTime > 250)) {
        _lastStepTime = now;
        _onStep();
      }
    });

    _compassSub = FlutterCompass.events?.listen((event) {
      // Smooth heading (optional, but keep it simple for now)
      _heading = event.heading ?? 0.0;
      _controller.add(PositionUpdate(x: _x, y: _y, heading: _heading));
    });
  }

  int _lastStepTime = 0;

  void _onStep() {
    // Dead reckoning: x = v * cos(heading), y = v * sin(heading)
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
  }
}
