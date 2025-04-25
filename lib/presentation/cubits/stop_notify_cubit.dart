import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:equatable/equatable.dart';

part 'stop_notify_state.dart';

class StopNotifyCubit extends Cubit<StopNotifyState> {
  StopNotifyCubit() : super(StopNotifyInitial());

  void selectPreview() {
    emit(const StopNotifyActionSelected('Preview'));
  }

  void selectConfirm() {
    emit(const StopNotifyActionSelected('Confirm'));
  }
}