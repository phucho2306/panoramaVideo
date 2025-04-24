import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../widgets/compass/compass_arrow.dart';
import '../../widgets/compass/arrow_360.dart';
import '../../widgets/painters/arrow_painter.dart';
import '../../widgets/painters/grid_painter.dart';
import '../video/video_preview_screen.dart';
import '../loading/loading_screen.dart';
import 'package:panorama_capture/presentation/cubit/video_recorder/video_recorder_cubit.dart';
import 'notification_video.dart';
import 'package:panorama_capture/presentation/widgets/ready/video_ready_widget.dart';

class VideoRecorderScreen extends StatefulWidget {
  final CameraController cameraController;
  final List<CameraDescription> cameras;

  const VideoRecorderScreen({
    Key? key,
    required this.cameras,
    required this.cameraController,
  }) : super(key: key);

  @override
  _VideoRecorderScreenState createState() => _VideoRecorderScreenState();
}

class _VideoRecorderScreenState extends State<VideoRecorderScreen> {
  bool _isReady = true; // Trạng thái để hiển thị VideoReadyWidget hay giao diện ghi hình

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: _isReady
          ? VideoReadyWidget(
              cameras: widget.cameras,
              cameraController: widget.cameraController,
              onReadyPressed: () {
                setState(() {
                  _isReady = false; // Chuyển sang giao diện ghi hình
                });
              },
            )
          : BlocProvider(
              create: (context) =>
                  VideoRecorderCubit(widget.cameraController)..initialize(),
              child: BlocConsumer<VideoRecorderCubit, VideoRecorderState>(
                listener: (context, state) {
                  print(
                      'Listener triggered: isRecording=${state.isRecording}, videoFile=${state.videoFile}');
                  // Hiển thị bottom sheet khi video dừng và có videoFile
                  if (!state.isRecording && state.videoFile != null) {
                    _reset360.currentState?.reset();
                    showStopNotifyBottomSheet(
                      context: context,
                      videoFile: state.videoFile!,
                      cameras: widget.cameras,
                      cameraController: widget.cameraController,
                    ).then((result) {
                      if (result == 'Preview') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoPreviewScreen(
                              videoFile: state.videoFile!,
                              cameras: widget.cameras,
                              cameraController: widget.cameraController,
                            ),
                          ),
                        );
                      } else if (result == 'Confirm') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                LoadingScreen(videoFile: state.videoFile!),
                          ),
                        );
                      }
                    });
                  }
                },
                builder: (context, state) {
                  if (!widget.cameraController.value.isInitialized) {
                    return Center(child: CircularProgressIndicator());
                  }

                  int percentage =
                      ((state.accumulatedRotation / 360) * 100).toInt();
                  String displayPercentage = percentage < 0
                      ? "0%"
                      : percentage > 100
                          ? "100%"
                          : "$percentage%";

                  String formatDuration(int seconds) {
                    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
                    final secs = (seconds % 60).toString().padLeft(2, '0');
                    return "$minutes:$secs";
                  }

                  return Stack(
                    children: [
                      CameraPreview(widget.cameraController),
                      CustomPaint(size: Size.infinite, painter: GridPainter()),
                      CustomPaint(
                        size: Size.infinite,
                        painter: ArrowPainter(
                          color: state.isTiltOk
                              ? Color(0xFFFFCC00)
                              : Color(0xFFFFFFFF),
                        ),
                      ),
                      Transform.rotate(
                        angle: state.tiltAngle * 0.1,
                        child: Center(
                          child: Container(
                            key: _tiltBarKey,
                            width: 140,
                            height: 4,
                            color: state.isTiltOk
                                ? Color(0xFFFFCC00)
                                : Color(0xFFFFFFFF),
                          ),
                        ),
                      ),
                      if (!state.isRecording)
                        Positioned(
                          bottom: 150,
                          left: 16,
                          right: 16,
                          child: Card(
                            color: Colors.black.withOpacity(0.3),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'assets/images/Frame_1261158946.svg',
                                    width: 48,
                                    height: 36,
                                  ),
                                  const SizedBox(width: 8),
                                  const Flexible(
                                    child: Text(
                                      "Aligning the line during recording will enhance your 360 results significantly",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFFFFFFFF),
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        bottom: 150,
                        left: 20,
                        right: 20,
                        child: AnimatedOpacity(
                          opacity: state.showDirectionWarning ? 1.0 : 0.0,
                          duration: Duration(milliseconds: 3000),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Card(
                              color: Colors.black.withOpacity(0.9),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/images/Frame.svg',
                                      width: 50,
                                      height: 50,
                                    ),
                                    const SizedBox(width: 8),
                                    const Flexible(
                                      child: Text(
                                        "Keep your phone steady and slide it "
                                        "to the left until the progress bar "
                                        "is completely filled",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          color: Colors.black.withOpacity(0.4),
                          child: Transform.translate(
                            offset: Offset(0, -10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Visibility(
                                  visible: state.isRecording,
                                  child: Flexible(
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 16,
                                            height: 16,
                                          ),
                                          Text(
                                            displayPercentage,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                state.isRecording
                                    ? InkWell(
                                        key: _startRecordingButtonKey,
                                        onTap: () async {
                                          _reset360.currentState?.reset();
                                          context
                                              .read<VideoRecorderCubit>()
                                              .stopRecording()
                                              .then((videoFile) {
                                            if (videoFile != null) {
                                              showStopNotifyBottomSheet(
                                                context: context,
                                                videoFile: videoFile,
                                                cameras: widget.cameras,
                                                cameraController:
                                                    widget.cameraController,
                                              ).then((result) {
                                                if (result == 'Preview') {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          VideoPreviewScreen(
                                                        videoFile: videoFile,
                                                        cameras: widget.cameras,
                                                        cameraController:
                                                            widget
                                                                .cameraController,
                                                      ),
                                                    ),
                                                  );
                                                } else if (result == 'Confirm') {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          LoadingScreen(
                                                              videoFile:
                                                                  videoFile),
                                                    ),
                                                  );
                                                }
                                              });
                                            }
                                          });
                                        },
                                        child:
                                            CenterCompassArrow(key: _reset360),
                                      )
                                    : InkWell(
                                        key: _startRecordingButtonKey,
                                        onTap: () {
                                          context
                                              .read<VideoRecorderCubit>()
                                              .startRecording();
                                          _reset360.currentState?.reset();
                                        },
                                        child: SvgPicture.asset(
                                          'assets/images/Oval.svg',
                                          width: 100,
                                          height: 100,
                                        ),
                                      ),
                                Visibility(
                                  visible: state.isRecording,
                                  child: Flexible(
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 16,
                                            height: 16,
                                            margin: const EdgeInsets.only(
                                                right: 6),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          Text(
                                            formatDuration(state.recordingSeconds),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).padding.top),
                          height: MediaQuery.of(context).padding.top + 85,
                          color: Colors.black.withOpacity(0.4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: GestureDetector(
                                  onTap: () {
                                    context
                                        .read<VideoRecorderCubit>()
                                        .handleBackButton()
                                        .then((_) {
                                      if (state.isRecording) {
                                        Navigator.pop(context);
                                      } else {
                                        setState(() {
                                          _isReady = true; // Quay lại VideoReadyWidget
                                        });
                                      }
                                    });
                                  },
                                  child: SvgPicture.asset(
                                    'assets/images/Button.svg',
                                    width: 200,
                                    height: 50,
                                  ),
                                ),
                              ),
                              if (state.isRecording)
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: CompassArrow(key: _compassArrow),
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (state.error != null)
                        Center(
                          child: Text(
                            state.error!,
                            style: TextStyle(color: Colors.red, fontSize: 16),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
    );
  }

  final GlobalKey _tiltBarKey = GlobalKey();
  final GlobalKey _startRecordingButtonKey = GlobalKey();
  final GlobalKey _arrow360 = GlobalKey();
  final GlobalKey _compassArrow = GlobalKey();
  final GlobalKey<CenterCompassArrowState> _reset360 = GlobalKey();
}