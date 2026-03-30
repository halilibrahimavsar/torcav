import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/packet_log.dart';
import '../../../data/services/packet_sniffer_service.dart';

// ── EVENTS ──
sealed class PacketSnifferEvent extends Equatable {
  const PacketSnifferEvent();

  @override
  List<Object?> get props => [];
}

class StartCapture extends PacketSnifferEvent {
  const StartCapture();
}

class StopCapture extends PacketSnifferEvent {
  const StopCapture();
}

class ClearLogs extends PacketSnifferEvent {
  const ClearLogs();
}

class _PacketReceived extends PacketSnifferEvent {
  final PacketLog packet;
  const _PacketReceived(this.packet);

  @override
  List<Object?> get props => [packet];
}

// ── STATES ──
class PacketSnifferState extends Equatable {
  const PacketSnifferState({
    this.logs = const [],
    this.isCapturing = false,
    this.totalPackets = 0,
    this.packetsPerSecond = 0,
    this.throughputKbps = 0,
  });

  final List<PacketLog> logs;
  final bool isCapturing;
  final int totalPackets;
  final double packetsPerSecond;
  final double throughputKbps;

  PacketSnifferState copyWith({
    List<PacketLog>? logs,
    bool? isCapturing,
    int? totalPackets,
    double? packetsPerSecond,
    double? throughputKbps,
  }) =>
      PacketSnifferState(
        logs: logs ?? this.logs,
        isCapturing: isCapturing ?? this.isCapturing,
        totalPackets: totalPackets ?? this.totalPackets,
        packetsPerSecond: packetsPerSecond ?? this.packetsPerSecond,
        throughputKbps: throughputKbps ?? this.throughputKbps,
      );

  @override
  List<Object?> get props => [
        logs,
        isCapturing,
        totalPackets,
        packetsPerSecond,
        throughputKbps,
      ];
}

// ── BLOC ──
@injectable
class PacketSnifferBloc extends Bloc<PacketSnifferEvent, PacketSnifferState> {
  final PacketSnifferService _snifferService;
  StreamSubscription<PacketLog>? _subscription;

  PacketSnifferBloc(this._snifferService) : super(const PacketSnifferState()) {
    on<StartCapture>(_onStartCapture);
    on<StopCapture>(_onStopCapture);
    on<ClearLogs>(_onClearLogs);
    on<_PacketReceived>(_onPacketReceived);
  }

  void _onStartCapture(StartCapture event, Emitter<PacketSnifferState> emit) {
    if (state.isCapturing) return;
    _snifferService.startCapture();
    _subscription?.cancel();
    _subscription = _snifferService.packetStream.listen((packet) {
      add(_PacketReceived(packet));
    });
    emit(state.copyWith(isCapturing: true));
  }

  void _onStopCapture(StopCapture event, Emitter<PacketSnifferState> emit) {
    _snifferService.stopCapture();
    _subscription?.cancel();
    _subscription = null;
    emit(state.copyWith(isCapturing: false));
  }

  void _onClearLogs(ClearLogs event, Emitter<PacketSnifferState> emit) {
    emit(state.copyWith(
      logs: [],
      totalPackets: 0,
      packetsPerSecond: 0,
      throughputKbps: 0,
    ));
  }

  void _onPacketReceived(_PacketReceived event, Emitter<PacketSnifferState> emit) {
    final updatedLogs = List<PacketLog>.from(state.logs);
    updatedLogs.add(event.packet);
    if (updatedLogs.length > 100) updatedLogs.removeAt(0);

    // Simple pseudo-metric calc for simulation
    final total = state.totalPackets + 1;
    final pps = total > 0 ? 1.5 + (total % 5) / 2.0 : 0.0;
    final speed = total > 0 ? 8.4 + (total % 10) / 1.5 : 0.0;

    emit(state.copyWith(
      logs: updatedLogs,
      totalPackets: total,
      packetsPerSecond: pps,
      throughputKbps: speed,
    ));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
