import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/wifi_network.dart';
import '../../domain/usecases/scan_wifi.dart';

part 'wifi_scan_event.dart';
part 'wifi_scan_state.dart';

@injectable
class WifiScanBloc extends Bloc<WifiScanEvent, WifiScanState> {
  final ScanWifi _scanWifi;

  WifiScanBloc(this._scanWifi) : super(WifiScanInitial()) {
    on<WifiScanStarted>(_onStarted);
  }

  Future<void> _onStarted(
    WifiScanStarted event,
    Emitter<WifiScanState> emit,
  ) async {
    emit(WifiScanLoading());
    final result = await _scanWifi();
    result.fold(
      (failure) => emit(WifiScanError(failure.message)),
      (networks) => emit(WifiScanLoaded(networks)),
    );
  }
}
