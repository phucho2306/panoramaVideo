import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'video_ready_state.dart';

class VideoReadyCubit extends Cubit<VideoReadyState> {
  final CameraController cameraController;

  VideoReadyCubit(this.cameraController) : super(VideoReadyState.initial());

  Future<void> initializeCamera() async {
    if (!cameraController.value.isInitialized) {
      try {
        await cameraController.initialize();
        emit(state.copyWith(isCameraInitialized: true));
      } catch (e) {
        emit(state.copyWith(error: 'Failed to initialize camera: $e'));
      }
    } else {
      emit(state.copyWith(isCameraInitialized: true));
    }
  }
}