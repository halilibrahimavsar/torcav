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

  /// Snaps the current relative heading to the absolute compass reference.
  void realignHeading();
}

@LazySingleton(as: PositionDataSource)
class PositionDataSourceImpl implements PositionDataSource {
  double _x = 0;
  double _y = 0;
  double _heading = 0;
  double _stepLength = 0.75;

  // Sensor Fusion State
  double _smoothedHeading = 0;
  double _lastEmittedHeading = 0;
  int _lastHeadingEmitTime = 0;

  // Gyroscope integration state
  double? _lastGyroTime;

  // Step detection state
  double _baselineMag = 9.8;
  static const _baselineAlpha = 0.05;
  int _lastStepTime = 0;

  // BUG-18: Buffer the first few compass readings
  static const _warmUpCount = 3;
  final List<double> _warmUpHeadings = [];
  bool _headingWarmedUp = false;

  final _controller = StreamController<PositionUpdate>.broadcast();
  StreamSubscription? _accelSub;
  StreamSubscription? _compassSub;
  StreamSubscription? _gyroSub;

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

  @override
  void realignHeading() {
    AppLogger.i(
      'Manual heading realign requested. Snapping fused heading to absolute compass.',
    );
    // Re-warmup from next few readings or just snap to current?
    // Let's reset the fusion state to the next compass sample.
    _headingWarmedUp = false;
    _warmUpHeadings.clear();
  }

  static const _stepDynamicThreshold =
      0.45; // Significantly increased sensitivity for slow AR walking
  static const _stepMinInterval = 450;

  /// Sensor fusion step using a Complementary Filter.
  /// Integrates gyroscope for short-term rotation and uses compass for slow bias correction.
  void _updateFusedHeading(double compassRaw) {
    if (!_headingWarmedUp) return;

    // alpha: 0.02 means 98% weight to gyro integration, 2% to absolute compass.
    // This provides high immunity to magnetic noise while staying anchored to North.
    const alpha = 0.02;

    // Step 1: Compass normalization (shortest path)
    final angleDiff = (compassRaw - _smoothedHeading);
    var delta =
        angleDiff > 180
            ? angleDiff - 360
            : (angleDiff < -180 ? angleDiff + 360 : angleDiff);

    // If compass jumps > 60 degrees, we snap to it (likely a manual re-orientation or massive local interference)
    if (delta.abs() > 60.0) {
      _smoothedHeading = compassRaw;
    } else {
      _smoothedHeading = (_smoothedHeading + (delta * alpha)) % 360.0;
    }

    if (_smoothedHeading < 0) _smoothedHeading += 360.0;
    _heading = _smoothedHeading;
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
    _baselineMag = 9.8; // Reset baseline for fresh session tracking
    _warmUpHeadings.clear();
    _headingWarmedUp = false;
    _lastGyroTime = null;

    try {
      _accelSub = accelerometerEventStream().listen(
        (event) {
          final rawMag = math.sqrt(
            event.x * event.x + event.y * event.y + event.z * event.z,
          );

          // Dynamic gravity rejection via low-pass baseline tracking
          _baselineMag =
              (_baselineMag * (1 - _baselineAlpha)) + (rawMag * _baselineAlpha);
          final dynamicMag = (rawMag - _baselineMag).abs();

          final now = DateTime.now().millisecondsSinceEpoch;

          if (dynamicMag > _stepDynamicThreshold &&
              (now - _lastStepTime > _stepMinInterval)) {
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

    // High-frequency Gyroscope listener for short-term orientation changes
    _gyroSub = gyroscopeEventStream().listen((event) {
      final now = DateTime.now().millisecondsSinceEpoch.toDouble() / 1000.0;
      if (_lastGyroTime != null && _headingWarmedUp) {
        final dt = now - _lastGyroTime!;
        // gyro.z is yaw velocity in rad/s. Negative because Android Z is up.
        // We convert to degrees.
        final rotationDegrees = (-event.z * 180.0 / math.pi) * dt;

        _smoothedHeading = (_smoothedHeading + rotationDegrees) % 360.0;
        if (_smoothedHeading < 0) _smoothedHeading += 360.0;
        _heading = _smoothedHeading;

        _emitIfChanged();
      }
      _lastGyroTime = now;
    });

    _compassSub = FlutterCompass.events?.listen((event) {
      final raw = event.heading ?? _heading;

      if (!_headingWarmedUp) {
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
        _heading = raw;
        _controller.add(PositionUpdate(x: _x, y: _y, heading: _heading));
        return;
      }

      _updateFusedHeading(raw);
      _emitIfChanged();
    });
  }

  void _emitIfChanged() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final delta = (_heading - _lastEmittedHeading).abs();
    final wrappedDelta = delta > 180 ? 360 - delta : delta;
    final elapsed = now - _lastHeadingEmitTime;

    // Threshold lowered to 0.4° for fluidity, throttled to 30Hz (33ms) for
    // superior AR projection smoothness.
    if (wrappedDelta >= 0.4 && elapsed >= 33) {
      _lastEmittedHeading = _heading;
      _lastHeadingEmitTime = now;
      _controller.add(PositionUpdate(x: _x, y: _y, heading: _heading));
    }
  }

  void _onStep() {
    final radians = _heading * (math.pi / 180.0);
    _x += _stepLength * math.sin(radians);
    _y += _stepLength * math.cos(radians);

    AppLogger.i(
      '👟 Step Detected: Heading ${_heading.toStringAsFixed(1)}°, New Pos (${_x.toStringAsFixed(2)}, ${_y.toStringAsFixed(2)})',
    );

    _controller.add(
      PositionUpdate(x: _x, y: _y, heading: _heading, isStep: true),
    );
  }

  @override
  void stopTracking() {
    _accelSub?.cancel();
    _compassSub?.cancel();
    _gyroSub?.cancel();
    _accelSub = null;
    _compassSub = null;
    _gyroSub = null;
  }
}
