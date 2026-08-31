part of 'wifi_scan_bloc.dart';

abstract class WifiScanState extends Equatable {
  const WifiScanState();

  // `Object?`, matching Equatable's own signature, so a state can carry an
  // optional field (e.g. WifiScanError.messageKey) without a covariance
  // clash. Subclasses returning List<Object> stay valid overrides.
  @override
  List<Object?> get props => [];
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
  const WifiScanError(this.message, {this.messageKey});

  /// Technical detail, for logs.
  final String message;

  /// Localization key for the user-facing sentence; resolve with
  /// `FailureLabels.forKey`.
  final String? messageKey;

  @override
  List<Object?> get props => [message, messageKey];
}
