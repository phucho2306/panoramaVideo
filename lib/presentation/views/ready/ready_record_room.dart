import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:panorama_capture/presentation/views/hotspot/confirm_hotspot.dart';

class VideoReadyScreenRoom extends StatefulWidget {
  final List<CameraDescription> cameras;
  final CameraController cameraController; // Nhận CameraController từ MyApp
  const VideoReadyScreenRoom({
    Key? key,
    required this.cameras,
    required this.cameraController,
  }) : super(key: key);

  @override
  State<VideoReadyScreenRoom> createState() => _VideoReadyScreenRoomState();
}

class _VideoReadyScreenRoomState extends State<VideoReadyScreenRoom> {
  late CameraController _controller;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.cameraController; // Sử dụng CameraController được truyền vào
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    if (!_controller.value.isInitialized) {
      await _controller.initialize();
    }
    if (mounted) {
      setState(() => _isCameraInitialized = true);
    }
  }

  @override
  void dispose() {
    // Không dispose _controller ở đây vì MyApp sẽ quản lý
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isCameraInitialized
          ? Stack(
        children: [
          Stack(
            children: [
              SizedBox.expand(
                child: CameraPreview(_controller),
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
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: Text(
                          'Please arrive at the selected room.',
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
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: Text(
                          'Keep the phone in a fixed position and record a video all around.',
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
                        padding: const EdgeInsets.symmetric(horizontal: 85.0),
                        child: Text(
                          'Tip: Holding your phone steady while rotating helps enhance the image quality during a 360 tour scan.',
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
                          offset: Offset(0, -30), // Move button up by 10 pixels
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ConfirmHotsPot(
                                   // cameras: widget.cameras,
                                   // cameraController: _controller,
                                  ),
                                ),
                              ).then((_) {
                                if (mounted) {
                                  setState(() {});
                                }
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFCD9B4B),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(99),
                                side: BorderSide(
                                  color: Colors.white,
                                  width: 4,
                                ),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
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
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      )
          : Center(child: CircularProgressIndicator()),
    );
  }
}