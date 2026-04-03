import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme.dart';

// ── Info Icon Button ─────────────────────────────────────────────────
//
// A small ℹ️ icon that opens a bottom sheet explaining a technical term
// in plain language. Use it next to any technical label so beginners
// can understand what it means without cluttering the main UI.

class InfoIconButton extends StatelessWidget {
  final String title;
  final String body;
  final Color? color;

  const InfoIconButton({
    super.key,
    required this.title,
    required this.body,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: () => _showInfoSheet(context, effectiveColor),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Icon(
          Icons.info_outline_rounded,
          size: 16,
          color: effectiveColor.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  void _showInfoSheet(BuildContext context, Color color) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _InfoSheet(title: title, body: body, color: color),
    );
  }
}

class _InfoSheet extends StatelessWidget {
  final String title;
  final String body;
  final Color color;

  const _InfoSheet({
    required this.title,
    required this.body,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      borderColor: color,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.info_outline_rounded, color: color, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.orbitron(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            body,
            style: GoogleFonts.rajdhani(
              fontSize: 15,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ── Neon Error Card ──────────────────────────────────────────────────
//
// A styled error state widget with a red neon glow, error icon, message
// text, and an optional retry button. Use this to replace plain Text
// error widgets across the app for consistent, user-friendly error UX.

class NeonErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const NeonErrorCard({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final errorColor = Theme.of(context).colorScheme.error;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: NeonCard(
          glowColor: errorColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, color: errorColor, size: 48),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.rajdhani(
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
                  height: 1.4,
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: Icon(Icons.refresh_rounded, color: errorColor, size: 18),
                  label: Text(
                    'RETRY',
                    style: GoogleFonts.orbitron(
                      fontSize: 12,
                      color: errorColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: errorColor.withValues(alpha: 0.6)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBorder = borderColor ?? Theme.of(context).colorScheme.primary;
    final effectiveBg = backgroundColor ??
        (isDark
            ? Theme.of(context).colorScheme.surfaceContainerLow.withValues(alpha: 0.1)
            : Theme.of(context).colorScheme.surfaceContainerHigh.withValues(alpha: 0.2));

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
  final Color? glowColor;
  final double glowIntensity;
  final double borderRadius;
  final VoidCallback? onTap;

  const NeonCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.glowColor,
    this.glowIntensity = 0.15,
    this.borderRadius = 16,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGlowColor = glowColor ?? Theme.of(context).colorScheme.primary;
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: effectiveGlowColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: AppColors.glowTiers[GlowTier.low]!(effectiveGlowColor),
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: effectiveGlowColor.withValues(alpha: 0.1),
          highlightColor: effectiveGlowColor.withValues(alpha: 0.05),
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
  final Color? glowColor;
  final double minOpacity;
  final double maxOpacity;
  final Duration duration;

  const NeonGlowBox({
    super.key,
    required this.child,
    this.glowColor,
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
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveGlowColor =
        widget.glowColor ?? Theme.of(context).colorScheme.primary;

    // Static glow when reduced motion is preferred
    if (MediaQuery.of(context).disableAnimations) {
      return Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: effectiveGlowColor.withValues(alpha: widget.minOpacity),
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
                color: effectiveGlowColor.withValues(alpha: _animation.value),
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
  final TextOverflow? overflow;
  final int? maxLines;

  const NeonText(
    this.text, {
    super.key,
    this.style,
    this.glowColor,
    this.glowRadius = 12,
    this.overflow,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveStyle = style ??
        GoogleFonts.orbitron(
          color: isDark ? scheme.primary : scheme.onSurface,
          fontSize: 18,
        );
    final effectiveGlow = glowColor ?? (isDark ? scheme.primary : scheme.primary.withValues(alpha: 0.5));

    return Text(
      text,
      overflow: overflow,
      maxLines: maxLines,
      style: effectiveStyle.copyWith(
        shadows: [
          Shadow(color: effectiveGlow.withValues(alpha: 0.8), blurRadius: 2),
          Shadow(color: effectiveGlow.withValues(alpha: 0.4), blurRadius: 10),
          Shadow(color: effectiveGlow.withValues(alpha: 0.2), blurRadius: 24),
        ],
      ),
    );
  }
}

// ── Pulsing Dot ──────────────────────────────────────────────────────

/// A small dot that gently pulses; used to indicate live status.
class PulsingDot extends StatefulWidget {
  final Color? color;
  final double size;

  const PulsingDot({
    super.key,
    this.color,
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
    final effectiveColor = widget.color ?? Theme.of(context).colorScheme.tertiary;

    // Static dot when reduced motion is preferred
    if (MediaQuery.of(context).disableAnimations) {
      return Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: effectiveColor,
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
            color: effectiveColor.withValues(alpha: opacity),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: effectiveColor.withValues(alpha: opacity * 0.5),
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
  final Color? color;
  final double size;
  final VoidCallback? onTap;
  final String? tooltip;

  const NeonIconButton({
    super.key,
    required this.icon,
    this.color,
    this.size = 24,
    this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;
    final button = IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: effectiveColor, size: size),
      splashColor: effectiveColor.withValues(alpha: 0.2),
      highlightColor: effectiveColor.withValues(alpha: 0.1),
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
  final Color? color;
  final double height;

  const NeonDivider({
    super.key,
    this.color,
    this.height = 1,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            effectiveColor.withValues(alpha: 0.5),
            effectiveColor.withValues(alpha: 0.8),
            effectiveColor.withValues(alpha: 0.5),
            Colors.transparent,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: effectiveColor.withValues(alpha: 0.3),
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
  final Color? color;
  final TextStyle? textStyle;

  const NeonChip({
    super.key,
    required this.label,
    this.color,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: effectiveColor.withValues(alpha: 0.1),
        border: Border.all(color: effectiveColor.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: effectiveColor.withValues(alpha: 0.08),
            blurRadius: 8,
          ),
        ],
      ),
      child: Text(
        label,
        style:
            textStyle ??
            GoogleFonts.outfit(
              color: effectiveColor.withValues(alpha: 0.9),
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
    _controller = AnimationController(vsync: this, duration: widget.duration);
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
          child: Transform.translate(offset: _slide.value, child: child),
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
  final Color? color;

  const NeonSectionHeader({
    super.key,
    required this.label,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: effectiveColor, size: 16),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label.toUpperCase(),
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.orbitron(
              color: effectiveColor.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: NeonDivider(color: effectiveColor)),
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
  final Color? color;
  final String? subValue;

  const BentoStatTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color,
    this.subValue,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;
    return NeonCard(
      glowColor: effectiveColor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: effectiveColor.withValues(alpha: 0.7), size: 18),
              if (subValue != null)
                Flexible(
                  child: Text(
                    subValue!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.rajdhani(
                      color: effectiveColor.withValues(alpha: 0.5),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: GoogleFonts.orbitron(
                color: effectiveColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.rajdhani(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
  final Color? color;
  final double height;

  const NeonButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.color,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        splashColor: effectiveColor.withValues(alpha: 0.2),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.transparent
                : Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? effectiveColor.withValues(alpha: 0.5) : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: effectiveColor.withValues(alpha: 0.15),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: isDark ? effectiveColor : Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 20,
                ),
                const SizedBox(width: 10),
              ],
              Text(
                label.toUpperCase(),
                style: GoogleFonts.orbitron(
                  color: isDark ? effectiveColor : Theme.of(context).colorScheme.onPrimaryContainer,
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

  const HolographicCard({super.key, required this.child, this.color});

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: effectiveColor.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: effectiveColor.withValues(alpha: 0.1),
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
                color: effectiveColor.withValues(alpha: 0.05),
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
    final paint =
        Paint()
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
  final Color? confirmColor;

  const NeonConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.onConfirm,
    this.confirmColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final effectiveConfirmColor = confirmColor ?? scheme.error;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: scheme.primary.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.2),
                blurRadius: 50,
              ),
              BoxShadow(
                color: scheme.primary.withValues(alpha: 0.05),
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
                  color: effectiveConfirmColor.withValues(alpha: 0.8),
                  size: 48,
                ),
                const SizedBox(height: 16),
                NeonText(
                  title.toUpperCase(),
                  style: GoogleFonts.orbitron(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: NeonButton(
                        onPressed: onConfirm,
                        label: confirmLabel,
                        color: effectiveConfirmColor,
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
