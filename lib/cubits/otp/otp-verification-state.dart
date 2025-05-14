import 'package:equatable/equatable.dart';
import 'package:tech_app/Helper/enum-helper.dart';


abstract class OtpState extends Equatable {
  const OtpState();
  @override
  List<Object> get props => [];
}

class OtpInitial extends OtpState {
  final String email;
  const OtpInitial({required this.email});
  @override
  List<Object> get props => [email];
}

class OtpLoading extends OtpState {}

class OtpSuccess extends OtpState {
  final String message;
  final OtpType otpType;
  const OtpSuccess(this.message, {required this.otpType});
  @override
  List<Object> get props => [message, otpType];
}

class OtpFailure extends OtpState {
  final String error;
  const OtpFailure(this.error);
  @override
  List<Object> get props => [error];
}

class OtpResent extends OtpState {
  final String message;
  const OtpResent(this.message);
  @override
  List<Object> get props => [message];
}

class OtpTimerRunning extends OtpState {
  final int secondsRemaining;
  const OtpTimerRunning(this.secondsRemaining);
  @override
  List<Object> get props => [secondsRemaining];
}

class OtpTimerComplete extends OtpState {}

class OtpEntered extends OtpState {
  final String otp;
  const OtpEntered(this.otp);
  @override
  List<Object> get props => [otp];
}