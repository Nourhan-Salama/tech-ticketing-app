import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tech_app/cubits/profile-cubit.dart';
import 'package:tech_app/cubits/prpfile-state.dart';


class SearchChat extends StatelessWidget {
  const SearchChat({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Search Bar Row
          Row(
            children: [
              /// Profile Image from ProfileCubit
              BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, state) {
                  String? imagePath;
                  if (state is ProfileLoaded) {
                    imagePath = state.imagePath;
                  }

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CircleAvatar(
                      backgroundImage: (imagePath != null && imagePath.isNotEmpty)
                          ? FileImage(File(imagePath)) as ImageProvider
                          : const AssetImage('assets/icons/avatar.png'),
                      radius: 25,
                    ),
                  );
                },
              ),
              
              const SizedBox(width: 10), // Spacing

              /// Search Bar
              Expanded(
                child: TextField(
                  onSubmitted: (value) {},
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    hintText: 'Search',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.green),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10), // Space before "Chats" title
          const Text(
            'Chats',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          ),
        ],
      ),
    );
  }
}

