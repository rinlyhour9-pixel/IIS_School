import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/views/score_verification/controller.dart';
import 'package:schoolapp/views/score_verification/widgets/widgets.dart';
import '../start/widgets/customize_app_bar.dart';

class ScoreVerificationView extends GetView<ScoreVerificationController> {
  const ScoreVerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: CustomizeAppBar(
              title: LocaleKeys.scoreVerificationTitle.tr,
              subTitle: LocaleKeys.scoreVerificationSubTitle.tr,
            ),
          ),
          UIConstants.spacingSmall.height,
          Expanded(
            child: Obx(() {
              // Read (not just pass along) each RxList synchronously inside
              // this callback — Obx only tracks observables actually read
              // within its own builder. PendingScoreSection iterates `items`
              // in its own separate build() call, outside this scope, so
              // handing it the bare RxList reference registers no
              // subscription at all: GetX flags that as "improper use of
              // GetX" and the list silently never rebuilds on verify.
              final examinationItems = controller.examinationItems.toList(
                growable: false,
              );
              final quarterItems = controller.quarterItems.toList(
                growable: false,
              );
              final assessmentItems = controller.assessmentItems.toList(
                growable: false,
              );

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                children: [
                  PendingScoreSection(
                    category: PendingScoreCategory.examination,
                    title: LocaleKeys.scoreVerificationPendingExam.tr,
                    description: LocaleKeys.scoreVerificationPendingExamDesc.tr,
                    items: examinationItems,
                    controller: controller,
                  ),
                  const SizedBox(height: 16),
                  PendingScoreSection(
                    category: PendingScoreCategory.quarter,
                    title: LocaleKeys.scoreVerificationPendingQuarter.tr,
                    description:
                        LocaleKeys.scoreVerificationPendingQuarterDesc.tr,
                    items: quarterItems,
                    controller: controller,
                  ),
                  const SizedBox(height: 16),
                  PendingScoreSection(
                    category: PendingScoreCategory.assessment,
                    title: LocaleKeys.scoreVerificationPendingAssessment.tr,
                    description:
                        LocaleKeys.scoreVerificationPendingAssessmentDesc.tr,
                    items: assessmentItems,
                    controller: controller,
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
