part of 'video_preview_cubit.dart';

abstract class VideoPreviewState extends Equatable {
  const VideoPreviewState();

  @override
  List<Object?> get props => [];
}

class VideoPreviewInitial extends VideoPreviewState {}

class VideoPreviewLoading extends VideoPreviewState {}

class VideoPreviewInitialized extends VideoPreviewState {
  final VideoPlayerController controller;
  final bool isPlaying;
  final bool showCenterIcon;
  final Duration position;
  final Duration duration;
  final bool isCompleted;

  const VideoPreviewInitialized({
    required this.controller,
    required this.isPlaying,
    required this.showCenterIcon,
    required this.position,
    required this.duration,
    required this.isCompleted,
  });

  @override
  List<Object?> get props => [
    controller,
    isPlaying,
    showCenterIcon,
    position,
    duration,
    isCompleted,
  ];
}

class VideoPreviewError extends VideoPreviewState {
  final String message;

  const VideoPreviewError({required this.message});

  @override
  List<Object?> get props => [message];
}