
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tech_app/Helper/Custom-big-button.dart';
import 'package:tech_app/Helper/enum-helper.dart';
import 'package:tech_app/Helper/resend-otp-button.dart';
import 'package:tech_app/Widgets/otp_input_field.dart';
import 'package:tech_app/cubits/otp/otp-verification-cubit.dart';
import 'package:tech_app/cubits/otp/otp-verification-state.dart';
import 'package:tech_app/screens/chande-password.dart';
import 'package:tech_app/screens/login.dart';
import 'package:tech_app/services/resend-otp-api.dart';
import 'package:tech_app/services/verify_user_auth.dart';
import 'package:tech_app/util/colors.dart';
import 'package:tech_app/util/responsive-helper.dart';
import 'package:tech_app/util/translation-manager.dart';

class OtpVerificationPage extends StatelessWidget {
  static const routeName = '/otp-page';
  final String email;
  final OtpType otpType;
  final TextEditingController otpController = TextEditingController();

  OtpVerificationPage({
    Key? key,
    required this.email,
    required this.otpType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OtpCubit(
        context.read<VerifyUserApi>(),
        context.read<ResendOtpApi>(),
        email,
        otpType,
      ),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: ResponsiveHelper.screenHeight(context) -
                    ResponsiveHelper.safeAreaTop(context) -
                    ResponsiveHelper.safeAreaBottom(context),
              ),
              child: Padding(
                padding: ResponsiveHelper.responsivePadding(context),
                child: BlocListener<OtpCubit, OtpState>(
                  listener: (context, state) {
                    if (state is OtpSuccess) {
                      _handleSuccess(context, state);
                    } else if (state is OtpFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.error),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: ResponsiveHelper.heightPercent(context, 0.05)),
                      _buildHeaderIcon(context),
                      SizedBox(height: ResponsiveHelper.heightPercent(context, 0.03)),
                      _buildTitle(context),
                      SizedBox(height: ResponsiveHelper.heightPercent(context, 0.02)),
                      _buildDescription(context),
                      SizedBox(height: ResponsiveHelper.heightPercent(context, 0.04)),
                      _buildOtpInputField(context),
                      SizedBox(height: ResponsiveHelper.heightPercent(context, 0.04)),
                      _buildVerifyButton(context),
                      SizedBox(height: ResponsiveHelper.heightPercent(context, 0.02)),
                      _buildResendButton(context),
                      SizedBox(height: ResponsiveHelper.heightPercent(context, 0.05)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIcon(BuildContext context) {
    return Icon(
      otpType == OtpType.verification ? Icons.verified_user : Icons.lock_reset,
      size: ResponsiveHelper.responsiveValue(
        context: context,
        mobile: 60,
        tablet: 80,
        desktop: 100,
      ),
      color: ColorsHelper.darkBlue,
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      otpType == OtpType.verification
          ? "verifyYourAccount".tr()
          : "Reset Your Password".tr(),
      style: TextStyle(
        fontSize: ResponsiveHelper.responsiveTextSize(context, 20),
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.widthPercent(context, 0.05),
      ),
      child: Text(
        otpType == OtpType.verification
            ? "enterVerificationCode".tr()
            : "enterCodeToResetPassword".tr(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: ResponsiveHelper.responsiveTextSize(context, 14),
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildOtpInputField(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.widthPercent(context, 0.1),
      ),
      child: OtpInputField(
        controller: otpController,
        onChanged: (value) {
          context.read<OtpCubit>().updateOtp(value);
        },
      ),
    );
  }

  Widget _buildVerifyButton(BuildContext context) {
    return BlocBuilder<OtpCubit, OtpState>(
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.widthPercent(context, 0.1),
          ),
          child: SubmitButton(
            buttonText: otpType == OtpType.verification
                ? 'VerifvAccount'.tr()
                : 'continue'.tr(),
            isEnabled: state is! OtpLoading,
            isLoading: state is OtpLoading,
            onPressed: () {
              context.read<OtpCubit>().verifyOtp();
            },
          ),
        );
      },
    );
  }

  Widget _buildResendButton(BuildContext context) {
    return ResendOtpButton(
      email: email,
      otpType: otpType,
    );
  }

  void _handleSuccess(BuildContext context, OtpSuccess state) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.message),
        backgroundColor: Colors.green,
      ),
    );

    if (state.otpType == OtpType.verification) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChangePasswordScreen(
            handle: email,
            verificationCode: otpController.text,
          ),
        ),
      );
    }
  }
}




