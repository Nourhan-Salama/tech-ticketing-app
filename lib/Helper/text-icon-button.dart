
import 'package:flutter/material.dart';
import 'package:tech_app/util/colors.dart';

class TextIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isSelected;
  
  const TextIconButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? ColorsHelper.darkBlue : Colors.transparent, // Change background when selected
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.white : ColorsHelper.LightGrey),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : ColorsHelper.LightGrey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

