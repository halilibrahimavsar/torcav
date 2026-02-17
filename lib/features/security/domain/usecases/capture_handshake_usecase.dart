import 'package:injectable/injectable.dart';

import '../entities/security_event.dart';
import '../repositories/active_security_repository.dart';

@lazySingleton
class CaptureHandshakeUseCase {
  final ActiveSecurityRepository _repository;

  CaptureHandshakeUseCase(this._repository);

  Future<SecurityEvent> call({
    required String ssid,
    required String bssid,
    required int channel,
    required String interfaceName,
  }) {
    return _repository.captureHandshake(
      ssid: ssid,
      bssid: bssid,
      channel: channel,
      interfaceName: interfaceName,
    );
  }
}
