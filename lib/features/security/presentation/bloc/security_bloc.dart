import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/known_network.dart';
import '../../domain/entities/security_event.dart' as domain_event;
import '../../domain/repositories/security_repository.dart';
import '../../domain/usecases/analyze_network_security_usecase.dart';
import '../../domain/usecases/security_analyzer.dart';
import '../../domain/usecases/dns_leak_test_usecase.dart';
import '../../domain/entities/dns_test_result.dart';
import '../../domain/entities/assessment_session.dart';
import 'package:torcav/features/wifi_scan/domain/entities/wifi_network.dart';
import 'package:torcav/features/wifi_scan/domain/services/scan_session_store.dart';
import 'package:torcav/features/settings/domain/services/app_settings_store.dart';
import '../../domain/entities/trusted_network_profile.dart';
import 'dart:async';

part 'security_event.dart';
part 'security_state.dart';

@injectable
class SecurityBloc extends Bloc<SecurityEvent, SecurityState> {
  final SecurityRepository _repository;
  final AnalyzeNetworkSecurityUseCase _analyzeUseCase;
  final ScanSessionStore _sessionStore;
  final SecurityAnalyzer _analyzer;
  final DnsLeakTestUsecase _dnsLeakTestUsecase;
  final AppSettingsStore _settingsStore;
  StreamSubscription? _scanSubscription;
  StreamSubscription? _settingsSubscription;

  List<WifiNetwork> _lastNetworks = [];

  SecurityBloc(
    this._repository,
    this._analyzeUseCase,
    this._sessionStore,
    this._analyzer,
    this._dnsLeakTestUsecase,
    this._settingsStore,
  ) : super(SecurityInitial()) {
    on<SecurityStarted>(_onStarted);
    on<SecurityAnalyzeRequested>(_onAnalyzeRequested);
    on<SecurityUntrustRequested>(_onUntrustRequested);
    on<SecurityDnsTestRequested>(_onDnsTestRequested);
    on<SecurityDeepScanToggled>(_onDeepScanToggled);

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

    // Listen to global settings changes for Deep Scan sync
    _settingsSubscription = _settingsStore.changes.listen((settings) {
      final currentState = state;
      if (currentState is SecurityLoaded) {
        if (currentState.isDeepScanEnabled != settings.isDeepScanEnabled) {
          add(SecurityDeepScanToggled(settings.isDeepScanEnabled));
        }
      }
    });
  }

  @override
  Future<void> close() {
    _scanSubscription?.cancel();
    _settingsSubscription?.cancel();
    return super.close();
  }

  Future<void> _onStarted(
    SecurityStarted event,
    Emitter<SecurityState> emit,
  ) async {
    emit(SecurityLoading());
    try {
      // If a scan happened before this page was opened, analyse it immediately.
      // SecurityBloc is a factory — it misses broadcast events emitted before
      // subscription. We recover by checking the session store's cached latest.
      final latest = _sessionStore.latest;
      if (latest != null && _lastNetworks.isEmpty) {
        _lastNetworks = latest.networks.map((n) => n.toWifiNetwork()).toList();
        await _analyzeUseCase(_lastNetworks);
      }

      final knownResult = await _repository.getKnownNetworks();
      final known = knownResult.getOrElse(() => []);
      final trustedResult = await _repository.getTrustedNetworkProfiles();
      final trusted = trustedResult.getOrElse(() => []);
      final eventsResult = await _repository.getSecurityEvents();
      final events = eventsResult.getOrElse(() => []);
      final score = _computeScore(_lastNetworks);
      final summary =
          _lastNetworks.isEmpty ? null : _buildSummary(_lastNetworks);
      final sessionResult = await _repository.getLatestAssessmentSession();
      final latestSession = sessionResult.getOrElse(() => null);

      if (isClosed) return;

      emit(
        SecurityLoaded(
          knownNetworks: known,
          trustedNetworkProfiles: trusted,
          recentEvents: events,
          overallScore: score,
          scanSummary: summary,
          latestSession: latestSession,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(SecurityError(e.toString()));
    }
  }

  Future<void> _onAnalyzeRequested(
    SecurityAnalyzeRequested event,
    Emitter<SecurityState> emit,
  ) async {
    try {
      _lastNetworks = event.networks;
      final isDeepScan =
          event.isDeepScan ?? _settingsStore.value.isDeepScanEnabled;

      final currentState = state;
      if (currentState is SecurityLoaded && isDeepScan) {
        emit(
          currentState.copyWith(isDeepScanning: true, isDeepScanEnabled: true),
        );
      }

      await _analyzeUseCase(event.networks, isDeepScan: isDeepScan);

      final knownResult = await _repository.getKnownNetworks();
      final known = knownResult.getOrElse(() => []);
      final trustedResult = await _repository.getTrustedNetworkProfiles();
      final trusted = trustedResult.getOrElse(() => []);
      final eventsResult = await _repository.getSecurityEvents();
      final events = eventsResult.getOrElse(() => []);
      final score = _computeScore(event.networks);
      final summary = _buildSummary(event.networks);

      final sessionResult = await _repository.getLatestAssessmentSession();
      final latestSession = sessionResult.getOrElse(() => null);

      if (isClosed) return;

      emit(
        SecurityLoaded(
          knownNetworks: known,
          trustedNetworkProfiles: trusted,
          recentEvents: events,
          overallScore: score,
          scanSummary: summary,
          isDeepScanEnabled: isDeepScan,
          isDeepScanning: false,
          latestSession: latestSession,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(SecurityError(e.toString()));
    }
  }

  Future<void> _onUntrustRequested(
    SecurityUntrustRequested event,
    Emitter<SecurityState> emit,
  ) async {
    try {
      await _repository.deleteTrustedNetworkProfile(event.bssid);

      final knownResult = await _repository.getKnownNetworks();
      final known = knownResult.getOrElse(() => []);
      final trustedResult = await _repository.getTrustedNetworkProfiles();
      final trusted = trustedResult.getOrElse(() => []);
      final eventsResult = await _repository.getSecurityEvents();
      final events = eventsResult.getOrElse(() => []);
      final score = _computeScore(_lastNetworks);
      final summary =
          _lastNetworks.isEmpty ? null : _buildSummary(_lastNetworks);
      final isDeepScan =
          state is SecurityLoaded
              ? (state as SecurityLoaded).isDeepScanEnabled
              : false;
      final dnsResult =
          state is SecurityLoaded ? (state as SecurityLoaded).dnsResult : null;

      final latestSession =
          state is SecurityLoaded
              ? (state as SecurityLoaded).latestSession
              : null;

      if (isClosed) return;

      emit(
        SecurityLoaded(
          knownNetworks: known,
          trustedNetworkProfiles: trusted,
          recentEvents: events,
          overallScore: score,
          scanSummary: summary,
          isDeepScanEnabled: isDeepScan,
          dnsResult: dnsResult,
          latestSession: latestSession,
        ),
      );
    } catch (e) {
      if (isClosed) return;
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
      openCount: networks.where((n) => n.security == SecurityType.open).length,
      wepCount: networks.where((n) => n.security == SecurityType.wep).length,
      wpsCount: networks.where((n) => n.hasWps == true).length,
    );
  }

  Future<void> _onDnsTestRequested(
    SecurityDnsTestRequested event,
    Emitter<SecurityState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SecurityLoaded) return;

    emit(currentState.copyWith(isDnsLoading: true));

    final result = await _dnsLeakTestUsecase(null);

    if (isClosed) return;

    result.fold(
      (failure) => emit(currentState.copyWith(isDnsLoading: false)),
      (dnsResult) => emit(
        currentState.copyWith(
          isDnsLoading: false,
          dnsResult: dnsResult,
          // Also update latestSession if it contains DNS results
          latestSession: currentState.latestSession?.copyWith(
            dnsResult: dnsResult,
          ),
        ),
      ),
    );
  }

  Future<void> _onDeepScanToggled(
    SecurityDeepScanToggled event,
    Emitter<SecurityState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SecurityLoaded) return;

    if (isClosed) return;

    // Update global settings to sync and persist
    if (_settingsStore.value.isDeepScanEnabled != event.value) {
      _settingsStore.update(
        _settingsStore.value.copyWith(isDeepScanEnabled: event.value),
      );
    }

    emit(currentState.copyWith(isDeepScanEnabled: event.value));

    // Trigger analysis with new setting
    add(SecurityAnalyzeRequested(_lastNetworks, isDeepScan: event.value));
  }
}
