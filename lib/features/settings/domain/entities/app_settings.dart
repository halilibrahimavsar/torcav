import 'package:equatable/equatable.dart';

import '../../../security/domain/entities/network_context_type.dart';
import '../../../wifi_scan/domain/entities/scan_request.dart';

enum AppBackgroundType {
  neomorphic,
  classic,
  auroraMesh,
  holoSphere,
  neuralPulse,
  aegisShield,
  signalTopography,
  quantumMesh,
}

class AppSettings extends Equatable {
  final int scanIntervalSeconds;
  final int defaultScanPasses;
  final WifiBackendPreference defaultBackendPreference;
  final bool includeHiddenSsids;
  final bool strictSafetyMode;
  final bool autoScanEnabled;
  final bool isDeepScanEnabled;

  /// When `true`, deep scan is automatically suppressed on networks resolved
  /// to a `public` or `guest` context. Active probing on networks the user
  /// does not own is the dominant legal/ethical risk; this default-on guard
  /// prevents accidental aggressive scans at cafés, hotels, etc.
  final bool restrictDeepScanOnPublic;

  /// Timeout in milliseconds for each port probe during LAN scanning.
  /// Lower values are faster but may miss open ports on slow networks.
  final int portScanTimeoutMs;
  final bool isAiEnabled;
  final AppBackgroundType backgroundType;

  /// Data retention periods in days (0 = keep forever).
  final int scanHistoryRetentionDays;
  final int speedTestRetentionDays;
  final int securityEventRetentionDays;

  /// User's declared default trust posture for unknown networks. Set during
  /// onboarding and used by [NetworkContextResolver] as a fallback when the
  /// inferrer can't classify a network on its own.
  final NetworkContextType defaultNetworkContext;

  /// When true, the platform's background monitoring service runs while
  /// the app is closed. Off by default — opt-in to keep battery + privacy
  /// posture conservative.
  final bool backgroundMonitoringEnabled;

  /// Download speed (Mbps) the user's ISP plan promises ("taahhüt hızı").
  /// Null until the user declares it; drives the paying-vs-getting
  /// comparison in the Speed hub.
  final double? planDownloadMbps;

  /// When true, a WorkManager probe measures download speed roughly twice
  /// a day on unmetered networks, feeding the plan-comparison trend.
  /// Off by default — opt-in, like every background behavior.
  final bool scheduledSpeedTestEnabled;

  const AppSettings({
    this.scanIntervalSeconds = 30,
    this.defaultScanPasses = 3,
    this.defaultBackendPreference = WifiBackendPreference.auto,
    this.includeHiddenSsids = false,
    this.strictSafetyMode = true,
    this.autoScanEnabled = false,
    this.isDeepScanEnabled = false,
    this.restrictDeepScanOnPublic = true,
    this.portScanTimeoutMs = 500,
    this.isAiEnabled = true,
    this.backgroundType = AppBackgroundType.aegisShield,
    this.scanHistoryRetentionDays = 30,
    this.speedTestRetentionDays = 30,
    this.securityEventRetentionDays = 30,
    this.defaultNetworkContext = NetworkContextType.unknown,
    this.backgroundMonitoringEnabled = false,
    this.planDownloadMbps,
    this.scheduledSpeedTestEnabled = false,
  });

  AppSettings copyWith({
    int? scanIntervalSeconds,
    int? defaultScanPasses,
    WifiBackendPreference? defaultBackendPreference,
    bool? includeHiddenSsids,
    bool? strictSafetyMode,
    bool? autoScanEnabled,
    bool? isDeepScanEnabled,
    bool? restrictDeepScanOnPublic,
    int? portScanTimeoutMs,
    bool? isAiEnabled,
    AppBackgroundType? backgroundType,
    int? scanHistoryRetentionDays,
    int? speedTestRetentionDays,
    int? securityEventRetentionDays,
    NetworkContextType? defaultNetworkContext,
    bool? backgroundMonitoringEnabled,
    double? planDownloadMbps,
    bool clearPlanDownloadMbps = false,
    bool? scheduledSpeedTestEnabled,
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
      restrictDeepScanOnPublic:
          restrictDeepScanOnPublic ?? this.restrictDeepScanOnPublic,
      portScanTimeoutMs: portScanTimeoutMs ?? this.portScanTimeoutMs,
      isAiEnabled: isAiEnabled ?? this.isAiEnabled,
      backgroundType: backgroundType ?? this.backgroundType,
      scanHistoryRetentionDays:
          scanHistoryRetentionDays ?? this.scanHistoryRetentionDays,
      speedTestRetentionDays:
          speedTestRetentionDays ?? this.speedTestRetentionDays,
      securityEventRetentionDays:
          securityEventRetentionDays ?? this.securityEventRetentionDays,
      defaultNetworkContext:
          defaultNetworkContext ?? this.defaultNetworkContext,
      backgroundMonitoringEnabled:
          backgroundMonitoringEnabled ?? this.backgroundMonitoringEnabled,
      planDownloadMbps:
          clearPlanDownloadMbps
              ? null
              : (planDownloadMbps ?? this.planDownloadMbps),
      scheduledSpeedTestEnabled:
          scheduledSpeedTestEnabled ?? this.scheduledSpeedTestEnabled,
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
    restrictDeepScanOnPublic,
    portScanTimeoutMs,
    isAiEnabled,
    backgroundType,
    scanHistoryRetentionDays,
    speedTestRetentionDays,
    securityEventRetentionDays,
    defaultNetworkContext,
    backgroundMonitoringEnabled,
    planDownloadMbps,
    scheduledSpeedTestEnabled,
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
      'restrictDeepScanOnPublic': restrictDeepScanOnPublic,
      'portScanTimeoutMs': portScanTimeoutMs,
      'isAiEnabled': isAiEnabled,
      'backgroundType': backgroundType.name,
      'scanHistoryRetentionDays': scanHistoryRetentionDays,
      'speedTestRetentionDays': speedTestRetentionDays,
      'securityEventRetentionDays': securityEventRetentionDays,
      'defaultNetworkContext': defaultNetworkContext.name,
      'backgroundMonitoringEnabled': backgroundMonitoringEnabled,
      'planDownloadMbps': planDownloadMbps,
      'scheduledSpeedTestEnabled': scheduledSpeedTestEnabled,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final backendName = json['defaultBackendPreference'] as String?;
    final bgTypeName = json['backgroundType'] as String?;

    return AppSettings(
      scanIntervalSeconds: _readInt(json['scanIntervalSeconds'], fallback: 30),
      defaultScanPasses: _readInt(json['defaultScanPasses'], fallback: 3),
      defaultBackendPreference: _parseBackendPreference(backendName),
      includeHiddenSsids: _readBool(
        json['includeHiddenSsids'],
        fallback: false,
      ),
      strictSafetyMode: _readBool(json['strictSafetyMode'], fallback: true),
      autoScanEnabled: _readBool(json['autoScanEnabled'], fallback: false),
      isDeepScanEnabled: _readBool(json['isDeepScanEnabled'], fallback: false),
      restrictDeepScanOnPublic: _readBool(
        json['restrictDeepScanOnPublic'],
        fallback: true,
      ),
      portScanTimeoutMs: _readInt(json['portScanTimeoutMs'], fallback: 500),
      isAiEnabled: _readBool(json['isAiEnabled'], fallback: true),
      backgroundType: _parseBackgroundType(bgTypeName),
      scanHistoryRetentionDays: _readInt(
        json['scanHistoryRetentionDays'],
        fallback: 30,
      ),
      speedTestRetentionDays: _readInt(
        json['speedTestRetentionDays'],
        fallback: 30,
      ),
      securityEventRetentionDays: _readInt(
        json['securityEventRetentionDays'],
        fallback: 30,
      ),
      defaultNetworkContext: _parseNetworkContext(
        json['defaultNetworkContext'] as String?,
      ),
      backgroundMonitoringEnabled: _readBool(
        json['backgroundMonitoringEnabled'],
        fallback: false,
      ),
      planDownloadMbps: _readDoubleOrNull(json['planDownloadMbps']),
      scheduledSpeedTestEnabled: _readBool(
        json['scheduledSpeedTestEnabled'],
        fallback: false,
      ),
    );
  }

  static double? _readDoubleOrNull(Object? raw) {
    return switch (raw) {
      final num value when value > 0 => value.toDouble(),
      _ => null,
    };
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

  static AppBackgroundType _parseBackgroundType(String? name) {
    for (final value in AppBackgroundType.values) {
      if (value.name == name) {
        return value;
      }
    }
    return AppBackgroundType.aegisShield;
  }

  static NetworkContextType _parseNetworkContext(String? name) {
    for (final value in NetworkContextType.values) {
      if (value.name == name) {
        return value;
      }
    }
    return NetworkContextType.unknown;
  }
}
