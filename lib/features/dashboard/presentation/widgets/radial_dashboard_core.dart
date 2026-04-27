import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import 'security_core.dart';

/// Hero widget for the dashboard: the existing animated SecurityCore in the
/// center, surrounded by four orbital arc-gauges representing security score,
/// signal quality, threat count, and device count. Each gauge animates its
/// fill on data change and runs a continuous tracker dot.
class RadialDashboardCore extends StatefulWidget {
  final Color statusColor;
  final String label;
  final String subLabel;
  final bool isLoading;

  /// 0..100
  final int securityScore;

  /// 0..100 (RSSI mapped to percent; null if unknown)
  final int? signalQualityPct;

  /// Active threat / unread security event count
  final int threatCount;

  /// Discovered device / network count from latest snapshot
  final int deviceCount;

  final VoidCallback? onTapSecurity;
  final VoidCallback? onTapSignal;
  final VoidCallback? onTapThreats;
  final VoidCallback? onTapDevices;

  const RadialDashboardCore({
    super.key,
    required this.statusColor,
    required this.label,
    required this.subLabel,
    this.isLoading = false,
    required this.securityScore,
    required this.signalQualityPct,
    required this.threatCount,
    required this.deviceCount,
    this.onTapSecurity,
    this.onTapSignal,
    this.onTapThreats,
    this.onTapDevices,
  });

  @override
  State<RadialDashboardCore> createState() => _RadialDashboardCoreState();
}

class _RadialDashboardCoreState extends State<RadialDashboardCore>
    with TickerProviderStateMixin {
  late final AnimationController _orbit;

  @override
  void initState() {
    super.initState();
    _orbit = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _orbit.dispose();
    super.dispose();
  }

  Color _scoreColor(int score, ColorScheme scheme) {
    if (score >= 85) return scheme.primary;
    if (score >= 60) return const Color(0xFFFFB300);
    return scheme.error;
  }

  Color _signalColor(int? pct) {
    if (pct == null) return AppColors.textMuted;
    if (pct >= 70) return AppColors.neonCyan;
    if (pct >= 40) return const Color(0xFFFFB300);
    return AppColors.neonRed;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final size = 320.0;

    final secColor = _scoreColor(widget.securityScore, scheme);
    final sigColor = _signalColor(widget.signalQualityPct);
    final threatColor = widget.threatCount > 0
        ? scheme.error
        : scheme.primary.withValues(alpha: 0.6);
    final deviceColor = AppColors.neonPurple;

    final gauges = <_GaugeSpec>[
      _GaugeSpec(
        anglePos: -math.pi / 2, // top
        valuePct: widget.securityScore / 100,
        color: secColor,
        icon: Icons.shield_rounded,
        label: '${widget.securityScore}',
        unit: '%',
        onTap: widget.onTapSecurity,
      ),
      _GaugeSpec(
        anglePos: 0, // right
        valuePct: (widget.signalQualityPct ?? 0) / 100,
        color: sigColor,
        icon: Icons.wifi_rounded,
        label: widget.signalQualityPct != null
            ? '${widget.signalQualityPct}'
            : '—',
        unit: '%',
        onTap: widget.onTapSignal,
      ),
      _GaugeSpec(
        anglePos: math.pi / 2, // bottom
        valuePct: (widget.threatCount.clamp(0, 10) / 10).toDouble(),
        color: threatColor,
        icon: Icons.warning_amber_rounded,
        label: '${widget.threatCount}',
        unit: '',
        onTap: widget.onTapThreats,
      ),
      _GaugeSpec(
        anglePos: math.pi, // left
        valuePct: (widget.deviceCount.clamp(0, 25) / 25).toDouble(),
        color: deviceColor,
        icon: Icons.devices_other_rounded,
        label: '${widget.deviceCount}',
        unit: '',
        onTap: widget.onTapDevices,
      ),
    ];

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer orbital arcs painter
          AnimatedBuilder(
            animation: _orbit,
            builder: (context, _) {
              return CustomPaint(
                size: Size(size, size),
                painter: _OrbitPainter(
                  gauges: gauges,
                  orbit: _orbit.value,
                  trackColor: scheme.onSurface.withValues(alpha: 0.05),
                ),
              );
            },
          ),

          // Central core (existing animated widget)
          SecurityCore(
            statusColor: widget.statusColor,
            label: widget.label,
            subLabel: widget.subLabel,
            isLoading: widget.isLoading,
          ),

          // Tappable badges at each gauge position
          for (final g in gauges) _GaugeBadge(spec: g, parentSize: size),
        ],
      ),
    );
  }
}

class _GaugeSpec {
  final double anglePos;
  final double valuePct; // 0..1
  final Color color;
  final IconData icon;
  final String label;
  final String unit;
  final VoidCallback? onTap;

  _GaugeSpec({
    required this.anglePos,
    required this.valuePct,
    required this.color,
    required this.icon,
    required this.label,
    required this.unit,
    required this.onTap,
  });
}

class _GaugeBadge extends StatelessWidget {
  final _GaugeSpec spec;
  final double parentSize;

  const _GaugeBadge({required this.spec, required this.parentSize});

  @override
  Widget build(BuildContext context) {
    final radius = parentSize / 2 - 18;
    final dx = math.cos(spec.anglePos) * radius;
    final dy = math.sin(spec.anglePos) * radius;

    return Transform.translate(
      offset: Offset(dx, dy),
      child: GestureDetector(
        onTap: spec.onTap,
        behavior: HitTestBehavior.opaque,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.7, end: 1.0),
          duration: const Duration(milliseconds: 700),
          curve: Curves.elasticOut,
          builder: (context, scale, child) =>
              Transform.scale(scale: scale, child: child),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: spec.color.withValues(alpha: 0.12),
              border: Border.all(
                color: spec.color.withValues(alpha: 0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: spec.color.withValues(alpha: 0.25),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(spec.icon, size: 12, color: spec.color),
                const SizedBox(height: 1),
                Text(
                  spec.label,
                  style: GoogleFonts.orbitron(
                    color: spec.color,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  final List<_GaugeSpec> gauges;
  final double orbit; // 0..1
  final Color trackColor;

  _OrbitPainter({
    required this.gauges,
    required this.orbit,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 18;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background full track
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = trackColor;
    canvas.drawCircle(center, radius, track);

    // Each gauge: arc that sweeps centered on its anchor angle
    const halfArc = math.pi / 4 - 0.05; // ~44° each side, gap between arcs
    for (final g in gauges) {
      final start = g.anglePos - halfArc;
      final fullSweep = halfArc * 2;
      final filled = fullSweep * g.valuePct.clamp(0.0, 1.0);

      // Faint background arc segment
      final bg = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = g.color.withValues(alpha: 0.12);
      canvas.drawArc(rect, start, fullSweep, false, bg);

      // Filled value arc (animated via TweenAnimationBuilder externally would
      // be nicer, but keeping it deterministic for paint perf)
      final fg = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: start,
          endAngle: start + fullSweep,
          colors: [
            g.color.withValues(alpha: 0.4),
            g.color,
          ],
          tileMode: TileMode.clamp,
          transform: GradientRotation(start),
        ).createShader(rect);
      canvas.drawArc(rect, start, filled, false, fg);

      // Tracker dot orbiting along the arc (within its sweep)
      final tProgress =
          (orbit * 2 * math.pi) % (2 * math.pi); // 0..2π continuous
      // Map tProgress to a back-and-forth within fullSweep so tracker bounces.
      final phase = (tProgress + g.anglePos) % (2 * math.pi);
      final tNormalized = (math.sin(phase) + 1) / 2; // 0..1
      final dotAngle = start + fullSweep * tNormalized;
      final dotPos = Offset(
        center.dx + math.cos(dotAngle) * radius,
        center.dy + math.sin(dotAngle) * radius,
      );
      canvas.drawCircle(
        dotPos,
        2.5,
        Paint()
          ..style = PaintingStyle.fill
          ..color = g.color,
      );
      canvas.drawCircle(
        dotPos,
        5,
        Paint()
          ..style = PaintingStyle.fill
          ..color = g.color.withValues(alpha: 0.25),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter old) =>
      old.orbit != orbit || old.gauges != gauges;
}
