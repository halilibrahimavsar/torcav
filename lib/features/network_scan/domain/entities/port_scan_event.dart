import 'package:equatable/equatable.dart';
import 'service_fingerprint.dart';

/// Represents a single event during a port scan.
/// 
/// Emitted for every port probed to provide real-time progress.
class PortScanEvent extends Equatable {
  /// Total number of ports currently being scanned.
  final int totalCount;
  
  /// Number of ports scanned so far (including the one in this event).
  final int scannedCount;
  
  /// The port currently being described.
  final int currentPort;

  /// The discovered service, if the port was open.
  final ServiceFingerprint? discovery;

  const PortScanEvent({
    required this.totalCount,
    required this.scannedCount,
    required this.currentPort,
    this.discovery,
  });

  @override
  List<Object?> get props => [totalCount, scannedCount, currentPort, discovery];
}
