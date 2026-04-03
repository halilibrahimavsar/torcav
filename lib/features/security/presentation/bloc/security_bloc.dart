import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/known_network.dart';
import '../../domain/entities/security_event.dart' as domain_event;
import '../../domain/repositories/security_repository.dart';
import '../../domain/usecases/analyze_network_security_usecase.dart';
import '../../domain/usecases/security_analyzer.dart';
import 'package:torcav/features/wifi_scan/domain/entities/wifi_network.dart';
import 'package:torcav/features/wifi_scan/domain/services/scan_session_store.dart';
import 'dart:async';

part 'security_event.dart';
part 'security_state.dart';

@injectable
class SecurityBloc extends Bloc<SecurityEvent, SecurityState> {
  final SecurityRepository _repository;
  final AnalyzeNetworkSecurityUseCase _analyzeUseCase;
  final ScanSessionStore _sessionStore;
  final SecurityAnalyzer _analyzer;
  StreamSubscription? _scanSubscription;

  List<WifiNetwork> _lastNetworks = [];

  SecurityBloc(
    this._repository,
    this._analyzeUseCase,
    this._sessionStore,
    this._analyzer,
  ) : super(SecurityInitial()) {
    on<SecurityStarted>(_onStarted);
    on<SecurityAnalyzeRequested>(_onAnalyzeRequested);
    on<SecurityNetworkTrustChanged>(_onTrustChanged);

    // Auto-analyze on every new scan
    DateTime? lastTimestamp;
    _scanSubscription = _sessionStore.snapshots.listen((snapshot) {
      if (lastTimestamp == snapshot.timestamp) return;
      lastTimestamp = snapshot.timestamp;
      add(
        SecurityAnalyzeRequested(
          snapshot.networks.map((n) => n.toWifiNetwork()).toList(),
        ),
      );
    });
  }

  @override
  Future<void> close() {
    _scanSubscription?.cancel();
    return super.close();
  }

  Future<void> _onStarted(
    SecurityStarted event,
    Emitter<SecurityState> emit,
  ) async {
    emit(SecurityLoading());
    try {
      final known = await _repository.getKnownNetworks();
      final events = await _repository.getSecurityEvents();
      final score = _computeScore(_lastNetworks);
      final summary =
          _lastNetworks.isEmpty ? null : _buildSummary(_lastNetworks);
      emit(SecurityLoaded(
        knownNetworks: known,
        recentEvents: events,
        overallScore: score,
        scanSummary: summary,
      ));
    } catch (e) {
      emit(SecurityError(e.toString()));
    }
  }

  Future<void> _onAnalyzeRequested(
    SecurityAnalyzeRequested event,
    Emitter<SecurityState> emit,
  ) async {
    try {
      _lastNetworks = event.networks;
      await _analyzeUseCase(event.networks);
      final known = await _repository.getKnownNetworks();
      final events = await _repository.getSecurityEvents();
      final score = _computeScore(event.networks);
      final summary = _buildSummary(event.networks);
      emit(SecurityLoaded(
        knownNetworks: known,
        recentEvents: events,
        overallScore: score,
        scanSummary: summary,
      ));
    } catch (e) {
      emit(SecurityError(e.toString()));
    }
  }

  Future<void> _onTrustChanged(
    SecurityNetworkTrustChanged event,
    Emitter<SecurityState> emit,
  ) async {
    try {
      if (event.isTrusted) {
        await _repository.saveKnownNetwork(event.network);
      } else {
        await _repository.deleteKnownNetwork(event.network.bssid);
      }
      final known = await _repository.getKnownNetworks();
      final events = await _repository.getSecurityEvents();
      final score = _computeScore(_lastNetworks);
      final summary =
          _lastNetworks.isEmpty ? null : _buildSummary(_lastNetworks);
      emit(SecurityLoaded(
        knownNetworks: known,
        recentEvents: events,
        overallScore: score,
        scanSummary: summary,
      ));
    } catch (e) {
      emit(SecurityError(e.toString()));
    }
  }

  /// Returns the worst single-network score across all scanned networks.
  int _computeScore(List<WifiNetwork> networks) {
    if (networks.isEmpty) return 100;
    return networks
        .map((n) => _analyzer.assess(n, localBaseline: networks).score)
        .reduce((a, b) => a < b ? a : b);
  }

  SecurityScanSummary _buildSummary(List<WifiNetwork> networks) {
    return SecurityScanSummary(
      totalNetworks: networks.length,
      openCount:
          networks.where((n) => n.security == SecurityType.open).length,
      wepCount: networks.where((n) => n.security == SecurityType.wep).length,
      wpsCount: networks.where((n) => n.hasWps == true).length,
    );
  }
}
