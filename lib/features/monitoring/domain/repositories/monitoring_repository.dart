import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../features/wifi_scan/domain/entities/wifi_network.dart';

abstract class MonitoringRepository {
  Stream<Either<Failure, List<WifiNetwork>>> monitorNetworks({
    Duration interval,
  });
  Stream<Either<Failure, WifiNetwork>> monitorNetwork(
    String bssid, {
    Duration interval,
  });
}
