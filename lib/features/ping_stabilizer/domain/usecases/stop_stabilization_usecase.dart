import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/ping_stabilizer_repository.dart';

@lazySingleton
class StopStabilizationUseCase {
  final PingStabilizerRepository _repository;

  const StopStabilizationUseCase(this._repository);

  Future<Either<Failure, void>> call() => _repository.stop();
}
