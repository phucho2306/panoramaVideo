import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:panorama_capture/presentation/cubit/video_ready/video_ready_cubit.dart';

class VideoReadyWidget extends StatelessWidget {
  final List<CameraDescription> cameras;
  final CameraController cameraController;
  final VoidCallback onReadyPressed;

  const VideoReadyWidget({
    Key? key,
    required this.cameras,
    required this.cameraController,
    required this.onReadyPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VideoReadyCubit(cameraController)..initializeCamera(),
      child: BlocBuilder<VideoReadyCubit, VideoReadyState>(
        builder: (context, state) {
          if (state.error != null) {
            return Center(child: Text(state.error!));
          }
          return state.isCameraInitialized
              ? Stack(
                  children: [
                    Stack(
                      children: [
                        SizedBox.expand(
                          child: CameraPreview(cameraController),
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SvgPicture.asset(
                                  'assets/images/Button.svg',
                                  width: 100,
                                  height: 50,
                                  fit: BoxFit.contain,
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
                              SizedBox(height: 50),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40.0),
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
                              SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40.0),
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
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 85.0),
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
                              SizedBox(height: 25),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Transform.translate(
                                  offset: Offset(0, -30),
                                  child: ElevatedButton(
                                    onPressed: onReadyPressed,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFFCD9B4B),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(99),
                                        side: BorderSide(
                                          color: Colors.white,
                                          width: 4,
                                        ),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 30, vertical: 20),
                                    ),
                                    child: Text(
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
                  ],
                )
              : Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}