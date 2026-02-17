part of 'wifi_scan_bloc.dart';

abstract class WifiScanState extends Equatable {
  const WifiScanState();

  @override
  List<Object> get props => [];
}

class WifiScanInitial extends WifiScanState {}

class WifiScanLoading extends WifiScanState {}

class WifiScanLoaded extends WifiScanState {
  final ScanSnapshot snapshot;

  const WifiScanLoaded(this.snapshot);

  List<WifiObservation> get networks => snapshot.networks;

  @override
  List<Object> get props => [snapshot];
}

class WifiScanError extends WifiScanState {
  final String message;

  const WifiScanError(this.message);

  @override
  List<Object> get props => [message];
}
