import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/host_scan_result.dart';
import '../entities/network_device.dart';
import '../entities/network_scan_profile.dart';

abstract class NetworkScanRepository {
  Future<Either<Failure, List<NetworkDevice>>> scanNetwork(String subnet);
  Future<Either<Failure, List<HostScanResult>>> scanWithProfile(
    String target, {
    NetworkScanProfile profile,
    PortScanMethod method,
  });
}
