
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tech_app/Helper/Custom-big-button.dart';
import 'package:tech_app/Helper/custom-textField.dart';
import 'package:tech_app/cubits/changePassword/change-pass-cubit.dart';
import 'package:tech_app/cubits/changePassword/change-pass-state.dart';
import 'package:tech_app/util/responsive-helper.dart';
import 'package:tech_app/util/translation-manager.dart';


class ChangePasswordScreen extends StatelessWidget {
  static const String routeName ='/change-password';
  final String handle;
  final String verificationCode;

  const ChangePasswordScreen({
    super.key,
    required this.handle,
    required this.verificationCode,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChangePasswordCubit(),
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: ResponsiveHelper.responsivePadding(context),
              child: BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
                listener: (context, state) {
                  if (state is ChangePasswordSuccess) {
                
                    context.read<ChangePasswordCubit>().clearFields();

               
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('password_reset_successful'.tr()),
                        backgroundColor: Colors.green,
                      ),
                    );

                    Future.delayed(Duration(seconds: 1), () {
                      Navigator.pushReplacementNamed(context, '/user-dashboard');
                    });
                  } else if (state is ChangePasswordFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  final cubit = context.read<ChangePasswordCubit>();
                  bool isButtonEnabled = state is ChangePasswordValid && state.isEnabled;
                  bool isLoading = state is ChangePasswordLoading;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'create_new_password_title'.tr(),
                        style: TextStyle(
                          fontSize: ResponsiveHelper.responsiveTextSize(context, 24),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: ResponsiveHelper.heightPercent(context, 0.02)),
                      Text(
                        'password_instruction'.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: ResponsiveHelper.responsiveTextSize(context, 16),
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: ResponsiveHelper.heightPercent(context, 0.04)),
                      CustomTextField(
                        label: 'new_password_label'.tr(),
                        obscureText: true,
                        hintText: 'new_password_hint'.tr(),
                        prefixIcon: Icons.lock,
                        controller: cubit.passwordController,
                        onChanged: (_) => cubit.validatePasswords(),
                      ),
                      SizedBox(height: ResponsiveHelper.heightPercent(context, 0.02)),
                      CustomTextField(
                        label: 'confirm_password_label'.tr(),
                        hintText: 'confirm_password_hint'.tr(),
                        prefixIcon: Icons.lock,
                        obscureText: true,
                        controller: cubit.confirmPasswordController,
                        onChanged: (_) => cubit.validatePasswords(),
                      ),
                      SizedBox(height: ResponsiveHelper.heightPercent(context, 0.04)),
                      SubmitButton(
                        isEnabled: isButtonEnabled && !isLoading,
                        onPressed: isButtonEnabled && !isLoading
                            ? () => cubit.resetPassword(
                                  handle: handle,
                                  verificationCode: verificationCode,
                                )
                            : null,
                        buttonText: isLoading ? 'loading_text'.tr() : 'sign_in_button'.tr(),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}



