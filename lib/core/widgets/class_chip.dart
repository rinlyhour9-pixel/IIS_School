import 'package:flutter/material.dart';
import 'package:schoolapp/core/configs/app_style.dart';

/// A pill showing a class name, optionally selectable.
///
/// Used on the student-facing Class Activity and Homework screens to switch
/// between the classes a student is enrolled in, and as a plain (non-tappable)
/// badge on the teacher screens.
class ClassChip extends StatelessWidget {
  const ClassChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final bool selected;

  /// When null the chip renders as a plain badge with no tap behaviour.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? Colors.white : const Color(0xFF1F2937);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColor.primary : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColor.primary : const Color(0xFFD6E4E0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.groups_rounded,
              size: 14,
              color: selected ? Colors.white : AppColor.primary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
