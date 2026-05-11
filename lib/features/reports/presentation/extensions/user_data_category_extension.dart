import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/entities/user_data_category.dart';

extension UserDataCategoryPresentationX on UserDataCategory {
  String localizedLabel(BuildContext context) {
    final l10n = context.l10n;
    switch (this) {
      case UserDataCategory.wifiScanHistory:
        return l10n.categoryWifiScanHistory;
      case UserDataCategory.speedTestResults:
        return l10n.categorySpeedTestResults;
      case UserDataCategory.securityEvents:
        return l10n.categorySecurityEvents;
      case UserDataCategory.knownAndTrustedNetworks:
        return l10n.categoryKnownAndTrustedNetworks;
      case UserDataCategory.channelRatingsHistory:
        return l10n.categoryChannelRatingsHistory;
      case UserDataCategory.heatmapSessions:
        return l10n.categoryHeatmapSessions;
      case UserDataCategory.lanScanLatest:
        return l10n.categoryLanScanLatest;
      case UserDataCategory.deviceLabelOverrides:
        return l10n.categoryDeviceLabelOverrides;
      case UserDataCategory.pinnedNetworks:
        return l10n.categoryPinnedNetworks;
      case UserDataCategory.scoreHistory:
        return l10n.categoryScoreHistory;
      case UserDataCategory.networkContextOverrides:
        return l10n.categoryNetworkContextOverrides;
      case UserDataCategory.routerHardeningProgress:
        return l10n.categoryRouterHardeningProgress;
    }
  }
}
