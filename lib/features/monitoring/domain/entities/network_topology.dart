import 'package:equatable/equatable.dart';

class TopologyNode extends Equatable {
  final String id;
  final String label;
  final TopologyNodeType type;
  final String? ip;
  final String? mac;
  final int? signalStrength;
  final int? frequency;
  final int? latencyMs;
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
    this.frequency,
    this.latencyMs,
    this.vendor,
    this.isGateway = false,
    this.isCurrentDevice = false,
  });

  TopologyNode copyWith({
    String? id,
    String? label,
    TopologyNodeType? type,
    String? ip,
    String? mac,
    int? signalStrength,
    int? frequency,
    int? latencyMs,
    String? vendor,
    bool? isGateway,
    bool? isCurrentDevice,
  }) {
    return TopologyNode(
      id: id ?? this.id,
      label: label ?? this.label,
      type: type ?? this.type,
      ip: ip ?? this.ip,
      mac: mac ?? this.mac,
      signalStrength: signalStrength ?? this.signalStrength,
      frequency: frequency ?? this.frequency,
      latencyMs: latencyMs ?? this.latencyMs,
      vendor: vendor ?? this.vendor,
      isGateway: isGateway ?? this.isGateway,
      isCurrentDevice: isCurrentDevice ?? this.isCurrentDevice,
    );
  }

  bool get isMacRandomized {
    if (mac == null) return false;
    final firstOctet = int.tryParse(mac!.split(':').first, radix: 16) ?? 0;
    return (firstOctet & 0x02) != 0;
  }

  @override
  List<Object?> get props => [
    id,
    label,
    type,
    ip,
    mac,
    signalStrength,
    frequency,
    latencyMs,
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
      nodes
          .where(
            (n) =>
                !n.isCurrentDevice &&
                !n.isGateway &&
                n.type != TopologyNodeType.accessPoint,
          )
          .toList();

  @override
  List<Object?> get props => [nodes, edges, timestamp, currentDeviceIp];
}
