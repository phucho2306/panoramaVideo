import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:sensors_plus/sensors_plus.dart';

part 'video_recorder_state.dart';

class VideoRecorderCubit extends Cubit<VideoRecorderState> {
  final CameraController cameraController;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<CompassEvent>? _compassSubscription;
  Timer? _recordingTimer;
  File? _videoFile;
  double _tiltAngle = 0.0;
  bool _isTiltOk = false;
  double _alpha = 0.2;
  double _accumulatedRotation = 0.0;
  double? _startDirection;
  double? _previousDirection;
  bool _isComplete = false;
  bool _showDirectionWarning = false;
  int _recordingSeconds = 0;

  VideoRecorderCubit({required this.cameraController})
      : super(VideoRecorderInitial()) {
    _initialize();
  }

  Future<void> _initialize() async {
    emit(VideoRecorderLoading());
    try {
      if (!cameraController.value.isInitialized) {
        await cameraController.initialize();
      }
    } catch (e) {
      emit(VideoRecorderError(message: "Error initializing camera: $e"));
      return;
    }

    _accelerometerSubscription = accelerometerEvents.listen((event) {
      double newTiltAngle = math.atan2(event.x, event.z);
      double magnitude = math.sqrt(event.x * event.x + event.z * event.z);
      if (magnitude < 1.0) return;

      _tiltAngle = _alpha * newTiltAngle + (1 - _alpha) * _tiltAngle;
      _tiltAngle = _tiltAngle.clamp(-math.pi / 4, math.pi / 4);
      _isTiltOk = _tiltAngle.abs() < 0.20;

      _emitCurrentState();
    });

    emit(VideoRecorderReady(
      cameraController: cameraController,
      isTiltOk: _isTiltOk,
      tiltAngle: _tiltAngle,
    ));
  }

  Future<void> startRecording() async {
    _startDirection = null;
    _previousDirection = null;
    _accumulatedRotation = 0;
    _isComplete = false;
    _recordingSeconds = 0;
    _videoFile = null;

    if (!cameraController.value.isRecordingVideo) {
      await cameraController.startVideoRecording();
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _recordingSeconds++;
        _emitCurrentState();
      });

      _compassSubscription = FlutterCompass.events!.listen((event) {
        double? currentDirection = event.heading;
        if (currentDirection == null) return;

        if (_startDirection == null) {
          _startDirection = currentDirection;
          _previousDirection = currentDirection;
          _accumulatedRotation = 0;
          _isComplete = false;
          _showDirectionWarning = false;
          _emitCurrentState();
          return;
        }

        double delta = currentDirection - _previousDirection!;
        if (delta > 180) delta -= 360;
        if (delta < -180) delta += 360;

        _accumulatedRotation += delta;
        _previousDirection = currentDirection;

        _showDirectionWarning = delta < -1;

        if (!_isComplete && _accumulatedRotation >= 360) {
          _isComplete = true;
          stopRecording();
        }

        if (_isComplete && _accumulatedRotation < 360) {
          _isComplete = false;
        }

        _emitCurrentState();
      });

      _emitCurrentState();
    }
  }

  Future<File?> stopRecording({bool isBackPressed = false}) async {
    try {
      if (cameraController.value.isRecordingVideo) {
        final XFile video = await cameraController.stopVideoRecording();
        _videoFile = File(video.path);
        _recordingTimer?.cancel();
        _compassSubscription?.cancel();
        if (!isBackPressed) {
          emit(VideoRecorderStopped(
            cameraController: cameraController,
            videoFile: _videoFile!,
          ));
        } else {
          emit(VideoRecorderReady(
            cameraController: cameraController,
            isTiltOk: _isTiltOk,
            tiltAngle: _tiltAngle,
          ));
        }
        return _videoFile;
      }
    } catch (e) {
      emit(VideoRecorderError(message: "Error stopping recording: $e"));
    }
    return null;
  }

  void _emitCurrentState() {
    if (cameraController.value.isRecordingVideo) {
      emit(VideoRecorderRecording(
        cameraController: cameraController,
        isTiltOk: _isTiltOk,
        tiltAngle: _tiltAngle,
        accumulatedRotation: _accumulatedRotation,
        isComplete: _isComplete,
        showDirectionWarning: _showDirectionWarning,
        recordingSeconds: _recordingSeconds,
        startDirection: _startDirection,
        previousDirection: _previousDirection,
      ));
    } else if (_videoFile != null && !cameraController.value.isRecordingVideo) {
      emit(VideoRecorderStopped(
        cameraController: cameraController,
        videoFile: _videoFile!,
      ));
    } else {
      emit(VideoRecorderReady(
        cameraController: cameraController,
        isTiltOk: _isTiltOk,
        tiltAngle: _tiltAngle,
      ));
    }
  }

  Future<void> handleBackButton() async {
    if (cameraController.value.isRecordingVideo) {
      await stopRecording(isBackPressed: true);
    }
    _accelerometerSubscription?.cancel();
    _compassSubscription?.cancel();
    _recordingTimer?.cancel();
  }

  String formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  @override
  Future<void> close() {
    _accelerometerSubscription?.cancel();
    _compassSubscription?.cancel();
    _recordingTimer?.cancel();
    return super.close();
  }


  Future<void> focusCamera() async {
    try {
      await cameraController.setFocusMode(FocusMode.auto);
    } catch (e) {
      print("Focus failed: $e");
      emit(VideoRecorderError(message: "Error focusing camera: $e"));
    }
  }

}