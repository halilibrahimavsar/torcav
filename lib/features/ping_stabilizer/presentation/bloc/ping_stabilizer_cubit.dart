import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/l10n/locale_cubit.dart';
import '../../../../core/logging/app_logger.dart';
import '../../data/datasources/ping_stabilizer_settings_store.dart';
import '../../domain/entities/dns_candidate.dart';
import '../../domain/entities/jitter_sample.dart';
import '../../domain/entities/live_stats.dart';
import '../../domain/entities/stabilization_profile.dart';
import '../../domain/entities/stabilizer_recommendation.dart';
import '../../domain/repositories/ping_stabilizer_repository.dart';
import '../../domain/usecases/apply_dns_usecase.dart';
import '../../domain/usecases/baseline_ping_usecase.dart';
import '../../domain/usecases/benchmark_dns_usecase.dart';
import '../../domain/usecases/list_profiles_usecase.dart';
import '../../domain/usecases/observe_live_stats_usecase.dart';
import '../../domain/usecases/start_stabilization_usecase.dart';
import '../../domain/usecases/stop_stabilization_usecase.dart';
import 'ping_stabilizer_state.dart';

/// Singleton: the tunnel itself is process-global (one VpnService at a time)
/// so the cubit's state must be too. Multiple BlocProviders (dashboard tile +
/// dedicated page) share this single instance via `BlocProvider.value`.
@lazySingleton
class PingStabilizerCubit extends Cubit<PingStabilizerState> {
  final StartStabilizationUseCase _start;
  final StopStabilizationUseCase _stop;
  final ObserveLiveStatsUseCase _observe;
  final BenchmarkDnsUseCase _benchmarkDns;
  final ApplyDnsUseCase _applyDns;
  final ListProfilesUseCase _listProfiles;
  final BaselinePingUseCase _baseline;
  final PingStabilizerRepository _repository;
  final PingStabilizerSettingsStore _settings;

  StreamSubscription? _statsSub;
  StreamSubscription? _stoppedSub;
  bool _bootstrapped = false;

  /// Number of consecutive over-threshold samples before a reconnect
  /// recommendation fires. Three samples ≈ 3 s at 1 Hz — long enough to ride
  /// out one-shot spikes, short enough to react to a sticky bad path.
  static const int _breachWindow = 3;

  /// Watchdog: native tarafın çöktüğünü `tunnelStopped` event'i bize ulaşmadan
  /// fark edebilmek için, sample stream'inin sessiz kaldığı süreyi izleriz.
  /// Sample'lar normalde ~1 Hz akar; [_silenceThreshold] üst sınırı aşıldığında
  /// native tünelin öldüğünü varsayıp [_onNativeStopped] çalıştırırız.
  Timer? _healthCheckTimer;
  DateTime _lastSampleTime = DateTime.now();
  static const Duration _healthCheckInterval = Duration(seconds: 30);
  static const Duration _silenceThreshold = Duration(seconds: 35);

  PingStabilizerCubit(
    this._start,
    this._stop,
    this._observe,
    this._benchmarkDns,
    this._applyDns,
    this._listProfiles,
    this._baseline,
    this._repository,
    this._settings,
  ) : super(
        PingStabilizerState.initial().copyWith(
          autoSwitchDns: _settings.autoSwitchDns,
          jitterThresholdMs: _settings.jitterThresholdMs,
        ),
      ) {
    // Always-on listener for native-driven teardown (notification "Stop"
    // action, system VPN revoke). The stream is broadcast and replays no
    // events, so this is safe to wire up immediately.
    _stoppedSub = _repository.observeTunnelStopped().listen((_) {
      _onNativeStopped();
    });
  }

  void _onNativeStopped() {
    if (isClosed) return;
    _healthCheckTimer?.cancel();
    _healthCheckTimer = null;
    _statsSub?.cancel();
    _statsSub = null;
    emit(
      state.copyWith(
        status: StabilizerStatus.idle,
        stats: LiveStats.empty(),
        recommendations: const [],
        clearSession: true,
      ),
    );
  }

  /// Idempotent. Called from every UI surface that mounts a
  /// PingStabilizerCubit consumer; subsequent calls are no-ops because the
  /// cubit is a singleton and the bootstrap pings should only run once.
  Future<void> bootstrap() async {
    if (_bootstrapped || isClosed) return;
    _bootstrapped = true;

    final profilesEither = await _listProfiles();
    if (isClosed) return;
    final profiles = profilesEither.getOrElse(
      () => StabilizationProfile.builtIns(),
    );
    // Restore the last-selected profile from disk; falls back to first.
    final savedId = _settings.selectedProfileId;
    final initialProfile =
        (savedId == null)
            ? profiles.first
            : profiles.firstWhere(
              (p) => p.id == savedId,
              orElse: () => profiles.first,
            );
    emit(
      state.copyWith(
        profiles: profiles,
        profile: state.profile ?? initialProfile,
        dnsCandidates: DnsCandidate.defaults,
      ),
    );

    // Pre-tunnel baseline so the user sees a "before/after" delta on start.
    final baseline = await _baseline();
    if (isClosed) return;
    baseline.fold(
      (_) {},
      (rttMs) => emit(state.copyWith(baselineLatencyMs: rttMs)),
    );

    // Pre-bench candidate DNS resolvers.
    final benched = await _benchmarkDns();
    if (isClosed) return;
    benched.fold((_) {}, (list) {
      final ranked = BenchmarkDnsUseCase.rank(list);
      emit(
        state.copyWith(
          dnsCandidates: ranked,
          activeDns: ranked.isNotEmpty ? ranked.first : null,
        ),
      );
    });
  }

  Future<void> startStabilizer() async {
    final profile = state.profile;
    if (profile == null) return;
    emit(state.copyWith(status: StabilizerStatus.starting, clearError: true));

    // Android 13+ requires POST_NOTIFICATIONS at runtime; without it the
    // foreground HUD won't render even though the foreground service is up.
    // We ask once on first start; user can deny — VPN still works, just
    // without the in-shade ping HUD.
    if (Platform.isAndroid) {
      var status = await Permission.notification.status;
      if (status.isDenied) {
        status = await Permission.notification.request();
      }
      if (isClosed) return;
      // Granted normally; denied → user can still run the tunnel but won't
      // see the live HUD. permanentlyDenied → must use system settings.
      // MIUI sometimes reports `granted` while sub-toggles (lock-screen,
      // floating, banner) are off — we surface a banner regardless when
      // the user reports they cannot see the HUD.
      emit(state.copyWith(notificationsBlocked: !status.isGranted));
    }

    final result = await _start(profile);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: StabilizerStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (session) {
        emit(
          state.copyWith(
            status: StabilizerStatus.active,
            session: session,
            stats: LiveStats.empty(),
          ),
        );
        _statsSub?.cancel();
        _statsSub = _observe().listen(_onSample);

        // Watchdog: tunnelStopped event'i gelmezse sample sessizliğinden anla.
        _lastSampleTime = DateTime.now();
        _healthCheckTimer?.cancel();
        _healthCheckTimer = Timer.periodic(_healthCheckInterval, (_) {
          if (isClosed) return;
          final silent = DateTime.now().difference(_lastSampleTime);
          if (silent > _silenceThreshold) {
            AppLogger.w(
              'PingStabilizer: native sample timeout '
              '(${silent.inSeconds}s) — assuming tunnel down',
            );
            _onNativeStopped();
          }
        });

        // Push the resolved active DNS down to the native tunnel so its
        // interceptor uses the fastest one immediately.
        final dns = state.activeDns;
        if (dns != null) {
          unawaited(_applyDns(dns));
        }

        // Arm the native alert engine: thresholds, candidate resolvers and
        // localized notification strings. From here on the native service
        // evaluates jitter/loss/DNS rules and posts alerts itself, so they
        // keep working after this isolate is killed.
        unawaited(_pushNativeConfig());
      },
    );
  }

  /// Ships current settings + localized notification templates to the
  /// native alert engine. `{jitter}`, `{threshold}`, `{dns}`, `{delta}` and
  /// `{loss}` placeholders are substituted natively at fire time.
  Future<void> _pushNativeConfig() async {
    Map<String, String> strings;
    try {
      final l10n = lookupAppLocalizations(getIt<LocaleCubit>().state);
      strings = {
        'jitterTitle': l10n.stabilizerJitterSpikeTitle,
        'jitterBody': l10n.stabilizerNativeJitterBody(
          '{jitter}',
          '{threshold}',
        ),
        'dnsTitle': l10n.stabilizerFasterDnsTitle,
        'dnsBody': l10n.stabilizerFasterDnsBody('{dns}'),
        'dnsSwitchedTitle': l10n.stabilizerDnsSwitchedTitle,
        'dnsSwitchedBody': l10n.stabilizerDnsSwitchedBody('{dns}', '{delta}'),
        'lossTitle': l10n.stabilizerPacketLossTitle,
        'lossBody': l10n.stabilizerPacketLossBody('{loss}'),
        'alertChannelName': l10n.stabilizerAlertChannelName,
        'alertChannelDesc': l10n.stabilizerAlertChannelDesc,
        'hudChannelName': l10n.pingStabilizerTitle,
        'hudChannelDesc': l10n.stabilizerHudChannelDesc,
        'hudMeasuring': l10n.stabilizerHudMeasuring,
        'hudBody': l10n.stabilizerHudBody('{dns}'),
        'actionCycle': l10n.stabilizerActionCycle,
        'actionStop': l10n.stabilizerActionStop,
      };
    } catch (_) {
      // DI/locale unavailable (unit tests, early boot edge). The native
      // engine has built-in English fallbacks for every key.
      strings = const {};
    }
    try {
      await _repository.pushNativeConfig(
        jitterThresholdMs: state.jitterThresholdMs,
        autoSwitchDns: state.autoSwitchDns,
        candidates:
            state.dnsCandidates.isNotEmpty
                ? state.dnsCandidates
                : DnsCandidate.defaults,
        notificationStrings: strings,
      );
    } catch (e) {
      AppLogger.d('PingStabilizer: native config push failed: $e');
    }
  }

  Future<void> stopStabilizer() async {
    emit(state.copyWith(status: StabilizerStatus.stopping));
    _healthCheckTimer?.cancel();
    _healthCheckTimer = null;
    await _statsSub?.cancel();
    _statsSub = null;
    await _stop();
    emit(
      state.copyWith(
        status: StabilizerStatus.idle,
        stats: LiveStats.empty(),
        recommendations: const [],
        clearSession: true,
      ),
    );
  }

  /// Opens the OS notification settings page for this app. On MIUI this is
  /// the right entry point because Xiaomi exposes per-toggle controls
  /// (lock screen, floating, banner) that the standard runtime permission
  /// prompt does not surface.
  Future<void> openNotificationSettings() async {
    await openAppSettings();
  }

  void selectProfile(StabilizationProfile profile) {
    emit(state.copyWith(profile: profile));
    unawaited(_settings.setSelectedProfileId(profile.id));
  }

  Future<void> selectDns(DnsCandidate candidate) async {
    emit(state.copyWith(activeDns: candidate));
    await _applyDns(candidate);
  }

  void setAutoSwitchDns(bool enabled) {
    emit(state.copyWith(autoSwitchDns: enabled));
    unawaited(_settings.setAutoSwitchDns(enabled));
    unawaited(_pushNativeConfig());
  }

  void setJitterThreshold(double ms) {
    emit(state.copyWith(jitterThresholdMs: ms));
    unawaited(_settings.setJitterThresholdMs(ms));
    unawaited(_pushNativeConfig());
  }

  void dismissRecommendation(StabilizerRecommendation rec) {
    final next = state.recommendations.where((r) => r != rec).toList();
    emit(state.copyWith(recommendations: next));
  }

  Future<void> acceptRecommendation(StabilizerRecommendation rec) async {
    switch (rec.type) {
      case RecommendationType.switchDns:
        final ip = rec.payload['ip'] as String?;
        if (ip == null) break;
        final candidate = state.dnsCandidates.firstWhere(
          (c) => c.ip == ip,
          orElse: () => DnsCandidate(ip: ip, label: ip),
        );
        await selectDns(candidate);
      case RecommendationType.reconnectTunnel:
        await stopStabilizer();
        await startStabilizer();
      case RecommendationType.suggestDual:
        // Phase 2: enable dual-interface on active profile.
        break;
    }
    dismissRecommendation(rec);
  }

  void _onSample(JitterSample sample) {
    _lastSampleTime = DateTime.now();

    // Mirror DNS switches made by the native alert engine (auto-switch runs
    // natively so it survives process death; the UI just follows along).
    var activeDns = state.activeDns;
    final nativeIp = sample.activeDnsIp;
    if (nativeIp != null && nativeIp.isNotEmpty && nativeIp != activeDns?.ip) {
      activeDns = state.dnsCandidates.firstWhere(
        (c) => c.ip == nativeIp,
        orElse: () => DnsCandidate(ip: nativeIp, label: nativeIp),
      );
    }

    final updated = state.stats.add(sample, activeDns: activeDns);
    // System notifications for these recommendations are posted by the
    // native StabilizerAlertEngine (it outlives this isolate); here we only
    // maintain the in-app recommendation cards.
    final recs = _evaluateRecommendations(updated);
    emit(
      state.copyWith(stats: updated, recommendations: recs, activeDns: activeDns),
    );
  }

  List<StabilizerRecommendation> _evaluateRecommendations(LiveStats s) {
    final l10n = lookupAppLocalizations(getIt<LocaleCubit>().state);
    final recs = <StabilizerRecommendation>[];

    if (s.jitterBreached(state.jitterThresholdMs, _breachWindow)) {
      recs.add(
        StabilizerRecommendation(
          type: RecommendationType.reconnectTunnel,
          severity: RecommendationSeverity.warning,
          message: l10n.stabilizerJitterSpikeBody(
            state.jitterThresholdMs.toStringAsFixed(0),
            _breachWindow,
          ),
        ),
      );
    }

    final active = s.activeDns;
    final ranked = BenchmarkDnsUseCase.rank(state.dnsCandidates);
    if (active != null && ranked.isNotEmpty) {
      final best = ranked.first;
      final activeRtt = active.lastRttMs ?? double.infinity;
      final bestRtt = best.lastRttMs ?? double.infinity;
      if (best.ip != active.ip && bestRtt * 1.5 < activeRtt) {
        recs.add(
          StabilizerRecommendation(
            type: RecommendationType.switchDns,
            severity: RecommendationSeverity.info,
            message: l10n.stabilizerFasterDnsBody(best.label),
            payload: {'ip': best.ip},
          ),
        );
      }
    }

    if (s.lossPct > 1.0) {
      recs.add(
        StabilizerRecommendation(
          type: RecommendationType.suggestDual,
          severity: RecommendationSeverity.info,
          message: l10n.stabilizerPacketLossBody(s.lossPct.toStringAsFixed(1)),
        ),
      );
    }
    return recs;
  }

  @override
  Future<void> close() async {
    _healthCheckTimer?.cancel();
    await _statsSub?.cancel();
    await _stoppedSub?.cancel();
    return super.close();
  }
}
