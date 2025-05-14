import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final String firstName;
  final String lastName;
  final String? imagePath;
  final File? imageFile;
  final String? firstNameError;
  final String? lastNameError;
  final String? errorMessage;
  final String? firstNameSuccess;
  final String? lastNameSuccess;
  final bool isLoading;
  final bool isSuccess;
  final bool isButtonEnabled;

  const ProfileLoaded({
    this.firstName = '',
    this.lastName = '',
    this.imagePath,
    this.imageFile,
    this.firstNameError,
    this.lastNameError,
    this.errorMessage,
    this.firstNameSuccess,
    this.lastNameSuccess,
    this.isLoading = false,
    this.isSuccess = false,
    this.isButtonEnabled = false,
  });

  ProfileLoaded copyWith({
    String? firstName,
    String? lastName,
    String? imagePath,
    File? imageFile,
    String? firstNameError,
    String? lastNameError,
    String? errorMessage,
    String? firstNameSuccess,
    String? lastNameSuccess,
    bool? isLoading,
    bool? isSuccess,
    bool? isButtonEnabled,
  }) {
    return ProfileLoaded(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      imagePath: imagePath ?? this.imagePath,
      imageFile: imageFile ?? this.imageFile,
      firstNameError: firstNameError ?? this.firstNameError,
      lastNameError: lastNameError ?? this.lastNameError,
      errorMessage: errorMessage ?? this.errorMessage,
      firstNameSuccess: firstNameSuccess ?? this.firstNameSuccess,
      lastNameSuccess: lastNameSuccess ?? this.lastNameSuccess,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      isButtonEnabled: isButtonEnabled ?? this.isButtonEnabled,
    );
  }

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        imagePath,
        imageFile,
        firstNameError,
        lastNameError,
        errorMessage,
        firstNameSuccess,
        lastNameSuccess,
        isLoading,
        isSuccess,
        isButtonEnabled,
      ];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);

  @override
  List<Object> get props => [message];
}

