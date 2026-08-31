import '../../../../core/l10n/app_localizations.dart';
import '../../domain/entities/user_data_category.dart';

/// Resolves [UserDataCategory.labelKey].
///
/// The category name is interpolated into already-translated sentences, so an
/// English name produced a half-translated line: "Henüz veri yok: Wi-Fi scan
/// history".
class DataCategoryLabels {
  const DataCategoryLabels._();

  static String resolve(AppLocalizations l10n, UserDataCategory category) =>
      switch (category.labelKey) {
        'dataCatWifiScanHistory' => l10n.dataCatWifiScanHistory,
        'dataCatSpeedTests' => l10n.dataCatSpeedTests,
        'dataCatSecurityEvents' => l10n.dataCatSecurityEvents,
        'dataCatKnownNetworks' => l10n.dataCatKnownNetworks,
        'dataCatChannelRatings' => l10n.dataCatChannelRatings,
        'dataCatHeatmapSessions' => l10n.dataCatHeatmapSessions,
        'dataCatLanScan' => l10n.dataCatLanScan,
        'dataCatDeviceLabels' => l10n.dataCatDeviceLabels,
        'dataCatPinnedNetworks' => l10n.dataCatPinnedNetworks,
        'dataCatScoreHistory' => l10n.dataCatScoreHistory,
        'dataCatNetworkContexts' => l10n.dataCatNetworkContexts,
        'dataCatRouterHardening' => l10n.dataCatRouterHardening,
        _ => category.labelKey,
      };
}
