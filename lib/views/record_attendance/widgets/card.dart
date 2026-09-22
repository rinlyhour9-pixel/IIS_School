import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/views/record_attendance/controller.dart';
import 'package:schoolapp/models/models.dart';
import 'package:flutter/material.dart';
import 'package:schoolapp/views/views.dart';
import 'row.dart';
import 'package:get/get.dart';

class RecordAttendanceCardWidget extends GetView<RecordAttendanceController> {
  const RecordAttendanceCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FiltersCard(controller: controller),
          const SizedBox(height: 16),
          _SearchAndSelectAllRow(controller: controller),
          const SizedBox(height: 12),
          Obx(
            () =>
                controller.isLoading.value
                    ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : _StudentTable(controller: controller),
          ),
          const SizedBox(height: 20),
          _SubmitButton(controller: controller),
          const SizedBox(height: 20),
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

class _FiltersCard extends StatelessWidget {
  final RecordAttendanceController controller;

  const _FiltersCard({required this.controller});

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
                child: Obx(() {
                  final classItems = controller.classes.toList();
                  return AppIconDropdown<ClassModel>(
                    value: controller.selectedClass.value,
                    items: classItems,
                    itemLabel: (c) => c.className,
                    onChanged: controller.selectClass,
                    hintText: LocaleKeys.classLabel.tr,
                  );
                }),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(() {
                  final sectionItems = controller.sections.toList();
                  return AppIconDropdown<SectionModel>(
                    value: controller.selectedSection.value,
                    items: sectionItems,
                    itemLabel: (s) => s.section,
                    onChanged: controller.selectSection,
                    hintText: LocaleKeys.section.tr,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Obx(() {
                  final subjectItems = controller.subjects.toList();
                  return AppIconDropdown<SubjectModel>(
                    value: controller.selectedSubject.value,
                    items: subjectItems,
                    itemLabel: (s) => s.name,
                    onChanged: controller.selectSubject,
                    hintText: LocaleKeys.subject.tr,
                  );
                }),
              ),
              const SizedBox(width: 12),
              Expanded(child: _DateField(controller: controller)),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          const _TeacherRow(),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final RecordAttendanceController controller;

  const _DateField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => controller.pickDate(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColor.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColor.white,
                border: Border(right: BorderSide(color: AppColor.divider)),
              ),
              child: const Icon(
                Icons.calendar_today_outlined,
                color: AppColor.darkGrey,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(
                () => Text(
                  controller.selectedDate.value,
                  style: AppTextStyle.normalPrimaryRegular,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchAndSelectAllRow extends StatelessWidget {
  final RecordAttendanceController controller;

  const _SearchAndSelectAllRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller.searchCtl,
          decoration: InputDecoration(
            hintText: LocaleKeys.recordAttendanceSearchHint.tr,
            suffixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: AppColor.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColor.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColor.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColor.primary),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            onPressed: controller.selectAllPresent,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColor.primary,
              side: const BorderSide(color: AppColor.primary),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: Text(LocaleKeys.recordAttendanceSelectAllPresent.tr),
          ),
        ),
      ],
    );
  }
}

class _StudentTable extends StatelessWidget {
  final RecordAttendanceController controller;

  const _StudentTable({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final rows = controller.studentList;
      if (rows.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: Text(LocaleKeys.recordAttendanceNoStudentsFound.tr),
          ),
        );
      }
      return Column(
        children: [
          const _TableHeader(),
          ...List.generate(rows.length, (index) {
            return _StudentRowWidget(
              index: index + 1,
              row: rows[index],
              controller: controller,
              isEven: index.isEven,
            );
          }),
        ],
      );
    });
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              LocaleKeys.recordAttendanceNoColumn.tr,
              style: AppTextStyle.normalPrimarySemiBold,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              LocaleKeys.studentName.tr,
              style: AppTextStyle.normalPrimarySemiBold,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              LocaleKeys.recordAttendanceGender.tr,
              style: AppTextStyle.normalPrimarySemiBold,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              LocaleKeys.attendance.tr,
              style: AppTextStyle.normalPrimarySemiBold,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              LocaleKeys.recordAttendanceNote.tr,
              style: AppTextStyle.normalPrimarySemiBold,
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentRowWidget extends StatelessWidget {
  final int index;
  final StudentAttendanceRow row;
  final RecordAttendanceController controller;
  final bool isEven;

  const _StudentRowWidget({
    required this.index,
    required this.row,
    required this.controller,
    required this.isEven,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isEven ? AppColor.backgroundColor : AppColor.white,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 32, child: Text('$index')),
          Expanded(flex: 3, child: Text(row.studentName)),
          Expanded(flex: 2, child: Text(row.gender)),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: Obx(
                    () => _AttendanceChip(
                      label: 'P',
                      color: AppColor.green,
                      active: row.presence.value,
                      onTap: () => controller.togglePresence(row),
                    ),
                  ),
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: Obx(
                    () => _AttendanceChip(
                      label: 'L',
                      color: AppColor.yellow,
                      active: row.late.value,
                      onTap: () => controller.toggleLate(row),
                    ),
                  ),
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: Obx(
                    () => _AttendanceChip(
                      label: 'A',
                      color: AppColor.red,
                      active: row.absent.value,
                      onTap: () => controller.toggleAbsent(row),
                    ),
                  ),
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: Obx(
                    () => _AttendanceChip(
                      label: 'F',
                      color: AppColor.blue,
                      active: row.permission.value,
                      onTap: () => controller.togglePermission(row),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: _NoteCell(row: row, onTap: () => _showNoteDialog(context)),
          ),
        ],
      ),
    );
  }

  void _showNoteDialog(BuildContext context) {
    final noteCtl = TextEditingController(text: row.note.value);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(LocaleKeys.recordAttendanceNote.tr),
            content: TextField(
              controller: noteCtl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: LocaleKeys.recordAttendanceEnterNoteHint.tr,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(LocaleKeys.cancel.tr),
              ),
              TextButton(
                onPressed: () {
                  controller.updateNote(row, noteCtl.text.trim());
                  Navigator.of(context).pop();
                },
                child: Text(LocaleKeys.recordAttendanceSave.tr),
              ),
            ],
          ),
    );
  }
}

class _NoteCell extends StatelessWidget {
  final StudentAttendanceRow row;
  final VoidCallback onTap;

  const _NoteCell({required this.row, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final note = row.note.value.trim();
      if (note.isEmpty) {
        return Center(
          child: IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.edit_outlined, size: 18),
            onPressed: onTap,
          ),
        );
      }
      return InkWell(
        onTap: onTap,
        child: Center(
          child: Text(
            note,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.smallRegular,
          ),
        ),
      );
    });
  }
}

class _AttendanceChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool active;
  final VoidCallback onTap;

  const _AttendanceChip({
    required this.label,
    required this.color,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? color : AppColor.divider,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? AppColor.white : AppColor.black,
              fontWeight: FontWeight.w600,
              fontSize: label.length > 1 ? 9 : 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final RecordAttendanceController controller;

  const _SubmitButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Obx(
        () => ElevatedButton(
          onPressed:
              controller.isSubmitting.value
                  ? null
                  : controller.submitAttendance,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child:
              controller.isSubmitting.value
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColor.white,
                    ),
                  )
                  : Text(
                    LocaleKeys.recordAttendanceSubmit.tr,
                    style: AppTextStyle.normalWhiteRegular,
                  ),
        ),
      ),
    );
  }
}
