import 'package:flutter/material.dart';
import 'package:tech_app/Widgets/notifications-badge.dart';
import 'package:tech_app/util/colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onPressed;
  final List<Widget>? actions;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.onPressed,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isRTL = Directionality.of(context) == TextDirection.rtl;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (BuildContext context) {
            return Padding(
              padding: EdgeInsets.only(
                left: isRTL ? 0 : 7.0,
                right: isRTL ? 8.0 : 0,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  InkWell(
                    onTap: onPressed ?? () => Scaffold.of(context).openDrawer(),
                    borderRadius: BorderRadius.circular(5),
                    child: Container(
                      width: 47,
                      height: 47,
                      margin: EdgeInsets.only(
                        left: isRTL ? 0 : 8.0,
                        right: isRTL ? 8.0 : 0,
                      ),
                      decoration: BoxDecoration(
                        color: ColorsHelper.darkBlue,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const CircleAvatar(
                        radius: 22,
                        backgroundImage: AssetImage('assets/icons/formal.jpg'),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: isRTL ? null : -7,
                    left: isRTL ? -7 : null,
                    child: Material(
                      type: MaterialType.circle,
                      color: Colors.white,
                      elevation: 2,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: onPressed ?? () => Scaffold.of(context).openDrawer(),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.menu,
                            size: 13,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          const NotificationBadge(),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
