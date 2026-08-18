import 'package:schoolapp/core/configs/app_style.dart';
import 'package:flutter/material.dart';
// import 'package:your_project/core/constants/app_color.dart';
// import 'package:your_project/core/utils/app_text_style.dart';

class SummaryItem extends StatelessWidget {
  final String label;
  final String count;
  final Color color;
  final IconData? icon; // Added for extra visual polish
  final VoidCallback? onTap;
  final bool isActive;

  const SummaryItem({
    super.key,
    required this.label,
    required this.count,
    required this.color,
    this.icon,
    this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.only(top: 12),
          decoration: BoxDecoration(
            color: isActive ? color.withValues(alpha: 0.08) : Colors.white,
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
            borderRadius: BorderRadius.circular(8.0),
            border:
                isActive
                    ? Border.all(color: color, width: 1.2)
                    : Border.all(color: Colors.transparent),
          ),
          child: Column(
            children: [
              // Icon + Label Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    label,
                    style: AppTextStyle.mendiumPrimaryBold.copyWith(
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // The Count
              Text(
                count,
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              // The Accent Bottom Bar
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8.0),
                  bottomRight: Radius.circular(8.0),
                ),
                child: Container(
                  height: 4,
                  width: double.infinity,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
