import 'package:flutter/material.dart';

class MessageInputField extends StatefulWidget {
  final Function(String) onSend;

  const MessageInputField({super.key, required this.onSend});

  @override
  State<MessageInputField> createState() => _MessageInputFieldState();
}

class _MessageInputFieldState extends State<MessageInputField> {
  final TextEditingController _controller = TextEditingController();
  bool _isComposing = false;

  void _handleSubmit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    widget.onSend(text);
    _controller.clear();
    setState(() => _isComposing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (text) {
                setState(() => _isComposing = text.trim().isNotEmpty);
              },
              onSubmitted: (_) => _handleSubmit(),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.send,
              color: _isComposing ? Colors.blue : Colors.grey,
            ),
            onPressed: _isComposing ? _handleSubmit : null,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}




