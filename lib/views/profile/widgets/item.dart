import 'package:flutter/material.dart';
import 'package:schoolapp/core/core.dart';

class ProfileItemWidget extends StatelessWidget {
  const ProfileItemWidget({
    super.key,
    required this.icon,
    required this.text,
    this.iconColor = AppColor.black,
    this.style = AppTextStyle.normalPrimaryRegular,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String text;
  final Color iconColor;
  final TextStyle style;
  final Function()? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColor.lightGrey,
                child: Icon(icon, color: iconColor),
              ),
              16.width,
              Expanded(child: Text(text, style: style)),
              if (trailing != null) ...[
                12.width,
                trailing!,
              ],
            ],
          ),
        ],
      ),
    );
  }
}
