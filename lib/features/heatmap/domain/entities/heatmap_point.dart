import 'package:equatable/equatable.dart';

/// A single RSSI measurement captured at a relative [x], [y] grid position.
///
/// Coordinates are normalised to a 0–1 unit square so they are independent of
/// screen resolution and can be stored compactly.  The renderer maps them back
/// to pixel offsets at paint time.
class HeatmapPoint extends Equatable {
  const HeatmapPoint({
    required this.x,
    required this.y,
    required this.rssi,
    required this.timestamp,
    this.ssid = '',
  });

  /// Normalised horizontal position [0.0, 1.0].
  final double x;

  /// Normalised vertical position [0.0, 1.0].
  final double y;

  /// Signal strength in dBm (typically –30 to –90).
  final int rssi;

  /// When the measurement was recorded.
  final DateTime timestamp;

  /// SSID of the AP this reading belongs to (optional, for multi-SSID views).
  final String ssid;

  HeatmapPoint copyWith({
    double? x,
    double? y,
    int? rssi,
    DateTime? timestamp,
    String? ssid,
  }) =>
      HeatmapPoint(
        x: x ?? this.x,
        y: y ?? this.y,
        rssi: rssi ?? this.rssi,
        timestamp: timestamp ?? this.timestamp,
        ssid: ssid ?? this.ssid,
      );

  @override
  List<Object?> get props => [x, y, rssi, timestamp, ssid];
}
