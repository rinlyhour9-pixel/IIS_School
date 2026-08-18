import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';

class CloseWidget extends StatelessWidget {
  const CloseWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: 2.padAll,
              decoration: const BoxDecoration(
                color: AppColor.grey,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: AppColor.black),
            ),
          ),
        ),
      ],
    );
  }
}
