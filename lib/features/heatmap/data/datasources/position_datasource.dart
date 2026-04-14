import 'dart:async';
import 'dart:math' as math;
import 'package:injectable/injectable.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:torcav/core/logging/app_logger.dart';
import '../../domain/entities/position_update.dart';

abstract class PositionDataSource {
  Stream<PositionUpdate> get positionStream;
  void startTracking();
  void stopTracking();
  void setStepLength(double meters);
  void setPosition(double x, double y);
}

@LazySingleton(as: PositionDataSource)
class PositionDataSourceImpl implements PositionDataSource {
  double _x = 0;
  double _y = 0;
  double _heading = 0;
  double _stepLength = 0.75;

  // EMA smoothing state
  double _smoothedHeading = 0;
  double _lastEmittedHeading = 0;
  int _lastHeadingEmitTime = 0;

  // BUG-18: Buffer the first few compass readings and initialise the EMA from
  // their circular mean. Starting from 0° causes the EMA to drift toward North
  // for several seconds after app launch when the device is actually facing
  // another direction, which breaks the initial AR heading offset calculation.
  static const _warmUpCount = 3;
  final List<double> _warmUpHeadings = [];
  bool _headingWarmedUp = false;

  final _controller = StreamController<PositionUpdate>.broadcast();
  StreamSubscription? _accelSub;
  StreamSubscription? _compassSub;

  @override
  Stream<PositionUpdate> get positionStream => _controller.stream;

  @override
  void setStepLength(double meters) => _stepLength = meters;

  @override
  void setPosition(double x, double y) {
    _x = x;
    _y = y;
    _controller.add(PositionUpdate(x: _x, y: _y, heading: _heading));
  }

  static const _stepMagMin = 12.5;
  static const _stepMinInterval = 350;

  /// EMA low-pass filter for compass heading with 0°/360° wraparound handling.
  /// alpha: 0.03: high persistence (premium stable feel), 0.2: high responsiveness (jumpy).
  double _smoothHeading(double raw) {
    const alpha = 0.03;
    final rawRad = raw * math.pi / 180.0;
    final smoothRad = _smoothedHeading * math.pi / 180.0;
    
    // Check for large angular jumps (e.g., initial fix or rapid turn)
    // If > 45 degrees, we "snap" the smoothed value to avoid a long slow drift.
    final angleDiff = (raw - _smoothedHeading).abs();
    final wrappedDiff = angleDiff > 180 ? 360 - angleDiff : angleDiff;
    if (wrappedDiff > 45.0) {
      _smoothedHeading = raw;
      return _smoothedHeading;
    }

    // We compute the shortest angular distance to avoid 0/360 flip jank
    final sinSmooth =
        (1 - alpha) * math.sin(smoothRad) + alpha * math.sin(rawRad);
    final cosSmooth =
        (1 - alpha) * math.cos(smoothRad) + alpha * math.cos(rawRad);
        
    _smoothedHeading = math.atan2(sinSmooth, cosSmooth) * 180.0 / math.pi;
    if (_smoothedHeading < 0) _smoothedHeading += 360.0;
    return _smoothedHeading;
  }

  @override
  void startTracking() {
    stopTracking();
    _x = 0;
    _y = 0;
    _heading = 0;
    _smoothedHeading = 0;
    _lastEmittedHeading = 0;
    _lastHeadingEmitTime = 0;
    _lastStepTime = 0;
    _warmUpHeadings.clear();
    _headingWarmedUp = false;

    try {
      _accelSub = accelerometerEventStream().listen(
        (event) {
          final mag = math.sqrt(
            event.x * event.x + event.y * event.y + event.z * event.z,
          );
          final now = DateTime.now().millisecondsSinceEpoch;
          if (mag > _stepMagMin && (now - _lastStepTime > _stepMinInterval)) {
            _lastStepTime = now;
            _onStep();
          }
        },
        onError: (_) {},
        cancelOnError: false,
      );
    } catch (e) {
      AppLogger.w('Accelerometer unavailable: $e');
    }

    _compassSub = FlutterCompass.events?.listen((event) {
      final raw = event.heading ?? _heading;

      if (!_headingWarmedUp) {
        // Accumulate warm-up readings and compute the circular mean to get a
        // statistically correct average over the 0°/360° boundary.
        _warmUpHeadings.add(raw);
        if (_warmUpHeadings.length >= _warmUpCount) {
          double sinSum = 0, cosSum = 0;
          for (final h in _warmUpHeadings) {
            final rad = h * math.pi / 180.0;
            sinSum += math.sin(rad);
            cosSum += math.cos(rad);
          }
          var mean = math.atan2(sinSum, cosSum) * 180.0 / math.pi;
          if (mean < 0) mean += 360.0;
          _smoothedHeading = mean;
          _lastEmittedHeading = mean;
          _headingWarmedUp = true;
          _warmUpHeadings.clear();
        }
        // Emit a preliminary update using the raw value so the UI isn't frozen
        // during warm-up, but don't set _smoothedHeading until we're warmed up.
        _heading = raw;
        _controller.add(PositionUpdate(x: _x, y: _y, heading: _heading));
        return;
      }

      _heading = _smoothHeading(raw);

      // We emit more frequently but with heavier smoothing to allow the
      // TweenAnimationBuilder in the UI to perform fluid interpolation.
      final now = DateTime.now().millisecondsSinceEpoch;
      final delta = (_heading - _lastEmittedHeading).abs();
      final wrappedDelta = delta > 180 ? 360 - delta : delta;
      final elapsed = now - _lastHeadingEmitTime;

      // Threshold lowered to 0.4° for fluidity, but throttled to 15Hz (66ms).
      if (wrappedDelta >= 0.4 && elapsed >= 66) {
        _lastEmittedHeading = _heading;
        _lastHeadingEmitTime = now;
        _controller.add(PositionUpdate(x: _x, y: _y, heading: _heading));
      }
    });
  }

  int _lastStepTime = 0;

  void _onStep() {
    // Correct PDR displacement for compass bearing:
    //   East  (X) = sin(heading)  — heading 90° → X increases
    //   North (Y) = cos(heading)  — heading  0° → Y increases
    final radians = _heading * (math.pi / 180.0);
    _x += _stepLength * math.sin(radians);
    _y += _stepLength * math.cos(radians);

    _controller.add(
      PositionUpdate(x: _x, y: _y, heading: _heading, isStep: true),
    );
  }

  @override
  void stopTracking() {
    _accelSub?.cancel();
    _compassSub?.cancel();
    _accelSub = null;
    _compassSub = null;
  }
}
