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

class ScanPortsEvent extends TopologyEvent {
  final String nodeId;
  final String ip;
  final String? customPorts;

  const ScanPortsEvent({
    required this.nodeId,
    required this.ip,
    this.customPorts,
  });

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

class DetectOsEvent extends TopologyEvent {
  final String nodeId;
  final String ip;

  const DetectOsEvent({required this.nodeId, required this.ip});

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
  final String? scanningNodeId;
  final List<int>? openPorts;
  final String? lookingUpNodeId;
  final String? hostname;
  final bool isScanningPorts;
  final bool isLookingUpHostname;
  final String? osHint;
  final String? detectingOsNodeId;
  final bool isDetectingOs;
  final String? lastErrorMessage;

  const TopologyLoaded({
    required this.topology,
    this.pingingNodeId,
    this.scanningNodeId,
    this.openPorts,
    this.lookingUpNodeId,
    this.hostname,
    this.isScanningPorts = false,
    this.isLookingUpHostname = false,
    this.osHint,
    this.detectingOsNodeId,
    this.isDetectingOs = false,
    this.lastErrorMessage,
  });

  TopologyLoaded copyWith({
    NetworkTopology? topology,
    String? pingingNodeId,
    bool clearPinging = false,
    String? scanningNodeId,
    bool clearScanning = false,
    List<int>? openPorts,
    bool clearOpenPorts = false,
    String? lookingUpNodeId,
    bool clearLookingUp = false,
    String? hostname,
    bool clearHostname = false,
    bool? isScanningPorts,
    bool? isLookingUpHostname,
    String? osHint,
    bool clearOsHint = false,
    String? detectingOsNodeId,
    bool clearDetectingOs = false,
    bool? isDetectingOs,
    String? lastErrorMessage,
    bool clearErrorMessage = false,
  }) {
    return TopologyLoaded(
      topology: topology ?? this.topology,
      pingingNodeId:
          clearPinging ? null : (pingingNodeId ?? this.pingingNodeId),
      scanningNodeId:
          clearScanning ? null : (scanningNodeId ?? this.scanningNodeId),
      openPorts: clearOpenPorts ? null : (openPorts ?? this.openPorts),
      lookingUpNodeId:
          clearLookingUp ? null : (lookingUpNodeId ?? this.lookingUpNodeId),
      hostname: clearHostname ? null : (hostname ?? this.hostname),
      isScanningPorts: isScanningPorts ?? this.isScanningPorts,
      isLookingUpHostname: isLookingUpHostname ?? this.isLookingUpHostname,
      osHint: clearOsHint ? null : (osHint ?? this.osHint),
      detectingOsNodeId:
          clearDetectingOs
              ? null
              : (detectingOsNodeId ?? this.detectingOsNodeId),
      isDetectingOs: isDetectingOs ?? this.isDetectingOs,
      lastErrorMessage:
          clearErrorMessage
              ? null
              : (lastErrorMessage ?? this.lastErrorMessage),
    );
  }

  @override
  List<Object?> get props => [
    topology,
    pingingNodeId,
    scanningNodeId,
    openPorts,
    lookingUpNodeId,
    hostname,
    isScanningPorts,
    isLookingUpHostname,
    osHint,
    detectingOsNodeId,
    isDetectingOs,
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

  TopologyBloc(this._getTopology, this._pingNode, this._repository)
    : super(TopologyInitial()) {
    on<LoadTopologyEvent>(_onLoadTopology);
    on<PingNodeEvent>(_onPingNode);
    on<ScanPortsEvent>(_onScanPorts);
    on<LookupHostnameEvent>(_onLookupHostname);
    on<DetectOsEvent>(_onDetectOs);
  }

  Future<void> _onLoadTopology(
    LoadTopologyEvent event,
    Emitter<TopologyState> emit,
  ) async {
    emit(TopologyLoading());
    try {
      await for (final result in _getTopology()) {
        result.fold(
          (failure) {
            // Re-emit error only if we haven't loaded any topology yet
            if (state is! TopologyLoaded) {
              emit(TopologyError(failure.message));
            }
          },
          (topology) {
            final currentState = state;
            if (currentState is TopologyLoaded) {
              emit(currentState.copyWith(topology: topology));
            } else {
              emit(TopologyLoaded(topology: topology));
            }
          },
        );
      }
    } catch (e) {
      if (state is! TopologyLoaded) {
        emit(TopologyError(e.toString()));
      }
    }
  }

  Future<void> _onPingNode(
    PingNodeEvent event,
    Emitter<TopologyState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TopologyLoaded) return;

    emit(currentState.copyWith(pingingNodeId: event.nodeId));

    final result = await _pingNode(event.ip);
    final afterState =
        state is TopologyLoaded ? state as TopologyLoaded : currentState;

    result.fold(
      (f) {
        emit(
          afterState.copyWith(clearPinging: true, lastErrorMessage: f.message),
        );
      },
      (ms) {
        final updatedNodes =
            afterState.topology.nodes.map((node) {
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
          edges: afterState.topology.edges,
          timestamp: afterState.topology.timestamp,
          currentDeviceIp: afterState.topology.currentDeviceIp,
        );

        emit(
          currentState.copyWith(
            topology: updatedTopology,
            clearPinging: true,
            clearErrorMessage: true,
          ),
        );
      },
    );
  }

  Future<void> _onScanPorts(
    ScanPortsEvent event,
    Emitter<TopologyState> emit,
  ) async {
    if (state is! TopologyLoaded) return;
    final currentState = state as TopologyLoaded;

    emit(
      currentState.copyWith(
        scanningNodeId: event.nodeId,
        isScanningPorts: true,
        clearOpenPorts: true,
        clearErrorMessage: true,
      ),
    );

    List<int>? targetPorts;
    if (event.customPorts != null && event.customPorts!.isNotEmpty) {
      targetPorts = [];
      final parts = event.customPorts!.split(',');
      for (final part in parts) {
        final trimmed = part.trim();
        if (trimmed.contains('-')) {
          final range = trimmed.split('-');
          if (range.length == 2) {
            final start = int.tryParse(range[0].trim());
            final end = int.tryParse(range[1].trim());
            if (start != null && end != null) {
              for (int i = start; i <= end; i++) {
                if (i > 0 && i < 65536) targetPorts.add(i);
              }
            }
          }
        } else {
          final port = int.tryParse(trimmed);
          if (port != null && port > 0 && port < 65536) {
            targetPorts.add(port);
          }
        }
      }
      // Remove duplicates and sort
      targetPorts = targetPorts.toSet().toList()..sort();
      // Safety limit for reasonable scan time
      if (targetPorts.length > 500) {
        targetPorts = targetPorts.sublist(0, 500);
      }
    }

    final result = await _repository.scanPorts(event.ip, ports: targetPorts);
    final afterState =
        state is TopologyLoaded ? state as TopologyLoaded : currentState;

    result.fold(
      (f) => emit(
        afterState.copyWith(
          isScanningPorts: false,
          lastErrorMessage: f.message,
        ),
      ),
      (ports) => emit(
        afterState.copyWith(
          isScanningPorts: false,
          openPorts: ports,
          clearErrorMessage: true,
        ),
      ),
    );
  }

  Future<void> _onLookupHostname(
    LookupHostnameEvent event,
    Emitter<TopologyState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TopologyLoaded) return;

    emit(
      currentState.copyWith(
        lookingUpNodeId: event.nodeId,
        isLookingUpHostname: true,
        clearHostname: true,
        clearErrorMessage: true,
      ),
    );

    final result = await _repository.reverseLookup(event.ip);
    final afterState =
        state is TopologyLoaded ? state as TopologyLoaded : currentState;

    result.fold(
      (f) => emit(
        afterState.copyWith(
          isLookingUpHostname: false,
          lastErrorMessage: f.message,
        ),
      ),
      (host) => emit(
        afterState.copyWith(
          isLookingUpHostname: false,
          hostname: host,
          clearErrorMessage: true,
        ),
      ),
    );
  }

  Future<void> _onDetectOs(
    DetectOsEvent event,
    Emitter<TopologyState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TopologyLoaded) return;

    emit(
      currentState.copyWith(
        detectingOsNodeId: event.nodeId,
        isDetectingOs: true,
        clearOsHint: true,
        clearErrorMessage: true,
      ),
    );

    final result = await _repository.detectOsFromTtl(event.ip);
    final afterState =
        state is TopologyLoaded ? state as TopologyLoaded : currentState;

    result.fold(
      (f) => emit(
        afterState.copyWith(isDetectingOs: false, lastErrorMessage: f.message),
      ),
      (hint) => emit(
        afterState.copyWith(
          isDetectingOs: false,
          osHint: hint,
          clearErrorMessage: true,
        ),
      ),
    );
  }
}
