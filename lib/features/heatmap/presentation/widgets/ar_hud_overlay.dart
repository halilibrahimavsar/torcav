import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../domain/entities/heatmap_point.dart';
import '../../domain/entities/heatmap_session.dart';
import '../../domain/entities/wall_segment.dart';
import '../../domain/services/signal_tier.dart';
import '../../domain/services/survey_guidance_service.dart';
import '../bloc/heatmap_bloc.dart';
import '../bloc/survey_gate.dart';
import 'heatmap_canvas.dart';

/// Premium full-screen HUD overlay for the AR camera heatmap experience.
///
/// Reads live state from [HeatmapBloc] via granular [BlocSelector]s so each
/// sub-region rebuilds independently. Renders over both [ArCoreView] and
/// the camera-fallback [CameraPreview] without consuming gestures outside
/// the center reticle — ARCore/camera still receive pan/tap events everywhere
/// else.
///
/// Usage:
/// ```dart
/// Stack(children: [
///   ArCoreView(...),
///   ArHudOverlay(
///     guidance: SurveyGuidanceService().analyze(...),
///     onExpand: () => _toggleFullScreen(true),
///     onFlagWeakZone: _flagCurrentPosition,
///   ),
/// ])
/// ```
class ArHudOverlay extends StatefulWidget {
  const ArHudOverlay({
    super.key,
    required this.guidance,
    this.immersive = false,
    this.estimatedMode = false,
    this.onExpand,
    this.onCollapse,
    this.onFlagWeakZone,
  });

  /// Latest guidance snapshot. The parent is responsible for calling
  /// [SurveyGuidanceService.analyze] — the overlay does not recompute it.
  final SurveyGuidance guidance;

  /// True when hosted inside the expanded (pseudo-fullscreen) mode in [HeatmapPage].
  /// Hides the expand button and shows the collapse button instead.
  final bool immersive;

  /// True when the AR view is actually the camera fallback and spatial
  /// placement is estimated rather than anchored.
  final bool estimatedMode;

  /// Called when the user taps the expand-to-fullscreen dock button. Null when
  /// already in fullscreen mode.
  final VoidCallback? onExpand;

  /// Called when the user taps the collapse dock button inside fullscreen mode.
  final VoidCallback? onCollapse;

  /// Called when the user taps the center reticle while RSSI indicates a weak
  /// or poor tier, or taps the flag dock button.
  final VoidCallback? onFlagWeakZone;

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
    _reticleCtl = AnimationController(
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
    } else if (!widget.guidance.readyToFinish &&
        oldWidget.guidance.readyToFinish) {
      _bannerCtl.reverse();
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
        // ── 1. Scrim gradient for readability ──────────────────────────
        const IgnorePointer(child: _HudScrim()),

        // ── 2. Top bar: SSID + compass ─────────────────────────────────
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
                  const Flexible(child: _SsidChip()),
                  const SizedBox(width: 10),
                  const _CompassRing(),
                ],
              ),
            ),
          ),
        ),

        if (widget.estimatedMode)
          Positioned(
            top: 84,
            left: 14,
            child: _ModeBadge(
              label: 'ESTIMATED MODE',
              color: AppColors.neonOrange,
            ),
          ),

        // ── 3. Survey Pilot card (top-right) ───────────────────────────
        Positioned(
          top: 96,
          right: 14,
          child: _SurveyPilotCard(guidance: guidance),
        ),

        const Positioned(
          top: 168,
          left: 14,
          right: 14,
          child: _MeasurementLockBanner(),
        ),

        // ── 4. Left rail dBm gauge ─────────────────────────────────────
        const Positioned(left: 10, top: 170, bottom: 220, child: _DbmGauge()),

        // ── 5. Right rail mini-map ─────────────────────────────────────
        Positioned(right: 14, top: 280, child: _MiniMapPanel()),

        // ── 6. Sparse-region directional arrow (above dock) ─────────────
        if (guidance.sparseRegion != null)
          Positioned(
            bottom: 180,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Center(
                child: _SparseRegionArrow(
                  region: guidance.sparseRegion!,
                  controller: _reticleCtl,
                  tone: guidance.tone,
                ),
              ),
            ),
          ),

        // ── 7. Center reticle (only interactive region outside the dock) ─
        Positioned.fill(
          child: Center(
            child: _ReticleHitArea(
              controller: _reticleCtl,
              onFlagWeakZone: widget.onFlagWeakZone,
            ),
          ),
        ),

        // ── 8. Sample badge (bottom-left) ───────────────────────────────
        const Positioned(bottom: 28, left: 16, child: _SampleBadge()),

        // ── 9. Bottom-right dock ────────────────────────────────────────
        Positioned(
          bottom: 24,
          right: 16,
          child: _Dock(
            immersive: widget.immersive,
            onExpand: widget.onExpand,
            onCollapse: widget.onCollapse,
            onFlagWeakZone: widget.onFlagWeakZone,
          ),
        ),

        // ── 10. Ready-to-finish banner ──────────────────────────────────
        if (guidance.readyToFinish)
          Positioned(
            bottom: 110,
            left: 24,
            right: 24,
            child: _ReadyBanner(controller: _bannerCtl),
          ),

        // ── 11. Live Diagnostic Tag (bottom-center) ────────────────────
        Positioned(
          bottom: 110,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Center(
              child: _LiveSignalTag(estimatedMode: widget.estimatedMode),
            ),
          ),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────
// 1. Scrim — subtle top + bottom gradient for HUD text readability.
// ────────────────────────────────────────────────────────────────────

class _HudScrim extends StatelessWidget {
  const _HudScrim();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.25, 0.75, 1.0],
          colors: [
            Color(0xCC000000),
            Color(0x33000000),
            Color(0x33000000),
            Color(0xCC000000),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────
// 2a. SSID chip — top-left glass pill with live SSID/BSSID.
// ────────────────────────────────────────────────────────────────────

class _SsidChip extends StatelessWidget {
  const _SsidChip();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HeatmapBloc, HeatmapState, _SsidSlice>(
      selector: (s) {
        return _SsidSlice(
          ssid: s.targetSsid ?? '',
          bssid: s.targetBssid ?? '',
          rssi: s.currentRssi,
          locked: s.surveyGate == SurveyGate.none,
        );
      },
      builder: (context, slice) {
        final tier = signalTierFor(slice.rssi);
        final color = signalTierColor(tier);
        return GlassmorphicContainer(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          borderRadius: BorderRadius.circular(18),
          borderColor: color,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_rounded, color: color, size: 16),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      slice.ssid.isEmpty
                          ? 'LIVE WI-FI'
                          : slice.ssid.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.orbitron(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      slice.bssid.isEmpty
                          ? signalTierLabel(tier)
                          : '${slice.locked ? 'LOCK' : 'HOLD'} ${_compactBssid(slice.bssid)}',
                      style: GoogleFonts.outfit(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SsidSlice {
  const _SsidSlice({
    required this.ssid,
    required this.bssid,
    required this.rssi,
    required this.locked,
  });
  final String ssid;
  final String bssid;
  final int? rssi;
  final bool locked;

  @override
  bool operator ==(Object other) =>
      other is _SsidSlice &&
      other.ssid == ssid &&
      other.bssid == bssid &&
      other.rssi == rssi &&
      other.locked == locked;

  @override
  int get hashCode => Object.hash(ssid, bssid, rssi, locked);
}

String _compactBssid(String bssid) {
  if (bssid.length < 8) return bssid;
  final parts = bssid.split(':');
  if (parts.length < 3) return bssid;
  return '${parts.first}:${parts[1]}:..:${parts.last}';
}

// ────────────────────────────────────────────────────────────────────
// 2b. Compass ring — heading indicator, 52px.
// ────────────────────────────────────────────────────────────────────

class _CompassRing extends StatelessWidget {
  const _CompassRing();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HeatmapBloc, HeatmapState, double>(
      selector: (s) => s.currentHeading,
      builder: (context, heading) {
        return SizedBox(
          width: 56,
          height: 56,
          child: CustomPaint(painter: _CompassPainter(heading: heading)),
        );
      },
    );
  }
}

class _CompassPainter extends CustomPainter {
  _CompassPainter({required this.heading});

  final double heading;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Glass backing disc.
    final bgPaint = Paint()..color = Colors.black.withValues(alpha: 0.55);
    canvas.drawCircle(center, radius, bgPaint);

    // Ring.
    final ringPaint =
        Paint()
          ..color = AppColors.neonCyan.withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius, ringPaint);

    // Cardinal ticks.
    final tickPaint =
        Paint()
          ..color = AppColors.neonCyan.withValues(alpha: 0.5)
          ..strokeWidth = 1;
    for (var i = 0; i < 12; i++) {
      final angle = (i * 30) * math.pi / 180;
      final inner =
          center +
          Offset(
            math.sin(angle) * (radius - 4),
            -math.cos(angle) * (radius - 4),
          );
      final outer =
          center + Offset(math.sin(angle) * radius, -math.cos(angle) * radius);
      canvas.drawLine(inner, outer, tickPaint);
    }

    // North indicator (rotates opposite to heading).
    final headingRad = -heading * math.pi / 180;
    final needlePaint =
        Paint()
          ..color = AppColors.neonRed
          ..style = PaintingStyle.fill;
    final path =
        Path()
          ..moveTo(
            center.dx + math.sin(headingRad) * (radius - 6),
            center.dy - math.cos(headingRad) * (radius - 6),
          )
          ..lineTo(
            center.dx + math.sin(headingRad + 0.35) * 4,
            center.dy - math.cos(headingRad + 0.35) * 4,
          )
          ..lineTo(
            center.dx + math.sin(headingRad - 0.35) * 4,
            center.dy - math.cos(headingRad - 0.35) * 4,
          )
          ..close();
    canvas.drawPath(path, needlePaint);

    // "N" label (always at top of world).
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'N',
        style: TextStyle(
          color: AppColors.neonCyan,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(center.dx - textPainter.width / 2, 2));
  }

  @override
  bool shouldRepaint(covariant _CompassPainter oldDelegate) =>
      oldDelegate.heading != heading;
}

// ────────────────────────────────────────────────────────────────────
// 3. Survey Pilot card — stage, tone, 3 progress rings, feed dots.
// ────────────────────────────────────────────────────────────────────

class _SurveyPilotCard extends StatelessWidget {
  const _SurveyPilotCard({required this.guidance});

  final SurveyGuidance guidance;

  @override
  Widget build(BuildContext context) {
    final accent = _toneColor(guidance.tone);
    return SizedBox(
      width: 190,
      child: HolographicCard(
        color: accent,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(_toneIcon(guidance.tone), color: accent, size: 14),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      _stageLabel(guidance.stage),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.orbitron(
                        color: accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _MiniRing(
                    value: guidance.planScore,
                    color: AppColors.neonPurple,
                    label: 'PLAN',
                  ),
                  _MiniRing(
                    value: guidance.coverageScore,
                    color: AppColors.neonCyan,
                    label: 'COV',
                  ),
                  _MiniRing(
                    value: guidance.signalScore,
                    color: AppColors.neonGreen,
                    label: 'SIG',
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(height: 1, color: accent.withValues(alpha: 0.25)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _FeedDot(label: 'MOT', live: guidance.feeds.motionLive),
                  _FeedDot(label: 'WIFI', live: guidance.feeds.wifiLive),
                  _FeedDot(label: 'CAM', live: guidance.feeds.cameraLive),
                  _FeedDot(label: 'MAP', live: guidance.feeds.planLive),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Color _toneColor(SurveyTone tone) {
    switch (tone) {
      case SurveyTone.info:
        return AppColors.neonCyan;
      case SurveyTone.progress:
        return AppColors.neonYellow;
      case SurveyTone.caution:
        return AppColors.neonOrange;
      case SurveyTone.success:
        return AppColors.neonGreen;
    }
  }

  static IconData _toneIcon(SurveyTone tone) {
    switch (tone) {
      case SurveyTone.info:
        return Icons.info_outline_rounded;
      case SurveyTone.progress:
        return Icons.autorenew_rounded;
      case SurveyTone.caution:
        return Icons.warning_amber_rounded;
      case SurveyTone.success:
        return Icons.check_circle_outline_rounded;
    }
  }

  static String _stageLabel(SurveyStage stage) {
    switch (stage) {
      case SurveyStage.idle:
        return 'STANDBY';
      case SurveyStage.calibration:
        return 'CALIBRATE';
      case SurveyStage.planCapture:
        return 'SCAN WALLS';
      case SurveyStage.coverageSweep:
        return 'SWEEP ROOMS';
      case SurveyStage.weakZoneReview:
        return 'WEAK ZONE';
      case SurveyStage.wrapUp:
        return 'WRAP UP';
      case SurveyStage.review:
        return 'REVIEW';
    }
  }
}

class _MiniRing extends StatelessWidget {
  const _MiniRing({
    required this.value,
    required this.color,
    required this.label,
  });

  final double value;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 38,
          height: 38,
          child: CustomPaint(
            painter: _MiniRingPainter(value: value.clamp(0, 1), color: color),
            child: Center(
              child: Text(
                '${(value.clamp(0, 1) * 100).round()}',
                style: GoogleFonts.orbitron(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: GoogleFonts.outfit(
            color: color.withValues(alpha: 0.85),
            fontSize: 8,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

class _MiniRingPainter extends CustomPainter {
  _MiniRingPainter({required this.value, required this.color});

  final double value;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    final trackPaint =
        Paint()
          ..color = color.withValues(alpha: 0.18)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    final progressPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * value,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _MiniRingPainter oldDelegate) =>
      oldDelegate.value != value || oldDelegate.color != color;
}

class _FeedDot extends StatelessWidget {
  const _FeedDot({required this.label, required this.live});

  final String label;
  final bool live;

  @override
  Widget build(BuildContext context) {
    final color = live ? AppColors.neonGreen : AppColors.textMuted;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        live
            ? PulsingDot(color: color, size: 8)
            : Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.35),
                shape: BoxShape.circle,
              ),
            ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.outfit(
            color: color,
            fontSize: 8,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────
// 4. Left rail dBm gauge.
// ────────────────────────────────────────────────────────────────────

class _DbmGauge extends StatelessWidget {
  const _DbmGauge();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HeatmapBloc, HeatmapState, int?>(
      selector: (s) => s.currentRssi,
      builder: (context, rssi) {
        final tier = signalTierFor(rssi);
        final color = signalTierColor(tier);
        return SizedBox(
          width: 48,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                rssi == null ? '-- dBm' : '$rssi dBm',
                style: GoogleFonts.orbitron(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: CustomPaint(
                  painter: _GaugePainter(rssi: rssi),
                  size: Size.infinite,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'RSSI',
                style: GoogleFonts.outfit(
                  color: AppColors.textSecondary,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({required this.rssi});

  final int? rssi;

  @override
  void paint(Canvas canvas, Size size) {
    final trackRect = Rect.fromLTWH(size.width / 2 - 6, 0, 12, size.height);
    final rrect = RRect.fromRectAndRadius(trackRect, const Radius.circular(6));

    // Gradient background (red at bottom → green at top).
    final gradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: const [
        Color(0xFFFF1744),
        Color(0xFFFF6E27),
        Color(0xFFEEFF41),
        Color(0xFF00F5FF),
        Color(0xFF39FF14),
      ],
    );
    canvas.drawRRect(rrect, Paint()..shader = gradient.createShader(trackRect));

    // Border.
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    if (rssi == null) return;

    // Tick marker.
    final normalized = ((rssi! + 90) / 55).clamp(0.0, 1.0);
    final tickY = size.height - size.height * normalized;
    final color = signalGradientColor(rssi!);
    final tickPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2, tickY), 7, tickPaint);

    final glowPaint =
        Paint()
          ..color = color.withValues(alpha: 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(Offset(size.width / 2, tickY), 10, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.rssi != rssi;
}

// ────────────────────────────────────────────────────────────────────
// 5. Right rail mini-map. Bucketed rebuild to avoid per-sample churn.
// ────────────────────────────────────────────────────────────────────

class _MiniMapPanel extends StatelessWidget {
  const _MiniMapPanel();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HeatmapBloc, HeatmapState, _MiniMapSlice>(
      selector: (s) {
        final points = s.currentSession?.points ?? const <HeatmapPoint>[];
        final walls = (s.liveFloorPlan?.walls ?? const <WallSegment>[]).length;
        final pos = s.currentPosition;
        final bucket = points.length ~/ 3;
        final posKey =
            pos == null
                ? '-'
                : '${(pos.dx * 10).round()}_${(pos.dy * 10).round()}';
        return _MiniMapSlice(
          pointCountBucket: bucket,
          wallCount: walls,
          positionKey: posKey,
          rawState: s,
        );
      },
      builder: (context, slice) {
        final s = slice.rawState;
        final session =
            s.currentSession ??
            HeatmapSession(
              id: '',
              name: '',
              points: const [],
              createdAt: DateTime.now(),
            );
        return SizedBox(
          width: 120,
          height: 150,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.neonCyan.withValues(alpha: 0.28),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 6, 8, 2),
                    child: Row(
                      children: [
                        Icon(
                          Icons.map_outlined,
                          color: AppColors.neonCyan,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          s.isArSupported ? 'MAP' : 'MAP EST',
                          style: GoogleFonts.orbitron(
                            color: AppColors.neonCyan,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                      child: HeatmapCanvas(
                        session: session,
                        floorPlan: s.liveFloorPlan,
                        showPath: true,
                        activeFloor: s.currentFloor,
                        currentPosition: s.currentPosition,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MiniMapSlice {
  const _MiniMapSlice({
    required this.pointCountBucket,
    required this.wallCount,
    required this.positionKey,
    required this.rawState,
  });

  final int pointCountBucket;
  final int wallCount;
  final String positionKey;
  final HeatmapState rawState;

  @override
  bool operator ==(Object other) =>
      other is _MiniMapSlice &&
      other.pointCountBucket == pointCountBucket &&
      other.wallCount == wallCount &&
      other.positionKey == positionKey;

  @override
  int get hashCode => Object.hash(pointCountBucket, wallCount, positionKey);
}

// ────────────────────────────────────────────────────────────────────
// 6. Sparse-region directional arrow.
// ────────────────────────────────────────────────────────────────────

class _SparseRegionArrow extends StatelessWidget {
  const _SparseRegionArrow({
    required this.region,
    required this.controller,
    required this.tone,
  });

  final SparseRegion region;
  final AnimationController controller;
  final SurveyTone tone;

  @override
  Widget build(BuildContext context) {
    final color = _SurveyPilotCard._toneColor(tone);
    final (label, rotation) = switch (region) {
      SparseRegion.leftWing => ('HEAD LEFT', -math.pi / 2),
      SparseRegion.rightWing => ('HEAD RIGHT', math.pi / 2),
      SparseRegion.topWing => ('MOVE FORWARD', 0.0),
      SparseRegion.bottomWing => ('STEP BACK', math.pi),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 16),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.rotate(
            angle: rotation,
            child: AnimatedBuilder(
              animation: controller,
              builder:
                  (_, __) => _MarchingChevrons(
                    progress: controller.value,
                    color: color,
                  ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.orbitron(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '— SPARSE COVERAGE',
            style: GoogleFonts.outfit(
              color: color.withValues(alpha: 0.85),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _MarchingChevrons extends StatelessWidget {
  const _MarchingChevrons({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 16,
      child: CustomPaint(
        painter: _ChevronsPainter(progress: progress, color: color),
      ),
    );
  }
}

class _ChevronsPainter extends CustomPainter {
  _ChevronsPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 3; i++) {
      final phase = ((progress + i / 3) % 1.0);
      final opacity = (1 - (phase - 0.5).abs() * 2).clamp(0.0, 1.0);
      paint.color = color.withValues(alpha: opacity);
      final x = phase * size.width - size.width * 0.15;
      final path =
          Path()
            ..moveTo(x, 2)
            ..lineTo(x + 6, size.height / 2)
            ..lineTo(x, size.height - 2);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ChevronsPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

// ────────────────────────────────────────────────────────────────────
// 7. Center reticle — the only interactive hit area outside the dock.
// ────────────────────────────────────────────────────────────────────

class _ReticleHitArea extends StatelessWidget {
  const _ReticleHitArea({
    required this.controller,
    required this.onFlagWeakZone,
  });

  final AnimationController controller;
  final VoidCallback? onFlagWeakZone;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HeatmapBloc, HeatmapState, _ReticleSlice>(
      selector:
          (s) => _ReticleSlice(
            rssi: s.currentRssi,
            lastStepTimestamp: s.lastStepTimestamp,
            surveyGate: s.surveyGate,
          ),
      builder: (context, slice) {
        final tier = signalTierFor(slice.rssi);
        final color = signalTierColor(tier);
        final isWeak =
            slice.surveyGate == SurveyGate.none &&
            (tier == SignalTier.weak || tier == SignalTier.poor);
        final hitSize = isWeak ? 140.0 : 120.0;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: isWeak ? onFlagWeakZone : null,
          child: SizedBox(
            width: hitSize,
            height: hitSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: controller,
                  builder:
                      (_, __) => CustomPaint(
                        size: Size(hitSize, hitSize),
                        painter: _ReticlePainter(
                          progress: controller.value,
                          color: color,
                          stepTs: slice.lastStepTimestamp,
                        ),
                      ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      slice.rssi == null ? '-- dBm' : '${slice.rssi} dBm',
                      style: GoogleFonts.orbitron(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.85),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    if (isWeak) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.18),
                          border: Border.all(
                            color: color.withValues(alpha: 0.8),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'TAP TO FLAG',
                          style: GoogleFonts.orbitron(
                            color: color,
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ReticleSlice {
  const _ReticleSlice({
    required this.rssi,
    required this.lastStepTimestamp,
    required this.surveyGate,
  });

  final int? rssi;
  final DateTime? lastStepTimestamp;
  final SurveyGate surveyGate;

  @override
  bool operator ==(Object other) =>
      other is _ReticleSlice &&
      other.rssi == rssi &&
      other.lastStepTimestamp == lastStepTimestamp &&
      other.surveyGate == surveyGate;

  @override
  int get hashCode => Object.hash(rssi, lastStepTimestamp, surveyGate);
}

class _ReticlePainter extends CustomPainter {
  _ReticlePainter({
    required this.progress,
    required this.color,
    required this.stepTs,
  });

  final double progress;
  final Color color;
  final DateTime? stepTs;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final base = math.min(size.width, size.height) / 2;

    // Outer static ring.
    final ringPaint =
        Paint()
          ..color = color.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4;
    canvas.drawCircle(center, base - 4, ringPaint);

    // Corner brackets.
    final bracketPaint =
        Paint()
          ..color = color.withValues(alpha: 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;
    const bracket = 14.0;
    for (final corner in [
      Offset(-1, -1),
      Offset(1, -1),
      Offset(1, 1),
      Offset(-1, 1),
    ]) {
      final cx = center.dx + corner.dx * (base - 10);
      final cy = center.dy + corner.dy * (base - 10);
      canvas.drawLine(
        Offset(cx, cy),
        Offset(cx - corner.dx * bracket, cy),
        bracketPaint,
      );
      canvas.drawLine(
        Offset(cx, cy),
        Offset(cx, cy - corner.dy * bracket),
        bracketPaint,
      );
    }

    // Pulsing inner ring.
    final pulseRadius = (base - 18) + math.sin(progress * 2 * math.pi) * 3;
    final pulsePaint =
        Paint()
          ..color = color.withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2;
    canvas.drawCircle(center, pulseRadius, pulsePaint);

    // Crosshair.
    final crossPaint =
        Paint()
          ..color = color.withValues(alpha: 0.7)
          ..strokeWidth = 1.4;
    canvas.drawLine(
      Offset(center.dx - 10, center.dy),
      Offset(center.dx + 10, center.dy),
      crossPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - 10),
      Offset(center.dx, center.dy + 10),
      crossPaint,
    );

    // Step pulse — expanding ring on footstep detection.
    if (stepTs != null) {
      final diffMs = DateTime.now().difference(stepTs!).inMilliseconds;
      if (diffMs < 800) {
        final t = diffMs / 800.0;
        final stepPaint =
            Paint()
              ..color = AppColors.neonCyan.withValues(alpha: (1 - t) * 0.45)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2;
        canvas.drawCircle(center, 22 + (t * 80), stepPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ReticlePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.stepTs != stepTs;
}

// ────────────────────────────────────────────────────────────────────
// 8. Sample badge (bottom-left).
// ────────────────────────────────────────────────────────────────────

class _SampleBadge extends StatelessWidget {
  const _SampleBadge();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HeatmapBloc, HeatmapState, int>(
      selector: (s) => s.currentSession?.points.length ?? 0,
      builder: (context, count) {
        return NeonChip(
          icon: Icons.sensors_rounded,
          label: '$count pts',
          color: AppColors.neonCyan,
        );
      },
    );
  }
}

class _MeasurementLockBanner extends StatelessWidget {
  const _MeasurementLockBanner();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HeatmapBloc, HeatmapState, _GateSlice>(
      selector:
          (s) => _GateSlice(
            gate: s.surveyGate,
            targetBssid: s.targetBssid,
            targetSsid: s.targetSsid,
          ),
      builder: (context, slice) {
        if (slice.gate == SurveyGate.none) {
          return const SizedBox.shrink();
        }

        final (title, body, color, icon) = switch (slice.gate) {
          SurveyGate.noConnectedBssid => (
            'MEASUREMENT LOCKED',
            slice.targetBssid == null
                ? 'Connect to a Wi-Fi network to lock the survey target.'
                : 'Reconnect to ${_compactBssid(slice.targetBssid!)} to resume sampling.',
            AppColors.neonRed,
            Icons.link_off_rounded,
          ),
          SurveyGate.staleSignal => (
            'WAITING FOR FRESH SIGNAL',
            'Connected RSSI is older than 3 seconds. Hold position for a new sample.',
            AppColors.neonOrange,
            Icons.hourglass_top_rounded,
          ),
          SurveyGate.originNotPlaced => (
            'PLACE SURVEY ORIGIN',
            'Tap a detected plane to anchor the AR survey before recording points.',
            AppColors.neonCyan,
            Icons.gps_fixed_rounded,
          ),
          SurveyGate.trackingLost => (
            'TRACKING LOST',
            'Motion tracking is unavailable. Move slowly until tracking returns.',
            AppColors.neonOrange,
            Icons.route_rounded,
          ),
          SurveyGate.none => (
            '',
            '',
            AppColors.neonGreen,
            Icons.check_circle_outline_rounded,
          ),
        };

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.orbitron(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      body,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GateSlice {
  const _GateSlice({
    required this.gate,
    required this.targetBssid,
    required this.targetSsid,
  });

  final SurveyGate gate;
  final String? targetBssid;
  final String? targetSsid;

  @override
  bool operator ==(Object other) =>
      other is _GateSlice &&
      other.gate == gate &&
      other.targetBssid == targetBssid &&
      other.targetSsid == targetSsid;

  @override
  int get hashCode => Object.hash(gate, targetBssid, targetSsid);
}

class _ModeBadge extends StatelessWidget {
  const _ModeBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.55)),
      ),
      child: Text(
        label,
        style: GoogleFonts.orbitron(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────
// 9. Bottom-right dock: screen-rec, flag, expand/collapse.
// ────────────────────────────────────────────────────────────────────

class _Dock extends StatelessWidget {
  const _Dock({
    required this.immersive,
    required this.onExpand,
    required this.onCollapse,
    required this.onFlagWeakZone,
  });

  final bool immersive;
  final VoidCallback? onExpand;
  final VoidCallback? onCollapse;
  final VoidCallback? onFlagWeakZone;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!immersive && onExpand != null)
          _DockButton(
            icon: Icons.fullscreen_rounded,
            tooltip: 'Full screen',
            color: AppColors.neonCyan,
            onTap: onExpand!,
          ),
        if (immersive && onCollapse != null)
          _DockButton(
            icon: Icons.fullscreen_exit_rounded,
            tooltip: 'Exit full screen',
            color: AppColors.neonCyan,
            onTap: onCollapse!,
          ),
        const SizedBox(height: 10),
        if (onFlagWeakZone != null)
          _DockButton(
            icon: Icons.flag_rounded,
            tooltip: 'Flag weak zone',
            color: AppColors.neonOrange,
            onTap: onFlagWeakZone!,
          ),
        const SizedBox(height: 10),
        _DockButton(
          icon: Icons.sync_problem_rounded,
          tooltip: 'Recalibrate labels',
          color: AppColors.neonCyan,
          onTap: () {
            HapticFeedback.mediumImpact();
            context.read<HeatmapBloc>().recalibrateHeading();
          },
        ),
      ],
    );
  }
}

class _DockButton extends StatelessWidget {
  const _DockButton({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.62),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.55)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────
// 10. Ready-to-finish celebration banner.
// ────────────────────────────────────────────────────────────────────

class _ReadyBanner extends StatelessWidget {
  const _ReadyBanner({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Opacity(
          opacity: controller.value,
          child: Transform.translate(
            offset: Offset(0, (1 - controller.value) * 20),
            child: child,
          ),
        );
      },
      child: NeonGlowBox(
        glowColor: AppColors.neonGreen,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.read<HeatmapBloc>().stopScanning(),
            borderRadius: BorderRadius.circular(22),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: AppColors.neonGreen.withValues(alpha: 0.6),
                  width: 1.4,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    color: AppColors.neonGreen,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'COVERAGE COMPLETE',
                          style: GoogleFonts.orbitron(
                            color: AppColors.neonGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tap to finish scan',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.neonGreen,
                    size: 18,
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

// ────────────────────────────────────────────────────────────────────
// 11. Live Signal Tag — Floating diagnostic data centered at bottom.
// ────────────────────────────────────────────────────────────────────

class _LiveSignalTag extends StatelessWidget {
  const _LiveSignalTag({required this.estimatedMode});

  final bool estimatedMode;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HeatmapBloc, HeatmapState, _SignalSlice>(
      selector:
          (s) => _SignalSlice(
            rssi: s.currentRssi,
            stdDev: s.lastSignalStdDev,
            sampleCount: s.lastSignalSampleCount,
            ageSeconds:
                s.lastSignalAt == null
                    ? null
                    : DateTime.now().difference(s.lastSignalAt!).inSeconds,
            surveyGate: s.surveyGate,
          ),
      builder: (context, slice) {
        if (slice.rssi == null) return const SizedBox.shrink();

        final tier = signalTierFor(slice.rssi);
        final color = signalTierColor(tier);

        return GlassmorphicContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          borderRadius: BorderRadius.circular(24),
          borderColor: color.withValues(alpha: 0.6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SignalIcon(rssi: slice.rssi!, color: color),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${slice.rssi}',
                        style: GoogleFonts.orbitron(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'dBm',
                        style: GoogleFonts.orbitron(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    signalTierLabel(tier).toUpperCase(),
                    style: GoogleFonts.outfit(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'STD ${slice.stdDev.toStringAsFixed(1)} · ${slice.sampleCount} samp · ${slice.ageSeconds ?? '-'}s',
                    style: GoogleFonts.outfit(
                      color: Colors.white60,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Container(width: 1, height: 30, color: Colors.white24),
              const SizedBox(width: 16),
              _ArStatusIndicator(
                gate: slice.surveyGate,
                estimatedMode: estimatedMode,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SignalSlice {
  const _SignalSlice({
    required this.rssi,
    required this.stdDev,
    required this.sampleCount,
    required this.ageSeconds,
    required this.surveyGate,
  });
  final int? rssi;
  final double stdDev;
  final int sampleCount;
  final int? ageSeconds;
  final SurveyGate surveyGate;

  @override
  bool operator ==(Object other) =>
      other is _SignalSlice &&
      other.rssi == rssi &&
      other.stdDev == stdDev &&
      other.sampleCount == sampleCount &&
      other.ageSeconds == ageSeconds &&
      other.surveyGate == surveyGate;

  @override
  int get hashCode =>
      Object.hash(rssi, stdDev, sampleCount, ageSeconds, surveyGate);
}

class _SignalIcon extends StatelessWidget {
  const _SignalIcon({required this.rssi, required this.color});
  final int rssi;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.radar_rounded,
          color: color.withValues(alpha: 0.3),
          size: 28,
        ),
        Icon(Icons.wifi_tethering_rounded, color: color, size: 18),
      ],
    );
  }
}

class _ArStatusIndicator extends StatelessWidget {
  const _ArStatusIndicator({required this.gate, required this.estimatedMode});

  final SurveyGate gate;
  final bool estimatedMode;

  @override
  Widget build(BuildContext context) {
    final label = switch (gate) {
      SurveyGate.none => estimatedMode ? 'EST' : 'LOCKED',
      SurveyGate.noConnectedBssid => 'NO AP',
      SurveyGate.staleSignal => 'STALE',
      SurveyGate.originNotPlaced => 'ORIGIN',
      SurveyGate.trackingLost => 'TRACK',
    };
    final icon =
        estimatedMode ? Icons.layers_clear_rounded : Icons.view_in_ar_rounded;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white70, size: 14),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.orbitron(
            color: Colors.white70,
            fontSize: 8,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
