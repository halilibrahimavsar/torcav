import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/host_scan_result.dart';
import '../../domain/entities/network_device.dart';
import '../../domain/entities/network_scan_policy.dart';
import '../../domain/entities/network_scan_profile.dart';
import '../../domain/repositories/network_scan_repository.dart';
import '../../domain/services/new_device_detector.dart';
import '../../../settings/domain/services/app_settings_store.dart';

// Events
abstract class NetworkScanEvent extends Equatable {
  const NetworkScanEvent();
}

class StartNetworkScan extends NetworkScanEvent {
  final String target;
  final NetworkScanProfile profile;
  final PortScanMethod method;
  final bool deepScan;

  const StartNetworkScan({
    required this.target,
    this.profile = NetworkScanProfile.fast,
    this.method = PortScanMethod.auto,
    this.deepScan = false,
  });

  @override
  List<Object?> get props => [target, profile, method, deepScan];
}

class CancelNetworkScan extends NetworkScanEvent {
  const CancelNetworkScan();
  @override
  List<Object?> get props => [];
}

class AcknowledgeLegalRisk extends NetworkScanEvent {
  final bool accepted;
  const AcknowledgeLegalRisk(this.accepted);
  @override
  List<Object?> get props => [accepted];
}

// Internal events
class _HostFound extends NetworkScanEvent {
  final HostScanResult host;
  const _HostFound(this.host);
  @override
  List<Object?> get props => [host];
}

class _ScanComplete extends NetworkScanEvent {
  const _ScanComplete();
  @override
  List<Object?> get props => [];
}

class _ScanFailed extends NetworkScanEvent {
  final String message;
  const _ScanFailed(this.message);
  @override
  List<Object?> get props => [message];
}

// State
abstract class NetworkScanState extends Equatable {
  const NetworkScanState();
  @override
  List<Object?> get props => [];
}

class NetworkScanInitial extends NetworkScanState {}

class NetworkScanConsentRequired extends NetworkScanState {}

class NetworkScanLoading extends NetworkScanState {}

class NetworkScanLoaded extends NetworkScanState {
  final List<NetworkDevice> devices;
  final List<HostScanResult> hosts;
  final List<HostScanResult> newDevices;
  final bool isScanning;

  const NetworkScanLoaded({
    required this.devices,
    required this.hosts,
    this.newDevices = const [],
    this.isScanning = false,
  });

  @override
  List<Object?> get props => [devices, hosts, newDevices, isScanning];
}

class NetworkScanError extends NetworkScanState {
  final String message;
  const NetworkScanError(this.message);
  @override
  List<Object?> get props => [message];
}

@injectable
class NetworkScanBloc extends Bloc<NetworkScanEvent, NetworkScanState> {
  final NetworkScanRepository _repository;
  final NewDeviceDetector _newDeviceDetector;
  final AppSettingsStore _settingsStore;

  bool _consentGiven = false;
  StreamSubscription? _scanSubscription;

  // Accumulate partial results so cancel can emit them
  final List<HostScanResult> _activeHosts = [];
  final List<NetworkDevice> _activeDevices = [];
  List<HostScanResult> _activeNewDevices = [];

  NetworkScanBloc(
    this._repository,
    this._newDeviceDetector,
    this._settingsStore,
  ) : super(NetworkScanInitial()) {
    on<StartNetworkScan>(_onStartScan);
    on<CancelNetworkScan>(_onCancelScan);
    on<AcknowledgeLegalRisk>(_onAcknowledgeRisk);
    on<_HostFound>(_onHostFound);
    on<_ScanComplete>(_onScanComplete);
    on<_ScanFailed>(_onScanFailed);
  }

  void _onAcknowledgeRisk(
    AcknowledgeLegalRisk event,
    Emitter<NetworkScanState> emit,
  ) {
    _consentGiven = event.accepted;
    if (_consentGiven) {
      emit(NetworkScanInitial());
    } else {
      emit(
        const NetworkScanError(
          'Legal acknowledgement required for LAN discovery.',
        ),
      );
    }
  }

  Future<void> _onStartScan(
    StartNetworkScan event,
    Emitter<NetworkScanState> emit,
  ) async {
    if (!_consentGiven) {
      emit(NetworkScanConsentRequired());
      return;
    }

    if (!NetworkScanPolicy.standard.isTargetSafe(event.target)) {
      emit(
        const NetworkScanError(
          'Scan target exceeds safety limits. Please restrict to /24 or smaller subnets.',
        ),
      );
      return;
    }
 
    // ENFORCEMENT: If strictSafetyMode is ON, we block deep scans
    if (_settingsStore.value.strictSafetyMode && event.deepScan) {
      emit(
        const NetworkScanError(
          'Deep scanning is disabled when Strict Safety Mode is active.',
        ),
      );
      return;
    }

    await _scanSubscription?.cancel();
    _scanSubscription = null;
    _activeHosts.clear();
    _activeDevices.clear();
    _activeNewDevices = [];

    emit(NetworkScanLoading());

    _scanSubscription = _repository
        .scanWithProfile(event.target, profile: event.profile, method: event.method)
        .listen(
          (result) => result.fold(
            (failure) => add(_ScanFailed(failure.message)),
            (host) => add(_HostFound(host)),
          ),
          onDone: () => add(const _ScanComplete()),
          onError: (Object e) => add(_ScanFailed(e.toString())),
        );
  }

  Future<void> _onCancelScan(
    CancelNetworkScan event,
    Emitter<NetworkScanState> emit,
  ) async {
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    emit(
      NetworkScanLoaded(
        devices: List.from(_activeDevices),
        hosts: List.from(_activeHosts),
        newDevices: List.from(_activeNewDevices),
        isScanning: false,
      ),
    );
  }

  void _onHostFound(_HostFound event, Emitter<NetworkScanState> emit) {
    final host = event.host;

    final hostIndex = _activeHosts.indexWhere((h) => h.ip == host.ip);
    if (hostIndex != -1) {
      _activeHosts[hostIndex] = host;
    } else {
      _activeHosts.add(host);
    }

    final device = NetworkDevice(
      ip: host.ip,
      mac: host.mac,
      vendor: host.vendor,
      hostName: host.hostName,
      latency: host.latency,
    );
    final deviceIndex = _activeDevices.indexWhere((d) => d.ip == host.ip);
    if (deviceIndex != -1) {
      _activeDevices[deviceIndex] = device;
    } else {
      _activeDevices.add(device);
    }

    _activeNewDevices = _newDeviceDetector.detectNew(_activeHosts);

    emit(
      NetworkScanLoaded(
        devices: List.from(_activeDevices),
        hosts: List.from(_activeHosts),
        newDevices: List.from(_activeNewDevices),
        isScanning: true,
      ),
    );
  }

  void _onScanComplete(_ScanComplete event, Emitter<NetworkScanState> emit) {
    emit(
      NetworkScanLoaded(
        devices: List.from(_activeDevices),
        hosts: List.from(_activeHosts),
        newDevices: List.from(_activeNewDevices),
        isScanning: false,
      ),
    );
  }

  void _onScanFailed(_ScanFailed event, Emitter<NetworkScanState> emit) {
    emit(NetworkScanError(event.message));
  }

  @override
  Future<void> close() {
    _scanSubscription?.cancel();
    return super.close();
  }
}
