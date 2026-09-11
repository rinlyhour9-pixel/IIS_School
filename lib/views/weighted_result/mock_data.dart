/// Static placeholder data for Weighted Result.
///
/// There is no backend endpoint for this yet (no `weight`/`grade`/`gpa`
/// anything anywhere in `EndPoints`), so this is invented, internally
/// consistent demo data rather than an empty table — the point of a static
/// preview is to show what the screen looks like with content. When the API
/// lands, delete this file and replace the `TODO(api)` seam in
/// `WeightedResultController`.
library;

import 'package:schoolapp/views/weighted_result/controller.dart';

// Rescaled to 0-5 (each criterion's max, per WeightCriterion.maxScore) —
// originally invented on a 0-10 scale before the real max was confirmed by
// the View Score screen's "(out of 5)" column headers.
const Map<String, int> _kStrongScores = <String, int>{
  'homework': 5,
  'communication': 5,
  'classwork': 4,
  'reflection': 4,
  'be_respectful': 5,
  'students_attention': 4,
  'task_responsibility': 5,
  'work_independently': 4,
  'students_punctually': 5,
  'morality': 5,
};

// Matches a real observed web row (100/60/80/80/100/60/80/100/80/80 →
// 5/3/4/4/5/3/4/5/4/4 out of 5) — the web renders each criterion as a
// percentage of its max, and 82% is exactly the average of those ten
// percentages (820/10), confirming Weighted % is that unweighted average
// since every criterion here carries an equal 10% weight.
const Map<String, int> _kAverageScores = <String, int>{
  'homework': 5,
  'communication': 3,
  'classwork': 4,
  'reflection': 4,
  'be_respectful': 5,
  'students_attention': 3,
  'task_responsibility': 4,
  'work_independently': 5,
  'students_punctually': 4,
  'morality': 4,
};

const List<WeightedResultItem> kMockWeightedResults = <WeightedResultItem>[
  WeightedResultItem(
    admissionNo: 'iiS9-00001',
    studentName: 'SOK NA',
    criteriaScores: _kStrongScores,
    weightedPercent: 91,
    grade: 'A',
    gpa: 3.9,
    result: 'Pass',
  ),
  WeightedResultItem(
    admissionNo: 'iiS9-00002',
    studentName: 'CHAN DARA',
    criteriaScores: _kAverageScores,
    weightedPercent: 82,
    grade: 'B',
    gpa: 3.0,
    result: 'Pass',
  ),
];
