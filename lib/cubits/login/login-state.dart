import 'package:equatable/equatable.dart';

class LoginState extends Equatable {
  final String? emailError;
  final String? passwordError;
  final String? errorMessage;
  final bool isButtonEnabled;
  final bool isLoading;
  final bool isSuccess;
  final bool obscurePassword;
  final bool rememberMe;
  final String name;
  final String email;

  const LoginState({
    this.email = '',
    this.name = '',
    this.emailError,
    this.passwordError,
    this.errorMessage,
    this.isButtonEnabled = false,
    this.isLoading = false,
    this.isSuccess = false,
    this.obscurePassword = true,
    this.rememberMe = false,
  });

  factory LoginState.initial() => const LoginState();

  LoginState copyWith({
    String? emailError,
    String? passwordError,
    String? errorMessage,
    bool? isButtonEnabled,
    bool? isLoading,
    bool? isSuccess,
    bool? obscurePassword,
    bool? rememberMe, 
      String? email,  name,
  }) {
    return LoginState(
      emailError: emailError,
      passwordError: passwordError,
      errorMessage: errorMessage,
      isButtonEnabled: isButtonEnabled ?? this.isButtonEnabled,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }

  @override
  List<Object?> get props => [
        emailError,
        passwordError,
        errorMessage,
        isButtonEnabled,
        isLoading,
        isSuccess,
        obscurePassword,
        rememberMe,
      ];
}



