import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/models/models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller.dart';

class DetailedAttendanceCardWidget
    extends GetView<DetailedAttendanceController> {
  const DetailedAttendanceCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FiltersCard(controller: controller),
          const SizedBox(height: 16),
          _SearchRow(controller: controller),
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
        ],
      ),
    );
  }
}

class _FiltersCard extends StatelessWidget {
  final DetailedAttendanceController controller;

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
                child: Obx(
                  () => _ReadOnlyField(
                    label: controller.selectedClass.value?.className,
                    hintText: 'Class',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(
                  () => _ReadOnlyField(
                    label: controller.selectedSection.value?.section,
                    hintText: 'Section',
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
                  () => _ReadOnlyField(
                    label: controller.selectedSubject.value?.name,
                    hintText: 'Subject',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: _DateField(controller: controller)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final IconData? icon;
  final String? label;
  final String hintText;

  const _ReadOnlyField({
    required this.label,
    required this.hintText,
  }) : icon = null;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: EdgeInsets.only(right: 12, left: icon == null ? 12 : 0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.divider),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 52,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColor.white,
                border: Border(right: BorderSide(color: AppColor.divider)),
              ),
              child: Icon(icon, color: AppColor.darkGrey, size: 20),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              (label == null || label!.isEmpty) ? hintText : label!,
              style: AppTextStyle.normalPrimaryRegular,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final DetailedAttendanceController controller;

  const _DateField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.only(right: 8),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: AppColor.white,
              border: Border(right: BorderSide(color: AppColor.divider)),
            ),
            child: const Icon(
              Icons.calendar_today_outlined,
              color: AppColor.darkGrey,
              size: 12,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(
              () => Text(
                controller.selectedDate.value.isEmpty
                    ? 'All dates'
                    : controller.selectedDate.value,
                style: AppTextStyle.normalPrimaryRegular,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchRow extends StatelessWidget {
  final DetailedAttendanceController controller;

  const _SearchRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller.searchCtl,
      decoration: InputDecoration(
        hintText: 'Search Student...',
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
    );
  }
}

class _StudentTable extends StatelessWidget {
  final DetailedAttendanceController controller;

  const _StudentTable({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final rows = controller.studentList;
      if (rows.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(child: Text('No records found')),
        );
      }
      return Column(
        children: [
          const _TableHeader(),
          ...List.generate(rows.length, (index) {
            return _StudentRowWidget(
              index: index + 1,
              item: rows[index],
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
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text('No.', style: AppTextStyle.normalPrimarySemiBold),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Student Name',
              style: AppTextStyle.normalPrimarySemiBold,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text('Subject', style: AppTextStyle.normalPrimarySemiBold),
          ),
          Expanded(
            flex: 2,
            child: Text('Status', style: AppTextStyle.normalPrimarySemiBold),
          ),
          Expanded(
            flex: 2,
            child: Text('Note', style: AppTextStyle.normalPrimarySemiBold),
          ),
        ],
      ),
    );
  }
}

class _StudentRowWidget extends StatelessWidget {
  final int index;
  final DetailedAttendanceItem item;
  final bool isEven;

  const _StudentRowWidget({
    required this.index,
    required this.item,
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
          Expanded(flex: 3, child: Text(item.studentName)),
          Expanded(flex: 2, child: Text(item.subjectName)),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _StatusBadge(status: item.attendanceStatus),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              item.note.isEmpty ? '     ' : item.note,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.smallRegular,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _configFor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: config.color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(config.label, style: AppTextStyle.smallWhiteSemibold),
    );
  }

  _StatusConfig _configFor(String status) {
    switch (status.toUpperCase()) {
      case 'P':
        return const _StatusConfig('Present', AppColor.green);
      case 'L':
        return const _StatusConfig('Late', AppColor.yellow);
      case 'A':
        return const _StatusConfig('Absent', AppColor.red);
      case 'F':
        return const _StatusConfig('Permission', AppColor.blue);
      default:
        return const _StatusConfig('N/A', AppColor.grey);
    }
  }
}

class _StatusConfig {
  final String label;
  final Color color;

  const _StatusConfig(this.label, this.color);
}
