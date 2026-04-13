import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:torcav/core/theme/app_theme.dart';
import 'package:torcav/features/heatmap/domain/entities/wall_segment.dart';
import 'package:torcav/features/heatmap/domain/services/survey_guidance_service.dart';
import 'package:torcav/features/heatmap/presentation/bloc/heatmap_bloc.dart';
import 'package:torcav/features/heatmap/presentation/bloc/scan_phase.dart';
import 'package:torcav/features/heatmap/presentation/widgets/ar_hud_overlay.dart';

/// Camera-preview fallback for devices without ARCore support.
///
/// Streams camera frames into the bloc for wall detection, renders an
/// AR-style crosshair + wall overlay via [_ArOverlayPainter], then tops it
/// with the shared [ArHudOverlay] so non-ARCore devices receive the same
/// premium information surface.
class ArCameraView extends StatefulWidget {
  const ArCameraView({
    super.key,
    this.onFinish,
    this.onDiscard,
  });

  final VoidCallback? onFinish;
  final VoidCallback? onDiscard;

  @override
  State<ArCameraView> createState() => _ArCameraViewState();
}

class _ArCameraViewState extends State<ArCameraView> {
  static const _guidanceService = SurveyGuidanceService();

  CameraController? _controller;
  bool _isInit = false;
  bool _isDisposed = false;
  String? _cameraError;

  /// Transient flagged weak-zone markers in normalized screen coordinates.
  final List<Offset> _flagOverlay = [];

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (_isDisposed) return;

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
      if (_isDisposed || !mounted) {
        _controller?.dispose();
        return;
      }

      setState(() => _isInit = true);

      final bloc = context.read<HeatmapBloc>();
      if (!_controller!.value.isStreamingImages) {
        await _controller!.startImageStream((image) {
          if (_isDisposed || !mounted) return;
          bloc.processCameraImage(image);
        });
      }
    } catch (error) {
      debugPrint('Camera error: $error');
      if (!_isDisposed && mounted) {
        setState(() => _cameraError = 'Camera preview could not start.');
      }
    }
  }

  void _flagCurrentPosition() {
    if (_isDisposed) return;
    // Fallback path has no ARCore anchor — place marker at screen center.
    context.read<HeatmapBloc>().flagCurrentWeakZone();
    setState(() {
      _flagOverlay.add(const Offset(0.5, 0.5));
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Weak zone flagged'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.black87,
      ),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    if (_controller?.value.isInitialized ?? false) {
      if (_controller?.value.isStreamingImages ?? false) {
        _controller?.stopImageStream();
      }
      _controller?.dispose();
    }
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
        final guidance = _guidanceService.analyze(
          points: state.currentSession?.points ?? const [],
          floorPlan: state.liveFloorPlan,
          isRecording: state.isRecording,
          hasArOrigin: state.hasArOrigin,
          pendingWallCount: state.pendingWalls.length,
          currentRssi: state.currentRssi,
          surveyGate: state.surveyGate,
          lastSignalAt: state.lastSignalAt,
          currentSignalStdDev: state.lastSignalStdDev,
          currentX: state.currentPosition?.dx,
          currentY: state.currentPosition?.dy,
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            CameraPreview(_controller!),
            const IgnorePointer(child: _CameraVignette()),
            IgnorePointer(
              child: CustomPaint(
                painter: _ArOverlayPainter(
                  phase: state.phase,
                  pendingWalls: state.pendingWalls,
                  currentRssi: state.currentRssi,
                  lastStepTimestamp: state.lastStepTimestamp,
                  flagMarkers: _flagOverlay,
                ),
              ),
            ),
            if (state.phase == ScanPhase.scanning)
              ArHudOverlay(
                guidance: guidance,
                estimatedMode: true,
                onFinish: widget.onFinish,
                onDiscard: widget.onDiscard,
                onFlagWeakZone: _flagCurrentPosition,
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
    required this.flagMarkers,
    this.currentRssi,
    this.lastStepTimestamp,
  });

  final ScanPhase phase;
  final List<WallSegment> pendingWalls;
  final int? currentRssi;
  final DateTime? lastStepTimestamp;
  final List<Offset> flagMarkers;

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

    // Flag markers — red crosshair pins in normalized screen space.
    final flagPaint =
        Paint()
          ..color = AppColors.neonRed
          ..style = PaintingStyle.fill;
    final flagGlow =
        Paint()
          ..color = AppColors.neonRed.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    for (final f in flagMarkers) {
      final c = Offset(f.dx * size.width, f.dy * size.height);
      canvas.drawCircle(c, 10, flagGlow);
      canvas.drawCircle(c, 6, flagPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ArOverlayPainter oldDelegate) =>
      oldDelegate.phase != phase ||
      oldDelegate.pendingWalls != pendingWalls ||
      oldDelegate.currentRssi != currentRssi ||
      oldDelegate.lastStepTimestamp != lastStepTimestamp ||
      oldDelegate.flagMarkers != flagMarkers;
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
