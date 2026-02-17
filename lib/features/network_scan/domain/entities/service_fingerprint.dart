import 'package:equatable/equatable.dart';

class ServiceFingerprint extends Equatable {
  final int port;
  final String protocol;
  final String serviceName;
  final String product;
  final String version;

  const ServiceFingerprint({
    required this.port,
    required this.protocol,
    required this.serviceName,
    this.product = '',
    this.version = '',
  });

  @override
  List<Object?> get props => [port, protocol, serviceName, product, version];
}
