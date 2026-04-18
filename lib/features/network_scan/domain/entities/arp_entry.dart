import 'package:equatable/equatable.dart';

class ArpEntry extends Equatable {
  final String ip;
  final String mac;
  final String vendor;
  final double latency;

  const ArpEntry({
    required this.ip,
    required this.mac,
    required this.vendor,
    this.latency = 0,
  });

  @override
  List<Object?> get props => [ip, mac, vendor, latency];
}
