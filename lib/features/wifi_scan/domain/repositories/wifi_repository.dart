import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/wifi_network.dart';

abstract class WifiRepository {
  Future<Either<Failure, List<WifiNetwork>>> scanNetworks();
}
