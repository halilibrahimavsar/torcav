import 'package:flutter/material.dart';

import 'package:torcav/core/theme/app_theme.dart';

import 'package:torcav/features/heatmap/presentation/widgets/hud/hud_dock.dart';
import 'package:torcav/features/heatmap/presentation/widgets/hud/hud_scrim.dart';
import 'package:torcav/features/heatmap/presentation/widgets/hud/live_signal_tag.dart';
import 'package:torcav/features/heatmap/presentation/widgets/hud/measurement_lock_banner.dart';
import 'package:torcav/features/heatmap/presentation/widgets/hud/mini_map_layer.dart';
import 'package:torcav/features/heatmap/presentation/widgets/hud/mode_badge.dart';
import 'package:torcav/features/heatmap/presentation/widgets/hud/reticle_hit_area.dart';
import 'package:torcav/features/heatmap/presentation/widgets/hud/ssid_chip.dart';
import 'package:torcav/features/heatmap/presentation/widgets/hud/recording_status.dart';

/// Premium full-screen HUD overlay for the AR camera heatmap experience.
///
/// Composed of modular components to ensure SOLID principles and
/// maintainability. Shows: SSID, recording status, mini-map, lock banner,
/// reticle, dock controls, and live signal tag.
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
    with SingleTickerProviderStateMixin {
  late final AnimationController _reticleCtl;

  @override
  void initState() {
    super.initState();
    _reticleCtl =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 1600),
        )..repeat();
  }

  @override
  void dispose() {
    _reticleCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

        // 3. Mini Map layer (top-right)
        const Positioned(top: 96, right: 14, child: MiniMapLayer()),

        // 4. Lock Banner for survey gate states
        const Positioned(
          top: 168,
          left: 14,
          right: 14,
          child: MeasurementLockBanner(),
        ),

        // 5. Center reticle
        Positioned.fill(
          child: Center(
            child: ReticleHitArea(
              controller: _reticleCtl,
              onFlagWeakZone: widget.onFlagWeakZone,
            ),
          ),
        ),

        // 6. Bottom-right control dock
        Positioned(
          bottom: 24,
          right: 16,
          child: HudDock(
            onFlagWeakZone: widget.onFlagWeakZone,
            onFinish: widget.onFinish,
            onDiscard: widget.onDiscard,
          ),
        ),

        // 7. Live Diagnostic Tag (bottom-center)
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
