import 'package:equatable/equatable.dart';

enum AuthorizedOperation { passiveOnly, handshakeCapture, activeDefense }

class AuthorizedTarget extends Equatable {
  final String bssid;
  final String ssid;
  final List<AuthorizedOperation> operations;
  final DateTime approvedAt;
  final String approvedBy;

  const AuthorizedTarget({
    required this.bssid,
    required this.ssid,
    required this.operations,
    required this.approvedAt,
    required this.approvedBy,
  });

  bool allows(AuthorizedOperation operation) => operations.contains(operation);

  @override
  List<Object?> get props => [bssid, ssid, operations, approvedAt, approvedBy];
}
