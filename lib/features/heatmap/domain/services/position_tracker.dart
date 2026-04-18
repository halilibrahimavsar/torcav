import 'dart:async';
import 'dart:math' as math;
import 'package:injectable/injectable.dart';
import 'package:torcav/features/heatmap/data/datasources/position_datasource.dart';
import 'package:torcav/features/heatmap/domain/entities/heatmap_session.dart';
import 'package:torcav/features/heatmap/domain/entities/position_update.dart';

/// Service responsible for tracking user position and determining when to sample points.
/// Integrates with [PositionDataSource] and implements auto-sampling logic.
@LazySingleton()
class PositionTracker {
  PositionTracker(this._positionDataSource);

  final PositionDataSource _positionDataSource;
  StreamSubscription? _subscription;

  final _candidateController = StreamController<PointCandidate>.broadcast();
  Stream<PointCandidate> get candidateStream => _candidateController.stream;

  final StreamController<PositionUpdate> _rawPositionController =
      StreamController<PositionUpdate>.broadcast();

  /// Stream of real-time position updates.
  Stream<PositionUpdate> get rawPositionStream => _rawPositionController.stream;

  double? _lastRecordedX;
  double? _lastRecordedY;

  final bool _isAutoSamplingEnabled = true;
  final double _minDistanceThreshold = 1.0; // Meters

  void start(double initialX, double initialY) {
    _lastRecordedX = initialX;
    _lastRecordedY = initialY;
    _subscription?.cancel();
    _subscription = _positionDataSource.positionStream.listen(
      _onPositionUpdate,
    );
    _positionDataSource.startTracking();
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
    _positionDataSource.stopTracking();
  }

  void _onPositionUpdate(PositionUpdate pos) {
    _rawPositionController.add(pos);

    bool shouldTrigger = false;

    if (_isAutoSamplingEnabled) {
      if (_lastRecordedX == null || _lastRecordedY == null) {
        shouldTrigger = true;
      } else {
        final distance = math.sqrt(
          math.pow(pos.x - _lastRecordedX!, 2) +
              math.pow(pos.y - _lastRecordedY!, 2),
        );
        if (distance >= _minDistanceThreshold) {
          shouldTrigger = true;
        }
      }
    } else if (pos.isStep) {
      shouldTrigger = true;
    }

    if (shouldTrigger) {
      _candidateController.add(
        PointCandidate(
          x: pos.x,
          y: pos.y,
          heading: pos.heading,
          isStep: pos.isStep,
        ),
      );
    }
  }

  /// Verification logic to ensure we don't record points too close to each other.
  bool shouldRecordPoint(
    HeatmapSession session,
    double x,
    double y,
    double minDistance,
  ) {
    if (session.points.isEmpty) return true;
    final lastPoint = session.points.last;
    final dx = x - lastPoint.floorX;
    final dy = y - lastPoint.floorY;
    final distance = math.sqrt(dx * dx + dy * dy);
    return distance >= minDistance;
  }

  void markPointRecorded(double x, double y) {
    _lastRecordedX = x;
    _lastRecordedY = y;
  }

  void setPosition(double x, double y) {
    _positionDataSource.setPosition(x, y);
    _lastRecordedX = x;
    _lastRecordedY = y;
  }

  /// Manually realigns the underlying PDR heading to the absolute compass.
  void realign() {
    _positionDataSource.realignHeading();
  }

  void dispose() {
    stop();
    _candidateController.close();
    _rawPositionController.close();
  }
}
