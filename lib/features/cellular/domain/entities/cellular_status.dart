import 'package:equatable/equatable.dart';

/// Snapshot of the device's cellular connection, read without
/// `READ_PHONE_STATE` (see `CellularChannelHandler.kt` for the permission
/// story). All fields are best-effort: OEMs and radios differ in what they
/// report, so consumers must render partial data gracefully.
class CellularStatus extends Equatable {
  /// Network operator display name (e.g. "Turkcell"). Null when no SIM or
  /// the platform withheld it.
  final String? operatorName;

  /// Radio generation of the serving cell: '5G' | '4G' | '3G' | '2G'.
  final String? generation;

  /// Serving-cell signal strength in dBm (negative; closer to 0 is better).
  final int? dbm;

  /// Android's own 0..4 signal bucket — comparable to Wi-Fi bars.
  final int? level;

  /// True when the active default network is the cellular transport.
  final bool mobileDataActive;

  /// OS bandwidth estimates for the cellular link, when it is active.
  final int? downKbps;
  final int? upKbps;

  /// True when fine-location permission is missing, which blocks the
  /// serving-cell read (operator + data-active still work without it).
  final bool permissionMissing;

  const CellularStatus({
    this.operatorName,
    this.generation,
    this.dbm,
    this.level,
    this.mobileDataActive = false,
    this.downKbps,
    this.upKbps,
    this.permissionMissing = false,
  });

  /// Platform gave us nothing usable (no SIM, unsupported platform, …).
  bool get hasSignalInfo => generation != null || dbm != null || level != null;

  static const unavailable = CellularStatus();

  @override
  List<Object?> get props => [
    operatorName,
    generation,
    dbm,
    level,
    mobileDataActive,
    downKbps,
    upKbps,
    permissionMissing,
  ];
}
