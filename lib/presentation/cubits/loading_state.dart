part of 'loading_cubit.dart';

abstract class LoadingState extends Equatable {
  const LoadingState();

  @override
  List<Object?> get props => [];
}

class LoadingInitial extends LoadingState {}

class LoadingInProgress extends LoadingState {}

class LoadingSuccess extends LoadingState {
  final String base64Image;

  const LoadingSuccess({required this.base64Image});

  @override
  List<Object?> get props => [base64Image];
}

class LoadingError extends LoadingState {
  final String message;

  const LoadingError({required this.message});

  @override
  List<Object?> get props => [message];
}