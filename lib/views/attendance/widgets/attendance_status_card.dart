import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:schoolapp/core/core.dart';

class AttendanceStatusCardData {
  const AttendanceStatusCardData({
    required this.studentName,
    required this.classroom,
    required this.section,
    required this.subject,
    required this.dateText,
    required this.status,
  });

  final String studentName;
  final String classroom;
  final String section;
  final String subject;
  final String dateText;
  final String status;
}

class AttendanceStatusCard extends StatelessWidget {
  const AttendanceStatusCard({super.key, required this.card});

  final AttendanceStatusCardData card;

  @override
  Widget build(BuildContext context) {
    final statusStyle = AppStatusStyles.attendance(card.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _line(LocaleKeys.studentNameLabel.tr, card.studentName),
                const SizedBox(height: 4),
                _line(LocaleKeys.classLabel.tr, card.classroom),
                const SizedBox(height: 4),
                _line(LocaleKeys.sectionLabel.tr, card.section),
                const SizedBox(height: 4),
                _line(LocaleKeys.subjectLabel.tr, card.subject),
                const SizedBox(height: 4),
                _line(LocaleKeys.dateLabel.tr, card.dateText),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            margin: const EdgeInsets.only(top: 18),
            width: 110,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: statusStyle.color,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              statusStyle.label,
              style: TextStyle(
                color: Colors.white,
                fontFamily: AppFontFamily.forText(statusStyle.label),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 88,
          child: Text(
            '$label:',
            style: TextStyle(
              fontFamily: AppFontFamily.forText(label),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, color: Color(0xFF555555)),
          ),
        ),
      ],
    );
  }
}
