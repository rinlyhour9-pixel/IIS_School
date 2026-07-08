import 'package:schoolapp/views/record_attendance/controller.dart';
import 'package:schoolapp/views/record_attendance/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import '../start/widgets/customize_app_bar.dart';

class RecordAttendanceView extends GetView<RecordAttendanceController> {
  const RecordAttendanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: CustomizeAppBar(
              title: LocaleKeys.attendanceRecordTitle.tr,
              subTitle: LocaleKeys.attendanceRecordSubTitle.tr,
              teacherSubTitle: LocaleKeys.attendanceRecordTeacherSubTitle.tr,
            ),
          ),
          UIConstants.spacingSmall.height,
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.loadStudentAttendance,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(child: const RecordAttendanceCardWidget()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
