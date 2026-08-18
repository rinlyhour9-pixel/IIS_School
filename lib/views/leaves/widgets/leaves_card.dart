import 'package:schoolapp/models/models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:intl/intl.dart';

class LeaveCardWidget extends StatelessWidget {
  final LeaveItem item;
  final VoidCallback onView;

  const LeaveCardWidget({super.key, required this.item, required this.onView});

  static const _avatarColors = <Color>[
    Color(0xFFE53935),
    Color(0xFF1E88E5),
    Color(0xFFEC407A),
    Color(0xFF8E24AA),
    Color(0xFF00897B),
  ];

  Color get _avatarColor {
    final key = item.studentId.isNotEmpty ? item.studentId : item.studentName;
    final hash = key.codeUnits.fold<int>(0, (sum, code) => sum + code);
    return _avatarColors[hash % _avatarColors.length];
  }

  int get _leaveDays {
    final start = DateTime.tryParse(item.fromDate);
    final end = DateTime.tryParse(item.toDate);
    if (start == null || end == null) return 0;
    return end.difference(start).inDays + 1;
  }

  AppStatusStyle get _statusConfig => leaveStatusConfig(item.status);

  String _leaveDaysText(int days) {
    if (days <= 0) return '-';
    final number = NumberFormat.decimalPattern('en_US').format(days);
    final unit =
        days == 1 ? LocaleKeys.leaveDay.tr : LocaleKeys.leaveDaysUnit.tr;
    return '$number $unit';
  }

  @override
  Widget build(BuildContext context) {
    final status = _statusConfig;
    final days = _leaveDays;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: _avatarColor,
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: AppColor.backgroundColor,
                  backgroundImage:
                      item.profile.isEmpty ? null : NetworkImage(item.profile),
                  child:
                      item.profile.isEmpty
                          ? const Icon(Icons.person, color: AppColor.grey)
                          : null,
                ),
              ),
              UIConstants.spacingSmall.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.studentName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.midPrimaryBold,
                    ),
                    if ((item.className ?? '').isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          item.className!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.normalGreyRegular,
                        ),
                      ),
                    if (item.studentId.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      _StudentIdChip(studentId: item.studentId),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              LeaveStatusBadge(config: status),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColor.divider),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const _IconBox(icon: Icons.calendar_today_rounded),
              UIConstants.spacingSmall.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleKeys.leaveDuration.tr,
                      style: AppTextStyle.smallGreyRegular,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.fromDate} - ${item.toDate}',
                      softWrap: true,
                      style: AppTextStyle.normalPrimaryBold,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocaleKeys.totalLeaveDays.tr,
                    style: AppTextStyle.smallGreyRegular,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _leaveDaysText(days),
                    style: AppTextStyle.normalPrimaryBold,
                  ),
                ],
              ),
              const Spacer(),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColor.primary,
                  side: const BorderSide(color: AppColor.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                ),
                onPressed: onView,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(LocaleKeys.view.tr, style: AppTextStyle.normalRedBold),
                    const Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: AppColor.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StudentIdChip extends StatelessWidget {
  final String studentId;

  const _StudentIdChip({required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColor.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person_outline, size: 13, color: AppColor.primary),
          const SizedBox(width: 4),
          Text(
            '${LocaleKeys.studentId.tr}: $studentId',
            style: AppTextStyle.smallPrimarySemibold,
          ),
        ],
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;

  const _IconBox({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColor.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 18, color: AppColor.primary),
    );
  }
}

class LeaveStatusBadge extends StatelessWidget {
  final AppStatusStyle config;

  const LeaveStatusBadge({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        config.label,
        style: TextStyle(
          color: config.color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          fontFamily: AppFontFamily.forText(config.label),
        ),
      ),
    );
  }
}

AppStatusStyle leaveStatusConfig(String status) {
  return AppStatusStyles.leave(status);
}
