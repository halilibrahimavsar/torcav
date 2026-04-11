import 'dart:math' as math;
import 'package:intl/intl.dart';

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
import '../../domain/services/survey_guidance_service.dart';
import '../bloc/heatmap_bloc.dart';
import '../bloc/scan_phase.dart';
import '../widgets/ar_camera_view.dart';
import '../widgets/arcore_heatmap_view.dart';
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


class _HeatmapView extends StatefulWidget {
  const _HeatmapView();

  @override
  State<_HeatmapView> createState() => _HeatmapViewState();
}

class _HeatmapViewState extends State<_HeatmapView> {
  static const _guidanceService = SurveyGuidanceService();

  final _arViewKey = GlobalKey();
  final _cameraFallbackKey = GlobalKey();

  /// When not null, we show a premium 'Signal Probe' tooltip.
  Offset? _probePoint;

  /// When true, the detailed information cards are minimized into compact badges
  /// to maximize screen real estate for the heatmap/floorplan.
  @override
  Widget build(BuildContext context) {
    final copy = _HeatmapCopy.of(context);

    return BlocBuilder<HeatmapBloc, HeatmapState>(
      builder: (context, state) {
        final bloc = context.read<HeatmapBloc>();
        final isRecording = state.isRecording;
        final isScanning = isRecording && state.phase == ScanPhase.scanning;
        final isReviewing = state.phase == ScanPhase.reviewing;

        final session = isRecording ? state.currentSession : state.selectedSession;
        final floorPlan = isRecording ? state.liveFloorPlan : session?.floorPlan;

        final summary = _HeatmapSummary.from(
          session: session ??
              HeatmapSession(
                id: 'idle',
                name: '',
                points: const [],
                createdAt: DateTime.now(),
              ),
          floorPlan: floorPlan,
          currentRssi: state.currentRssi,
        );

        // Adaptive RSSI range for canvas color scaling
        final points = session?.points ?? const [];
        final int minRssi =
            points.isEmpty ? -90 : points.map((p) => p.rssi).reduce(math.min);
        final int maxRssi =
            points.isEmpty ? -35 : points.map((p) => p.rssi).reduce(math.max);

        final guidance = _guidanceService.analyze(
          points: session?.points ?? const [],
          floorPlan: floorPlan,
          isRecording: isRecording,
          hasArOrigin: state.hasArOrigin,
          pendingWallCount: state.pendingWalls.length,
          currentRssi: state.currentRssi,
          surveyGate: state.surveyGate,
          lastSignalAt: state.lastSignalAt,
          currentSignalStdDev: state.lastSignalStdDev,
          currentX: state.currentPosition?.dx,
          currentY: state.currentPosition?.dy,
        );

        return PopScope(
          canPop: !isRecording && session?.points.isEmpty == true,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;

            final shouldPop = await showDialog<bool>(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        backgroundColor: AppColors.deepBlack,
                        title: Text(
                          'End Survey?',
                          style: GoogleFonts.orbitron(
                            color: AppColors.neonCyan,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: Text(
                          isRecording
                              ? 'Your current survey data will be lost if you discard it. Save or Discard?'
                              : 'Exit session review?',
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(
                              'CANCEL',
                              style: GoogleFonts.orbitron(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          if (isRecording)
                            TextButton(
                              onPressed: () {
                                bloc.stopSession();
                                bloc.exitArView();
                                Navigator.of(context).pop(true);
                              },
                              child: Text(
                                'SAVE',
                                style: GoogleFonts.orbitron(
                                  color: AppColors.neonGreen,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          TextButton(
                            onPressed: () {
                              if (isRecording) {
                                bloc.discardSession();
                              }
                              bloc.exitArView();
                              Navigator.of(context).pop(true);
                            },
                            child: Text(
                              isRecording ? 'DISCARD' : 'EXIT',
                              style: GoogleFonts.orbitron(
                                color: AppColors.neonRed,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                ) ??
                false;

            if (shouldPop && context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Scaffold(
            backgroundColor: AppColors.deepBlack,
            resizeToAvoidBottomInset: false,
            appBar:
                isScanning
                    ? null
                    : AppBar(
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        onPressed: () async {
                          // Trigger PopScope manually for consistency
                          final canPop =
                              !isRecording && session?.points.isEmpty == true;
                          if (canPop) {
                            bloc.exitArView();
                            Navigator.of(context).pop();
                          } else {
                            // This will trigger onPopInvokedWithResult
                            Navigator.of(context).maybePop();
                          }
                        },
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
          body: Stack(
            fit: StackFit.expand,
            children: [
              // 2D Result / Idle Layer
              Stack(
                children: [
                  _CanvasBackdrop(summary: summary),
                  if (session != null)
                    Positioned.fill(
                      child: HeatmapCanvas(
                        session: session,
                        floorPlan: floorPlan,
                        showPath: session.points.isNotEmpty,
                        activeFloor: null,
                        minRssi: minRssi,
                        maxRssi: maxRssi,
                        onTap: (metric) {
                          setState(() => _probePoint = metric);
                        },
                      ),
                    ),
                  if (_shouldShowCanvasEmptyState(state, summary))
                    _CanvasEmptyState(
                      state: state,
                      copy: copy,
                      onStart:
                          () => _showNewSessionDialog(context, bloc, copy),
                    ),
                  Positioned(
                    top: 14,
                    left: 14,
                    child: _ViewModeBadge(label: copy.resultViewLabel),
                  ),
                  if (isReviewing && _probePoint == null && session != null)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _SurveyConclusionOverlay(
                        session: session,
                        summary: summary,
                        guidance: guidance,
                        copy: copy,
                        onDismiss: bloc.clearSelection,
                        onNewSurvey: () =>
                            _showNewSessionDialog(context, bloc, copy),
                      ),
                    ),
                  if (_probePoint != null && session != null)
                    _SignalProbeOverlay(
                      point: _findNearestPoint(
                        session.points,
                        _probePoint!,
                      ),
                      onDismiss: () => setState(() => _probePoint = null),
                      copy: copy,
                    ),
                ],
              ),

              // AR / Camera Layer — present during recording OR AR replay mode.
              if (state.isArSupported && (isRecording || state.isViewingInAr))
                ArCoreHeatmapView(
                  key: _arViewKey,
                  onFinish: isRecording ? bloc.stopSession : bloc.exitArView,
                  onDiscard: isRecording ? bloc.discardSession : bloc.exitArView,
                )
              else if (isRecording)
                ArCameraView(
                  key: _cameraFallbackKey,
                  onFinish: bloc.stopSession,
                  onDiscard: bloc.discardSession,
                ),
            ],
          ),
          floatingActionButton:
              !isRecording
                  ? NeonButton(
                    onPressed: () => _showNewSessionDialog(context, bloc, copy),
                    icon: Icons.add_rounded,
                    label: copy.startSurvey,
                  )
                  : null,
          ),
        );
      },
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

  bool _shouldShowCanvasEmptyState(
    HeatmapState state,
    _HeatmapSummary summary,
  ) {
    if (state.isRecording) {
      // During recording, we are either in AR or Camera fallback.
      // The 2D canvas is hidden during active scanning (phase == scanning).
      // If we are recording but NOT scanning (e.g. paused), we show the canvas.
      return summary.sampleCount == 0;
    }
    return summary.sampleCount == 0 && summary.wallCount == 0;
  }


  HeatmapPoint? _findNearestPoint(List<HeatmapPoint> points, Offset metric) {
    if (points.isEmpty) return null;
    HeatmapPoint? closest;
    double minSqDist = double.infinity;
    for (final p in points) {
      final dx = p.floorX - metric.dx;
      final dy = p.floorY - metric.dy;
      final d2 = dx * dx + dy * dy;
      if (d2 < minSqDist) {
        minSqDist = d2;
        closest = p;
      }
    }
    // Only return if within reasonable distance (e.g. 5 meters)
    return minSqDist < 25.0 ? closest : null;
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
  const _CanvasEmptyState({
    required this.state,
    required this.copy,
    required this.onStart,
  });

  final HeatmapState state;
  final _HeatmapCopy copy;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final title =
        state.isRecording ? copy.walkToBeginTitle : copy.noSurveyYetTitle;
    final body =
        state.isRecording ? copy.walkToBeginBody : copy.noSurveyYetBody;

    return Center(
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonCyan.withValues(alpha: 0.08),
              blurRadius: 32,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.neonCyan.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                state.isRecording
                    ? Icons.directions_walk_rounded
                    : Icons.map_rounded,
                color: AppColors.neonCyan,
                size: 40,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title.toUpperCase(),
              textAlign: TextAlign.center,
              style: GoogleFonts.orbitron(
                color: AppColors.textPrimary,
                fontSize: 13,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              body,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            if (!state.isRecording) ...[
              const SizedBox(height: 24),
              NeonButton(
                onPressed: onStart,
                label: copy.startSurvey,
                icon: Icons.play_arrow_rounded,
              ),
            ],
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
    final weakZoneCount =
        points.where((point) => point.rssi < -72 || point.isFlagged).length;
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
  String get recordingInsightReady =>
      isTurkish
          ? 'Survey artik yeterince doldu. Son bir oda gecisi daha alip sonucu kaydedebilirsiniz.'
          : 'The survey is now dense enough. One last room transition is enough before saving the result.';
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
  String get cameraViewLabel => isTurkish ? 'CANLI KAMERA' : 'LIVE CAMERA';
  String get infoSheetTitle =>
      isTurkish ? 'CANLI SURVEY VERILERI' : 'LIVE SURVEY DATA';

  String feedStatusLabel(String label, bool active) {
    if (isTurkish) {
      return '$label: ${active ? 'aktif' : 'pasif'}';
    }
    return '$label: ${active ? 'active' : 'inactive'}';
  }

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

  String get routeLabel => isTurkish ? 'SONRAKI ADIM' : 'NEXT STEP';
  String get planConfidenceLabel =>
      isTurkish ? 'PLAN GUVENI' : 'PLAN CONFIDENCE';
  String get coverageConfidenceLabel =>
      isTurkish ? 'KAPSAMA GUVENI' : 'COVERAGE CONFIDENCE';
  String get signalConfidenceLabel =>
      isTurkish ? 'SINYAL GUVENI' : 'SIGNAL CONFIDENCE';
  String get motionFeedLabel => isTurkish ? 'Hareket' : 'Motion';
  String get wifiFeedLabel => 'Wi-Fi';
  String get cameraFeedLabel => isTurkish ? 'Kamera' : 'Camera';
  String get planFeedLabel => isTurkish ? 'Plan' : 'Plan';

  String percent(double value) => '${(value.clamp(0.0, 1.0) * 100).round()}%';

  Color guidanceColor(SurveyGuidance guidance) {
    switch (guidance.tone) {
      case SurveyTone.info:
        return AppColors.neonCyan;
      case SurveyTone.progress:
        return AppColors.neonGreen;
      case SurveyTone.caution:
        return AppColors.neonOrange;
      case SurveyTone.success:
        return AppColors.neonBlue;
    }
  }

  IconData guidanceIcon(SurveyGuidance guidance) {
    switch (guidance.stage) {
      case SurveyStage.idle:
        return Icons.play_arrow_rounded;
      case SurveyStage.calibration:
        return Icons.directions_walk_rounded;
      case SurveyStage.planCapture:
        return guidance.suggestAr
            ? Icons.view_in_ar_rounded
            : Icons.home_work_outlined;
      case SurveyStage.coverageSweep:
        return Icons.alt_route_rounded;
      case SurveyStage.weakZoneReview:
        return Icons.wifi_tethering_error_rounded;
      case SurveyStage.wrapUp:
        return Icons.flag_rounded;
      case SurveyStage.review:
        return Icons.analytics_rounded;
    }
  }

  String guidanceTitle(SurveyGuidance guidance) {
    switch (guidance.stage) {
      case SurveyStage.idle:
        return isTurkish ? 'Survey Hazirligi' : 'Survey Setup';
      case SurveyStage.calibration:
        return isTurkish ? 'Rota Baslatiliyor' : 'Starting Route';
      case SurveyStage.planCapture:
        return isTurkish ? 'Plan Cizgisi Toplaniyor' : 'Capturing Outline';
      case SurveyStage.coverageSweep:
        return isTurkish ? 'Kapsama Dolduruluyor' : 'Filling Coverage';
      case SurveyStage.weakZoneReview:
        return isTurkish ? 'Zayif Alan Dogrulama' : 'Weak Zone Check';
      case SurveyStage.wrapUp:
        return isTurkish ? 'Kayda Hazir' : 'Ready To Save';
      case SurveyStage.review:
        return isTurkish ? 'Survey Kalitesi' : 'Survey Quality';
    }
  }

  String guidanceBody(SurveyGuidance guidance, _HeatmapSummary summary) {
    switch (guidance.stage) {
      case SurveyStage.idle:
        return isTurkish
            ? 'Yeni bir tur baslatin. Uygulama hareket, kamera ve Wi-Fi izini birlikte sentezleyerek net bir plan cikarmaya calisacak.'
            : 'Start a new survey. The app will combine motion, camera, and Wi-Fi traces into a cleaner floor plan.';
      case SurveyStage.calibration:
        return isTurkish
            ? 'Ilk izi olusturmak icin 5-8 adim duz ilerleyin. Oda girisleri ve kose donusleri konum iskeletini daha hizli oturtur.'
            : 'Walk straight for 5-8 steps to establish the first trace. Doorways and corner turns help anchor the layout faster.';
      case SurveyStage.planCapture:
        return guidance.suggestAr
            ? (isTurkish
                ? 'Plan guveni henuz dusuk. AR moduna gecip telefonu duvarlara ve kapi hatlarina cevirin.'
                : 'Outline confidence is still low. Switch to AR and face walls and door edges.')
            : (isTurkish
                ? 'Duvar cizgisi toplanıyor. Telefonu oda sinirlarina dogru sakin sekilde gezdirin.'
                : 'Wall lines are being captured. Sweep the phone calmly across room boundaries.');
      case SurveyStage.coverageSweep:
        return isTurkish
            ? 'Haritanin ${routeLabelValue(guidance)} tarafi daha seyrek. O yone gidip 3-4 yeni ornek toplayin.'
            : 'The ${routeLabelValue(guidance)} side of the map is still sparse. Move there and collect 3-4 more samples.';
      case SurveyStage.weakZoneReview:
        return isTurkish
            ? 'Su an zayif sinyal bolgesindesiniz. Bu alani biraz daha tarayip sonucun gercek bir olu nokta olup olmadigini netlestirin.'
            : 'You are currently in a weak-signal area. Sweep this zone a bit more to confirm whether it is a real dead spot.';
      case SurveyStage.wrapUp:
        return isTurkish
            ? 'Plan, kapsama ve sinyal yogunlugu yeterince doldu. Sonucu kaydedip review ekraninda plan/isi haritasini okuyabilirsiniz.'
            : 'Outline, coverage, and signal density are now strong enough. Save the result and read the plan/heatmap in review.';
      case SurveyStage.review:
        return isTurkish
            ? 'Bu tur ${(guidance.overallProgress * 100).round()}% dolulukta. ${summary.sampleCount} ornek ve ${summary.wallCount} duvar ile sonuc okunabilir.'
            : 'This survey is ${(guidance.overallProgress * 100).round()}% complete. With ${summary.sampleCount} samples and ${summary.wallCount} walls, the result is readable.';
    }
  }

  String routeLabelValue(SurveyGuidance guidance) {
    if (guidance.readyToFinish) {
      return isTurkish ? 'Kaydi bitir' : 'Finish survey';
    }
    switch (guidance.stage) {
      case SurveyStage.idle:
        return isTurkish ? 'Turu baslat' : 'Start survey';
      case SurveyStage.calibration:
        return isTurkish ? 'Duz ilerle' : 'Walk forward';
      case SurveyStage.planCapture:
        return guidance.suggestAr
            ? (isTurkish ? 'AR moduna gec' : 'Switch to AR')
            : (isTurkish ? 'Duvarlari tara' : 'Scan the walls');
      case SurveyStage.coverageSweep:
        return directionLabel(guidance.sparseRegion);
      case SurveyStage.weakZoneReview:
        return isTurkish ? 'Zayif alani tara' : 'Sweep weak zone';
      case SurveyStage.wrapUp:
        return isTurkish ? 'Son turu tamamla' : 'Wrap up run';
      case SurveyStage.review:
        return isTurkish ? 'Sonucu incele' : 'Review result';
    }
  }

  String directionLabel(SparseRegion? region) {
    switch (region) {
      case SparseRegion.leftWing:
        return isTurkish ? 'sol kanada ilerle' : 'move to left wing';
      case SparseRegion.rightWing:
        return isTurkish ? 'sag kanada ilerle' : 'move to right wing';
      case SparseRegion.topWing:
        return isTurkish ? 'ust bolgeyi doldur' : 'cover upper area';
      case SparseRegion.bottomWing:
        return isTurkish ? 'alt bolgeyi doldur' : 'cover lower area';
      case null:
        return isTurkish ? 'dengeyi koru' : 'keep sweeping';
    }
  }
}

class _SignalProbeOverlay extends StatelessWidget {
  const _SignalProbeOverlay({
    required this.point,
    required this.onDismiss,
    required this.copy,
  });

  final HeatmapPoint? point;
  final VoidCallback onDismiss;
  final _HeatmapCopy copy;

  @override
  Widget build(BuildContext context) {
    if (point == null) {
      return Positioned(
        left: 20,
        right: 20,
        bottom: 120,
        child: _InfoBanner(
          color: AppColors.neonOrange,
          icon: Icons.search_off_rounded,
          title: 'NO DATA AT THIS LOCATION',
          body: 'Try tapping closer to a captured signal point.',
        ),
      );
    }

    final p = point!;
    final rssi = p.rssi;
    final color = _signalColor(rssi);

    final statusLabel = rssi > -60 ? 'OPTIMAL' : rssi > -75 ? 'FAIR' : 'CRITICAL';
    final statusColor = rssi > -60
        ? AppColors.neonGreen
        : rssi > -75
        ? AppColors.neonOrange
        : AppColors.neonRed;

    final apName = (p.ssid.isNotEmpty) ? p.ssid : p.bssid;
    final timeLabel = DateFormat('HH:mm:ss').format(p.timestamp);
    final posLabel =
        'X ${p.floorX.toStringAsFixed(1)} m  ·  Y ${p.floorY.toStringAsFixed(1)} m';
    final samplesLabel =
        '${p.sampleCount} samples  ·  ±${p.rssiStdDev.toStringAsFixed(1)} dBm';

    return Positioned.fill(
      child: Stack(
        children: [
          GestureDetector(
            onTap: onDismiss,
            behavior: HitTestBehavior.opaque,
            child: Container(color: Colors.black.withValues(alpha: 0.2)),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: StaggeredEntry(
                duration: const Duration(milliseconds: 400),
                child: GlassmorphicContainer(
                  borderRadius: BorderRadius.circular(28),
                  borderColor: color,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Header ──────────────────────────────────────────
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.analytics_rounded,
                              color: color,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SIGNAL PROBE',
                                  style: GoogleFonts.orbitron(
                                    color: color,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                                if (apName.isNotEmpty)
                                  Text(
                                    apName,
                                    style: GoogleFonts.outfit(
                                      color: AppColors.textMuted,
                                      fontSize: 11,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              color: AppColors.textMuted,
                            ),
                            onPressed: onDismiss,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── Primary stats row ────────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: _StatBrick(
                              label: 'RSSI',
                              value: '$rssi dBm',
                              color: color,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatBrick(
                              label: 'STATUS',
                              value: statusLabel,
                              color: statusColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatBrick(
                              label: 'FLOOR',
                              value: '${p.floor}',
                              color: AppColors.neonBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // ── Detail rows ──────────────────────────────────────
                      _ProbeDetailRow(
                        icon: Icons.location_on_outlined,
                        label: 'POSITION',
                        value: posLabel,
                      ),
                      const SizedBox(height: 6),
                      _ProbeDetailRow(
                        icon: Icons.wifi_outlined,
                        label: 'SAMPLES',
                        value: samplesLabel,
                      ),
                      const SizedBox(height: 6),
                      _ProbeDetailRow(
                        icon: Icons.schedule_outlined,
                        label: 'CAPTURED',
                        value: timeLabel,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _signalColor(int rssi) {
    if (rssi > -50) return AppColors.neonGreen;
    if (rssi > -65) return const Color(0xFFC6FF00); // Lime
    if (rssi > -75) return AppColors.neonOrange;
    return AppColors.neonRed;
  }
}

class _ProbeDetailRow extends StatelessWidget {
  const _ProbeDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.orbitron(
            color: AppColors.textMuted,
            fontSize: 9,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.outfit(
              color: AppColors.textPrimary,
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _SurveyConclusionOverlay extends StatelessWidget {
  const _SurveyConclusionOverlay({
    required this.session,
    required this.summary,
    required this.guidance,
    required this.copy,
    required this.onDismiss,
    required this.onNewSurvey,
  });

  final HeatmapSession session;
  final _HeatmapSummary summary;
  final SurveyGuidance guidance;
  final _HeatmapCopy copy;
  final VoidCallback onDismiss;
  final VoidCallback onNewSurvey;

  @override
  Widget build(BuildContext context) {
    final averageRssi = session.points.isEmpty
        ? 0
        : (session.points.map((p) => p.rssi).reduce((a, b) => a + b) /
                session.points.length)
            .round();

    final statusColor = averageRssi > -60
        ? AppColors.neonGreen
        : averageRssi > -75
        ? AppColors.neonOrange
        : AppColors.neonRed;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: StaggeredEntry(
          duration: const Duration(milliseconds: 600),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: GlassmorphicContainer(
            borderRadius: BorderRadius.circular(32),
            borderColor: AppColors.neonCyan.withValues(alpha: 0.3),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Badge/Header
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.neonCyan.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.neonCyan.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        color: AppColors.neonCyan,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'SURVEY COMPLETE',
                        style: GoogleFonts.orbitron(
                          color: AppColors.neonCyan,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Session Name
                Text(
                  session.name.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('MMMM dd, HH:mm').format(session.createdAt),
                  style: GoogleFonts.outfit(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 32),

                // Metrics Row
                Row(
                  children: [
                    Expanded(
                      child: _StatBrick(
                        label: 'AVG SIGNAL',
                        value: '$averageRssi dBm',
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatBrick(
                        label: 'COVERAGE',
                        value: '${(guidance.overallProgress * 100).round()}%',
                        color: AppColors.neonBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatBrick(
                        label: 'SAMPLES',
                        value: '${summary.sampleCount}',
                        color: AppColors.neonGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatBrick(
                        label: 'WALLS',
                        value: '${summary.wallCount}',
                        color: AppColors.neonCyan,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Insight Text
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        copy.findingsTitle,
                        style: GoogleFonts.orbitron(
                          color: AppColors.textMuted,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        guidance.summaryText,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Actions
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onDismiss,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppColors.neonCyan.withValues(alpha: 0.15),
                          foregroundColor: AppColors.neonCyan,
                          side: BorderSide(
                            color: AppColors.neonCyan.withValues(alpha: 0.4),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          copy.closeReview,
                          style: GoogleFonts.orbitron(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                    if (context.read<HeatmapBloc>().state.isArSupported) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => context.read<HeatmapBloc>().viewInAr(),
                          icon: const Icon(Icons.view_in_ar_rounded, size: 18),
                          label: Text(
                            'VIEW IN 3D',
                            style: GoogleFonts.orbitron(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 2,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                AppColors.neonCyan.withValues(alpha: 0.8),
                            foregroundColor: Colors.black,
                            elevation: 8,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: onNewSurvey,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                      ),
                      child: Text(
                        copy.newSurvey,
                        style: GoogleFonts.orbitron(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}

class _StatBrick extends StatelessWidget {
  const _StatBrick({
    required this.label,
    required this.value,
    this.color,
  });

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (color ?? Colors.white).withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.orbitron(
              color: AppColors.textMuted,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: color ?? Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
