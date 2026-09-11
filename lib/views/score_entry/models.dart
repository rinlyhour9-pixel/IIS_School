int _asInt(dynamic value) => value is int ? value : int.tryParse('$value') ?? 0;

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

class ScoreEntryFilters {
  const ScoreEntryFilters({
    required this.monthOptions,
    required this.semesterOptions,
  });

  final List<String> monthOptions;
  final List<String> semesterOptions;

  factory ScoreEntryFilters.fromJson(Map<String, dynamic> json) {
    final data = Map<String, dynamic>.from(json['data'] as Map? ?? const {});
    return ScoreEntryFilters(
      monthOptions: _asStringList(data['month_options']),
      semesterOptions: _asStringList(data['semester_options']),
    );
  }
}

/// One row of a teacher's class/subject assignments — the real backing data
/// behind Level, Subject (the table's row axis), and (via
/// [sessionSectionLabel]) Section.
///
/// `section_id`/`section_name` are always null on the live endpoint (a class
/// can teach more than one subject in the same session/time-slot instead —
/// e.g. Math and English both in the Morning session), so
/// [sessionSectionLabel] (e.g. "Morning (7:30AM - 10:30AM)") is what
/// disambiguates/groups those rows instead. Level+Section resolve to a *set*
/// of these rows (one per subject taught in that session), not a single one
/// — unlike Assessment Management's single fixed criteria list, Score
/// Entry's row axis is exactly those resolved subjects.
class ScoreEntryAssignment {
  const ScoreEntryAssignment({
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

  factory ScoreEntryAssignment.fromJson(Map<String, dynamic> json) =>
      ScoreEntryAssignment(
        id: _asInt(json['id']),
        classId: _asInt(json['class_id']),
        className: (json['class_name'] ?? '').toString(),
        subjectId: _asInt(json['subject_id']),
        subjectName: (json['subject_name'] ?? '').toString(),
        sessionSectionLabel:
            (json['session_section_label'] ?? json['session'] ?? '').toString(),
      );

  static List<ScoreEntryAssignment> listFromJson(List<dynamic> data) {
    return data
        .map(
          (e) => ScoreEntryAssignment.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }
}

/// One enrolled student with their existing scores for the resolved
/// assignments/period, if any were already recorded. `scores` is keyed by
/// subject id as a string (e.g. `"23"`), matching
/// [ScoreEntryAssignment.subjectId] directly — no remapping needed to feed
/// `StudentScoreColumn`'s existing subject-id-keyed controllers.
class ScoreEntryStudentRecord {
  const ScoreEntryStudentRecord({
    required this.id,
    required this.admissionNo,
    required this.name,
    required this.gender,
    required this.scores,
  });

  final int id;
  final String admissionNo;
  final String name;
  final String gender;
  final Map<String, dynamic> scores;

  factory ScoreEntryStudentRecord.fromJson(Map<String, dynamic> json) {
    final admissionNo = (json['admission_no'] ?? '').toString();
    final firstName = (json['firstname'] ?? '').toString().trim();
    final lastName = (json['lastname'] ?? '').toString().trim();
    final name = [firstName, lastName].where((s) => s.isNotEmpty).join(' ');
    final rawScores = json['scores'];
    return ScoreEntryStudentRecord(
      id: _asInt(json['id']),
      admissionNo: admissionNo,
      name: name.isEmpty ? admissionNo : name,
      gender: (json['gender'] ?? '').toString(),
      scores:
          rawScores is Map
              ? Map<String, dynamic>.from(rawScores)
              : const <String, dynamic>{},
    );
  }

  static List<ScoreEntryStudentRecord> listFromJson(List<dynamic> data) {
    return data
        .map(
          (e) => ScoreEntryStudentRecord.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }
}
