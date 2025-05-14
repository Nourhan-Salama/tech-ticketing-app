import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tech_app/Helper/Custom-big-button.dart';
import 'package:tech_app/Helper/app-bar.dart';
import 'package:tech_app/Helper/custom-textField.dart';
import 'package:tech_app/Widgets/drawer.dart';
import 'package:tech_app/cubits/profile/profile-cubit.dart';
import 'package:tech_app/cubits/profile/prpfile-state.dart';
import 'package:tech_app/util/colors.dart';
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
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80, // Compress image to save memory
      );
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        if (file.existsSync()) {
          context.read<ProfileCubit>().updateImage(file);
        } else {
          _showErrorSnackBar(context, 'Selected image file does not exist');
        }
      }
    } catch (e) {
      // Close loading dialog if still showing
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      _showErrorSnackBar(context, 'Failed to pick image: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
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
                backgroundColor: ColorsHelper.darkBlue,
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
    ImageProvider? imageProvider;
    
    if (file != null && file.existsSync()) {
      imageProvider = FileImage(file);
    } else if (imagePath.isNotEmpty) {
      if (imagePath.startsWith('http')) {
        // Handle network image
        imageProvider = NetworkImage(imagePath);
      } else {
        // Handle local file path
        final imageFile = File(imagePath);
        if (imageFile.existsSync()) {
          imageProvider = FileImage(imageFile);
        }
      }
    }
    
    // Default to asset image if no valid image is found
    imageProvider ??= const AssetImage('assets/icons/avatar.png');

    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _showImageOptions(context),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: ColorsHelper.darkBlue.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: radius,
                backgroundImage: imageProvider,
                backgroundColor: Colors.white,
              ),
            ),
          ),
          SizedBox(height: ResponsiveHelper.heightPercent(context, 0.01)),
          GestureDetector(
            onTap: () => _showImageOptions(context),
            child: Text(
              'Change Photo',
              style: TextStyle(
                fontSize: ResponsiveHelper.responsiveTextSize(context, 16),
                color: ColorsHelper.darkBlue,
                fontWeight: FontWeight.w500,
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Profile Photo',
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Divider(),
            if (state.imageFile != null || (state.imagePath?.isNotEmpty ?? false))
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Photo'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<ProfileCubit>().updateImage(null);
                },
              ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: ColorsHelper.darkBlue),
              title: const Text('Take a photo'),
              onTap: () async {
                Navigator.pop(context);
                await _pickImage(context, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: ColorsHelper.darkBlue),
              title: const Text('Choose from gallery'),
              onTap: () async {
                Navigator.pop(context);
                await _pickImage(context, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}
