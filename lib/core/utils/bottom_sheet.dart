import 'package:flutter/material.dart';
import 'package:schoolapp/core/core.dart';

class BottomSheetManager {
  static Future custom({required Widget content}) {
    final BuildContext context = UserRepository.shared.context!;
    return showModalBottomSheet(
      context: context,
      enableDrag: true,
      backgroundColor: AppColor.white,
      isDismissible: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: 18.padAll,
          child: Stack(
            children: [
              content,
              const Positioned(right: 0, top: 0, child: CloseIcon()),
            ],
          ),
        );
      },
    );
  }
}
