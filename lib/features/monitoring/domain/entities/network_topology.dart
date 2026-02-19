import 'package:equatable/equatable.dart';

class TopologyNode extends Equatable {
  final String id;
  final String label;
  final TopologyNodeType type;
  final String? ip;
  final String? mac;
  final int? signalStrength;
  final String? vendor;
  final bool isGateway;
  final bool isCurrentDevice;

  const TopologyNode({
    required this.id,
    required this.label,
    required this.type,
    this.ip,
    this.mac,
    this.signalStrength,
    this.vendor,
    this.isGateway = false,
    this.isCurrentDevice = false,
  });

  @override
  List<Object?> get props => [
    id,
    label,
    type,
    ip,
    mac,
    signalStrength,
    vendor,
    isGateway,
    isCurrentDevice,
  ];
}

enum TopologyNodeType { router, accessPoint, device, mobile, iot, unknown }

class TopologyEdge extends Equatable {
  final String sourceId;
  final String targetId;
  final EdgeType type;
  final double? bandwidth;
  final int? latency;

  const TopologyEdge({
    required this.sourceId,
    required this.targetId,
    required this.type,
    this.bandwidth,
    this.latency,
  });

  @override
  List<Object?> get props => [sourceId, targetId, type, bandwidth, latency];
}

enum EdgeType { wired, wireless, unknown }

class NetworkTopology extends Equatable {
  final List<TopologyNode> nodes;
  final List<TopologyEdge> edges;
  final DateTime timestamp;
  final String? currentDeviceIp;

  const NetworkTopology({
    required this.nodes,
    required this.edges,
    required this.timestamp,
    this.currentDeviceIp,
  });

  TopologyNode? get gateway => nodes.where((n) => n.isGateway).firstOrNull;

  TopologyNode? get currentDevice =>
      nodes.where((n) => n.isCurrentDevice).firstOrNull;

  List<TopologyNode> get accessPoints =>
      nodes.where((n) => n.type == TopologyNodeType.accessPoint).toList();

  List<TopologyNode> get connectedDevices =>
      nodes.where((n) => n.type == TopologyNodeType.device).toList();

  @override
  List<Object?> get props => [nodes, edges, timestamp, currentDeviceIp];
}
