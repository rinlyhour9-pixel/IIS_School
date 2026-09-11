import 'package:flutter/widgets.dart';
import 'package:schoolapp/views/weighted_result/controller.dart'
    show kWeightCriteria;

/// One student's raw per-criterion scores.
///
/// Holds one [TextEditingController] per criterion. There are no `Rx` fields
/// by design: the controller *is* the source of truth and `TextField` listens
/// to it internally, so a score cell can be a plain StatelessWidget with zero
/// `Obx` — typing rebuilds nothing above `EditableText`. Mirrors
/// `score_entry/widgets/student_column.dart`'s `StudentScoreColumn`.
///
/// The one lifecycle obligation is [dispose]. See
/// `ViewScoreController._replaceResults` for why it must run *after* the
/// frame in which the item is unmounted.
class ViewScoreItem {
  ViewScoreItem({
    required this.admissionNo,
    required this.studentName,
    required this.gender,
    Map<String, int?> initialScores = const <String, int?>{},
  }) : _controllers = <String, TextEditingController>{
         for (final criterion in kWeightCriteria)
           criterion.key: TextEditingController(
             text: initialScores[criterion.key]?.toString() ?? '',
           ),
       };

  final String admissionNo;
  final String studentName;
  final String gender;

  final Map<String, TextEditingController> _controllers;

  TextEditingController controllerFor(String criterionKey) =>
      _controllers[criterionKey]!;

  /// A blank cell maps to `null` (not graded), never `0`.
  Map<String, int?> toScores() => <String, int?>{
    for (final entry in _controllers.entries)
      entry.key: int.tryParse(entry.value.text.trim()),
  };

  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
  }
}
