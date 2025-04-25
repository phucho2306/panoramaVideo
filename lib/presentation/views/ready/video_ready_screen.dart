import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../cubits/video_ready_cubit.dart';
import '../recorder/video_recorder_screen.dart';

class VideoReadyScreen extends StatelessWidget {
  final List<CameraDescription> cameras;
  final CameraController cameraController;

  const VideoReadyScreen({
    Key? key,
    required this.cameras,
    required this.cameraController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VideoReadyCubit(
        cameraController: cameraController,
        cameras: cameras,
      ),
      child: Scaffold(
        body: BlocBuilder<VideoReadyCubit, VideoReadyState>(
          builder: (context, state) {
            if (state is VideoReadyLoading || state is VideoReadyInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is VideoReadyError) {
              return Center(child: Text(state.message, style: const TextStyle(color: Colors.white)));
            } else if (state is VideoReadyInitialized) {
              return Stack(
                children: [
                  Stack(
                    children: [
                      SizedBox.expand(
                        child: CameraPreview(state.cameraController),
                      ),
                      SizedBox.expand(
                        child: Container(
                          color: Colors.black.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  Opacity(
                    opacity: 0.7,
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context); // Quay lại màn hình trước đó
                                  },
                                  child: SvgPicture.asset(
                                    'assets/images/Button.svg',
                                    width: 100,
                                    height: 50,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              SvgPicture.asset(
                                'assets/images/IconReady.svg',
                                width: 165,
                                height: 165,
                              ),
                              const SizedBox(height: 50),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 40.0),
                                child: Text(
                                  'Keep the phone in a fixed position and record a video all around.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 40.0),
                                child: Text(
                                  'Holding your phone steady while rotating helps enhance the image quality during a 360 tour.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 85.0),
                                child: Text(
                                  'Move closer to the door to start your first point in the 360 tour',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 25),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Transform.translate(
                                  offset: const Offset(0, -30),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => VideoRecorderScreen(
                                            cameras: cameras,
                                            cameraController: state.cameraController,
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFCD9B4B),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(99),
                                        side: const BorderSide(
                                          color: Colors.white,
                                          width: 4,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                                    ),
                                    child: const Text(
                                      'READY TO RECORD',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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