import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:sensors_plus/sensors_plus.dart';

part 'video_recorder_state.dart';

class VideoRecorderCubit extends Cubit<VideoRecorderState> {
  final CameraController cameraController;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<CompassEvent>? _compassSubscription;
  Timer? _recordingTimer;
  final double _alpha = 0.5;

  VideoRecorderCubit(this.cameraController) : super(VideoRecorderState.initial());

  void initialize() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _setupAccelerometer();
    _setupCompass();
  }

  void _setupAccelerometer() {
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      double newTiltAngle = math.atan2(event.x, event.z);
      double magnitude = math.sqrt(event.x * event.x + event.z * event.z);
      if (magnitude < 1.0) return;

      double tiltAngle = _alpha * newTiltAngle + (1 - _alpha) * state.tiltAngle;
      tiltAngle = tiltAngle.clamp(-math.pi / 4, math.pi / 4);
      bool isTiltOk = tiltAngle.abs() < 0.15;

      emit(state.copyWith(tiltAngle: tiltAngle, isTiltOk: isTiltOk));
    });
  }

  void _setupCompass() {
    _compassSubscription = FlutterCompass.events?.listen((event) {
      if (!state.isRecording) return;
      double? currentDirection = event.heading;
      if (currentDirection == null) {
        print('Compass event null heading');
        return;
      }

      if (state.startDirection == null) {
        emit(state.copyWith(
          startDirection: currentDirection,
          previousDirection: currentDirection,
          accumulatedRotation: 0.0,
          showDirectionWarning: false,
        ));
        return;
      }

      double delta = currentDirection - state.previousDirection!;
      if (delta > 180) delta -= 360;
      if (delta < -180) delta += 360;

      double newAccumulatedRotation = state.accumulatedRotation + delta;
      bool showDirectionWarning = delta < -1;

      print('Accumulated Rotation: $newAccumulatedRotation, Is Recording: ${state.isRecording}');

      emit(state.copyWith(
        accumulatedRotation: newAccumulatedRotation,
        previousDirection: currentDirection,
        showDirectionWarning: showDirectionWarning,
      ));

      // Kích hoạt tự động dừng khi đạt 360 độ
      if (newAccumulatedRotation >= 360 && state.isRecording) {
        print('Calling stopRecording due to 360 degrees reached');
        stopRecording();
      }
    });
  }

  Future<void> startRecording() async {
    if (!cameraController.value.isRecordingVideo) {
      try {
        print('Starting video recording');
        await cameraController.startVideoRecording();
        _recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
          emit(state.copyWith(recordingSeconds: state.recordingSeconds + 1));
        });
        emit(state.copyWith(
          isRecording: true,
          recordingSeconds: 0,
          startDirection: null,
          previousDirection: null,
          accumulatedRotation: 0.0,
          showDirectionWarning: false,
        ));
      } catch (e) {
        print('Error starting recording: $e');
        emit(state.copyWith(error: 'Failed to start recording: $e'));
      }
    }
  }

  Future<File?> stopRecording() async {
    if (cameraController.value.isRecordingVideo) {
      try {
        print('Stopping video recording');
        final XFile video = await cameraController.stopVideoRecording();
        File videoFile = File(video.path);
        _recordingTimer?.cancel();
        print('Video stopped successfully: ${video.path}');
        emit(state.copyWith(
          isRecording: false,
          videoFile: videoFile,
        ));
        return videoFile;
      } catch (e) {
        print('Error stopping video: $e');
        emit(state.copyWith(error: 'Failed to stop recording: $e'));
        return null;
      }
    } else {
      print('Camera is not recording');
      return null;
    }
  }

  Future<void> handleBackButton() async {
    if (state.isRecording) {
      await stopRecording();
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Future<void> close() {
    _accelerometerSubscription?.cancel();
    _compassSubscription?.cancel();
    _recordingTimer?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    return super.close();
  }
}