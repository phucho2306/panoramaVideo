import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'presentation/views/ready/video_ready_screen.dart';

class Panorama extends StatefulWidget {
  const Panorama({Key? key}) : super(key: key);

  @override
  _PanoramaState createState() => _PanoramaState();
}

class _PanoramaState extends State<Panorama> {
  late CameraController _cameraController;
  List<CameraDescription> cameras = [];

  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();

    _cameraController = CameraController(
      cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.back),
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await _cameraController.initialize();

    try {
      await _cameraController.setFocusMode(FocusMode.auto);
      await _cameraController.setExposureMode(ExposureMode.auto);
      await _cameraController.lockCaptureOrientation(DeviceOrientation.portraitUp);
    } catch (e) {
      debugPrint("Camera advanced config error: $e");
    }

    if (mounted) {
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isCameraInitialized
        ? VideoReadyScreen(cameras: cameras, cameraController: _cameraController)
        : Center(child: CircularProgressIndicator());
  }
}
