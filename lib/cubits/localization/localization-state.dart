import 'package:equatable/equatable.dart';

abstract class LocalizationState extends Equatable {
  @override
  List<Object> get props => [];
}

class LocalizationInitial extends LocalizationState {}

class LocalizationLoading extends LocalizationState {}

class LocalizationSuccess extends LocalizationState {}

class LocalizationError extends LocalizationState {
  final String message;
  LocalizationError(this.message);

  @override
  List<Object> get props => [message];
}
