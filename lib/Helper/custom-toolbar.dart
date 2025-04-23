
import 'package:flutter/material.dart';
import 'package:tech_app/util/colors.dart';

class CustomToolbar extends StatelessWidget {
  final VoidCallback onBoldToggle;
  final VoidCallback onItalicToggle;
  final VoidCallback onUnderlineToggle;
  final VoidCallback onBulletedToggle;
  final VoidCallback onLinkPressed;
  final bool isBold;
  final bool isItalic;
  final bool isUnderlined;
  final bool isBulleted;

  CustomToolbar({
    required this.onBoldToggle,
    required this.onItalicToggle,
    required this.onUnderlineToggle,
    required this.onBulletedToggle,
    required this.onLinkPressed,
    required this.isBold,
    required this.isItalic,
    required this.isUnderlined,
    required this.isBulleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 194, 193, 193),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildToolbarButton(Icons.link, false, onLinkPressed),
          _buildToolbarButton(Icons.format_bold, isBold, onBoldToggle),
          _buildToolbarButton(Icons.format_italic, isItalic, onItalicToggle),
          _buildToolbarButton(Icons.format_underline, isUnderlined, onUnderlineToggle),
          _buildToolbarButton(Icons.format_list_bulleted, isBulleted, onBulletedToggle),
        ],
      ),
    );
  }

  
  Widget _buildToolbarButton(IconData icon, bool isActive, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive ? ColorsHelper.darkBlue.withOpacity(0.2) : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isActive ? ColorsHelper.darkBlue : Colors.grey[700], 
            size: 20,
          ),
        ),
      ),
    );
  }
}





