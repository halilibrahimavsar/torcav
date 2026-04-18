import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/service_fingerprint.dart';

abstract class PortScanRepository {
  Future<Either<Failure, List<ServiceFingerprint>>> scanPorts(String ip);

  /// Streams discovered services in real-time.
  Stream<ServiceFingerprint> scanPortsReactive(
    String ip, {
    Duration timeout = const Duration(milliseconds: 500),
  });
}
