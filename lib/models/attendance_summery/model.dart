class AttendanceSummery {
  bool? success;
  int? statusCode;
  String? message;
  List<Data>? data;
  List<Data>? summary;
  AttendanceListPage? attendancesList;

  AttendanceSummery({
    this.success,
    this.statusCode,
    this.message,
    this.data,
    this.summary,
    this.attendancesList,
  });

  AttendanceSummery.fromJson(Map<String, dynamic> json) {
    success = json['success'] == true;
    statusCode = _toInt(json['statusCode'] ?? json['status_code']);
    message = json['message']?.toString();

    data = _parseDataList(json['data']);
    summary = _parseDataList(json['summary']);

    final rawPage = json['attendances_list'];
    if (rawPage is Map<String, dynamic>) {
      attendancesList = AttendanceListPage.fromJson(rawPage);
    } else if (rawPage is Map) {
      attendancesList = AttendanceListPage.fromJson(
        Map<String, dynamic>.from(rawPage),
      );
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['statusCode'] = statusCode;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (summary != null) {
      data['summary'] = summary!.map((v) => v.toJson()).toList();
    }
    if (attendancesList != null) {
      data['attendances_list'] = attendancesList!.toJson();
    }
    return data;
  }
}

class Data {
  int? studentId;
  String? firstname;
  String? firstnamekh;
  String? classroom;
  String? section;
  String? totalPresence;
  String? totalLate;
  String? totalAbsent;
  String? totalPermission;
  String? attendanceDate;
  String? createdAt;

  Data({
    this.studentId,
    this.firstname,
    this.firstnamekh,
    this.classroom,
    this.section,
    this.totalPresence,
    this.totalLate,
    this.totalAbsent,
    this.totalPermission,
    this.attendanceDate,
    this.createdAt,
  });

  Data.fromJson(Map<String, dynamic> json) {
    studentId = _toInt(
      json['student_id'] ??
          json['studentId'] ??
          json['student']?['id'] ??
          json['student']?['student_id'],
    );
    firstname = _readString(json, const ['firstname', 'name', 'student_name']);
    firstnamekh = _readString(json, const [
      'firstnamekh',
      'name_kh',
      'student_name_kh',
    ]);
    classroom = _readString(json, const ['class', 'class_name', 'classroom']);
    section = _readString(json, const ['section']);
    totalPresence = _asCount(json['total_presence']);
    totalLate = _asCount(json['total_late']);
    totalAbsent = _asCount(json['total_absent']);
    totalPermission = _asCount(json['total_permission']);
    attendanceDate = _readString(json, const [
      'attendance_date',
      'date',
      'attendanceDate',
    ]);
    createdAt = _readString(json, const ['created_at', 'createdAt']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['student_id'] = studentId;
    data['firstname'] = firstname;
    data['firstnamekh'] = firstnamekh;
    data['class'] = classroom;
    data['section'] = section;
    data['total_presence'] = totalPresence;
    data['total_late'] = totalLate;
    data['total_absent'] = totalAbsent;
    data['total_permission'] = totalPermission;
    data['attendance_date'] = attendanceDate;
    data['created_at'] = createdAt;
    return data;
  }
}

class AttendanceListPage {
  int? currentPage;
  List<Data>? data;
  int? lastPage;
  int? perPage;
  int? total;

  AttendanceListPage({
    this.currentPage,
    this.data,
    this.lastPage,
    this.perPage,
    this.total,
  });

  AttendanceListPage.fromJson(Map<String, dynamic> json) {
    currentPage = _toInt(json['current_page']);
    data = _parseDataList(json['data']);
    lastPage = _toInt(json['last_page']);
    perPage = _toInt(json['per_page']);
    total = _toInt(json['total']);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'current_page': currentPage,
      'last_page': lastPage,
      'per_page': perPage,
      'total': total,
      'data': data?.map((e) => e.toJson()).toList() ?? <Map<String, dynamic>>[],
    };
  }
}

List<Data> _parseDataList(dynamic raw) {
  if (raw is! List) {
    return <Data>[];
  }
  return raw
      .map((e) {
        if (e is Map<String, dynamic>) {
          return Data.fromJson(e);
        }
        if (e is Map) {
          return Data.fromJson(Map<String, dynamic>.from(e));
        }
        return null;
      })
      .whereType<Data>()
      .toList();
}

int? _toInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is String) {
    return int.tryParse(value.trim());
  }
  return null;
}

String? _readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty && text.toLowerCase() != 'null') {
      return text;
    }
  }

  final student = json['student'];
  if (student is Map<String, dynamic>) {
    for (final key in keys) {
      final value = student[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty && text.toLowerCase() != 'null') {
        return text;
      }
    }
  } else if (student is Map) {
    final map = Map<String, dynamic>.from(student);
    for (final key in keys) {
      final value = map[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty && text.toLowerCase() != 'null') {
        return text;
      }
    }
  }
  return null;
}

String _asCount(dynamic value) {
  if (value == null) {
    return '0';
  }
  final raw = value.toString().trim();
  if (raw.isEmpty || raw.toLowerCase() == 'null') {
    return '0';
  }
  return raw;
}
