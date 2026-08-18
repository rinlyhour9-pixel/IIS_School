import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/resources/locales.g.dart';

class PaymentStatusTabBar extends StatelessWidget {
  const PaymentStatusTabBar({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final List<Map<String, Object>> tabs = [
      {'icon': Icons.menu_rounded, 'title': LocaleKeys.all.tr},
      {'icon': Icons.check_circle_outline_rounded, 'title': LocaleKeys.paid.tr},
      {'icon': Icons.pending_outlined, 'title': LocaleKeys.unpaid.tr},
    ];

    return Container(
      color: Colors.white,
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = selectedIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(index),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        tabs[index]['icon'] as IconData,
                        size: 16,
                        color: isSelected ? Colors.black : Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        tabs[index]['title'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.black : Colors.grey,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    height: 3,
                    width: double.infinity,
                    color:
                        isSelected
                            ? const Color(0xFF0B7A53)
                            : const Color(0xFFDCE5EA),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
