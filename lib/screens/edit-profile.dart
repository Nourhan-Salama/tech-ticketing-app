import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tech_app/Helper/Custom-big-button.dart';
import 'package:tech_app/Helper/app-bar.dart';
import 'package:tech_app/Helper/custom-textField.dart';
import 'package:tech_app/Widgets/drawer.dart';
import 'package:tech_app/cubits/profile-cubit.dart';
import 'package:tech_app/cubits/prpfile-state.dart';
import 'package:tech_app/util/responsive-helper.dart';



class EditProfileScreen extends StatefulWidget {
  static const routeName = '/edit-profile';

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        context.read<ProfileCubit>().updateImage(File(pickedFile.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveHelper.responsivePadding(context);
    final verticalSpace = ResponsiveHelper.heightPercent(context, 0.025);
    final imageRadius = ResponsiveHelper.responsiveValue(
      context: context,
      mobile: 50,
      tablet: 70,
      desktop: 90,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: MyDrawer(),
      appBar: CustomAppBar(title: 'Edit Profile'),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded && state.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Profile updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final loadedState = state is ProfileLoaded
              ? state
              : ProfileLoaded(
                  firstName: '',
                  lastName: '',
                  email: '',
                  imagePath: '',
                );

          return SingleChildScrollView(
            padding: padding,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: verticalSpace),
                  _buildProfilePicture(context, loadedState.imageFile, loadedState.imagePath ?? '', imageRadius),
                  SizedBox(height: verticalSpace),

                  CustomTextField(
                    successText: loadedState.firstNameSuccess,
                    label: "First Name",
                    hintText: "Enter Your First Name",
                    prefixIcon: Icons.person,
                    errorText: loadedState.firstNameError,
                    controller: context.read<ProfileCubit>().firstNameController,
                    onChanged: (_) {
                      context.read<ProfileCubit>().validateFields();
                      _formKey.currentState?.validate();
                    },
                  ),
                  SizedBox(height: verticalSpace),

                  CustomTextField(
                    successText: loadedState.lastNameSuccess,
                    label: "Last Name",
                    hintText: "Enter Your Last Name",
                    prefixIcon: Icons.person_outline,
                    errorText: loadedState.lastNameError,
                    controller: context.read<ProfileCubit>().lastNameController,
                    onChanged: (_) {
                      context.read<ProfileCubit>().validateFields();
                      _formKey.currentState?.validate();
                    },
                  ),
                  SizedBox(height: verticalSpace),

                  CustomTextField(
                    successText: loadedState.emailSuccess,
                    label: "Email",
                    hintText: "Enter Your Email",
                    prefixIcon: Icons.email,
                    errorText: loadedState.emailError,
                    controller: context.read<ProfileCubit>().emailController,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) {
                      context.read<ProfileCubit>().validateFields();
                      _formKey.currentState?.validate();
                    },
                  ),
                  SizedBox(height: verticalSpace * 1.5),

                  SubmitButton(
                    buttonText: 'Submit',
                    isEnabled: loadedState.isButtonEnabled && !loadedState.isLoading,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<ProfileCubit>().saveProfile();
                      }
                    },
                  ),

                  if (loadedState.isLoading)
                    Padding(
                      padding: EdgeInsets.only(top: verticalSpace),
                      child: const CircularProgressIndicator(),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfilePicture(BuildContext context, File? file, String imagePath, double radius) {
    final ImageProvider imageProvider = file != null
        ? FileImage(file)
        : (imagePath.isNotEmpty
            ? FileImage(File(imagePath))
            : const AssetImage('assets/icons/avatar.png')) as ImageProvider;

    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _showImageOptions(context),
            child: CircleAvatar(
              radius: radius,
              backgroundImage: imageProvider,
            ),
          ),
          SizedBox(height: ResponsiveHelper.heightPercent(context, 0.01)),
          GestureDetector(
            onTap: () => _showImageOptions(context),
            child: Text(
              'Change Photo',
              style: TextStyle(
                fontSize: ResponsiveHelper.responsiveTextSize(context, 16),
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageOptions(BuildContext context) {
    final state = context.read<ProfileCubit>().state;
    if (state is! ProfileLoaded) return;

    showModalBottomSheet(
      context: context,
      builder: (_) => Wrap(
        children: [
          if (state.imageFile != null || (state.imagePath?.isNotEmpty ?? false))
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                context.read<ProfileCubit>().updateImage(null);
              },
            ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take a photo'),
            onTap: () async {
              Navigator.pop(context);
              await _pickImage(context, ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from gallery'),
            onTap: () async {
              Navigator.pop(context);
              await _pickImage(context, ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }
}
