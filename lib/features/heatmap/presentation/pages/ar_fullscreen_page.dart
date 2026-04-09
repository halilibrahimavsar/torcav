import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../bloc/heatmap_bloc.dart';
import '../widgets/ar_camera_view.dart';
import '../widgets/arcore_heatmap_view.dart';

/// Immersive full-screen AR heatmap route.
///
/// Hides the system nav + status bars while alive and locks to portrait.
/// Expects the caller to provide the active [HeatmapBloc] via
/// `BlocProvider.value` so the same scan session continues uninterrupted.
class ArFullScreenPage extends StatefulWidget {
  const ArFullScreenPage({super.key});

  @override
  State<ArFullScreenPage> createState() => _ArFullScreenPageState();
}

class _ArFullScreenPageState extends State<ArFullScreenPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    _restoreSystemUi();
    super.dispose();
  }

  void _restoreSystemUi() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _restoreSystemUi();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            BlocBuilder<HeatmapBloc, HeatmapState>(
              buildWhen: (p, c) => p.isArSupported != c.isArSupported,
              builder: (context, state) {
                if (state.isArSupported) {
                  return ArCoreHeatmapView(
                    immersive: true,
                    onCollapse: () => Navigator.of(context).pop(),
                  );
                }
                return ArCameraView(
                  immersive: true,
                  onCollapse: () => Navigator.of(context).pop(),
                );
              },
            ),
            // Defensive fallback back arrow — in case the dock is ever hidden.
            Positioned(
              top: 0,
              left: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Material(
                    color: Colors.transparent,
                    child: IconButton(
                      tooltip: 'Exit full screen',
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.neonCyan,
                        size: 20,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
