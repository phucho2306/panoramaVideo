part of 'video_ready_cubit.dart';

class VideoReadyState {
  final bool isCameraInitialized;
  final String? error;

  VideoReadyState({
    required this.isCameraInitialized,
    this.error,
  });

  factory VideoReadyState.initial() => VideoReadyState(
        isCameraInitialized: false,
        error: null,
      );

  VideoReadyState copyWith({
    bool? isCameraInitialized,
    String? error,
  }) {
    return VideoReadyState(
      isCameraInitialized: isCameraInitialized ?? this.isCameraInitialized,
      error: error ?? this.error,
    );
  }
}