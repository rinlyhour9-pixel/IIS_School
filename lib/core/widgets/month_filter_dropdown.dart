import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/resources/locales.g.dart';

class MonthFilterItem {
  final int month;
  final String localeKey;
  final String fallbackLabel;

  const MonthFilterItem({
    required this.month,
    required this.localeKey,
    required this.fallbackLabel,
  });

  String get label {
    final translated = localeKey.tr;
    return translated == localeKey ? fallbackLabel : translated;
  }

  DateTime startDate(int year) => DateTime(year, month);

  DateTime endDate(int year) => DateTime(year, month + 1, 0);

  static const List<MonthFilterItem> all = <MonthFilterItem>[
    MonthFilterItem(
      month: 1,
      localeKey: LocaleKeys.monthJanuary,
      fallbackLabel: 'January',
    ),
    MonthFilterItem(
      month: 2,
      localeKey: LocaleKeys.monthFebruary,
      fallbackLabel: 'February',
    ),
    MonthFilterItem(
      month: 3,
      localeKey: LocaleKeys.monthMarch,
      fallbackLabel: 'March',
    ),
    MonthFilterItem(
      month: 4,
      localeKey: LocaleKeys.monthApril,
      fallbackLabel: 'April',
    ),
    MonthFilterItem(
      month: 5,
      localeKey: LocaleKeys.monthMay,
      fallbackLabel: 'May',
    ),
    MonthFilterItem(
      month: 6,
      localeKey: LocaleKeys.monthJune,
      fallbackLabel: 'June',
    ),
    MonthFilterItem(
      month: 7,
      localeKey: LocaleKeys.monthJuly,
      fallbackLabel: 'July',
    ),
    MonthFilterItem(
      month: 8,
      localeKey: LocaleKeys.monthAugust,
      fallbackLabel: 'August',
    ),
    MonthFilterItem(
      month: 9,
      localeKey: LocaleKeys.monthSeptember,
      fallbackLabel: 'September',
    ),
    MonthFilterItem(
      month: 10,
      localeKey: LocaleKeys.monthOctober,
      fallbackLabel: 'October',
    ),
    MonthFilterItem(
      month: 11,
      localeKey: LocaleKeys.monthNovember,
      fallbackLabel: 'November',
    ),
    MonthFilterItem(
      month: 12,
      localeKey: LocaleKeys.monthDecember,
      fallbackLabel: 'December',
    ),
  ];

  static MonthFilterItem fromMonth(int month) {
    return all.firstWhere(
      (item) => item.month == month,
      orElse: () => all.first,
    );
  }
}

class MonthFilterDropdown extends StatelessWidget {
  final List<String> months;
  final String selectedMonth;
  final ValueChanged<String> onSelected;
  final TextStyle? textStyle;
  final Color borderColor;
  final Color backgroundColor;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final bool showFilterIcon;
  final Color iconColor;
  final double menuMaxHeightFactor;
  final double? height;

  const MonthFilterDropdown({
    super.key,
    required this.months,
    required this.selectedMonth,
    required this.onSelected,
    this.textStyle,
    this.borderColor = const Color(0xFF00675B),
    this.backgroundColor = Colors.white,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    this.showFilterIcon = true,
    this.iconColor = const Color(0xFF00675B),
    this.menuMaxHeightFactor = 0.45,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final selected =
        months.contains(selectedMonth) && selectedMonth.isNotEmpty
            ? selectedMonth
            : (months.isNotEmpty ? months.first : '');

    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor),
        borderRadius: borderRadius,
      ),
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        initialValue: selected.isEmpty ? null : selected,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * menuMaxHeightFactor,
        ),
        onSelected: onSelected,
        itemBuilder: (BuildContext context) {
          return months.map((String month) {
            return PopupMenuItem<String>(
              value: month,
              child: Text(month, style: textStyle ?? const TextStyle(fontSize: 14)),
            );
          }).toList();
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                selected,
                overflow: TextOverflow.ellipsis,
                style:
                    textStyle ??
                    const TextStyle(
                      color: Color(0xFF00675B),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
              ),
            ),
            if (showFilterIcon) ...[
              const SizedBox(width: 6),
              Icon(Icons.filter_alt_outlined, color: iconColor, size: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class LocalizedMonthFilterDropdown extends StatelessWidget {
  final List<MonthFilterItem> items;
  final int selectedMonth;
  final ValueChanged<MonthFilterItem> onSelected;
  final TextStyle? textStyle;
  final Color borderColor;
  final Color backgroundColor;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final bool showFilterIcon;
  final Color iconColor;
  final double menuMaxHeightFactor;
  final double? height;

  const LocalizedMonthFilterDropdown({
    super.key,
    this.items = MonthFilterItem.all,
    required this.selectedMonth,
    required this.onSelected,
    this.textStyle,
    this.borderColor = const Color(0xFF00675B),
    this.backgroundColor = Colors.white,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    this.showFilterIcon = true,
    this.iconColor = const Color(0xFF00675B),
    this.menuMaxHeightFactor = 0.45,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final selected = items.firstWhere(
      (item) => item.month == selectedMonth,
      orElse: () => items.isNotEmpty ? items.first : MonthFilterItem.all.first,
    );

    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor),
        borderRadius: borderRadius,
      ),
      child: PopupMenuButton<MonthFilterItem>(
        padding: EdgeInsets.zero,
        initialValue: selected,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * menuMaxHeightFactor,
        ),
        onSelected: onSelected,
        itemBuilder: (BuildContext context) {
          return items.map((MonthFilterItem item) {
            return PopupMenuItem<MonthFilterItem>(
              value: item,
              child: Text(
                item.label,
                style: textStyle ?? const TextStyle(fontSize: 14),
              ),
            );
          }).toList();
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                selected.label,
                overflow: TextOverflow.ellipsis,
                style:
                    textStyle ??
                    const TextStyle(
                      color: Color(0xFF00675B),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
              ),
            ),
            if (showFilterIcon) ...[
              const SizedBox(width: 6),
              Icon(Icons.filter_alt_outlined, color: iconColor, size: 16),
            ],
          ],
        ),
      ),
    );
  }
}
