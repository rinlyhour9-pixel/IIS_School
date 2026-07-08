class StudentAttendanceModel {
  final List<StudentAttendanceItem> items;

  const StudentAttendanceModel({required this.items});

  factory StudentAttendanceModel.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List<dynamic>? ?? const [];
    return StudentAttendanceModel(
      items:
          list
              .map(
                (e) => StudentAttendanceItem.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList(),
    );
  }
}

class StudentAttendanceItem {
  final int id;
  final String admissionNo;
  final String studentName;
  final String studentNameKh;
  final String gender;
  final String mobileNo;
  final String className;
  final bool presence;
  final bool permission;
  final bool late;
  final bool absent;
  final String note;
  final String subjectName;
  final int subjectId;
  final String teacherName;

  const StudentAttendanceItem({
    required this.id,
    required this.admissionNo,
    required this.studentName,
    required this.studentNameKh,
    required this.gender,
    required this.mobileNo,
    required this.className,
    required this.presence,
    required this.permission,
    required this.late,
    required this.absent,
    required this.note,
    required this.subjectName,
    required this.subjectId,
    required this.teacherName,
  });

  factory StudentAttendanceItem.fromJson(Map<String, dynamic> json) {
    return StudentAttendanceItem(
      id: json['student_id'] as int? ?? 0,
      admissionNo: json['admission_no'] as String? ?? '',
      studentName: json['student_name'] as String? ?? '',
      studentNameKh: json['student_name_kh'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      mobileNo: json['mobileno'] as String? ?? '',
      className: json['class_name'] as String? ?? '',
      presence: _toBool(json['presence']),
      permission: _toBool(json['permission']),
      late: _toBool(json['late']),
      absent: _toBool(json['absent']),
      note: json['note'] as String? ?? '',
      subjectName: json['subject_name'] as String? ?? '',
      subjectId: json['subject_id'] as int? ?? 0,
      teacherName: json['teacher_name'] as String? ?? '',
    );
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    return false;
  }
}
