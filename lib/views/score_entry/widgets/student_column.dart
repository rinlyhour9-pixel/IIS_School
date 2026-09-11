import 'package:flutter/widgets.dart';

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

  TextEditingController? controllerFor(int subjectId) =>
      _controllers[subjectId];

  bool get hasAnyScore =>
      _controllers.values.any((c) => c.text.trim().isNotEmpty);

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
