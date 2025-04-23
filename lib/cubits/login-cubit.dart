
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tech_app/cubits/login-state.dart';
import 'package:tech_app/services/login-service.dart';
import 'package:tech_app/services/service-profile.dart';


class LoginCubit extends Cubit<LoginState> {
  final AuthApi authApi;
  final FlutterSecureStorage secureStorage;
  final ProfileService? profileService;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginCubit({
    required this.authApi,
     this.profileService,
    FlutterSecureStorage? storage,
  })  : secureStorage = storage ?? const FlutterSecureStorage(),
        super(LoginState.initial()) {
    _loadRememberedCredentials();
    emailController.addListener(validateFields);
    passwordController.addListener(validateFields);
  }

  Future<void> _loadRememberedCredentials() async {
    try {
      final rememberedEmail = await secureStorage.read(key: 'remembered_email');
      final rememberedPassword = await secureStorage.read(key: 'remembered_password');
      final rememberMe = (await secureStorage.read(key: 'remember_me')) == 'true';

      if (rememberedEmail != null && rememberedPassword != null && rememberMe) {
        emailController.text = rememberedEmail;
        passwordController.text = rememberedPassword;
        emit(state.copyWith(
          rememberMe: true,
          isButtonEnabled: true,
        ));
      }
    } catch (e) {
      print('Error loading remembered credentials: $e');
    }
  }

  void togglePasswordVisibility() {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  void toggleRememberMe(bool value) {
    emit(state.copyWith(rememberMe: value));
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }

  void validateFields() {
    final email = emailController.text.trim();
    final password = passwordController.text;

    String? emailError, passwordError;
    bool isButtonEnabled = false;

    final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");

    if (email.isEmpty) {
      emailError = 'Email cannot be empty';
    } else if (!emailRegex.hasMatch(email)) {
      emailError = 'Invalid Email';
    }

    if (password.isEmpty) {
      passwordError = "Password cannot be empty";
    } else if (password.length < 8) {
      passwordError = "Password must be at least 8 characters";
    }

    isButtonEnabled = emailError == null &&
        passwordError == null &&
        email.isNotEmpty &&
        password.isNotEmpty;

    emit(state.copyWith(
      emailError: emailError,
      passwordError: passwordError,
      isButtonEnabled: isButtonEnabled,
    ));
  }

  Future<void> login() async {
    if (state.isLoading) return;

    emit(state.copyWith(
      isLoading: true,
      errorMessage: null,
      isSuccess: false,
    ));

    try {
      final response = await authApi.login(
        handle: emailController.text.trim(),
        password: passwordController.text,
      );

      print('API Response: $response');

      if (response.containsKey('code')) {
        if (response['code'] == 200) {
          // Save remember me preferences
          if (state.rememberMe) {
            await secureStorage.write(
              key: 'remembered_email',
              value: emailController.text.trim(),
            );
            await secureStorage.write(
              key: 'remembered_password',
              value: passwordController.text,
            );
            await secureStorage.write(
              key: 'remember_me',
              value: 'true',
            );
          } else {
            await secureStorage.delete(key: 'remembered_email');
            await secureStorage.delete(key: 'remembered_password');
            await secureStorage.write(
              key: 'remember_me',
              value: 'false',
            );
          }

          // Update state with user data
          emit(state.copyWith(
            isLoading: false,
            isSuccess: true,
            name: response['data']['user']['name'] ?? '',
            email: response['data']['user']['email'] ?? '',
          ));
          return;
        }

        // Handle error cases
        final errorMessage = response['message'] ?? 'Login failed';
        emit(state.copyWith(
          isLoading: false,
          errorMessage: errorMessage,
        ));
        return;
      }

      // Handle invalid response format
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Invalid server response format',
      ));
    } catch (e) {
      print('Login error: $e');
      String errorMessage = 'Login failed';
      if (e is FormatException) {
        errorMessage = 'Invalid server response';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = 'Network error. Please check your connection.';
      }

      emit(state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      ));
    }
  }

  @override
  Future<void> close() {
    emailController.removeListener(validateFields);
    passwordController.removeListener(validateFields);
    emailController.dispose();
    passwordController.dispose();
    return super.close();
  }
}



