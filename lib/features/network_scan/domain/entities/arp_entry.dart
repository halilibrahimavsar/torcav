import 'package:equatable/equatable.dart';

class ArpEntry extends Equatable {
  final String ip;
  final String mac;
  final String vendor;

  const ArpEntry({
    required this.ip,
    required this.mac,
    required this.vendor,
  });

  @override
  List<Object?> get props => [ip, mac, vendor];
}
