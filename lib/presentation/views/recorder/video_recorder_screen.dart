import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:another_flushbar/flushbar.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:panorama_viewer/panorama_viewer.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../widgets/compass/compass_arrow.dart';
import '../../widgets/compass/arrow_360.dart';
import '../../widgets/painters/arrow_painter.dart';
import '../../widgets/painters/grid_painter.dart';
import '../image_view/image_view_screen.dart';
import '../loading/loading_screen.dart';

import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../video/video_preview_screen.dart';
import 'notification_video.dart';

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
  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;
  bool _isTiltOk = false;
  late CameraController _controller;
  bool _isRecording = false;
  bool _isUploading = false;
  File? _videoFile;
  double _tiltAngle = 0.0;

  Timer? _timer;
  final GlobalKey _tiltBarKey = GlobalKey();
  final GlobalKey _startRecordingButtonKey = GlobalKey();
  final GlobalKey _arrow360 = GlobalKey();
  final GlobalKey _compassArrow = GlobalKey();
  final GlobalKey<CenterCompassArrowState> _reset360 = GlobalKey();

  double _alpha = 0.5; // Tăng alpha để làm mượt hơn
  List<TargetFocus> targets = [];
  double _accumulatedRotation = 0.0;
  double? _startDirection;
  double? _previousDirection;
  StreamSubscription<CompassEvent>? _compassSubscription;
  bool _isDirectionCorrect = true;
  bool _showDirectionWarning = false;

  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  bool _isComplete = false;



  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  @override
  void initState() {
    super.initState();
    // Ẩn status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _controller = widget.cameraController;
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      setState(() {
        // Tính góc nghiêng dựa trên event.x và event.z
        double newTiltAngle = math.atan2(event.x, event.z);

        // Kiểm tra nếu thiết bị nghiêng quá mức (gần 90 độ)
        double magnitude = math.sqrt(event.x * event.x + event.z * event.z);
        if (magnitude < 1.0) { // Ngưỡng để phát hiện nghiêng lớn
          // Không cập nhật _tiltAngle nếu thiết bị nghiêng quá mức
          return;
        }

        // Áp dụng bộ lọc trung bình động
        _tiltAngle = _alpha * newTiltAngle + (1 - _alpha) * _tiltAngle;

        // Giới hạn _tiltAngle trong khoảng hợp lý (ví dụ: ±45 độ)
        _tiltAngle = _tiltAngle.clamp(-math.pi / 4, math.pi / 4);

        // Cập nhật trạng thái _isTiltOk
        _isTiltOk = _tiltAngle.abs() < 0.15;
      });
    });

    _compassSubscription = FlutterCompass.events!.listen((event) {
      if (!_isRecording) return;

      double? currentDirection = event.heading;
      if (currentDirection == null) return;

      if (_startDirection == null) {
        _startDirection = currentDirection;
        _previousDirection = currentDirection;
        _accumulatedRotation = 0;
        _isComplete = false;
        _showDirectionWarning = false;
        return;
      }

      double delta = currentDirection - _previousDirection!;
      if (delta > 180) delta -= 360;
      if (delta < -180) delta += 360;

      _accumulatedRotation += delta;
      _previousDirection = currentDirection;

      if (delta < -1) {
        setState(() {
          _showDirectionWarning = true;
        });
      } else {
        setState(() {
          _showDirectionWarning = false;
        });
      }

      if (!_isComplete && _accumulatedRotation >= 360) {
        setState(() {
          _isComplete = true;
        });
        _stopRecording();
      }

      if (_isComplete && _accumulatedRotation < 360) {
        setState(() {
          _isComplete = false;
        });
      }

      setState(() {});
    });
  }

  Future<void> _startRecording() async {
    _reset360.currentState?.reset();
    _startDirection = null;
    _previousDirection = null;
    _accumulatedRotation = 0;
    _isComplete = false;
    _recordingSeconds = 0;

    if (!_controller.value.isRecordingVideo) {
      await _controller.startVideoRecording();
      setState(() {
        _isRecording = true;
      });

      _recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          _recordingSeconds++;
        });
      });
    }
  }

  Future<void> _stopRecording() async {
    _reset360.currentState?.reset();

    try {
      if (_controller.value.isRecordingVideo) {
        final XFile video = await _controller.stopVideoRecording();

        setState(() {
          _videoFile = File(video.path);
          _isRecording = false;
        });

        _recordingTimer?.cancel();

        final result = await showStopNotifyBottomSheet(
          context: context,
          videoFile: _videoFile!,
          cameras: widget.cameras,
          cameraController: _controller,
        );

        if (result == 'Preview') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPreviewScreen(
                videoFile: _videoFile!,
                cameras: widget.cameras,
                cameraController: _controller,
              ),
            ),
          );
        } else if (result == 'Confirm') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoadingScreen(videoFile: _videoFile!),
            ),
          );
        }
      }
    } catch (e) {
      print("❌ Lỗi khi dừng quay: $e");
    }
  }


  Future<void> _handleBackButton() async {
    if (_isRecording) {
      try {
        if (_controller.value.isRecordingVideo) {
          await _controller.stopVideoRecording();
        }
      } catch (e) {
        print("❌ Error stopping recording on back: $e");
      }
      setState(() {
        _isRecording = false;
      });
      _recordingTimer?.cancel();
    }
    Navigator.pop(context);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _accelerometerSubscription.cancel();
    _compassSubscription?.cancel();
    _recordingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    int percentage = ((_accumulatedRotation / 360) * 100).toInt();
    String displayPercentage;
    if (percentage < 0) {
      displayPercentage = "0%";
    } else if (percentage > 100) {
      displayPercentage = "100%";
    } else {
      displayPercentage = "$percentage%";
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [

          CameraPreview(_controller),

          CustomPaint(size: Size.infinite, painter: GridPainter()),
          CustomPaint(
            size: Size.infinite,
            painter: ArrowPainter(
              color: _isTiltOk ? Color(0xFFFFCC00) : Color(0xFFFFFFFF),
            ),
          ),
          Transform.rotate(
            angle: _tiltAngle * 0.1, // Giảm biên độ xoay
            child: Center(
              child: Container(
                key: _tiltBarKey,
                width: 140,
                height: 4,
                color: _isTiltOk ? Color(0xFFFFCC00) : Color(0xFFFFFFFF),
              ),
            ),
          ),

          if (!_isRecording)
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              opacity: _showDirectionWarning ? 1.0 : 0.0,
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            bottom: 0, // Keep container at bottom to cover full area
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: Colors.black.withOpacity(0.4),
              child: Transform.translate(
                offset: Offset(0, -10), // Move content up by 10 pixels
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Visibility(
                      visible: _isRecording,
                      child: Flexible(
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.3,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
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
                    _isRecording
                        ? InkWell(
                      onTap: _stopRecording,
                      child: CenterCompassArrow(key: _reset360),
                    )
                        : InkWell(
                      onTap: _startRecording,
                      child: SvgPicture.asset(
                        'assets/images/Oval.svg',
                        width: 100,
                        height: 100,
                      ),
                    ),
                    Visibility(
                      visible: _isRecording,
                      child: Flexible(
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.3,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                margin: const EdgeInsets.only(right: 6),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Text(
                                _formatDuration(_recordingSeconds),
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
                      onTap: _handleBackButton,
                      child: SvgPicture.asset(
                        'assets/images/Button.svg',
                        width: 200,
                        height: 50,
                      ),
                    ),
                  ),
                  if (_isRecording)
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: CompassArrow(),
                    ),
                ],
              ),
            ),
          ),
          if (_isUploading)
            Container(
              color: Colors.black54,
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
