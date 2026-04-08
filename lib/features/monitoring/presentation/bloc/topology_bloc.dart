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

class ScanPortsEvent extends TopologyEvent {
  final String nodeId;
  final String ip;
  final List<int>? customPorts;

  const ScanPortsEvent({required this.nodeId, required this.ip, this.customPorts});

  @override
  List<Object?> get props => [nodeId, ip, customPorts];
}

class LookupHostnameEvent extends TopologyEvent {
  final String nodeId;
  final String ip;

  const LookupHostnameEvent({required this.nodeId, required this.ip});

  @override
  List<Object?> get props => [nodeId, ip];
}

class GetArpInfoEvent extends TopologyEvent {
  final String nodeId;
  final String ip;

  const GetArpInfoEvent({required this.nodeId, required this.ip});

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
  final String? scanningNodeId;
  final List<int>? openPorts;
  final String? lookingUpNodeId;
  final String? hostname;
  final String? gettingArpNodeId;
  final String? arpInfo;
  final bool isScanningPorts;
  final bool isLookingUpHostname;
  final bool isGettingArp;
  final String? lastErrorMessage;

  const TopologyLoaded({
    required this.topology,
    this.pingingNodeId,
    this.tracingNodeId,
    this.traceResult,
    this.scanningNodeId,
    this.openPorts,
    this.lookingUpNodeId,
    this.hostname,
    this.gettingArpNodeId,
    this.arpInfo,
    this.isScanningPorts = false,
    this.isLookingUpHostname = false,
    this.isGettingArp = false,
    this.lastErrorMessage,
  });

  TopologyLoaded copyWith({
    NetworkTopology? topology,
    String? pingingNodeId,
    bool clearPinging = false,
    String? tracingNodeId,
    bool clearTracing = false,
    List<TraceHop>? traceResult,
    bool clearTraceResult = false,
    String? scanningNodeId,
    bool clearScanning = false,
    List<int>? openPorts,
    bool clearOpenPorts = false,
    String? lookingUpNodeId,
    bool clearLookingUp = false,
    String? hostname,
    bool clearHostname = false,
    String? gettingArpNodeId,
    bool clearGettingArp = false,
    String? arpInfo,
    bool clearArpInfo = false,
    bool? isScanningPorts,
    bool? isLookingUpHostname,
    bool? isGettingArp,
    String? lastErrorMessage,
    bool clearErrorMessage = false,
  }) {
    return TopologyLoaded(
      topology: topology ?? this.topology,
      pingingNodeId: clearPinging ? null : (pingingNodeId ?? this.pingingNodeId),
      tracingNodeId: clearTracing ? null : (tracingNodeId ?? this.tracingNodeId),
      traceResult: clearTraceResult ? null : (traceResult ?? this.traceResult),
      scanningNodeId: clearScanning ? null : (scanningNodeId ?? this.scanningNodeId),
      openPorts: clearOpenPorts ? null : (openPorts ?? this.openPorts),
      lookingUpNodeId: clearLookingUp ? null : (lookingUpNodeId ?? this.lookingUpNodeId),
      hostname: clearHostname ? null : (hostname ?? this.hostname),
      gettingArpNodeId: clearGettingArp ? null : (gettingArpNodeId ?? this.gettingArpNodeId),
      arpInfo: clearArpInfo ? null : (arpInfo ?? this.arpInfo),
      isScanningPorts: isScanningPorts ?? this.isScanningPorts,
      isLookingUpHostname: isLookingUpHostname ?? this.isLookingUpHostname,
      isGettingArp: isGettingArp ?? this.isGettingArp,
      lastErrorMessage: clearErrorMessage ? null : (lastErrorMessage ?? this.lastErrorMessage),
    );
  }

  @override
  List<Object?> get props => [
        topology,
        pingingNodeId,
        tracingNodeId,
        traceResult,
        scanningNodeId,
        openPorts,
        lookingUpNodeId,
        hostname,
        gettingArpNodeId,
        arpInfo,
        isScanningPorts,
        isLookingUpHostname,
        isGettingArp,
        lastErrorMessage,
      ];
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
    on<ScanPortsEvent>(_onScanPorts);
    on<LookupHostnameEvent>(_onLookupHostname);
    on<GetArpInfoEvent>(_onGetArpInfo);
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
        emit(currentState.copyWith(clearPinging: true, lastErrorMessage: f.message));
      },
      (ms) {
        final updatedNodes = currentState.topology.nodes.map((node) {
          if (node.id == event.nodeId) {
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

        emit(currentState.copyWith(
          topology: updatedTopology,
          clearPinging: true,
          clearErrorMessage: true,
        ));
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
      clearErrorMessage: true,
    ));

    final result = await _repository.traceRoute(event.ip);

    result.fold(
      (f) => emit(currentState.copyWith(clearTracing: true, lastErrorMessage: f.message)),
      (hops) => emit(currentState.copyWith(
        clearTracing: true,
        traceResult: hops,
        clearErrorMessage: true,
      )),
    );
  }

  Future<void> _onScanPorts(
    ScanPortsEvent event,
    Emitter<TopologyState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TopologyLoaded) return;

    emit(currentState.copyWith(
      scanningNodeId: event.nodeId,
      isScanningPorts: true,
      clearOpenPorts: true,
      clearErrorMessage: true,
    ));

    final result = await _repository.scanPorts(event.ip, ports: event.customPorts);

    result.fold(
      (f) => emit(currentState.copyWith(isScanningPorts: false, lastErrorMessage: f.message)),
      (ports) => emit(currentState.copyWith(
        isScanningPorts: false,
        openPorts: ports,
        clearErrorMessage: true,
      )),
    );
  }

  Future<void> _onLookupHostname(
    LookupHostnameEvent event,
    Emitter<TopologyState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TopologyLoaded) return;

    emit(currentState.copyWith(
      lookingUpNodeId: event.nodeId,
      isLookingUpHostname: true,
      clearHostname: true,
      clearErrorMessage: true,
    ));

    final result = await _repository.reverseLookup(event.ip);

    result.fold(
      (f) => emit(currentState.copyWith(isLookingUpHostname: false, lastErrorMessage: f.message)),
      (host) => emit(currentState.copyWith(
        isLookingUpHostname: false,
        hostname: host,
        clearErrorMessage: true,
      )),
    );
  }

  Future<void> _onGetArpInfo(
    GetArpInfoEvent event,
    Emitter<TopologyState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TopologyLoaded) return;

    emit(currentState.copyWith(
      gettingArpNodeId: event.nodeId,
      isGettingArp: true,
      clearArpInfo: true,
      clearErrorMessage: true,
    ));

    final result = await _repository.getArpInfo(event.ip);

    result.fold(
      (f) => emit(currentState.copyWith(isGettingArp: false, lastErrorMessage: f.message)),
      (info) => emit(currentState.copyWith(
        isGettingArp: false,
        arpInfo: info,
        clearErrorMessage: true,
      )),
    );
  }
}
