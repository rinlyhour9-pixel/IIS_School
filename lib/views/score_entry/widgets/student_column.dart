import 'package:flutter/widgets.dart';

/// One student's column in the transposed score sheet.
///
/// Holds one [TextEditingController] per subject row. There are no `Rx`
/// fields by design: the controller *is* the source of truth and `TextField`
/// listens to it internally, so a score cell can be a plain StatelessWidget
/// with zero `Obx` — typing rebuilds nothing above `EditableText`, and there
/// are no listeners to tear down.
///
/// The one lifecycle obligation is [dispose]. See
/// `ScoreEntryController._replaceStudents` for why it must run *after* the
/// frame in which the column is unmounted.
class StudentScoreColumn {
  StudentScoreColumn({
    required this.id,
    required this.admissionNo,
    required this.studentName,
    required this.gender,
    required List<int> subjectIds,
    Map<int, int?> initialScores = const <int, int?>{},
  }) : _controllers = <int, TextEditingController>{
         for (final subjectId in subjectIds)
           subjectId: TextEditingController(
             text: initialScores[subjectId]?.toString() ?? '',
           ),
       };

  final int id;
  final String admissionNo;
  final String studentName;
  final String gender;

  final Map<int, TextEditingController> _controllers;

  /// Nullable on purpose: if the subject list ever changes after the students
  /// were built, the cell renders blank rather than throwing.
  TextEditingController? controllerFor(int subjectId) =>
      _controllers[subjectId];

  bool get hasAnyScore =>
      _controllers.values.any((c) => c.text.trim().isNotEmpty);

  /// A blank cell maps to `null` (not graded), never `0`.
  Map<String, int?> toPayload() => <String, int?>{
    for (final entry in _controllers.entries)
      entry.key.toString(): int.tryParse(entry.value.text.trim()),
  };

  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
  }
}
