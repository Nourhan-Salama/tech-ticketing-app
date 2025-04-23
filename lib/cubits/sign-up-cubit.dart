
// import 'package:flutter/material.dart';
// import 'package:bloc/bloc.dart';
// import 'package:tech_app/cubits/sign-up-state.dart';
// import 'package:tech_app/services/auth-service-register.dart';


// class SignUpCubit extends Cubit<SignUpState> {
//     SignUpCubit() : super(SignUpState.initial()) {
//     // Add listeners to all controllers
//     firstNameController.addListener(validateFields);
//     lastNameController.addListener(validateFields);
//     emailController.addListener(validateFields);
//     passwordController.addListener(validateFields);
//     confirmPasswordController.addListener(validateFields);
//   }

//   final TextEditingController firstNameController = TextEditingController();
//   final TextEditingController lastNameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController confirmPasswordController = TextEditingController();

//   void togglePasswordVisibility() {
//     emit(state.copyWith(obscurePassword: !state.obscurePassword));
//   }

//   void toggleConfirmPasswordVisibility() {
//     emit(state.copyWith(obscureConfirmPassword: !state.obscureConfirmPassword));
//   }

//   void validateFields() {
//     final firstName = firstNameController.text.trim();
//     final lastName = lastNameController.text.trim();
//     final email = emailController.text.trim();
//     final password = passwordController.text;
//     final confirmPassword = confirmPasswordController.text;

//     String? firstNameError, lastNameError, emailError, passwordError, confirmPasswordError;
//     String? firstNameSuccess, lastNameSuccess, emailSuccess, passwordSuccess, confirmPasswordSuccess;

//     if (firstName.isEmpty) {
//       firstNameError = 'First name is required';
//     } else if (firstName.length < 2) {
//       firstNameError = 'First name is too short';
//     } else {
//       firstNameSuccess = "Looks good!";
//     }

//     if (lastName.isEmpty) {
//       lastNameError = 'Last name is required';
//     } else if (lastName.length < 2) {
//       lastNameError = 'Last name is too short';
//     } else {
//       lastNameSuccess = "Looks good!";
//     }

//     final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
//     if (email.isEmpty) {
//       emailError = 'Email cannot be empty';
//     } else if (!emailRegex.hasMatch(email)) {
//       emailError = 'Invalid Email';
//     } else {
//       emailSuccess = "Valid Email!";
//     }

//     if (password.isEmpty) {
//       passwordError = "Password cannot be empty";
//     } else if (password.length < 8) {
//       passwordError = "Password must be at least 8 characters";
//     } else {
//       passwordSuccess = "Strong password!";
//     }

//     if (confirmPassword.isEmpty) {
//       confirmPasswordError = "Please confirm your password";
//     } else if (password != confirmPassword) {
//       confirmPasswordError = "Passwords do not match";
//     } else {
//       confirmPasswordSuccess = "Passwords match!";
//     }

//     final isButtonEnabled = firstName.isNotEmpty &&
//         lastName.isNotEmpty &&
//         email.isNotEmpty &&
//         password.isNotEmpty &&
//         confirmPassword.isNotEmpty &&
//         firstNameError == null &&
//         lastNameError == null &&
//         emailError == null &&
//         passwordError == null &&
//         confirmPasswordError == null;

//     emit(state.copyWith(
//       firstNameError: firstNameError,
//       lastNameError: lastNameError,
//       emailError: emailError,
//       passwordError: passwordError,
//       confirmPasswordError: confirmPasswordError,
//       firstNameSuccess: firstNameSuccess,
//       lastNameSuccess: lastNameSuccess,
//       emailSuccess: emailSuccess,
//       passwordSuccess: passwordSuccess,
//       confirmPasswordSuccess: confirmPasswordSuccess,
//       isButtonEnabled: isButtonEnabled,
//       errorMessage: null,
//       email: email, 
//     ));
//   }

//   Future<void> submitForm(BuildContext context) async {
//     validateFields();

//     if (!state.isButtonEnabled) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please fill all fields correctly'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     emit(state.copyWith(
//       isLoading: true,
//       errorMessage: null,
//     ));

//     try {
//       // Debug print to see what's being sent
//       print("Attempting to register with email: ${emailController.text.trim()}");
//       AuthService authService = AuthService();
//       final result = await authService.register(
//         firstNameController.text.trim(),
//         lastNameController.text.trim(),
//         emailController.text.trim(),
//         passwordController.text,
//         confirmPasswordController.text, 
//       );

//       print("✅ API Response: ${result}");

//       if (result["success"]) {
//         emit(state.copyWith(isSuccess: true, isLoading: false));

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(result["message"]),
//             backgroundColor: Colors.green,
//           ),
//         );
//       } else {
//         emit(state.copyWith(isLoading: false, errorMessage: result["message"]));

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(result["message"]),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } catch (e) {
//       emit(state.copyWith(
//         isLoading: false,
//         errorMessage: "Registration failed: ${e.toString()}",
//       ));

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Registration failed: ${e.toString()}"),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   @override
//   Future<void> close() {
//     firstNameController.dispose();
//     lastNameController.dispose();
//     emailController.dispose();
//     passwordController.dispose();
//     confirmPasswordController.dispose();
//     return super.close();
//   }
// }




