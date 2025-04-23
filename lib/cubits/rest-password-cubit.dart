import 'package:bloc/bloc.dart';
import 'package:tech_app/cubits/rest-password-state.dart';
import 'package:tech_app/services/send-forget-pass-api.dart';


class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  final SendForgetPassApi _api;
  
  ResetPasswordCubit(this._api) : super(ResetPasswordInitial());

  void updateButtonState(String email) {
    final isValid = _isEmailValid(email);
    emit(ResetPasswordButtonState(isValid));
  }

  Future<void> resetPassword(String email) async {
    if (!_isEmailValid(email)) {
      emit(ResetPasswordFailure("Please enter a valid email address."));
      return;
    }

    emit(ResetPasswordLoading());

    try {
      final response = await _api.sendForgetPass(handle: email);

      if (response["success"] == true) {
        emit(ResetPasswordSuccess(email, response["message"]));
      } else {
        emit(ResetPasswordFailure(response["message"] ?? "Something went wrong."));
      }
    } catch (e) {
      emit(ResetPasswordFailure("Failed to connect. Please try again later."));
    }
  }

  void clearState() {
    emit(ResetPasswordInitial());
  }
  
  bool _isEmailValid(String email) {
    final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return emailRegex.hasMatch(email);
  }
}
