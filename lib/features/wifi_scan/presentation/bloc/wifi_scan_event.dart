part of 'wifi_scan_bloc.dart';

abstract class WifiScanEvent extends Equatable {
  const WifiScanEvent();

  @override
  List<Object> get props => [];
}

class WifiScanStarted extends WifiScanEvent {
  final ScanRequest request;

  const WifiScanStarted({this.request = const ScanRequest()});

  @override
  List<Object> get props => [request];
}

class WifiScanRefreshed extends WifiScanEvent {
  final ScanRequest request;

  const WifiScanRefreshed({this.request = const ScanRequest()});

  @override
  List<Object> get props => [request];
}
