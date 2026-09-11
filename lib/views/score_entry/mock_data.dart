/// Static placeholder data still used by `weighted_result` and `view_score`,
/// neither of which is wired to a real endpoint yet.
///
/// Score Entry itself no longer imports this file — it's fully wired to the
/// real `/api/v1/teacher/score-entry/*` endpoints (see `ScoreEntryController`
/// and `score_entry/models.dart`). Kept here only because the two other
/// screens still import `kMockClasses`/`kMockSections`/`kMockSubjects` from
/// it; delete once they're wired too.
library;

import 'package:schoolapp/models/models.dart';

const List<ClassModel> kMockClasses = <ClassModel>[
  ClassModel(id: 1, teacherId: 0, className: 'BP-PreK'),
  ClassModel(id: 2, teacherId: 0, className: 'BP-K1'),
  ClassModel(id: 3, teacherId: 0, className: 'BP-K2'),
  ClassModel(id: 4, teacherId: 0, className: 'BP-K3'),
  ClassModel(id: 5, teacherId: 0, className: 'BP-P5'),
];

const List<SectionModel> kMockSections = <SectionModel>[
  SectionModel(id: 1, section: 'Morning (7:30AM - 10:30AM)'),
  SectionModel(id: 2, section: 'Afternoon (1:30PM - 4:30PM)'),
];

const List<SubjectModel> kMockSubjects = <SubjectModel>[
  SubjectModel(id: 1, name: 'Math', code: 'MATH'),
  SubjectModel(id: 2, name: 'English', code: 'ENG'),
  SubjectModel(id: 3, name: 'Biology', code: 'BIO'),
  SubjectModel(id: 4, name: 'Khmer', code: 'KHM'),
];
