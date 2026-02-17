import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/bandwidth_sample.dart';
import '../../../../features/wifi_scan/domain/entities/wifi_network.dart';

abstract class MonitoringRepository {
  Stream<Either<Failure, List<WifiNetwork>>> monitorNetworks({
    Duration interval,
  });
  Stream<Either<Failure, WifiNetwork>> monitorNetwork(
    String bssid, {
    Duration interval,
  });

  Stream<Either<Failure, BandwidthSample>> monitorBandwidth(
    String interfaceName, {
    Duration interval,
  });
}
