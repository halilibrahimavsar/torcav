
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:torcav/core/theme/neon_widgets.dart';
import 'package:torcav/core/l10n/app_localizations.dart';
import 'package:torcav/features/security/domain/entities/security_event.dart' as domain_event;
import '../bloc/security_bloc.dart';
import 'security_status_radar.dart';

class SecurityCenterBentoHeader extends StatelessWidget {
  final SecurityState state;

  const SecurityCenterBentoHeader({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    final loaded = state is SecurityLoaded ? state as SecurityLoaded : null;
    final score = loaded?.overallScore ?? 100;
    final hasCritical =
        loaded?.recentEvents.any(
          (e) => e.severity == domain_event.SecurityEventSeverity.critical,
        ) ??
        false;
    final hasHigh =
        loaded?.recentEvents.any(
          (e) => e.severity == domain_event.SecurityEventSeverity.high,
        ) ??
        false;

    final isSecure = score >= 85 && !hasCritical;
    final activeColor =
        hasCritical
            ? scheme.error
            : (hasHigh
                ? const Color(0xFFFFB300)
                : (score >= 85 ? scheme.primary : scheme.outline));

    final statusLabel =
        state is SecurityLoading
            ? l10n.scanning
            : (isSecure ? l10n.shieldActive : l10n.threatsDetected);

    return StaggeredEntry(
      delay: const Duration(milliseconds: 50),
      child: SizedBox(
        height: 340,
        child: NeonCard(
          glowColor: activeColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Stack(
            children: [
              // ── Animated Background Layer ──
              Positioned.fill(
                child: _NeonHeaderBackground(color: activeColor),
              ),
              
              // ── Foreground Content ──
              Column(
                children: [
            // ── Top Header Row (Premium Subtle) ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Opacity(
                    opacity: 0.7,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state is SecurityLoading ? 'SCANNING' : 'SYSTEM STATUS',
                          style: GoogleFonts.firaCode(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: activeColor,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          statusLabel.toUpperCase(),
                          style: GoogleFonts.orbitron(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: activeColor,
                            letterSpacing: 2.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                Opacity(
                  opacity: 0.8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'SECURITY SCORE',
                        style: GoogleFonts.rajdhani(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: activeColor.withValues(alpha: 0.6),
                          letterSpacing: 2,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          AnimatedSecurityScore(
                            score: score,
                            color: activeColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '/100',
                            style: GoogleFonts.orbitron(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: activeColor.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // ── Maximized & Perfectly Centered Animation ──
            Expanded(
              child: Center(
                child: SecurityStatusRadar(
                  score: score.toDouble(),
                  isScanning: state is SecurityLoading,
                  color: activeColor,
                  size: 240, // Maximized for visual impact
                ),
              ),
            ),

            // ── Integrated Footer Metrics Row ──
            Container(
              padding: const EdgeInsets.only(top: 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: activeColor.withValues(alpha: 0.05),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _BottomStat(
                    label: 'SHIELD INTEGRITY',
                    value: hasCritical ? 'CRITICAL' : (hasHigh ? 'WARNING' : 'OPTIMAL'),
                    color: hasCritical ? scheme.error : (hasHigh ? const Color(0xFFFFB300) : scheme.tertiary),
                    opacity: 0.7,
                  ),
                  _BottomStat(
                    label: 'ACTIVE THREATS',
                    value: '${loaded?.recentEvents.length ?? 0}',
                    color: hasCritical ? scheme.error : scheme.primary,
                    opacity: 0.7,
                  ),
                ],
              ),
            ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── NEW Component: Animated Header Background ──

class _NeonHeaderBackground extends StatefulWidget {
  final Color color;
  const _NeonHeaderBackground({required this.color});

  @override
  State<_NeonHeaderBackground> createState() => _NeonHeaderBackgroundState();
}

class _NeonHeaderBackgroundState extends State<_NeonHeaderBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(seconds: 4))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _HeaderGlowPainter(
            color: widget.color,
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

class _HeaderGlowPainter extends CustomPainter {
  final Color color;
  final double progress;

  _HeaderGlowPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.45);
    final maxRadius = size.width * 0.55;

    canvas.save();
    
    // Rotate the entire canvas based on animation progress
    canvas.translate(center.dx, center.dy);
    canvas.rotate(progress * 2 * 3.14159);
    canvas.translate(-center.dx, -center.dy);

    // ── Orbital Glow Sweep ──
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        colors: [
          color.withValues(alpha: 0.0),
          color.withValues(alpha: 0.2),
          color.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius));

    canvas.drawCircle(center, maxRadius, sweepPaint);

    // ── Concentric Fading Rings (Subtle) ──
    for (int i = 1; i <= 3; i++) {
      final ringRadius = maxRadius * (i / 3);
      final ringPaint = Paint()
        ..color = color.withValues(alpha: 0.05 / i)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawCircle(center, ringRadius, ringPaint);
    }

    canvas.restore();

    // ── Subtle Horizon Glow ──
    final horizonPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.0),
          color.withValues(alpha: 0.03),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), horizonPaint);
  }

  @override
  bool shouldRepaint(_HeaderGlowPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

class _BottomStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final double opacity;

  const _BottomStat({
    required this.label,
    required this.value,
    required this.color,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.rajdhani(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: color.withValues(alpha: 0.6),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value.toUpperCase(),
            style: GoogleFonts.orbitron(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}


class ShimmerOverlayPainter extends CustomPainter {
  final Color color;
  ShimmerOverlayPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withValues(alpha: 0),
          color.withValues(alpha: 0.2),
          color.withValues(alpha: 0),
        ],
        stops: const [0.3, 0.5, 0.7],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class AnimatedSecurityScore extends StatefulWidget {
  final int score;
  final Color color;

  const AnimatedSecurityScore({
    super.key,
    required this.score,
    required this.color,
  });

  @override
  State<AnimatedSecurityScore> createState() => _AnimatedSecurityScoreState();
}

class _AnimatedSecurityScoreState extends State<AnimatedSecurityScore>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = IntTween(begin: 0, end: widget.score).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedSecurityScore oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _animation = IntTween(begin: oldWidget.score, end: widget.score).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return NeonText(
          '${_animation.value}',
          style: GoogleFonts.orbitron(
            fontSize: 42,
            fontWeight: FontWeight.w900,
            color: widget.color,
          ),
          glowColor: widget.color,
          glowRadius: 12,
        );
      },
    );
  }
}

