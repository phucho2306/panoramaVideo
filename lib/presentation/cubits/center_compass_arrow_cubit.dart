import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_compass/flutter_compass.dart';

part 'center_compass_arrow_state.dart';

class CenterCompassArrowCubit extends Cubit<CenterCompassArrowState> {
  double? _startDirection;
  double? _lastDirection;
  double _totalRotation = 0;
  bool _isComplete = false;
  StreamSubscription<CompassEvent>? _compassSub;
  int _skipCount = 3;


  CenterCompassArrowCubit() : super(CenterCompassArrowInitial()) {
    _initializeCompass();
  }

  // void _initializeCompass() {
  //   _compassSub = FlutterCompass.events!.listen((event) {
  //     double? direction = event.heading;
  //     if (direction == null) {
  //       emit(const CenterCompassArrowError(message: 'Compass data unavailable'));
  //       return;
  //     }
  //
  //     if (_startDirection == null) {
  //       _startDirection = direction;
  //       _lastDirection = direction;
  //       emit(const CenterCompassArrowUpdating(
  //         relativeDirection: 0,
  //         totalRotation: 0,
  //         isComplete: false,
  //       ));
  //       return;
  //     }
  //
  //     double delta = _calculateDelta(_lastDirection!, direction);
  //     _totalRotation += delta;
  //     _lastDirection = direction;
  //
  //     if (!_isComplete && _totalRotation >= 360) {
  //       _isComplete = true;
  //     }
  //
  //     if (_isComplete && _totalRotation < 360) {
  //       _isComplete = false;
  //     }
  //
  //     double relativeDirection = (direction - _startDirection!) % 360;
  //     if (relativeDirection > 180) relativeDirection -= 360;
  //     if (relativeDirection < -180) relativeDirection += 360;
  //
  //     emit(CenterCompassArrowUpdating(
  //       relativeDirection: relativeDirection,
  //       totalRotation: _totalRotation,
  //       isComplete: _isComplete,
  //     ));
  //   });
  // }


  void _initializeCompass() {
    _compassSub = FlutterCompass.events!.listen((event) {
      double? direction = event.heading;
      if (direction == null) {
        emit(const CenterCompassArrowError(message: 'Compass data unavailable'));
        return;
      }

      if (_skipCount > 0) {
        _skipCount--;
        return;
      }

      if (_startDirection == null) {
        _startDirection = direction;
        _lastDirection = direction;
        emit(const CenterCompassArrowUpdating(
          relativeDirection: 0,
          totalRotation: 0,
          isComplete: false,
        ));
        return;
      }

      double delta = _calculateDelta(_lastDirection!, direction);
      _totalRotation += delta;
      _lastDirection = direction;

      if (!_isComplete && _totalRotation >= 360) _isComplete = true;
      if (_isComplete && _totalRotation < 360) _isComplete = false;

      double relativeDirection = (direction - _startDirection!) % 360;
      if (relativeDirection > 180) relativeDirection -= 360;
      if (relativeDirection < -180) relativeDirection += 360;

      emit(CenterCompassArrowUpdating(
        relativeDirection: relativeDirection,
        totalRotation: _totalRotation,
        isComplete: _isComplete,
      ));
    });
  }


  double _calculateDelta(double last, double current) {
    double delta = current - last;
    if (delta > 180) {
      delta -= 360;
    } else if (delta < -180) {
      delta += 360;
    }
    return delta;
  }

  void reset() {
    _startDirection = null;
    _lastDirection = null;
    _totalRotation = 0;
    _isComplete = false;
    emit(const CenterCompassArrowUpdating(
      relativeDirection: 0,
      totalRotation: 0,
      isComplete: false,
    ));
  }

  @override
  Future<void> close() {
    _compassSub?.cancel();
    return super.close();
  }
}