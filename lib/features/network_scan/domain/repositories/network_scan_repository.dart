import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/host_scan_result.dart';
import '../entities/network_device.dart';
import '../entities/network_scan_profile.dart';

abstract class NetworkScanRepository {
  Stream<Either<Failure, List<NetworkDevice>>> scanNetwork(String subnet);
  Stream<Either<Failure, HostScanResult>> scanWithProfile(
    String target, {
    NetworkScanProfile profile = NetworkScanProfile.fast,
    PortScanMethod method = PortScanMethod.auto,
  });
}
