import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/models/models.dart';
import 'package:schoolapp/views/score_entry/controller.dart';
import 'package:schoolapp/views/score_entry/widgets/score_layout.dart';
import 'package:schoolapp/views/score_entry/widgets/student_column.dart';
// Imported directly rather than through views.dart: score_entry is itself
// exported from that barrel, so going through it would create a cycle.
import 'package:schoolapp/views/start/controller.dart';

class ScoreEntryCardWidget extends GetView<ScoreEntryController> {
  const ScoreEntryCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FiltersCard(controller: controller),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (!controller.hasFiltered.value) {
              return _TableHint(LocaleKeys.scoreEntrySelectFiltersHint.tr);
            }
            if (controller.students.isEmpty) {
              return _TableHint(LocaleKeys.scoreEntryNoStudentsFound.tr);
            }
            if (controller.subjects.isEmpty) {
              return _TableHint(LocaleKeys.scoreEntryNoSubjects.tr);
            }
            return _ScoreTable(
              students: controller.students.toList(),
              subjects: controller.subjects.toList(),
            );
          }),
          const SizedBox(height: 20),
          _SaveButton(controller: controller),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _TableHint extends StatelessWidget {
  const _TableHint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(child: Text(text, style: AppTextStyle.normalGreyRegular)),
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

class _FiltersCard extends StatelessWidget {
  const _FiltersCard({required this.controller});

  final ScoreEntryController controller;

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
                    isLoading: controller.isLoadingOptions.value,
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
                    isLoading: controller.isLoadingOptions.value,
                    hintText: LocaleKeys.section.tr,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => AppIconDropdown<ResultType>(
                    value: controller.selectedResultType.value,
                    items: ResultType.values,
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
                                ResultType.quarterly
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

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.controller});

  final ScoreEntryController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Obx(
        () => ElevatedButton.icon(
          onPressed:
              controller.isLoading.value ? null : () => _onPressed(context),
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

  Future<void> _onPressed(BuildContext context) async {
    // Re-filtering rebuilds every column, which discards anything typed but
    // not yet saved — so confirm first when there is something to lose.
    if (controller.hasUnsavedScores) {
      final discard = await showDialog<bool>(
        context: context,
        builder:
            (dialogContext) => AlertDialog(
              backgroundColor: AppColor.white,
              surfaceTintColor: AppColor.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text('Discard unsaved scores?'),
              content: const Text(
                'You have scores that have not been saved. Filtering again '
                'will clear them.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(LocaleKeys.cancel.tr),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFD32F2F),
                  ),
                  child: const Text('Discard'),
                ),
              ],
            ),
      );
      if (discard != true) return;
    }
    await controller.applyFilter();
  }
}

/// The transposed score sheet.
///
/// Subjects run down the frozen left column; each student is a column inside
/// a single horizontal scroll view. Both halves use the same fixed heights
/// from score_layout.dart so they can never shear.
///
/// StatefulWidget because it owns the horizontal ScrollController — hanging
/// that on the GetX controller risks `Scrollbar` asserting on a detached
/// controller across route transitions.
class _ScoreTable extends StatefulWidget {
  const _ScoreTable({required this.students, required this.subjects});

  final List<StudentScoreColumn> students;
  final List<SubjectModel> subjects;

  @override
  State<_ScoreTable> createState() => _ScoreTableState();
}

class _ScoreTableState extends State<_ScoreTable> {
  final ScrollController _horizontalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Every header/row height is a fixed constant, so the table's total height
    // is exact. The seam below needs it explicitly: in a Row with
    // crossAxisAlignment.start a height-less Container gets loose vertical
    // constraints and would collapse to zero, making the divider invisible.
    final tableHeight =
        kHeaderHeight +
        (widget.subjects.length * kRowHeight) +
        kScrollbarLaneHeight;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.white,
          border: Border.all(color: AppColor.divider),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SubjectColumn(subjects: widget.subjects),
            // Sells the "frozen" affordance — without it the pinned block
            // reads as part of the scrolling table.
            Container(width: 1, height: tableHeight, color: AppColor.divider),
            Expanded(
              child: Scrollbar(
                controller: _horizontalController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _horizontalController,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: scrollableWidthFor(widget.students.length),
                    child: _StudentColumns(
                      students: widget.students,
                      subjects: widget.subjects,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Frozen left column: an empty corner cell, then one label per subject.
class _SubjectColumn extends StatelessWidget {
  const _SubjectColumn({required this.subjects});

  final List<SubjectModel> subjects;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: kSubjectColWidth,
      child: Column(
        children: [
          // Empty corner above the subject labels, matching the header height.
          Container(
            height: kHeaderHeight,
            decoration: const BoxDecoration(
              color: AppColor.backgroundColor,
              border: Border(bottom: BorderSide(color: AppColor.divider)),
            ),
          ),
          ...subjects.map(
            (subject) => Container(
              height: kRowHeight,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: const BoxDecoration(
                color: AppColor.backgroundColor,
                border: Border(bottom: BorderSide(color: AppColor.divider)),
              ),
              child: Text(
                subject.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.normalPrimarySemiBold,
              ),
            ),
          ),
          // Matches the scrollbar lane on the scrolling side.
          const SizedBox(height: kScrollbarLaneHeight),
        ],
      ),
    );
  }
}

/// Scrolling right side: one column per student, each with a three-line
/// header (admission no, name, gender) above its score cells.
class _StudentColumns extends StatelessWidget {
  const _StudentColumns({required this.students, required this.subjects});

  final List<StudentScoreColumn> students;
  final List<SubjectModel> subjects;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: kHeaderHeight,
          child: Row(
            children:
                students
                    .map((student) => _StudentHeaderCell(student: student))
                    .toList(),
          ),
        ),
        ...subjects.map(
          (subject) => SizedBox(
            height: kRowHeight,
            child: Row(
              children:
                  students
                      .map(
                        (student) =>
                            _ScoreCell(student: student, subject: subject),
                      )
                      .toList(),
            ),
          ),
        ),
        // Lane for the always-visible horizontal scrollbar.
        const SizedBox(height: kScrollbarLaneHeight),
      ],
    );
  }
}

class _StudentHeaderCell extends StatelessWidget {
  const _StudentHeaderCell({required this.student});

  final StudentScoreColumn student;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: kStudentColWidth,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColor.backgroundColor,
        border: Border(
          right: BorderSide(color: AppColor.divider),
          bottom: BorderSide(color: AppColor.divider),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            student.admissionNo,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.smallGreyRegular,
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              student.studentName,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.normalPrimarySemiBold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            student.gender,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.smallGreyRegular,
          ),
        ],
      ),
    );
  }
}

/// A single editable score cell for one (student, subject) pair.
///
/// Deliberately has no `Obx`: the student's TextEditingController is the
/// source of truth and `TextField` listens to it internally, so typing
/// rebuilds nothing above `EditableText`.
class _ScoreCell extends StatelessWidget {
  const _ScoreCell({required this.student, required this.subject});

  final StudentScoreColumn student;
  final SubjectModel subject;

  @override
  Widget build(BuildContext context) {
    final scoreController = student.controllerFor(subject.id);

    return Container(
      width: kStudentColWidth,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: AppColor.divider),
          bottom: BorderSide(color: AppColor.divider),
        ),
      ),
      child:
          scoreController == null
              ? const SizedBox.shrink()
              : TextField(
                controller: scoreController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  const MaxScoreInputFormatter(kSubjectMaxScore),
                ],
                style: AppTextStyle.smallRegular,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: '-',
                  filled: true,
                  fillColor: AppColor.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 10,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColor.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColor.primary),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColor.divider),
                  ),
                ),
              ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.controller});

  final ScoreEntryController controller;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Obx(
        () => ElevatedButton.icon(
          onPressed: controller.isSubmitting.value ? null : controller.save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primary,
            foregroundColor: AppColor.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon:
              controller.isSubmitting.value
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColor.white,
                    ),
                  )
                  : const Icon(Icons.save_outlined, size: 18),
          label: Text(
            LocaleKeys.scoreEntrySave.tr,
            style: AppTextStyle.normalWhiteRegular,
          ),
        ),
      ),
    );
  }
}
