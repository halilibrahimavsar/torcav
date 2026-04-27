import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:network_info_plus/network_info_plus.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../heatmap/domain/entities/connected_signal.dart';
import '../../../heatmap/domain/services/connected_signal_service.dart';
import '../../../performance/domain/entities/speed_test_result.dart';
import '../../../performance/domain/repositories/speed_test_history_repository.dart';
import '../../../security/domain/entities/security_assessment.dart';
import '../../../security/domain/entities/security_event.dart';
import '../../../security/domain/repositories/security_repository.dart';
import '../../../security/domain/usecases/security_analyzer.dart';
import '../../../security/presentation/bloc/notification/notification_bloc.dart';
import '../../../wifi_scan/domain/entities/channel_rating.dart';
import '../../../wifi_scan/domain/entities/scan_snapshot.dart';
import '../../../wifi_scan/domain/entities/wifi_network.dart';
import '../../../wifi_scan/domain/services/channel_rating_engine.dart';
import '../../../wifi_scan/domain/services/scan_session_store.dart';
import '../../data/datasources/score_history_local_data_source.dart';
import '../widgets/activity_timeline.dart';
import '../widgets/live_metrics_bento.dart';
import '../widgets/radial_dashboard_core.dart';
import 'notification_sheet.dart';

/// Dashboard — radial hero + bento metrics + activity timeline. Pulls live
/// data from every major feature (security, wifi scan, signal, speed test,
/// notifications) and animates value transitions.
class DashboardPage extends StatefulWidget {
  final void Function(String destination) onNavigate;
  final VoidCallback? onOpenDrawer;

  const DashboardPage({super.key, required this.onNavigate, this.onOpenDrawer});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _ssid = '—';
  String _ip = '—';
  String _gateway = '—';
  int _networkCount = 0;
  bool _loading = true;
  int _securityScore = 100;
  int? _signalQualityPct;
  int _threatCount = 0;
  int _newDeviceCount = 0;

  ChannelRating? _bestChannel;
  int? _currentChannel;
  List<ChannelRating> _channelRatings = const [];

  SecurityAssessment? _worstAssessment;
  List<int> _scoreHistory = const [];
  List<int> _rssiHistory = const [];
  List<SecurityEvent> _recentEvents = const [];
  List<ScanSnapshot> _recentSnapshots = const [];
  SpeedTestResult? _lastSpeedTest;

  StreamSubscription<ScanSnapshot>? _scanSub;
  late final NotificationBloc _notificationBloc;

  @override
  void initState() {
    super.initState();
    _notificationBloc = getIt<NotificationBloc>()..add(LoadNotifications());
    _loadNetworkInfo();
    _scanSub =
        getIt<ScanSessionStore>().snapshots.listen((_) => _loadNetworkInfo());
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    _notificationBloc.close();
    super.dispose();
  }

  Future<void> _loadNetworkInfo() async {
    try {
      final info = getIt<NetworkInfo>();
      final results = await Future.wait([
        info.getWifiName(),
        info.getWifiIP(),
        info.getWifiGatewayIP(),
      ]);

      final store = getIt<ScanSessionStore>();
      final allSnapshots = store.all;
      final latestSnapshot = store.latest;
      final networks =
          latestSnapshot?.networks.map((n) => n.toWifiNetwork()).toList() ??
              <WifiNetwork>[];

      // ── Security score ──
      int secScore = 100;
      SecurityAssessment? worstAssessment;
      if (networks.isNotEmpty) {
        final analyzer = getIt<SecurityAnalyzer>();
        final assessments = networks
            .map((n) => analyzer.assess(n, localBaseline: networks))
            .toList();
        worstAssessment =
            assessments.reduce((a, b) => a.score < b.score ? a : b);
        secScore = worstAssessment.score;
      }

      // ── Snapshot diff ──
      int newDeviceCount = 0;
      if (allSnapshots.length >= 2) {
        final prev = allSnapshots[allSnapshots.length - 2];
        final prevBssids = prev.networks.map((n) => n.bssid).toSet();
        final latestBssids =
            latestSnapshot!.networks.map((n) => n.bssid).toSet();
        newDeviceCount = latestBssids.difference(prevBssids).length;
      }

      // ── Score history ──
      final scoreStore = getIt<ScoreHistoryLocalDataSource>();
      if (networks.isNotEmpty) {
        await scoreStore.saveScore(secScore);
      }
      final recentScores = await scoreStore.getRecentScores();
      final scoreHistory = recentScores.map((e) => e.score).toList();

      // ── Channel ratings + best-channel recommendation ──
      List<ChannelRating> ratings = const [];
      ChannelRating? bestCh;
      int? currentCh;
      final ssid = _cleanSsid(results[0]) ?? '';
      if (networks.isNotEmpty) {
        final engine = getIt<ChannelRatingEngine>();
        ratings = engine.calculateRatings(networks);
        final connected = networks.where((n) => n.ssid == ssid).toList();
        if (connected.isNotEmpty) {
          currentCh = connected.first.channel;
          final band24 = ratings.where((r) => r.frequency < 4000).toList()
            ..sort((a, b) => b.rating.compareTo(a.rating));
          final band5 = ratings
              .where((r) => r.frequency >= 4000 && r.frequency < 6000)
              .toList()
            ..sort((a, b) => b.rating.compareTo(a.rating));
          final sameBand = connected.first.frequency < 4000 ? band24 : band5;
          if (sameBand.isNotEmpty &&
              sameBand.first.channel != currentCh &&
              sameBand.first.rating > 7.0) {
            bestCh = sameBand.first;
          }
        }
      }

      // ── Connected signal RSSI ──
      ConnectedSignal? signal;
      try {
        signal = await getIt<ConnectedSignalService>().getConnectedSignal();
      } catch (_) {
        signal = null;
      }
      final qualityPct = signal == null
          ? null
          : (((signal.rssi + 100) / 70) * 100).clamp(0.0, 100.0).round();
      final rssiHistory = List<int>.from(_rssiHistory);
      if (signal != null) {
        rssiHistory.add(signal.rssi);
        if (rssiHistory.length > 20) {
          rssiHistory.removeRange(0, rssiHistory.length - 20);
        }
      }

      // ── Recent security events ──
      List<SecurityEvent> events = const [];
      try {
        final eventsResult =
            await getIt<SecurityRepository>().getSecurityEvents();
        events = eventsResult.fold<List<SecurityEvent>>(
          (_) => const [],
          (list) => list,
        );
      } catch (_) {
        events = const [];
      }
      final unread = events.where((e) => !e.isRead).toList();

      // ── Latest speed test ──
      SpeedTestResult? lastSpeed;
      try {
        final list =
            await getIt<SpeedTestHistoryRepository>().getRecent(limit: 1);
        lastSpeed = list.isEmpty ? null : list.first;
      } catch (_) {
        lastSpeed = null;
      }

      // ── Recent snapshots (newest-first slice) ──
      final recentSnapshots = allSnapshots.reversed.take(6).toList();

      if (!mounted) return;
      setState(() {
        _ssid = _cleanSsid(results[0]) ?? '—';
        _ip = results[1] ?? '—';
        _gateway = results[2] ?? '—';
        _networkCount = latestSnapshot?.networks.length ?? 0;
        _securityScore = secScore;
        _bestChannel = bestCh;
        _currentChannel = currentCh;
        _channelRatings = ratings;
        _newDeviceCount = newDeviceCount;
        _worstAssessment = worstAssessment;
        _scoreHistory = scoreHistory;
        _signalQualityPct = qualityPct;
        _rssiHistory = rssiHistory;
        _recentEvents = events.take(20).toList();
        _threatCount = unread.length;
        _lastSpeedTest = lastSpeed;
        _recentSnapshots = recentSnapshots;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  String? _cleanSsid(String? raw) => raw?.replaceAll('"', '');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final isConnected = _ssid != '—' && _ssid.isNotEmpty;
    final accentColor = isConnected ? scheme.primary : scheme.error;
    final statusLabel =
        isConnected ? l10n.connectedStatusCaps : l10n.disconnectedStatusCaps;

    return BlocProvider.value(
      value: _notificationBloc,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          centerTitle: true,
          leading: Builder(
            builder: (context) => IconButton(
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
              onPressed: widget.onOpenDrawer ??
                  () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: NeonText(
            'TORCAV',
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
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
          onRefresh: _loadNetworkInfo,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            children: [
              // ── Hero: radial dashboard core with orbital gauges ──
              StaggeredEntry(
                delay: const Duration(milliseconds: 80),
                child: Center(
                  child: RadialDashboardCore(
                    statusColor: accentColor,
                    label: statusLabel,
                    subLabel: _ssid,
                    isLoading: _loading,
                    securityScore: _securityScore,
                    signalQualityPct: _signalQualityPct,
                    threatCount: _threatCount,
                    deviceCount: _networkCount,
                    onTapSecurity: () => widget.onNavigate('security'),
                    onTapSignal: () => widget.onNavigate('operations'),
                    onTapThreats: () => _showNotificationSheet(context),
                    onTapDevices: () => widget.onNavigate('wifi'),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── IP / Gateway compact strip ──
              StaggeredEntry(
                delay: const Duration(milliseconds: 200),
                child: _NetworkIdStrip(
                  ssid: _ssid,
                  ip: _ip,
                  gateway: _gateway,
                ),
              ),

              const SizedBox(height: 24),

              // ── Live Pulse: bento of mini metrics ──
              StaggeredEntry(
                delay: const Duration(milliseconds: 280),
                child: NeonSectionHeader(
                  label: l10n.livePulse,
                  color: scheme.primary,
                  icon: Icons.monitor_heart_rounded,
                ),
              ),
              const SizedBox(height: 12),

              LiveMetricsBento(
                signalQualityPct: _signalQualityPct,
                rssiHistory: _rssiHistory,
                scoreHistory: _scoreHistory,
                channelRatings: _channelRatings,
                newDeviceCount: _newDeviceCount,
                recentEvents: _recentEvents,
                lastDownloadMbps: _lastSpeedTest?.downloadMbps,
                lastUploadMbps: _lastSpeedTest?.uploadMbps,
                lastSpeedTestAt: _lastSpeedTest?.recordedAt,
                onTapSignal: () => widget.onNavigate('operations'),
                onTapScore: () => _worstAssessment != null
                    ? _showScoreExplanation(context, _worstAssessment!)
                    : widget.onNavigate('security'),
                onTapChannels: () => widget.onNavigate('operations'),
                onTapDevices: () => widget.onNavigate('wifi'),
                onTapThreats: () => _showNotificationSheet(context),
                onTapSpeed: () => widget.onNavigate('operations'),
              ),

              const SizedBox(height: 28),

              // ── Activity Timeline ──
              StaggeredEntry(
                delay: const Duration(milliseconds: 360),
                child: NeonSectionHeader(
                  label: l10n.networkLogs,
                  color: scheme.tertiary,
                  icon: Icons.timeline_rounded,
                ),
              ),
              const SizedBox(height: 12),

              StaggeredEntry(
                delay: const Duration(milliseconds: 440),
                child: ActivityTimeline(
                  snapshots: _recentSnapshots,
                  events: _recentEvents,
                  onNavigate: widget.onNavigate,
                ),
              ),

              if (_bestChannel != null) ...[
                const SizedBox(height: 20),
                StaggeredEntry(
                  delay: const Duration(milliseconds: 520),
                  child: _ChannelRecommendationCard(
                    best: _bestChannel!,
                    currentChannel: _currentChannel,
                    onTap: () => widget.onNavigate('monitor/channels'),
                  ),
                ),
              ],
            ],
          ),
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

  void _showNotificationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => BlocProvider.value(
        value: _notificationBloc,
        child: const NotificationSheet(),
      ),
    );
  }
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
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return GlassmorphicContainer(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      borderColor: scheme.primary.withValues(alpha: 0.2),
      child: Row(
        children: [
          Expanded(
            child: _InlineId(
              icon: Icons.wifi_rounded,
              label: 'SSID',
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
              top: BorderSide(
                color: scheme.primary.withValues(alpha: 0.2),
                width: 1,
              ),
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
                      'SECURITY SCORE',
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
                child: findings.isEmpty
                    ? Center(
                        child: Text(
                          'No security findings detected.',
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
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final f = findings[i];
                          final color =
                              _severityColor(f.severity.name, scheme);
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
                                        f.title,
                                        style: GoogleFonts.orbitron(
                                          color: scheme.onSurface,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        f.recommendation,
                                        style: GoogleFonts.rajdhani(
                                          color: scheme.onSurfaceVariant,
                                          fontSize: 12,
                                          height: 1.4,
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
              'CH ${best.channel}',
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

