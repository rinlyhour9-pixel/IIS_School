import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/models/requestleave/model.dart';
import 'package:schoolapp/views/all_requested_leave/widget/all_requested_leave_status.dart';

class AllRequestedLeaveItemCard extends StatelessWidget {
  const AllRequestedLeaveItemCard({
    super.key,
    required this.item,
    required this.selectedStudentName,
    required this.selectedStudentGrade,
  });

  final RequestLeaveModel item;
  final String selectedStudentName;
  final String selectedStudentGrade;

  @override
  Widget build(BuildContext context) {
    final status = requestLeaveStatusOf(item);
    final statusStyle = requestLeaveStatusStyle(status);
    final start = (item.dateStart ?? '').trim();
    final end = (item.dateEnd ?? '').trim();
    final reason = (item.reason ?? '').trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(title: _titleText(), statusStyle: statusStyle),
          const SizedBox(height: 8),
          _DateRange(start: start, end: end),
          const SizedBox(height: 10),
          _ReasonBox(text: reason.isEmpty ? '-' : reason),
        ],
      ),
    );
  }

  String _titleText() {
    final requestName = (item.name ?? '').trim();
    final requestGrade = (item.grade ?? '').trim();
    final displayName =
        _isPlaceholderName(requestName)
            ? (selectedStudentName.isEmpty
                ? LocaleKeys.student.tr
                : selectedStudentName)
            : requestName;
    final displayGrade =
        _isValidGrade(requestGrade) ? requestGrade : selectedStudentGrade;

    if (!_isValidGrade(displayGrade)) {
      return displayName.isEmpty ? LocaleKeys.student.tr : displayName;
    }
    return '$displayName - $displayGrade';
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE5E7EB)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x1A000000),
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    );
  }

  bool _isValidGrade(String value) {
    final text = value.trim().toLowerCase();
    if (text.isEmpty) {
      return false;
    }
    return text != 'n/a' && text != 'na' && text != 'null' && text != '-';
  }

  bool _isPlaceholderName(String value) {
    final text = value.trim().toLowerCase();
    if (text.isEmpty) {
      return true;
    }
    return text == 'student' ||
        text == 'n/a' ||
        text == 'na' ||
        text == 'null' ||
        text == '-';
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.statusStyle});

  final String title;
  final AppStatusStyle statusStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
               fontFamily: AppFontFamily.forText(title),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusStyle.background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            statusStyle.label,
            style: TextStyle(
              color: statusStyle.color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
               fontFamily: AppFontFamily.forText(statusStyle.label),
            ),
          ),
        ),
      ],
    );
  }
}

class _DateRange extends StatelessWidget {
  const _DateRange({required this.start, required this.end});

  final String start;
  final String end;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.calendar_month_outlined, size: 16),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            '${start.isEmpty ? '-' : start}  ${LocaleKeys.to.tr}  ${end.isEmpty ? '-' : end}',
            style: TextStyle(
              fontSize: 13,
              color: const Color(0xFF6B7280),
              // fontWeight: FontWeight.w500,
               fontFamily: AppFontFamily.forText(
                 '${start.isEmpty ? '-' : start}  ${LocaleKeys.to.tr}  ${end.isEmpty ? '-' : end}',
               ),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ReasonBox extends StatelessWidget {
  const _ReasonBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            border: Border.all(color: const Color(0xFF0F8A80)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: const Color(0xFF374151),
               fontFamily: AppFontFamily.forText(text),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              border: Border.all(color: const Color(0xFF0F8A80)),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              LocaleKeys.reason.tr,
              style: TextStyle(
                fontSize: 10,
                color: const Color(0xFF065F5B),
                fontWeight: FontWeight.w600,
                 fontFamily: AppFontFamily.forText(LocaleKeys.reason.tr),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
