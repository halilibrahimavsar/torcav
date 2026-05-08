import 'package:equatable/equatable.dart';

class DnsCandidate extends Equatable {
  final String ip;
  final String label;
  final double? lastRttMs;

  const DnsCandidate({required this.ip, required this.label, this.lastRttMs});

  DnsCandidate copyWith({double? lastRttMs}) =>
      DnsCandidate(ip: ip, label: label, lastRttMs: lastRttMs ?? this.lastRttMs);

  @override
  List<Object?> get props => [ip, label, lastRttMs];

  static const defaults = <DnsCandidate>[
    DnsCandidate(ip: '1.1.1.1', label: 'Cloudflare'),
    DnsCandidate(ip: '8.8.8.8', label: 'Google'),
    DnsCandidate(ip: '9.9.9.9', label: 'Quad9'),
    DnsCandidate(ip: '208.67.222.222', label: 'OpenDNS'),
  ];
}
