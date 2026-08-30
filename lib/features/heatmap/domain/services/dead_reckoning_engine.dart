import 'dart:math' as math;

/// What changed after feeding one sensor sample into [DeadReckoningEngine].
enum ReckoningChange {
  /// Nothing worth telling the UI about.
  none,

  /// Heading moved enough to be worth redrawing.
  heading,

  /// A footstep was detected and the position advanced.
  step,
}

/// Pedestrian dead reckoning: turns accelerometer, gyroscope and compass
/// samples into an (x, y, heading) estimate for indoor heatmap surveys.
///
/// Deliberately pure — no sensor plugins, no `DateTime.now()`, no streams.
/// Every timestamp is passed in. That is what makes the fusion maths testable
/// without a device, which matters more here than almost anywhere else in the
/// app: a regression in this file does not crash, it silently draws the
/// coverage map wrong, and the user then moves their router based on it.
///
/// Coordinates are metres from the survey origin, heading is degrees clockwise
/// from north.
class DeadReckoningEngine {
  // ── Step detection ──────────────────────────────────────────────────
  /// Low-pass factor tracking the gravity baseline so tilt does not read as
  /// motion.
  static const _baselineAlpha = 0.05;

  /// Acceleration above the baseline that counts as a footfall. Tuned for the
  /// slow, deliberate walk an AR survey produces, not for jogging.
  static const stepDynamicThreshold = 0.45;

  /// Debounce between footfalls; below this a single stride double-counts.
  static const stepMinIntervalMs = 450;

  // ── Heading fusion ──────────────────────────────────────────────────
  /// Complementary-filter weight: 2 % absolute compass, 98 % gyro
  /// integration. High immunity to magnetic noise while staying anchored to
  /// north.
  static const headingAlpha = 0.02;

  /// A compass jump this large is re-orientation or hard interference, not
  /// drift — snap rather than ease toward it.
  static const compassSnapDegrees = 60.0;

  /// Compass readings averaged before fusion starts, so a single noisy first
  /// reading does not anchor the whole survey.
  static const warmUpCount = 3;

  // ── Emission throttle ───────────────────────────────────────────────
  static const _emitMinDeltaDegrees = 0.4;
  static const _emitMinIntervalMs = 33; // ~30 Hz, for AR projection smoothness

  double _x = 0;
  double _y = 0;
  double _heading = 0;
  double _stepLength = 0.75;

  double _smoothedHeading = 0;
  double _lastEmittedHeading = 0;
  int _lastHeadingEmitMs = 0;

  double? _lastGyroSeconds;

  double _baselineMag = 9.8;
  int _lastStepMs = 0;

  final List<double> _warmUpHeadings = [];
  bool _headingWarmedUp = false;

  double get x => _x;
  double get y => _y;

  /// Degrees clockwise from north, always in `[0, 360)`.
  double get heading => _heading;

  /// True once enough compass readings have been averaged for fusion to run.
  bool get isWarmedUp => _headingWarmedUp;

  void setStepLength(double metres) => _stepLength = metres;

  void setPosition(double x, double y) {
    _x = x;
    _y = y;
  }

  /// Clears all state for a fresh survey.
  void reset() {
    _x = 0;
    _y = 0;
    _heading = 0;
    _smoothedHeading = 0;
    _lastEmittedHeading = 0;
    _lastHeadingEmitMs = 0;
    _lastStepMs = 0;
    _baselineMag = 9.8;
    _lastGyroSeconds = null;
    _warmUpHeadings.clear();
    _headingWarmedUp = false;
  }

  /// Drops the fused heading back to whatever the compass says next. Used when
  /// the user reports the arrow is pointing the wrong way.
  void realignHeading() {
    _headingWarmedUp = false;
    _warmUpHeadings.clear();
  }

  /// Feed one accelerometer sample. [magnitude] is the vector length in m/s².
  ///
  /// Returns [ReckoningChange.step] when this sample completed a footfall and
  /// the position advanced.
  ReckoningChange onAccelerometer(double magnitude, int nowMs) {
    // Track gravity with a low-pass filter rather than assuming 9.8: the
    // device is held at an angle during a survey, so the resting magnitude
    // drifts and a fixed constant would either miss steps or invent them.
    _baselineMag = (_baselineMag * (1 - _baselineAlpha)) + (magnitude * _baselineAlpha);
    final dynamicMag = (magnitude - _baselineMag).abs();

    if (dynamicMag > stepDynamicThreshold &&
        (nowMs - _lastStepMs > stepMinIntervalMs)) {
      _lastStepMs = nowMs;
      final radians = _heading * (math.pi / 180.0);
      _x += _stepLength * math.sin(radians);
      _y += _stepLength * math.cos(radians);
      return ReckoningChange.step;
    }
    return ReckoningChange.none;
  }

  /// Feed one gyroscope sample. [yawRadPerSec] is the z-axis rate; it is
  /// negated because Android's z axis points up out of the screen.
  ///
  /// Does nothing until the compass has warmed up — integrating rotation onto
  /// an unknown starting heading would accumulate error with no anchor.
  ReckoningChange onGyroscope(double yawRadPerSec, double nowSeconds) {
    final last = _lastGyroSeconds;
    _lastGyroSeconds = nowSeconds;
    if (last == null || !_headingWarmedUp) return ReckoningChange.none;

    final dt = nowSeconds - last;
    final rotationDegrees = (-yawRadPerSec * 180.0 / math.pi) * dt;
    _smoothedHeading = _wrap(_smoothedHeading + rotationDegrees);
    _heading = _smoothedHeading;

    return _shouldEmit((nowSeconds * 1000).round())
        ? ReckoningChange.heading
        : ReckoningChange.none;
  }

  /// Feed one compass reading in degrees clockwise from north.
  ReckoningChange onCompass(double headingDegrees, int nowMs) {
    if (!_headingWarmedUp) {
      _warmUpHeadings.add(headingDegrees);
      if (_warmUpHeadings.length >= warmUpCount) {
        // Circular mean — averaging 359° and 1° arithmetically gives 180°,
        // which would point the survey backwards.
        var sinSum = 0.0;
        var cosSum = 0.0;
        for (final h in _warmUpHeadings) {
          final rad = h * math.pi / 180.0;
          sinSum += math.sin(rad);
          cosSum += math.cos(rad);
        }
        final mean = _wrap(math.atan2(sinSum, cosSum) * 180.0 / math.pi);
        _smoothedHeading = mean;
        _lastEmittedHeading = mean;
        _headingWarmedUp = true;
        _warmUpHeadings.clear();
      }
      // While warming up the raw reading is shown so the arrow is not frozen.
      _heading = headingDegrees;
      return ReckoningChange.heading;
    }

    final angleDiff = headingDegrees - _smoothedHeading;
    final delta =
        angleDiff > 180
            ? angleDiff - 360
            : (angleDiff < -180 ? angleDiff + 360 : angleDiff);

    if (delta.abs() > compassSnapDegrees) {
      _smoothedHeading = headingDegrees;
    } else {
      _smoothedHeading = _wrap(_smoothedHeading + (delta * headingAlpha));
    }
    _heading = _smoothedHeading;

    return _shouldEmit(nowMs) ? ReckoningChange.heading : ReckoningChange.none;
  }

  bool _shouldEmit(int nowMs) {
    final delta = (_heading - _lastEmittedHeading).abs();
    final wrapped = delta > 180 ? 360 - delta : delta;
    if (wrapped >= _emitMinDeltaDegrees &&
        nowMs - _lastHeadingEmitMs >= _emitMinIntervalMs) {
      _lastEmittedHeading = _heading;
      _lastHeadingEmitMs = nowMs;
      return true;
    }
    return false;
  }

  static double _wrap(double degrees) {
    var d = degrees % 360.0;
    if (d < 0) d += 360.0;
    return d;
  }
}
