import 'package:flutter/material.dart';

/// Every category of locally-stored user data the app exposes for export.
///
/// The label/icon getters power a generic dropdown in the export UI without
/// the widget needing to know about underlying storage.
enum UserDataCategory {
  wifiScanHistory,
  speedTestResults,
  securityEvents,
  knownAndTrustedNetworks,
  channelRatingsHistory,
  heatmapSessions,
  lanScanLatest,
  deviceLabelOverrides,
  pinnedNetworks,
  scoreHistory,
  networkContextOverrides,
  routerHardeningProgress,
}

extension UserDataCategoryX on UserDataCategory {
  /// Localization key for the category name.
  ///
  /// A key rather than the English name: it was being interpolated into an
  /// already-translated sentence, so a Turkish user read
  /// "Henüz veri yok: Wi-Fi scan history" — half translated, half not.
  String get labelKey => switch (this) {
    UserDataCategory.wifiScanHistory => 'dataCatWifiScanHistory',
    UserDataCategory.speedTestResults => 'dataCatSpeedTests',
    UserDataCategory.securityEvents => 'dataCatSecurityEvents',
    UserDataCategory.knownAndTrustedNetworks => 'dataCatKnownNetworks',
    UserDataCategory.channelRatingsHistory => 'dataCatChannelRatings',
    UserDataCategory.heatmapSessions => 'dataCatHeatmapSessions',
    UserDataCategory.lanScanLatest => 'dataCatLanScan',
    UserDataCategory.deviceLabelOverrides => 'dataCatDeviceLabels',
    UserDataCategory.pinnedNetworks => 'dataCatPinnedNetworks',
    UserDataCategory.scoreHistory => 'dataCatScoreHistory',
    UserDataCategory.networkContextOverrides => 'dataCatNetworkContexts',
    UserDataCategory.routerHardeningProgress => 'dataCatRouterHardening',
  };

  /// Stable JSON key used in the composite ("All categories") export and as
  /// the per-category top-level key. Keep in `snake_case`.
  String get jsonKey => switch (this) {
    UserDataCategory.wifiScanHistory => 'wifi_scan_history',
    UserDataCategory.speedTestResults => 'speed_test_results',
    UserDataCategory.securityEvents => 'security_events',
    UserDataCategory.knownAndTrustedNetworks => 'known_and_trusted_networks',
    UserDataCategory.channelRatingsHistory => 'channel_ratings_history',
    UserDataCategory.heatmapSessions => 'heatmap_sessions',
    UserDataCategory.lanScanLatest => 'lan_scan_latest',
    UserDataCategory.deviceLabelOverrides => 'device_label_overrides',
    UserDataCategory.pinnedNetworks => 'pinned_networks',
    UserDataCategory.scoreHistory => 'security_score_history',
    UserDataCategory.networkContextOverrides => 'network_context_overrides',
    UserDataCategory.routerHardeningProgress => 'router_hardening_progress',
  };

  IconData get icon => switch (this) {
    UserDataCategory.wifiScanHistory => Icons.wifi_rounded,
    UserDataCategory.speedTestResults => Icons.speed_rounded,
    UserDataCategory.securityEvents => Icons.gpp_maybe_rounded,
    UserDataCategory.knownAndTrustedNetworks => Icons.verified_user_rounded,
    UserDataCategory.channelRatingsHistory => Icons.tune_rounded,
    UserDataCategory.heatmapSessions => Icons.map_rounded,
    UserDataCategory.lanScanLatest => Icons.lan_rounded,
    UserDataCategory.deviceLabelOverrides => Icons.devices_rounded,
    UserDataCategory.pinnedNetworks => Icons.push_pin_rounded,
    UserDataCategory.scoreHistory => Icons.bar_chart_rounded,
    UserDataCategory.networkContextOverrides => Icons.public_rounded,
    UserDataCategory.routerHardeningProgress => Icons.shield_moon_rounded,
  };

  /// True if the category contains identifiers (BSSID/SSID/MAC) that should
  /// be masked when the user requests anonymisation.
  bool get carriesIdentifiers => switch (this) {
    UserDataCategory.wifiScanHistory => true,
    UserDataCategory.securityEvents => true,
    UserDataCategory.knownAndTrustedNetworks => true,
    UserDataCategory.heatmapSessions => true,
    UserDataCategory.lanScanLatest => true,
    UserDataCategory.deviceLabelOverrides => true,
    UserDataCategory.pinnedNetworks => true,
    UserDataCategory.networkContextOverrides => true,
    UserDataCategory.routerHardeningProgress => true,
    UserDataCategory.speedTestResults => false,
    UserDataCategory.channelRatingsHistory => false,
    UserDataCategory.scoreHistory => false,
  };
}
