import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:torcav/core/errors/failures.dart';
import 'package:torcav/features/monitoring/domain/entities/network_topology.dart';
import 'package:torcav/features/monitoring/domain/repositories/topology_repository.dart';
import 'package:torcav/features/monitoring/domain/usecases/get_topology_usecase.dart';
import 'package:torcav/features/monitoring/domain/usecases/ping_node_usecase.dart';

class _MockTopologyRepository extends Mock implements TopologyRepository {}

void main() {
  late _MockTopologyRepository repo;

  setUp(() {
    repo = _MockTopologyRepository();
  });

  group('GetTopologyUseCase', () {
    test('delegates to repository.getTopologyStream', () async {
      final topology = NetworkTopology(
        nodes: const [],
        edges: const [],
        timestamp: DateTime(2026),
      );
      when(() => repo.getTopologyStream()).thenAnswer(
        (_) => Stream.value(Right(topology)),
      );

      final usecase = GetTopologyUseCase(repo);
      final result = await usecase().first;

      expect(result.isRight(), isTrue);
      verify(() => repo.getTopologyStream()).called(1);
    });

    test('passes through Left failures', () async {
      when(() => repo.getTopologyStream()).thenAnswer(
        (_) => Stream.value(const Left(ServerFailure('boom'))),
      );

      final result = await GetTopologyUseCase(repo)().first;
      expect(result.isLeft(), isTrue);
    });
  });

  group('PingNodeUseCase', () {
    test('returns repository latency on success', () async {
      when(() => repo.pingNode('192.168.1.1'))
          .thenAnswer((_) async => const Right(42));

      final result = await PingNodeUseCase(repo)('192.168.1.1');

      expect(result, const Right<Failure, int>(42));
      verify(() => repo.pingNode('192.168.1.1')).called(1);
    });

    test('propagates failures from repository', () async {
      when(() => repo.pingNode(any())).thenAnswer(
        (_) async => const Left(ServerFailure('unreachable')),
      );

      final result = await PingNodeUseCase(repo)('10.0.0.1');
      expect(result.isLeft(), isTrue);
    });
  });
}
