import 'package:equatable/equatable.dart';

/// A single RSSI measurement captured at a physical location.
///
/// Coordinates are in meters relative to the start of the scan session (0,0).
/// The [x] and [y] normalized coordinates are kept for backward compatibility
/// but are deprecated.
class HeatmapPoint extends Equatable {
  const HeatmapPoint({
    required this.x,
    required this.y,
    required this.floorX,
    required this.floorY,
    required this.rssi,
    required this.timestamp,
    this.heading = 0.0,
    this.ssid = '',
    this.floor = 0,
  });

  /// Normalised horizontal position [0.0, 1.0] (deprecated in favour of floorX).
  final double x;

  /// Normalised vertical position [0.0, 1.0] (deprecated in favour of floorY).
  final double y;

  /// Metric horizontal position in meters from origin.
  final double floorX;

  /// Metric vertical position in meters from origin.
  final double floorY;

  /// Compass heading in degrees [0-360] at time of measurement.
  final double heading;

  /// Signal strength in dBm (typically –30 to –90).
  final int rssi;

  /// When the measurement was recorded.
  final DateTime timestamp;

  /// SSID of the AP this reading belongs to (optional, for multi-SSID views).
  final String ssid;

  /// Floor index relative to scan start (0 = starting floor, barometer-based).
  final int floor;

  HeatmapPoint copyWith({
    double? x,
    double? y,
    double? floorX,
    double? floorY,
    double? heading,
    int? rssi,
    DateTime? timestamp,
    String? ssid,
    int? floor,
  }) =>
      HeatmapPoint(
        x: x ?? this.x,
        y: y ?? this.y,
        floorX: floorX ?? this.floorX,
        floorY: floorY ?? this.floorY,
        heading: heading ?? this.heading,
        rssi: rssi ?? this.rssi,
        timestamp: timestamp ?? this.timestamp,
        ssid: ssid ?? this.ssid,
        floor: floor ?? this.floor,
      );

  @override
  List<Object?> get props => [x, y, floorX, floorY, heading, rssi, timestamp, ssid, floor];
}
