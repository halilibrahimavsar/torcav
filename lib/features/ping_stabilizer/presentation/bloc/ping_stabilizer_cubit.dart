import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/l10n/locale_cubit.dart';
import '../../../../core/services/notification_service.dart';
import '../../data/datasources/ping_stabilizer_settings_store.dart';
import '../../domain/entities/dns_candidate.dart';
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
  final NotificationService _notifications;
  final PingStabilizerRepository _repository;
  final PingStabilizerSettingsStore _settings;

  StreamSubscription? _statsSub;
  StreamSubscription? _stoppedSub;
  final Set<String> _notifiedKeys = {};
  bool _bootstrapped = false;

  /// Number of consecutive over-threshold samples before a reconnect
  /// recommendation fires. Three samples ≈ 3 s at 1 Hz — long enough to ride
  /// out one-shot spikes, short enough to react to a sticky bad path.
  static const int _breachWindow = 3;

  PingStabilizerCubit(
    this._start,
    this._stop,
    this._observe,
    this._benchmarkDns,
    this._applyDns,
    this._listProfiles,
    this._baseline,
    this._notifications,
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
    _statsSub?.cancel();
    _statsSub = null;
    _notifiedKeys.clear();
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

        // Push the resolved active DNS down to the native tunnel so its
        // interceptor uses the fastest one immediately.
        final dns = state.activeDns;
        if (dns != null) {
          unawaited(_applyDns(dns));
        }
      },
    );
  }

  Future<void> stopStabilizer() async {
    emit(state.copyWith(status: StabilizerStatus.stopping));
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
  }

  void setJitterThreshold(double ms) {
    emit(state.copyWith(jitterThresholdMs: ms));
    unawaited(_settings.setJitterThresholdMs(ms));
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

  void _onSample(sample) {
    final updated = state.stats.add(sample, activeDns: state.activeDns);
    final recs = _evaluateRecommendations(updated);
    emit(state.copyWith(stats: updated, recommendations: recs));

    final l10n = lookupAppLocalizations(getIt<LocaleCubit>().state);

    // Surface new (not previously seen this session) recommendations as
    // system notifications so the user is informed even when the page is
    // backgrounded. Auto-dismiss-style suppression via the _notifiedKeys
    // set prevents toast spam when the same condition holds for many
    // consecutive samples.
    for (final r in recs) {
      final key = r.type.name;
      if (_notifiedKeys.add(key)) {
        unawaited(
          _notifications.showStabilizerAlert(
            title: switch (r.type) {
              RecommendationType.switchDns => l10n.stabilizerFasterDnsTitle,
              RecommendationType.reconnectTunnel =>
                l10n.stabilizerJitterSpikeTitle,
              RecommendationType.suggestDual => l10n.stabilizerPacketLossTitle,
            },
            body: r.message,
            actionable: r.type != RecommendationType.suggestDual,
          ),
        );
      }
    }
    // Clear keys whose recommendation has gone away so they can re-fire
    // next time the condition reappears.
    _notifiedKeys.removeWhere((k) => !recs.any((r) => r.type.name == k));

    // Auto-apply DNS swap when user opted in.
    final auto = state.autoSwitchDns;
    if (auto) {
      final swap = recs.firstWhere(
        (r) => r.type == RecommendationType.switchDns,
        orElse:
            () => StabilizerRecommendation(
              type: RecommendationType.switchDns,
              severity: RecommendationSeverity.info,
              message: '',
            ),
      );
      final ip = swap.payload['ip'] as String?;
      if (ip != null && ip.isNotEmpty) {
        unawaited(acceptRecommendation(swap));
      }
    }
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
    await _statsSub?.cancel();
    await _stoppedSub?.cancel();
    return super.close();
  }
}
