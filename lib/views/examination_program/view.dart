import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/routes.dart';
import '../start/widgets/customize_app_bar.dart';

/// Program picker shown when a teacher taps the Examination dashboard tile.
/// Only Khmer is wired up to a real Score Entry flow so far; Chinese
/// English shows the same "coming soon" dialog used elsewhere on the
/// dashboard for not-yet-built features.
class ExaminationProgramView extends StatelessWidget {
  const ExaminationProgramView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: CustomizeAppBar(
                title: LocaleKeys.examinationProgramTitle.tr,
              ),
            ),
            UIConstants.spacingSmall.height,
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _ProgramCard(
                    title: LocaleKeys.examinationProgramChineseEnglish.tr,
                    subtitle:
                        LocaleKeys.examinationProgramChineseEnglishSubtitle.tr,
                    onTap: () => Get.toNamed(Routes.assessmentManagement),
                  ),
                  const SizedBox(height: 16),
                  _ProgramCard(
                    title: LocaleKeys.examinationProgramKhmer.tr,
                    subtitle: LocaleKeys.examinationProgramKhmerSubtitle.tr,
                    onTap: () => Get.toNamed(Routes.scoreEntry),
                  ),
                  const SizedBox(height: 16),
                  _ProgramCard(
                    icon: Icons.leaderboard_outlined,
                    title: LocaleKeys.examinationProgramWeightedResult.tr,
                    subtitle:
                        LocaleKeys.examinationProgramWeightedResultSubtitle.tr,
                    onTap: () => Get.toNamed(Routes.weightedResult),
                  ),
                  const SizedBox(height: 16),
                  _ProgramCard(
                    icon: Icons.visibility_outlined,
                    title: LocaleKeys.examinationProgramViewScore.tr,
                    subtitle: LocaleKeys.examinationProgramViewScoreSubtitle.tr,
                    onTap: () => Get.toNamed(Routes.viewScore),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({
    this.icon = Icons.menu_book_outlined,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColor.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColor.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
