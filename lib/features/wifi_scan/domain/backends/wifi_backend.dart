import '../entities/scan_request.dart';
import '../entities/wifi_network.dart';

class BackendCapabilities {
  final String backendName;
  final bool supportsHiddenScan;
  final bool requiresPrivileges;
  final bool supportsRealtimeDbm;

  const BackendCapabilities({
    required this.backendName,
    required this.supportsHiddenScan,
    required this.requiresPrivileges,
    required this.supportsRealtimeDbm,
  });
}

class BackendScanResult {
  final String backendName;
  final List<WifiNetwork> networks;

  const BackendScanResult({required this.backendName, required this.networks});
}

abstract class WifiBackend {
  Future<BackendScanResult> scan({
    required String interfaceName,
    required ScanRequest request,
  });

  Future<BackendCapabilities> capabilities();
}
