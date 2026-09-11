import 'package:flutter/widgets.dart';
import 'package:schoolapp/views/assessment_management/models.dart'
    show AssessmentField, AssessmentFieldKind;

/// One student's column in the assessment sheet.
///
/// Holds one [TextEditingController] per scoreable [AssessmentField] (group
/// header rows hold no input, so they're skipped), plus an optional
/// [commentController] for Quarterly/Semester's free-text "Teacher Comment".
/// No `Rx` fields by design: the controller *is* the source of truth and
/// `TextField` listens to it internally, so a score cell can be a plain
/// StatelessWidget with zero `Obx` — typing rebuilds nothing above
/// `EditableText`.
///
/// The one lifecycle obligation is [dispose]. See
/// `AssessmentManagementController._replaceStudents` for why it must run
/// *after* the frame in which the column is unmounted.
class AssessmentStudentColumn {
  AssessmentStudentColumn({
    required this.id,
    required this.admissionNo,
    required this.studentName,
    required this.gender,
    required List<AssessmentField> fields,
    bool withComment = false,
    Map<String, String> initialValues = const <String, String>{},
  }) : _controllers = <String, TextEditingController>{
         for (final field in fields)
           if (field.kind == AssessmentFieldKind.score)
             field.key: TextEditingController(
               text: initialValues[field.key] ?? '',
             ),
       },
       commentController =
           withComment
               ? TextEditingController(text: initialValues['comment'] ?? '')
               : null;

  /// The real student id from the API — the key the save endpoint expects.
  final int id;
  final String admissionNo;
  final String studentName;
  final String gender;

  final Map<String, TextEditingController> _controllers;

  /// Null when this result type has no Teacher Comment section (Monthly).
  final TextEditingController? commentController;

  /// Nullable on purpose: if the field list ever changes after the students
  /// were built, the cell renders blank rather than throwing.
  TextEditingController? controllerFor(String fieldKey) =>
      _controllers[fieldKey];

  bool get hasAnyInput =>
      _controllers.values.any((c) => c.text.trim().isNotEmpty) ||
      (commentController?.text.trim().isNotEmpty ?? false);

  /// A blank score cell maps to `null` (not graded), never `0`.
  Map<String, dynamic> toPayload() => <String, dynamic>{
    for (final entry in _controllers.entries)
      entry.key: int.tryParse(entry.value.text.trim()),
    if (commentController != null) 'comment': commentController!.text.trim(),
  };

  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    commentController?.dispose();
  }
}
