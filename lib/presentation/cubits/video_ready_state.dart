part of 'video_ready_cubit.dart';

abstract class VideoReadyState extends Equatable {
  const VideoReadyState();

  @override
  List<Object> get props => [];
}

class VideoReadyInitial extends VideoReadyState {}

class VideoReadyLoading extends VideoReadyState {}

class VideoReadyInitialized extends VideoReadyState {
  final CameraController cameraController;

  const VideoReadyInitialized(this.cameraController);

  @override
  List<Object> get props => [cameraController];
}

class VideoReadyError extends VideoReadyState {
  final String message;

  const VideoReadyError({required this.message});

  @override
  List<Object> get props => [message];
}