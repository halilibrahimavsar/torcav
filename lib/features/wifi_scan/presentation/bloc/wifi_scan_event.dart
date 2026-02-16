part of 'wifi_scan_bloc.dart';

abstract class WifiScanEvent extends Equatable {
  const WifiScanEvent();

  @override
  List<Object> get props => [];
}

class WifiScanStarted extends WifiScanEvent {
  const WifiScanStarted();
}
