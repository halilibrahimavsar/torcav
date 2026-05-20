import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:network_info_plus/network_info_plus.dart';

import '../../../../core/errors/failures.dart';
import '../../../heatmap/domain/services/connected_signal_service.dart';
import '../../../performance/domain/repositories/speed_test_history_repository.dart';
import '../../../security/domain/entities/network_context_type.dart';
import '../../../security/domain/repositories/security_repository.dart';
import '../../../security/domain/services/network_context_resolver.dart';
import '../../../security/domain/usecases/security_analyzer.dart';
import '../../../wifi_scan/domain/entities/wifi_network.dart';
import '../../../wifi_scan/domain/services/channel_rating_engine.dart';
import '../../../wifi_scan/domain/services/scan_session_store.dart';
import '../../../diagnostics/domain/entities/diagnosis_inputs.dart';
import '../../../diagnostics/domain/usecases/diagnose_usecase.dart';
import '../../../diagnostics/domain/usecases/get_network_health_score_usecase.dart';
import '../../../diagnostics/domain/entities/network_health_score.dart';
import '../../data/datasources/score_history_local_data_source.dart';
import '../../../security/domain/entities/security_event.dart';
import '../../../wifi_scan/domain/entities/channel_rating.dart';
import 'dashboard_state.dart';

@injectable
class DashboardCubit extends Cubit<DashboardState> {
  final NetworkInfo _networkInfo;
  final ScanSessionStore _scanStore;
  final SecurityAnalyzer _securityAnalyzer;
  final NetworkContextResolver _contextResolver;
  final ScoreHistoryLocalDataSource _scoreStore;
  final ChannelRatingEngine _ratingEngine;
  final ConnectedSignalService _signalService;
  final SecurityRepository _securityRepository;
  final SpeedTestHistoryRepository _speedRepository;
  final DiagnoseUseCase _diagnoseUseCase;
  final GetNetworkHealthScoreUseCase _healthScoreUseCase;

  StreamSubscription<void>? _scanSubscription;

  DashboardCubit(
    this._networkInfo,
    this._scanStore,
    this._securityAnalyzer,
    this._contextResolver,
    this._scoreStore,
    this._ratingEngine,
    this._signalService,
    this._securityRepository,
    this._speedRepository,
    this._diagnoseUseCase,
    this._healthScoreUseCase,
  ) : super(const DashboardInitial()) {
    _scanSubscription = _scanStore.snapshots.listen((_) => load());
  }

  Future<void> load() async {
    if (state is DashboardInitial) {
      emit(const DashboardLoading());
    }

    try {
      final results = await Future.wait([
        _networkInfo.getWifiName(),
        _networkInfo.getWifiIP(),
        _networkInfo.getWifiGatewayIP(),
      ]);

      final latestSnapshot = _scanStore.latest;
      final networks =
          latestSnapshot?.networks.map((n) => n.toWifiNetwork()).toList() ??
              const <WifiNetwork>[];

      // Speed test (Needed early for Health Score)
      final speedResults = await _speedRepository.getRecent(limit: 1);
      final lastSpeed = speedResults.isEmpty ? null : speedResults.first;

      // Security assessment
      int secScore = 100;
      var worstAssessment = (state is DashboardSuccess)
          ? (state as DashboardSuccess).worstAssessment
          : null;
      final ssidForCtx = _cleanSsid(results[0]) ?? '';

      WifiNetwork? connectedNet;
      var connectedCtx = (state is DashboardSuccess)
          ? (state as DashboardSuccess).connectedContext
          : null;

      if (networks.isNotEmpty) {
        final contexts = await Future.wait(
          networks.map((n) => _contextResolver.resolve(n)),
        );
        final assessments = networks.asMap().entries.map((entry) {
          return _securityAnalyzer.assess(
            entry.value,
            localBaseline: networks,
            context: contexts[entry.key],
          );
        }).toList();

        if (assessments.isNotEmpty) {
          worstAssessment = assessments.reduce(
            (a, b) => a.score < b.score ? a : b,
          );
          secScore = worstAssessment.score;

          if (ssidForCtx.isNotEmpty) {
            for (var i = 0; i < networks.length; i++) {
              if (networks[i].ssid == ssidForCtx) {
                connectedNet = networks[i];
                connectedCtx = contexts[i];
                break;
              }
            }
          }
        }
      }

      // Snapshot diff
      int newDeviceCount = 0;
      final allSnapshots = _scanStore.all;
      if (allSnapshots.length >= 2) {
        final prev = allSnapshots[allSnapshots.length - 2];
        final prevBssids = prev.networks.map((n) => n.bssid).toSet();
        final latestBssids =
            latestSnapshot!.networks.map((n) => n.bssid).toSet();
        newDeviceCount = latestBssids.difference(prevBssids).length;
      }

      // Score history
      if (networks.isNotEmpty) {
        await _scoreStore.saveScore(secScore);
      }
      final recentScores = await _scoreStore.getRecentScores();
      final scoreHistory = recentScores.map((e) => e.score).toList();

      // Channel ratings
      final List<ChannelRating> ratings =
          networks.isNotEmpty ? _ratingEngine.calculateRatings(networks) : <ChannelRating>[];
      var bestCh = (state is DashboardSuccess)
          ? (state as DashboardSuccess).bestChannel
          : null;
      int? currentCh;

      if (networks.isNotEmpty && ssidForCtx.isNotEmpty) {
        final connected = networks.where((n) => n.ssid == ssidForCtx).toList();
        if (connected.isNotEmpty) {
          currentCh = connected.first.channel;
          final List<ChannelRating> band24 = ratings.where((r) => r.frequency < 4000).toList()
            ..sort((a, b) => b.rating.compareTo(a.rating));
          final List<ChannelRating> band5 =
              ratings.where((r) => r.frequency >= 4000 && r.frequency < 6000).toList()
                ..sort((a, b) => b.rating.compareTo(a.rating),);
          final List<ChannelRating> sameBand = connected.first.frequency < 4000 ? band24 : band5;

          if (sameBand.isNotEmpty &&
              sameBand.first.channel != currentCh &&
              sameBand.first.rating > 7.0) {
            bestCh = sameBand.first;
          } else {
            bestCh = null;
          }
        }
      }

      // Signal RSSI
      final signal = await _signalService.getConnectedSignal().catchError((_) => null);
      final qualityPct = signal == null
          ? null
          : (((signal.rssi + 100) / 70) * 100).round().clamp(0, 100);

      final rssiHistory = (state is DashboardSuccess)
          ? List<int>.from((state as DashboardSuccess).rssiHistory)
          : <int>[];
      if (signal != null) {
        rssiHistory.add(signal.rssi);
        if (rssiHistory.length > 20) {
          rssiHistory.removeRange(0, rssiHistory.length - 20);
        }
      }

      // Security events
      final eventsResult = await _securityRepository.getSecurityEvents();
      final List<SecurityEvent> events = eventsResult.fold((_) => <SecurityEvent>[], (list) => list);
      final unreadCount = events.where((e) => !e.isRead).length;

      // Network Health Score
      NetworkHealthScore? healthScore;
      if (worstAssessment != null) {
        final diagInputs = DiagnosisInputs(
          connectedNetwork: connectedNet,
          visibleNetworks: networks,
          speedTest: lastSpeed,
          gatewayPingMs: null,
          dnsBenchmark: null,
          context: connectedCtx ?? NetworkContextType.unknown,
        );
        final diagnosisResult = _diagnoseUseCase(diagInputs);
        healthScore = _healthScoreUseCase(
          securityAssessment: worstAssessment,
          diagnosisResult: diagnosisResult,
        );
      }

      emit(DashboardSuccess(
        ssid: _cleanSsid(results[0]) ?? '—',
        ip: results[1] ?? '—',
        gateway: results[2] ?? '—',
        networkCount: latestSnapshot?.networks.length ?? 0,
        securityScore: secScore,
        signalQualityPct: qualityPct,
        threatCount: unreadCount,
        newDeviceCount: newDeviceCount,
        bestChannel: bestCh,
        currentChannel: currentCh,
        channelRatings: ratings,
        worstAssessment: worstAssessment,
        connectedContext: connectedCtx,
        connectedBssid: connectedNet?.bssid,
        scoreHistory: scoreHistory,
        rssiHistory: rssiHistory,
        recentEvents: events.take(20).toList(),
        recentSnapshots: allSnapshots.reversed.take(6).toList(),
        lastSpeedTest: lastSpeed,
        networkHealthScore: healthScore,
      ),);
    } catch (e) {
      emit(DashboardFailure(ServerFailure(e.toString())));
    }
  }

  String? _cleanSsid(String? raw) => raw?.replaceAll('"', '');

  @override
  Future<void> close() {
    _scanSubscription?.cancel();
    return super.close();
  }
}
