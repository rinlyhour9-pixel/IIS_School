class StaffModel {
  bool? success;
  String? message;
  StaffSummary? summary;
  StaffPage? data;

  StaffModel({this.success, this.message, this.summary, this.data});

  StaffModel.fromJson(Map<String, dynamic> json) {
    success = json['success'] == true;
    message = json['message']?.toString();
    summary =
        json['summary'] is Map<String, dynamic>
            ? StaffSummary.fromJson(json['summary'])
            : null;
    data =
        json['data'] is Map<String, dynamic>
            ? StaffPage.fromJson(json['data'])
            : null;
  }
}

class StaffSummary {
  String present;
  String late;
  String absent;
  String permission;

  StaffSummary({
    this.present = '0',
    this.late = '0',
    this.absent = '0',
    this.permission = '0',
  });

  StaffSummary.fromJson(Map<String, dynamic> json)
    : present = _asCount(json['present']),
      late = _asCount(json['late']),
      absent = _asCount(json['absent']),
      permission = _asCount(json['permission']);

  static String _asCount(dynamic value) {
    if (value == null) {
      return '0';
    }
    if (value is num) {
      return value.toInt().toString();
    }
    final text = value.toString().trim();
    return text.isEmpty ? '0' : text;
  }
}

class StaffPage {
  int currentPage;
  List<StaffAttendanceItem> items;
  int lastPage;
  int perPage;
  int total;

  StaffPage({
    this.currentPage = 1,
    this.items = const <StaffAttendanceItem>[],
    this.lastPage = 1,
    this.perPage = 0,
    this.total = 0,
  });

  StaffPage.fromJson(Map<String, dynamic> json)
    : currentPage = _asInt(json['current_page'], fallback: 1),
      items =
          (json['data'] is List)
              ? (json['data'] as List)
                  .whereType<Map>()
                  .map((e) => StaffAttendanceItem.fromJson(Map<String, dynamic>.from(e)))
                  .toList()
              : <StaffAttendanceItem>[],
      lastPage = _asInt(json['last_page'], fallback: 1),
      perPage = _asInt(json['per_page'], fallback: 0),
      total = _asInt(json['total'], fallback: 0);

  static int _asInt(dynamic value, {required int fallback}) {
    if (value == null) {
      return fallback;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value.toString()) ?? fallback;
  }
}

class StaffAttendanceItem {
  String id;
  String staffCode;
  String fullnameEn;
  String fullnameKh;
  String profile;
  String attendanceDate;
  String timeIn1;
  String timeOut1;
  String timeIn2;
  String timeOut2;
  String status;
  String createdAt;

  StaffAttendanceItem({
    this.id = '',
    this.staffCode = '',
    this.fullnameEn = '',
    this.fullnameKh = '',
    this.profile = '',
    this.attendanceDate = '',
    this.timeIn1 = '-',
    this.timeOut1 = '-',
    this.timeIn2 = '-',
    this.timeOut2 = '-',
    this.status = 'present',
    this.createdAt = '',
  });

  StaffAttendanceItem.fromJson(Map<String, dynamic> json)
    : id = _asText(json['id']),
      staffCode = _resolveStaffCode(json),
      fullnameEn = _asText(json['fullname_en'] ?? json['full_name_en']),
      fullnameKh = _asText(json['fullname_kh'] ?? json['full_name_kh']),
      profile = _asText(
        json['profile'] ??
            json['avatar'] ??
            json['photo'] ??
            json['image'] ??
            json['image_url'] ??
            json['profile_url'],
      ),
      attendanceDate = _asText(json['attendance_date'] ?? json['date']),
      timeIn1 = _asText(json['time_in_1'] ?? json['check_in_morning'] ?? json['time']),
      timeOut1 = _asText(json['time_out_1'] ?? json['check_out_morning']),
      timeIn2 = _asText(json['time_in_2'] ?? json['check_in_afternoon']),
      timeOut2 = _asText(json['time_out_2'] ?? json['check_out_afternoon']),
      status = _asText(json['status'] ?? json['attendance_status']).toLowerCase(),
      createdAt = _asText(json['created_at'] ?? json['createdAt']);

  String get displayName => fullnameKh.isNotEmpty ? fullnameKh : fullnameEn;

  static String _resolveStaffCode(Map<String, dynamic> json) {
    final direct = _firstText(<dynamic>[
      json['staff_code'],
      json['staffCode'],
      json['code'],
      json['employee_id'],
      json['employee_code'],
      json['user_code'],
      json['staff_id'],
      json['card_uid'],
      json['username'],
    ]);
    if (direct.isNotEmpty) {
      return direct;
    }

    final staff = _asMap(json['staff']);
    final user = _asMap(json['user']);
    final profile = _asMap(json['profile']);

    return _firstText(<dynamic>[
      staff?['staff_code'],
      staff?['staffCode'],
      staff?['code'],
      staff?['employee_code'],
      staff?['employee_id'],
      staff?['user_code'],
      staff?['card_uid'],
      staff?['id'],
      user?['staff_code'],
      user?['staffCode'],
      user?['code'],
      user?['employee_code'],
      user?['employee_id'],
      user?['user_code'],
      user?['card_uid'],
      user?['id'],
      profile?['card_uid'],
      profile?['staff_code'],
      profile?['code'],
    ]);
  }

  static String _asText(dynamic value) {
    if (value == null) {
      return '';
    }
    final text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') {
      return '';
    }
    return text;
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  static String _firstText(List<dynamic> values) {
    for (final value in values) {
      final text = _asText(value);
      if (text.isNotEmpty) {
        return text;
      }
    }
    return '';
  }
}
