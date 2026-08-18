import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';

class CustomTopTabBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onChanged;

  const CustomTopTabBar({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _TabItem(Icons.list_alt_rounded, LocaleKeys.all.tr),
      _TabItem(Icons.schedule_rounded, LocaleKeys.pending.tr),
      _TabItem(Icons.check_circle_outline_rounded, LocaleKeys.approved.tr),
      _TabItem(Icons.cancel_outlined, LocaleKeys.rejected.tr),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE1EAE8)),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final tab = tabs[index];
          final isSelected = selectedIndex == index;

          return Expanded(
            child: InkWell(
              onTap: () => onChanged(index),
              borderRadius: BorderRadius.circular(11),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOutCubic,
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow:
                      isSelected
                          ? const [
                            BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ]
                          : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tab.icon,
                      size: 14,
                      color:
                          isSelected
                              ? AppColor.primaryColor
                              : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 3),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          tab.title,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                isSelected
                                    ? AppColor.primaryColor
                                    : const Color(0xFF64748B),
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            fontFamily: AppFontFamily.forText(tab.title),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final String title;

  const _TabItem(this.icon, this.title);
}
