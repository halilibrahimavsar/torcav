import 'package:equatable/equatable.dart';

import '../../../wifi_scan/domain/entities/scan_request.dart';

class AppSettings extends Equatable {
  final int scanIntervalSeconds;
  final int defaultScanPasses;
  final WifiBackendPreference defaultBackendPreference;
  final bool includeHiddenSsids;
  final bool strictSafetyMode;
  final bool autoScanEnabled;
  final bool isDeepScanEnabled;
  /// Timeout in milliseconds for each port probe during LAN scanning.
  /// Lower values are faster but may miss open ports on slow networks.
  final int portScanTimeoutMs;

  const AppSettings({
    this.scanIntervalSeconds = 30,
    this.defaultScanPasses = 3,
    this.defaultBackendPreference = WifiBackendPreference.auto,
    this.includeHiddenSsids = false,
    this.strictSafetyMode = true,
    this.autoScanEnabled = false,
    this.isDeepScanEnabled = false,
    this.portScanTimeoutMs = 500,
  });

  AppSettings copyWith({
    int? scanIntervalSeconds,
    int? defaultScanPasses,
    WifiBackendPreference? defaultBackendPreference,
    bool? includeHiddenSsids,
    bool? strictSafetyMode,
    bool? autoScanEnabled,
    bool? isDeepScanEnabled,
    int? portScanTimeoutMs,
  }) {
    return AppSettings(
      scanIntervalSeconds: scanIntervalSeconds ?? this.scanIntervalSeconds,
      defaultScanPasses: defaultScanPasses ?? this.defaultScanPasses,
      defaultBackendPreference:
          defaultBackendPreference ?? this.defaultBackendPreference,
      includeHiddenSsids: includeHiddenSsids ?? this.includeHiddenSsids,
      strictSafetyMode: strictSafetyMode ?? this.strictSafetyMode,
      autoScanEnabled: autoScanEnabled ?? this.autoScanEnabled,
      isDeepScanEnabled: isDeepScanEnabled ?? this.isDeepScanEnabled,
      portScanTimeoutMs: portScanTimeoutMs ?? this.portScanTimeoutMs,
    );
  }

  @override
  List<Object?> get props => [
    scanIntervalSeconds,
    defaultScanPasses,
    defaultBackendPreference,
    includeHiddenSsids,
    strictSafetyMode,
    autoScanEnabled,
    isDeepScanEnabled,
    portScanTimeoutMs,
  ];

  Map<String, dynamic> toJson() {
    return {
      'scanIntervalSeconds': scanIntervalSeconds,
      'defaultScanPasses': defaultScanPasses,
      'defaultBackendPreference': defaultBackendPreference.name,
      'includeHiddenSsids': includeHiddenSsids,
      'strictSafetyMode': strictSafetyMode,
      'autoScanEnabled': autoScanEnabled,
      'isDeepScanEnabled': isDeepScanEnabled,
      'portScanTimeoutMs': portScanTimeoutMs,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final backendName = json['defaultBackendPreference'] as String?;

    return AppSettings(
      scanIntervalSeconds: _readInt(json['scanIntervalSeconds'], fallback: 30),
      defaultScanPasses: _readInt(json['defaultScanPasses'], fallback: 3),
      defaultBackendPreference: _parseBackendPreference(backendName),
      includeHiddenSsids: _readBool(json['includeHiddenSsids'], fallback: false),
      strictSafetyMode: _readBool(json['strictSafetyMode'], fallback: true),
      autoScanEnabled: _readBool(json['autoScanEnabled'], fallback: false),
      isDeepScanEnabled: _readBool(json['isDeepScanEnabled'], fallback: false),
      portScanTimeoutMs: _readInt(json['portScanTimeoutMs'], fallback: 500),
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
