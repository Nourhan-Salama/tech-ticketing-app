// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:tech_app/cubits/create-new-state.dart';
// import 'package:tech_app/cubits/get-ticket-cubits.dart';
// import 'package:tech_app/models/ticket-model.dart';

// class CreateNewCubit extends Cubit<CreateNewState> {
//   final TextEditingController firstNameController = TextEditingController();
//   final TextEditingController lastNameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController departmentController = TextEditingController();
//   final TextEditingController descriptionController = TextEditingController();

//   CreateNewCubit() : super(CreateNewState.initial()) {
//     _setupListeners();
//   }

//   void _setupListeners() {
//     firstNameController.addListener(_debouncedValidation);
//     lastNameController.addListener(_debouncedValidation);
//     emailController.addListener(_debouncedValidation);
//     departmentController.addListener(_debouncedValidation);
//     descriptionController.addListener(_debouncedValidation);
//   }

//   Timer? _debounceTimer;
//   void _debouncedValidation() {
//     _debounceTimer?.cancel();
//     _debounceTimer = Timer(const Duration(milliseconds: 500), validateFields);
//   }

//   void validateFields() {
//     final firstName = firstNameController.text.trim();
//     final lastName = lastNameController.text.trim();
//     final email = emailController.text.trim();
//     final department = departmentController.text.trim();
//     final description = descriptionController.text.trim();

//     // Clear previous states first
//     var newState = state.copyWith(
//       firstNameError: null,
//       lastNameError: null,
//       emailError: null,
//       descriptionError: null,
//       departmentError: null,
//       firstNameSuccess: null,
//       lastNameSuccess: null,
//       emailSuccess: null,
//       descriptionSuccess: null,
//       departmentSuccess: null,
//     );

//     // First Name validation
//     if (firstName.isNotEmpty) {
//       if (firstName.length < 2) {
//         newState = newState.copyWith(firstNameError: 'At least 2 characters');
//       } else {
//         newState = newState.copyWith(firstNameSuccess: 'Looks good!');
//       }
//     }

//     // Last Name validation
//     if (lastName.isNotEmpty) {
//       if (lastName.length < 2) {
//         newState = newState.copyWith(lastNameError: 'At least 2 characters');
//       } else {
//         newState = newState.copyWith(lastNameSuccess: 'Looks good!');
//       }
//     }

//     // Email validation
//     final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
//     if (email.isNotEmpty) {
//       if (!emailRegex.hasMatch(email)) {
//         newState = newState.copyWith(emailError: 'Invalid email format');
//       } else {
//         newState = newState.copyWith(emailSuccess: 'Valid email');
//       }
//     }

//     // Department validation
//     if (department.isEmpty) {
//       newState = newState.copyWith(departmentError: 'Please select department');
//     } else {
//       newState = newState.copyWith(departmentSuccess: 'Selected');
//     }

//     // Description validation
//     if (description.isNotEmpty) {
//       if (description.length < 10) {
//         newState = newState.copyWith(descriptionError: 'At least 10 characters');
//       } else {
//         newState = newState.copyWith(descriptionSuccess: 'Good description');
//       }
//     }

//     // Update button state
//     newState = newState.copyWith(
//       isButtonEnabled: firstName.isNotEmpty &&
//           lastName.isNotEmpty &&
//           emailRegex.hasMatch(email) &&
//           department.isNotEmpty &&
//           description.length >= 10,
//     );

//     emit(newState);
//   }

//   Future<void> submitForm(BuildContext context) async {
//     if (!state.isButtonEnabled) {
//       emit(state.copyWith(
//         submissionError: 'Please complete all fields correctly',
//       ));
//       return;
//     }

//     emit(state.copyWith(isLoading: true));

//     try {
//       final newTicket = TicketModel(
//         firstName: firstNameController.text.trim(),
//         lastName: lastNameController.text.trim(),
//         email: emailController.text.trim(),
//         department: departmentController.text.trim(),
//         description: descriptionController.text.trim(),
//         status: "Pending",
//         statusColor: Colors.grey,
//         createdAt: DateTime.now(),
//       );

//       context.read<TicketsCubit>().addTicket(newTicket);
      
//       emit(state.copyWith(
//         isLoading: false,
//         isSuccess: true,
//       ));
//     } catch (e) {
//       emit(state.copyWith(
//         isLoading: false,
//         submissionError: 'Submission failed: ${e.toString()}',
//       ));
//     }
//   }

//   @override
//   Future<void> close() {
//     _debounceTimer?.cancel();
//     firstNameController.dispose();
//     lastNameController.dispose();
//     emailController.dispose();
//     departmentController.dispose();
//     descriptionController.dispose();
//     return super.close();
//   }
// }







