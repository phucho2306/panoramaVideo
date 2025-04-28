import 'package:camera/camera.dart';
import 'package:capture_360_inside/presentation/views/recorder/stop_notify_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../cubits/video_recorder_cubit.dart';
import '../../widgets/compass/center_compass_arrow.dart';
import '../../widgets/compass/compass_arrow.dart';
import '../../widgets/painters/arrow_painter.dart';
import '../../widgets/painters/grid_painter.dart';
import '../loading/loading_screen.dart';
import '../ready/video_ready_screen.dart';
import '../video/video_preview_screen.dart';

class VideoRecorderScreen extends StatelessWidget {
  final List<CameraDescription> cameras;
  final CameraController cameraController;
  final VideoRecorderCubit? existingCubit;

  const VideoRecorderScreen({Key? key, required this.cameras, required this.cameraController, this.existingCubit})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = existingCubit ?? VideoRecorderCubit(cameraController: cameraController);

    return BlocProvider<VideoRecorderCubit>.value(
      value: cubit,
      child: BlocListener<VideoRecorderCubit, VideoRecorderState>(
        listener: (context, state) {
          if (state is VideoRecorderStopped) {
            if (ModalRoute.of(context)?.isCurrent == true) {
              showStopNotifyBottomSheet(
                context: context,
                videoFile: state.videoFile,
                cameras: cameras,
                cameraController: cameraController,
              ).then((result) {
                if (result == 'Preview') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => VideoPreviewScreen(
                            videoFile: state.videoFile,
                            cameras: cameras,
                            cameraController: cameraController,
                          ),
                    ),
                  );
                } else if (result == 'Confirm') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoadingScreen(videoFile: state.videoFile)),
                  );
                }
              });
            }
          }
        },
        child: BlocBuilder<VideoRecorderCubit, VideoRecorderState>(
          builder: (context, state) {
            final cubit = context.read<VideoRecorderCubit>();

            if (state is VideoRecorderInitial || state is VideoRecorderLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is VideoRecorderError) {
              return Center(child: Text(state.message));
            }

            final isRecording = state is VideoRecorderRecording;
            final isTiltOk =
                state is VideoRecorderReady
                    ? state.isTiltOk
                    : state is VideoRecorderRecording
                    ? state.isTiltOk
                    : true;
            final tiltAngle =
                state is VideoRecorderReady
                    ? state.tiltAngle
                    : state is VideoRecorderRecording
                    ? state.tiltAngle
                    : 0.0;
            final accumulatedRotation = state is VideoRecorderRecording ? state.accumulatedRotation : 0.0;
            final showDirectionWarning = state is VideoRecorderRecording ? state.showDirectionWarning : false;
            final recordingSeconds = state is VideoRecorderRecording ? state.recordingSeconds : 0;

            int percentage = ((accumulatedRotation / 360) * 100).toInt();
            String displayPercentage =
                percentage < 0
                    ? "0%"
                    : percentage > 100
                    ? "100%"
                    : "$percentage%";

            return Scaffold(
              extendBodyBehindAppBar: true,
              backgroundColor: Colors.transparent,
              body: Stack(
                children: [
                  GestureDetector(
                    onTapUp: (details) {
                      cubit.focusCamera();
                    },
                    child: CameraPreview(cameraController),
                  ),
                  CustomPaint(size: Size.infinite, painter: GridPainter()),
                  CustomPaint(
                    size: Size.infinite,
                    painter: ArrowPainter(color: isTiltOk ? const Color(0xFFFFCC00) : const Color(0xFFFFFFFF)),
                  ),
                  Transform.rotate(
                    angle: tiltAngle * 0.1,
                    child: Center(
                      child: Container(
                        width: 140,
                        height: 4,
                        color: isTiltOk ? const Color(0xFFFFCC00) : const Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                  if (!isRecording)
                    Positioned(
                      bottom: 150,
                      left: 16,
                      right: 16,
                      child: Card(
                        color: Colors.black.withOpacity(0.3),
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'packages/capture_360_inside/assets/images/Frame_1261158946.svg',
                                width: 48,
                                height: 36,
                              ),
                              const SizedBox(width: 8),
                              const Flexible(
                                child: Text(
                                  "Aligning the line during recording will enhance your 360 results significantly",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(fontSize: 12, color: Color(0xFFFFFFFF), fontFamily: 'Inter'),
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
                      opacity: showDirectionWarning ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 3000),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Card(
                          color: Colors.black.withOpacity(0.9),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'packages/capture_360_inside/assets/images/Frame.svg',
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
                    child: SafeArea(
                      top: false,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Visibility(
                              visible: isRecording,
                              child: Flexible(
                                child: Container(
                                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.3),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(width: 16),
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
                            isRecording
                                ? InkWell(
                                  onTap: () async {
                                    await cubit.stopRecording();
                                  },
                                  child: const CenterCompassArrow(),
                                )
                                : InkWell(
                                  onTap: cubit.startRecording,
                                  child: SvgPicture.asset(
                                    'packages/capture_360_inside/assets/images/Oval.svg',
                                    width: 100,
                                    height: 100,
                                  ),
                                ),
                            Visibility(
                              visible: isRecording,
                              child: Flexible(
                                child: Container(
                                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.3),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 16,
                                        height: 16,
                                        margin: const EdgeInsets.only(right: 6),
                                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                      ),
                                      Text(
                                        cubit.formatDuration(recordingSeconds),
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
                      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                      height: MediaQuery.of(context).padding.top + 85,
                      color: Colors.black.withOpacity(0.4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: GestureDetector(
                              onTap: () async {
                                await cubit.handleBackButton();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            VideoReadyScreen(cameras: cameras, cameraController: cameraController),
                                  ),
                                );
                              },
                              child: SvgPicture.asset(
                                'packages/capture_360_inside/assets/images/Button.svg',
                                width: 200,
                                height: 50,
                              ),
                            ),
                          ),
                          if (isRecording) const Padding(padding: EdgeInsets.only(right: 10), child: CompassArrow()),
                        ],
                      ),
                    ),
                  ),
                  if (state is VideoRecorderUploading)
                    Container(color: Colors.black54, child: const Center(child: CircularProgressIndicator())),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
