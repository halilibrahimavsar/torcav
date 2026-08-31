import '../entities/floor_reading.dart';

/// Floor-change estimates from barometric pressure.
///
/// The interface belongs to the domain; the `data` implementation owns the
/// sensor plugin.
abstract class BarometerDataSource {
  Stream<FloorReading> get floorStream;

  /// Start barometer tracking. Pass [baselinePressureHpa] = 0 to
  /// auto-calibrate from the first sensor reading (recommended).
  void startTracking(double baselinePressureHpa);

  void stopTracking();
}
