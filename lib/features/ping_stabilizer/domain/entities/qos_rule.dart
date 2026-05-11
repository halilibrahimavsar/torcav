import 'package:equatable/equatable.dart';

enum QosQueue { lowLatency, bulk }

enum QosProtocol { udp, tcp, any }

/// A single classifier rule applied by the native VPN reader thread to assign
/// outgoing packets to a queue. Matches by protocol + destination port range.
class QosRule extends Equatable {
  final QosProtocol protocol;
  final int portStart;
  final int portEnd;
  final QosQueue queue;
  final int dscp;

  const QosRule({
    required this.protocol,
    required this.portStart,
    required this.portEnd,
    required this.queue,
    this.dscp = 0,
  });

  bool matches(QosProtocol p, int port) {
    if (protocol != QosProtocol.any && protocol != p) return false;
    return port >= portStart && port <= portEnd;
  }

  Map<String, Object?> toMap() => {
    'protocol': protocol.name,
    'portStart': portStart,
    'portEnd': portEnd,
    'queue': queue.name,
    'dscp': dscp,
  };

  @override
  List<Object?> get props => [protocol, portStart, portEnd, queue, dscp];
}
