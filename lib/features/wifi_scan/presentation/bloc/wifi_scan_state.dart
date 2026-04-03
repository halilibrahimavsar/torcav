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
  final Set<String> pinnedBssids;

  const WifiScanLoaded(this.snapshot, {this.pinnedBssids = const {}});

  List<WifiObservation> get networks => snapshot.networks;

  @override
  List<Object> get props => [snapshot, pinnedBssids];
}

class WifiScanError extends WifiScanState {
  final String message;

  const WifiScanError(this.message);

  @override
  List<Object> get props => [message];
}
