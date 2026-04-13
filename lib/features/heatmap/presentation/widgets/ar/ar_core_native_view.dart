import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';

/// A stable hosting widget for ArCoreView that doesn't rebuild when its parent does.
/// Prevents costly native view recreations during high-frequency sensor updates.
class ArCoreNativeView extends StatelessWidget {
  const ArCoreNativeView({super.key, required this.onCreated});

  final void Function(ArCoreController) onCreated;

  @override
  Widget build(BuildContext context) {
    return ArCoreView(
      onArCoreViewCreated: onCreated,
      enableTapRecognizer: true,
    );
  }
}
