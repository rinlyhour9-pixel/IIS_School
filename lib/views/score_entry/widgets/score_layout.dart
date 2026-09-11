import 'package:flutter/services.dart';

const double kSubjectColWidth = 116;
const double kStudentColWidth = 124;
const double kHeaderHeight = 96;
const double kRowHeight = 64;
const double kScrollbarLaneHeight = 14;
const int kSubjectMaxScore = 100;
double scrollableWidthFor(int studentCount) => studentCount * kStudentColWidth;

class MaxScoreInputFormatter extends TextInputFormatter {
  const MaxScoreInputFormatter(this.max);

  final int max;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    final parsed = int.tryParse(newValue.text);
    if (parsed == null || parsed > max) return oldValue;
    return newValue;
  }
}
