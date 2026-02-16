import 'package:equatable/equatable.dart';

class NetworkDevice extends Equatable {
  final String ip;
  final String mac;
  final String vendor;
  final String hostName;
  final double latency;

  const NetworkDevice({
    required this.ip,
    required this.mac,
    required this.vendor,
    this.hostName = '',
    this.latency = 0.0,
  });

  @override
  List<Object?> get props => [ip, mac, vendor, hostName, latency];
}
