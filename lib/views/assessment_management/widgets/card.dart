import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/models/models.dart';
import 'package:schoolapp/views/assessment_management/controller.dart';
import 'package:schoolapp/views/score_entry/widgets/score_layout.dart'
    show
        kHeaderHeight,
        kScrollbarLaneHeight,
        kStudentColWidth,
        MaxScoreInputFormatter,
        scrollableWidthFor;
// Imported directly rather than through views.dart: assessment_management is
// itself exported from that barrel, so going through it would create a cycle.
import 'package:schoolapp/views/start/controller.dart';

/// Frozen left column is wider than Score Entry's own `kSubjectColWidth`
/// (116) — field labels like "Task Responsibility" / "Students punctually"
/// are longer than subject names, and each row also carries a small
/// "(out of N)" caption underneath.
const double kFieldColWidth = 150;

/// A scoreable field row's height — label (up to 2 lines) plus a small
/// "(out of N)" caption underneath.
const double kFieldRowHeight = 76;

/// A group-header band's height (Semester Exam's "First/Second Quarter").
const double kGroupRowHeight = 36;

double _heightOf(AssessmentField field) =>
    field.kind == AssessmentFieldKind.group ? kGroupRowHeight : kFieldRowHeight;

class AssessmentManagementCardWidget
    extends GetView<AssessmentManagementController> {
  const AssessmentManagementCardWidget({super.key});

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
            final students = controller.students.toList();
            final fields = controller.activeFields.toList();
            final hasComment = controller.activeHasComment.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _AssessmentTable(students: students, fields: fields),
                if (hasComment) ...[
                  const SizedBox(height: 16),
                  _TeacherCommentsSection(students: students),
                ],
              ],
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

  final AssessmentManagementController controller;

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
                    isLoading: controller.isLoadingAssignments.value,
                    hintText: LocaleKeys.scoreEntryLevel.tr,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(
                  () => AppIconDropdown<SubjectModel>(
                    value: controller.selectedSubject.value,
                    items: controller.subjectsForSelectedClass,
                    itemLabel: (item) => item.name,
                    onChanged: controller.selectSubject,
                    isLoading: controller.isLoadingAssignments.value,
                    hintText: LocaleKeys.subject.tr,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Section — really the specific session/time-slot a class+
              // subject assignment happens in (see AssessmentAssignment's
              // doc comment); only has real options once Level+Subject are
              // both picked.
              Expanded(
                child: Obx(
                  () => AppIconDropdown<String>(
                    value: controller.selectedSection.value,
                    items: controller.sectionsForSelectedClassAndSubject,
                    itemLabel: (item) => item,
                    onChanged: controller.selectSection,
                    isLoading: controller.isLoadingAssignments.value,
                    hintText: LocaleKeys.section.tr,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(
                  () => AppIconDropdown<AssessmentResultType>(
                    value: controller.selectedResultType.value,
                    items: AssessmentResultType.values,
                    itemLabel: (type) => type.label,
                    onChanged: controller.selectResultType,
                    hintText: LocaleKeys.scoreEntryResultType.tr,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(
            () => AppIconDropdown<String>(
              value: controller.selectedPeriod.value,
              items: controller.periodItems,
              itemLabel: (item) => item,
              onChanged: controller.selectPeriod,
              isLoading: controller.isLoadingFilters.value,
              hintText: switch (controller.selectedResultType.value) {
                AssessmentResultType.quarterly =>
                  LocaleKeys.scoreEntryQuarter.tr,
                AssessmentResultType.semester =>
                  LocaleKeys.assessmentManagementSemester.tr,
                AssessmentResultType.monthly ||
                null => LocaleKeys.scoreEntryMonth.tr,
              },
              emptyText: LocaleKeys.scoreEntrySelectResultTypeFirst.tr,
            ),
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

  final AssessmentManagementController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Obx(
        () => ElevatedButton.icon(
          onPressed: controller.isLoading.value ? null : _onPressed,
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

  Future<void> _onPressed() async {
    // Re-filtering rebuilds every column, which discards anything typed but
    // not yet saved — so confirm first when there is something to lose.
    // Uses Get.dialog()/Get.back() rather than raw showDialog(), same as
    // Score Entry's filter button (see the Navigator bug fixed this session).
    if (controller.hasUnsavedScores) {
      final discard = await Get.dialog<bool>(
        AlertDialog(
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
              onPressed: () => Get.back(result: false),
              child: Text(LocaleKeys.cancel.tr),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
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

/// The assessment sheet.
///
/// The selected Result Type's fields run down the frozen left column; each
/// student is a column inside a single horizontal scroll view. Both halves
/// derive every row height from the same [_heightOf] so they can never
/// shear, including group-header rows (Semester Exam's "First/Second
/// Quarter"), which are taller than a normal header but shorter than a
/// score row.
///
/// StatefulWidget because it owns the horizontal ScrollController — hanging
/// that on the GetX controller risks `Scrollbar` asserting on a detached
/// controller across route transitions.
class _AssessmentTable extends StatefulWidget {
  const _AssessmentTable({required this.students, required this.fields});

  final List<AssessmentStudentColumn> students;
  final List<AssessmentField> fields;

  @override
  State<_AssessmentTable> createState() => _AssessmentTableState();
}

class _AssessmentTableState extends State<_AssessmentTable> {
  final ScrollController _horizontalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tableHeight =
        kHeaderHeight +
        widget.fields.fold<double>(0, (sum, f) => sum + _heightOf(f)) +
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
            _FieldColumn(fields: widget.fields),
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
                      fields: widget.fields,
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

/// Frozen left column: an empty corner cell, then one row per field — a
/// tinted full-width band for a group header, or a label + "(out of N)"
/// caption for a scoreable field.
class _FieldColumn extends StatelessWidget {
  const _FieldColumn({required this.fields});

  final List<AssessmentField> fields;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: kFieldColWidth,
      child: Column(
        children: [
          // Empty corner above the field labels, matching header height.
          Container(
            height: kHeaderHeight,
            decoration: const BoxDecoration(
              color: AppColor.backgroundColor,
              border: Border(bottom: BorderSide(color: AppColor.divider)),
            ),
          ),
          ...fields.map(
            (field) =>
                field.kind == AssessmentFieldKind.group
                    ? _GroupHeaderCell(label: field.label)
                    : Container(
                      height: kFieldRowHeight,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: const BoxDecoration(
                        color: AppColor.backgroundColor,
                        border: Border(
                          bottom: BorderSide(color: AppColor.divider),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            // Real names from the API, not a LocaleKeys
                            // constant — no Khmer translation exists for
                            // these dynamic strings.
                            field.label,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyle.normalPrimarySemiBold,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '(out of ${field.maxScore})',
                            textAlign: TextAlign.center,
                            style: AppTextStyle.smallGreyRegular,
                          ),
                        ],
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

class _GroupHeaderCell extends StatelessWidget {
  const _GroupHeaderCell({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kGroupRowHeight,
      width: double.infinity,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColor.primary.withValues(alpha: 0.08),
        border: const Border(bottom: BorderSide(color: AppColor.divider)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyle.smallPrimaryBold,
      ),
    );
  }
}

/// Scrolling right side: one column per student, each with a three-line
/// header (admission no, name, gender) above its field rows.
class _StudentColumns extends StatelessWidget {
  const _StudentColumns({required this.students, required this.fields});

  final List<AssessmentStudentColumn> students;
  final List<AssessmentField> fields;

  @override
  Widget build(BuildContext context) {
    final totalWidth = scrollableWidthFor(students.length);
    return Column(
      children: [
        SizedBox(
          height: kHeaderHeight,
          child: Row(
            // Row defaults to centering children on the cross axis, which
            // would let each cell's own (shorter) intrinsic height float in
            // the middle of this fixed-height slot — its border then only
            // wraps its own content instead of reaching the true row
            // boundary, visibly misaligning against the frozen column's
            // dividers (which use an explicit height, not centering).
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children:
                students
                    .map((student) => _StudentHeaderCell(student: student))
                    .toList(),
          ),
        ),
        ...fields.map(
          (field) =>
              field.kind == AssessmentFieldKind.group
                  ? Container(
                    height: kGroupRowHeight,
                    width: totalWidth,
                    decoration: BoxDecoration(
                      color: AppColor.primary.withValues(alpha: 0.08),
                      border: const Border(
                        bottom: BorderSide(color: AppColor.divider),
                      ),
                    ),
                  )
                  : SizedBox(
                    height: kFieldRowHeight,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children:
                          students
                              .map(
                                (student) =>
                                    _ScoreCell(student: student, field: field),
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

  final AssessmentStudentColumn student;

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

/// A single editable score cell for one (student, field) pair.
///
/// Deliberately has no `Obx`: the student's TextEditingController is the
/// source of truth and `TextField` listens to it internally, so typing
/// rebuilds nothing above `EditableText`.
class _ScoreCell extends StatelessWidget {
  const _ScoreCell({required this.student, required this.field});

  final AssessmentStudentColumn student;
  final AssessmentField field;

  @override
  Widget build(BuildContext context) {
    final scoreController = student.controllerFor(field.key);

    return Container(
      width: kStudentColWidth,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      // Now that the row's Row stretches this cell to the full row height,
      // a Container with no alignment leaves its child pinned to the top
      // instead of centering in the extra space.
      alignment: Alignment.center,
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
                  MaxScoreInputFormatter(field.maxScore),
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

/// Quarterly/Semester's free-text "Teacher Comment" — one full-width,
/// multi-line field per student, below the table (not a cramped cell inside
/// a 124px-wide table column).
class _TeacherCommentsSection extends StatelessWidget {
  const _TeacherCommentsSection({required this.students});

  final List<AssessmentStudentColumn> students;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.assessmentManagementTeacherComment.tr,
            style: AppTextStyle.normalPrimarySemiBold,
          ),
          const SizedBox(height: 12),
          for (final student in students) ...[
            Text(student.studentName, style: AppTextStyle.smallGreyRegular),
            const SizedBox(height: 6),
            if (student.commentController != null)
              TextField(
                controller: student.commentController,
                maxLines: 3,
                style: AppTextStyle.smallRegular,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: '-',
                  filled: true,
                  fillColor: AppColor.backgroundColor,
                  contentPadding: const EdgeInsets.all(10),
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
            if (student != students.last) const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.controller});

  final AssessmentManagementController controller;

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
