import 'package:schoolapp/views/attendance_record/controller.dart';
import 'package:schoolapp/views/attendance_record/widgets/attendence_record_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import '../start/widgets/customize_app_bar.dart';

class AttendanceRecordView extends GetView<AttendanceRecordController> {
  const AttendanceRecordView({super.key});

  void onSearch() async {
    if (!controller.formKey.currentState!.validate()) {
      return;
    }
    await controller.loadAttendanceLogs();
  }

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
              onRefresh: controller.loadAttendanceLogs,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(child: const AttendenceRecordCardWidget()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
