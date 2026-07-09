import 'package:flutter/material.dart';
import 'package:schoolapp/core/core.dart';

class CircleIcon extends StatelessWidget {
  const CircleIcon({super.key, required this.onTap, required this.icon});

  final void Function()? onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: CircleAvatar(
        backgroundColor: AppColor.primary,
        child: Icon(icon, color: AppColor.white),
      ),
    );
  }
}
