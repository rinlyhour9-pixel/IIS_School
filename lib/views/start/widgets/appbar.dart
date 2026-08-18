import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/views/views.dart';

dynamic _tapFunction({required index}) {
  switch (index) {
    case 0:
      return DialogManager.showCustom(DashboardFilterDialog());
  }
}

PreferredSizeWidget appBarWidget() {
  final StartController startCtl = Get.find<StartController>();

  return AppBar(
    title: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Image.asset(
            'assets/images/logo_title_05.png',
            width: 230,
            height: 190,
          ),
        ),
      ],
    ),
    elevation: 0,
    actions: [
      Obx(() {
        if (startCtl.selectedIndex.value != 2 &&
            startCtl.selectedIndex.value != 4) {
          return Padding(
            padding: 15.padRight,
            child: Row(
              children: [
                // InkWell(
                //   child: const Icon(Icons.notifications),
                //   onTap:
                //       () => _tapFunction(index: startCtl.selectedIndex.value),
                // ),
                InkWell(
                  child: Image.asset('assets/images/user_profile.png'),
                  onTap:
                      () => _tapFunction(index: startCtl.selectedIndex.value),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      }),
    ],
  );
}
