import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/wifi_network.dart';
import '../repositories/wifi_repository.dart';

@lazySingleton
class ScanWifi {
  final WifiRepository repository;

  ScanWifi(this.repository);

  Future<Either<Failure, List<WifiNetwork>>> call() {
    return repository.scanNetworks();
  }
}
