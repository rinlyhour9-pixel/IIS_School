import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/models/models.dart';
import 'package:schoolapp/views/weighted_result/controller.dart';
import 'package:schoolapp/views/weighted_result/widgets/widgets.dart';
// Imported directly rather than through views.dart, matching score_entry's
// card.dart — weighted_result is itself exported from that barrel, so
// going through it would create a cycle.
import 'package:schoolapp/views/start/controller.dart';
import '../start/widgets/customize_app_bar.dart';

class WeightedResultView extends GetView<WeightedResultController> {
  const WeightedResultView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: CustomizeAppBar(
              title: LocaleKeys.weightedResultTitle.tr,
              subTitle: LocaleKeys.weightedResultSubTitle.tr,
            ),
          ),
          UIConstants.spacingSmall.height,
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const WeightsSummary(),
                  const SizedBox(height: 16),
                  _FiltersCard(controller: controller),
                  const SizedBox(height: 16),
                  Obx(() {
                    // Read every observable synchronously, right here — the
                    // exact mistake found in Score Verification's first cut
                    // was passing a bare RxList into a separate widget's own
                    // build() call, which registers no subscription with
                    // this Obx at all.
                    final isLoading = controller.isLoading.value;
                    final hasFiltered = controller.hasFiltered.value;
                    final results = controller.results.toList(growable: false);

                    if (isLoading) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (!hasFiltered) {
                      return _Hint(
                        LocaleKeys.weightedResultSelectFiltersHint.tr,
                      );
                    }
                    if (results.isEmpty) {
                      return _Hint(LocaleKeys.weightedResultNoStudentsFound.tr);
                    }
                    return Column(
                      children: [
                        for (final item in results) ...[
                          WeightedResultCard(item: item),
                          if (item != results.last) const SizedBox(height: 12),
                        ],
                      ],
                    );
                  }),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(child: Text(text, style: AppTextStyle.normalGreyRegular)),
    );
  }
}

class _FiltersCard extends StatelessWidget {
  const _FiltersCard({required this.controller});

  final WeightedResultController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => AppIconDropdown<ClassModel>(
                    value: controller.selectedClass.value,
                    items: controller.classes.toList(),
                    itemLabel: (item) => item.className,
                    onChanged: controller.selectClass,
                    hintText: LocaleKeys.scoreEntryLevel.tr,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(
                  () => AppIconDropdown<SectionModel>(
                    value: controller.selectedSection.value,
                    items: controller.sections.toList(),
                    itemLabel: (item) => item.section,
                    onChanged: controller.selectSection,
                    hintText: LocaleKeys.section.tr,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(
            () => AppIconDropdown<SubjectModel>(
              value: controller.selectedSubject.value,
              items: controller.subjects.toList(),
              itemLabel: (item) => item.name,
              onChanged: controller.selectSubject,
              hintText: LocaleKeys.subject.tr,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => AppIconDropdown<WeightedResultPeriodType>(
                    value: controller.selectedResultType.value,
                    items: WeightedResultPeriodType.values,
                    itemLabel: (type) => type.label,
                    onChanged: controller.selectResultType,
                    hintText: LocaleKeys.scoreEntryResultType.tr,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(
                  () => AppIconDropdown<String>(
                    value: controller.selectedPeriod.value,
                    items: controller.periodItems,
                    itemLabel: (item) => item,
                    onChanged: controller.selectPeriod,
                    hintText:
                        controller.selectedResultType.value ==
                                WeightedResultPeriodType.quarterly
                            ? LocaleKeys.scoreEntryQuarter.tr
                            : LocaleKeys.scoreEntryMonth.tr,
                    emptyText: LocaleKeys.scoreEntrySelectResultTypeFirst.tr,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          const _TeacherRow(),
          const SizedBox(height: 16),
          _FilterButton(controller: controller),
        ],
      ),
    );
  }
}

class _TeacherRow extends StatelessWidget {
  const _TeacherRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColor.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Icon(
            Icons.perm_contact_calendar_outlined,
            color: AppColor.primary,
            size: 16,
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(LocaleKeys.teacher.tr, style: AppTextStyle.smallGreyRegular),
            const SizedBox(height: 2),
            Obx(() {
              final name = Get.find<StartController>().userName.value.trim();
              return Text(
                name.isEmpty ? 'N/A' : name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.midPrimaryBold,
              );
            }),
          ],
        ),
      ],
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.controller});

  final WeightedResultController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Obx(
        () => ElevatedButton.icon(
          onPressed: controller.isLoading.value ? null : controller.applyFilter,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primary,
            foregroundColor: AppColor.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: const Icon(Icons.filter_alt_outlined, size: 18),
          label: const Text('Filter', style: AppTextStyle.normalWhiteRegular),
        ),
      ),
    );
  }
}
