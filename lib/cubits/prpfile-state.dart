// lib/cubits/profile_state.dart
import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final String imagePath;
  final String firstName;
  final String lastName;
  final String email;

  const ProfileLoaded({
    required this.imagePath,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  @override
  List<Object?> get props => [imagePath, firstName, lastName, email];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);

  @override
  List<Object> get props => [message];
}
