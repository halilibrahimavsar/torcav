import 'package:injectable/injectable.dart';

import '../entities/speed_test_progress.dart';
import '../repositories/speed_test_repository.dart';

@lazySingleton
class RunSpeedTestUseCase {
  final SpeedTestRepository _repository;

  RunSpeedTestUseCase(this._repository);

  Stream<SpeedTestProgress> call() {
    return _repository.runSpeedTest();
  }
}
