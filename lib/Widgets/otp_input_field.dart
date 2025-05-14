
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tech_app/cubits/otp/otp-verification-cubit.dart';
import 'package:tech_app/cubits/otp/otp-verification-state.dart';
import 'package:tech_app/util/responsive-helper.dart';


class OtpInputField extends StatelessWidget {
  final TextEditingController controller;
  
  const OtpInputField({Key? key, required this.controller, required Null Function(dynamic value) onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OtpCubit, OtpState>(
      builder: (context, state) {
        return PinCodeTextField(
          appContext: context,
          length: 4,
          controller: controller,
          keyboardType: TextInputType.number,
          textStyle: TextStyle(
            fontSize: ResponsiveHelper.responsiveTextSize(context, 18),
            fontWeight: FontWeight.bold,
          ),
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(8),
            fieldHeight: ResponsiveHelper.responsiveValue(
              context: context,
              mobile: 45,
              tablet: 55,
            ),
            fieldWidth: ResponsiveHelper.responsiveValue(
              context: context,
              mobile: 40,
              tablet: 50,
            ),
            activeFillColor: Colors.white,
            inactiveColor: Colors.grey,
            selectedColor: Colors.deepPurple,
            activeColor: Colors.deepPurple,
          ),
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          onChanged: (value) {
            context.read<OtpCubit>().updateOtp(value);
          },
          onCompleted: (value) {
            context.read<OtpCubit>().verifyOtp();
          },
        );
      },
    );
  }
}
