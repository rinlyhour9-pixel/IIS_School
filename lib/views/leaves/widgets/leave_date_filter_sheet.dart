import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/views/leaves/controller.dart';

void showLeaveDateFilterSheet(
  BuildContext context,
  LeavesController controller,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter Date',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            _DateFieldRow(
              label: 'Start',
              value: controller.fromDate,
              onTap: () => controller.pickFromDate(sheetContext),
            ),
            const SizedBox(height: 12),
            _DateFieldRow(
              label: 'End',
              value: controller.toDate,
              onTap: () => controller.pickToDate(sheetContext),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.red,
                  foregroundColor: AppColor.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  controller.applyDateFilter();
                  Navigator.of(sheetContext).pop();
                },
                child: Text(
                  LocaleKeys.search.tr,
                  style: AppTextStyle.mediumWhiteSemiBold,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _DateFieldRow extends StatelessWidget {
  final String label;
  final RxString value;
  final VoidCallback onTap;

  const _DateFieldRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 50,
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Obx(
              () => Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColor.primary.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      color: AppColor.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        value.value.isEmpty
                            ? LocaleKeys.selectDate.tr
                            : value.value,
                        style: TextStyle(
                          fontSize: 13,
                          color:
                              value.value.isEmpty
                                  ? AppColor.grey
                                  : AppColor.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
