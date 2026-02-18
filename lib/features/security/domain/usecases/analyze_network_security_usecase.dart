import 'package:injectable/injectable.dart';
import '../entities/security_event.dart';
import '../repositories/security_repository.dart';
import 'package:torcav/features/wifi_scan/domain/entities/wifi_network.dart';

@lazySingleton
class AnalyzeNetworkSecurityUseCase {
  final SecurityRepository _repository;

  AnalyzeNetworkSecurityUseCase(this._repository);

  Future<List<SecurityEvent>> call(List<WifiNetwork> networks) {
    return _repository.analyzeNetworks(networks);
  }
}
