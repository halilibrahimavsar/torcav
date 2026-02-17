import 'package:equatable/equatable.dart';

import '../../../wifi_scan/domain/entities/scan_request.dart';

class AppSettings extends Equatable {
  final int scanIntervalSeconds;
  final int defaultScanPasses;
  final WifiBackendPreference defaultBackendPreference;
  final bool includeHiddenSsids;
  final bool strictSafetyMode;

  const AppSettings({
    this.scanIntervalSeconds = 5,
    this.defaultScanPasses = 3,
    this.defaultBackendPreference = WifiBackendPreference.auto,
    this.includeHiddenSsids = true,
    this.strictSafetyMode = true,
  });

  AppSettings copyWith({
    int? scanIntervalSeconds,
    int? defaultScanPasses,
    WifiBackendPreference? defaultBackendPreference,
    bool? includeHiddenSsids,
    bool? strictSafetyMode,
  }) {
    return AppSettings(
      scanIntervalSeconds: scanIntervalSeconds ?? this.scanIntervalSeconds,
      defaultScanPasses: defaultScanPasses ?? this.defaultScanPasses,
      defaultBackendPreference:
          defaultBackendPreference ?? this.defaultBackendPreference,
      includeHiddenSsids: includeHiddenSsids ?? this.includeHiddenSsids,
      strictSafetyMode: strictSafetyMode ?? this.strictSafetyMode,
    );
  }

  @override
  List<Object?> get props => [
    scanIntervalSeconds,
    defaultScanPasses,
    defaultBackendPreference,
    includeHiddenSsids,
    strictSafetyMode,
  ];
}
