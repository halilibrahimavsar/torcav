import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme.dart';

// ── Glassmorphic Container ──────────────────────────────────────────

/// A frosted-glass container with optional neon border glow.
class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final Color? borderColor;
  final double borderWidth;
  final double blurSigma;
  final Color? backgroundColor;

  const GlassmorphicContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.borderColor,
    this.borderWidth = 1,
    this.blurSigma = 12,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorder = borderColor ?? AppColors.neonCyan;
    final effectiveBg = backgroundColor ?? AppColors.darkSurfaceLight.withValues(alpha: 0.1);

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: effectiveBg,
            borderRadius: borderRadius,
            border: Border.all(
              color: effectiveBorder.withValues(alpha: 0.2),
              width: borderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: effectiveBorder.withValues(alpha: 0.05),
                blurRadius: 20,
                spreadRadius: 1,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

// ── Neon Card ────────────────────────────────────────────────────────

/// A card with a subtle neon border glow and dark glassmorphic surface.
class NeonCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color glowColor;
  final double glowIntensity;
  final double borderRadius;
  final VoidCallback? onTap;

  const NeonCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.glowColor = const Color(0xFF00F5FF),
    this.glowIntensity = 0.15,
    this.borderRadius = 16,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceLight,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: glowColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: AppColors.glowTiers[GlowTier.low]!(glowColor),
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: glowColor.withValues(alpha: 0.1),
          highlightColor: glowColor.withValues(alpha: 0.05),
          child: card,
        ),
      );
    }

    return card;
  }
}

// ── Neon Glow Box ────────────────────────────────────────────────────

/// Wraps any child with a subtle pulsating neon glow.
class NeonGlowBox extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double minOpacity;
  final double maxOpacity;
  final Duration duration;

  const NeonGlowBox({
    super.key,
    required this.child,
    this.glowColor = const Color(0xFF00F5FF),
    this.minOpacity = 0.06,
    this.maxOpacity = 0.2,
    this.duration = const Duration(milliseconds: 2000),
  });

  @override
  State<NeonGlowBox> createState() => _NeonGlowBoxState();
}

class _NeonGlowBoxState extends State<NeonGlowBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(
      begin: widget.minOpacity,
      end: widget.maxOpacity,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Static glow when reduced motion is preferred
    if (MediaQuery.of(context).disableAnimations) {
      return Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: widget.glowColor.withValues(alpha: widget.minOpacity),
              blurRadius: 30,
              spreadRadius: 4,
            ),
          ],
        ),
        child: widget.child,
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withValues(alpha: _animation.value),
                blurRadius: 30,
                spreadRadius: 4,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// ── Neon Text ────────────────────────────────────────────────────────

/// Text with a subtle neon glow shadow behind it.
class NeonText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color? glowColor;
  final double glowRadius;

  const NeonText(
    this.text, {
    super.key,
    this.style,
    this.glowColor,
    this.glowRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveStyle =
        style ?? GoogleFonts.orbitron(color: AppColors.neonCyan, fontSize: 18);
    final effectiveGlow = glowColor ?? effectiveStyle.color ?? AppColors.neonCyan;

    return Text(
      text,
      style: effectiveStyle.copyWith(
        shadows: [
          Shadow(
            color: effectiveGlow.withValues(alpha: 0.8),
            blurRadius: 2,
          ),
          Shadow(
            color: effectiveGlow.withValues(alpha: 0.4),
            blurRadius: 10,
          ),
          Shadow(
            color: effectiveGlow.withValues(alpha: 0.2),
            blurRadius: 24,
          ),
        ],
      ),
    );
  }
}

// ── Pulsing Dot ──────────────────────────────────────────────────────

/// A small dot that gently pulses; used to indicate live status.
class PulsingDot extends StatefulWidget {
  final Color color;
  final double size;

  const PulsingDot({
    super.key,
    this.color = const Color(0xFF39FF14),
    this.size = 10,
  });

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Static dot when reduced motion is preferred
    if (MediaQuery.of(context).disableAnimations) {
      return Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final opacity = 0.4 + (_controller.value * 0.6);
        final glowRadius = 4.0 + (_controller.value * 8.0);
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: opacity),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: opacity * 0.5),
                blurRadius: glowRadius,
                spreadRadius: 1,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Neon Icon Button ─────────────────────────────────────────────────

/// An icon with neon glow that intensifies on tap.
class NeonIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback? onTap;
  final String? tooltip;

  const NeonIconButton({
    super.key,
    required this.icon,
    this.color = const Color(0xFF00F5FF),
    this.size = 24,
    this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: color, size: size),
      splashColor: color.withValues(alpha: 0.2),
      highlightColor: color.withValues(alpha: 0.1),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}

// ── Neon Divider ─────────────────────────────────────────────────────

/// A horizontal divider with neon gradient glow.
class NeonDivider extends StatelessWidget {
  final Color color;
  final double height;

  const NeonDivider({
    super.key,
    this.color = const Color(0xFF00F5FF),
    this.height = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            color.withValues(alpha: 0.5),
            color.withValues(alpha: 0.8),
            color.withValues(alpha: 0.5),
            Colors.transparent,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
    );
  }
}

// ── Neon Chip ────────────────────────────────────────────────────────

/// A small pill-shaped label with neon border.
class NeonChip extends StatelessWidget {
  final String label;
  final Color color;
  final TextStyle? textStyle;

  const NeonChip({
    super.key,
    required this.label,
    this.color = const Color(0xFF00F5FF),
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 8,
          ),
        ],
      ),
      child: Text(
        label,
        style: textStyle ??
            GoogleFonts.outfit(
              color: color.withValues(alpha: 0.9),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

// ── Animated Stagger Entry ───────────────────────────────────────────

/// Wraps a child with a fade + slide-up entry animation that triggers once.
class StaggeredEntry extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final double slideOffset;

  const StaggeredEntry({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 500),
    this.slideOffset = 30,
  });

  @override
  State<StaggeredEntry> createState() => _StaggeredEntryState();
}

class _StaggeredEntryState extends State<StaggeredEntry>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: Offset(0, widget.slideOffset),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Skip animation when reduced motion is preferred
    if (MediaQuery.of(context).disableAnimations) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fade.value,
          child: Transform.translate(
            offset: _slide.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

// ── Neon Section Header ──────────────────────────────────────────────

/// Section header used across pages with neon styling.
class NeonSectionHeader extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;

  const NeonSectionHeader({
    super.key,
    required this.label,
    this.icon,
    this.color = const Color(0xFF00F5FF),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
        ],
        Text(
          label.toUpperCase(),
          style: GoogleFonts.orbitron(
            color: color.withValues(alpha: 0.7),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: NeonDivider(color: color)),
      ],
    );
  }
}
// ── Bento Stat Tile ──────────────────────────────────────────────────

/// A small square tile for the Bento grid displaying a label, value, and icon with neon styling.
class BentoStatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? subValue;

  const BentoStatTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color = AppColors.neonCyan,
    this.subValue,
  });

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      glowColor: color,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color.withValues(alpha: 0.7), size: 18),
              if (subValue != null)
                Text(
                  subValue!,
                  style: GoogleFonts.rajdhani(
                    color: color.withValues(alpha: 0.5),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.orbitron(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.rajdhani(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
// ── Neon Button ──────────────────────────────────────────────────────

/// A premium neon-styled button with optional icon and glow.
class NeonButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData? icon;
  final Color color;
  final double height;

  const NeonButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.color = AppColors.neonCyan,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        splashColor: color.withValues(alpha: 0.2),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.15),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 10),
              ],
              Text(
                label.toUpperCase(),
                style: GoogleFonts.orbitron(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HolographicCard extends StatelessWidget {
  final Widget child;
  final Color? color;

  const HolographicCard({
    super.key,
    required this.child,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? AppColors.neonCyan;
    
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xE60A0E14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: themeColor.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: ScanlinePainter(
                color: themeColor.withValues(alpha: 0.05),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class ScanlinePainter extends CustomPainter {
  final Color color;
  const ScanlinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Neon Confirm Dialog ──────────────────────────────────────────────

/// A premium cyber-themed confirmation dialog.
class NeonConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;
  final Color confirmColor;

  const NeonConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.onConfirm,
    this.confirmColor = Colors.redAccent,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.darkSurface.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.neonCyan.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 50,
              ),
              BoxShadow(
                color: AppColors.neonCyan.withValues(alpha: 0.05),
                blurRadius: 20,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: confirmColor.withValues(alpha: 0.8),
                  size: 48,
                ),
                const SizedBox(height: 16),
                NeonText(
                  title.toUpperCase(),
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: AppColors.textMuted,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: NeonButton(
                        onPressed: () => Navigator.of(context).pop(),
                        label: cancelLabel,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: NeonButton(
                        onPressed: onConfirm,
                        label: confirmLabel,
                        color: confirmColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
