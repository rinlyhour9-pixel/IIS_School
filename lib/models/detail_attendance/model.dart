class DetailedAttendanceItem {
  final int id;
  final String admissionNo;
  final String studentName;
  final String studentNameKh;
  final String className;
  final String sectionName;
  final String subjectName;
  final String attendanceStatus;
  final String note;

  DetailedAttendanceItem({
    required this.id,
    required this.admissionNo,
    required this.studentName,
    required this.studentNameKh,
    required this.className,
    required this.sectionName,
    required this.subjectName,
    required this.attendanceStatus,
    required this.note,
  });

  factory DetailedAttendanceItem.fromJson(Map<String, dynamic> json) {
    final rawNote = json['note'];
    final note =
        (rawNote == null || rawNote == 'N/A') ? '' : rawNote.toString();

    return DetailedAttendanceItem(
      id: json['id'] as int,
      admissionNo: json['admission_no']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? '',
      studentNameKh: json['student_name_kh']?.toString() ?? '',
      className: json['class_name']?.toString() ?? '',
      sectionName: json['section_name']?.toString() ?? '',
      subjectName: json['subject_name']?.toString() ?? '',
      attendanceStatus: json['attendance_status']?.toString() ?? '',
      note: note,
    );
  }
}

class DetailedAttendanceModel {
  final List<DetailedAttendanceItem> items;
  final int currentPage;
  final int lastPage;
  final int total;

  DetailedAttendanceModel({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  factory DetailedAttendanceModel.fromJson(Map<String, dynamic> json) {
    final list =
        (json['data'] as List<dynamic>? ?? [])
            .map(
              (e) => DetailedAttendanceItem.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList();

    return DetailedAttendanceModel(
      items: list,
      currentPage: json['current_page'] as int? ?? 1,
      lastPage: json['last_page'] as int? ?? 1,
      total: json['total'] as int? ?? list.length,
    );
  }
}
