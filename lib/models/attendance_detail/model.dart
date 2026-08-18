class AttendanceDetailResponse {
  AttendanceDetailResponse({required this.summary, required this.data});

  final List<AttendanceMonthSummary> summary;
  final List<AttendanceDetailRecord> data;

  factory AttendanceDetailResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceDetailResponse(
      summary:
          ((json['summary'] as List?) ?? [])
              .map(
                (e) => AttendanceMonthSummary.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList(),
      data:
          ((json['data'] as List?) ?? [])
              .map(
                (e) => AttendanceDetailRecord.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList(),
    );
  }
}

class AttendanceMonthSummary {
  AttendanceMonthSummary({
    required this.month,
    required this.totalPresence,
    required this.totalLate,
    required this.totalAbsent,
    required this.totalPermission,
  });

  final String month; // "2026-07"
  final int totalPresence;
  final int totalLate;
  final int totalAbsent;
  final int totalPermission;

  factory AttendanceMonthSummary.fromJson(Map<String, dynamic> json) {
    int parse(dynamic v) => int.tryParse((v ?? '0').toString().trim()) ?? 0;
    return AttendanceMonthSummary(
      month: (json['month'] ?? '').toString(),
      totalPresence: parse(json['total_presence']),
      totalLate: parse(json['total_late']),
      totalAbsent: parse(json['total_absent']),
      totalPermission: parse(json['total_permission']),
    );
  }
}

class AttendanceDetailRecord {
  AttendanceDetailRecord({
    required this.date,
    required this.admissionNo,
    required this.studentName,
    required this.studentNameKh,
    required this.classroom,
    required this.section,
    required this.subject,
    required this.status,
    required this.reason,
    required this.recordedAt,
  });

  final String date;
  final String admissionNo;
  final String studentName;
  final String studentNameKh;
  final String classroom;
  final String section;
  final String subject;
  final String status;
  final String reason;
  final String recordedAt;

  factory AttendanceDetailRecord.fromJson(Map<String, dynamic> json) {
    String s(dynamic v) => (v ?? '').toString().trim();
    return AttendanceDetailRecord(
      date: s(json['date']),
      admissionNo: s(json['admission_no']),
      studentName: s(json['student_name']),
      studentNameKh: s(json['student_name_kh']),
      classroom: s(json['class']),
      section: s(json['section']),
      subject: s(json['subject']),
      status: s(json['status']),
      reason: s(json['reason']),
      recordedAt: s(json['recorded_at']),
    );
  }

  /// "Firstname Lastname (ADM-001)"
  String get displayName {
    final full = [
      studentName,
      studentNameKh,
    ].where((e) => e.isNotEmpty).join(' ');
    return admissionNo.isEmpty ? full : '$full ($admissionNo)';
  }
}
