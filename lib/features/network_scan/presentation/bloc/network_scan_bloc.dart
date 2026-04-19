import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/host_scan_result.dart';
import '../../domain/entities/network_device.dart';
import '../../domain/entities/network_scan_policy.dart';
import '../../domain/entities/network_scan_profile.dart';
import '../../domain/repositories/network_scan_repository.dart';
import '../../domain/services/new_device_detector.dart';

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

class AcknowledgeLegalRisk extends NetworkScanEvent {
  final bool accepted;
  const AcknowledgeLegalRisk(this.accepted);
  @override
  List<Object?> get props => [accepted];
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

  bool _consentGiven = false;

  NetworkScanBloc(
    this._repository,
    this._newDeviceDetector,
  ) : super(NetworkScanInitial()) {
    on<StartNetworkScan>(_onStartScan);
    on<AcknowledgeLegalRisk>(_onAcknowledgeRisk);
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

    // Apply safety guardrails
    if (!NetworkScanPolicy.standard.isTargetSafe(event.target)) {
      emit(
        const NetworkScanError(
          'Scan target exceeds safety limits. Please restrict to /24 or smaller subnets.',
        ),
      );
      return;
    }

    emit(NetworkScanLoading());

    final List<HostScanResult> currentHosts = [];
    final List<NetworkDevice> currentDevices = [];
    List<HostScanResult> currentNewDevices = [];

    try {
      await for (final result in _repository.scanWithProfile(
        event.target,
        profile: event.profile,
        method: event.method,
      )) {
        await result.fold(
          (failure) async => emit(NetworkScanError(failure.message)),
          (host) async {
            final hostIndex = currentHosts.indexWhere((h) => h.ip == host.ip);
            if (hostIndex != -1) {
              currentHosts[hostIndex] = host;
            } else {
              currentHosts.add(host);
            }

            final device = NetworkDevice(
              ip: host.ip,
              mac: host.mac,
              vendor: host.vendor,
              hostName: host.hostName,
              latency: host.latency,
            );

            final deviceIndex = currentDevices.indexWhere(
              (d) => d.ip == host.ip,
            );
            if (deviceIndex != -1) {
              currentDevices[deviceIndex] = device;
            } else {
              currentDevices.add(device);
            }

            currentNewDevices = _newDeviceDetector.detectNew(currentHosts);

            emit(
              NetworkScanLoaded(
                devices: List.from(currentDevices),
                hosts: List.from(currentHosts),
                newDevices: List.from(currentNewDevices),
                isScanning: true,
              ),
            );
          },
        );
      }

      // Discovery complete – emit final state without scanning flag
      emit(
        NetworkScanLoaded(
          devices: List.from(currentDevices),
          hosts: List.from(currentHosts),
          newDevices: List.from(currentNewDevices),
          isScanning: false,
        ),
      );
    } catch (e) {
      emit(NetworkScanError(e.toString()));
    }
  }
}
