import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:torcav/core/network/connected_signal.dart';
import '../../data/services/connection_snapshot_service.dart';
import '../../domain/entities/cellular_status.dart';

/// Which link the heuristic currently favours.
enum ConnectionVerdict { wifi, cellular, even, bothWeak, unknown }

class ConnectionCompareState extends Equatable {
  final bool loading;
  final CellularStatus cellular;
  final ConnectedSignal? wifi;

  const ConnectionCompareState({
    this.loading = false,
    this.cellular = CellularStatus.unavailable,
    this.wifi,
  });

  /// Wi-Fi RSSI mapped onto Android's 0..4 cellular bucket scale so the
  /// two radios can be compared on one axis.
  int? get wifiLevel {
    final rssi = wifi?.rssi;
    if (rssi == null) return null;
    if (rssi >= -55) return 4;
    if (rssi >= -65) return 3;
    if (rssi >= -75) return 2;
    if (rssi >= -85) return 1;
    return 0;
  }

  ConnectionVerdict get verdict {
    final w = wifiLevel;
    final c = cellular.hasSignalInfo ? cellular.level : null;
    if (w == null && c == null) return ConnectionVerdict.unknown;
    if (w == null) return ConnectionVerdict.cellular;
    if (c == null) return ConnectionVerdict.wifi;
    if (w <= 1 && c <= 1) return ConnectionVerdict.bothWeak;
    if (w > c) return ConnectionVerdict.wifi;
    if (c > w) return ConnectionVerdict.cellular;
    return ConnectionVerdict.even;
  }

  ConnectionCompareState copyWith({
    bool? loading,
    CellularStatus? cellular,
    ConnectedSignal? wifi,
    bool clearWifi = false,
  }) {
    return ConnectionCompareState(
      loading: loading ?? this.loading,
      cellular: cellular ?? this.cellular,
      wifi: clearWifi ? null : (wifi ?? this.wifi),
    );
  }

  @override
  List<Object?> get props => [loading, cellular, wifi];
}

/// Fetches one snapshot of each link on demand. New instance per mount —
/// there is no cross-page state worth sharing.
@injectable
class ConnectionCompareCubit extends Cubit<ConnectionCompareState> {
  final ConnectionSnapshotService _service;

  ConnectionCompareCubit(this._service) : super(const ConnectionCompareState());

  Future<void> refresh() async {
    emit(state.copyWith(loading: true));
    final cellular = await _service.cellular();
    final wifi = await _service.wifi();
    if (isClosed) return;
    emit(ConnectionCompareState(cellular: cellular, wifi: wifi));
  }
}
