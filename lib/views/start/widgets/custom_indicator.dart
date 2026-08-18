import 'package:flutter/material.dart';
import 'package:schoolapp/core/configs/configs.dart';

class CustomIndicator extends StatelessWidget {
  final double progress;

  const CustomIndicator({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 3,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade300, // background
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(color: AppColor.red),
          ),
        ),
      ),
    );
  }
}
