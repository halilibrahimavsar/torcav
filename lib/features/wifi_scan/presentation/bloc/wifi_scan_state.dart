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
  final bool isRefreshing;

  const WifiScanLoaded(
    this.snapshot, {
    this.pinnedBssids = const {},
    this.isRefreshing = false,
  });

  List<WifiObservation> get networks => snapshot.networks;

  @override
  List<Object> get props => [snapshot, pinnedBssids, isRefreshing];

  WifiScanLoaded copyWith({
    ScanSnapshot? snapshot,
    Set<String>? pinnedBssids,
    bool? isRefreshing,
  }) {
    return WifiScanLoaded(
      snapshot ?? this.snapshot,
      pinnedBssids: pinnedBssids ?? this.pinnedBssids,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

class WifiScanError extends WifiScanState {
  final String message;

  const WifiScanError(this.message);

  @override
  List<Object> get props => [message];
}
