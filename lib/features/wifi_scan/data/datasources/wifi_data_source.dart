import '../../domain/entities/scan_request.dart';
import '../../domain/entities/scan_snapshot.dart';
import '../../domain/entities/wifi_network.dart';

abstract class WifiDataSource {
  Future<ScanSnapshot> scanSnapshot(ScanRequest request);

  Future<List<WifiNetwork>> scanNetworks({ScanRequest? request}) async {
    final snapshot = await scanSnapshot(request ?? const ScanRequest());
    return snapshot.toLegacyNetworks();
  }
}
