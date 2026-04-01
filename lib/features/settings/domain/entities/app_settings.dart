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

  Map<String, dynamic> toJson() {
    return {
      'scanIntervalSeconds': scanIntervalSeconds,
      'defaultScanPasses': defaultScanPasses,
      'defaultBackendPreference': defaultBackendPreference.name,
      'includeHiddenSsids': includeHiddenSsids,
      'strictSafetyMode': strictSafetyMode,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final backendName = json['defaultBackendPreference'] as String?;

    return AppSettings(
      scanIntervalSeconds: _readInt(json['scanIntervalSeconds'], fallback: 5),
      defaultScanPasses: _readInt(json['defaultScanPasses'], fallback: 3),
      defaultBackendPreference: _parseBackendPreference(backendName),
      includeHiddenSsids: _readBool(json['includeHiddenSsids'], fallback: true),
      strictSafetyMode: _readBool(json['strictSafetyMode'], fallback: true),
    );
  }

  static int _readInt(Object? raw, {required int fallback}) {
    return switch (raw) {
      final int value => value,
      final num value => value.round(),
      _ => fallback,
    };
  }

  static bool _readBool(Object? raw, {required bool fallback}) {
    return raw is bool ? raw : fallback;
  }

  static WifiBackendPreference _parseBackendPreference(String? name) {
    for (final value in WifiBackendPreference.values) {
      if (value.name == name) {
        return value;
      }
    }
    return WifiBackendPreference.auto;
  }
}
