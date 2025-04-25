import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';

part 'video_ready_state.dart';

class VideoReadyCubit extends Cubit<VideoReadyState> {
  final CameraController cameraController;

  VideoReadyCubit({required this.cameraController}) : super(VideoReadyInitial()) {
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    emit(VideoReadyLoading());
    if (!cameraController.value.isInitialized) {
      await cameraController.initialize();
    }
    emit(VideoReadyInitialized(cameraController));
  }

  @override
  Future<void> close() {
    // CameraController is managed by MyApp, so no dispose here
    return super.close();
  }
}