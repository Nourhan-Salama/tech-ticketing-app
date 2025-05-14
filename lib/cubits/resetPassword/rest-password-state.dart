abstract class ResetPasswordState {}

class ResetPasswordInitial extends ResetPasswordState {}

class ResetPasswordButtonState extends ResetPasswordState {
  final bool isEnabled;
  ResetPasswordButtonState(this.isEnabled);
}

class ResetPasswordLoading extends ResetPasswordState {}

class ResetPasswordSuccess extends ResetPasswordState {
  final String email;
  final String message;
  ResetPasswordSuccess(this.email, this.message);
}

class ResetPasswordFailure extends ResetPasswordState {
  final String message;
  ResetPasswordFailure(this.message);
}

