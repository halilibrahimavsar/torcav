import 'package:camera/camera.dart';

abstract class CameraDataSource {
  Future<void> initialize();
  CameraController? get controller;
  Stream<CameraImage> get frameStream;
  Future<void> dispose();
}

class CameraDataSourceImpl implements CameraDataSource {
  CameraController? _controller;

  @override
  CameraController? get controller => _controller;

  @override
  Future<void> initialize() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _controller = CameraController(
      cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg, 
    );

    await _controller!.initialize();
  }

  @override
  Stream<CameraImage> get frameStream {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Stream.empty();
    }
    // Note: The camera plugin doesn't naturally expose a stream of frames
    // directly like this; it usually uses startImageStream.
    // This is a simplified interface for our BLoC/Usecase.
    return const Stream.empty(); 
  }

  @override
  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
  }
}
