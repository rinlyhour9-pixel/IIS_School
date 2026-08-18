import 'package:flutter/material.dart';
import 'package:schoolapp/core/core.dart';

class ContactItemWidget extends StatelessWidget {
  const ContactItemWidget({
    super.key,
    required this.icons,
    required this.label,
  });

  final IconData icons;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icons, color: AppColor.red, size: 30),
        const SizedBox(width: 20),
        Flexible(child: Text(label, style: AppTextStyle.normalPrimaryRegular)),
      ],
    );
  }
}
