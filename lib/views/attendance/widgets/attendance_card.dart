import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/core/widgets/attendance/summary_item.dart';
import 'package:schoolapp/views/attendance/controller.dart';
import 'package:schoolapp/views/attendance/widgets/attendance_status_card.dart';

class AttendanceCardWidget extends GetView<AttendanceController> {
  const AttendanceCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Obx(() {
            final present = AppStatusStyles.attendance('Present');
            final late = AppStatusStyles.attendance('Late');
            final absent = AppStatusStyles.attendance('Absent');
            final permission = AppStatusStyles.attendance('Permission');

            return Row(
              children: [
                SummaryItem(
                  label: present.label,
                  count: controller.totalPresent.toString(),
                  color: present.color,
                  isActive: controller.selectedStatusFilter.value == 'Present',
                  onTap: () => controller.toggleStatusFilter('Present'),
                ),
                SummaryItem(
                  label: late.label,
                  count: controller.totalLate.toString(),
                  color: late.color,
                  isActive: controller.selectedStatusFilter.value == 'Late',
                  onTap: () => controller.toggleStatusFilter('Late'),
                ),
                SummaryItem(
                  label: absent.label,
                  count: controller.totalAbsent.toString(),
                  color: absent.color,
                  isActive: controller.selectedStatusFilter.value == 'Absent',
                  onTap: () => controller.toggleStatusFilter('Absent'),
                ),
                SummaryItem(
                  label: permission.label,
                  count: controller.totalPermission.toString(),
                  color: permission.color,
                  isActive:
                      controller.selectedStatusFilter.value == 'Permission',
                  onTap: () => controller.toggleStatusFilter('Permission'),
                ),
              ],
            );
          }),
          20.height,
          Obx(() {
            if (controller.isLoadingSummary.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            var items = controller.records.toList();
            final selected = controller.selectedStatusFilter.value;
            if (selected != null && selected.isNotEmpty) {
              items = items
                  .where(
                    (r) => r.status.toLowerCase() == selected.toLowerCase(),
                  )
                  .toList(growable: false);
            }

            if (items.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  LocaleKeys.noAttendanceLogsFound.tr,
                  style: const TextStyle(color: Colors.grey),
                ),
              );
            }

            return Column(
              children:
                  items
                      .map(
                        (r) => AttendanceStatusCard(
                          card: AttendanceStatusCardData(
                            studentName: r.displayName,
                            classroom: r.classroom,
                            section: r.section,
                            subject: r.subject,
                            dateText: _formatDate(r.date),
                            status: r.status,
                          ),
                        ),
                      )
                      .toList(),
            );
          }),
        ],
      ),
    );
  }

  String _formatDate(String value) {
    final raw = value.trim();
    if (raw.isEmpty) return DateFormat('dd MMM yyyy').format(DateTime.now());
    final parsed = DateTime.tryParse(raw);
    return parsed == null ? raw : DateFormat('dd MMM yyyy').format(parsed);
  }
}
