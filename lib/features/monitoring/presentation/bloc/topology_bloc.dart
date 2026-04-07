import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/network_topology.dart';
import '../../domain/repositories/topology_repository.dart';
import '../../domain/usecases/get_topology_usecase.dart';
import '../../domain/usecases/ping_node_usecase.dart';

// Events
abstract class TopologyEvent extends Equatable {
  const TopologyEvent();
  @override
  List<Object?> get props => [];
}

class LoadTopologyEvent extends TopologyEvent {
  const LoadTopologyEvent();
}

class PingNodeEvent extends TopologyEvent {
  final String nodeId;
  final String ip;

  const PingNodeEvent({required this.nodeId, required this.ip});

  @override
  List<Object?> get props => [nodeId, ip];
}

class TraceRouteEvent extends TopologyEvent {
  final String nodeId;
  final String ip;

  const TraceRouteEvent({required this.nodeId, required this.ip});

  @override
  List<Object?> get props => [nodeId, ip];
}

// States
abstract class TopologyState extends Equatable {
  const TopologyState();
  @override
  List<Object?> get props => [];
}

class TopologyInitial extends TopologyState {}

class TopologyLoading extends TopologyState {}

class TopologyLoaded extends TopologyState {
  final NetworkTopology topology;
  final String? pingingNodeId;
  final String? tracingNodeId;
  final List<TraceHop>? traceResult;

  const TopologyLoaded({
    required this.topology,
    this.pingingNodeId,
    this.tracingNodeId,
    this.traceResult,
  });

  TopologyLoaded copyWith({
    NetworkTopology? topology,
    String? pingingNodeId,
    bool clearPinging = false,
    String? tracingNodeId,
    bool clearTracing = false,
    List<TraceHop>? traceResult,
    bool clearTraceResult = false,
  }) {
    return TopologyLoaded(
      topology: topology ?? this.topology,
      pingingNodeId: clearPinging ? null : (pingingNodeId ?? this.pingingNodeId),
      tracingNodeId: clearTracing ? null : (tracingNodeId ?? this.tracingNodeId),
      traceResult: clearTraceResult ? null : (traceResult ?? this.traceResult),
    );
  }

  @override
  List<Object?> get props => [topology, pingingNodeId, tracingNodeId, traceResult];
}

class TopologyError extends TopologyState {
  final String message;
  const TopologyError(this.message);
  @override
  List<Object?> get props => [message];
}

@injectable
class TopologyBloc extends Bloc<TopologyEvent, TopologyState> {
  final GetTopologyUseCase _getTopology;
  final PingNodeUseCase _pingNode;
  final TopologyRepository _repository;

  TopologyBloc(
    this._getTopology,
    this._pingNode,
    this._repository,
  ) : super(TopologyInitial()) {
    on<LoadTopologyEvent>(_onLoadTopology);
    on<PingNodeEvent>(_onPingNode);
    on<TraceRouteEvent>(_onTraceRoute);
  }

  Future<void> _onLoadTopology(
    LoadTopologyEvent event,
    Emitter<TopologyState> emit,
  ) async {
    emit(TopologyLoading());
    final result = await _getTopology();
    result.fold(
      (failure) => emit(TopologyError(failure.message)),
      (topology) => emit(TopologyLoaded(topology: topology)),
    );
  }

  Future<void> _onPingNode(
    PingNodeEvent event,
    Emitter<TopologyState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TopologyLoaded) return;

    emit(currentState.copyWith(pingingNodeId: event.nodeId));

    final result = await _pingNode(event.ip);
    
    result.fold(
      (f) {
        // Ping failed, update node with null latency? No, maybe just clear pinging status.
        emit(currentState.copyWith(clearPinging: true));
      },
      (ms) {
        // Success: Create a new topology with the updated node latency
        final updatedNodes = currentState.topology.nodes.map((node) {
          if (node.id == event.nodeId) {
            // Need a copyWith on TopologyNode or create it manually
            return TopologyNode(
              id: node.id,
              label: node.label,
              type: node.type,
              ip: node.ip,
              mac: node.mac,
              signalStrength: node.signalStrength,
              frequency: node.frequency,
              latencyMs: ms,
              vendor: node.vendor,
              isGateway: node.isGateway,
              isCurrentDevice: node.isCurrentDevice,
            );
          }
          return node;
        }).toList();

        final updatedTopology = NetworkTopology(
          nodes: updatedNodes,
          edges: currentState.topology.edges,
          timestamp: currentState.topology.timestamp,
          currentDeviceIp: currentState.topology.currentDeviceIp,
        );

        emit(TopologyLoaded(topology: updatedTopology, pingingNodeId: null));
      },
    );
  }

  Future<void> _onTraceRoute(
    TraceRouteEvent event,
    Emitter<TopologyState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TopologyLoaded) return;

    emit(currentState.copyWith(
      tracingNodeId: event.nodeId,
      clearTraceResult: true,
    ));

    final result = await _repository.traceRoute(event.ip);

    result.fold(
      (_) => emit(currentState.copyWith(clearTracing: true)),
      (hops) => emit(currentState.copyWith(
        clearTracing: true,
        traceResult: hops,
      )),
    );
  }
}
