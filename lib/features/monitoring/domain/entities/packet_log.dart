import 'package:equatable/equatable.dart';

enum PacketProtocol {
  tcp,
  udp,
  icmp,
  http,
  https,
  dns,
  arp;

  String get label {
    switch (this) {
      case PacketProtocol.tcp:
        return 'TCP';
      case PacketProtocol.udp:
        return 'UDP';
      case PacketProtocol.icmp:
        return 'ICMP';
      case PacketProtocol.http:
        return 'HTTP';
      case PacketProtocol.https:
        return 'HTTPS';
      case PacketProtocol.dns:
        return 'DNS';
      case PacketProtocol.arp:
        return 'ARP';
    }
  }
}

class PacketLog extends Equatable {
  const PacketLog({
    required this.timestamp,
    required this.protocol,
    required this.source,
    required this.destination,
    required this.port,
    required this.size,
    required this.hexData,
    this.flags = '',
    this.method = '',
    this.info = '',
  });

  final DateTime timestamp;
  final PacketProtocol protocol;
  final String source;
  final String destination;
  final int port;
  final int size;
  final String hexData;
  final String flags;
  final String method;
  final String info;

  PacketLog copyWith({
    DateTime? timestamp,
    PacketProtocol? protocol,
    String? source,
    String? destination,
    int? port,
    int? size,
    String? hexData,
    String? flags,
    String? method,
    String? info,
  }) => PacketLog(
    timestamp: timestamp ?? this.timestamp,
    protocol: protocol ?? this.protocol,
    source: source ?? this.source,
    destination: destination ?? this.destination,
    port: port ?? this.port,
    size: size ?? this.size,
    hexData: hexData ?? this.hexData,
    flags: flags ?? this.flags,
    method: method ?? this.method,
    info: info ?? this.info,
  );

  @override
  List<Object?> get props => [
    timestamp,
    protocol,
    source,
    destination,
    port,
    size,
    hexData,
    flags,
    method,
    info,
  ];
}
