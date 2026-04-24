import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/service_fingerprint.dart';
import '../../domain/entities/port_scan_event.dart';

abstract class PortScanRepository {
  Future<Either<Failure, List<ServiceFingerprint>>> scanPorts(String ip);

  /// Streams discovered services and scan progress in real-time.
  Stream<PortScanEvent> scanPortsReactive(
    String ip, {
    List<int>? ports,
    Duration timeout = const Duration(milliseconds: 500),
  });
}
