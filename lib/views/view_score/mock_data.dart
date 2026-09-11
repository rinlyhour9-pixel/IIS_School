/// Static placeholder data for View Score.
///
/// There is no backend endpoint for this yet, so this is invented demo
/// data — two students with example scores already filled in, rather than
/// an empty table. When the API lands, delete this file and replace the
/// `TODO(api)` seam in `ViewScoreController`.
///
/// Raw maps rather than `ViewScoreItem` instances: each item now owns live
/// `TextEditingController`s (for inline score entry), so it can't be a
/// `const` value — `ViewScoreController.applyFilter()` builds fresh items
/// from this seed data on every fetch, the same way Score Entry's
/// `_fetchStudents` maps its own raw mock rows into `StudentScoreColumn`s.
library;

const List<Map<String, dynamic>> kMockViewScoreStudents =
    <Map<String, dynamic>>[
      {
        'admission_no': 'iiS9-00001',
        'student_name': 'SOK NA',
        'gender': 'Male',
        'scores': <String, int>{
          'homework': 5,
          'communication': 4,
          'classwork': 5,
          'reflection': 4,
          'be_respectful': 5,
          'students_attention': 4,
          'task_responsibility': 5,
          'work_independently': 4,
          'students_punctually': 5,
          'morality': 5,
        },
      },
      {
        'admission_no': 'iiS1-00127',
        'student_name': 'Seavlinh',
        'gender': 'Female',
        'scores': <String, int>{
          'homework': 4,
          'communication': 5,
          'classwork': 3,
          'reflection': 4,
          'be_respectful': 5,
          'students_attention': 3,
          'task_responsibility': 4,
          'work_independently': 3,
          'students_punctually': 4,
          'morality': 5,
        },
      },
    ];
