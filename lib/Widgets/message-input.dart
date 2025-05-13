import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MessageInputField extends StatefulWidget {
  final Function(String) onSend;

  const MessageInputField({super.key, required this.onSend});

  @override
  State<MessageInputField> createState() => _MessageInputFieldState();
}

class _MessageInputFieldState extends State<MessageInputField> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty && _selectedImage == null) return;

    if (text.isNotEmpty) {
      widget.onSend(text);
    }

    if (_selectedImage != null) {
      // Handle image sending
    }

    _controller.clear();
    setState(() => _selectedImage = null);
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => _pickImage(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Gallery'),
              onTap: () => _pickImage(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context);
    final image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_selectedImage != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                Image.file(
                  _selectedImage!,
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedImage = null),
                    child: const CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.black54,
                      child: Icon(Icons.close, size: 16, color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.attach_file),
                onPressed: _showAttachmentOptions,
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}





// import 'package:flutter/material.dart';
// import 'package:tech_app/util/const.dart';

// class MessageInputField extends StatefulWidget {
//   @override
//   State<MessageInputField> createState() => _MessageInputFieldState();
// }

// class _MessageInputFieldState extends State<MessageInputField> {
//   final controller = TextEditingController();

//   void sendMessage() {
//     if (controller.text.trim().isEmpty) return;
//     setState(() {
//       messages.insert(0, {'text': controller.text, 'isMe': true});
//     });
//     controller.clear();
//   }

//   void attachFile() {
   
//     print("Attach file clicked");
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         color: Colors.white,
//         child: Row(
//           children: [
        
//             IconButton(
//               icon: const Icon(Icons.attach_file, color: Colors.grey),
//               onPressed: attachFile,
//             ),

           
//             Expanded(
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade200,
//                   borderRadius: BorderRadius.circular(25),
//                 ),
//                 child: TextField(
//                   controller: controller,
//                   decoration: const InputDecoration(
//                     hintText: 'Type a message...',
//                     border: InputBorder.none,
//                   ),
//                   minLines: 1,
//                   maxLines: 4,
//                 ),
//               ),
//             ),

//             const SizedBox(width: 6),

        
//             CircleAvatar(
//               backgroundColor: Colors.blue,
//               radius: 22,
//               child: IconButton(
//                 icon: const Icon(Icons.send, color: Colors.white, size: 20),
//                 onPressed: sendMessage,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
