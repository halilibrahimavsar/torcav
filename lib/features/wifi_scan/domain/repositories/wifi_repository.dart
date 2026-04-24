import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/scan_request.dart';
import '../entities/scan_snapshot.dart';
import '../entities/wifi_network.dart';

abstract class WifiRepository {
  Future<Either<Failure, List<WifiNetwork>>> scanNetworks();
  Future<Either<Failure, ScanSnapshot>> scanSnapshot(ScanRequest request);
}
