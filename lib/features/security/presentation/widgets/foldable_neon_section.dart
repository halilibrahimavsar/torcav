import 'package:flutter/material.dart';
import 'package:torcav/core/theme/neon_widgets.dart';

/// A premium, cyber-themed foldable section wrapper for Security Center.
class FoldableNeonSection extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Widget child;
  final bool initialExpanded;

  const FoldableNeonSection({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.child,
    this.initialExpanded = false,
  });

  @override
  State<FoldableNeonSection> createState() => _FoldableNeonSectionState();
}

class _FoldableNeonSectionState extends State<FoldableNeonSection>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _controller;
  late Animation<double> _iconRotation;
  late Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initialExpanded;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _iconRotation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );
    _heightFactor = _controller.drive(CurveTween(curve: Curves.easeInOutExpo));

    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        // ── Section Header (Interactive) ──
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _toggleExpanded,
            borderRadius: BorderRadius.circular(8),
            splashColor: widget.color.withValues(alpha: 0.1),
            highlightColor: widget.color.withValues(alpha: 0.05),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: NeonSectionHeader(
                      label: widget.label.toUpperCase(),
                      icon: widget.icon,
                      color: widget.color,
                    ),
                  ),
                  RotationTransition(
                    turns: _iconRotation,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: widget.color.withValues(alpha: 0.7),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // ── Animated Content ──
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: _heightFactor.value,
                child: Opacity(
                  opacity: _heightFactor.value.clamp(0.0, 1.0),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: child,
                  ),
                ),
              ),
            );
          },
          child: widget.child,
        ),
      ],
    );
  }
}
