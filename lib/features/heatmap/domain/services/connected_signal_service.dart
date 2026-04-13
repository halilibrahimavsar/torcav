import 'package:injectable/injectable.dart';

import 'package:torcav/core/platform/wifi_extended_channel.dart';
import 'package:torcav/features/heatmap/domain/entities/connected_signal.dart';

abstract class ConnectedSignalService {
  Future<ConnectedSignal?> getConnectedSignal();
}

@LazySingleton(as: ConnectedSignalService)
class ConnectedSignalServiceImpl implements ConnectedSignalService {
  @override
  Future<ConnectedSignal?> getConnectedSignal() async {
    return WifiExtendedChannel.getConnectedSignal();
  }
}
