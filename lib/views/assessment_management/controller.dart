import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/models/models.dart';
import 'package:schoolapp/views/assessment_management/models.dart';
import 'package:schoolapp/views/assessment_management/widgets/student_column.dart';

export 'package:schoolapp/views/assessment_management/widgets/student_column.dart'
    show AssessmentStudentColumn;
export 'package:schoolapp/views/assessment_management/models.dart'
    show AssessmentCriterion, AssessmentField, AssessmentFieldKind;

enum AssessmentResultType {
  monthly('Monthly Exam'),
  quarterly('Quarterly Exam'),
  semester('Semester Exam');

  const AssessmentResultType(this.label);

  final String label;
}

class AssessmentManagementController extends GetxController {
  /// Raw class/subject assignment rows, the source of truth for both
  /// [classes] and [subjectsForSelectedClass].
  final RxList<AssessmentAssignment> _assignments =
      <AssessmentAssignment>[].obs;
  final RxList<ClassModel> classes = <ClassModel>[].obs;
  final RxBool isLoadingAssignments = false.obs;

  /// Populated from the real assessment-management/filters endpoint.
  final RxList<AssessmentCriterion> criteria = <AssessmentCriterion>[].obs;
  final RxList<String> months = <String>[].obs;
  final RxList<String> quarters = <String>[].obs;
  final RxList<String> semesters = <String>[].obs;
  final RxList<AssessmentSubjectScore> quarterlySubjects =
      <AssessmentSubjectScore>[].obs;
  final RxList<AssessmentBilingualCriterion> quarterlyCriteria =
      <AssessmentBilingualCriterion>[].obs;
  final RxList<AssessmentSubjectScore> semesterSubjects =
      <AssessmentSubjectScore>[].obs;
  final RxBool isLoadingFilters = false.obs;

  final Rx<ClassModel?> selectedClass = Rx<ClassModel?>(null);
  final Rx<SubjectModel?> selectedSubject = Rx<SubjectModel?>(null);

  final RxnString selectedSection = RxnString();
  final Rx<AssessmentResultType?> selectedResultType =
      Rx<AssessmentResultType?>(null);
  final RxnString selectedPeriod = RxnString();

  /// The column axis of the sheet — one column per student.
  final RxList<AssessmentStudentColumn> students =
      <AssessmentStudentColumn>[].obs;

  final RxList<AssessmentField> activeFields = <AssessmentField>[].obs;
  final RxBool activeHasComment = false.obs;

  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;

  /// Distinguishes "you haven't filtered yet" from "that filter had no
  /// students".
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
        EndPoints.assessmentManagementFilters,
        isShowLoading: false,
      );
      final data = res.data;
      if (data is! Map) return;

      final filters = AssessmentManagementFilters.fromJson(
        Map<String, dynamic>.from(data),
      );
      criteria.assignAll(filters.criteria);
      months.assignAll(filters.monthOptions);
      quarters.assignAll(filters.quarterOptions);
      semesters.assignAll(filters.semesterOptions);
      quarterlySubjects.assignAll(filters.quarterlySubjects);
      quarterlyCriteria.assignAll(filters.quarterlyCriteria);
      semesterSubjects.assignAll(filters.semesterSubjects);
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
        EndPoints.assessmentManagementAssignments,
        isShowLoading: false,
      );
      final data = res.data;
      if (data is! Map) return;
      final body = Map<String, dynamic>.from(data['data'] as Map? ?? const {});
      _assignments.assignAll(
        AssessmentAssignment.listFromJson(
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

  List<SubjectModel> get subjectsForSelectedClass {
    final classId = selectedClass.value?.id;
    final seenSubjectIds = <int>{};
    return [
      for (final a in _assignments)
        if ((classId == null || a.classId == classId) &&
            seenSubjectIds.add(a.subjectId))
          SubjectModel(id: a.subjectId, name: a.subjectName, code: ''),
    ];
  }

  List<String> get sectionsForSelectedClassAndSubject {
    final classId = selectedClass.value?.id;
    final subjectId = selectedSubject.value?.id;
    if (classId == null || subjectId == null) return const <String>[];
    final seen = <String>{};
    return [
      for (final a in _assignments)
        if (a.classId == classId &&
            a.subjectId == subjectId &&
            seen.add(a.sessionSectionLabel))
          a.sessionSectionLabel,
    ];
  }

  int? get resolvedAssignmentId {
    final classId = selectedClass.value?.id;
    final subjectId = selectedSubject.value?.id;
    final section = selectedSection.value;
    if (classId == null || subjectId == null || section == null) return null;
    for (final a in _assignments) {
      if (a.classId == classId &&
          a.subjectId == subjectId &&
          a.sessionSectionLabel == section) {
        return a.id;
      }
    }
    return null;
  }

  List<String> get periodItems => switch (selectedResultType.value) {
    AssessmentResultType.monthly => months.toList(),
    AssessmentResultType.quarterly => quarters.toList(),
    AssessmentResultType.semester => semesters.toList(),
    null => const <String>[],
  };

  bool get hasTeacherComment =>
      selectedResultType.value == AssessmentResultType.quarterly ||
      selectedResultType.value == AssessmentResultType.semester;

  List<AssessmentField> get fieldsForSelectedResultType {
    switch (selectedResultType.value) {
      case AssessmentResultType.monthly:
        return [
          for (final c in criteria)
            AssessmentField.score(
              key: 'criterion_${c.id}',
              label: c.name,
              maxScore: c.maxScore,
            ),
        ];
      case AssessmentResultType.quarterly:
        return [
          for (final s in quarterlySubjects)
            AssessmentField.score(
              key: 'q_subject_${s.name}',
              label: s.name,
              maxScore: s.max,
            ),
          for (final c in quarterlyCriteria)
            AssessmentField.score(
              key: 'q_criterion_${c.en}',
              label: c.en,
              maxScore: 5,
            ),
        ];
      case AssessmentResultType.semester:
        return [
          const AssessmentField.group('First Quarter'),
          for (final s in semesterSubjects)
            AssessmentField.score(
              key: 'sem_q1_${s.name}',
              label: s.name,
              maxScore: s.max,
            ),
          const AssessmentField.group('Second Quarter'),
          for (final s in semesterSubjects)
            AssessmentField.score(
              key: 'sem_q2_${s.name}',
              label: s.name,
              maxScore: s.max,
            ),
        ];
      case null:
        return const <AssessmentField>[];
    }
  }

  bool get canFilter =>
      selectedClass.value != null &&
      selectedSubject.value != null &&
      selectedSection.value != null &&
      selectedResultType.value != null &&
      (selectedPeriod.value ?? '').isNotEmpty &&
      resolvedAssignmentId != null;

  bool get hasUnsavedScores => students.any((s) => s.hasAnyInput);

  void selectClass(ClassModel? value) {
    selectedClass.value = value;

    selectedSubject.value = null;
    selectedSection.value = null;
  }

  void selectSubject(SubjectModel? value) {
    selectedSubject.value = value;
    // Section options depend on the selected subject too.
    selectedSection.value = null;
  }

  void selectSection(String? value) => selectedSection.value = value;

  void selectResultType(AssessmentResultType? value) {
    selectedResultType.value = value;
    // A stale month while the items are quarters/semesters would render as
    // the hint, but the controller would still carry it.
    selectedPeriod.value = null;
  }

  void selectPeriod(String? value) => selectedPeriod.value = value;

  Future<void> applyFilter() async {
    if (!canFilter) {
      _warn('Select level, subject, section, result type and month first');
      return;
    }

    isLoading.value = true;
    hasFiltered.value = true;
    _replaceStudents(const <AssessmentStudentColumn>[]);

    try {
      final fields = fieldsForSelectedResultType;
      final withComment = hasTeacherComment;
      final resultType = selectedResultType.value!;
      activeFields.assignAll(fields);
      activeHasComment.value = withComment;

      final res = await Get.find<ApiService>().get(
        EndPoints.assessmentManagementStudents,
        queryParameters: {
          'assignment_id': resolvedAssignmentId,
          'period': selectedPeriod.value,
          'result_type': resultType.name,
        },
        isShowLoading: false,
      );
      final data = res.data;
      if (data is! Map) return;
      final body = Map<String, dynamic>.from(data['data'] as Map? ?? const {});
      final records = AssessmentStudentRecord.listFromJson(
        (body['students'] as List?) ?? const [],
      );

      final next =
          records
              .map(
                (record) => AssessmentStudentColumn(
                  id: record.id,
                  admissionNo: record.admissionNo,
                  studentName: record.name,
                  gender: record.gender,
                  fields: fields,
                  withComment: withComment,
                  initialValues: _initialValuesFor(record, resultType),
                ),
              )
              .toList();
      _replaceStudents(next);
    } catch (e) {
      _replaceStudents(const <AssessmentStudentColumn>[]);
      ExceptionHandler.handleException(e, alert: false);
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, String> _initialValuesFor(
    AssessmentStudentRecord record,
    AssessmentResultType resultType,
  ) {
    switch (resultType) {
      case AssessmentResultType.monthly:
        // Monthly comes back as a map keyed by criterion id.
        return <String, String>{
          for (final entry in record.scores.entries)
            if (entry.value != null)
              'criterion_${entry.key}': _displayScore(entry.value),
        };
      case AssessmentResultType.quarterly:
        return <String, String>{
          ..._fromPositional(_quarterSubjectKeys, record.quarterScores),
          ..._fromPositional(_quarterCriterionKeys, record.quarterEvaluation),
          'comment': record.teacherComment,
        };
      case AssessmentResultType.semester:
        return <String, String>{
          ..._fromPositional(_semesterKeys('sem_q1_'), record.firstQuarter),
          ..._fromPositional(_semesterKeys('sem_q2_'), record.secondQuarter),
          'comment': record.teacherComment,
        };
    }
  }

  /// Zips a positional array from the API back onto our field keys, in the
  /// same order [_encodePositional] writes them.
  Map<String, String> _fromPositional(
    List<String> fieldKeysInOrder,
    List<dynamic> values,
  ) {
    return <String, String>{
      for (var i = 0; i < fieldKeysInOrder.length && i < values.length; i++)
        if (values[i] != null && values[i].toString().isNotEmpty)
          fieldKeysInOrder[i]: _displayScore(values[i]),
    };
  }

  /// The API returns saved scores as decimal strings (e.g. `"5.00"`), which
  /// would show up verbatim in a whole-number score field. Renders a whole
  /// value as `5`, leaving anything genuinely fractional untouched.
  String _displayScore(dynamic value) {
    final parsed = value is num ? value : num.tryParse(value.toString());
    if (parsed == null) return value.toString();
    return parsed == parsed.roundToDouble()
        ? parsed.toInt().toString()
        : parsed.toString();
  }

  void _replaceStudents(List<AssessmentStudentColumn> next) {
    final outgoing = List<AssessmentStudentColumn>.of(students);
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
      _warn('Select level, subject, section, result type and month first');
      return;
    }
    if (students.isEmpty) {
      _warn('No students to save');
      return;
    }

    try {
      isSubmitting.value = true;

      final resultType = selectedResultType.value!;
      final endpoint = switch (resultType) {
        AssessmentResultType.monthly => EndPoints.assessmentManagementSave,
        AssessmentResultType.quarterly =>
          EndPoints.assessmentManagementSaveQuarterly,
        AssessmentResultType.semester =>
          EndPoints.assessmentManagementSaveSemester,
      };
      final body = switch (resultType) {
        AssessmentResultType.monthly => _monthlyBody(),
        AssessmentResultType.quarterly => _quarterlyBody(),
        AssessmentResultType.semester => _semesterBody(),
      };

      await Get.find<ApiService>().post(endpoint, body, isShowLoading: false);

      _success('Scores saved successfully');
    } catch (e) {
      ExceptionHandler.handleException(e, alert: true);
    } finally {
      isSubmitting.value = false;
    }
  }

  Map<String, dynamic> _monthlyBody() => {
    'assignment_id': resolvedAssignmentId,
    'period': selectedPeriod.value,
    'scores': _encodeScores(students, 'criterion_'),
  };

  Map<String, dynamic> _quarterlyBody() => {
    'assignment_id': resolvedAssignmentId,
    'period': selectedPeriod.value,
    'scores': _encodePositional(students, _quarterSubjectKeys),
    'evaluation': _encodePositional(students, _quarterCriterionKeys),
    'teacher_note': _encodeComments(students),
  };

  Map<String, dynamic> _semesterBody() => {
    'assignment_id': resolvedAssignmentId,
    'period': selectedPeriod.value,
    'first_quarter': _encodePositional(students, _semesterKeys('sem_q1_')),
    'second_quarter': _encodePositional(students, _semesterKeys('sem_q2_')),
    'teacher_note': _encodeComments(students),
  };

  /// Field keys in the exact order the API's positional arrays use — which
  /// is the order the filters endpoint returned them in.
  List<String> get _quarterSubjectKeys => [
    for (final s in quarterlySubjects) 'q_subject_${s.name}',
  ];

  List<String> get _quarterCriterionKeys => [
    for (final c in quarterlyCriteria) 'q_criterion_${c.en}',
  ];

  List<String> _semesterKeys(String prefix) => [
    for (final s in semesterSubjects) '$prefix${s.name}',
  ];

  /// `{ "<student_id>": ["<score>", "<score>", ...] }`.
  ///
  /// Quarterly/Semester don't use Monthly's id-keyed map — confirmed against
  /// the live endpoints, they're *positional* arrays sized to the filters
  /// lists (9 `quarterly_subjects`, 10 `quarterly_criteria`, 7
  /// `semester_subjects`), matching how the students endpoint returns
  /// `quarter_scores`/`quarter_evaluation`/`first_quarter`/`second_quarter`.
  /// A blank cell is sent as `""`, holding its slot.
  Map<String, List<String>> _encodePositional(
    List<AssessmentStudentColumn> students,
    List<String> fieldKeysInOrder,
  ) {
    return <String, List<String>>{
      for (final student in students)
        student.id.toString(): [
          for (final key in fieldKeysInOrder)
            student.controllerFor(key)?.text.trim() ?? '',
        ],
    };
  }

  /// `{ "<student_id>": { "<field_id>": "<score>" } }`, keeping only fields
  /// whose internal key carries [prefix] and stripping it, so the API sees
  /// its own bare identifier (e.g. `criterion_3` → `3`).
  ///
  /// The docs describe these fields only as `array[string]`, which is what
  /// Scramble infers from PHP — a JSON object with numeric keys *is* an
  /// array of strings on the Laravel side. Confirmed against the live
  /// Monthly endpoint: this shape persists, while a positional list of
  /// strings is accepted with 200 "Scores saved." and silently discarded.
  /// Blank cells are sent as `""`, which clears a previously saved score.
  Map<String, Map<String, String>> _encodeScores(
    List<AssessmentStudentColumn> students,
    String prefix,
  ) {
    return <String, Map<String, String>>{
      for (final student in students)
        student.id.toString(): <String, String>{
          for (final entry in student.toPayload().entries)
            if (entry.key != 'comment' && entry.key.startsWith(prefix))
              entry.key.substring(prefix.length): entry.value?.toString() ?? '',
        },
    };
  }

  /// `{ "<student_id>": "<note>" }` — same student-keyed shape as
  /// [_encodeScores], with one free-text note per student instead of a
  /// per-field map.
  Map<String, String> _encodeComments(
    List<AssessmentStudentColumn> students,
  ) => <String, String>{
    for (final student in students)
      student.id.toString(): (student.toPayload()['comment'] as String?) ?? '',
  };

  void _success(String message) =>
      _snack('Success', message, const Color(0xFF14925A));

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
