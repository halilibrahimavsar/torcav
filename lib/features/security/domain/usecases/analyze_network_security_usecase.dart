import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import 'package:torcav/core/errors/failures.dart';
import '../entities/security_event.dart';
import '../repositories/security_repository.dart';
import 'package:torcav/features/wifi_scan/domain/entities/wifi_network.dart';

@lazySingleton
class AnalyzeNetworkSecurityUseCase {
  final SecurityRepository _repository;

  AnalyzeNetworkSecurityUseCase(this._repository);

  Future<Either<Failure, List<SecurityEvent>>> call(
    List<WifiNetwork> networks, {
    bool isDeepScan = false,
  }) {
    return _repository.analyzeNetworks(networks, isDeepScan: isDeepScan);
  }
}
