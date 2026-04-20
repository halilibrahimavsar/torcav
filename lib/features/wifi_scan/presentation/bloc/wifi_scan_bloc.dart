import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../data/services/favorites_store.dart';
import '../../domain/entities/scan_request.dart';
import '../../domain/entities/scan_snapshot.dart';
import '../../domain/entities/wifi_observation.dart';
import '../../domain/services/scan_session_store.dart';
import '../../domain/usecases/scan_wifi.dart';

part 'wifi_scan_event.dart';
part 'wifi_scan_state.dart';

@injectable
class WifiScanBloc extends Bloc<WifiScanEvent, WifiScanState> {
  final ScanWifi _scanWifi;
  final FavoritesStore _favorites;
  final ScanSessionStore _sessionStore;

  WifiScanBloc(this._scanWifi, this._favorites, this._sessionStore)
    : super(WifiScanInitial()) {
    on<WifiScanStarted>(_onStarted);
    on<WifiScanRefreshed>(_onRefreshed);
    on<WifiScanToggleFavorite>(_onToggleFavorite);
  }

  Future<void> _onStarted(
    WifiScanStarted event,
    Emitter<WifiScanState> emit,
  ) async {
    emit(WifiScanLoading());
    final result = await _scanWifi(request: event.request);
    if (isClosed) return;

    result.fold((failure) => emit(WifiScanError(failure.message)), (snapshot) {
      final sortedSnapshot = _sortSnapshot(snapshot);
      _sessionStore.add(sortedSnapshot);
      emit(WifiScanLoaded(sortedSnapshot, pinnedBssids: _favorites.pinned));
    });
  }

  Future<void> _onRefreshed(
    WifiScanRefreshed event,
    Emitter<WifiScanState> emit,
  ) async {
    final current = state;
    if (current is WifiScanLoaded) {
      emit(current.copyWith(isRefreshing: true));
    } else {
      emit(WifiScanLoading());
    }

    final result = await _scanWifi(request: event.request);
    if (isClosed) return;

    result.fold((failure) => emit(WifiScanError(failure.message)), (snapshot) {
      final sortedSnapshot = _sortSnapshot(snapshot);
      _sessionStore.add(sortedSnapshot);
      emit(
        WifiScanLoaded(
          sortedSnapshot,
          pinnedBssids: _favorites.pinned,
          isRefreshing: false,
        ),
      );
    });
  }

  void _onToggleFavorite(
    WifiScanToggleFavorite event,
    Emitter<WifiScanState> emit,
  ) {
    _favorites.toggle(event.bssid);
    final current = state;
    if (current is WifiScanLoaded) {
      emit(
        WifiScanLoaded(
          current.snapshot,
          pinnedBssids: _favorites.pinned,
          isRefreshing: current.isRefreshing,
        ),
      );
    }
  }

  ScanSnapshot _sortSnapshot(ScanSnapshot snapshot) {
    final sortedNetworks =
        snapshot.networks.toList()
          ..sort((a, b) => b.avgSignalDbm.compareTo(a.avgSignalDbm));

    return ScanSnapshot(
      timestamp: snapshot.timestamp,
      backendUsed: snapshot.backendUsed,
      interfaceName: snapshot.interfaceName,
      networks: sortedNetworks,
      channelStats: snapshot.channelStats,
      bandStats: snapshot.bandStats,
      isFromCache: snapshot.isFromCache,
    );
  }
}
