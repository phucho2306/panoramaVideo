part of 'compass_arrow_cubit.dart';

abstract class CompassArrowState extends Equatable {
  const CompassArrowState();

  @override
  List<Object?> get props => [];
}

class CompassArrowInitial extends CompassArrowState {}

class CompassArrowReady extends CompassArrowState {}