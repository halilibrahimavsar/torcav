import 'package:flutter/material.dart';
import 'package:torcav/core/di/injection.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../../../settings/domain/services/app_settings_store.dart';
import 'classic_grid_background.dart';
import 'neomorphic_background.dart';

class CyberGridBackground extends StatefulWidget {
  final Color color;
  final Widget? child;

  const CyberGridBackground({super.key, required this.color, this.child});

  /// Static method to update scroll velocity globally
  static void updateScrollVelocity(double velocity) {
    _CyberGridBackgroundState.scrollVelocity.value = velocity.abs();
  }

  @override
  State<CyberGridBackground> createState() => _CyberGridBackgroundState();
}

class _CyberGridBackgroundState extends State<CyberGridBackground> {
  static final ValueNotifier<double> scrollVelocity = ValueNotifier<double>(0.0);
  late final AppSettingsStore _settingsStore;

  @override
  void initState() {
    super.initState();
    _settingsStore = getIt<AppSettingsStore>();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppSettings>(
      stream: _settingsStore.changes,
      initialData: _settingsStore.value,
      builder: (context, snapshot) {
        final settings = snapshot.data ?? const AppSettings();
        
        // Removed Light Mode restriction as requested by user.
        // Backgrounds are now adapted for both theme modes.

        if (settings.backgroundType == AppBackgroundType.classic) {
          return ClassicGridBackground(
            color: widget.color,
            scrollVelocity: scrollVelocity,
            child: widget.child,
          );
        }

        return NeomorphicBackground(
          scrollVelocity: scrollVelocity,
          child: widget.child,
        );
      },
    );
  }
}

