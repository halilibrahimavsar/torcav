import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/platform/wifi_extended_channel.dart';
import '../../../heatmap/domain/entities/connected_signal.dart';
import '../../domain/entities/cellular_status.dart';

/// One-shot snapshots of both link types for the comparison card.
///
/// Wraps the static [WifiExtendedChannel] plus the `torcav/cellular`
/// method channel behind an injectable seam so the cubit stays testable.
@lazySingleton
class ConnectionSnapshotService {
  static const _cellular = MethodChannel('torcav/cellular');

  Future<CellularStatus> cellular() async {
    try {
      final raw = await _cellular.invokeMethod<Map<Object?, Object?>>(
        'getStatus',
      );
      if (raw == null) return CellularStatus.unavailable;
      return CellularStatus(
        operatorName: raw['operator'] as String?,
        generation: raw['generation'] as String?,
        dbm: (raw['dbm'] as num?)?.toInt(),
        level: (raw['level'] as num?)?.toInt(),
        mobileDataActive: raw['mobileDataActive'] == true,
        downKbps: (raw['downKbps'] as num?)?.toInt(),
        upKbps: (raw['upKbps'] as num?)?.toInt(),
        permissionMissing: raw['permissionMissing'] == true,
      );
    } on PlatformException {
      return CellularStatus.unavailable;
    } on MissingPluginException {
      // iOS/desktop: no native impl — the card renders its N/A state.
      return CellularStatus.unavailable;
    }
  }

  Future<ConnectedSignal?> wifi() => WifiExtendedChannel.getConnectedSignal();
}
