import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/dns_candidate.dart';
import '../repositories/ping_stabilizer_repository.dart';

@lazySingleton
class BenchmarkDnsUseCase {
  final PingStabilizerRepository _repository;

  const BenchmarkDnsUseCase(this._repository);

  Future<Either<Failure, List<DnsCandidate>>> call({
    List<DnsCandidate>? candidates,
  }) {
    final list = candidates ?? DnsCandidate.defaults;
    return _repository.benchmarkDns(list);
  }

  /// Pure ranking helper (deterministic, easily unit-testable).
  static List<DnsCandidate> rank(List<DnsCandidate> input) {
    final ranked = List<DnsCandidate>.from(input);
    ranked.sort((a, b) {
      final aRtt = a.lastRttMs ?? double.infinity;
      final bRtt = b.lastRttMs ?? double.infinity;
      return aRtt.compareTo(bRtt);
    });
    return ranked;
  }
}
