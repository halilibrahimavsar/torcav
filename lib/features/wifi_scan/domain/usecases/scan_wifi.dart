import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/scan_request.dart';
import '../entities/scan_snapshot.dart';
import '../repositories/wifi_repository.dart';

@lazySingleton
class ScanWifi {
  final WifiRepository repository;

  ScanWifi(this.repository);

  Future<Either<Failure, ScanSnapshot>> call({
    ScanRequest request = const ScanRequest(),
  }) {
    return repository.scanSnapshot(request);
  }
}
