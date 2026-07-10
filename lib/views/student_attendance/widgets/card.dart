import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/models/models.dart';
import 'package:schoolapp/views/student_attendance/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StudentAttendanceHistoryCardWidget
    extends GetView<StudentAttendanceController> {
  const StudentAttendanceHistoryCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FiltersRow(controller: controller),
          const SizedBox(height: 16),
          Obx(
            () =>
                controller.isLoading.value
                    ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : _HistoryList(controller: controller),
          ),
        ],
      ),
    );
  }
}

class _FiltersRow extends StatelessWidget {
  final StudentAttendanceController controller;

  const _FiltersRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Obx(() {
            final classItems = controller.classes.toList();
            return AppIconDropdown<ClassModel>(
              value: controller.selectedClass.value,
              items: classItems,
              itemLabel: (c) => c.className,
              onChanged: controller.selectClass,
              hintText: 'Class',
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
              hintText: 'Section',
            );
          }),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Obx(() {
            final subjectItems = controller.subjects.toList();
            return AppIconDropdown<SubjectModel>(
              value: controller.selectedSubject.value,
              items: subjectItems,
              itemLabel: (s) => s.name,
              onChanged: controller.selectSubject,
              hintText: 'Subject',
            );
          }),
        ),
      ],
    );
  }
}

class _HistoryList extends StatelessWidget {
  final StudentAttendanceController controller;

  const _HistoryList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.historyList;
      if (items.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(child: Text('No attendance records found')),
        );
      }
      return Column(
        children:
            items
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _HistoryCard(controller: controller, item: item),
                  ),
                )
                .toList(),
      );
    });
  }
}

class _HistoryCard extends StatelessWidget {
  final StudentAttendanceController controller;
  final StudentAttendanceSummaryItem item;

  const _HistoryCard({required this.controller, required this.item});

  String get _formattedDate {
    final parsed = DateTime.tryParse(item.attendanceDate);
    if (parsed == null) return item.attendanceDate;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[parsed.month - 1]} ${parsed.day} ${parsed.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 8,
      ), // was: EdgeInsets.symmetric(horizontal: 16, vertical: 8)
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.lightGrey),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const _DateIconBox(),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_formattedDate, style: AppTextStyle.midPrimaryBold),
                const SizedBox(height: 3),
                Text(
                  item.className,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.smallGreyRegular,
                ),
                Text(
                  item.subjectName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.smallGreyRegular,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 5,
                runSpacing: 5,
                children: [
                  _CountChip(
                    label: 'P',
                    count: item.presenceCount,
                    color: AppColor.primary,
                  ),
                  _CountChip(
                    label: 'L',
                    count: item.lateCount,
                    color: AppColor.yellow,
                  ),
                  _CountChip(
                    label: 'A',
                    count: item.absentCount,
                    color: AppColor.red,
                  ),
                  _CountChip(
                    label: 'F',
                    count: item.permissionCount,
                    color: AppColor.blue,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              IconButton(
                onPressed: () => controller.openDetail(item),
                icon: const Icon(Icons.remove_red_eye_outlined, size: 17),
                color: AppColor.darkGrey,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateIconBox extends StatelessWidget {
  const _DateIconBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColor.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(9),
      ),
      child: const Icon(
        Icons.edit_calendar_outlined,
        color: AppColor.primary,
        size: 16,
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _CountChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label $count',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
