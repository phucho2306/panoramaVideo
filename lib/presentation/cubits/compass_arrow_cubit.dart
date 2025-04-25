import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'compass_arrow_state.dart';

class CompassArrowCubit extends Cubit<CompassArrowState> {
  CompassArrowCubit() : super(CompassArrowInitial()) {
    _initialize();
  }

  void _initialize() {
    emit(CompassArrowReady());
  }
}