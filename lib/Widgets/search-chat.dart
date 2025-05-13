import 'package:flutter/material.dart';

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
             CircleAvatar(
               radius: 25,
                backgroundImage: AssetImage('assets/icons/formal.jpg'),
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
