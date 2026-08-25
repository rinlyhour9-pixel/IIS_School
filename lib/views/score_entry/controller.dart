import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/models/models.dart';
import 'package:schoolapp/views/score_entry/mock_data.dart';
import 'package:schoolapp/views/score_entry/widgets/student_column.dart';

enum ResultType {
  monthly('Monthly Exam'),
  quarterly('Quarterly Exam');

  const ResultType(this.label);

  final String label;
}

const List<String> _kMonths = <String>[
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const List<String> _kQuarters = <String>[
  '1st Quarter',
  '2nd Quarter',
  '3rd Quarter',
  '4th Quarter',
];

class ScoreEntryController extends GetxController {
  // TODO(api): all three are static fixtures for now — swap for the real
  // `/api/v1/setting/*` lookups (or a dedicated score-sheet endpoint) when
  // the backend is ready.
  final RxList<ClassModel> classes = <ClassModel>[...kMockClasses].obs;
  final RxList<SectionModel> sections = <SectionModel>[...kMockSections].obs;

  /// The row axis of the sheet — one row per subject.
  final RxList<SubjectModel> subjects = <SubjectModel>[...kMockSubjects].obs;

  final RxBool isLoadingOptions = false.obs;

  final Rx<ClassModel?> selectedClass = Rx<ClassModel?>(null);
  final Rx<SectionModel?> selectedSection = Rx<SectionModel?>(null);
  final Rx<ResultType?> selectedResultType = Rx<ResultType?>(null);
  final RxnString selectedPeriod = RxnString();

  /// The column axis of the sheet — one column per student.
  final RxList<StudentScoreColumn> students = <StudentScoreColumn>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;

  /// Distinguishes "you haven't filtered yet" from "that filter had no
  /// students" — record_attendance conflates the two and shows "No students
  /// found" before you have picked anything.
  final RxBool hasFiltered = false.obs;

  // No onInit fetch: every dropdown is populated from static fixtures at
  // construction time.

  @override
  void onClose() {
    for (final student in students) {
      student.dispose();
    }
    super.onClose();
  }

  List<String> get periodItems => switch (selectedResultType.value) {
    ResultType.monthly => _kMonths,
    ResultType.quarterly => _kQuarters,
    null => const <String>[],
  };

  bool get canFilter =>
      selectedClass.value != null &&
      selectedSection.value != null &&
      selectedResultType.value != null &&
      (selectedPeriod.value ?? '').isNotEmpty;

  bool get hasUnsavedScores => students.any((s) => s.hasAnyScore);

  // AppIconDropdown fires onChanged(null) when you re-tap the selected item,
  // so every setter below must tolerate null.
  void selectClass(ClassModel? value) => selectedClass.value = value;

  void selectSection(SectionModel? value) => selectedSection.value = value;

  void selectResultType(ResultType? value) {
    selectedResultType.value = value;
    // Mandatory: a stale 'January' while the items are quarters renders as the
    // hint, but the controller would still ship it in the payload.
    selectedPeriod.value = null;
  }

  void selectPeriod(String? value) => selectedPeriod.value = value;

  Future<void> applyFilter() async {
    if (!canFilter) {
      _warn('Select level, section, result type and period first');
      return;
    }
    if (subjects.isEmpty) {
      _warn('No subjects available to score');
      return;
    }

    isLoading.value = true;
    hasFiltered.value = true;
    _replaceStudents(const <StudentScoreColumn>[]);

    try {
      final next = await _fetchStudents(
        classId: selectedClass.value!.id,
        sectionId: selectedSection.value!.id,
        resultType: selectedResultType.value!,
        period: selectedPeriod.value!,
      );
      _replaceStudents(next);
    } catch (e) {
      _replaceStudents(const <StudentScoreColumn>[]);
      ExceptionHandler.handleException(e, alert: false);
    } finally {
      isLoading.value = false;
    }
  }

  /// Swaps the student columns without ever disposing a controller that a
  /// mounted `TextField` still points at.
  ///
  /// Disposing before `assignAll` throws on the next build; disposing straight
  /// after it throws because the outgoing `TextField`s are still mounted for
  /// the remainder of the current frame. So: assign first (which marks the
  /// `Obx` dirty and unmounts them this frame), then dispose in a post-frame
  /// callback once that rebuild has committed.
  void _replaceStudents(List<StudentScoreColumn> next) {
    // `students` is an RxList mutated in place by assignAll, so a live
    // reference would be empty by the time the callback runs and would
    // dispose nothing.
    final outgoing = List<StudentScoreColumn>.of(students);
    students.assignAll(next);
    if (outgoing.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final student in outgoing) {
        student.dispose();
      }
    });
  }

  /// TODO(api): replace the mock body with the real score-sheet request once
  /// the endpoint exists. The signature already carries the real ids, so the
  /// swap is: drop the delay + mock map and call the repository.
  Future<List<StudentScoreColumn>> _fetchStudents({
    required int classId,
    required int sectionId,
    required ResultType resultType,
    required String period,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final subjectIds = subjects.map((s) => s.id).toList(growable: false);
    return kMockScoreStudents
        .map(
          (json) => StudentScoreColumn(
            id: json['id'] as int,
            admissionNo: json['admission_no'] as String,
            studentName: json['student_name'] as String,
            gender: json['gender'] as String,
            subjectIds: subjectIds,
          ),
        )
        .toList();
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

      // Built even though nothing is sent yet — this exercises toPayload() and
      // makes the eventual swap a one-line uncomment.
      final payload = <String, dynamic>{
        'class_id': selectedClass.value!.id,
        'section_id': selectedSection.value!.id,
        'result_type': selectedResultType.value!.name,
        'period': selectedPeriod.value,
        // { studentId: { subjectId: score } }
        'scores': <String, dynamic>{
          for (final student in students)
            student.id.toString(): student.toPayload(),
        },
      };

      // TODO(api): await Get.find<ApiService>().post(
      //   EndPoints.teacherScoreEntry, payload, isShowLoading: false);
      debugPrint('Score entry payload (not sent — no endpoint yet): $payload');
      await Future<void>.delayed(const Duration(milliseconds: 600));

      _success('Scores saved successfully');
    } catch (e) {
      _error('Failed to save scores');
      ExceptionHandler.handleException(e, alert: true);
    } finally {
      isSubmitting.value = false;
    }
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
