import 'package:flutter/material.dart';

/// Scrim gradient for top and bottom HUD readability.
class HudScrim extends StatelessWidget {
  const HudScrim({super.key});

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
