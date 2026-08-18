import 'package:schoolapp/core/configs/app_style.dart';
import 'package:flutter/material.dart';
// Import your custom text styles
// import 'package:schoolapp/core/utils/app_text_style.dart';

class CustomCard extends StatelessWidget {
  final String name;
  final String grade;
  final String date;
  final String status;
  final Color statusColor;

  const CustomCard({
    super.key,
    required this.name,
    required this.grade,
    required this.date,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Side: Name, Grade, and Date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and Grade
                Text(
                  '$name  $grade',
                  style: AppTextStyle.mendiumPrimary,
                  overflow:
                      TextOverflow.ellipsis, // Prevents overflow for long names
                ),
                const SizedBox(height: 6),
                // Date Row
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_outlined,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: AppTextStyle.mendiumPrimary.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Right Side: Status Badge
          Container(
            width: 85, // Slightly wider to avoid text clipping
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(
                0.2,
              ), // Light background for better look
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: statusColor), // Border makes it pop
            ),
            alignment: Alignment.center,
            child: Text(
              status,
              style: AppTextStyle.regularPrimarytext.copyWith(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
