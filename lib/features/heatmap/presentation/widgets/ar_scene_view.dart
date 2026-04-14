import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Embeds the native ARCore SceneView (`torcav/ar_scene_view`). The native
/// side streams vertical-plane polygons through the `torcav/ar_scene/events`
/// EventChannel — see [ArPlaneScannerDataSource].
class ArSceneView extends StatelessWidget {
  const ArSceneView({super.key});

  static const _viewType = 'torcav/ar_scene_view';

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return const SizedBox.shrink();
    }
    return const AndroidView(
      viewType: _viewType,
      creationParams: <String, dynamic>{},
      creationParamsCodec: StandardMessageCodec(),
    );
  }
}
