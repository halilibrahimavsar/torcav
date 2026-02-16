import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../features/wifi_scan/domain/entities/wifi_network.dart';
import '../../domain/entities/channel_rating.dart';
import '../../domain/repositories/monitoring_repository.dart';
import '../../domain/usecases/channel_analyzer.dart';

// Events
abstract class MonitoringEvent extends Equatable {
  const MonitoringEvent();
}

class StartMonitoring extends MonitoringEvent {
  final String bssid;
  const StartMonitoring(this.bssid);
  @override
  List<Object?> get props => [bssid];
}

class StopMonitoring extends MonitoringEvent {
  @override
  List<Object?> get props => [];
}

class AnalyzeChannels extends MonitoringEvent {
  final List<WifiNetwork> networks;
  const AnalyzeChannels(this.networks);
  @override
  List<Object?> get props => [networks];
}

class _UpdateNetwork extends MonitoringEvent {
  final WifiNetwork network;
  const _UpdateNetwork(this.network);
  @override
  List<Object?> get props => [network];
}

class _MonitoringError extends MonitoringEvent {
  final String message;
  const _MonitoringError(this.message);
  @override
  List<Object?> get props => [message];
}

// State
abstract class MonitoringState extends Equatable {
  const MonitoringState();
  @override
  List<Object?> get props => [];
}

class MonitoringInitial extends MonitoringState {}

class MonitoringLoading extends MonitoringState {}

class MonitoringActive extends MonitoringState {
  final WifiNetwork currentData;
  final List<int> signalHistory;

  const MonitoringActive(this.currentData, this.signalHistory);

  @override
  List<Object?> get props => [currentData, signalHistory];
}

class ChannelAnalysisReady extends MonitoringState {
  final List<ChannelRating> ratings;
  const ChannelAnalysisReady(this.ratings);
  @override
  List<Object?> get props => [ratings];
}

class MonitoringFailure extends MonitoringState {
  final String message;
  const MonitoringFailure(this.message);
  @override
  List<Object?> get props => [message];
}

@injectable
class MonitoringBloc extends Bloc<MonitoringEvent, MonitoringState> {
  final MonitoringRepository _repository;
  final ChannelAnalyzer _channelAnalyzer;
  StreamSubscription? _subscription;
  List<int> _history = [];

  MonitoringBloc(this._repository, this._channelAnalyzer)
    : super(MonitoringInitial()) {
    on<StartMonitoring>(_onStartMonitoring);
    on<StopMonitoring>(_onStopMonitoring);
    on<_UpdateNetwork>(_onUpdateNetwork);
    on<AnalyzeChannels>(_onAnalyzeChannels);
    on<_MonitoringError>(_onMonitoringError);
  }

  Future<void> _onStartMonitoring(
    StartMonitoring event,
    Emitter<MonitoringState> emit,
  ) async {
    emit(MonitoringLoading());
    _history = [];
    await _subscription?.cancel();

    _subscription = _repository
        .monitorNetwork(event.bssid, interval: const Duration(seconds: 2))
        .listen((result) {
          result.fold(
            (failure) => add(_MonitoringError(failure.message)),
            (network) => add(_UpdateNetwork(network)),
          );
        });
  }

  Future<void> _onStopMonitoring(
    StopMonitoring event,
    Emitter<MonitoringState> emit,
  ) async {
    await _subscription?.cancel();
    emit(MonitoringInitial());
  }

  void _onUpdateNetwork(_UpdateNetwork event, Emitter<MonitoringState> emit) {
    _history.add(event.network.signalStrength);
    if (_history.length > 20) {
      _history.removeAt(0);
    }
    emit(MonitoringActive(event.network, List.from(_history)));
  }

  void _onAnalyzeChannels(
    AnalyzeChannels event,
    Emitter<MonitoringState> emit,
  ) {
    emit(MonitoringLoading());
    try {
      final ratings = _channelAnalyzer.analyzeChannels(event.networks);
      emit(ChannelAnalysisReady(ratings));
    } catch (e) {
      emit(MonitoringFailure(e.toString()));
    }
  }

  void _onMonitoringError(
    _MonitoringError event,
    Emitter<MonitoringState> emit,
  ) {
    emit(MonitoringFailure(event.message));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
