import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/models/models.dart';
import 'package:schoolapp/views/score_entry/mock_data.dart'
    show kMockClasses, kMockSections;
import 'package:schoolapp/views/view_score/mock_data.dart';
import 'package:schoolapp/views/view_score/widgets/view_score_item.dart';

export 'package:schoolapp/views/view_score/widgets/view_score_item.dart'
    show ViewScoreItem;

/// Independent from Weighted Result's / Score Entry's own period enums —
/// each screen owns its own filter-shape concept.
enum ViewScorePeriodType {
  monthly('Monthly Exam'),
  quarterly('Quarterly Exam');

  const ViewScorePeriodType(this.label);

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

class ViewScoreController extends GetxController {
  // TODO(api): static fixtures shared with Score Entry / Weighted Result,
  // which are themselves waiting on a real /api/v1/setting/* wiring.
  final RxList<ClassModel> classes = <ClassModel>[...kMockClasses].obs;
  final RxList<SectionModel> sections = <SectionModel>[...kMockSections].obs;

  final Rx<ClassModel?> selectedClass = Rx<ClassModel?>(null);
  final Rx<SectionModel?> selectedSection = Rx<SectionModel?>(null);
  final Rx<ViewScorePeriodType?> selectedResultType = Rx<ViewScorePeriodType?>(
    null,
  );
  final RxnString selectedPeriod = RxnString();

  final RxList<ViewScoreItem> results = <ViewScoreItem>[].obs;
  final RxBool isLoading = false.obs;

  /// Distinguishes "you haven't filtered yet" from "that filter had no
  /// students".
  final RxBool hasFiltered = false.obs;

  @override
  void onClose() {
    for (final item in results) {
      item.dispose();
    }
    super.onClose();
  }

  List<String> get periodItems => switch (selectedResultType.value) {
    ViewScorePeriodType.monthly => _kMonths,
    ViewScorePeriodType.quarterly => _kQuarters,
    null => const <String>[],
  };

  bool get canFilter =>
      selectedClass.value != null &&
      selectedSection.value != null &&
      selectedResultType.value != null &&
      (selectedPeriod.value ?? '').isNotEmpty;

  // AppIconDropdown fires onChanged(null) when you re-tap the selected item,
  // so every setter below must tolerate null.
  void selectClass(ClassModel? value) => selectedClass.value = value;

  void selectSection(SectionModel? value) => selectedSection.value = value;

  void selectResultType(ViewScorePeriodType? value) {
    selectedResultType.value = value;
    // A stale 'January' while the items are quarters would render as the
    // hint, but the controller would still carry it.
    selectedPeriod.value = null;
  }

  void selectPeriod(String? value) => selectedPeriod.value = value;

  Future<void> applyFilter() async {
    if (!canFilter) return;

    isLoading.value = true;
    hasFiltered.value = true;
    _replaceResults(const <ViewScoreItem>[]);

    try {
      // TODO(api): replace with a real view-score request once the endpoint
      // exists. No network call yet — same as Score Entry / Weighted Result.
      await Future<void>.delayed(const Duration(milliseconds: 400));
      final next =
          kMockViewScoreStudents
              .map(
                (row) => ViewScoreItem(
                  admissionNo: row['admission_no'] as String,
                  studentName: row['student_name'] as String,
                  gender: row['gender'] as String,
                  initialScores:
                      (row['scores'] as Map<String, int>?) ??
                      const <String, int>{},
                ),
              )
              .toList();
      _replaceResults(next);
    } finally {
      isLoading.value = false;
    }
  }

  /// Swaps the result set without ever disposing a controller that a mounted
  /// `TextField` still points at.
  ///
  /// Disposing before `assignAll` throws on the next build; disposing right
  /// after throws too, since the outgoing `TextField`s are still mounted for
  /// the rest of that frame. So: assign first (marks the `Obx` dirty and
  /// unmounts them this frame), then dispose in a post-frame callback once
  /// that rebuild has committed. Mirrors
  /// `ScoreEntryController._replaceStudents`.
  void _replaceResults(List<ViewScoreItem> next) {
    // `results` is an RxList mutated in place by assignAll, so a live
    // reference would be empty by the time the callback runs and would
    // dispose nothing.
    final outgoing = List<ViewScoreItem>.of(results);
    results.assignAll(next);
    if (outgoing.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final item in outgoing) {
        item.dispose();
      }
    });
  }
}
