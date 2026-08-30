import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/notification_context_extensions.dart';
import '../../../diagnostics/domain/entities/root_cause_category.dart';
import '../../../performance/presentation/pages/speed_hub_page.dart';
import '../../../ping_stabilizer/presentation/bloc/ping_stabilizer_cubit.dart';
import '../../../ping_stabilizer/presentation/widgets/stabilizer_toggle_card.dart';
import 'package:torcav/core/network/network_context_type.dart';
import '../../../security/domain/entities/security_assessment.dart';
import '../../../security/domain/services/network_context_resolver.dart';
import '../../../security/presentation/bloc/notification/notification_bloc.dart';
import '../../../security/presentation/extensions/vulnerability_extensions.dart';
import '../../../security/presentation/pages/router_hardening_wizard_page.dart';
import '../../../wifi_scan/domain/entities/channel_rating.dart';
import '../bloc/dashboard_cubit.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/activity_timeline.dart';
import '../widgets/health_hero_card.dart';
import '../widgets/live_metrics_bento.dart';
import '../widgets/radial_dashboard_core.dart';
import '../widgets/gamification_tasks_card.dart';
import 'notification_sheet.dart';

/// Dashboard — radial hero + bento metrics + activity timeline. Pulls live
/// data from every major feature (security, wifi scan, signal, speed test,
/// notifications) and animates value transitions.
class DashboardPage extends StatelessWidget {
  final void Function(String destination) onNavigate;
  final VoidCallback? onOpenDrawer;

  const DashboardPage({super.key, required this.onNavigate, this.onOpenDrawer});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return MultiBlocProvider(
      providers: [
        BlocProvider<DashboardCubit>(
          create: (_) => getIt<DashboardCubit>()..load(),
        ),
        BlocProvider<NotificationBloc>(
          create: (_) => getIt<NotificationBloc>()..add(LoadNotifications()),
        ),
      ],
      child: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          final isConnected = state is DashboardSuccess && state.isConnected;
          final accentColor = isConnected ? scheme.primary : scheme.error;
          final statusLabel =
              isConnected
                  ? l10n.connectedStatusCaps
                  : l10n.disconnectedStatusCaps;

          return Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              centerTitle: true,
              leading: Builder(
                builder:
                    (context) => IconButton(
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: scheme.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Icon(Icons.menu_rounded, size: 18),
                      ),
                      onPressed:
                          onOpenDrawer ??
                          () => Scaffold.of(context).openDrawer(),
                    ),
              ),
              title: NeonText(
                l10n.appTitle,
                style: GoogleFonts.orbitron(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: 4,
                  color: scheme.primary,
                ),
                glowRadius: 15,
              ),
              actions: [
                BlocConsumer<NotificationBloc, NotificationState>(
                  listener: (context, state) {
                    if (state is NotificationError) {
                      context.showError(state.message);
                    }
                  },
                  builder: (context, state) {
                    int unreadCount = 0;
                    if (state is NotificationLoaded) {
                      unreadCount = state.unreadCount;
                    }
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        NeonIconButton(
                          icon: Icons.notifications_none_rounded,
                          onTap: () => _showNotificationSheet(context),
                          tooltip: l10n.securityAlertsTooltip,
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: scheme.error,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                unreadCount > 9 ? '9+' : unreadCount.toString(),
                                style: GoogleFonts.rajdhani(
                                  color: scheme.onError,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: RefreshIndicator(
              color: scheme.primary,
              backgroundColor: scheme.surfaceContainerHigh,
              onRefresh: () => context.read<DashboardCubit>().load(),
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                children: [
                  if (state is DashboardLoading || state is DashboardInitial)
                    const Center(child: CircularProgressIndicator())
                  else if (state is DashboardSuccess) ...[
                    // ── Connection bar: status + SSID + signal, hero'nun
                    //    üstünde — tıklayınca detay açar, rozet bağlam seçer ──
                    StaggeredEntry(
                      delay: const Duration(milliseconds: 40),
                      child: _ConnectionBar(
                        isConnected: isConnected,
                        accentColor: accentColor,
                        statusLabel: statusLabel,
                        ssid: state.ssid,
                        needsLocationForSsid: state.needsLocationForSsid,
                        signalQualityPct: state.signalQualityPct,
                        networkContext:
                            state.connectedBssid != null
                                ? (state.connectedContext ??
                                    NetworkContextType.unknown)
                                : null,
                        onRefresh: () => context.read<DashboardCubit>().load(),
                        onTapContext:
                            () => _showContextOverrideSheet(context, state),
                        onShowDetails:
                            () => _showConnectionDetails(context, state),
                        onGrantLocation:
                            () => _grantLocationPermission(context),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ── Hero: health score + one plain-language action (P2) ──
                    StaggeredEntry(
                      delay: const Duration(milliseconds: 80),
                      child: HealthHeroCard(
                        score:
                            state.networkHealthScore?.totalScore ??
                            state.securityScore,
                        isConnected: isConnected,
                        diagnosis: state.diagnosis,
                        onTapScore:
                            () =>
                                state.worstAssessment != null
                                    ? _showScoreExplanation(
                                      context,
                                      state.worstAssessment!,
                                    )
                                    : onNavigate('security'),
                        onAction:
                            (category) => _handleHeroAction(context, category),
                        onFullDiagnosis: () => _openSpeedDoctor(context),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Advanced metrics — pro depth behind one tap (P2) ──
                    StaggeredEntry(
                      delay: const Duration(milliseconds: 240),
                      child: Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          childrenPadding: EdgeInsets.zero,
                          shape: const Border(),
                          collapsedShape: const Border(),
                          iconColor: scheme.tertiary,
                          collapsedIconColor: scheme.onSurfaceVariant,
                          title: NeonSectionHeader(
                            label: l10n.dashAdvancedMetrics,
                            color: scheme.tertiary,
                            icon: Icons.insights_rounded,
                          ),
                          children: [
                            const SizedBox(height: 8),

                            // ── Radial core with orbital gauges ──
                            Center(
                              child: RadialDashboardCore(
                                statusColor: accentColor,
                                label: statusLabel,
                                subLabel: state.ssid,
                                healthScore:
                                    state.networkHealthScore?.totalScore ??
                                    state.securityScore,
                                signalQualityPct: state.signalQualityPct,
                                threatCount: state.threatCount,
                                deviceCount: state.networkCount,
                                onTapHealth:
                                    () =>
                                        state.worstAssessment != null
                                            ? _showScoreExplanation(
                                              context,
                                              state.worstAssessment!,
                                            )
                                            : onNavigate('security'),
                                onTapSignal:
                                    () => onNavigate('monitor/channels'),
                                onTapThreats:
                                    () => _showNotificationSheet(context),
                                onTapDevices: () => onNavigate('wifi'),
                                onTapCore:
                                    () =>
                                        _showConnectionDetails(context, state),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // ── IP / Gateway compact strip ──
                            _NetworkIdStrip(
                              ssid: state.ssid,
                              ip: state.ip,
                              gateway: state.gateway,
                            ),

                            const SizedBox(height: 24),

                            // ── Gamification Recommended Tasks ──
                            if (state.networkHealthScore != null &&
                                state
                                    .networkHealthScore!
                                    .recommendedTasks
                                    .isNotEmpty) ...[
                              GamificationTasksCard(
                                tasks:
                                    state.networkHealthScore!.recommendedTasks,
                                onTapTask: (task) {
                                  if (task.deepLinkRoute != null) {
                                    onNavigate(task.deepLinkRoute!);
                                  }
                                },
                              ),
                              const SizedBox(height: 24),
                            ],

                            // ── Live Pulse: bento of mini metrics ──
                            NeonSectionHeader(
                              label: l10n.livePulse,
                              color: scheme.primary,
                              icon: Icons.monitor_heart_rounded,
                            ),
                            const SizedBox(height: 12),

                            LiveMetricsBento(
                              signalQualityPct: state.signalQualityPct,
                              rssiHistory: state.rssiHistory,
                              scoreHistory: state.scoreHistory,
                              channelRatings: state.channelRatings,
                              newDeviceCount: state.newDeviceCount,
                              recentEvents: state.recentEvents,
                              lastDownloadMbps:
                                  state.lastSpeedTest?.downloadMbps,
                              lastUploadMbps: state.lastSpeedTest?.uploadMbps,
                              lastSpeedTestAt: state.lastSpeedTest?.recordedAt,
                              onTapSignal: () => onNavigate('monitor/channels'),
                              onTapScore:
                                  () =>
                                      state.worstAssessment != null
                                          ? _showScoreExplanation(
                                            context,
                                            state.worstAssessment!,
                                          )
                                          : onNavigate('security'),
                              onTapChannels:
                                  () => onNavigate('monitor/channels'),
                              onTapDevices: () => onNavigate('wifi'),
                              onTapThreats:
                                  () => _showNotificationSheet(context),
                              onTapSpeed: () => onNavigate('performance'),
                            ),

                            const SizedBox(height: 20),

                            // ── Ping Stabilizer quick-toggle ──
                            BlocProvider<PingStabilizerCubit>.value(
                              value: getIt<PingStabilizerCubit>()..bootstrap(),
                              child: StabilizerToggleCard(
                                onTap: () => onNavigate('ping_stabilizer'),
                              ),
                            ),

                            const SizedBox(height: 28),

                            // ── Activity Timeline ──
                            NeonSectionHeader(
                              label: l10n.networkLogs,
                              color: scheme.tertiary,
                              icon: Icons.timeline_rounded,
                            ),
                            const SizedBox(height: 12),

                            ActivityTimeline(
                              snapshots: state.recentSnapshots,
                              events: state.recentEvents,
                              onNavigate: onNavigate,
                            ),

                            if (state.bestChannel != null) ...[
                              const SizedBox(height: 20),
                              _ChannelRecommendationCard(
                                best: state.bestChannel!,
                                currentChannel: state.currentChannel,
                                onTap: () => onNavigate('monitor/channels'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ] else if (state is DashboardFailure)
                    Center(child: Text(state.failure.message)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Routes the hero's single action to the tool where the user can act on
  /// the diagnosed root cause.
  void _handleHeroAction(BuildContext context, RootCauseCategory category) {
    switch (category) {
      case RootCauseCategory.crowdedChannel:
        onNavigate('monitor/channels');
      case RootCauseCategory.slowDns:
        onNavigate('ping_stabilizer');
      case RootCauseCategory.ispSlow:
        onNavigate('reports');
      case RootCauseCategory.bufferbloat:
        unawaited(
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const RouterHardeningWizardPage(),
            ),
          ),
        );
      case RootCauseCategory.weakSignal:
      case RootCauseCategory.healthy:
        _openSpeedDoctor(context);
    }
  }

  void _openSpeedDoctor(BuildContext context) {
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const SpeedHubPage(initialDiagnose: true),
        ),
      ),
    );
  }

  void _showScoreExplanation(
    BuildContext context,
    SecurityAssessment assessment,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ScoreExplanationSheet(assessment: assessment),
    );
  }

  /// Android SSID'yi konum izni olmadan gizler; izin verilince yeniden yükle.
  Future<void> _grantLocationPermission(BuildContext context) async {
    final status = await Permission.location.request();
    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
    if (!context.mounted) return;
    unawaited(context.read<DashboardCubit>().load());
  }

  void _showConnectionDetails(BuildContext context, DashboardSuccess state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (_) => _ConnectionDetailSheet(
            state: state,
            onTapContext: () {
              Navigator.pop(context);
              _showContextOverrideSheet(context, state);
            },
          ),
    );
  }

  void _showNotificationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (sheetContext) => BlocProvider.value(
            value: context.read<NotificationBloc>(),
            child: const NotificationSheet(),
          ),
    );
  }

  Future<void> _showContextOverrideSheet(
    BuildContext context,
    DashboardSuccess state,
  ) async {
    final bssid = state.connectedBssid;
    if (bssid == null) return;
    final resolver = getIt<NetworkContextResolver>();
    final selected = await showModalBottomSheet<_ContextSheetResult>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (_) => _NetworkContextSheet(
            current: state.connectedContext ?? NetworkContextType.unknown,
            ssid: state.ssid,
          ),
    );
    if (selected == null) return;
    if (selected.reset) {
      await resolver.clearOverride(bssid);
    } else if (selected.context != null) {
      await resolver.setOverride(bssid, selected.context!);
    }
    if (!context.mounted) return;
    unawaited(context.read<DashboardCubit>().load());
  }
}

// ── Connection bar above the hero ────────────────────────────────────

/// Hero'nun üstünde duran bağlantı şeridi: durum noktası + SSID + sinyal
/// yüzdesi + ağ bağlamı rozeti + yenile. Şeride dokunmak detay sayfası açar;
/// SSID gizliyse konum izni ipucu gösterir.
class _ConnectionBar extends StatelessWidget {
  final bool isConnected;
  final Color accentColor;
  final String statusLabel;
  final String ssid;
  final bool needsLocationForSsid;
  final int? signalQualityPct;
  final NetworkContextType? networkContext;
  final VoidCallback onRefresh;
  final VoidCallback onTapContext;
  final VoidCallback onShowDetails;
  final VoidCallback onGrantLocation;

  const _ConnectionBar({
    required this.isConnected,
    required this.accentColor,
    required this.statusLabel,
    required this.ssid,
    required this.needsLocationForSsid,
    required this.signalQualityPct,
    required this.networkContext,
    required this.onRefresh,
    required this.onTapContext,
    required this.onShowDetails,
    required this.onGrantLocation,
  });

  IconData get _signalIcon {
    final pct = signalQualityPct;
    if (pct == null || !isConnected) return Icons.wifi_off_rounded;
    if (pct >= 66) return Icons.wifi_rounded;
    if (pct >= 33) return Icons.wifi_2_bar_rounded;
    return Icons.wifi_1_bar_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final ssidHidden = isConnected && (ssid == '—' || ssid.isEmpty);

    return GlassmorphicContainer(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderColor: accentColor.withValues(alpha: 0.25),
      child: InkWell(
        onTap: needsLocationForSsid ? onGrantLocation : onShowDetails,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor,
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.6),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(_signalIcon, size: 16, color: accentColor),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isConnected
                        ? (ssidHidden ? l10n.dashSsidHidden : ssid)
                        : statusLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.rajdhani(
                      color: scheme.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (needsLocationForSsid)
                    Text(
                      l10n.dashGrantLocationHint,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.rajdhani(
                        color: accentColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else if (isConnected && signalQualityPct != null)
                    Text(
                      '${l10n.dashSignalLabel}: %$signalQualityPct',
                      style: GoogleFonts.rajdhani(
                        color: scheme.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
            if (networkContext != null) ...[
              const SizedBox(width: 8),
              _NetworkContextBadge(
                context: networkContext!,
                onTap: onTapContext,
              ),
            ],
            const SizedBox(width: 4),
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: Icon(
                Icons.refresh_rounded,
                size: 18,
                color: scheme.onSurfaceVariant,
              ),
              onPressed: onRefresh,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Connection detail sheet (opened by the bar & the radial core) ────

/// Bağlantı kimlik kartı: animasyonlu sinyal halkası + SSID/BSSID/IP/ağ geçidi
/// satırları. Her satıra dokunmak değeri panoya kopyalar.
class _ConnectionDetailSheet extends StatelessWidget {
  final DashboardSuccess state;
  final VoidCallback onTapContext;

  const _ConnectionDetailSheet({required this.state, required this.onTapContext});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final accent = state.isConnected ? scheme.primary : scheme.error;
    final ssidHidden = state.ssid == '—' || state.ssid.isEmpty;

    final rows = <_DetailRowSpec>[
      _DetailRowSpec(
        icon: Icons.wifi_rounded,
        label: l10n.ssidLabel,
        value: ssidHidden ? null : state.ssid,
        color: scheme.primary,
      ),
      _DetailRowSpec(
        icon: Icons.router_rounded,
        label: l10n.bssidHeader,
        value: state.connectedBssid,
        color: AppColors.neonPurple,
        mono: true,
      ),
      _DetailRowSpec(
        icon: Icons.lan_outlined,
        label: l10n.ipLabel,
        value: state.ip == '—' ? null : state.ip,
        color: scheme.secondary,
        mono: true,
      ),
      _DetailRowSpec(
        icon: Icons.dns_outlined,
        label: l10n.gatewayLabel,
        value: state.gateway == '—' ? null : state.gateway,
        color: scheme.tertiary,
        mono: true,
      ),
      if (state.currentChannel != null)
        _DetailRowSpec(
          icon: Icons.tune_rounded,
          label: l10n.dashSignalLabel,
          value:
              '${l10n.channelShort(state.currentChannel!)}'
              '${state.signalQualityPct != null ? ' · %${state.signalQualityPct}' : ''}',
          color: scheme.primary,
        ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: accent.withValues(alpha: 0.25)),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewPadding.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                NeonText(
                  l10n.dashConnDetailTitle,
                  style: GoogleFonts.orbitron(
                    color: scheme.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                  glowRadius: 6,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: accent.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    state.isConnected
                        ? l10n.connectedStatusCaps
                        : l10n.disconnectedStatusCaps,
                    style: GoogleFonts.orbitron(
                      color: accent,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _SignalRing(
              pct: state.signalQualityPct,
              color: accent,
              caption: ssidHidden ? l10n.dashSsidHidden : state.ssid,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.dashConnDetailCopyHint,
              style: GoogleFonts.rajdhani(
                color: scheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 12),
            for (final spec in rows) ...[
              _DetailRow(
                spec: spec,
                onCopied:
                    () => context.showSuccess(l10n.dashValueCopied(spec.label)),
              ),
              const SizedBox(height: 8),
            ],
            if (state.connectedBssid != null) ...[
              const SizedBox(height: 4),
              _NetworkContextBadge(
                context: state.connectedContext ?? NetworkContextType.unknown,
                onTap: onTapContext,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRowSpec {
  final IconData icon;
  final String label;
  final String? value;
  final Color color;
  final bool mono;

  const _DetailRowSpec({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.mono = false,
  });
}

class _DetailRow extends StatelessWidget {
  final _DetailRowSpec spec;
  final VoidCallback onCopied;

  const _DetailRow({required this.spec, required this.onCopied});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final value = spec.value;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap:
          value == null
              ? null
              : () {
                Clipboard.setData(ClipboardData(text: value));
                onCopied();
              },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: spec.color.withValues(alpha: 0.25)),
          color: spec.color.withValues(alpha: 0.04),
        ),
        child: Row(
          children: [
            Icon(spec.icon, size: 16, color: spec.color),
            const SizedBox(width: 10),
            Text(
              spec.label.toUpperCase(),
              style: GoogleFonts.orbitron(
                color: spec.color.withValues(alpha: 0.8),
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const Spacer(),
            Flexible(
              child: Text(
                value ?? '—',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    spec.mono
                        ? GoogleFonts.jetBrainsMono(
                          color: scheme.onSurface,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        )
                        : GoogleFonts.rajdhani(
                          color: scheme.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
              ),
            ),
            if (value != null) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.copy_rounded,
                size: 12,
                color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Animasyonlu sinyal halkası: yüzdeye göre dolan gradyan yay + halka üzerinde
/// süzülen tarayıcı noktası. RadialDashboardCore'un görsel dilini sürdürür.
class _SignalRing extends StatefulWidget {
  final int? pct;
  final Color color;
  final String caption;

  const _SignalRing({
    required this.pct,
    required this.color,
    required this.caption,
  });

  @override
  State<_SignalRing> createState() => _SignalRingState();
}

class _SignalRingState extends State<_SignalRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scan;

  @override
  void initState() {
    super.initState();
    _scan = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _scan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pct = widget.pct;

    return Column(
      children: [
        SizedBox(
          width: 150,
          height: 150,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: (pct ?? 0) / 100),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, fill, _) {
              return AnimatedBuilder(
                animation: _scan,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _SignalRingPainter(
                      fill: fill,
                      scan: _scan.value,
                      color: widget.color,
                      trackColor: scheme.onSurface.withValues(alpha: 0.08),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            pct == null
                                ? Icons.wifi_off_rounded
                                : Icons.wifi_rounded,
                            color: widget.color,
                            size: 22,
                          ),
                          const SizedBox(height: 4),
                          NeonText(
                            pct == null ? '—' : '%$pct',
                            style: GoogleFonts.orbitron(
                              color: widget.color,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                            glowColor: widget.color,
                            glowRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Text(
          widget.caption,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.rajdhani(
            color: scheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SignalRingPainter extends CustomPainter {
  final double fill; // 0..1
  final double scan; // 0..1
  final Color color;
  final Color trackColor;

  _SignalRingPainter({
    required this.fill,
    required this.scan,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = trackColor,
    );

    const start = -math.pi / 2;
    final sweep = 2 * math.pi * fill.clamp(0.0, 1.0);
    if (sweep > 0) {
      canvas.drawArc(
        rect,
        start,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round
          ..shader = SweepGradient(
            colors: [color.withValues(alpha: 0.25), color],
            transform: const GradientRotation(start),
          ).createShader(rect),
      );
    }

    // Halka üzerinde süzülen tarayıcı noktası
    final dotAngle = start + 2 * math.pi * scan;
    final dotPos = Offset(
      center.dx + math.cos(dotAngle) * radius,
      center.dy + math.sin(dotAngle) * radius,
    );
    canvas.drawCircle(
      dotPos,
      5,
      Paint()..color = color.withValues(alpha: 0.25),
    );
    canvas.drawCircle(dotPos, 2.5, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _SignalRingPainter old) =>
      old.fill != fill || old.scan != scan || old.color != color;
}

// ── Compact identity strip below the radial hero ─────────────────────

class _NetworkIdStrip extends StatelessWidget {
  final String ssid;
  final String ip;
  final String gateway;

  const _NetworkIdStrip({
    required this.ssid,
    required this.ip,
    required this.gateway,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return GlassmorphicContainer(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      borderColor: scheme.primary.withValues(alpha: 0.2),
      child: Row(
        children: [
          Expanded(
            child: _InlineId(
              icon: Icons.wifi_rounded,
              label: l10n.ssidLabel,
              value: ssid,
              color: scheme.primary,
            ),
          ),
          Container(
            width: 1,
            height: 30,
            color: scheme.onSurface.withValues(alpha: 0.08),
          ),
          Expanded(
            child: _InlineId(
              icon: Icons.lan_outlined,
              label: l10n.ipLabel,
              value: ip,
              color: scheme.secondary,
            ),
          ),
          Container(
            width: 1,
            height: 30,
            color: scheme.onSurface.withValues(alpha: 0.08),
          ),
          Expanded(
            child: _InlineId(
              icon: Icons.router_outlined,
              label: l10n.gatewayLabel,
              value: gateway,
              color: scheme.tertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineId extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InlineId({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 11),
              const SizedBox(width: 4),
              Text(
                label.toUpperCase(),
                style: GoogleFonts.orbitron(
                  color: color.withValues(alpha: 0.8),
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.rajdhani(
              color: scheme.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Score Explanation Sheet (kept from previous design) ──────────────

class _ScoreExplanationSheet extends StatelessWidget {
  final SecurityAssessment assessment;
  const _ScoreExplanationSheet({required this.assessment});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final findings = assessment.evidenceFindings;

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: scheme.primary.withValues(alpha: 0.2)),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    NeonText(
                      context.l10n.securityScoreTitle.toUpperCase(),
                      style: GoogleFonts.orbitron(
                        color: scheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                      glowRadius: 6,
                    ),
                    const Spacer(),
                    NeonText(
                      '${assessment.score}%',
                      style: GoogleFonts.orbitron(
                        color: _scoreColor(scheme),
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                      glowColor: _scoreColor(scheme),
                      glowRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              Expanded(
                child:
                    findings.isEmpty
                        ? Center(
                          child: Text(
                            context.l10n.noSecurityFindings,
                            style: GoogleFonts.rajdhani(
                              color: scheme.onSurfaceVariant,
                              fontSize: 14,
                            ),
                          ),
                        )
                        : ListView.separated(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                          itemCount: findings.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, i) {
                            final f = findings[i];
                            final vulnerability = f.toVulnerability();
                            final title = vulnerability.localizedTitle(context);
                            final recommendation = vulnerability
                                .localizedRecommendation(context);
                            final color = _severityColor(
                              f.severity.name,
                              scheme,
                            );
                            return GlassmorphicContainer(
                              borderColor: color.withValues(alpha: 0.25),
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.only(top: 4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: color,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: GoogleFonts.orbitron(
                                            color: scheme.onSurface,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          recommendation,
                                          style: GoogleFonts.rajdhani(
                                            color: scheme.onSurfaceVariant,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _scoreColor(ColorScheme scheme) {
    if (assessment.score >= 85) return scheme.primary;
    if (assessment.score >= 60) return const Color(0xFFFFB300);
    return scheme.error;
  }

  Color _severityColor(String severity, ColorScheme scheme) {
    switch (severity) {
      case 'critical':
        return scheme.error;
      case 'high':
        return Colors.orange;
      case 'medium':
        return const Color(0xFFFFB300);
      default:
        return scheme.primary;
    }
  }
}

// ── Channel recommendation card (kept from previous design) ──────────

class _ChannelRecommendationCard extends StatelessWidget {
  final ChannelRating best;
  final int? currentChannel;
  final VoidCallback onTap;

  const _ChannelRecommendationCard({
    required this.best,
    required this.currentChannel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final color = scheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: GlassmorphicContainer(
        borderColor: color.withValues(alpha: 0.3),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.1),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Icon(Icons.tune_rounded, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.channelRecommendation,
                    style: GoogleFonts.orbitron(
                      color: color.withValues(alpha: 0.7),
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    l10n.switchToChannel(best.channel),
                    style: GoogleFonts.rajdhani(
                      color: scheme.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (currentChannel != null)
                    Text(
                      l10n.channelCongestionHint,
                      style: GoogleFonts.rajdhani(
                        color: scheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            NeonText(
              l10n.channelShort(best.channel),
              style: GoogleFonts.orbitron(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
              glowColor: color,
              glowRadius: 5,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Network context badge + override sheet ──────────────────────────

class _ContextSheetResult {
  final NetworkContextType? context;
  final bool reset;
  const _ContextSheetResult({this.context, this.reset = false});
}

Color _contextColor(NetworkContextType ctx, ColorScheme scheme) =>
    switch (ctx) {
      NetworkContextType.home => scheme.primary,
      NetworkContextType.public => scheme.error,
      NetworkContextType.guest => scheme.tertiary,
      NetworkContextType.unknown => scheme.onSurfaceVariant,
    };

IconData _contextIcon(NetworkContextType ctx) => switch (ctx) {
  NetworkContextType.home => Icons.home_rounded,
  NetworkContextType.public => Icons.public_rounded,
  NetworkContextType.guest => Icons.group_rounded,
  NetworkContextType.unknown => Icons.help_outline_rounded,
};

class _NetworkContextBadge extends StatelessWidget {
  final NetworkContextType context;
  final VoidCallback onTap;

  const _NetworkContextBadge({required this.context, required this.onTap});

  @override
  Widget build(BuildContext buildContext) {
    final scheme = Theme.of(buildContext).colorScheme;
    final color = _contextColor(context, scheme);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_contextIcon(context), size: 14, color: color),
            const SizedBox(width: 8),
            Text(
              _getNetworkContextLabel(buildContext, context).toUpperCase(),
              style: GoogleFonts.orbitron(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.tune_rounded,
              size: 12,
              color: color.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}

class _NetworkContextSheet extends StatelessWidget {
  final NetworkContextType current;
  final String ssid;

  const _NetworkContextSheet({required this.current, required this.ssid});

  List<(NetworkContextType, String)> _options(AppLocalizations l10n) => [
    (NetworkContextType.home, l10n.networkContextHomeDesc),
    (NetworkContextType.public, l10n.networkContextPublicDesc),
    (NetworkContextType.guest, l10n.networkContextGuestDesc),
    (NetworkContextType.unknown, l10n.networkContextUnknownDesc),
  ];

  @override
  Widget build(BuildContext buildContext) {
    final l10n = AppLocalizations.of(buildContext)!;
    final scheme = Theme.of(buildContext).colorScheme;
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: scheme.primary.withValues(alpha: 0.2)),
            ),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              NeonText(
                l10n.networkContextTitle,
                style: GoogleFonts.orbitron(
                  color: scheme.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
                glowRadius: 6,
              ),
              const SizedBox(height: 4),
              Text(
                ssid,
                style: GoogleFonts.rajdhani(
                  color: scheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              for (final option in _options(l10n))
                _ContextOption(
                  type: option.$1,
                  description: option.$2,
                  selected: option.$1 == current,
                  onTap: () {
                    Navigator.pop(
                      buildContext,
                      _ContextSheetResult(context: option.$1),
                    );
                  },
                ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.pop(
                    buildContext,
                    const _ContextSheetResult(reset: true),
                  );
                },
                child: Text(
                  l10n.resetToInferred,
                  style: GoogleFonts.rajdhani(
                    color: scheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ContextOption extends StatelessWidget {
  final NetworkContextType type;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  const _ContextOption({
    required this.type,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = _contextColor(type, scheme);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  selected
                      ? color.withValues(alpha: 0.6)
                      : scheme.outlineVariant.withValues(alpha: 0.3),
              width: selected ? 2 : 1,
            ),
            color: selected ? color.withValues(alpha: 0.06) : null,
          ),
          child: Row(
            children: [
              Icon(_contextIcon(type), color: color, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getNetworkContextLabel(context, type).toUpperCase(),
                      style: GoogleFonts.orbitron(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.rajdhani(
                        color: scheme.onSurface,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle_rounded, color: color, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

String _getNetworkContextLabel(BuildContext context, NetworkContextType type) {
  final l10n = context.l10n;
  return switch (type.labelKey) {
    'networkContextHomeLabel' => l10n.networkContextHomeLabel,
    'networkContextPublicLabel' => l10n.networkContextPublicLabel,
    'networkContextGuestLabel' => l10n.networkContextGuestLabel,
    'networkContextUnknownLabel' => l10n.networkContextUnknownLabel,
    _ => type.labelKey,
  };
}
