import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:torcav/core/theme/app_theme.dart';
import 'package:torcav/features/heatmap/domain/services/survey_guidance_service.dart';
import 'package:torcav/features/heatmap/presentation/widgets/hud/dbm_gauge.dart';
import 'package:torcav/features/heatmap/presentation/widgets/hud/hud_dock.dart';
import 'package:torcav/features/heatmap/presentation/widgets/hud/hud_scrim.dart';
import 'package:torcav/features/heatmap/presentation/widgets/hud/live_signal_tag.dart';
import 'package:torcav/features/heatmap/presentation/widgets/hud/measurement_lock_banner.dart';
import 'package:torcav/features/heatmap/presentation/widgets/hud/mini_map_layer.dart';
import 'package:torcav/features/heatmap/presentation/widgets/hud/mode_badge.dart';
import 'package:torcav/features/heatmap/presentation/widgets/hud/ready_banner.dart';
import 'package:torcav/features/heatmap/presentation/widgets/hud/reticle_hit_area.dart';
import 'package:torcav/features/heatmap/presentation/widgets/hud/sample_badge.dart';
import 'package:torcav/features/heatmap/presentation/widgets/hud/sparse_region_arrow.dart';
import 'package:torcav/features/heatmap/presentation/widgets/hud/ssid_chip.dart';
import 'package:torcav/features/heatmap/presentation/widgets/hud/survey_pilot_card.dart';
import 'package:torcav/features/heatmap/presentation/widgets/hud/recording_status.dart';

/// Premium full-screen HUD overlay for the AR camera heatmap experience.
///
/// Composed of modular components (extracted from the previously monolithic file)
/// to ensure SOLID principles and maintainability.
class ArHudOverlay extends StatefulWidget {
  const ArHudOverlay({
    super.key,
    required this.guidance,
    this.estimatedMode = false,
    this.onFlagWeakZone,
    this.onFinish,
    this.onDiscard,
  });

  /// Latest guidance snapshot.
  final SurveyGuidance guidance;

  /// Whether we are in PDR-estimated mode.
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
  late final AnimationController _bannerCtl;

  @override
  void initState() {
    super.initState();
    _reticleCtl =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 1600),
        )..repeat();
    _bannerCtl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    if (widget.guidance.readyToFinish) {
      _bannerCtl.forward();
    }
  }

  @override
  void didUpdateWidget(covariant ArHudOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.guidance.readyToFinish && !oldWidget.guidance.readyToFinish) {
      _bannerCtl.forward(from: 0);
      HapticFeedback.heavyImpact();
    } else if (!widget.guidance.readyToFinish &&
        oldWidget.guidance.readyToFinish) {
      _bannerCtl.reverse();
    }

    _checkMilestoneHaptics(
      oldWidget.guidance.overallProgress,
      widget.guidance.overallProgress,
    );
  }

  void _checkMilestoneHaptics(double oldProgress, double newProgress) {
    if (oldProgress >= newProgress) return;

    final milestones = [0.25, 0.50, 0.75, 1.0];
    for (final milestone in milestones) {
      if (oldProgress < milestone && newProgress >= milestone) {
        if (milestone >= 1.0) {
          HapticFeedback.heavyImpact();
        } else if (milestone >= 0.5) {
          HapticFeedback.mediumImpact();
        } else {
          HapticFeedback.lightImpact();
        }
        break;
      }
    }
  }

  @override
  void dispose() {
    _reticleCtl.dispose();
    _bannerCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final guidance = widget.guidance;

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
                ],
              ),
            ),
          ),
        ),

        // Mode badge (Estimated / PDR)
        if (widget.estimatedMode)
          Positioned(
            top: 84,
            left: 14,
            child: ModeBadge(
              label: 'ESTIMATED MODE',
              color: AppColors.neonOrange,
            ),
          ),

        // 3. Survey Pilot card (top-right)
        Positioned(
          top: 96,
          right: 14,
          child: SurveyPilotCard(guidance: guidance),
        ),

        // 3b. Mini Map layer
        const Positioned(top: 260, right: 14, child: MiniMapLayer()),

        // Lock Banner for survey states
        const Positioned(
          top: 168,
          left: 14,
          right: 14,
          child: MeasurementLockBanner(),
        ),

        // 4. Left rail dBm gauge
        const Positioned(left: 10, top: 170, bottom: 220, child: DbmGauge()),

        // 6. Sparse-region directional arrow
        if (guidance.sparseRegion != null)
          Positioned(
            bottom: 180,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Center(
                child: SparseRegionArrow(
                  region: guidance.sparseRegion!,
                  controller: _reticleCtl,
                  tone: guidance.tone,
                ),
              ),
            ),
          ),

        // 7. Center reticle
        Positioned.fill(
          child: Center(
            child: ReticleHitArea(
              controller: _reticleCtl,
              onFlagWeakZone: widget.onFlagWeakZone,
            ),
          ),
        ),

        // 8. Sample badge (bottom-left)
        const Positioned(bottom: 28, left: 16, child: SampleBadge()),

        // 9. Bottom-right control dock
        Positioned(
          bottom: 24,
          right: 16,
          child: HudDock(
            onFlagWeakZone: widget.onFlagWeakZone,
            onFinish: widget.onFinish,
            onDiscard: widget.onDiscard,
          ),
        ),

        // 10. Ready-to-finish banner
        if (guidance.readyToFinish)
          Positioned(
            bottom: 110,
            left: 24,
            right: 24,
            child: ReadyBanner(controller: _bannerCtl),
          ),

        // 11. Live Diagnostic Tag (bottom-center)
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
      ],
    );
  }
}
