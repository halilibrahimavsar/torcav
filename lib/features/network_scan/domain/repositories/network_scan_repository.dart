import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/network_device.dart';

abstract class NetworkScanRepository {
  Future<Either<Failure, List<NetworkDevice>>> scanNetwork(String subnet);
}
