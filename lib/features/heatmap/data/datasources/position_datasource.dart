import 'dart:async';
import 'dart:math' as math;
import 'package:injectable/injectable.dart';

import '../../domain/repositories/position_source.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:torcav/core/logging/app_logger.dart';
import '../../domain/entities/position_update.dart';
import '../../domain/services/dead_reckoning_engine.dart';


@LazySingleton(as: PositionDataSource)
class PositionDataSourceImpl implements PositionDataSource {
  /// All the fusion maths lives here — pure, unit-tested, no plugins. This
  /// class is only the adapter that pumps sensor streams into it and turns
  /// its verdicts into [PositionUpdate]s.
  final _engine = DeadReckoningEngine();

  final _controller = StreamController<PositionUpdate>.broadcast();
  StreamSubscription? _accelSub;
  StreamSubscription? _compassSub;
  StreamSubscription? _gyroSub;

  @override
  Stream<PositionUpdate> get positionStream => _controller.stream;

  @override
  void setStepLength(double meters) => _engine.setStepLength(meters);

  @override
  void setPosition(double x, double y) {
    _engine.setPosition(x, y);
    _emit();
  }

  @override
  void realignHeading() {
    AppLogger.i(
      'Manual heading realign requested. Snapping fused heading to absolute compass.',
    );
    _engine.realignHeading();
  }

  void _emit({bool isStep = false}) {
    _controller.add(
      PositionUpdate(
        x: _engine.x,
        y: _engine.y,
        heading: _engine.heading,
        isStep: isStep,
      ),
    );
  }

  @override
  void startTracking() {
    stopTracking();
    _engine.reset();

    try {
      _accelSub = accelerometerEventStream().listen(
        (event) {
          final magnitude = math.sqrt(
            event.x * event.x + event.y * event.y + event.z * event.z,
          );
          final change = _engine.onAccelerometer(
            magnitude,
            DateTime.now().millisecondsSinceEpoch,
          );
          if (change == ReckoningChange.step) {
            AppLogger.i(
              '👟 Step Detected: Heading ${_engine.heading.toStringAsFixed(1)}°, '
              'New Pos (${_engine.x.toStringAsFixed(2)}, ${_engine.y.toStringAsFixed(2)})',
            );
            _emit(isStep: true);
          }
        },
        onError: (_) {},
        cancelOnError: false,
      );
    } catch (e) {
      AppLogger.w('Accelerometer unavailable: $e');
    }

    _gyroSub = gyroscopeEventStream().listen((event) {
      final seconds = DateTime.now().millisecondsSinceEpoch / 1000.0;
      if (_engine.onGyroscope(event.z, seconds) == ReckoningChange.heading) {
        _emit();
      }
    });

    _compassSub = FlutterCompass.events?.listen((event) {
      final raw = event.heading ?? _engine.heading;
      final change = _engine.onCompass(
        raw,
        DateTime.now().millisecondsSinceEpoch,
      );
      if (change == ReckoningChange.heading) _emit();
    });
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
