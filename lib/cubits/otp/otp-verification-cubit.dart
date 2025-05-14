import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:tech_app/Helper/enum-helper.dart';
import 'package:tech_app/cubits/otp/otp-verification-state.dart';
import 'package:tech_app/services/resend-otp-api.dart';
import 'package:tech_app/services/verify_user_auth.dart';


class OtpCubit extends Cubit<OtpState> {
  final VerifyUserApi _verifyUserApi;
  final ResendOtpApi _resendOtpApi;
  OtpType _otpType;
  Timer? _timer;
  int _secondsRemaining = 120;
  String _handle;
  String _code = '';

  OtpCubit(
    this._verifyUserApi,
    this._resendOtpApi,
    String handle,
    OtpType otpType,
  )   : _handle = handle,
        _otpType = otpType,
        super(OtpInitial(email: handle)) {
    startTimer();
  }

  // Add this method to update email and OTP type
  void updateEmailAndType(String email, OtpType otpType) {
    _handle = email;
    _otpType = otpType;
    emit(OtpInitial(email: email)); // Update the state with new email
    startTimer(); // Restart the timer when email/type changes
  }

  void startTimer() {
    _timer?.cancel();
    _secondsRemaining = 120;
    emit(OtpTimerRunning(_secondsRemaining));

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        emit(OtpTimerRunning(_secondsRemaining));
      } else {
        _timer?.cancel();
        emit(OtpTimerComplete());
      }
    });
  }

  void updateOtp(String code) {
    _code = code;
    emit(OtpEntered(code));
  }

  Future<void> verifyOtp() async {
    if (_code.isEmpty) {
      emit(OtpFailure("Please enter the OTP."));
      return;
    }
    
    emit(OtpLoading());
    try {
      print("🔹 Verifying OTP for handle: $_handle, code: $_code, type: $_otpType");

      final response = await _verifyUserApi.verifyUser(
        handle: _handle,
        code: _code,
        otpType: _otpType,
      );
      
      print("✅ OTP Verification Response: $response");

      if (response["success"]) {
        emit(OtpSuccess(response["message"], otpType: _otpType));
      } else {
        emit(OtpFailure(response["message"]));
      }
    } catch (e) {
      print("❌ OTP Verification Error: $e");
      emit(OtpFailure("An error occurred. Please try again."));
    }
  }

  Future<void> resendOtp() async {
    emit(OtpLoading());
    try {
      print("🔄 Resending OTP for handle: $_handle, type: $_otpType");

      final response = await _resendOtpApi.resendOtp(
        handle: _handle,
        otpType: _otpType,
      );
      
      print("✅ Resend OTP Response: $response");

      if (response["success"]) {
        startTimer();
        emit(OtpResent(response["message"]));
      } else {
        emit(OtpFailure(response["message"]));
      }
    } catch (e) {
      print("❌ Resend OTP Error: $e");
      emit(OtpFailure("Failed to resend OTP. Please try again."));
    }
  }

  void cancelTimer() {
    _timer?.cancel();
    emit(OtpTimerComplete());
  }

  @override
  Future<void> close() {
    cancelTimer();
    return super.close();
  }
}



