class StudentProfileHistory {
  bool? success;
  int? statusCode;
  String? message;
  StudentProfileData? data;

  StudentProfileHistory({this.success, this.statusCode, this.message, this.data});

  StudentProfileHistory.fromJson(Map<String, dynamic> json) {
    success = json['success'] == true;
    statusCode = _toInt(json['statusCode'] ?? json['status_code']);
    message = json['message']?.toString();
    final raw = json['data'];
    if (raw is Map<String, dynamic>) {
      data = StudentProfileData.fromJson(raw);
    } else if (raw is Map) {
      data = StudentProfileData.fromJson(Map<String, dynamic>.from(raw));
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = success;
    map['statusCode'] = statusCode;
    map['message'] = message;
    if (data != null) {
      map['data'] = data!.toJson();
    }
    return map;
  }
}

class StudentProfileData {
  int? id;
  int? classId;
  String? admissionNo;
  String? fullnameEnglish;
  String? fullnameKhmer;
  String? profile;
  String? dob;
  String? gender;
  String? phone;
  String? pod;
  String? address;
  String? className;
  String? teacher;

  StudentProfileData({
    this.id,
    this.classId,
    this.admissionNo,
    this.fullnameEnglish,
    this.fullnameKhmer,
    this.profile,
    this.dob,
    this.gender,
    this.phone,
    this.pod,
    this.address,
    this.className,
    this.teacher,
  });

  StudentProfileData.fromJson(Map<String, dynamic> json) {
    id = _toInt(json['id']);
    classId = _readClassId(json);
    admissionNo = _first(json, const ['admission_no']);
    fullnameEnglish = _first(json, const ['fullname_english', 'name_english']);
    fullnameKhmer = _first(json, const ['fullname_khmer', 'name_khmer']);
    profile = _first(json, const ['profile', 'profile_path', 'photo', 'image']);
    dob = _first(json, const ['dob', 'date_of_birth', 'birth_date']);
    gender = _first(json, const ['gender', 'sex']);
    phone = _first(json, const ['phone']);
    pod = _first(json, const ['pod', 'pob', 'place_of_birth']);
    address = _first(json, const ['address']);
    className = _readClassName(json);
    teacher = _first(json, const ['teacher', 'teacher_name']);
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['class_id'] = classId;
    map['admission_no'] = admissionNo;
    map['fullname_english'] = fullnameEnglish;
    map['fullname_khmer'] = fullnameKhmer;
    map['profile'] = profile;
    map['dob'] = dob;
    map['gender'] = gender;
    map['phone'] = phone;
    map['pod'] = pod;
    map['address'] = address;
    map['class'] = className;
    map['teacher'] = teacher;
    return map;
  }
}

int? _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
}

int? _readClassId(Map<String, dynamic> json) {
  final direct = _toInt(json['class_id'] ?? json['classId']);
  if (direct != null) {
    return direct;
  }

  final rawClass = json['class'];
  if (rawClass is Map<String, dynamic>) {
    return _toInt(rawClass['id'] ?? rawClass['class_id'] ?? rawClass['value']);
  }
  if (rawClass is Map) {
    final map = Map<String, dynamic>.from(rawClass);
    return _toInt(map['id'] ?? map['class_id'] ?? map['value']);
  }

  return null;
}

String? _s(dynamic value) {
  if (value == null) return null;
  final v = value.toString().trim();
  if (v.isEmpty || v.toLowerCase() == 'null' || v.toLowerCase() == 'n/a') {
    return null;
  }
  return v;
}

String? _first(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = _s(json[key]);
    if (value != null && value.isNotEmpty) {
      return value;
    }
  }
  return null;
}

String? _readClassName(Map<String, dynamic> json) {
  final direct = _first(
    json,
    const ['class_name', 'class', 'grade', 'grade_name'],
  );
  if (direct != null && direct.isNotEmpty && !direct.startsWith('{')) {
    return direct;
  }

  final rawClass = json['class'];
  if (rawClass is Map<String, dynamic>) {
    return _first(rawClass, const ['name', 'class_name', 'title', 'label']);
  }
  if (rawClass is Map) {
    final map = Map<String, dynamic>.from(rawClass);
    return _first(map, const ['name', 'class_name', 'title', 'label']);
  }

  return null;
}
