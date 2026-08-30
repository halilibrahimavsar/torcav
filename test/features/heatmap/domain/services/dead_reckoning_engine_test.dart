import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/features/heatmap/domain/services/dead_reckoning_engine.dart';

/// Walks the compass through warm-up so fusion is active.
void _warmUp(DeadReckoningEngine e, {double heading = 0, int startMs = 0}) {
  for (var i = 0; i < DeadReckoningEngine.warmUpCount; i++) {
    e.onCompass(heading, startMs + i);
  }
}

/// A magnitude comfortably past the step threshold, and one comfortably under.
const _stride = 9.8 + 3.0;
const _still = 9.8;

void main() {
  late DeadReckoningEngine engine;

  setUp(() => engine = DeadReckoningEngine());

  group('warm-up', () {
    test('fusion is inactive until enough compass readings arrive', () {
      engine.onCompass(90, 0);
      expect(engine.isWarmedUp, isFalse);
      engine.onCompass(90, 10);
      expect(engine.isWarmedUp, isFalse);
      engine.onCompass(90, 20);
      expect(engine.isWarmedUp, isTrue);
    });

    test('warm-up uses the circular mean, not the arithmetic one', () {
      // Arithmetic mean of 359, 1, 0 is 120 — pointing the survey sideways.
      engine
        ..onCompass(359, 0)
        ..onCompass(1, 10)
        ..onCompass(0, 20);

      // Nudge fusion once so the smoothed heading surfaces.
      engine.onCompass(0, 100);
      expect(engine.heading, closeTo(0, 1.0));
    });

    test('the raw reading is shown while warming up, not a frozen zero', () {
      engine.onCompass(123, 0);
      expect(engine.heading, closeTo(123, 0.001));
    });
  });

  group('heading fusion', () {
    test('small compass drift is eased toward, not snapped', () {
      _warmUp(engine, heading: 100);
      final before = engine.heading;

      engine.onCompass(110, 1000);

      // alpha = 0.02, so a 10° disagreement moves the estimate ~0.2°.
      expect(engine.heading, greaterThan(before));
      expect(engine.heading - before, lessThan(1.0));
    });

    test('a jump past the snap threshold is adopted immediately', () {
      _warmUp(engine, heading: 10);

      engine.onCompass(200, 1000);

      expect(engine.heading, closeTo(200, 0.001));
    });

    test('drift across the 0/360 seam takes the short way round', () {
      _warmUp(engine, heading: 355);

      // 5° is 10° clockwise from 355°, not 350° counter-clockwise.
      engine.onCompass(5, 1000);

      // Eased by alpha, so still just past 355 — and crucially not near 180.
      expect(engine.heading, greaterThan(354.0));
      expect(engine.heading, lessThan(360.0));
    });

    test('heading always stays within [0, 360)', () {
      _warmUp(engine, heading: 1);
      for (var i = 0; i < 200; i++) {
        engine.onGyroscope(5.0, i * 0.1); // hard, sustained yaw
        expect(engine.heading, inInclusiveRange(0, 360));
        expect(engine.heading, lessThan(360));
      }
    });

    test('gyroscope is ignored until the compass has anchored it', () {
      engine.onGyroscope(1.0, 0.0);
      engine.onGyroscope(1.0, 1.0);
      expect(engine.heading, 0);
      expect(engine.isWarmedUp, isFalse);
    });

    test('a positive yaw rate turns counter-clockwise (Android z is up)', () {
      _warmUp(engine, heading: 90);
      engine.onGyroscope(0, 0.0); // seed the timestamp
      engine.onGyroscope(math.pi / 2, 1.0); // +90 deg/s for 1 s

      expect(engine.heading, closeTo(0, 1.5));
    });

    test('realign drops back to warm-up so the next fix re-anchors', () {
      _warmUp(engine, heading: 100);
      expect(engine.isWarmedUp, isTrue);

      engine.realignHeading();

      expect(engine.isWarmedUp, isFalse);
      _warmUp(engine, heading: 270, startMs: 5000);
      expect(engine.isWarmedUp, isTrue);
      engine.onCompass(270, 6000);
      expect(engine.heading, closeTo(270, 1.0));
    });
  });

  group('step detection', () {
    test('a still device takes no steps', () {
      for (var i = 0; i < 100; i++) {
        expect(
          engine.onAccelerometer(_still, i * 20),
          ReckoningChange.none,
        );
      }
      expect(engine.x, 0);
      expect(engine.y, 0);
    });

    test('a stride registers exactly one step', () {
      final change = engine.onAccelerometer(_stride, 1000);
      expect(change, ReckoningChange.step);
    });

    test('a second peak inside the debounce window is not a second step', () {
      engine.onAccelerometer(_stride, 1000);
      final tooSoon = engine.onAccelerometer(_stride, 1000 + 100);
      expect(tooSoon, ReckoningChange.none);
    });

    test('a peak after the debounce window is a new step', () {
      engine.onAccelerometer(_stride, 1000);
      final later = engine.onAccelerometer(
        _stride,
        1000 + DeadReckoningEngine.stepMinIntervalMs + 1,
      );
      expect(later, ReckoningChange.step);
    });

    test('a stationary device at Earth gravity never steps', () {
      // |acceleration| is ~9.81 for a still device at ANY tilt — the vector
      // rotates, its magnitude does not. This is the case the 9.8 seed is
      // chosen for, and it must be silent.
      var steps = 0;
      for (var i = 0; i < 300; i++) {
        if (engine.onAccelerometer(9.81, i * 200) == ReckoningChange.step) {
          steps++;
        }
      }
      expect(steps, 0);
    });

    test('the baseline converges on a biased sensor, and how fast', () {
      // A sensor whose zero point is off (or a survey started mid-motion)
      // feeds a magnitude the 9.8 seed does not match. The low-pass filter
      // absorbs it, but not instantly: with alpha = 0.05 a 2.3 m/s² offset
      // stays above the 0.45 threshold for roughly 32 samples.
      //
      // Every one of those samples that clears the 450 ms debounce counts as
      // a step, so a biased sensor injects phantom distance at the start of a
      // survey. Pinned here as the real, measured behaviour: the fix (seeding
      // the baseline from the first reading instead of a constant) has to
      // update this test deliberately.
      var steps = 0;
      for (var i = 0; i < 200; i++) {
        if (engine.onAccelerometer(7.5, i * 500) == ReckoningChange.step) {
          steps++;
        }
      }
      expect(steps, inInclusiveRange(25, 35));

      // Once converged it goes quiet and stays quiet.
      var afterConvergence = 0;
      for (var i = 200; i < 300; i++) {
        if (engine.onAccelerometer(7.5, i * 500) == ReckoningChange.step) {
          afterConvergence++;
        }
      }
      expect(afterConvergence, 0);
    });
  });

  group('dead reckoning', () {
    test('a step at heading 0 advances north (+y)', () {
      engine.onAccelerometer(_stride, 1000);
      expect(engine.x, closeTo(0, 0.001));
      expect(engine.y, closeTo(0.75, 0.001));
    });

    test('a step at heading 90 advances east (+x)', () {
      _warmUp(engine, heading: 90);
      engine.onCompass(90, 100);
      engine.onAccelerometer(_stride, 1000);

      expect(engine.x, closeTo(0.75, 0.01));
      expect(engine.y, closeTo(0, 0.01));
    });

    test('step length scales the advance', () {
      engine.setStepLength(1.5);
      engine.onAccelerometer(_stride, 1000);
      expect(engine.y, closeTo(1.5, 0.001));
    });

    test('walking a square returns near the origin', () {
      engine.setStepLength(1.0);
      var t = 1000;
      for (final heading in [0.0, 90.0, 180.0, 270.0]) {
        engine.realignHeading();
        _warmUp(engine, heading: heading, startMs: t);
        engine.onCompass(heading, t + 10);
        t += 100;
        engine.onAccelerometer(_stride, t);
        t += DeadReckoningEngine.stepMinIntervalMs + 1;
      }

      expect(engine.x, closeTo(0, 0.05));
      expect(engine.y, closeTo(0, 0.05));
    });

    test('setPosition relocates without disturbing heading', () {
      _warmUp(engine, heading: 45);
      final heading = engine.heading;

      engine.setPosition(3, -2);

      expect(engine.x, 3);
      expect(engine.y, -2);
      expect(engine.heading, heading);
    });

    test('reset clears position, heading and warm-up', () {
      _warmUp(engine, heading: 200);
      engine.onAccelerometer(_stride, 1000);

      engine.reset();

      expect(engine.x, 0);
      expect(engine.y, 0);
      expect(engine.heading, 0);
      expect(engine.isWarmedUp, isFalse);
    });
  });

  group('emission throttle', () {
    test('a heading change below the threshold is not emitted', () {
      _warmUp(engine, heading: 100);
      // alpha eases a 1° disagreement to ~0.02°, under the 0.4° floor.
      expect(engine.onCompass(101, 10000), ReckoningChange.none);
    });

    test('a large change is emitted', () {
      _warmUp(engine, heading: 100);
      expect(engine.onCompass(150, 10000), ReckoningChange.heading);
    });
  });
}
