import 'package:schoolapp/views/student_attendance/controller.dart';
import 'package:schoolapp/views/student_attendance/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import '../start/widgets/customize_app_bar.dart';

const _teal = Color(0xFF0F5C4E);

class StudentAttendanceView extends GetView<StudentAttendanceController> {
  const StudentAttendanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: CustomizeAppBar(
              title: LocaleKeys.studentAttendanceTitle.tr,
              subTitle: LocaleKeys.studentAttendanceSubTitle.tr,
              teacherSubTitle: LocaleKeys.studentAttendanceTeacherSubTitle.tr,
              trailing: const _AppBarDateFilter(),
            ),
          ),
          UIConstants.spacingSmall.height,
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.loadHistory,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  child: const StudentAttendanceHistoryCardWidget(),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.goToRecordAttendance,
        backgroundColor: _teal,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _AppBarDateFilter extends GetView<StudentAttendanceController> {
  const _AppBarDateFilter();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasDate = controller.selectedDate.value.isNotEmpty;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasDate)
            IconButton(
              onPressed: controller.clearDate,
              icon: const Icon(Icons.close, size: 20),
              tooltip: 'Clear date',
            ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () => controller.pickDate(context),
                icon: const Icon(Icons.calendar_today_outlined, size: 20),
                tooltip: 'Filter by date',
              ),
              if (hasDate)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColor.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      );
    });
  }
}
