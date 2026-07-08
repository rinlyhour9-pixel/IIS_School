class LeaveListResponse {
  final bool success;
  final String message;
  final LeavePagination? data;

  LeaveListResponse({required this.success, required this.message, this.data});

  factory LeaveListResponse.fromJson(Map<String, dynamic> json) {
    return LeaveListResponse(
      success: json['success'] == true,
      message: (json['message'] ?? '').toString(),
      data:
          json['data'] is Map
              ? LeavePagination.fromJson(
                Map<String, dynamic>.from(json['data']),
              )
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
    final rawList = json['data'];
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
    required this.profile,
    this.approvedBy,
    this.docs = const [],
  });

  factory LeaveItem.fromJson(Map<String, dynamic> json) {
    return LeaveItem(
      id: json['id'] ?? 0,
      fromDate: (json['from_date'] ?? '').toString(),
      toDate: (json['to_date'] ?? '').toString(),
      applyDate: (json['apply_date'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      reason: (json['reason'] ?? '').toString(),
      className: json['class_name']?.toString(),
      sectionName: json['section_name']?.toString(),
      studentName: (json['student_name'] ?? '').toString(),
      profile: (json['profile'] ?? '').toString(),
      approvedBy: json['approved_by']?.toString(),
      docs: _parseDocs(json['docs']),
    );
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
