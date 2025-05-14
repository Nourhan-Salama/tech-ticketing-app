import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tech_app/cubits/profile/prpfile-state.dart';
import 'package:tech_app/services/service-profile.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileService profileService;

  ProfileCubit(this.profileService) : super(ProfileInitial()) {
    firstNameController.addListener(validateFields);
    lastNameController.addListener(validateFields);
    loadProfile();
  }

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  File? selectedImage;

  void validateFields() {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();

    String? firstNameError, lastNameError;
    String? firstNameSuccess, lastNameSuccess;

    if (firstName.isEmpty) {
      firstNameError = 'First name is required';
    } else if (firstName.length < 2) {
      firstNameError = 'First name is too short';
    } else {
      firstNameSuccess = "Looks good!";
    }

    if (lastName.isEmpty) {
      lastNameError = 'Last name is required';
    } else if (lastName.length < 2) {
      lastNameError = 'Last name is too short';
    } else {
      lastNameSuccess = "Looks good!";
    }

    final isButtonEnabled = firstNameError == null && lastNameError == null;

    emit(ProfileLoaded(
      firstName: firstName,
      lastName: lastName,
      imageFile: selectedImage,
      imagePath: selectedImage?.path,
      firstNameError: firstNameError,
      lastNameError: lastNameError,
      firstNameSuccess: firstNameSuccess,
      lastNameSuccess: lastNameSuccess,
      isButtonEnabled: isButtonEnabled,
    ));
  }

  Future<void> updateImage(File? imageFile) async {
    try {
      selectedImage = imageFile;
      
      if (imageFile == null) {
        await profileService.removeUserImage();
      }

      if (state is ProfileLoaded) {
        final currentState = state as ProfileLoaded;
        emit(currentState.copyWith(
          imageFile: imageFile,
          imagePath: imageFile?.path,
        ));
      }
    } catch (e) {
      emit(ProfileError('Failed to update image: ${e.toString()}'));
      await Future.delayed(const Duration(milliseconds: 200));
      if (state is ProfileLoaded) {
        emit((state as ProfileLoaded).copyWith());
      }
    }
  }

  Future<void> saveProfile() async {
  if (state is! ProfileLoaded || !(state as ProfileLoaded).isButtonEnabled)
    return;

  final currentState = state as ProfileLoaded;
  emit(currentState.copyWith(isLoading: true));

  try {
    await profileService.updateProfile(
      firstName: currentState.firstName,
      lastName: currentState.lastName,
      avatar: currentState.imageFile,
    );

    await profileService.saveUserData(
      firstName: currentState.firstName,
      lastName: currentState.lastName,
      imagePath: currentState.imageFile?.path ?? currentState.imagePath,
    );

    // Change here: Set isLoading to false when successful
    emit(currentState.copyWith(
      isSuccess: true,
      isLoading: false,  // This ensures the loading indicator disappears
      isButtonEnabled: true,  // Allow the user to submit again if needed
    ));
  } catch (e) {
    emit(ProfileError(e.toString()));
    await Future.delayed(const Duration(milliseconds: 200));
    // Make sure we return to a non-loading state even after an error
    emit(currentState.copyWith(isLoading: false));
  }
}
  Future<void> loadProfile() async {
    emit(ProfileLoading());
    try {
      final profileData = await profileService.getProfile();
      final fullName = profileData['user']['name'] ?? "User";
      final imagePath = profileData['user']['avatar'] ?? '';

      final nameParts = fullName.split(" ");
      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final lastName =
          nameParts.length > 1 ? nameParts.sublist(1).join(" ") : '';

      firstNameController.text = firstName;
      lastNameController.text = lastName;

      emit(ProfileLoaded(
        firstName: firstName,
        lastName: lastName,
        imagePath: imagePath,
        isButtonEnabled: true,
      ));
    } catch (e) {
      try {
        final localData = await profileService.loadUserData();
        final fullName = localData['name'] ?? '';
        final nameParts = fullName.split(' ');
        final firstName = nameParts.isNotEmpty ? nameParts.first : '';
        final lastName =
            nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
        final imagePath = localData['image_path'] ?? '';

        firstNameController.text = firstName;
        lastNameController.text = lastName;

        emit(ProfileLoaded(
          firstName: firstName,
          lastName: lastName,
          imagePath: imagePath,
          isButtonEnabled: true,
        ));
      } catch (e) {
        emit(ProfileLoaded(
          firstName: '',
          lastName: '',
          imagePath: '',
          isButtonEnabled: false,
        ));
      }
    }
  }

  @override
  Future<void> close() {
    firstNameController.dispose();
    lastNameController.dispose();
    return super.close();
  }
}