class LeaveListResponse {
  final bool success;
  final String message;
  final LeavePagination? data;

  LeaveListResponse({required this.success, required this.message, this.data});

  factory LeaveListResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    return LeaveListResponse(
      success: json['success'] == true,
      message: (json['message'] ?? '').toString(),
      data:
          rawData is Map
              ? LeavePagination.fromJson(Map<String, dynamic>.from(rawData))
              : rawData is List
              ? LeavePagination.fromList(rawData)
              : null,
    );
  }
}

class LeavePagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final List<LeaveItem> items;

  LeavePagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.items,
  });

  factory LeavePagination.fromJson(Map<String, dynamic> json) {
    final rawList =
        json['data'] ??
        json['leave_requests'] ??
        json['items'] ??
        json['records'] ??
        json['results'];

    return LeavePagination(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 0,
      total: json['total'] ?? 0,
      items:
          rawList is List
              ? rawList
                  .whereType<Map>()
                  .map((e) => LeaveItem.fromJson(Map<String, dynamic>.from(e)))
                  .toList()
              : const <LeaveItem>[],
    );
  }
  factory LeavePagination.fromList(List<dynamic> list) {
    final items =
        list
            .whereType<Map>()
            .map((e) => LeaveItem.fromJson(Map<String, dynamic>.from(e)))
            .toList();
    return LeavePagination(
      currentPage: 1,
      lastPage: 1,
      perPage: items.length,
      total: items.length,
      items: items,
    );
  }
}

class LeaveDetailResponse {
  final bool success;
  final String message;
  final LeaveItem? data;

  LeaveDetailResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory LeaveDetailResponse.fromJson(Map<String, dynamic> json) {
    return LeaveDetailResponse(
      success: json['success'] == true,
      message: (json['message'] ?? '').toString(),
      data:
          json['data'] is Map
              ? LeaveItem.fromJson(Map<String, dynamic>.from(json['data']))
              : null,
    );
  }
}

class LeaveItem {
  final int id;
  final String fromDate;
  final String toDate;
  final String applyDate;
  final String status;
  final String reason;
  final String? className;
  final String? sectionName;
  final String studentName;
  final String studentId;
  final String profile;
  final String? approvedBy;
  final List<String> docs;

  LeaveItem({
    required this.id,
    required this.fromDate,
    required this.toDate,
    required this.applyDate,
    required this.status,
    required this.reason,
    this.className,
    this.sectionName,
    required this.studentName,
    this.studentId = '',
    required this.profile,
    this.approvedBy,
    this.docs = const [],
  });

  factory LeaveItem.fromJson(Map<String, dynamic> json) {
    return LeaveItem(
      id: json['id'] ?? 0,
      fromDate: _readText(json, const [
        'from_date',
        'date_start',
        'start_date',
      ]),
      toDate: _readText(json, const ['to_date', 'date_end', 'end_date']),
      applyDate: _readText(json, const ['apply_date', 'created_at']),
      status: _normalizeStatus(
        rawStatus: _readText(json, const [
          'status',
          'leave_status',
          'approval_status',
          'approve_status',
          'request_status',
          'state',
        ]),
        approvedFlag: _readText(json, const [
          'approved',
          'is_approved',
          'isApproved',
        ]),
        rejectedFlag: _readText(json, const [
          'rejected',
          'is_rejected',
          'isRejected',
        ]),
        approvedAt: _readText(json, const ['approved_at', 'approvedAt']),
        rejectedAt: _readText(json, const ['rejected_at', 'rejectedAt']),
      ),
      reason: _readText(json, const ['reason', 'description', 'remark']),
      className: _readNullableText(json, const [
        'class_name',
        'class',
        'grade',
      ]),
      sectionName: _readNullableText(json, const ['section_name', 'section']),
      studentName: _readText(json, const [
        'student_name',
        'name',
        'fullname',
        'full_name',
      ]),
      studentId: _readStudentId(json),
      profile: _readText(json, const ['profile', 'avatar', 'photo']),
      approvedBy: json['approved_by']?.toString(),
      docs: _parseDocs(json['docs']),
    );
  }

  static String _readText(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) {
        continue;
      }
      final text = value.toString().trim();
      if (text.isNotEmpty && text.toLowerCase() != 'null') {
        return text;
      }
    }
    return '';
  }

  static String? _readNullableText(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    final text = _readText(json, keys);
    return text.isEmpty ? null : text;
  }

  static String _readStudentId(Map<String, dynamic> json) {
    bool isValid(dynamic value) {
      if (value == null) return false;
      final text = value.toString().trim();
      return text.isNotEmpty && text.toLowerCase() != 'null';
    }

    for (final key in const <String>[
      'student_id',
      'studentId',
      'admission_no',
      'student_code',
    ]) {
      final value = json[key];
      if (isValid(value)) {
        return value.toString().trim();
      }
    }

    final student = json['student'];
    if (student is Map) {
      final map = Map<String, dynamic>.from(student);
      for (final key in const <String>['id', 'admission_no', 'student_code']) {
        final value = map[key];
        if (isValid(value)) {
          return value.toString().trim();
        }
      }
    }

    return '';
  }

  static List<String> _parseDocs(dynamic raw) {
    if (raw == null) return const [];
    if (raw is String) return raw.isEmpty ? const [] : [raw];
    if (raw is List) {
      return raw
          .map((e) {
            if (e is String) return e;
            if (e is Map) {
              final m = Map<String, dynamic>.from(e);
              return (m['url'] ?? m['path'] ?? m['file'] ?? '').toString();
            }
            return '';
          })
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return const [];
  }
}

String _normalizeStatus({
  required String rawStatus,
  required String approvedFlag,
  required String rejectedFlag,
  required String approvedAt,
  required String rejectedAt,
}) {
  final approved = approvedFlag.toLowerCase().trim();
  final rejected = rejectedFlag.toLowerCase().trim();
  if (rejected == '1' || rejected == 'true' || rejected == 'yes') {
    return 'rejected';
  }
  if (approved == '1' || approved == 'true' || approved == 'yes') {
    return 'approved';
  }

  final status = rawStatus.toLowerCase().trim();
  if (status.isNotEmpty) {
    if (status == '1' ||
        status.contains('approve') ||
        status.contains('accept') ||
        status == 'true') {
      return 'approved';
    }
    if (status == '2' ||
        status.contains('reject') ||
        status.contains('deny') ||
        status.contains('decline')) {
      return 'rejected';
    }
    if (status == '0' ||
        status.contains('pending') ||
        status.contains('wait') ||
        status.contains('review') ||
        status == 'false') {
      return 'pending';
    }
  }

  if (rejectedAt.trim().isNotEmpty) {
    return 'rejected';
  }
  if (approvedAt.trim().isNotEmpty) {
    return 'approved';
  }
  return 'pending';
}
