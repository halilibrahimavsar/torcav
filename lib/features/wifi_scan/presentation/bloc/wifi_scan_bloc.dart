import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/di/injection.dart';
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

  WifiScanBloc(this._scanWifi, this._favorites) : super(WifiScanInitial()) {
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
    result.fold((failure) => emit(WifiScanError(failure.message)), (snapshot) {
      getIt<ScanSessionStore>().add(snapshot);
      emit(WifiScanLoaded(snapshot, pinnedBssids: _favorites.pinned));
    });
  }

  Future<void> _onRefreshed(
    WifiScanRefreshed event,
    Emitter<WifiScanState> emit,
  ) async {
    emit(WifiScanLoading());
    final result = await _scanWifi(request: event.request);
    result.fold((failure) => emit(WifiScanError(failure.message)), (snapshot) {
      getIt<ScanSessionStore>().add(snapshot);
      emit(WifiScanLoaded(snapshot, pinnedBssids: _favorites.pinned));
    });
  }

  void _onToggleFavorite(
    WifiScanToggleFavorite event,
    Emitter<WifiScanState> emit,
  ) {
    _favorites.toggle(event.bssid);
    final current = state;
    if (current is WifiScanLoaded) {
      emit(WifiScanLoaded(current.snapshot, pinnedBssids: _favorites.pinned));
    }
  }
}
