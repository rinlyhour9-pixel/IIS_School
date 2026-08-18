import 'package:flutter/material.dart';
import 'package:schoolapp/core/core.dart';

class CustomDropdown extends StatelessWidget {
  const CustomDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    this.initValue,
    this.hintText,
    this.validator,
    this.isReason = true,
    this.color,
    this.selectedValue,
  });

  final List<dynamic> items;
  final Function(String) onChanged;
  final String? hintText;
  final String? initValue;
  final String? Function(String?)? validator;
  final bool isReason;
  final Color? color;
  final String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Fills available horizontal space
      child: DropdownButtonFormField<String>(
        value: initValue,
        onChanged: (value) => onChanged(value!),
        validator: validator,
        dropdownColor: AppColor.white,
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColor.white,
          hintText: hintText,
          hintStyle: AppTextStyle.smallGreyRegular,
          contentPadding: 5.padHorizontal,
          border: OutlineInputBorder(
            borderRadius: UIConstants.radius.radiusAll,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: UIConstants.radius.radiusAll,
            borderSide: const BorderSide(color: AppColor.lightGrey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: UIConstants.radius.radiusAll,
            borderSide: const BorderSide(color: AppColor.lightGrey, width: 1),
          ),
        ),
        items:
            items.map<DropdownMenuItem<String>>((dynamic value) {
              return DropdownMenuItem<String>(
                value:
                    isReason ? value.id.toString() : value.deliverId.toString(),
                child: Text(
                  value.name ?? 'N/A',
                  style: TextStyle(color: color),
                ),
              );
            }).toList(),
      ),
    );
  }
}
