import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/wall_segment.dart';
import '../bloc/heatmap_bloc.dart';
import '../bloc/scan_phase.dart';

class ArCameraView extends StatefulWidget {
  const ArCameraView({super.key});

  @override
  State<ArCameraView> createState() => _ArCameraViewState();
}

class _ArCameraViewState extends State<ArCameraView> {
  CameraController? _controller;
  bool _isInit = false;
  String? _cameraError;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          setState(() => _cameraError = 'No camera available on this device.');
        }
        return;
      }

      _controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _controller!.initialize();
      if (!mounted) return;

      setState(() => _isInit = true);

      final bloc = context.read<HeatmapBloc>();
      if (!_controller!.value.isStreamingImages) {
        await _controller!.startImageStream((image) {
          if (!mounted) return;
          bloc.processCameraImage(image);
        });
      }
    } catch (error) {
      debugPrint('Camera error: $error');
      if (mounted) {
        setState(() => _cameraError = 'Camera preview could not start.');
      }
    }
  }

  @override
  void dispose() {
    if (_controller?.value.isStreamingImages ?? false) {
      _controller?.stopImageStream();
    }
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraError != null) {
      return _CameraFallback(message: _cameraError!);
    }

    if (!_isInit || _controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return BlocBuilder<HeatmapBloc, HeatmapState>(
      builder: (context, state) {
        final sampleCount = state.currentSession?.points.length ?? 0;

        return Stack(
          fit: StackFit.expand,
          children: [
            CameraPreview(_controller!),
            const IgnorePointer(child: _CameraVignette()),
            CustomPaint(
              painter: _ArOverlayPainter(
                phase: state.phase,
                pendingWalls: state.pendingWalls,
                currentRssi: state.currentRssi,
                lastStepTimestamp: state.lastStepTimestamp,
              ),
            ),
            if (state.phase == ScanPhase.scanning)
              _ScanningHud(
                currentRssi: state.currentRssi,
                wallCount: state.pendingWalls.length,
                sampleCount: sampleCount,
              ),
          ],
        );
      },
    );
  }
}

class _ArOverlayPainter extends CustomPainter {
  _ArOverlayPainter({
    required this.phase,
    required this.pendingWalls,
    this.currentRssi,
    this.lastStepTimestamp,
  });

  final ScanPhase phase;
  final List<WallSegment> pendingWalls;
  final int? currentRssi;
  final DateTime? lastStepTimestamp;

  @override
  void paint(Canvas canvas, Size size) {
    if (phase != ScanPhase.scanning) return;

    final wallPaint =
        Paint()
          ..color = AppColors.neonCyan.withValues(alpha: 0.65)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.4);

    for (final wall in pendingWalls) {
      canvas.drawLine(
        Offset(wall.x1 * size.width, wall.y1 * size.height),
        Offset(wall.x2 * size.width, wall.y2 * size.height),
        wallPaint,
      );
    }

    if (currentRssi != null) {
      final strength = ((currentRssi! + 90) / 55).clamp(0.0, 1.0);
      final signalPaint =
          Paint()
            ..color =
                Color.lerp(
                  const Color(0xFFFF3B30),
                  const Color(0xFF00E676),
                  strength,
                )!
            ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        9,
        signalPaint,
      );
    }

    if (lastStepTimestamp != null) {
      final diff = DateTime.now().difference(lastStepTimestamp!).inMilliseconds;
      if (diff < 800) {
        final progress = diff / 800.0;
        final pulsePaint =
            Paint()
              ..color = AppColors.neonCyan.withValues(
                alpha: (1 - progress) * 0.35,
              )
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2;
        canvas.drawCircle(
          Offset(size.width / 2, size.height / 2),
          18 + (progress * 120),
          pulsePaint,
        );
      }
    }

    _drawCrosshair(canvas, size);
  }

  void _drawCrosshair(Canvas canvas, Size size) {
    final linePaint =
        Paint()
          ..color = AppColors.neonCyan.withValues(alpha: 0.28)
          ..strokeWidth = 1.1;

    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawLine(
      Offset(center.dx - 20, center.dy),
      Offset(center.dx + 20, center.dy),
      linePaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - 20),
      Offset(center.dx, center.dy + 20),
      linePaint,
    );
    canvas.drawLine(
      Offset(center.dx - 96, center.dy),
      Offset(center.dx - 38, center.dy),
      linePaint,
    );
    canvas.drawLine(
      Offset(center.dx + 38, center.dy),
      Offset(center.dx + 96, center.dy),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ArOverlayPainter oldDelegate) =>
      oldDelegate.phase != phase ||
      oldDelegate.pendingWalls != pendingWalls ||
      oldDelegate.currentRssi != currentRssi ||
      oldDelegate.lastStepTimestamp != lastStepTimestamp;
}

class _ScanningHud extends StatelessWidget {
  const _ScanningHud({
    required this.currentRssi,
    required this.wallCount,
    required this.sampleCount,
  });

  final int? currentRssi;
  final int wallCount;
  final int sampleCount;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _HudChip(
                  label: 'RSSI',
                  value: currentRssi == null ? '--' : '$currentRssi dBm',
                  valueColor:
                      currentRssi == null
                          ? AppColors.textSecondary
                          : _signalColor(currentRssi!),
                ),
                const SizedBox(width: 10),
                _HudChip(label: 'Walls', value: '$wallCount'),
                const SizedBox(width: 10),
                _HudChip(label: 'Samples', value: '$sampleCount'),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.44),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.neonCyan.withValues(alpha: 0.22),
                ),
              ),
              child: const Text(
                'Walk across each room. Keep the phone facing the walls from time to time so the outline can lock in.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _signalColor(int rssi) {
    final normalized = ((rssi + 90) / 55).clamp(0.0, 1.0);
    return Color.lerp(
      const Color(0xFFFF3B30),
      const Color(0xFF00E676),
      normalized,
    )!;
  }
}

class _HudChip extends StatelessWidget {
  const _HudChip({
    required this.label,
    required this.value,
    this.valueColor = Colors.white,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.42),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CameraFallback extends StatelessWidget {
  const _CameraFallback({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.darkSurface,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.no_photography_outlined,
            color: AppColors.textSecondary,
            size: 44,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraVignette extends StatelessWidget {
  const _CameraVignette();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.28),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withValues(alpha: 0.36),
          ],
        ),
      ),
    );
  }
}
