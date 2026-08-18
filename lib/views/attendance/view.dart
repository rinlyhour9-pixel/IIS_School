import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/constants/ui_constants.dart';
import 'package:schoolapp/core/extensions/int.dart';
import 'package:schoolapp/core/resources/locales.g.dart';
import 'package:schoolapp/views/attendance/controller.dart';
import 'package:schoolapp/views/attendance/widgets/month_filter.dart';
import 'package:schoolapp/views/attendance/widgets/widgets.dart';
import 'package:schoolapp/views/start/widgets/custom_indicator.dart';

import '../start/widgets/customize_app_bar.dart';

class AttendanceView extends GetView<AttendanceController> {
  const AttendanceView({super.key});

  void onSearch() async {
    if (!controller.formKey.currentState!.validate()) {
      return;
    }
    await controller.fetchTracking();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: CustomizeAppBar(
              title: LocaleKeys.attendance.tr,
              subTitle: LocaleKeys.attendanceSubTitle.tr,
              teacherSubTitle: LocaleKeys.attendanceTeacherSubTitle.tr,
              trailing: MonthFilterWidget(controller: controller),
            ),
          ),
          UIConstants.spacingSmall.height,
          const CustomIndicator(progress: 1 / 4),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.fetchAttendanceSummary,
              child: SingleChildScrollView(
                controller: controller.attendanceScrollCtl,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  decoration: const BoxDecoration(),
                  child: const AttendanceCardWidget(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
