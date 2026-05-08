import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/dns_candidate.dart';
import '../repositories/ping_stabilizer_repository.dart';

@lazySingleton
class ApplyDnsUseCase {
  final PingStabilizerRepository _repository;

  const ApplyDnsUseCase(this._repository);

  Future<Either<Failure, void>> call(DnsCandidate candidate) =>
      _repository.setActiveDns(candidate);
}
