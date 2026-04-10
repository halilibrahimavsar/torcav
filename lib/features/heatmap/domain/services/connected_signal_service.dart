import 'package:injectable/injectable.dart';

import '../../../../core/platform/wifi_extended_channel.dart';
import '../entities/connected_signal.dart';

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
