import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:torcav/core/theme/app_theme.dart';
import 'package:torcav/features/heatmap/domain/entities/survey_gate.dart';
import 'package:torcav/features/heatmap/domain/services/survey_guidance_service.dart';
import 'package:torcav/features/heatmap/presentation/bloc/heatmap_bloc.dart';
import 'package:torcav/features/heatmap/presentation/bloc/scan_phase.dart';

import 'package:torcav/features/heatmap/presentation/widgets/hud/hud_dock.dart';
import 'package:torcav/features/heatmap/presentation/widgets/hud/hud_models.dart';
import 'package:torcav/features/heatmap/presentation/widgets/hud/hud_scrim.dart';
import 'package:torcav/features/heatmap/presentation/widgets/hud/live_signal_tag.dart';
import 'package:torcav/features/heatmap/presentation/widgets/hud/measurement_lock_banner.dart';
import 'package:torcav/features/heatmap/presentation/widgets/hud/mini_map_layer.dart';
import 'package:torcav/features/heatmap/presentation/widgets/hud/mode_badge.dart';
import 'package:torcav/features/heatmap/presentation/widgets/hud/ready_banner.dart';
import 'package:torcav/features/heatmap/presentation/widgets/hud/reticle_hit_area.dart';
import 'package:torcav/features/heatmap/presentation/widgets/hud/sparse_region_arrow.dart';
import 'package:torcav/features/heatmap/presentation/widgets/hud/ssid_chip.dart';
import 'package:torcav/features/heatmap/presentation/widgets/hud/guidance_pill.dart';
import 'package:torcav/features/heatmap/presentation/widgets/hud/recording_status.dart';
import 'package:torcav/features/heatmap/presentation/widgets/hud/survey_pilot_card.dart';

/// Premium full-screen HUD overlay for the AR camera heatmap experience.
///
/// Composed of modular components to ensure SOLID principles and
/// maintainability. Shows: SSID, recording status, mini-map, lock banner,
/// reticle, dock controls, live diagnostic tag, and survey-guidance widgets
/// (pilot card, sparse-region arrow, ready-to-save banner, guidance pill).
class ArHudOverlay extends StatefulWidget {
  const ArHudOverlay({
    super.key,
    this.estimatedMode = false,
    this.onFlagWeakZone,
    this.onFinish,
    this.onDiscard,
  });

  /// Whether we are in PDR-estimated mode (no ARCore).
  final bool estimatedMode;

  /// Called when the user taps the flag dock button or the reticle.
  final VoidCallback? onFlagWeakZone;

  /// Called when the user taps the Finish & Review dock button.
  final VoidCallback? onFinish;

  /// Called when the user taps the Discard dock button.
  final VoidCallback? onDiscard;

  @override
  State<ArHudOverlay> createState() => _ArHudOverlayState();
}

class _ArHudOverlayState extends State<ArHudOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _reticleCtl;
  late final AnimationController _chevronCtl;
  late final AnimationController _readyCtl;

  @override
  void initState() {
    super.initState();
    _reticleCtl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    _chevronCtl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _readyCtl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    _reticleCtl.dispose();
    _chevronCtl.dispose();
    _readyCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topGuidanceTop = widget.estimatedMode ? 128.0 : 88.0;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Scrim gradient for readability
        const IgnorePointer(child: HudScrim()),

        // 2. Top bar: SSID + REC Status
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Flexible(child: SsidChip()),
                  const SizedBox(width: 8),
                  const RecordingStatus(),
                  const Spacer(),
                  IconButton(
                    onPressed: () => context.read<HeatmapBloc>().realignHeading(),
                    icon: const Icon(Icons.explore_rounded, color: Colors.white),
                    tooltip: 'Realign Compass',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.4),
                      shape: const CircleBorder(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _showSettingsSheet(context),
                    icon: const Icon(Icons.settings_rounded, color: Colors.white),
                    tooltip: 'Settings',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.4),
                      shape: const CircleBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // 3. Guidance Pill (top-center)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Center(
                child: BlocSelector<HeatmapBloc, HeatmapState, GuidanceSlice>(
                  selector: (s) => GuidanceSlice(
                    guidance: const SurveyGuidanceService().analyze(
                      points: s.currentSession?.points ?? const [],
                      floorPlan: s.liveFloorPlan,
                      isRecording: s.isRecording,
                      hasArOrigin: s.currentPosition != null,
                      pendingWallCount: s.pendingWalls.length,
                      currentRssi: s.currentRssi,
                      surveyGate: s.surveyGate,
                      lastSignalAt: s.lastSignalAt,
                      currentSignalStdDev: s.lastSignalStdDev,
                      currentX: s.currentPosition?.dx,
                      currentY: s.currentPosition?.dy,
                    ),
                  ),
                  builder: (context, slice) {
                    return GuidancePill(
                      stage: slice.guidance.stage,
                      tone: slice.guidance.tone,
                      customInstruction: slice.guidance.customInstruction,
                    );
                  },
                ),
              ),
            ),
          ),
        ),

        // Mode badge (Estimated / PDR)
        if (widget.estimatedMode)
          const Positioned(
            top: 84,
            left: 14,
            child: ModeBadge(
              label: 'ESTIMATED MODE',
              color: AppColors.neonOrange,
            ),
          ),

        // 4. Mini Map layer (top-right)
        const Positioned(top: 96, right: 14, child: MiniMapLayer()),

        // 5. Lock Banner for survey gate states
        const Positioned(
          top: 168,
          left: 14,
          right: 14,
          child: MeasurementLockBanner(),
        ),

        // 6. Center reticle
        Positioned.fill(
          child: Center(
            child: ReticleHitArea(
              controller: _reticleCtl,
              onFlagWeakZone: widget.onFlagWeakZone,
            ),
          ),
        ),

        // 7. Bottom-right control dock
        Positioned(
          bottom: 24,
          right: 16,
          child: HudDock(
            onFlagWeakZone: widget.onFlagWeakZone,
            onFinish: widget.onFinish,
            onDiscard: widget.onDiscard,
          ),
        ),

        // 8. Live Diagnostic Tag (bottom-center)
        Positioned(
          bottom: 110,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Center(
              child: LiveSignalTag(estimatedMode: widget.estimatedMode),
            ),
          ),
        ),

        // 9. Survey guidance layer — pilot card, sparse arrow, ready banner.
        _GuidanceLayer(
          chevronCtl: _chevronCtl,
          readyCtl: _readyCtl,
          topGuidanceTop: topGuidanceTop,
        ),
      ],
    );
  }

  void _showSettingsSheet(BuildContext context) {
    final bloc = context.read<HeatmapBloc>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black.withValues(alpha: 0.9),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return BlocProvider.value(
          value: bloc,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Heatmap Settings',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 24),
                Text(
                  'Auto-sampling Distance',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
                BlocBuilder<HeatmapBloc, HeatmapState>(
                  builder: (context, state) {
                    return Column(
                      children: [
                        Slider(
                          value: state.autoSamplingDistance,
                          min: 0.5,
                          max: 2.5,
                          divisions: 8, // Steps of 0.25
                          label: '${state.autoSamplingDistance.toStringAsFixed(2)}m',
                          activeColor: AppColors.neonCyan,
                          inactiveColor: Colors.white24,
                          onChanged: (val) {
                            context.read<HeatmapBloc>().updateAutoSamplingDistance(val);
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('0.5m', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54)),
                            Text('2.5m', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          value: state.isAutoWallEnabled,
                          title: Text(
                            'Auto-Wall Detection',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
                          ),
                          subtitle: Text(
                            'Automatically commit walls after 1.2s of focus',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54),
                          ),
                          activeColor: AppColors.neonYellow,
                          activeTrackColor: AppColors.neonYellow.withValues(alpha: 0.3),
                          onChanged: (_) => context.read<HeatmapBloc>().toggleAutoWall(),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}


/// Reads a memoized guidance slice from the bloc and renders the three
/// guidance-driven widgets: [SurveyPilotCard] (top-left), [SparseRegionArrow]
/// (top-center, when coverage is lopsided), and [ReadyBanner] (bottom-center,
/// when conditions are complete).
class _GuidanceLayer extends StatefulWidget {
  const _GuidanceLayer({
    required this.chevronCtl,
    required this.readyCtl,
    required this.topGuidanceTop,
  });

  final AnimationController chevronCtl;
  final AnimationController readyCtl;
  final double topGuidanceTop;

  @override
  State<_GuidanceLayer> createState() => _GuidanceLayerState();
}

class _GuidanceLayerState extends State<_GuidanceLayer> {
  static const _service = SurveyGuidanceService();
  bool _wasReady = false;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HeatmapBloc, HeatmapState, GuidanceCameraSlice>(
      selector: (s) => GuidanceCameraSlice(
        pointCount: s.currentSession?.points.length ?? 0,
        hasFloorPlan: s.liveFloorPlan?.walls.isNotEmpty ?? false,
        isRecording: s.isRecording,
        hasArOrigin: s.currentPosition != null,
        pendingWallCount: s.pendingWalls.length,
        currentRssi: s.currentRssi,
        surveyGate: s.surveyGate,
        lastSignalAt: s.lastSignalAt,
        lastSignalStdDev: s.lastSignalStdDev,
        currentPosition: s.currentPosition,
        phase: s.phase,
        pendingWalls: s.pendingWalls,
        lastStepTimestamp: s.lastStepTimestamp,
      ),
      builder: (context, slice) {
        if (slice.phase != ScanPhase.scanning || !slice.isRecording) {
          return const SizedBox.shrink();
        }

        final session = context.read<HeatmapBloc>().state.currentSession;
        final floorPlan = context.read<HeatmapBloc>().state.liveFloorPlan;

        final guidance = _service.analyze(
          points: session?.points ?? const [],
          floorPlan: floorPlan,
          isRecording: slice.isRecording,
          hasArOrigin: slice.hasArOrigin,
          pendingWallCount: slice.pendingWallCount,
          currentRssi: slice.currentRssi,
          surveyGate: slice.surveyGate,
          lastSignalAt: slice.lastSignalAt,
          currentSignalStdDev: slice.lastSignalStdDev,
          currentX: slice.currentPosition?.dx,
          currentY: slice.currentPosition?.dy,
        );

        _syncReadyAnimation(guidance.readyToFinish);

        final hasLockBanner = slice.surveyGate != SurveyGate.none;
        final showSparseArrow =
            guidance.sparseRegion != null && !hasLockBanner;

        return Stack(
          fit: StackFit.expand,
          children: [
            // Pilot card — top-left, beneath SSID/mode rows. Skipped when the
            // lock banner is visible to avoid visual collision.
            if (!hasLockBanner)
              Positioned(
                top: widget.topGuidanceTop,
                left: 14,
                child: SurveyPilotCard(guidance: guidance),
              ),

            // Sparse-region arrow — top-center, points user to under-sampled
            // quadrant. Hidden behind the lock banner when gating is active.
            if (showSparseArrow)
              Positioned(
                top: 178,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Center(
                    child: SparseRegionArrow(
                      region: guidance.sparseRegion!,
                      controller: widget.chevronCtl,
                      tone: guidance.tone,
                    ),
                  ),
                ),
              ),

            // Ready banner — bottom-center, above LiveSignalTag. Tappable to
            // trigger stopScanning via its internal handler.
            if (guidance.readyToFinish)
              Positioned(
                bottom: 178,
                left: 24,
                right: 24,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: ReadyBanner(controller: widget.readyCtl),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _syncReadyAnimation(bool ready) {
    if (ready == _wasReady) return;
    _wasReady = ready;
    if (ready) {
      widget.readyCtl.forward(from: 0);
    } else {
      widget.readyCtl.value = 0;
    }
  }
}
