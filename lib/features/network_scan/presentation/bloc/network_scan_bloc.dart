import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/host_scan_result.dart';
import '../../domain/entities/network_device.dart';
import '../../domain/entities/network_scan_profile.dart';
import '../../domain/repositories/network_scan_repository.dart';

// Events
abstract class NetworkScanEvent extends Equatable {
  const NetworkScanEvent();
}

class StartNetworkScan extends NetworkScanEvent {
  final String target;
  final NetworkScanProfile profile;
  final PortScanMethod method;

  const StartNetworkScan({
    required this.target,
    this.profile = NetworkScanProfile.fast,
    this.method = PortScanMethod.auto,
  });

  @override
  List<Object?> get props => [target, profile, method];
}

// State
abstract class NetworkScanState extends Equatable {
  const NetworkScanState();
  @override
  List<Object?> get props => [];
}

class NetworkScanInitial extends NetworkScanState {}

class NetworkScanLoading extends NetworkScanState {}

class NetworkScanLoaded extends NetworkScanState {
  final List<NetworkDevice> devices;
  final List<HostScanResult> hosts;

  const NetworkScanLoaded({required this.devices, required this.hosts});

  @override
  List<Object?> get props => [devices, hosts];
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

  NetworkScanBloc(this._repository) : super(NetworkScanInitial()) {
    on<StartNetworkScan>(_onStartScan);
  }

  Future<void> _onStartScan(
    StartNetworkScan event,
    Emitter<NetworkScanState> emit,
  ) async {
    emit(NetworkScanLoading());
    final detailed = await _repository.scanWithProfile(
      event.target,
      profile: event.profile,
      method: event.method,
    );

    await detailed.fold(
      (failure) async => emit(NetworkScanError(failure.message)),
      (hosts) async {
        final devices =
            hosts
                .map(
                  (host) => NetworkDevice(
                    ip: host.ip,
                    mac: host.mac,
                    vendor: host.vendor,
                    hostName: host.hostName,
                    latency: host.latency,
                  ),
                )
                .toList();
        emit(NetworkScanLoaded(devices: devices, hosts: hosts));
      },
    );
  }
}
