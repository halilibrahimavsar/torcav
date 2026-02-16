import '../../domain/entities/wifi_network.dart';

abstract class WifiDataSource {
  Future<List<WifiNetwork>> scanNetworks();
}
