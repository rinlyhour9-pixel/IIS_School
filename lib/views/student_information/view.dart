import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/views/views.dart';

class StudentInformationView extends GetView<StudentInformationController> {
  const StudentInformationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          Obx(() => _ProfileActionBar(title: _profileTitle())),
          Obx(() {
            if (controller.isTeacherMode.value) {
              return const TeacherProfileWidget();
            }
            if (controller.showParentProfile.value) {
              return const ParentProfileWidget();
            }
            return const StudentProfileWidget();
          }),
        ],
      ),
    );
  }

  String _profileTitle() {
    if (controller.isTeacherMode.value) {
      return LocaleKeys.teacherProfile.tr;
    }
    if (controller.showParentProfile.value) {
      return LocaleKeys.parentProfile.tr;
    }
    return LocaleKeys.studentProfile.tr;
  }
}

class _ProfileActionBar extends StatelessWidget {
  const _ProfileActionBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Color(0xFF006E6D),
              ),
            ),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF006E6D),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
