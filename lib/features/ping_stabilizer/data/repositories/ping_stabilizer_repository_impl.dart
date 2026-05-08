import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/dns_candidate.dart';
import '../../domain/entities/jitter_sample.dart';
import '../../domain/entities/stabilization_profile.dart';
import '../../domain/entities/stabilization_session.dart';
import '../../domain/repositories/ping_stabilizer_repository.dart';
import '../datasources/ping_stabilizer_channel.dart';

@LazySingleton(as: PingStabilizerRepository)
class PingStabilizerRepositoryImpl implements PingStabilizerRepository {
  final PingStabilizerChannel _channel;
  final _uuid = const Uuid();

  // Custom profiles persisted in-memory for v1; settings UI can swap this for
  // the existing storage layer later without touching the domain contract.
  final List<StabilizationProfile> _customProfiles = [];

  PingStabilizerRepositoryImpl(this._channel);

  @override
  Future<Either<Failure, bool>> isVpnPrepared() async {
    try {
      return Right(await _channel.isPrepared());
    } catch (e) {
      return Left(PermissionFailure('Could not query VPN state: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> requestVpnPermission() async {
    try {
      return Right(await _channel.requestPermission());
    } catch (e) {
      return Left(PermissionFailure('VPN consent flow failed: $e'));
    }
  }

  @override
  Future<Either<Failure, StabilizationSession>> start(
    StabilizationProfile profile,
  ) async {
    try {
      final ok = await _channel.start(profile);
      if (!ok) {
        return const Left(
          ServerFailure('Native VPN service refused to start.'),
        );
      }
      return Right(
        StabilizationSession(
          id: _uuid.v4(),
          startedAt: DateTime.now(),
          profile: profile,
        ),
      );
    } catch (e) {
      return Left(ServerFailure('Failed to start tunnel: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> stop() async {
    try {
      await _channel.stop();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to stop tunnel: $e'));
    }
  }

  @override
  Stream<JitterSample> observeSamples() => _channel.samples();

  @override
  Future<Either<Failure, List<DnsCandidate>>> benchmarkDns(
    List<DnsCandidate> candidates,
  ) async {
    try {
      return Right(await _channel.benchmarkDns(candidates));
    } catch (e) {
      return Left(ServerFailure('DNS benchmark failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setActiveDns(DnsCandidate candidate) async {
    try {
      await _channel.setDns(candidate.ip);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('DNS update rejected: $e'));
    }
  }

  @override
  Future<Either<Failure, List<StabilizationProfile>>> listProfiles() async {
    final all = [...StabilizationProfile.builtIns(), ..._customProfiles];
    return Right(all);
  }

  @override
  Future<Either<Failure, void>> upsertProfile(
    StabilizationProfile profile,
  ) async {
    final idx = _customProfiles.indexWhere((p) => p.id == profile.id);
    if (idx >= 0) {
      _customProfiles[idx] = profile;
    } else {
      _customProfiles.add(profile);
    }
    return const Right(null);
  }
}
