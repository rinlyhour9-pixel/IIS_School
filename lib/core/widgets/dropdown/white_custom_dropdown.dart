import 'package:flutter/material.dart';
import 'package:schoolapp/core/core.dart';

class AppIconDropdown<T> extends StatelessWidget {
  const AppIconDropdown({
    super.key,
    this.icon,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.isLoading = false,
    this.hintText = 'Select',
    this.loadingText = 'Loading...',
    this.emptyText = 'No options available',
  });

  final IconData? icon;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;
  final bool isLoading;
  final String hintText;
  final String loadingText;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    final selectedValue = value != null && items.contains(value) ? value : null;

    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: EdgeInsets.only(right: 8, left: icon == null ? 12 : 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 52,
              height: 48,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(right: BorderSide(color: Color(0xFFE0E0E0))),
              ),
              child: Icon(icon, color: Colors.black54, size: 20),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: selectedValue,
                isExpanded: true,
                hint: Text(
                  isLoading
                      ? loadingText
                      : (items.isEmpty ? emptyText : hintText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                borderRadius: BorderRadius.circular(12),
                dropdownColor: Colors.white,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColor.darkGrey,
                ),
                style: AppTextStyle.normalPrimaryRegular,
                items:
                    items
                        .map(
                          (item) => DropdownMenuItem<T>(
                            value: item,
                            child: Text(
                              itemLabel(item),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                onChanged:
                    items.isEmpty
                        ? null
                        : (picked) {
                          // Re-tapping the already-selected item clears it.
                          onChanged(picked == selectedValue ? null : picked);
                        },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
