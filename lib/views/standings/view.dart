import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/constants/ui_constants.dart';
import 'package:schoolapp/core/extensions/int.dart';
import 'package:schoolapp/core/resources/locales.g.dart';
import 'package:schoolapp/views/start/widgets/customize_app_bar.dart';
import 'package:schoolapp/views/views.dart';

class StandingsView extends GetView<StandingsController> {
  const StandingsView({super.key});

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
              title: 'ពិនិត្យលទ្ធផលពិន្ទុ',
              subTitle: 'លោកអ្នកអាចពិនិត្យលទ្ធផលកូនៗ​ បាននៅខាងក្រោមនេះ',
              teacherSubTitle: LocaleKeys.standingsTeacherSubTitle.tr,
            ),
          ),
          UIConstants.spacingSmall.height,
          Expanded(
            child: SingleChildScrollView(
              child: Container(child: StandingsCardWidget()),
            ),
          ),
        ],
      ),
    );
  }
}
