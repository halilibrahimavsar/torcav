import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/stabilization_profile.dart';
import '../repositories/ping_stabilizer_repository.dart';

@lazySingleton
class ListProfilesUseCase {
  final PingStabilizerRepository _repository;

  const ListProfilesUseCase(this._repository);

  Future<Either<Failure, List<StabilizationProfile>>> call() =>
      _repository.listProfiles();
}
