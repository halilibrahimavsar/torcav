import 'package:injectable/injectable.dart';

import '../entities/security_event.dart';
import '../repositories/active_security_repository.dart';

@lazySingleton
class RunActiveDefenseCheckUseCase {
  final ActiveSecurityRepository _repository;

  RunActiveDefenseCheckUseCase(this._repository);

  Future<SecurityEvent> call({
    required String ssid,
    required String bssid,
    required String interfaceName,
  }) {
    return _repository.runActiveDefenseCheck(
      ssid: ssid,
      bssid: bssid,
      interfaceName: interfaceName,
    );
  }
}
