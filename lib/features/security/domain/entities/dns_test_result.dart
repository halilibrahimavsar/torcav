import 'package:equatable/equatable.dart';

enum DnsSecurityStatus { secure, warning, dangerous }

class DnsTestResult extends Equatable {
  final String currentDns;
  final String ispName;
  final bool isHijacked;
  final bool isLeaking;
  final DnsSecurityStatus status;
  final List<String> detectedServers;

  const DnsTestResult({
    required this.currentDns,
    required this.ispName,
    required this.isHijacked,
    required this.isLeaking,
    required this.status,
    required this.detectedServers,
  });

  @override
  List<Object?> get props => [
    currentDns,
    ispName,
    isHijacked,
    isLeaking,
    status,
    detectedServers,
  ];
}
