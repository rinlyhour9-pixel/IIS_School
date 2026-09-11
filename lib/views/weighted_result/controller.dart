import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/models/models.dart';
import 'package:schoolapp/views/score_entry/mock_data.dart'
    show kMockClasses, kMockSections, kMockSubjects;
import 'package:schoolapp/views/weighted_result/mock_data.dart';

/// Independent from Score Entry's own `ResultType` (which is private to that
/// file) — each screen owns its own filter-shape concept rather than being
/// coupled to another screen's.
enum WeightedResultPeriodType {
  monthly('Monthly Exam'),
  quarterly('Quarterly Exam');

  const WeightedResultPeriodType(this.label);

  final String label;
}

/// One of the 10 weighted behaviour criteria shown in the web's "Weights:"
/// badge row, in its exact order.
///
/// Holds a `labelKey` (a `LocaleKeys` constant) rather than a plain string:
/// this list is `const`, and `.tr` is a runtime getter that can't appear in
/// a const expression, so the actual localized text is resolved at render
/// time via `criterion.labelKey.tr` in the widgets.
class WeightCriterion {
  const WeightCriterion({
    required this.key,
    required this.labelKey,
    required this.weightPercent,
    this.maxScore = 5,
  });

  final String key;
  final String labelKey;
  final int weightPercent;

  /// The raw per-criterion score scale — 5 for every criterion, confirmed by
  /// the View Score screen's "(out of 5)" column headers. Distinct from
  /// [weightPercent]: that's how much this criterion counts toward the final
  /// weighted result; this is the ceiling for the raw score itself.
  final int maxScore;
}

const List<WeightCriterion> kWeightCriteria = <WeightCriterion>[
  WeightCriterion(
    key: 'homework',
    labelKey: LocaleKeys.weightedResultCriterionHomework,
    weightPercent: 10,
  ),
  WeightCriterion(
    key: 'communication',
    labelKey: LocaleKeys.weightedResultCriterionCommunication,
    weightPercent: 10,
  ),
  WeightCriterion(
    key: 'classwork',
    labelKey: LocaleKeys.weightedResultCriterionClasswork,
    weightPercent: 10,
  ),
  WeightCriterion(
    key: 'reflection',
    labelKey: LocaleKeys.weightedResultCriterionReflection,
    weightPercent: 10,
  ),
  WeightCriterion(
    key: 'be_respectful',
    labelKey: LocaleKeys.weightedResultCriterionBeRespectful,
    weightPercent: 10,
  ),
  WeightCriterion(
    key: 'students_attention',
    labelKey: LocaleKeys.weightedResultCriterionStudentsAttention,
    weightPercent: 10,
  ),
  WeightCriterion(
    key: 'task_responsibility',
    labelKey: LocaleKeys.weightedResultCriterionTaskResponsibility,
    weightPercent: 10,
  ),
  WeightCriterion(
    key: 'work_independently',
    labelKey: LocaleKeys.weightedResultCriterionWorkIndependently,
    weightPercent: 10,
  ),
  WeightCriterion(
    key: 'students_punctually',
    labelKey: LocaleKeys.weightedResultCriterionStudentsPunctually,
    weightPercent: 10,
  ),
  WeightCriterion(
    key: 'morality',
    labelKey: LocaleKeys.weightedResultCriterionMorality,
    weightPercent: 10,
  ),
];

class WeightedResultItem {
  const WeightedResultItem({
    required this.admissionNo,
    required this.studentName,
    required this.criteriaScores,
    required this.weightedPercent,
    required this.grade,
    required this.gpa,
    required this.result,
  });

  final String admissionNo;
  final String studentName;

  /// Keyed by [WeightCriterion.key], each 0-10.
  final Map<String, int> criteriaScores;
  final double weightedPercent;
  final String grade;
  final double gpa;
  final String result;
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

class WeightedResultController extends GetxController {
  // TODO(api): all three are static fixtures shared with Score Entry, which
  // is itself waiting on a real /api/v1/setting/* wiring — see
  // score_entry/mock_data.dart.
  final RxList<ClassModel> classes = <ClassModel>[...kMockClasses].obs;
  final RxList<SectionModel> sections = <SectionModel>[...kMockSections].obs;
  final RxList<SubjectModel> subjects = <SubjectModel>[...kMockSubjects].obs;

  final Rx<ClassModel?> selectedClass = Rx<ClassModel?>(null);
  final Rx<SectionModel?> selectedSection = Rx<SectionModel?>(null);
  final Rx<SubjectModel?> selectedSubject = Rx<SubjectModel?>(null);
  final Rx<WeightedResultPeriodType?> selectedResultType =
      Rx<WeightedResultPeriodType?>(null);
  final RxnString selectedPeriod = RxnString();

  final RxList<WeightedResultItem> results = <WeightedResultItem>[].obs;
  final RxBool isLoading = false.obs;

  /// Distinguishes "you haven't filtered yet" from "that filter had no
  /// students".
  final RxBool hasFiltered = false.obs;

  List<String> get periodItems => switch (selectedResultType.value) {
    WeightedResultPeriodType.monthly => _kMonths,
    WeightedResultPeriodType.quarterly => _kQuarters,
    null => const <String>[],
  };

  bool get canFilter =>
      selectedClass.value != null &&
      selectedSection.value != null &&
      selectedSubject.value != null &&
      selectedResultType.value != null &&
      (selectedPeriod.value ?? '').isNotEmpty;

  // AppIconDropdown fires onChanged(null) when you re-tap the selected item,
  // so every setter below must tolerate null.
  void selectClass(ClassModel? value) => selectedClass.value = value;

  void selectSection(SectionModel? value) => selectedSection.value = value;

  void selectSubject(SubjectModel? value) => selectedSubject.value = value;

  void selectResultType(WeightedResultPeriodType? value) {
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
    results.clear();

    try {
      // TODO(api): replace with a real weighted-result request once the
      // endpoint exists. No network call yet — same as Score Entry.
      await Future<void>.delayed(const Duration(milliseconds: 400));
      results.assignAll(kMockWeightedResults);
    } finally {
      isLoading.value = false;
    }
  }
}
