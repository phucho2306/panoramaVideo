part of 'video_recorder_cubit.dart';

class VideoRecorderState {
  final bool isRecording;
  final double tiltAngle;
  final bool isTiltOk;
  final double? startDirection;
  final double? previousDirection;
  final double accumulatedRotation;
  final int recordingSeconds;
  final bool showDirectionWarning;
  final File? videoFile;
  final String? error;

  VideoRecorderState({
    required this.isRecording,
    required this.tiltAngle,
    required this.isTiltOk,
    this.startDirection,
    this.previousDirection,
    required this.accumulatedRotation,
    required this.recordingSeconds,
    required this.showDirectionWarning,
    this.videoFile,
    this.error,
  });

  factory VideoRecorderState.initial() {
    return VideoRecorderState(
      isRecording: false,
      tiltAngle: 0.0,
      isTiltOk: false,
      startDirection: null,
      previousDirection: null,
      accumulatedRotation: 0.0,
      recordingSeconds: 0,
      showDirectionWarning: false,
      videoFile: null,
      error: null,
    );
  }

  VideoRecorderState copyWith({
    bool? isRecording,
    double? tiltAngle,
    bool? isTiltOk,
    double? startDirection,
    double? previousDirection,
    double? accumulatedRotation,
    int? recordingSeconds,
    bool? showDirectionWarning,
    File? videoFile,
    String? error,
  }) {
    return VideoRecorderState(
      isRecording: isRecording ?? this.isRecording,
      tiltAngle: tiltAngle ?? this.tiltAngle,
      isTiltOk: isTiltOk ?? this.isTiltOk,
      startDirection: startDirection ?? this.startDirection,
      previousDirection: previousDirection ?? this.previousDirection,
      accumulatedRotation: accumulatedRotation ?? this.accumulatedRotation,
      recordingSeconds: recordingSeconds ?? this.recordingSeconds,
      showDirectionWarning: showDirectionWarning ?? this.showDirectionWarning,
      videoFile: videoFile ?? this.videoFile,
      error: error ?? this.error,
    );
  }
}