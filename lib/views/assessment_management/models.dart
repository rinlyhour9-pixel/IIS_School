int _asInt(dynamic value) => value is int ? value : int.tryParse('$value') ?? 0;

List<dynamic> _asList(dynamic raw) => raw is List ? raw : const <dynamic>[];

List<String> _asStringList(dynamic raw) {
  if (raw is List) return raw.map((e) => e.toString()).toList();
  if (raw is String && raw.trim().isNotEmpty) {
    return raw
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }
  return const <String>[];
}

/// One of the 10 behaviour criteria the Monthly Exam table scores each
/// student on — confirmed via the live endpoint's `assessment_types` field
/// (a misleading name: these are scoring criteria, not exam-type choices).
/// Quarterly/Semester exams use different row axes — [AssessmentSubjectScore]
/// and [AssessmentBilingualCriterion] — from the same filters response.
class AssessmentCriterion {
  const AssessmentCriterion({
    required this.id,
    required this.name,
    required this.maxScore,
  });

  final int id;
  final String name;
  final int maxScore;

  factory AssessmentCriterion.fromJson(Map<String, dynamic> json) =>
      AssessmentCriterion(
        id: _asInt(json['id']),
        name: (json['name'] ?? '').toString(),
        maxScore:
            _asInt(json['max_score']) == 0 ? 5 : _asInt(json['max_score']),
      );

  static List<AssessmentCriterion> listFromJson(List<dynamic> data) {
    return data
        .map(
          (e) =>
              AssessmentCriterion.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  }
}

/// One row of `quarterly_subjects`/`semester_subjects` — a per-subject score
/// out of a subject-specific max (e.g. Reading out of 100, Quiz out of 20).
class AssessmentSubjectScore {
  const AssessmentSubjectScore({required this.name, required this.max});

  final String name;
  final int max;

  factory AssessmentSubjectScore.fromJson(Map<String, dynamic> json) =>
      AssessmentSubjectScore(
        name: (json['name'] ?? '').toString(),
        max: _asInt(json['max']) == 0 ? 100 : _asInt(json['max']),
      );

  static List<AssessmentSubjectScore> listFromJson(List<dynamic> data) {
    return data
        .map(
          (e) => AssessmentSubjectScore.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }
}

/// One row of `quarterly_criteria` — bilingual (English/Chinese) labels for
/// the Quarterly Exam's behaviour criteria. Only [en] is displayed for now;
/// [cn] is parsed but unused (the app has no Chinese locale yet).
class AssessmentBilingualCriterion {
  const AssessmentBilingualCriterion({required this.en, required this.cn});

  final String en;
  final String cn;

  factory AssessmentBilingualCriterion.fromJson(Map<String, dynamic> json) =>
      AssessmentBilingualCriterion(
        en: (json['en'] ?? '').toString(),
        cn: (json['cn'] ?? '').toString(),
      );

  static List<AssessmentBilingualCriterion> listFromJson(List<dynamic> data) {
    return data
        .map(
          (e) => AssessmentBilingualCriterion.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }
}

/// One row rendered in the assessment table — either a scoreable field, or a
/// full-width group header band (Semester Exam's "First/Second Quarter").
enum AssessmentFieldKind { score, group }

class AssessmentField {
  const AssessmentField.score({
    required this.key,
    required this.label,
    required this.maxScore,
  }) : kind = AssessmentFieldKind.score;

  const AssessmentField.group(this.label)
    : kind = AssessmentFieldKind.group,
      key = '',
      maxScore = 0;

  final AssessmentFieldKind kind;

  /// Stable identifier used as the per-student TextEditingController key and
  /// the save payload key. Empty for group rows (they hold no input).
  final String key;
  final String label;
  final int maxScore;
}

/// One student enrolled in the chosen assignment, with their existing scores
/// for the selected period/result type (if any were already recorded).
///
/// `scores` is keyed by the raw id/name the API used for that field — for
/// Monthly this is confirmed to be the criterion id as a string (e.g.
/// `"3"`, matching [AssessmentCriterion.id]); Quarterly/Semester's key
/// format has no worked example yet, so those start blank rather than
/// guessing. A student with nothing recorded yet comes back with
/// `scores: []` (empty array) instead of an object — handled defensively.
class AssessmentStudentRecord {
  const AssessmentStudentRecord({
    required this.id,
    required this.admissionNo,
    required this.name,
    required this.gender,
    required this.scores,
    required this.quarterScores,
    required this.quarterEvaluation,
    required this.firstQuarter,
    required this.secondQuarter,
    required this.teacherComment,
  });

  final int id;
  final String admissionNo;
  final String name;
  final String gender;

  /// Monthly only — a map keyed by criterion id (e.g. `{"3": "5.00"}`).
  final Map<String, dynamic> scores;

  /// Quarterly only — positional arrays, ordered to match the filters
  /// endpoint's `quarterly_subjects` (9) and `quarterly_criteria` (10).
  final List<dynamic> quarterScores;
  final List<dynamic> quarterEvaluation;

  /// Semester only — positional arrays, each ordered to match the filters
  /// endpoint's `semester_subjects` (7).
  final List<dynamic> firstQuarter;
  final List<dynamic> secondQuarter;

  /// Quarterly/Semester only — the free-text note for this student.
  final String teacherComment;

  factory AssessmentStudentRecord.fromJson(Map<String, dynamic> json) {
    final admissionNo = (json['admission_no'] ?? '').toString();
    final firstName = (json['firstname'] ?? '').toString().trim();
    final lastName = (json['lastname'] ?? '').toString().trim();
    final name = [firstName, lastName].where((s) => s.isNotEmpty).join(' ');
    final rawScores = json['scores'];
    return AssessmentStudentRecord(
      id: _asInt(json['id']),
      admissionNo: admissionNo,
      name: name.isEmpty ? admissionNo : name,
      gender: (json['gender'] ?? '').toString(),
      scores:
          rawScores is Map
              ? Map<String, dynamic>.from(rawScores)
              : const <String, dynamic>{},
      quarterScores: _asList(json['quarter_scores']),
      quarterEvaluation: _asList(json['quarter_evaluation']),
      firstQuarter: _asList(json['first_quarter']),
      secondQuarter: _asList(json['second_quarter']),
      teacherComment: (json['teacher_comment'] ?? '').toString(),
    );
  }

  static List<AssessmentStudentRecord> listFromJson(List<dynamic> data) {
    return data
        .map(
          (e) => AssessmentStudentRecord.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }
}

/// One row of a teacher's class/subject assignments — the real backing data
/// behind Level, Subject, and (via [sessionSectionLabel]) Section. The Save
/// endpoint takes a single `assignment_id`, not separate class/section/
/// subject ids, so [id] is what Level+Subject+Section ultimately resolve to.
///
/// `section_id`/`section_name` are always null on the live endpoint (a class
/// can teach the same subject in more than one session/time-slot instead —
/// e.g. Morning vs Afternoon), so [sessionSectionLabel] (matching the format
/// of the filters endpoint's old `section_options` labels, e.g. "Morning
/// (7:30AM - 10:30AM)") is what disambiguates those rows instead.
class AssessmentAssignment {
  const AssessmentAssignment({
    required this.id,
    required this.classId,
    required this.className,
    required this.subjectId,
    required this.subjectName,
    required this.sessionSectionLabel,
  });

  final int id;
  final int classId;
  final String className;
  final int subjectId;
  final String subjectName;
  final String sessionSectionLabel;

  factory AssessmentAssignment.fromJson(Map<String, dynamic> json) =>
      AssessmentAssignment(
        id: _asInt(json['id']),
        classId: _asInt(json['class_id']),
        className: (json['class_name'] ?? '').toString(),
        subjectId: _asInt(json['subject_id']),
        subjectName: (json['subject_name'] ?? '').toString(),
        sessionSectionLabel:
            (json['session_section_label'] ?? json['session'] ?? '').toString(),
      );

  static List<AssessmentAssignment> listFromJson(List<dynamic> data) {
    return data
        .map(
          (e) => AssessmentAssignment.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }
}

class AssessmentManagementFilters {
  const AssessmentManagementFilters({
    required this.criteria,
    required this.monthOptions,
    required this.quarterOptions,
    required this.semesterOptions,
    required this.quarterlySubjects,
    required this.quarterlyCriteria,
    required this.semesterSubjects,
  });

  /// The 10 Monthly Exam scoring criteria — from `assessment_types`.
  final List<AssessmentCriterion> criteria;
  final List<String> monthOptions;
  final List<String> quarterOptions;
  final List<String> semesterOptions;
  final List<AssessmentSubjectScore> quarterlySubjects;
  final List<AssessmentBilingualCriterion> quarterlyCriteria;
  final List<AssessmentSubjectScore> semesterSubjects;

  factory AssessmentManagementFilters.fromJson(Map<String, dynamic> json) {
    final data = Map<String, dynamic>.from(json['data'] as Map? ?? const {});
    return AssessmentManagementFilters(
      criteria: AssessmentCriterion.listFromJson(
        (data['assessment_types'] as List?) ?? const [],
      ),
      monthOptions: _asStringList(data['month_options']),
      quarterOptions: _asStringList(data['quarter_options']),
      semesterOptions: _asStringList(data['semester_options']),
      quarterlySubjects: AssessmentSubjectScore.listFromJson(
        (data['quarterly_subjects'] as List?) ?? const [],
      ),
      quarterlyCriteria: AssessmentBilingualCriterion.listFromJson(
        (data['quarterly_criteria'] as List?) ?? const [],
      ),
      semesterSubjects: AssessmentSubjectScore.listFromJson(
        (data['semester_subjects'] as List?) ?? const [],
      ),
    );
  }
}
