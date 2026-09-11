/// Static placeholder data for Score Verification.
///
/// There is no backend endpoint for pending-score verification yet (no
/// `verify`/`approve`/`lock` anything in `EndPoints`), so this mirrors what
/// the web admin panel currently shows for a real account rather than
/// inventing plausible-looking extra rows. When the API lands, delete this
/// file and replace the `TODO(api)` seams in `ScoreVerificationController`.
library;

import 'package:schoolapp/views/score_verification/controller.dart';

const List<PendingScoreItem> kMockPendingExaminationScores = <PendingScoreItem>[];

const List<PendingScoreItem> kMockPendingQuarterScores = <PendingScoreItem>[];

const List<PendingScoreItem> kMockPendingAssessmentScores = <PendingScoreItem>[
  PendingScoreItem(
    className: 'BP-K1',
    sectionName: 'Afternoon (1:30PM - 4:30PM)',
    subjectName: 'ខែ្មរសិក្សា',
    studentCount: 1,
    submittedAt: '17 Aug 2026 10:16 AM',
    sessionLabel: 'Afternoon-Session2',
  ),
];
