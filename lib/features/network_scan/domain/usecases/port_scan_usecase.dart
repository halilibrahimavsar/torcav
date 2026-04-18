import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/service_fingerprint.dart';
import '../repositories/port_scan_repository.dart';

/// UseCase to perform an active TCP port scan against a specified IP address.
@injectable
class PortScanUseCase {
  final PortScanRepository _repository;

  PortScanUseCase(this._repository);

  Future<Either<Failure, List<ServiceFingerprint>>> call(String ip) async {
    return _repository.scanPorts(ip);
  }

  Stream<ServiceFingerprint> callReactive(
    String ip, {
    Duration timeout = const Duration(milliseconds: 500),
  }) {
    return _repository.scanPortsReactive(ip, timeout: timeout);
  }
}
