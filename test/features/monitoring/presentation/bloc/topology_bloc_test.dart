import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:torcav/core/errors/failures.dart';
import 'package:torcav/features/monitoring/domain/entities/network_topology.dart';
import 'package:torcav/features/monitoring/domain/repositories/topology_repository.dart';
import 'package:torcav/features/monitoring/domain/usecases/get_topology_usecase.dart';
import 'package:torcav/features/monitoring/domain/usecases/ping_node_usecase.dart';
import 'package:torcav/features/monitoring/presentation/bloc/topology_bloc.dart';
import 'package:torcav/features/network_scan/domain/entities/network_device.dart';

import '../../../../helpers/fixtures.dart';

class _MockGetTopology extends Mock implements GetTopologyUseCase {}

class _MockPingNode extends Mock implements PingNodeUseCase {}

class _MockTopologyRepository extends Mock implements TopologyRepository {}

NetworkTopology _topology({List<TopologyNode>? nodes}) {
  return NetworkTopology(
    nodes: nodes ??
        [
          buildTopologyNode(id: 'current', isCurrentDevice: true),
          buildTopologyNode(id: 'device_192.168.1.42', ip: '192.168.1.42'),
        ],
    edges: const [],
    timestamp: DateTime(2026),
  );
}

void main() {
  late _MockGetTopology getTopology;
  late _MockPingNode pingNode;
  late _MockTopologyRepository repo;

  setUpAll(() {
    registerFallbackValue(<NetworkDevice>[]);
  });

  setUp(() {
    getTopology = _MockGetTopology();
    pingNode = _MockPingNode();
    repo = _MockTopologyRepository();
  });

  TopologyBloc buildBloc() => TopologyBloc(getTopology, pingNode, repo);

  group('LoadTopologyEvent', () {
    blocTest<TopologyBloc, TopologyState>(
      'emits Loading then Loaded on success',
      build: buildBloc,
      setUp: () {
        when(() => getTopology())
            .thenAnswer((_) => Stream.value(Right(_topology())));
      },
      act: (bloc) => bloc.add(const LoadTopologyEvent()),
      verify: (bloc) {
        expect(bloc.state, isA<TopologyLoaded>());
      },
    );

    blocTest<TopologyBloc, TopologyState>(
      'emits Error when stream yields Left and no prior topology',
      build: buildBloc,
      setUp: () {
        when(() => getTopology()).thenAnswer(
          (_) => Stream.value(const Left(ServerFailure('boom'))),
        );
      },
      act: (bloc) => bloc.add(const LoadTopologyEvent()),
      verify: (bloc) {
        expect(bloc.state, isA<TopologyError>());
      },
    );

    blocTest<TopologyBloc, TopologyState>(
      'late failure does not overwrite already-Loaded state',
      build: buildBloc,
      setUp: () {
        when(() => getTopology()).thenAnswer(
          (_) => Stream<Either<Failure, NetworkTopology>>.fromIterable([
            Right(_topology()),
            const Left(ServerFailure('transient')),
          ]),
        );
      },
      act: (bloc) => bloc.add(const LoadTopologyEvent()),
      verify: (bloc) {
        expect(bloc.state, isA<TopologyLoaded>());
      },
    );
  });

  group('BuildTopologyFromScanEvent', () {
    blocTest<TopologyBloc, TopologyState>(
      'emits Loaded when build succeeds',
      build: buildBloc,
      setUp: () {
        when(() => repo.buildFromDevices(any()))
            .thenAnswer((_) async => Right(_topology()));
      },
      act: (bloc) => bloc.add(BuildTopologyFromScanEvent(
        [buildNetworkDevice()],
      ),),
      verify: (bloc) {
        expect(bloc.state, isA<TopologyLoaded>());
      },
    );

    blocTest<TopologyBloc, TopologyState>(
      'emits Error on first failure with no prior topology',
      build: buildBloc,
      setUp: () {
        when(() => repo.buildFromDevices(any())).thenAnswer(
          (_) async => const Left(ScanFailure('build failed')),
        );
      },
      act: (bloc) =>
          bloc.add(const BuildTopologyFromScanEvent(<NetworkDevice>[])),
      verify: (bloc) {
        expect(bloc.state, isA<TopologyError>());
      },
    );
  });

  group('PingNodeEvent', () {
    blocTest<TopologyBloc, TopologyState>(
      'ignored when state is not Loaded',
      build: buildBloc,
      act: (bloc) => bloc.add(
        const PingNodeEvent(nodeId: 'x', ip: '1.2.3.4'),
      ),
      expect: () => <TopologyState>[],
    );

    blocTest<TopologyBloc, TopologyState>(
      'updates node latencyMs on success',
      build: buildBloc,
      seed: () => TopologyLoaded(topology: _topology()),
      setUp: () {
        when(() => pingNode('192.168.1.42'))
            .thenAnswer((_) async => const Right(7));
      },
      act: (bloc) => bloc.add(
        const PingNodeEvent(nodeId: 'device_192.168.1.42', ip: '192.168.1.42'),
      ),
      verify: (bloc) {
        final state = bloc.state as TopologyLoaded;
        final pinged = state.topology.nodes
            .firstWhere((n) => n.id == 'device_192.168.1.42');
        expect(pinged.latencyMs, 7);
        expect(state.pingingNodeId, isNull);
        expect(state.lastErrorMessage, isNull);
      },
    );

    blocTest<TopologyBloc, TopologyState>(
      'sets lastErrorMessage on failure',
      build: buildBloc,
      seed: () => TopologyLoaded(topology: _topology()),
      setUp: () {
        when(() => pingNode(any())).thenAnswer(
          (_) async => const Left(ServerFailure('Host Unreachable')),
        );
      },
      act: (bloc) => bloc.add(
        const PingNodeEvent(nodeId: 'device_192.168.1.42', ip: '192.168.1.42'),
      ),
      verify: (bloc) {
        final state = bloc.state as TopologyLoaded;
        expect(state.lastErrorMessage, 'Host Unreachable');
        expect(state.pingingNodeId, isNull);
      },
    );
  });

  group('LookupHostnameEvent', () {
    blocTest<TopologyBloc, TopologyState>(
      'stores hostname on success',
      build: buildBloc,
      seed: () => TopologyLoaded(topology: _topology()),
      setUp: () {
        when(() => repo.reverseLookup('192.168.1.42'))
            .thenAnswer((_) async => const Right('nas.local'));
      },
      act: (bloc) => bloc.add(
        const LookupHostnameEvent(
          nodeId: 'device_192.168.1.42',
          ip: '192.168.1.42',
        ),
      ),
      verify: (bloc) {
        final state = bloc.state as TopologyLoaded;
        expect(state.hostname, 'nas.local');
        expect(state.isLookingUpHostname, isFalse);
      },
    );

    blocTest<TopologyBloc, TopologyState>(
      'sets lastErrorMessage on failure',
      build: buildBloc,
      seed: () => TopologyLoaded(topology: _topology()),
      setUp: () {
        when(() => repo.reverseLookup(any())).thenAnswer(
          (_) async => const Left(ServerFailure('Hostname not found')),
        );
      },
      act: (bloc) => bloc.add(
        const LookupHostnameEvent(
          nodeId: 'device_192.168.1.42',
          ip: '192.168.1.42',
        ),
      ),
      verify: (bloc) {
        final state = bloc.state as TopologyLoaded;
        expect(state.lastErrorMessage, 'Hostname not found');
        expect(state.isLookingUpHostname, isFalse);
      },
    );
  });

  group('DetectOsEvent', () {
    blocTest<TopologyBloc, TopologyState>(
      'stores osHint on success',
      build: buildBloc,
      seed: () => TopologyLoaded(topology: _topology()),
      setUp: () {
        when(() => repo.detectOsFromTtl('192.168.1.42'))
            .thenAnswer((_) async => const Right('osLinuxMacOS'));
      },
      act: (bloc) => bloc.add(
        const DetectOsEvent(
          nodeId: 'device_192.168.1.42',
          ip: '192.168.1.42',
        ),
      ),
      verify: (bloc) {
        final state = bloc.state as TopologyLoaded;
        expect(state.osHint, 'osLinuxMacOS');
        expect(state.isDetectingOs, isFalse);
      },
    );
  });
}
