import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

part 'video_ready_state.dart';

class VideoReadyCubit extends Cubit<VideoReadyState> {
  final CameraController cameraController;
  final List<CameraDescription> cameras; // Thêm cameras để chọn camera sau

  VideoReadyCubit({
    required this.cameraController,
    required this.cameras,
  }) : super(VideoReadyInitial()) {
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    emit(VideoReadyLoading());
    try {
      if (!cameraController.value.isInitialized) {
        // Cấu hình camera tương tự _initializeCamera trong main.dart
        await cameraController.initialize();
        await cameraController.setFocusMode(FocusMode.auto);
        await cameraController.setExposureMode(ExposureMode.auto);
        await cameraController.lockCaptureOrientation(DeviceOrientation.portraitUp);
        debugPrint('Camera initialized with auto focus, auto exposure, and portrait orientation');
      }
      emit(VideoReadyInitialized(cameraController));
    } catch (e) {
      debugPrint("Camera initialization error: $e");
      emit(VideoReadyError(message: "Error initializing camera: $e"));
    }
  }

  @override
  Future<void> close() {
    // CameraController is managed by MyApp, so no dispose here
    return super.close();
  }
}