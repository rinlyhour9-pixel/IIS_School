import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/views/views.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'leaves_card.dart';

void showLeaveDetailSheet(BuildContext context, LeavesController controller) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Obx(() {
        if (controller.isDetailLoading.value) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final leave = controller.selectedLeave.value;
        if (leave == null) {
          return SizedBox(
            height: 200,
            child: Center(child: Text(LocaleKeys.somethingWentWrong.tr)),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(leave.profile),
                  ),
                  UIConstants.spacingSmall.width,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          leave.studentName,
                          style: AppTextStyle.midPrimaryBold,
                        ),
                        if ((leave.className ?? '').isNotEmpty)
                          Text(
                            leave.className!,
                            style: AppTextStyle.normalPrimaryRegular,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  LeaveStatusBadge(config: leaveStatusConfig(leave.status)),
                ],
              ),
              UIConstants.spacingMedium.height,
              Text(
                LocaleKeys.detailedReason.tr,
                style: AppTextStyle.midPrimaryBold,
              ),
              UIConstants.spacingSmall.height,
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColor.backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  leave.reason,
                  style: AppTextStyle.normalPrimaryRegular,
                ),
              ),
              if (leave.docs.isNotEmpty) ...[
                UIConstants.spacingMedium.height,
                Text(
                  LocaleKeys.attachments.tr,
                  style: AppTextStyle.midPrimaryBold,
                ),
                UIConstants.spacingSmall.height,
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      leave.docs.asMap().entries.map((entry) {
                        final index = entry.key;
                        final url = entry.value;
                        return InkWell(
                          onTap: () => launchUrlString(url),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.backgroundColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.insert_drive_file, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  '${LocaleKeys.document.tr} ${index + 1}',
                                  style: AppTextStyle.normalPrimaryRegular,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ],
            ],
          ),
        );
      });
    },
  );
}
