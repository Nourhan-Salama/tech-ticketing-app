
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tech_app/Helper/enum-helper.dart';
import 'package:tech_app/cubits/otp-verification-cubit.dart';
import 'package:tech_app/cubits/otp-verification-state.dart';
import 'package:tech_app/util/colors.dart';
import 'package:tech_app/util/responsive-helper.dart';


class ResendOtpButton extends StatelessWidget {
  final String email;
  const ResendOtpButton({Key? key, required this.email, required OtpType otpType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OtpCubit, OtpState>(
      builder: (context, state) {
        if (state is OtpTimerRunning) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timer, color: ColorsHelper.darkBlue),
              SizedBox(width: 5),
              Text(
                "Resend OTP in ${state.secondsRemaining}s",
                style: TextStyle(
                  fontSize: ResponsiveHelper.responsiveTextSize(context, 16),
                  color: ColorsHelper.darkBlue,
                ),
              ),
            ],
          );
        }

        return TextButton(
          onPressed: () => context.read<OtpCubit>().resendOtp(),
          child: Text(
            'Resend OTP ?',
            style: TextStyle(
              fontSize: ResponsiveHelper.responsiveTextSize(context, 16),
              color: ColorsHelper.darkBlue,
            ),
          ),
        );
      },
    );
  }
}
