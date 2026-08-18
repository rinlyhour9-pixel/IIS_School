class StudentAttendanceSummaryModel {
  final List<StudentAttendanceSummaryItem> items;

  const StudentAttendanceSummaryModel({required this.items});

  factory StudentAttendanceSummaryModel.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List<dynamic>? ?? const [];
    return StudentAttendanceSummaryModel(
      items:
          list
              .map(
                (e) => StudentAttendanceSummaryItem.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList(),
    );
  }
}

class StudentAttendanceSummaryItem {
  final String attendanceDate;
  final int classId;
  final String className;
  final int sectionId;
  final String sectionName;
  final int subjectId;
  final String subjectName;
  final int totalStudent;
  final int presenceCount;
  final int absentCount;
  final int lateCount;
  final int permissionCount;

  const StudentAttendanceSummaryItem({
    required this.attendanceDate,
    required this.classId,
    required this.className,
    required this.sectionId,
    required this.sectionName,
    required this.subjectId,
    required this.subjectName,
    required this.totalStudent,
    required this.presenceCount,
    required this.absentCount,
    required this.lateCount,
    required this.permissionCount,
  });

  factory StudentAttendanceSummaryItem.fromJson(Map<String, dynamic> json) {
    return StudentAttendanceSummaryItem(
      attendanceDate: json['attendance_date'] as String? ?? '',
      classId: json['class_id'] as int? ?? 0,
      className: json['class_name'] as String? ?? '',
      sectionId: json['section_id'] as int? ?? 0,
      sectionName: json['section_name'] as String? ?? '',
      subjectId: json['subject_id'] as int? ?? 0,
      subjectName: json['subject_name'] as String? ?? '',
      totalStudent: _toInt(json['total_student']),
      presenceCount: _toInt(json['P']),
      absentCount: _toInt(json['A']),
      lateCount: _toInt(json['L']),
      permissionCount: _toInt(json['F']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse((value ?? '').toString().trim()) ?? 0;
  }
}
