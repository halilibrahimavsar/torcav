import '../entities/position_update.dart';

/// Fused pedestrian position and heading from the device's motion sensors.
///
/// The interface belongs to the domain; `PositionDataSourceImpl` in `data`
/// owns the sensor plugins and the fusion maths in [DeadReckoningEngine].
abstract class PositionDataSource {
  Stream<PositionUpdate> get positionStream;
  void startTracking();
  void stopTracking();
  void setStepLength(double meters);
  void setPosition(double x, double y);

  /// Snaps the current relative heading to the absolute compass reference.
  void realignHeading();
}
