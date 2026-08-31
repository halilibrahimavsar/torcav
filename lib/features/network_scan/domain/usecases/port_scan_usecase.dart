import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/network_scan_policy.dart';
import '../entities/service_fingerprint.dart';
import '../entities/port_scan_event.dart';
import '../repositories/port_scan_repository.dart';

/// Active TCP port scan against one host.
///
/// Refuses any target outside private address space. CLAUDE.md's passivity
/// exception covers diagnostics the user starts *on their own network*, and
/// today the UI only ever passes hosts found by LAN discovery — but the
/// guarantee belongs here, not in the assumption that every future caller
/// will remember it.
@injectable
class PortScanUseCase {
  final PortScanRepository _repository;

  PortScanUseCase(this._repository);

  Future<Either<Failure, List<ServiceFingerprint>>> call(String ip) async {
    if (!NetworkScanPolicy.isPrivateAddress(ip)) {
      return const Left(
        SecurityFailure(
          'Refusing to port-scan a non-private address',
          messageKey: 'failureScanTargetNotLocal',
        ),
      );
    }
    return _repository.scanPorts(ip);
  }

  Stream<PortScanEvent> callReactive(
    String ip, {
    List<int>? ports,
    Duration timeout = const Duration(milliseconds: 500),
  }) {
    if (!NetworkScanPolicy.isPrivateAddress(ip)) {
      return const Stream.empty();
    }
    return _repository.scanPortsReactive(ip, ports: ports, timeout: timeout);
  }
}
