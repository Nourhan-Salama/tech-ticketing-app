
import 'package:flutter/material.dart';
import 'package:tech_app/util/colors.dart';
import 'package:tech_app/util/responsive-helper.dart';

class DataTableWidget extends StatelessWidget {
  final String title;
  final String userName;
  final String status;
  final Color statusColor;
  final bool showDivider;

  const DataTableWidget({
    super.key,
    required this.title,
    required this.userName,
    required this.status,
    required this.statusColor,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final textScale = ResponsiveHelper.textScaleFactor(context);

    return Row(
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
          child: IconButton(
            icon: Icon(Icons.more_vert,
                size: ResponsiveHelper.responsiveValue(
                  context: context,
                  mobile: 18,
                  tablet: 20,
                  desktop: 22,
                )),
            color: Colors.black,
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}