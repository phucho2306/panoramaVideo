part of 'center_compass_arrow_cubit.dart';

abstract class CenterCompassArrowState extends Equatable {
  const CenterCompassArrowState();

  @override
  List<Object?> get props => [];
}

class CenterCompassArrowInitial extends CenterCompassArrowState {}

class CenterCompassArrowUpdating extends CenterCompassArrowState {
  final double relativeDirection;
  final double totalRotation;
  final bool isComplete;

  const CenterCompassArrowUpdating({
    required this.relativeDirection,
    required this.totalRotation,
    required this.isComplete,
  });

  @override
  List<Object?> get props => [relativeDirection, totalRotation, isComplete];
}

class CenterCompassArrowError extends CenterCompassArrowState {
  final String message;

  const CenterCompassArrowError({required this.message});

  @override
  List<Object?> get props => [message];
}