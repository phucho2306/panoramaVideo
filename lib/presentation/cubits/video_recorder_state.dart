part of 'video_recorder_cubit.dart';

abstract class VideoRecorderState extends Equatable {
  const VideoRecorderState();

  @override
  List<Object?> get props => [];
}

class VideoRecorderInitial extends VideoRecorderState {}

class VideoRecorderLoading extends VideoRecorderState {}

class VideoRecorderReady extends VideoRecorderState {
  final CameraController cameraController;
  final bool isTiltOk;
  final double tiltAngle;

  const VideoRecorderReady({
    required this.cameraController,
    required this.isTiltOk,
    required this.tiltAngle,
  });

  @override
  List<Object?> get props => [cameraController, isTiltOk, tiltAngle];
}

class VideoRecorderRecording extends VideoRecorderState {
  final CameraController cameraController;
  final bool isTiltOk;
  final double tiltAngle;
  final double accumulatedRotation;
  final bool isComplete;
  final bool showDirectionWarning;
  final int recordingSeconds;
  final double? startDirection;
  final double? previousDirection;

  const VideoRecorderRecording({
    required this.cameraController,
    required this.isTiltOk,
    required this.tiltAngle,
    required this.accumulatedRotation,
    required this.isComplete,
    required this.showDirectionWarning,
    required this.recordingSeconds,
    this.startDirection,
    this.previousDirection,
  });

  @override
  List<Object?> get props => [
    cameraController,
    isTiltOk,
    tiltAngle,
    accumulatedRotation,
    isComplete,
    showDirectionWarning,
    recordingSeconds,
    startDirection,
    previousDirection,
  ];
}

class VideoRecorderStopped extends VideoRecorderState {
  final CameraController cameraController;
  final File videoFile;

  const VideoRecorderStopped({
    required this.cameraController,
    required this.videoFile,
  });

  @override
  List<Object?> get props => [cameraController, videoFile];
}

class VideoRecorderUploading extends VideoRecorderState {
  final CameraController cameraController;

  const VideoRecorderUploading({required this.cameraController});

  @override
  List<Object?> get props => [cameraController];
}

class VideoRecorderError extends VideoRecorderState {
  final String message;

  const VideoRecorderError({required this.message});

  @override
  List<Object?> get props => [message];
}