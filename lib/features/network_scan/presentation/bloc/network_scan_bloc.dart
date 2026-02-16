import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/network_device.dart';
import '../../domain/repositories/network_scan_repository.dart';

// Events
abstract class NetworkScanEvent extends Equatable {
  const NetworkScanEvent();
}

class StartNetworkScan extends NetworkScanEvent {
  final String subnet;
  const StartNetworkScan(this.subnet);
  @override
  List<Object?> get props => [subnet];
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
  const NetworkScanLoaded(this.devices);
  @override
  List<Object?> get props => [devices];
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
    on<StartNetworkScan>((event, emit) async {
      emit(NetworkScanLoading());
      final result = await _repository.scanNetwork(event.subnet);
      result.fold(
        (failure) => emit(NetworkScanError(failure.message)),
        (devices) => emit(NetworkScanLoaded(devices)),
      );
    });
  }
}
