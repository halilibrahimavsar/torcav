import 'package:equatable/equatable.dart';

enum DeauthEventType { burst, single, error }

class DeauthFrame extends Equatable {
  final String sourceMac;
  final String targetMac;
  final DateTime timestamp;

  const DeauthFrame({
    required this.sourceMac,
    required this.targetMac,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [sourceMac, targetMac, timestamp];
}

class DeauthEvent extends Equatable {
  final DeauthEventType type;
  final int frameCount;
  final List<String> sources;
  final String? errorMessage;
  final DateTime timestamp;

  const DeauthEvent({
    required this.type,
    this.frameCount = 0,
    this.sources = const [],
    this.errorMessage,
    required this.timestamp,
  });

  bool get isError => type == DeauthEventType.error;
  bool get isBurst => type == DeauthEventType.burst;

  @override
  List<Object?> get props => [
    type,
    frameCount,
    sources,
    errorMessage,
    timestamp,
  ];
}
