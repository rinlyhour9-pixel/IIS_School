import 'package:flutter/services.dart';

/// Layout constants for the transposed score sheet.
///
/// Students run across the top as columns; subjects run down the left as
/// rows. The subject column is frozen; the student columns scroll
/// horizontally.
// Frozen left column, holding subject names.
const double kSubjectColWidth = 116;

/// One student column. Must fit an admission number ("iiS9-00001" is ~68px at
/// 12px text) plus a name wrapped to two lines, with padding.
const double kStudentColWidth = 124;

/// Fixed heights are load-bearing: the frozen block and the scrolling block
/// are independent widget subtrees, so intrinsic sizing would let them drift
/// by a pixel and visually shear. Never use the `int.height` extension for
/// these — it scales by screen width.
///
/// The header stacks three lines: admission no, name (up to 2 lines), gender.
const double kHeaderHeight = 96;
const double kRowHeight = 64;

/// Empty strip below the last row so the always-visible horizontal scrollbar
/// has its own lane instead of overlaying the bottom row's inputs. Both the
/// frozen and scrolling columns reserve it, so the two stay aligned.
const double kScrollbarLaneHeight = 14;

/// Every subject is scored out of 100.
const int kSubjectMaxScore = 100;

double scrollableWidthFor(int studentCount) => studentCount * kStudentColWidth;

/// Rejects any keystroke that would push the value above [max].
///
/// Rejecting rather than clamping is deliberate: clamping mid-typing turns an
/// intended `100` into a fight with the field. Pair this with
/// [FilteringTextInputFormatter.digitsOnly], which runs first.
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
