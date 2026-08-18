import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/constants/ui_constants.dart';
import 'package:schoolapp/core/extensions/int.dart';
import 'package:schoolapp/core/resources/locales.g.dart';
import 'package:schoolapp/views/start/widgets/custom_indicator.dart';
import 'package:schoolapp/views/start/widgets/customize_app_bar.dart';
import 'package:schoolapp/views/student_document/controller.dart';
import 'package:schoolapp/views/student_document/widget/student_document.dart';

class StudentDocumentView extends GetView<StudentDocumentController> {
  const StudentDocumentView({super.key});

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
              title: 'ព័ត៌មានប្រវត្ដិរូបសិស្ស',
              subTitle: 'លោកអ្នកអាចតាមដានពី ស្ថានភាពកូនៗ បាននៅខាងក្រោម៖',
              teacherSubTitle: LocaleKeys.studentDocumentTeacherSubTitle.tr,
            ),
          ),
          UIConstants.spacingSmall.height,
          const CustomIndicator(progress: 1 / 4),
          const StudentDocumentWidget(),
        ],
      ),
    );
  }
}
