import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:video_player/video_player.dart';

part 'video_preview_state.dart';

class VideoPreviewCubit extends Cubit<VideoPreviewState> {
  final File videoFile;
  final List<CameraDescription> cameras;
  final CameraController cameraController;
  late VideoPlayerController _controller;
  Timer? _centerIconTimer;
  bool _isPlaying = false;
  bool _showCenterIcon = true;

  VideoPreviewCubit({
    required this.videoFile,
    required this.cameras,
    required this.cameraController,
  }) : super(VideoPreviewInitial()) {
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    emit(VideoPreviewLoading());
    try {
      _controller = VideoPlayerController.file(videoFile)
        ..addListener(() {
          emit(VideoPreviewInitialized(
            controller: _controller,
            isPlaying: _isPlaying,
            showCenterIcon: _showCenterIcon,
            position: _controller.value.position,
            duration: _controller.value.duration,
            isCompleted: _controller.value.isCompleted,
          ));
        });

      await _controller.initialize();
      _isPlaying = true;
      _showCenterIcon = false;
      await _controller.play();

      emit(VideoPreviewInitialized(
        controller: _controller,
        isPlaying: _isPlaying,
        showCenterIcon: _showCenterIcon,
        position: _controller.value.position,
        duration: _controller.value.duration,
        isCompleted: _controller.value.isCompleted,
      ));
    } catch (e) {
      emit(VideoPreviewError(message: 'Failed to initialize video: $e'));
    }
  }

  void togglePlay({bool fromBottomControl = false}) {
    if (_controller.value.isPlaying) {
      _controller.pause();
      _isPlaying = false;
      if (fromBottomControl) {
        _showCenterIcon = true;
        _startCenterIconHideTimer();
      }
    } else {
      _controller.play();
      _isPlaying = true;
      if (fromBottomControl) {
        _showCenterIcon = false;
        _centerIconTimer?.cancel();
      }
    }
    emit(VideoPreviewInitialized(
      controller: _controller,
      isPlaying: _isPlaying,
      showCenterIcon: _showCenterIcon,
      position: _controller.value.position,
      duration: _controller.value.duration,
      isCompleted: _controller.value.isCompleted,
    ));
  }

  void replayVideo() {
    _controller.seekTo(Duration.zero);
    _controller.play();
    _isPlaying = true;
    _showCenterIcon = false;
    emit(VideoPreviewInitialized(
      controller: _controller,
      isPlaying: _isPlaying,
      showCenterIcon: _showCenterIcon,
      position: _controller.value.position,
      duration: _controller.value.duration,
      isCompleted: _controller.value.isCompleted,
    ));
  }

  void _startCenterIconHideTimer() {
    _centerIconTimer?.cancel();
    _centerIconTimer = Timer(const Duration(seconds: 3), () {
      _showCenterIcon = false;
      emit(VideoPreviewInitialized(
        controller: _controller,
        isPlaying: _isPlaying,
        showCenterIcon: _showCenterIcon,
        position: _controller.value.position,
        duration: _controller.value.duration,
        isCompleted: _controller.value.isCompleted,
      ));
    });
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Future<void> close() {
    _controller.dispose();
    _centerIconTimer?.cancel();
    return super.close();
  }
}