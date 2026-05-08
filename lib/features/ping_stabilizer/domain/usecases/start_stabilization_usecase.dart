import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/stabilization_profile.dart';
import '../entities/stabilization_session.dart';
import '../repositories/ping_stabilizer_repository.dart';

@lazySingleton
class StartStabilizationUseCase {
  final PingStabilizerRepository _repository;

  const StartStabilizationUseCase(this._repository);

  Future<Either<Failure, StabilizationSession>> call(
    StabilizationProfile profile,
  ) async {
    final prepared = await _repository.isVpnPrepared();
    final ok = prepared.getOrElse(() => false);
    if (!ok) {
      final granted = await _repository.requestVpnPermission();
      final wasGranted = granted.getOrElse(() => false);
      if (!wasGranted) {
        return const Left(PermissionFailure('VPN permission denied.'));
      }
    }
    return _repository.start(profile);
  }
}
