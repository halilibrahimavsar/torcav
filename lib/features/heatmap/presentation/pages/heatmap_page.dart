import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:torcav/core/di/injection.dart';
import 'package:torcav/core/theme/app_theme.dart';
import 'package:torcav/core/theme/neon_widgets.dart';
import 'package:torcav/features/heatmap/domain/entities/heatmap_point.dart';
import 'package:torcav/features/heatmap/domain/entities/heatmap_session.dart';
import 'package:torcav/features/heatmap/domain/services/survey_guidance_service.dart';
import 'package:torcav/features/heatmap/presentation/bloc/heatmap_bloc.dart';
import 'package:torcav/features/heatmap/presentation/bloc/scan_phase.dart';
import 'package:torcav/features/heatmap/presentation/widgets/ar_camera_view.dart';
import 'package:torcav/features/heatmap/presentation/widgets/arcore_heatmap_view.dart';
import 'package:torcav/features/heatmap/presentation/widgets/heatmap/heatmap_page_models.dart';
import 'package:torcav/features/heatmap/presentation/widgets/heatmap/heatmap_tutorial_overlay.dart';
import 'package:torcav/features/heatmap/presentation/widgets/heatmap/heatmap_utility_widgets.dart';
import 'package:torcav/features/heatmap/presentation/widgets/heatmap/new_session_dialog.dart';
import 'package:torcav/features/heatmap/presentation/widgets/heatmap/session_picker_sheet.dart';
import 'package:torcav/features/heatmap/presentation/widgets/heatmap/signal_probe_overlay.dart';
import 'package:torcav/features/heatmap/presentation/widgets/heatmap/survey_conclusion_overlay.dart';
import 'package:torcav/features/heatmap/presentation/widgets/heatmap_canvas.dart';

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
    final copy = HeatmapCopy.of(context);

    return BlocProvider(
      create: (_) => getIt<HeatmapBloc>()..loadSessions(),
      child: Stack(
        children: [
          const _HeatmapView(),
          if (_showTutorial)
            HeatmapTutorialOverlay(copy: copy, onDismiss: _dismissTutorial),
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
    final copy = HeatmapCopy.of(context);

    return BlocBuilder<HeatmapBloc, HeatmapState>(
      builder: (context, state) {
        final bloc = context.read<HeatmapBloc>();
        final isRecording = state.isRecording;
        final isScanning = isRecording && state.phase == ScanPhase.scanning;
        final isReviewing = state.phase == ScanPhase.reviewing;

        final session = isRecording ? state.currentSession : state.selectedSession;
        final floorPlan = isRecording ? state.liveFloorPlan : session?.floorPlan;

        final summary = HeatmapSummary.from(
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

        _guidanceService.analyze(
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
                        onPressed: () => _showSessionsPicker(context, state.sessions, copy),
                      ),
                    ],
                  ),
          body: Stack(
            fit: StackFit.expand,
            children: [
              // 2D Result / Idle Layer
              Stack(
                children: [
                  CanvasBackdrop(summary: summary),
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
                    CanvasEmptyState(
                      state: state,
                      copy: copy,
                      onStart:
                          () => _showNewSessionDialog(context, bloc, copy),
                    ),
                  Positioned(
                    top: 14,
                    left: 14,
                    child: ViewModeBadge(label: copy.resultViewLabel),
                  ),
                  if (isReviewing && _probePoint == null && session != null)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: SurveyConclusionOverlay(
                        summary: summary,
                        copy: copy,
                        onRestart: () => bloc.startSession(session.name),
                        onDone: bloc.finishSession,
                      ),
                    ),
                  if (_probePoint != null && session != null)
                    SignalProbeOverlay(
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
    HeatmapCopy copy,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => NewSessionDialog(bloc: bloc, copy: copy),
    );
  }

  void _showSessionsPicker(BuildContext context, List<HeatmapSession> sessions, HeatmapCopy copy) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.deepBlack,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) => SessionPickerSheet(
        sessions: sessions,
        copy: copy,
        onSelect: (session) {
          context.read<HeatmapBloc>().selectSession(session);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  bool _shouldShowCanvasEmptyState(
    HeatmapState state,
    HeatmapSummary summary,
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

}
