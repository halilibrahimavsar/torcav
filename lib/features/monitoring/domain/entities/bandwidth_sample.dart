import 'package:equatable/equatable.dart';

class BandwidthSample extends Equatable {
  final DateTime timestamp;
  final String interfaceName;
  final double txBps;
  final double rxBps;

  const BandwidthSample({
    required this.timestamp,
    required this.interfaceName,
    required this.txBps,
    required this.rxBps,
  });

  @override
  List<Object?> get props => [timestamp, interfaceName, txBps, rxBps];
}
