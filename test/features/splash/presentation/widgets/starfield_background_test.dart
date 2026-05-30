import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/features/splash/presentation/widgets/starfield_background.dart';

import '../../../../helpers/widget_pump.dart';

void main() {
  testWidgets('renders without exception with no child', (tester) async {
    await pumpAppWidget(tester, const StarfieldBackground());
    await tester.pump(const Duration(milliseconds: 16));

    expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('hosts the provided child widget', (tester) async {
    await pumpAppWidget(
      tester,
      const StarfieldBackground(
        child: Text('boot screen'),
      ),
    );
    await tester.pump(const Duration(milliseconds: 16));

    expect(find.text('boot screen'), findsOneWidget);
  });

  testWidgets('rebuilds across animation ticks without crashing', (
    tester,
  ) async {
    await pumpAppWidget(
      tester,
      const StarfieldBackground(),
      surfaceSize: const Size(400, 600),
    );
    // Tick a few frames to exercise the AnimatedBuilder + painter.
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(tester.takeException(), isNull);
  });

  group('StarfieldPainter', () {
    test('shouldRepaint always returns true (animated painter)', () {
      final a = StarfieldPainter(stars: const [], progress: 0.0);
      final b = StarfieldPainter(stars: const [], progress: 0.5);
      expect(a.shouldRepaint(b), isTrue);
    });
  });

  group('Star', () {
    test('holds construction values without mutation', () {
      final s = Star(
        x: 0.25,
        y: 0.5,
        size: 1.5,
        velocity: 0.04,
        opacity: 0.9,
        layer: 2,
      );
      expect(s.x, 0.25);
      expect(s.y, 0.5);
      expect(s.size, 1.5);
      expect(s.velocity, 0.04);
      expect(s.opacity, 0.9);
      expect(s.layer, 2);
    });
  });
}
