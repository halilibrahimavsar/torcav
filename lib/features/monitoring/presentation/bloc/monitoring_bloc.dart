import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../features/wifi_scan/domain/entities/wifi_network.dart';
import '../../../../features/wifi_scan/domain/services/scan_session_store.dart';
import '../../../../features/wifi_scan/domain/entities/channel_rating.dart';
import '../../../../features/wifi_scan/domain/services/channel_rating_engine.dart';
import '../../../../features/wifi_scan/domain/entities/channel_rating_sample.dart';
import '../../../../features/wifi_scan/domain/usecases/get_historical_best_channel.dart';
import '../../../../features/wifi_scan/domain/repositories/channel_rating_repository.dart';
import '../../domain/entities/bandwidth_sample.dart';
import '../../domain/repositories/monitoring_repository.dart';

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

class StartBandwidthMonitoring extends MonitoringEvent {
  final String interfaceName;
  const StartBandwidthMonitoring(this.interfaceName);

  @override
  List<Object?> get props => [interfaceName];
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

class _UpdateBandwidth extends MonitoringEvent {
  final BandwidthSample sample;
  const _UpdateBandwidth(this.sample);

  @override
  List<Object?> get props => [sample];
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
  final BandwidthSample? latestBandwidth;

  const MonitoringActive(
    this.currentData,
    this.signalHistory, {
    this.latestBandwidth,
  });

  @override
  List<Object?> get props => [currentData, signalHistory, latestBandwidth];
}

class ChannelAnalysisReady extends MonitoringState {
  final List<ChannelRating> ratings;
  final Map<int, double> historicalAverages;
  final DateTime timestamp;

  const ChannelAnalysisReady(
    this.ratings, {
    this.historicalAverages = const {},
    required this.timestamp,
  });

  @override
  List<Object?> get props => [ratings, historicalAverages, timestamp];
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
  final ChannelRatingEngine _channelEngine;
  final ScanSessionStore _sessionStore;
  final ChannelRatingRepository _historyRepo;
  final GetBestHistoricalChannel _getHistory;

  StreamSubscription? _networkSubscription;
  StreamSubscription? _bandwidthSubscription;
  StreamSubscription? _channelSubscription;

  List<int> _history = [];
  WifiNetwork? _latestNetwork;
  BandwidthSample? _latestBandwidth;

  MonitoringBloc(
    this._repository,
    this._channelEngine,
    this._sessionStore,
    this._historyRepo,
    this._getHistory,
  ) : super(MonitoringInitial()) {
    on<StartMonitoring>(_onStartMonitoring);
    on<StopMonitoring>(_onStopMonitoring);
    on<StartBandwidthMonitoring>(_onStartBandwidthMonitoring);
    on<_UpdateNetwork>(_onUpdateNetwork);
    on<_UpdateBandwidth>(_onUpdateBandwidth);
    on<AnalyzeChannels>(_onAnalyzeChannels);
    on<_UpdateRatings>(_onUpdateRatings);
    on<_MonitoringError>(_onMonitoringError);
  }

  Future<void> _onStartMonitoring(
    StartMonitoring event,
    Emitter<MonitoringState> emit,
  ) async {
    emit(MonitoringLoading());
    _history = [];
    _latestNetwork = null;
    await _networkSubscription?.cancel();

    _networkSubscription = _repository
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
    await _networkSubscription?.cancel();
    await _bandwidthSubscription?.cancel();
    await _channelSubscription?.cancel();
    emit(MonitoringInitial());
  }

  void _onUpdateNetwork(_UpdateNetwork event, Emitter<MonitoringState> emit) {
    _latestNetwork = event.network;
    _history.add(event.network.signalStrength);
    if (_history.length > 20) {
      _history.removeAt(0);
    }
    emit(
      MonitoringActive(
        event.network,
        List.from(_history),
        latestBandwidth: _latestBandwidth,
      ),
    );
  }

  Future<void> _onStartBandwidthMonitoring(
    StartBandwidthMonitoring event,
    Emitter<MonitoringState> emit,
  ) async {
    await _bandwidthSubscription?.cancel();
    _bandwidthSubscription = _repository
        .monitorBandwidth(
          event.interfaceName,
          interval: const Duration(seconds: 2),
        )
        .listen((result) {
          result.fold(
            (failure) => add(_MonitoringError(failure.message)),
            (sample) => add(_UpdateBandwidth(sample)),
          );
        });
  }

  void _onUpdateBandwidth(
    _UpdateBandwidth event,
    Emitter<MonitoringState> emit,
  ) {
    _latestBandwidth = event.sample;
    final network = _latestNetwork;
    if (network == null) {
      return;
    }
    emit(
      MonitoringActive(
        network,
        List.from(_history),
        latestBandwidth: event.sample,
      ),
    );
  }

  Future<void> _onAnalyzeChannels(
    AnalyzeChannels event,
    Emitter<MonitoringState> emit,
  ) async {
    // Initial analysis
    final initialRatings = _channelEngine.calculateRatings(event.networks);
    final history = await _getHistory();
    emit(
      ChannelAnalysisReady(
        initialRatings,
        historicalAverages: history,
        timestamp: DateTime.now(),
      ),
    );

    // Start real-time updates
    await _channelSubscription?.cancel();
    _channelSubscription = _sessionStore.snapshots.listen((snapshot) {
      final networks = snapshot.networks.map((o) => o.toWifiNetwork()).toList();
      final liveRatings = _channelEngine.calculateRatings(networks);

      // Save to history asynchronously
      final timestamp = DateTime.now();
      _historyRepo.saveRatings(
        liveRatings
            .map(
              (r) => ChannelRatingSample(
                channel: r.channel,
                rating: r.rating,
                timestamp: timestamp,
              ),
            )
            .toList(),
      );

      add(_UpdateRatings(liveRatings));
    });
  }

  Future<void> _onUpdateRatings(
    _UpdateRatings event,
    Emitter<MonitoringState> emit,
  ) async {
    final history = await _getHistory();
    emit(
      ChannelAnalysisReady(
        event.ratings,
        historicalAverages: history,
        timestamp: DateTime.now(),
      ),
    );
  }

  void _onMonitoringError(
    _MonitoringError event,
    Emitter<MonitoringState> emit,
  ) {
    emit(MonitoringFailure(event.message));
  }

  @override
  Future<void> close() {
    _networkSubscription?.cancel();
    _bandwidthSubscription?.cancel();
    _channelSubscription?.cancel();
    return super.close();
  }
}

class _UpdateRatings extends MonitoringEvent {
  final List<ChannelRating> ratings;
  const _UpdateRatings(this.ratings);
  @override
  List<Object?> get props => [ratings];
}
