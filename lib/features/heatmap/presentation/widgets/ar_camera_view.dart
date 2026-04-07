import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/heatmap_bloc.dart';
import '../bloc/scan_phase.dart';
import '../../domain/entities/wall_segment.dart';

class ArCameraView extends StatefulWidget {
  const ArCameraView({super.key});

  @override
  State<ArCameraView> createState() => _ArCameraViewState();
}

class _ArCameraViewState extends State<ArCameraView> {
  CameraController? _controller;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _controller = CameraController(
      cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    try {
      await _controller!.initialize();
      if (!mounted) return;
      
      setState(() => _isInit = true);
      
      // Start image stream for wall detection
      final bloc = context.read<HeatmapBloc>();
      _controller!.startImageStream((image) {
        if (!mounted) return;
        bloc.processCameraImage(image);
      });
    } catch (e) {
      debugPrint('Camera error: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInit || _controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return BlocBuilder<HeatmapBloc, HeatmapState>(
      builder: (context, state) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // 1. Camera Feed
            CameraPreview(_controller!),

            // 2. AR Overlay (Walls & Points)
            CustomPaint(
              painter: _ArOverlayPainter(
                phase: state.phase,
                pendingWalls: state.pendingWalls,
                currentRssi: state.currentRssi,
                lastStepTimestamp: state.lastStepTimestamp,
              ),
            ),

            // 3. Scanning Animation/HUD
            if (state.phase == ScanPhase.scanning)
              const _ScanningHud(),
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

    final paint = Paint()
      ..color = AppColors.neonCyan.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    // Draw detected wall segments
    for (var wall in pendingWalls) {
        // wall.x1, y1 are normalized [0..1]
        canvas.drawLine(
          Offset(wall.x1 * size.width, wall.y1 * size.height),
          Offset(wall.x2 * size.width, wall.y2 * size.height),
          paint,
        );
    }
    
    // Draw "Signal Depth" indicator
    if (currentRssi != null) {
      final signalPaint = Paint()
        ..color = Color.lerp(Colors.red, Colors.green, (currentRssi! + 100) / 60)!
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2), 
        10.0, 
        signalPaint
      );
    }

    // 4. Step Pulse Animation
    if (lastStepTimestamp != null) {
      final diff = DateTime.now().difference(lastStepTimestamp!).inMilliseconds;
      if (diff < 800) {
        final progress = diff / 800.0;
        final pulsePaint = Paint()
          ..color = AppColors.neonCyan.withValues(alpha: (1.0 - progress) * 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawCircle(
          Offset(size.width / 2, size.height / 2),
          20.0 + (progress * 150.0),
          pulsePaint,
        );
      }
    }

    // 5. Digital Horizon / Level
    _drawDigitalHorizon(canvas, size);
  }

  void _drawDigitalHorizon(Canvas canvas, Size size) {
    final horizonPaint = Paint()
      ..color = AppColors.neonCyan.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Center Crosshair
    canvas.drawLine(Offset(centerX - 20, centerY), Offset(centerX + 20, centerY), horizonPaint);
    canvas.drawLine(Offset(centerX, centerY - 20), Offset(centerX, centerY + 20), horizonPaint);

    // Horizontal Level Lines
    canvas.drawLine(Offset(centerX - 100, centerY), Offset(centerX - 40, centerY), horizonPaint);
    canvas.drawLine(Offset(centerX + 40, centerY), Offset(centerX + 100, centerY), horizonPaint);
  }

  @override
  bool shouldRepaint(covariant _ArOverlayPainter oldDelegate) => true;
}

class _ScanningHud extends StatelessWidget {
  const _ScanningHud();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.neonCyan.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.qr_code_scanner_rounded, color: AppColors.neonCyan, size: 64),
            const SizedBox(height: 16),
            Text(
              'SCANNING ENVIRONMENT...',
              style: TextStyle(
                color: AppColors.neonCyan,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                shadows: [
                    Shadow(color: AppColors.neonCyan, blurRadius: 10),
                ]
              ),
            ),
          ],
        ),
      ),
    );
  }
}
