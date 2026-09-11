import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/models/models.dart';
import 'package:schoolapp/views/score_entry/models.dart';
import 'package:schoolapp/views/score_entry/widgets/student_column.dart';

enum ResultType {
  monthly('Monthly Exam'),
  semester('Semester Exam');

  const ResultType(this.label);

  final String label;
}

class ScoreEntryController extends GetxController {
  final RxList<ScoreEntryAssignment> _assignments =
      <ScoreEntryAssignment>[].obs;
  final RxList<ClassModel> classes = <ClassModel>[].obs;
  final RxBool isLoadingAssignments = false.obs;

  final RxList<String> months = <String>[].obs;
  final RxList<String> semesters = <String>[].obs;
  final RxBool isLoadingFilters = false.obs;

  final Rx<ClassModel?> selectedClass = Rx<ClassModel?>(null);

  final RxnString selectedSection = RxnString();
  final Rx<ResultType?> selectedResultType = Rx<ResultType?>(null);
  final RxnString selectedPeriod = RxnString();

  /// The column axis of the sheet — one column per student.
  final RxList<StudentScoreColumn> students = <StudentScoreColumn>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;

  final RxBool hasFiltered = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadFilters();
    _loadAssignments();
  }

  @override
  void onClose() {
    for (final student in students) {
      student.dispose();
    }
    super.onClose();
  }

  Future<void> _loadFilters() async {
    try {
      isLoadingFilters.value = true;
      final res = await Get.find<ApiService>().get(
        EndPoints.scoreEntryFilters,
        isShowLoading: false,
      );
      final data = res.data;
      if (data is! Map) return;

      final filters = ScoreEntryFilters.fromJson(
        Map<String, dynamic>.from(data),
      );
      months.assignAll(filters.monthOptions);
      semesters.assignAll(filters.semesterOptions);
    } catch (e) {
      ExceptionHandler.handleException(e, alert: false);
    } finally {
      isLoadingFilters.value = false;
    }
  }

  Future<void> _loadAssignments() async {
    try {
      isLoadingAssignments.value = true;
      final res = await Get.find<ApiService>().get(
        EndPoints.scoreEntryAssignments,
        isShowLoading: false,
      );
      final data = res.data;
      if (data is! Map) return;
      final body = Map<String, dynamic>.from(data['data'] as Map? ?? const {});
      _assignments.assignAll(
        ScoreEntryAssignment.listFromJson(
          (body['assignments'] as List?) ?? const [],
        ),
      );

      final seenClassIds = <int>{};
      classes.assignAll([
        for (final a in _assignments)
          if (seenClassIds.add(a.classId))
            ClassModel(id: a.classId, teacherId: 0, className: a.className),
      ]);
    } catch (e) {
      ExceptionHandler.handleException(e, alert: false);
    } finally {
      isLoadingAssignments.value = false;
    }
  }

  /// Session/time-slot options ("Section" in the UI) for the selected class
  /// — only meaningful once a class is picked.
  List<String> get sectionsForSelectedClass {
    final classId = selectedClass.value?.id;
    if (classId == null) return const <String>[];
    final seen = <String>{};
    return [
      for (final a in _assignments)
        if (a.classId == classId && seen.add(a.sessionSectionLabel))
          a.sessionSectionLabel,
    ];
  }

  /// The assignment rows Level+Section resolve to — one per subject taught
  /// in that class+session. Empty until both are picked.
  List<ScoreEntryAssignment> get resolvedAssignments {
    final classId = selectedClass.value?.id;
    final section = selectedSection.value;
    if (classId == null || section == null) return const [];
    return [
      for (final a in _assignments)
        if (a.classId == classId && a.sessionSectionLabel == section) a,
    ];
  }

  List<ScoreEntryAssignment> get _resolvedAssignmentsBySubject {
    final seen = <int>{};
    return [
      for (final a in resolvedAssignments)
        if (seen.add(a.subjectId)) a,
    ];
  }

  /// The row axis of the sheet — distinct subjects among [resolvedAssignments].
  List<SubjectModel> get subjectsForResolvedAssignments => [
    for (final a in _resolvedAssignmentsBySubject)
      SubjectModel(id: a.subjectId, name: a.subjectName, code: ''),
  ];

  List<int> get resolvedAssignmentIds =>
      _resolvedAssignmentsBySubject.map((a) => a.id).toList();

  List<String> get periodItems => switch (selectedResultType.value) {
    ResultType.monthly => months.toList(),
    ResultType.semester => semesters.toList(),
    null => const <String>[],
  };

  bool get canFilter =>
      selectedClass.value != null &&
      selectedSection.value != null &&
      selectedResultType.value != null &&
      (selectedPeriod.value ?? '').isNotEmpty &&
      resolvedAssignmentIds.isNotEmpty;

  bool get hasUnsavedScores => students.any((s) => s.hasAnyScore);

  void selectClass(ClassModel? value) {
    selectedClass.value = value;
    // Section options depend on the selected class.
    selectedSection.value = null;
  }

  void selectSection(String? value) => selectedSection.value = value;

  void selectResultType(ResultType? value) {
    selectedResultType.value = value;

    selectedPeriod.value = null;
  }

  void selectPeriod(String? value) => selectedPeriod.value = value;

  Future<void> applyFilter() async {
    if (!canFilter) {
      _warn('Select level, section, result type and period first');
      return;
    }

    isLoading.value = true;
    hasFiltered.value = true;
    _replaceStudents(const <StudentScoreColumn>[]);

    try {
      final subjectIds =
          subjectsForResolvedAssignments.map((s) => s.id).toList();
      final res = await Get.find<ApiService>().get(
        EndPoints.scoreEntryStudents,
        queryParameters: {
          'assignment_ids': resolvedAssignmentIds.join(','),
          'period': selectedPeriod.value,
        },
        isShowLoading: false,
      );
      final data = res.data;
      if (data is! Map) return;
      final body = Map<String, dynamic>.from(data['data'] as Map? ?? const {});
      final records = ScoreEntryStudentRecord.listFromJson(
        (body['students'] as List?) ?? const [],
      );

      final next =
          records
              .map(
                (record) => StudentScoreColumn(
                  id: record.id,
                  admissionNo: record.admissionNo,
                  studentName: record.name,
                  gender: record.gender,
                  subjectIds: subjectIds,
                  initialScores: _initialScoresFor(record),
                ),
              )
              .toList();
      _replaceStudents(next);
    } catch (e) {
      _replaceStudents(const <StudentScoreColumn>[]);
      ExceptionHandler.handleException(e, alert: false);
    } finally {
      isLoading.value = false;
    }
  }

  /// Maps a record's `scores` (subject id string → dynamic value) onto
  /// `StudentScoreColumn`'s `Map<int, int?>` — skipping any entry whose key
  /// isn't a parseable int or whose value isn't a whole number, rather than
  /// crashing or silently keying a score under a bogus subject id.
  ///
  /// The live endpoint returns each score as a numeric *string* (e.g.
  /// `"23": "50"`), not a JSON number — confirmed by a real saved score not
  /// showing up in the app until this handled `String` values too.
  Map<int, int?> _initialScoresFor(ScoreEntryStudentRecord record) {
    final result = <int, int?>{};
    for (final entry in record.scores.entries) {
      final subjectId = int.tryParse(entry.key);
      if (subjectId == null) continue;
      final value = entry.value;
      if (value is int) {
        result[subjectId] = value;
      } else if (value is num) {
        result[subjectId] = value.toInt();
      } else if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) result[subjectId] = parsed;
      }
    }
    return result;
  }

  void _replaceStudents(List<StudentScoreColumn> next) {
    final outgoing = List<StudentScoreColumn>.of(students);
    students.assignAll(next);
    if (outgoing.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final student in outgoing) {
        student.dispose();
      }
    });
  }

  Future<void> save() async {
    if (!canFilter) {
      _warn('Select level, section, result type and period first');
      return;
    }
    if (students.isEmpty) {
      _warn('No students to save');
      return;
    }

    try {
      isSubmitting.value = true;

      final body = <String, dynamic>{
        'assignment_ids': resolvedAssignmentIds,
        'period': selectedPeriod.value,
        'scores': _encodeScores(students),
      };

      await Get.find<ApiService>().post(
        EndPoints.scoreEntrySave,
        body,
        isShowLoading: false,
      );

      _success('Scores saved successfully');
    } catch (e) {
      _error('Failed to save scores');
      ExceptionHandler.handleException(e, alert: true);
    } finally {
      isSubmitting.value = false;
    }
  }

  /// `{ "<student_id>": { "<subject_id>": "<score>" } }`.
  ///
  /// The docs describe this field only as `array[string]`, which is what
  /// Scramble infers from PHP — a JSON object with numeric keys *is* an
  /// array of strings on the Laravel side. Confirmed by probing the live
  /// endpoint: this shape persists, while a positional list of strings (any
  /// delimiter, or JSON-per-student) is accepted with 200 "Scores saved."
  /// and then silently discarded.
  ///
  /// Blank cells are sent as `""` rather than omitted — also confirmed
  /// against the live endpoint, an empty string clears a previously saved
  /// score, whereas omitting the key would leave the old value in place and
  /// make it impossible to erase one.
  Map<String, Map<String, String>> _encodeScores(
    List<StudentScoreColumn> students,
  ) {
    return <String, Map<String, String>>{
      for (final student in students)
        student.id.toString(): <String, String>{
          for (final entry in student.toPayload().entries)
            entry.key: entry.value?.toString() ?? '',
        },
    };
  }

  void _success(String message) =>
      _snack('Success', message, const Color(0xFF14925A));

  void _error(String message) =>
      _snack('Error', message, const Color(0xFFD32F2F));

  void _warn(String message) =>
      _snack('Missing selection', message, const Color(0xFFD32F2F));

  void _snack(String title, String message, Color background) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: background,
      titleText: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
      messageText: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
