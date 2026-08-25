/// Static placeholder data for Score Entry.
///
/// The score-entry backend does not exist yet, so the whole screen runs on
/// the fixtures below — no network calls at all. When the API lands, delete
/// this file and replace the `TODO(api)` seams in `ScoreEntryController`.
library;

import 'package:schoolapp/models/models.dart';

/// Level / class options.
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

/// The row axis of the sheet — one row per subject.
const List<SubjectModel> kMockSubjects = <SubjectModel>[
  SubjectModel(id: 1, name: 'Math', code: 'MATH'),
  SubjectModel(id: 2, name: 'English', code: 'ENG'),
  SubjectModel(id: 3, name: 'Biology', code: 'BIO'),
  SubjectModel(id: 4, name: 'Khmer', code: 'KHM'),
];

/// Two students matches the mockup; the table scrolls horizontally once there
/// are more than roughly two columns on a phone.
const List<Map<String, dynamic>> kMockScoreStudents = <Map<String, dynamic>>[
  {
    'id': 1,
    'admission_no': 'iiS9-00001',
    'student_name': 'SOK NA',
    'gender': 'Male',
  },
  {
    'id': 2,
    'admission_no': 'iiS9-00002',
    'student_name': 'CHAN DARA',
    'gender': 'Female',
  },
  {
    'id': 3,
    'admission_no': 'iiS9-00003',
    'student_name': 'SREY MOM',
    'gender': 'Female',
  },
  {
    'id': 4,
    'admission_no': 'iiS9-00004',
    'student_name': 'VUTHY SOPHANNARITH',
    'gender': 'Male',
  },
  {
    'id': 5,
    'admission_no': 'iiS9-00005',
    'student_name': 'KIM LEANG',
    'gender': 'Female',
  },
  {
    'id': 6,
    'admission_no': 'iiS9-00006',
    'student_name': 'PISETH CHANTHAVY',
    'gender': 'Male',
  },
];
