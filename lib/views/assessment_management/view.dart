import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/views/assessment_management/controller.dart';
import 'package:schoolapp/views/assessment_management/widgets/card.dart';
import '../start/widgets/customize_app_bar.dart';

class AssessmentManagementView extends GetView<AssessmentManagementController> {
  const AssessmentManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: CustomizeAppBar(
              title: LocaleKeys.assessmentManagementTitle.tr,
              subTitle: LocaleKeys.assessmentManagementSubTitle.tr,
            ),
          ),
          UIConstants.spacingSmall.height,
          // No RefreshIndicator here: pull-to-refresh would silently destroy
          // scores typed but not yet saved.
          const Expanded(
            child: SingleChildScrollView(
              child: AssessmentManagementCardWidget(),
            ),
          ),
        ],
      ),
    );
  }
}
