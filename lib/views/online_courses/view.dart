import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/resources/locales.g.dart';
import 'package:schoolapp/views/start/widgets/custom_indicator.dart';
import 'package:schoolapp/views/start/widgets/customize_app_bar.dart';
import 'package:schoolapp/views/views.dart';

class OnlineCoursesView extends GetView<OnlineCoursesController> {
  const OnlineCoursesView({super.key});

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
            child: CustomizeAppBar(
              title: 'Online Courses',
              subTitle: 'Learn from video lessons and course materials.',
              teacherSubTitle: LocaleKeys.onlineCoursesTeacherSubTitle.tr,
            ),
          ),
          CustomIndicator(progress: 1 / 4),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(),
              child: const OnlineCoursesCardWidget(),
            ),
          ),
        ],
      ),
    );
  }
}
