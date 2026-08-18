import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/configs/configs.dart';
import 'package:schoolapp/core/widgets/month_filter_dropdown.dart';
import 'package:schoolapp/views/attendance/controller.dart';

class MonthFilterWidget extends StatelessWidget {
  final AttendanceController controller;

  const MonthFilterWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return LocalizedMonthFilterDropdown(
        selectedMonth: controller.selectedMonth.value,
        height: 40,
        backgroundColor: Colors.white,
        borderColor: AppColor.primaryColor,
        onSelected: controller.selectMonth,
      );
    });
  }
}
