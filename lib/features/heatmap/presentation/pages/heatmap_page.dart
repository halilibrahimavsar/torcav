import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../domain/entities/floor_plan.dart';
import '../../domain/entities/heatmap_point.dart';
import '../../domain/entities/heatmap_session.dart';
import '../../domain/entities/wall_segment.dart';
import '../bloc/heatmap_bloc.dart';
import '../bloc/scan_phase.dart';
import '../widgets/ar_camera_view.dart';
import '../widgets/heatmap_canvas.dart';

class HeatmapPage extends StatefulWidget {
  const HeatmapPage({super.key});

  @override
  State<HeatmapPage> createState() => _HeatmapPageState();
}

class _HeatmapPageState extends State<HeatmapPage> {
  static const _tutorialKey = 'heatmap_tutorial_seen';
  bool _showTutorial = false;

  @override
  void initState() {
    super.initState();
    _checkTutorial();
  }

  Future<void> _checkTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool(_tutorialKey) ?? false;
    if (!seen && mounted) {
      setState(() => _showTutorial = true);
    }
  }

  Future<void> _dismissTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tutorialKey, true);
    if (mounted) {
      setState(() => _showTutorial = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final copy = _HeatmapCopy.of(context);

    return BlocProvider(
      create: (_) => getIt<HeatmapBloc>()..loadSessions(),
      child: Stack(
        children: [
          const _HeatmapView(),
          if (_showTutorial)
            _HeatmapTutorialOverlay(copy: copy, onDismiss: _dismissTutorial),
        ],
      ),
    );
  }
}

class _HeatmapView extends StatelessWidget {
  const _HeatmapView();

  @override
  Widget build(BuildContext context) {
    final copy = _HeatmapCopy.of(context);

    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NeonText(
              copy.pageTitle,
              style: GoogleFonts.orbitron(
                color: AppColors.neonCyan,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.6,
              ),
              glowRadius: 8,
            ),
            Text(
              copy.pageSubtitle,
              style: GoogleFonts.outfit(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            color: AppColors.neonCyan,
            tooltip: copy.historyTooltip,
            onPressed: () => _showSessionsPicker(context, copy),
          ),
        ],
      ),
      body: BlocBuilder<HeatmapBloc, HeatmapState>(
        builder: (context, state) {
          final session =
              state.selectedSession ??
              state.currentSession ??
              HeatmapSession(
                id: '',
                name: copy.previewSessionName,
                points: const [],
                createdAt: DateTime.now(),
              );
          final floorPlan =
              state.selectedSession?.floorPlan ??
              state.currentSession?.floorPlan ??
              state.liveFloorPlan;
          final summary = _HeatmapSummary.from(
            session: session,
            floorPlan: floorPlan,
            currentRssi: state.currentRssi,
          );

          return Column(
            children: [
              _StatusBar(state: state, summary: summary, copy: copy),
              if (state.failure != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: _InfoBanner(
                    color: AppColors.neonRed,
                    icon: Icons.error_outline_rounded,
                    title: copy.issueTitle,
                    body:
                        state.failure!.message.isEmpty
                            ? copy.genericIssueBody
                            : state.failure!.message,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: _MissionCard(state: state, summary: summary, copy: copy),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _MetricsStrip(
                  state: state,
                  summary: summary,
                  copy: copy,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child:
                        state.isArViewEnabled &&
                                state.isRecording &&
                                state.phase == ScanPhase.scanning
                            ? const ArCameraView()
                            : Stack(
                              children: [
                                _CanvasBackdrop(summary: summary),
                                HeatmapCanvas(
                                  session: session,
                                  floorPlan: floorPlan,
                                  showPath: session.points.isNotEmpty,
                                  activeFloor:
                                      state.isRecording
                                          ? state.currentFloor
                                          : null,
                                  currentPosition:
                                      state.isRecording
                                          ? state.currentPosition
                                          : null,
                                ),
                                if (_shouldShowCanvasEmptyState(state, summary))
                                  _CanvasEmptyState(state: state, copy: copy),
                                Positioned(
                                  top: 14,
                                  left: 14,
                                  child: _ViewModeBadge(
                                    label:
                                        state.isRecording
                                            ? copy.mapViewLabel
                                            : copy.resultViewLabel,
                                  ),
                                ),
                                Positioned(
                                  right: 12,
                                  bottom: 12,
                                  child: _RssiLegend(
                                    summary: summary,
                                    copy: copy,
                                  ),
                                ),
                              ],
                            ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: _InsightCard(state: state, summary: summary, copy: copy),
              ),
              if (state.isRecording)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: _ArToggleButton(
                    isEnabled: state.isArViewEnabled,
                    onToggle: () => context.read<HeatmapBloc>().toggleArView(),
                    copy: copy,
                  ),
                ),
              _ActionBar(state: state, copy: copy),
              const SizedBox(height: 18),
            ],
          );
        },
      ),
    );
  }

  bool _shouldShowCanvasEmptyState(
    HeatmapState state,
    _HeatmapSummary summary,
  ) {
    if (state.isRecording) {
      return summary.sampleCount == 0 && !state.isArViewEnabled;
    }
    return summary.sampleCount == 0 && summary.wallCount == 0;
  }

  void _showSessionsPicker(BuildContext context, _HeatmapCopy copy) {
    final bloc = context.read<HeatmapBloc>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return BlocProvider.value(
          value: bloc,
          child: BlocBuilder<HeatmapBloc, HeatmapState>(
            builder:
                (ctx, state) => _SessionPickerSheet(
                  sessions: state.sessions,
                  copy: copy,
                  onSelect: (session) {
                    bloc.selectSession(session);
                    Navigator.of(ctx).pop();
                  },
                ),
          ),
        );
      },
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({
    required this.state,
    required this.summary,
    required this.copy,
  });

  final HeatmapState state;
  final _HeatmapSummary summary;
  final _HeatmapCopy copy;

  @override
  Widget build(BuildContext context) {
    final session = state.currentSession ?? state.selectedSession;
    final isViewing = state.selectedSession != null && !state.isRecording;
    final accent =
        state.isRecording
            ? AppColors.neonGreen
            : isViewing
            ? AppColors.neonBlue
            : AppColors.textMuted;
    final statusText =
        state.isRecording
            ? copy.recordingStatus
            : isViewing
            ? copy.reviewingStatus
            : copy.idleStatus;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accent.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state.isRecording)
                  _PulsingDot(color: accent)
                else
                  Icon(
                    isViewing
                        ? Icons.visibility_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: accent,
                    size: 10,
                  ),
                const SizedBox(width: 6),
                Text(
                  statusText,
                  style: GoogleFonts.orbitron(
                    fontSize: 10,
                    letterSpacing: 1.5,
                    color: accent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              session?.name ?? copy.previewSessionName,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Text(
            '${summary.sampleCount} ${copy.samplesShort} · ${summary.wallCount} ${copy.wallsShort}',
            style: GoogleFonts.orbitron(
              fontSize: 10,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({
    required this.state,
    required this.summary,
    required this.copy,
  });

  final HeatmapState state;
  final _HeatmapSummary summary;
  final _HeatmapCopy copy;

  @override
  Widget build(BuildContext context) {
    final mission = _mission();
    return _InfoBanner(
      color: mission.color,
      icon: mission.icon,
      title: mission.title,
      body: mission.body,
    );
  }

  _MissionData _mission() {
    if (state.isRecording) {
      if (!state.isArViewEnabled &&
          state.currentRssi == null &&
          summary.sampleCount == 0) {
        return _MissionData(
          color: AppColors.neonOrange,
          icon: Icons.wifi_find_rounded,
          title: copy.waitingForDataTitle,
          body: copy.waitingForDataBody,
        );
      }

      return _MissionData(
        color: state.isArViewEnabled ? AppColors.neonCyan : AppColors.neonGreen,
        icon:
            state.isArViewEnabled
                ? Icons.view_in_ar_rounded
                : Icons.map_rounded,
        title:
            state.isArViewEnabled ? copy.arCaptureTitle : copy.mapCaptureTitle,
        body: state.isArViewEnabled ? copy.arCaptureBody : copy.mapCaptureBody,
      );
    }

    if (state.selectedSession != null) {
      return _MissionData(
        color: summary.coverageColor,
        icon: Icons.analytics_rounded,
        title: copy.reviewTitle,
        body: copy.reviewBody(summary),
      );
    }

    return _MissionData(
      color: AppColors.neonCyan,
      icon: Icons.home_work_outlined,
      title: copy.goalTitle,
      body: copy.goalBody,
    );
  }
}

class _MetricsStrip extends StatelessWidget {
  const _MetricsStrip({
    required this.state,
    required this.summary,
    required this.copy,
  });

  final HeatmapState state;
  final _HeatmapSummary summary;
  final _HeatmapCopy copy;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _MetricCard(
        label: copy.samplesLabel,
        value: '${summary.sampleCount}',
        helper:
            summary.sampleCount == 0
                ? copy.noSamplesHelper
                : copy.samplesHelper(summary.sampleCount),
        color: AppColors.neonCyan,
      ),
      _MetricCard(
        label: copy.wallsLabel,
        value: '${summary.wallCount}',
        helper:
            summary.wallCount == 0
                ? copy.noWallsHelper
                : copy.wallsHelper(summary.wallCount),
        color: AppColors.neonBlue,
      ),
      _MetricCard(
        label:
            state.isRecording ? copy.currentSignalLabel : copy.avgSignalLabel,
        value: summary.signalDisplay(copy),
        helper: summary.signalHelper(copy),
        color: summary.signalColor,
      ),
      _MetricCard(
        label: copy.weakZonesLabel,
        value: '${summary.weakZoneCount}',
        helper: copy.weakZoneHelper(summary.weakZoneCount),
        color:
            summary.weakZoneCount == 0
                ? AppColors.neonGreen
                : AppColors.neonOrange,
      ),
      _MetricCard(
        label: copy.planSizeLabel,
        value: summary.planSizeDisplay(copy),
        helper: copy.planSizeHelper,
        color: AppColors.neonPurple,
      ),
    ];

    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cards.length,
        physics: const BouncingScrollPhysics(),
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) => cards[index],
      ),
    );
  }
}

class _CanvasBackdrop extends StatelessWidget {
  const _CanvasBackdrop({required this.summary});

  final _HeatmapSummary summary;

  @override
  Widget build(BuildContext context) {
    final glow = summary.coverageColor;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topLeft,
          radius: 1.25,
          colors: [
            glow.withValues(alpha: 0.12),
            AppColors.darkSurfaceLight,
            AppColors.deepBlack,
          ],
        ),
        border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.16)),
      ),
    );
  }
}

class _CanvasEmptyState extends StatelessWidget {
  const _CanvasEmptyState({required this.state, required this.copy});

  final HeatmapState state;
  final _HeatmapCopy copy;

  @override
  Widget build(BuildContext context) {
    final title =
        state.isRecording ? copy.walkToBeginTitle : copy.noSurveyYetTitle;
    final body =
        state.isRecording ? copy.walkToBeginBody : copy.noSurveyYetBody;

    return Center(
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.34),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.18)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              state.isRecording
                  ? Icons.directions_walk_rounded
                  : Icons.map_rounded,
              color: AppColors.neonCyan,
              size: 38,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.orbitron(
                color: AppColors.textPrimary,
                fontSize: 12,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewModeBadge extends StatelessWidget {
  const _ViewModeBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.glassWhiteBorder),
      ),
      child: Text(
        label,
        style: GoogleFonts.orbitron(
          color: AppColors.textPrimary,
          fontSize: 10,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.state,
    required this.summary,
    required this.copy,
  });

  final HeatmapState state;
  final _HeatmapSummary summary;
  final _HeatmapCopy copy;

  @override
  Widget build(BuildContext context) {
    return _InfoBanner(
      color: summary.coverageColor,
      icon: Icons.lightbulb_outline_rounded,
      title: copy.findingsTitle,
      body: _body(),
    );
  }

  String _body() {
    if (state.isRecording) {
      if (summary.sampleCount < 3) {
        return copy.recordingInsightTooEarly;
      }
      if (summary.wallCount == 0) {
        return copy.recordingInsightNoWalls;
      }
      return copy.recordingInsight(summary);
    }

    if (!summary.hasSamples) {
      return copy.reviewInsightNoSamples;
    }
    if (!summary.hasPlan) {
      return copy.reviewInsightNoPlan;
    }
    if (summary.weakZoneCount == 0 && (summary.averageRssi ?? -80) >= -60) {
      return copy.reviewInsightStrong;
    }
    if (summary.weakZoneCount >= math.max(2, summary.sampleCount ~/ 3)) {
      return copy.reviewInsightWeak(summary.weakZoneCount);
    }
    return copy.reviewInsightBalanced(summary.weakZoneCount);
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.state, required this.copy});

  final HeatmapState state;
  final _HeatmapCopy copy;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<HeatmapBloc>();

    if (state.selectedSession != null && !state.isRecording) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: bloc.clearSelection,
                icon: const Icon(Icons.close_rounded, size: 18),
                label: Text(copy.closeReview),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showNewSessionDialog(context, bloc, copy),
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: Text(copy.newSurvey),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonGreen.withValues(alpha: 0.12),
                  foregroundColor: AppColors.neonGreen,
                  side: BorderSide(
                    color: AppColors.neonGreen.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (state.isRecording) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton.icon(
          onPressed: bloc.stopSession,
          icon: const Icon(Icons.stop_rounded, size: 18),
          label: Text(copy.finishAndReview),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.neonRed.withValues(alpha: 0.12),
            foregroundColor: AppColors.neonRed,
            side: BorderSide(color: AppColors.neonRed.withValues(alpha: 0.4)),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton.icon(
        onPressed: () => _showNewSessionDialog(context, bloc, copy),
        icon: const Icon(Icons.play_arrow_rounded, size: 20),
        label: Text(copy.startSurvey),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonGreen.withValues(alpha: 0.12),
          foregroundColor: AppColors.neonGreen,
          side: BorderSide(color: AppColors.neonGreen.withValues(alpha: 0.4)),
        ),
      ),
    );
  }

  void _showNewSessionDialog(
    BuildContext context,
    HeatmapBloc bloc,
    _HeatmapCopy copy,
  ) {
    final now = DateTime.now();
    final controller = TextEditingController(
      text: copy.defaultSessionName(now),
    );

    showDialog<void>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(
              copy.newSurveyDialogTitle,
              style: GoogleFonts.orbitron(fontSize: 14, letterSpacing: 1.6),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  autofocus: false,
                  decoration: InputDecoration(
                    labelText: copy.sessionNameField,
                    prefixIcon: const Icon(Icons.label_outline_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  copy.newSurveyHint,
                  style: GoogleFonts.outfit(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(copy.cancel),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = controller.text.trim();
                  if (name.isNotEmpty) {
                    await [
                      Permission.sensors,
                      Permission.activityRecognition,
                      Permission.location,
                      Permission.camera,
                    ].request();

                    if (ctx.mounted) {
                      bloc.startSession(name);
                    }
                  }
                  if (ctx.mounted) {
                    Navigator.of(ctx).pop();
                  }
                },
                child: Text(copy.startNow),
              ),
            ],
          ),
    );
  }
}

class _SessionPickerSheet extends StatelessWidget {
  const _SessionPickerSheet({
    required this.sessions,
    required this.copy,
    required this.onSelect,
  });

  final List<HeatmapSession> sessions;
  final _HeatmapCopy copy;
  final void Function(HeatmapSession) onSelect;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<HeatmapBloc>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Text(
            copy.savedSurveysTitle,
            style: GoogleFonts.orbitron(
              color: AppColors.neonCyan,
              fontSize: 12,
              letterSpacing: 1.8,
            ),
          ),
        ),
        if (sessions.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(
                copy.noSavedSurveys,
                style: GoogleFonts.outfit(color: AppColors.textMuted),
              ),
            ),
          )
        else
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: sessions.length,
              itemBuilder: (_, index) {
                final session = sessions[index];
                final summary = _HeatmapSummary.from(
                  session: session,
                  floorPlan: session.floorPlan,
                  currentRssi: null,
                );

                return ListTile(
                  leading: Icon(
                    summary.wallCount > 0
                        ? Icons.home_work_outlined
                        : Icons.thermostat_rounded,
                    color: AppColors.neonCyan,
                  ),
                  title: Text(
                    session.name,
                    style: GoogleFonts.outfit(color: AppColors.textPrimary),
                  ),
                  subtitle: Text(
                    copy.savedSurveySubtitle(
                      summary.sampleCount,
                      summary.wallCount,
                      summary.weakZoneCount,
                      _formatTimestamp(session.createdAt),
                    ),
                    style: GoogleFonts.outfit(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  onTap: () => onSelect(session),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.neonRed,
                    ),
                    tooltip: copy.deleteSurveyTooltip,
                    onPressed: () => bloc.deleteSession(session.id),
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  String _formatTimestamp(DateTime dt) =>
      '${dt.day}.${dt.month}.${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
}

class _RssiLegend extends StatelessWidget {
  const _RssiLegend({required this.summary, required this.copy});

  final _HeatmapSummary summary;
  final _HeatmapCopy copy;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 176,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkSurface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassWhiteBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            copy.legendTitle,
            style: GoogleFonts.orbitron(
              fontSize: 10,
              color: AppColors.textMuted,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          _LegendRow(
            color: const Color(0xFF00E676),
            label: copy.legendStrong,
            trailing: '>-60 dBm',
          ),
          const SizedBox(height: 6),
          _LegendRow(
            color: const Color(0xFFFFD60A),
            label: copy.legendFair,
            trailing: '-60…-72 dBm',
          ),
          const SizedBox(height: 6),
          _LegendRow(
            color: const Color(0xFFFF3B30),
            label: copy.legendWeak,
            trailing: '<-72 dBm',
          ),
          if (summary.averageRssi != null) ...[
            const SizedBox(height: 10),
            Text(
              '${copy.avgSignalLabel}: ${summary.averageRssi!.round()} dBm',
              style: GoogleFonts.outfit(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.trailing,
  });

  final Color color;
  final String label;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.outfit(
              color: AppColors.textPrimary,
              fontSize: 12,
            ),
          ),
        ),
        Text(
          trailing,
          style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 11),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.helper,
    required this.color,
  });

  final String label;
  final String value;
  final String helper;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 166,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.darkSurface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.orbitron(
                color: color,
                fontSize: 10,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Text(
                helper,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.color,
    required this.icon,
    required this.title,
    required this.body,
  });

  final Color color;
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.orbitron(
                    color: color,
                    fontSize: 11,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: GoogleFonts.outfit(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color});

  final Color color;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.4,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}

class _HeatmapTutorialOverlay extends StatelessWidget {
  const _HeatmapTutorialOverlay({required this.copy, required this.onDismiss});

  final _HeatmapCopy copy;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: Colors.black.withValues(alpha: 0.82),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.neonCyan.withValues(alpha: 0.12),
                  border: Border.all(
                    color: AppColors.neonCyan.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.home_work_outlined,
                  color: AppColors.neonCyan,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              NeonText(
                copy.tutorialTitle,
                style: GoogleFonts.orbitron(
                  color: AppColors.neonCyan,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
                glowColor: AppColors.neonCyan,
                glowRadius: 8,
              ),
              const SizedBox(height: 28),
              _TutorialStep(number: '1', text: copy.tutorialStep1),
              const SizedBox(height: 16),
              _TutorialStep(number: '2', text: copy.tutorialStep2),
              const SizedBox(height: 16),
              _TutorialStep(number: '3', text: copy.tutorialStep3),
              const SizedBox(height: 16),
              _TutorialStep(number: '4', text: copy.tutorialStep4),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onDismiss,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonCyan.withValues(alpha: 0.15),
                    foregroundColor: AppColors.neonCyan,
                    side: BorderSide(
                      color: AppColors.neonCyan.withValues(alpha: 0.5),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.gotIt,
                    style: GoogleFonts.orbitron(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TutorialStep extends StatelessWidget {
  const _TutorialStep({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.neonCyan.withValues(alpha: 0.15),
            border: Border.all(
              color: AppColors.neonCyan.withValues(alpha: 0.4),
            ),
          ),
          child: Center(
            child: Text(
              number,
              style: GoogleFonts.orbitron(
                color: AppColors.neonCyan,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.rajdhani(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _ArToggleButton extends StatelessWidget {
  const _ArToggleButton({
    required this.isEnabled,
    required this.onToggle,
    required this.copy,
  });

  final bool isEnabled;
  final VoidCallback onToggle;
  final _HeatmapCopy copy;

  @override
  Widget build(BuildContext context) {
    final accent = isEnabled ? AppColors.neonCyan : AppColors.neonGreen;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.darkSurface.withValues(alpha: 0.84),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accent.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Icon(
                isEnabled ? Icons.view_in_ar_rounded : Icons.map_rounded,
                color: accent,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEnabled ? copy.arViewLabel : copy.mapViewLabel,
                      style: GoogleFonts.orbitron(
                        color: accent,
                        fontSize: 11,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isEnabled ? copy.switchToMapHint : copy.switchToArHint,
                      style: GoogleFonts.outfit(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.swap_horiz_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeatmapSummary {
  const _HeatmapSummary({
    required this.sampleCount,
    required this.wallCount,
    required this.weakZoneCount,
    required this.averageRssi,
    required this.currentRssi,
    required this.widthMeters,
    required this.heightMeters,
  });

  factory _HeatmapSummary.from({
    required HeatmapSession session,
    required FloorPlan? floorPlan,
    required int? currentRssi,
  }) {
    final points = session.points;
    final averageRssi =
        points.isEmpty
            ? null
            : points.map((point) => point.rssi).reduce((a, b) => a + b) /
                points.length;
    final weakZoneCount = points.where((point) => point.rssi < -72).length;
    final bounds = _MetricBounds.from(
      points: points,
      walls: floorPlan?.walls ?? const [],
    );

    return _HeatmapSummary(
      sampleCount: points.length,
      wallCount: floorPlan?.walls.length ?? 0,
      weakZoneCount: weakZoneCount,
      averageRssi: averageRssi,
      currentRssi: currentRssi,
      widthMeters: bounds.widthMeters,
      heightMeters: bounds.heightMeters,
    );
  }

  final int sampleCount;
  final int wallCount;
  final int weakZoneCount;
  final double? averageRssi;
  final int? currentRssi;
  final double widthMeters;
  final double heightMeters;

  bool get hasSamples => sampleCount > 0;
  bool get hasPlan => wallCount > 0;

  int? get signalForDisplay => currentRssi ?? averageRssi?.round();

  Color get signalColor {
    final signal = signalForDisplay;
    if (signal == null) return AppColors.textSecondary;
    if (signal >= -60) return AppColors.neonGreen;
    if (signal >= -72) return AppColors.neonYellow;
    return AppColors.neonRed;
  }

  Color get coverageColor {
    if (!hasSamples) return AppColors.textMuted;
    final avg = averageRssi ?? -80;
    if (weakZoneCount >= math.max(2, sampleCount ~/ 3) || avg < -72) {
      return AppColors.neonRed;
    }
    if (weakZoneCount > 0 || avg < -63) {
      return AppColors.neonOrange;
    }
    return AppColors.neonGreen;
  }

  String signalDisplay(_HeatmapCopy copy) {
    final signal = signalForDisplay;
    return signal == null ? copy.notAvailable : '$signal dBm';
  }

  String signalHelper(_HeatmapCopy copy) {
    final signal = signalForDisplay;
    if (signal == null) return copy.signalUnavailableHelper;
    if (signal >= -60) return copy.signalStrongHelper;
    if (signal >= -72) return copy.signalFairHelper;
    return copy.signalWeakHelper;
  }

  String planSizeDisplay(_HeatmapCopy copy) {
    if (!hasSamples && !hasPlan) return copy.notAvailable;
    return '${widthMeters.toStringAsFixed(1)} x ${heightMeters.toStringAsFixed(1)} m';
  }
}

class _MetricBounds {
  const _MetricBounds({required this.widthMeters, required this.heightMeters});

  factory _MetricBounds.from({
    required List<HeatmapPoint> points,
    required List<WallSegment> walls,
  }) {
    final xs = <double>[0];
    final ys = <double>[0];

    for (final point in points) {
      xs.add(point.floorX);
      ys.add(point.floorY);
    }
    for (final wall in walls) {
      xs
        ..add(wall.x1)
        ..add(wall.x2);
      ys
        ..add(wall.y1)
        ..add(wall.y2);
    }

    final width = (xs.reduce(math.max) - xs.reduce(math.min)).abs();
    final height = (ys.reduce(math.max) - ys.reduce(math.min)).abs();

    return _MetricBounds(
      widthMeters: math.max(1, width),
      heightMeters: math.max(1, height),
    );
  }

  final double widthMeters;
  final double heightMeters;
}

class _MissionData {
  const _MissionData({
    required this.color,
    required this.icon,
    required this.title,
    required this.body,
  });

  final Color color;
  final IconData icon;
  final String title;
  final String body;
}

class _HeatmapCopy {
  const _HeatmapCopy._({required this.isTurkish});

  factory _HeatmapCopy.of(BuildContext context) {
    final isTurkish = Localizations.localeOf(context).languageCode == 'tr';
    return _HeatmapCopy._(isTurkish: isTurkish);
  }

  final bool isTurkish;

  String get pageTitle =>
      isTurkish ? 'EV PLANI + WIFI ISI HARITASI' : 'HOME PLAN + WIFI HEATMAP';
  String get pageSubtitle =>
      isTurkish
          ? 'Plan cizgisi, kapsama ve zayif bolgeler'
          : 'Outline, coverage, and weak zones';
  String get historyTooltip =>
      isTurkish ? 'Kayitli turlari ac' : 'Open saved surveys';
  String get previewSessionName => isTurkish ? 'Onizleme' : 'Preview';
  String get recordingStatus => isTurkish ? 'KAYIT' : 'RECORDING';
  String get reviewingStatus => isTurkish ? 'INCELEME' : 'REVIEW';
  String get idleStatus => isTurkish ? 'HAZIR' : 'IDLE';
  String get samplesShort => isTurkish ? 'ornek' : 'samples';
  String get wallsShort => isTurkish ? 'duvar' : 'walls';

  String get issueTitle => isTurkish ? 'Duzeltilmesi Gereken Durum' : 'Issue';
  String get genericIssueBody =>
      isTurkish
          ? 'Tarama tamamlanamadi. Izinleri ve cihaz sensorlerini kontrol edin.'
          : 'The survey could not finish. Check permissions and device sensors.';

  String get goalTitle =>
      isTurkish ? 'Bu Ozellik Ne Yapiyor?' : 'What This Feature Does';
  String get goalBody =>
      isTurkish
          ? 'Yurudukce Wi-Fi ornekleri toplar, AR ile duvar cizgilerini yakalar ve sonunda ev planini sinyal yogunluguyla birlikte gostermeye calisir.'
          : 'It samples Wi-Fi as you walk, captures wall lines in AR, and then shows the home outline together with signal density.';

  String get waitingForDataTitle =>
      isTurkish ? 'Veri Bekleniyor' : 'Waiting For Data';
  String get waitingForDataBody =>
      isTurkish
          ? 'Henuz sinyal ornegi dusmedi. Konum ve hareket izinlerini kontrol edip birkac adim yuruyun.'
          : 'No signal sample has landed yet. Check motion and location permissions, then walk a few steps.';

  String get arCaptureTitle => isTurkish ? 'AR Modu Acik' : 'AR Mode Active';
  String get arCaptureBody =>
      isTurkish
          ? 'Telefonu oda kenarlarina ve kapi gecislerine cevirin. Kamera duvar cizgilerini ariyor, sinyal ise yurudukce otomatik ekleniyor.'
          : 'Point the phone at room edges and door openings. The camera searches for wall lines while signal points are added automatically as you move.';
  String get mapCaptureTitle => isTurkish ? '2D Harita Acik' : '2D Map Active';
  String get mapCaptureBody =>
      isTurkish
          ? 'Sonucu daha net izlemek icin 2D gorunumdesiniz. Ornekler yurudukce islenir; plan cizgisi zayifsa AR moduna gecin.'
          : 'You are in the clearer 2D view. Samples keep arriving as you walk; if the outline stays weak, switch to AR mode.';

  String get reviewTitle => isTurkish ? 'Sonuc Ozeti' : 'Survey Summary';
  String reviewBody(_HeatmapSummary summary) {
    if (!summary.hasSamples) {
      return isTurkish
          ? 'Kayitli tur var ama henuz anlamli sinyal ornegi yok.'
          : 'There is a saved survey, but it still lacks meaningful signal samples.';
    }
    if (!summary.hasPlan) {
      return isTurkish
          ? 'Sinyal izi var ama duvar plani zayif. Sonucu okuyabilirsiniz, plan icin bir tur daha faydali olur.'
          : 'The signal trail is there, but the wall plan is weak. You can read the result, though another pass would improve the outline.';
    }
    return isTurkish
        ? 'Plan ve kapsama birlikte okunabilir durumda. Zayif bolgeleri asagidaki ozetten takip edin.'
        : 'The outline and coverage are readable together. Use the summary below to inspect weak zones.';
  }

  String get samplesLabel => isTurkish ? 'TOPLANAN ORNEK' : 'SAMPLES';
  String get wallsLabel => isTurkish ? 'PLAN CIZGISI' : 'WALLS';
  String get currentSignalLabel => isTurkish ? 'ANLIK SINYAL' : 'LIVE SIGNAL';
  String get avgSignalLabel => isTurkish ? 'ORT. SINYAL' : 'AVG SIGNAL';
  String get weakZonesLabel => isTurkish ? 'ZAYIF NOKTA' : 'WEAK ZONES';
  String get planSizeLabel => isTurkish ? 'PLAN BOYUTU' : 'PLAN SIZE';
  String get notAvailable => isTurkish ? 'Hazir degil' : 'Not ready';
  String get noSamplesHelper =>
      isTurkish
          ? 'Tur baslayinca adimlarla dolar'
          : 'Fills in as you start walking';
  String samplesHelper(int count) =>
      isTurkish
          ? '$count noktadan sinyal okundu'
          : 'Signal read from $count locations';
  String get noWallsHelper =>
      isTurkish
          ? 'Plan icin AR turu gerekebilir'
          : 'AR pass may be needed for the outline';
  String wallsHelper(int count) =>
      isTurkish
          ? '$count duvar cizgisi secildi'
          : '$count wall segments retained';
  String get signalUnavailableHelper =>
      isTurkish
          ? 'Wi-Fi okumasi henuz gelmedi'
          : 'Wi-Fi reading has not arrived yet';
  String get signalStrongHelper =>
      isTurkish ? 'Guclu kapsama' : 'Strong coverage';
  String get signalFairHelper =>
      isTurkish ? 'Sinirda ama kullanilabilir' : 'Borderline but usable';
  String get signalWeakHelper =>
      isTurkish ? 'Zayif veya sorunlu bolge' : 'Weak or problematic zone';
  String weakZoneHelper(int count) {
    if (count == 0) {
      return isTurkish ? 'Belirgin olu nokta yok' : 'No obvious dead zones';
    }
    if (count == 1) {
      return isTurkish ? 'Tek sorunlu alan' : 'One problematic area';
    }
    return isTurkish
        ? '$count farkli zayif alan'
        : '$count weak areas detected';
  }

  String get planSizeHelper =>
      isTurkish
          ? 'Gorunen izden tahmini cap'
          : 'Estimated span from captured trace';

  String get noSurveyYetTitle => isTurkish ? 'Tur Baslatin' : 'Start A Survey';
  String get noSurveyYetBody =>
      isTurkish
          ? 'Ilk olarak bir ev turu baslatin. Sonuc ekraninda plan ve isi haritasi birlikte okunacak.'
          : 'Start a walkthrough first. The result view will then show the outline and heatmap together.';
  String get walkToBeginTitle =>
      isTurkish ? 'Yuruyerek Baslayin' : 'Start Walking';
  String get walkToBeginBody =>
      isTurkish
          ? 'Her odada birkac adim atildikca yol ve sinyal noktasi olusur.'
          : 'The trail and signal points appear as you take a few steps in each room.';

  String get mapViewLabel => isTurkish ? '2D HARITA' : '2D MAP';
  String get resultViewLabel => isTurkish ? 'SONUC GORUNUMU' : 'RESULT VIEW';

  String get findingsTitle => isTurkish ? 'NE ANLATIYOR?' : 'WHAT IT MEANS';
  String get recordingInsightTooEarly =>
      isTurkish
          ? 'Henuz cok erken. En az birkac odada dolasip 4-5 ornek toplandiginda sonuc yorumlanabilir hale gelir.'
          : 'It is still too early. After 4-5 samples across a few rooms, the result becomes readable.';
  String get recordingInsightNoWalls =>
      isTurkish
          ? 'Sinyal geliyor ama plan cizgisi yok. AR moduna gecip telefonu duvarlara dogru tutarak ikinci bir tur atmak plan kalitesini belirgin artirir.'
          : 'Signal is arriving but the outline is missing. Switch to AR and face the walls during another pass to improve the plan.';
  String recordingInsight(_HeatmapSummary summary) =>
      isTurkish
          ? 'Canli sonuc okunmaya basladi. ${summary.sampleCount} ornek ve ${summary.wallCount} duvar cizgisi ile zayif alanlar kabaca gorunuyor.'
          : 'The live result is starting to read well. With ${summary.sampleCount} samples and ${summary.wallCount} wall lines, weak areas are becoming visible.';
  String get reviewInsightNoSamples =>
      isTurkish
          ? 'Bu turde sinyal ornegi yok. Konum ve hareket algilama izinleri kapaliysa uygulama isi haritasi uretemez.'
          : 'This survey has no signal samples. If location or motion permissions are off, the app cannot build the heatmap.';
  String get reviewInsightNoPlan =>
      isTurkish
          ? 'Isi haritasi olusmus ama plan zayif. Tekrar denerken AR modunda oda sinirlarina bakarak yuruyun.'
          : 'The heatmap is present but the outline is weak. On the next run, use AR and face room boundaries while walking.';
  String get reviewInsightStrong =>
      isTurkish
          ? 'Kapsama genel olarak guclu. Belirgin olu nokta gorunmuyor; plan ve sinyal birlikte tutarli duruyor.'
          : 'Coverage looks strong overall. No clear dead zones are visible, and the outline agrees with the signal trace.';
  String reviewInsightWeak(int weakCount) =>
      isTurkish
          ? '$weakCount zayif bolge gorunuyor. Modemi daha merkezi bir konuma almak veya ek erisim noktasi dusunmek mantikli olabilir.'
          : '$weakCount weak zones are visible. Moving the router more centrally or adding another access point may help.';
  String reviewInsightBalanced(int weakCount) =>
      isTurkish
          ? 'Genel kapsama dengeli ama $weakCount noktada dusus var. Bunlar genelde kose, koridor sonu veya kalin duvar arkasi olur.'
          : 'Coverage is reasonably balanced, but it dips in $weakCount spots. These are often corners, corridor ends, or heavy wall transitions.';

  String get closeReview => isTurkish ? 'INCELEMEYI KAPAT' : 'CLOSE REVIEW';
  String get newSurvey => isTurkish ? 'YENI TUR' : 'NEW SURVEY';
  String get finishAndReview =>
      isTurkish ? 'BITIR VE SONUCU GOR' : 'FINISH & REVIEW';
  String get startSurvey => isTurkish ? 'EV TURUNU BASLAT' : 'START SURVEY';
  String get newSurveyDialogTitle => isTurkish ? 'YENI EV TURU' : 'NEW SURVEY';
  String defaultSessionName(DateTime now) =>
      isTurkish
          ? 'Ev turu ${now.hour}:${now.minute.toString().padLeft(2, '0')}'
          : 'Survey ${now.hour}:${now.minute.toString().padLeft(2, '0')}';
  String get sessionNameField => isTurkish ? 'Tur adi' : 'Survey name';
  String get newSurveyHint =>
      isTurkish
          ? 'Tur baslayinca sinyal yurudukce otomatik toplanir. Plan cizgisini guclendirmek isterseniz AR gorunumune gecebilirsiniz.'
          : 'Once the survey starts, signal samples are added automatically as you move. Switch to AR if you want a stronger room outline.';
  String get cancel => isTurkish ? 'Vazgec' : 'Cancel';
  String get startNow => isTurkish ? 'Baslat' : 'Start';

  String get savedSurveysTitle =>
      isTurkish ? 'KAYITLI EV TURLARI' : 'SAVED SURVEYS';
  String get noSavedSurveys =>
      isTurkish ? 'Henuz kayitli bir tur yok.' : 'No saved surveys yet.';
  String savedSurveySubtitle(
    int samples,
    int walls,
    int weak,
    String timestamp,
  ) {
    if (isTurkish) {
      return '$samples ornek · $walls duvar · $weak zayif nokta · $timestamp';
    }
    return '$samples samples · $walls walls · $weak weak zones · $timestamp';
  }

  String get deleteSurveyTooltip => isTurkish ? 'Turu sil' : 'Delete survey';

  String get legendTitle => isTurkish ? 'RENK ANLAMI' : 'COLOR GUIDE';
  String get legendStrong => isTurkish ? 'Guclu' : 'Strong';
  String get legendFair => isTurkish ? 'Orta' : 'Fair';
  String get legendWeak => isTurkish ? 'Zayif' : 'Weak';

  String get tutorialTitle =>
      isTurkish ? 'ISI HARITASINI NASIL OKURUM?' : 'HOW TO READ THE HEATMAP';
  String get tutorialStep1 =>
      isTurkish
          ? 'Yeni bir ev turu baslatin. Uygulama yurudukce sinyal noktalarini otomatik toplar.'
          : 'Start a new survey. The app collects signal samples automatically as you walk.';
  String get tutorialStep2 =>
      isTurkish
          ? 'Her odayi gezip koridor ve kose gecislerinden gecin. Harita iziniz bu sayede olusur.'
          : 'Walk each room and pass through corridor and corner transitions. That builds the survey trail.';
  String get tutorialStep3 =>
      isTurkish
          ? 'Plan cizgisi zayifsa AR moduna gecip telefonu duvarlara dogru tutun. Bu kisim ev plani icin kullanilir.'
          : 'If the outline is weak, switch to AR and face the walls. That pass is used to build the home plan.';
  String get tutorialStep4 =>
      isTurkish
          ? 'Bitirip sonucu acin. Ekran artik plan, sinyal ve zayif alanlari birlikte gosterecek.'
          : 'Finish and open the result. The screen will then show the plan, signal, and weak zones together.';

  String get arViewLabel => isTurkish ? 'AR GORUNUMU' : 'AR VIEW';
  String get switchToMapHint =>
      isTurkish
          ? 'Sonucu daha net okumak icin 2D haritaya don'
          : 'Return to the clearer 2D map';
  String get switchToArHint =>
      isTurkish
          ? 'Plan cizgisini guclendirmek icin AR kullan'
          : 'Use AR to strengthen the outline';
}
