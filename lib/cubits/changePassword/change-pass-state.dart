abstract class ChangePasswordState {}

class ChangePasswordInitial extends ChangePasswordState {}

class ChangePasswordValid extends ChangePasswordState {
  final bool isEnabled;
  ChangePasswordValid(this.isEnabled);
}

class ChangePasswordLoading extends ChangePasswordState {}

class ChangePasswordSuccess extends ChangePasswordState {}

class ChangePasswordFailure extends ChangePasswordState {
  final String message;
  ChangePasswordFailure(this.message);
}
