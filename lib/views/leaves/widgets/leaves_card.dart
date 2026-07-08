import 'package:schoolapp/models/models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';

class LeaveCardWidget extends StatelessWidget {
  final LeaveItem item;
  final VoidCallback onView;

  const LeaveCardWidget({super.key, required this.item, required this.onView});

  Color _statusColor() {
    switch (item.status.toLowerCase()) {
      case 'approved':
        return AppColor.primary;
      case 'rejected':
        return AppColor.red;
      default:
        return AppColor.yellow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(item.profile),
              ),
              UIConstants.spacingSmall.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.studentName, style: AppTextStyle.midPrimaryBold),
                    if ((item.className ?? '').isNotEmpty)
                      Text(
                        item.className!,
                        style: AppTextStyle.normalPrimaryRegular,
                      ),
                  ],
                ),
              ),
            ],
          ),
          UIConstants.spacingSmall.height,
          Text(
            LocaleKeys.leaveDuration.tr,
            style: AppTextStyle.normalPrimaryRegular,
          ),
          Text(
            '${item.fromDate} - ${item.toDate}',
            style: AppTextStyle.normalPrimaryBold,
          ),
          UIConstants.spacingSmall.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '${LocaleKeys.status.tr}  ',
                    style: AppTextStyle.normalPrimaryRegular,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor(),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.status,
                      style: AppTextStyle.smallWhiteSemibold,
                    ),
                  ),
                ],
              ),
              OutlinedButton(
                onPressed: onView,
                child: Text(LocaleKeys.view.tr),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
