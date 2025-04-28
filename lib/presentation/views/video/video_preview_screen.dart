import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:panorama_capture/presentation/views/recorder/video_recorder_screen.dart';
import 'package:video_player/video_player.dart';

import '../../cubits/video_preview_cubit.dart';
import '../loading/loading_screen.dart';
import '../ready/video_ready_screen.dart';

class VideoPreviewScreen extends StatelessWidget {
  final File videoFile;
  final List<CameraDescription> cameras;
  final CameraController cameraController;

  const VideoPreviewScreen({
    Key? key,
    required this.videoFile,
    required this.cameras,
    required this.cameraController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VideoPreviewCubit(
        videoFile: videoFile,
        cameras: cameras,
        cameraController: cameraController,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: BlocBuilder<VideoPreviewCubit, VideoPreviewState>(
          builder: (context, state) {
            final cubit = context.read<VideoPreviewCubit>();

            if (state is VideoPreviewLoading || state is VideoPreviewInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is VideoPreviewError) {
              return Center(child: Text(state.message, style: const TextStyle(color: Colors.white)));
            }

            if (state is VideoPreviewInitialized) {
              return Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height * 0.7,
                                child: FittedBox(
                                  fit: BoxFit.fill,
                                  child: SizedBox(
                                    width: state.controller.value.size.width,
                                    height: state.controller.value.size.height,
                                    child: VideoPlayer(state.controller),
                                  ),
                                ),
                              ),
                              if (state.showCenterIcon || state.isCompleted)
                                GestureDetector(
                                  onTap: () {
                                    if (state.isCompleted) {
                                      cubit.replayVideo();
                                    } else {
                                      cubit.togglePlay(fromBottomControl: false);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black.withOpacity(0.6),
                                    ),
                                    child: Icon(
                                      state.isCompleted
                                          ? Icons.repeat
                                          : state.isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => cubit.togglePlay(fromBottomControl: true),
                              child: Icon(
                                state.isPlaying ? Icons.pause : Icons.play_arrow,
                                size: 25,
                                color: const Color(0xFFFFFFFF),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: VideoProgressIndicator(
                                  state.controller,
                                  allowScrubbing: true,
                                  padding: EdgeInsets.zero,
                                  colors: const VideoProgressColors(
                                    playedColor: Color(0xFFFFFFFF),
                                    bufferedColor: Colors.grey,
                                    backgroundColor: Colors.white24,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              cubit.formatDuration(state.duration),
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VideoRecorderScreen(
                                        cameras: cameras,
                                        cameraController: cameraController,
                                      ),
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.white),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                ),
                                child: const Text(
                                  "Record Again",
                                  style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LoadingScreen(videoFile: videoFile),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                ),
                                child: const Text(
                                  "Confirm to Use",
                                  style: TextStyle(
                                    color: Color(0xFF00284B),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}