import 'package:flutter/material.dart';
import 'package:tech_app/util/colors.dart';
import 'package:tech_app/util/responsive-helper.dart';

class DataTableWidget extends StatelessWidget {
  final String title;
  final String userName;
  final String status;
  final Color statusColor;
  final bool showDivider;
  final int ticketId;
  final VoidCallback? onChatPressed;
  final VoidCallback? onFinishPressed;

  const DataTableWidget({
    super.key,
    required this.title,
    required this.userName,
    required this.status,
    required this.statusColor,
    required this.ticketId,
    this.showDivider = false,
    this.onChatPressed,
    this.onFinishPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final textScale = ResponsiveHelper.textScaleFactor(context);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: ResponsiveHelper.responsiveTextSize(
                        context,
                        isMobile ? 14 : 16,
                      ) * textScale,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.responsiveValue(
                    context: context,
                    mobile: 4,
                    tablet: 6,
                    desktop: 8,
                  )),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        color: ColorsHelper.LightGrey,
                        size: ResponsiveHelper.responsiveValue(
                          context: context,
                          mobile: 14,
                          tablet: 16,
                          desktop: 18,
                        ),
                      ),
                      SizedBox(width: ResponsiveHelper.responsiveValue(
                        context: context,
                        mobile: 4,
                        tablet: 6,
                        desktop: 8,
                      )),
                      Text(
                        userName,
                        style: TextStyle(
                          color: ColorsHelper.LightGrey,
                          fontSize: ResponsiveHelper.responsiveTextSize(
                            context,
                            isMobile ? 12 : 14,
                          ) * textScale,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.responsiveValue(
                    context: context,
                    mobile: 8,
                    tablet: 12,
                    desktop: 16,
                  ),
                  vertical: ResponsiveHelper.responsiveValue(
                    context: context,
                    mobile: 4,
                    tablet: 6,
                    desktop: 8,
                  ),
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.responsiveValue(
                      context: context,
                      mobile: 8,
                      tablet: 10,
                      desktop: 12,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: ResponsiveHelper.responsiveTextSize(
                        context,
                        isMobile ? 12 : 14,
                      ) * textScale,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  size: ResponsiveHelper.responsiveValue(
                    context: context,
                    mobile: 18,
                    tablet: 20,
                    desktop: 22,
                  ),
                  color: Colors.black,
                ),
                onSelected: (value) {
                  if (value == 'chat' && onChatPressed != null) {
                    onChatPressed!();
                  } else if (value == 'finish' && onFinishPressed != null) {
                    _showFinishConfirmationDialog(context);
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'chat',
                    child: Row(
                      children: [
                        Icon(Icons.chat, color: ColorsHelper.darkBlue),
                        SizedBox(width: 8),
                        Text(
                          'Chat',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.responsiveTextSize(
                              context,
                              isMobile ? 14 : 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'finish',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'Close Ticket',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.responsiveTextSize(
                              context,
                              isMobile ? 14 : 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        // if (showDivider)
        //   Divider(
        //     height: ResponsiveHelper.responsiveValue(
        //       context: context,
        //       mobile: 16,
        //       tablet: 20,
        //       desktop: 24,
        //     ),
        //     thickness: 1,
        //     color: Colors.grey[200],
        //   ),
      ],
    );
  }

  void _showFinishConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirm Close Ticket',
            style: TextStyle(
              fontSize: ResponsiveHelper.responsiveTextSize(
                context,
                18,
              ),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to close this ticket?',
            style: TextStyle(
              fontSize: ResponsiveHelper.responsiveTextSize(
                context,
                16,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: ColorsHelper.darkBlue,
                  fontSize: ResponsiveHelper.responsiveTextSize(
                    context,
                    16,
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (onFinishPressed != null) {
                  onFinishPressed!();
                }
              },
              child: Text(
                'Confirm',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: ResponsiveHelper.responsiveTextSize(
                    context,
                    16,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}