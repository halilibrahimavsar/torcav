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
import '../../domain/repositories/monitoring_repository.dart';
import '../../../security/domain/entities/security_event.dart';
import '../../../security/domain/repositories/security_repository.dart';

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
  final Map<int, double> historicalAverages;
  final DateTime timestamp;

  /// Per-channel rating from the most recent prior analysis emission, used to
  /// show "+/- X pts vs last scan" deltas. Empty on the first emission.
  final Map<int, double> previousRatings;

  const ChannelAnalysisReady(
    this.ratings, {
    this.historicalAverages = const {},
    required this.timestamp,
    this.previousRatings = const {},
  });

  @override
  List<Object?> get props => [
    ratings,
    historicalAverages,
    timestamp,
    previousRatings,
  ];
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
  final SecurityRepository _securityRepository;

  StreamSubscription? _networkSubscription;
  StreamSubscription? _channelSubscription;

  List<int> _history = [];

  /// Snapshot of the previous emission's ratings, keyed by channel — fed to
  /// the next emission so the UI can show "delta vs last scan".
  Map<int, double> _previousRatings = const {};

  MonitoringBloc(
    this._repository,
    this._channelEngine,
    this._sessionStore,
    this._historyRepo,
    this._getHistory,
    this._securityRepository,
  ) : super(MonitoringInitial()) {
    on<StartMonitoring>(_onStartMonitoring);
    on<StopMonitoring>(_onStopMonitoring);
    on<_UpdateNetwork>(_onUpdateNetwork);
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
    await _networkSubscription?.cancel();

    _networkSubscription = _repository
        .monitorNetwork(event.bssid, interval: const Duration(seconds: 2))
        .listen(
          (result) {
            result.fold(
              (failure) => add(_MonitoringError(failure.message)),
              (network) => add(_UpdateNetwork(network)),
            );
          },
          onError:
              (Object error, StackTrace st) =>
                  add(_MonitoringError(error.toString())),
        );
  }

  Future<void> _onStopMonitoring(
    StopMonitoring event,
    Emitter<MonitoringState> emit,
  ) async {
    await _networkSubscription?.cancel();
    await _channelSubscription?.cancel();
    emit(MonitoringInitial());
  }

  void _onUpdateNetwork(_UpdateNetwork event, Emitter<MonitoringState> emit) {
    final prev = _history.isNotEmpty ? _history.last : null;
    _history.add(event.network.signalStrength);
    if (_history.length > 20) _history.removeAt(0);

    if (prev != null && (prev - event.network.signalStrength) > 15) {
      final drop = prev - event.network.signalStrength;
      unawaited(
        _securityRepository
            .saveSecurityEvent(
              SecurityEvent(
                type: SecurityEventType.deauthAttackSuspected,
                severity: SecurityEventSeverity.high,
                ssid: event.network.ssid,
                bssid: event.network.bssid,
                evidence: 'Signal dropped $drop dBm in one interval',
                timestamp: DateTime.now(),
              ),
            )
            .then((_) {})
            .catchError((_) {}),
      );
    }

    emit(MonitoringActive(event.network, List.from(_history)));
  }

  Future<void> _onAnalyzeChannels(
    AnalyzeChannels event,
    Emitter<MonitoringState> emit,
  ) async {
    // Initial analysis
    final initialRatings = _channelEngine.calculateRatings(event.networks);
    final history = await _getHistory();
    // Pull the most recent prior sample for each channel from history (the
    // current analysis hasn't been persisted yet, so this is the *previous*
    // run).
    final previousByChannel = <int, double>{};
    final priorSamples = await _historyRepo.getHistory(
      limit: const Duration(hours: 1),
    );
    priorSamples.fold((_) => null, (samples) {
      // Latest sample per channel.
      final latest = <int, ChannelRatingSample>{};
      for (final s in samples) {
        final cur = latest[s.channel];
        if (cur == null || s.timestamp.isAfter(cur.timestamp)) {
          latest[s.channel] = s;
        }
      }
      previousByChannel.addAll({
        for (final e in latest.entries) e.key: e.value.rating,
      });
    });
    _previousRatings = previousByChannel;
    emit(
      ChannelAnalysisReady(
        initialRatings,
        historicalAverages: history,
        timestamp: DateTime.now(),
        previousRatings: previousByChannel,
      ),
    );

    // Save initial ratings synchronously so DB is populated before the
    // History tab's FutureBuilder runs.
    await _persistRatings(initialRatings, DateTime.now(), awaitWrite: true);

    // Start real-time updates
    await _channelSubscription?.cancel();
    _channelSubscription = _sessionStore.snapshots.listen((snapshot) {
      final networks = snapshot.networks.map((o) => o.toWifiNetwork()).toList();
      final liveRatings = _channelEngine.calculateRatings(networks);
      _persistRatings(liveRatings, DateTime.now());
      add(_UpdateRatings(liveRatings));
    });
  }

  /// Persists [ratings] as history samples. By default fire-and-forget; pass
  /// [awaitWrite] to make the caller block until the DB write completes (used
  /// for the initial analysis so the History tab's FutureBuilder sees data).
  Future<void> _persistRatings(
    List<ChannelRating> ratings,
    DateTime timestamp, {
    bool awaitWrite = false,
  }) async {
    if (ratings.isEmpty) return;
    final samples = [
      for (final r in ratings)
        ChannelRatingSample(
          channel: r.channel,
          frequency: r.frequency,
          rating: r.rating,
          timestamp: timestamp,
        ),
    ];
    final future = _historyRepo
        .saveRatings(samples)
        .then((_) {})
        .catchError((_) {});
    if (awaitWrite) {
      await future;
    } else {
      unawaited(future);
    }
  }

  Future<void> _onUpdateRatings(
    _UpdateRatings event,
    Emitter<MonitoringState> emit,
  ) async {
    final history = await _getHistory();
    // Live updates: previous = the snapshot we just emitted last.
    final cur = state;
    final prev =
        cur is ChannelAnalysisReady
            ? {for (final r in cur.ratings) r.channel: r.rating}
            : _previousRatings;
    emit(
      ChannelAnalysisReady(
        event.ratings,
        historicalAverages: history,
        timestamp: DateTime.now(),
        previousRatings: prev,
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
