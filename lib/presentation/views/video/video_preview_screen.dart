import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../loading/loading_screen.dart';
import '../ready/video_ready_screen.dart';

class VideoPreviewScreen extends StatefulWidget {
  final File videoFile;
  final List<CameraDescription> cameras;
  final CameraController cameraController;

  const VideoPreviewScreen({
    super.key,
    required this.videoFile,
    required this.cameras,
    required this.cameraController,
  });

  @override
  State<VideoPreviewScreen> createState() => _VideoPreviewScreenState();
}

class _VideoPreviewScreenState extends State<VideoPreviewScreen> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _showCenterIcon = true;

  Timer? _centerIconTimer;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _startCenterIconHideTimer() {
    _centerIconTimer?.cancel(); // Huỷ timer cũ nếu có
    _centerIconTimer = Timer(const Duration(seconds: 3), () {
      setState(() {
        _showCenterIcon = false;
      });
    });
  }

  void _initializeVideo() async {
    _controller = VideoPlayerController.file(widget.videoFile)
      ..addListener(() {
        setState(() {});
      })
      ..initialize().then((_) {
        setState(() {
          _isPlaying = true;
          _showCenterIcon = false;
          _controller.play();
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();

    _centerIconTimer?.cancel();
  }

  void _togglePlay({bool fromBottomControl = false}) {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
        if (fromBottomControl) {
          _showCenterIcon = true;
          _startCenterIconHideTimer(); // 👈 THÊM DÒNG NÀY
        }
      } else {
        _controller.play();
        _isPlaying = true;
        if (fromBottomControl) {
          _showCenterIcon = false;
          _centerIconTimer?.cancel(); // 👈 Nếu đang hiện icon thì ẩn luôn
        }
      }
    });
  }


  void _replayVideo() {
    setState(() {
      _controller.seekTo(Duration.zero);
      _controller.play();
      _isPlaying = true;
      _showCenterIcon = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final duration = _controller.value.duration;
    final position = _controller.value.position;

    String _formatDuration(Duration duration) {
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      final minutes = twoDigits(duration.inMinutes.remainder(60));
      final seconds = twoDigits(duration.inSeconds.remainder(60));
      return '$minutes:$seconds';
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Center(
                  child: _controller.value.isInitialized
                      ? Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: FittedBox(
                          fit: BoxFit.fill,
                          child: SizedBox(
                            width: _controller.value.size.width,
                            height: _controller.value.size.height,
                            child: VideoPlayer(_controller),
                          ),
                        ),
                      ),
                      if (_showCenterIcon || _controller.value.isCompleted)
                        GestureDetector(
                          onTap: () {
                            if (_controller.value.isCompleted) {
                              _replayVideo();
                            } else {
                              _togglePlay(fromBottomControl: false);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.6),
                            ),
                            child: Icon(
                              _controller.value.isCompleted
                                  ? Icons.repeat
                                  : _controller.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  )
                      : const CircularProgressIndicator(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => _togglePlay(fromBottomControl: true),
                      child: Icon(
                        _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 25,
                        color: const Color(0xFFFFFFFF),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: VideoProgressIndicator(
                          _controller,
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
                      _formatDuration(_controller.value.duration),
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
                          // Đóng màn hình preview hiện tại
                          Navigator.pop(context);
                          // Điều hướng đến VideoReadyScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VideoReadyScreen(
                                cameras: widget.cameras, // Bạn cần thêm cameras vào VideoPreviewScreen
                                cameraController: widget.cameraController, // Và cả cameraController
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
                          // Điều hướng đến LoadingScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoadingScreen(videoFile: widget.videoFile),
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
                          style: TextStyle(color: Color(0xFF00284B), fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          Positioned(
            top: 20,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.6),
                ),
                child: const Icon(
                  Icons.close,
                  size: 24,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}