class ParentWithChild {
  bool? success;
  int? statusCode;
  String? message;
  Data? data;

  ParentWithChild({this.success, this.statusCode, this.message, this.data});

  ParentWithChild.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    statusCode = _toInt(json['statusCode'] ?? json['status_code']);
    message = json['message']?.toString();

    final rawData = json['data'];
    if (rawData is Map<String, dynamic>) {
      data = Data.fromJson(rawData);
    } else if (rawData is Map) {
      data = Data.fromJson(Map<String, dynamic>.from(rawData));
    } else {
      data = null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['statusCode'] = statusCode;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  Parent? parent;
  List<Student>? student;

  Data({this.parent, this.student});

  Data.fromJson(Map<String, dynamic> json) {
    final rawParent = json['parent'];
    if (rawParent is Map<String, dynamic>) {
      parent = Parent.fromJson(rawParent);
    } else if (rawParent is Map) {
      parent = Parent.fromJson(Map<String, dynamic>.from(rawParent));
    } else {
      parent = null;
    }

    final rawStudents = json['student'] ?? json['students'] ?? json['children'];
    if (rawStudents is List) {
      student =
          rawStudents
              .whereType<dynamic>()
              .map((v) {
                if (v is Map<String, dynamic>) {
                  return Student.fromJson(v);
                }
                if (v is Map) {
                  return Student.fromJson(Map<String, dynamic>.from(v));
                }
                return null;
              })
              .whereType<Student>()
              .toList();
    } else {
      student = <Student>[];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (parent != null) {
      data['parent'] = parent!.toJson();
    }
    if (student != null) {
      data['student'] = student!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Parent {
  int? id;
  String? name;
  String? phone;
  String? profile;
  String? occupation;

  Parent({this.id, this.name, this.phone, this.profile, this.occupation});

  Parent.fromJson(Map<String, dynamic> json) {
    id = _toInt(json['id']);
    name = json['name']?.toString();
    phone = json['phone']?.toString();
    profile = json['profile']?.toString();
    occupation = json['occupation']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['phone'] = phone;
    data['profile'] = profile;
    data['occupation'] = occupation;
    return data;
  }
}

class Student {
  int? id;
  int? classId;
  String? admissionNo;
  String? name;
  String? nameKh;
  String? phone;
  String? profile;
  String? className;
  String? section;
  String? feeCategory;
  String? dob;
  String? pob;
  String? sex;
  String? profession;
  String? parentName;

  Student({
    this.id,
    this.classId,
    this.admissionNo,
    this.name,
    this.nameKh,
    this.phone,
    this.profile,
    this.className,
    this.section,
    this.feeCategory,
    this.dob,
    this.pob,
    this.sex,
    this.profession,
    this.parentName,
  });

  Student.fromJson(Map<String, dynamic> json) {
    id = _toInt(json['id']);
    classId = _readClassId(json);
    admissionNo = _readString(json, const <String>['admission_no']);
    name = _readString(json, const <String>[
      'name',
      'student_name',
      'fullname_english',
    ]);

    nameKh = _readString(json, const <String>[
      'name_kh',
      'fullname_kh',
      'fullname_khmer',
    ]);

    phone = _readString(json, const <String>['phone']);

    profile = _readString(json, const <String>[
      'profile',
      'profile_path',
      'profile_url',
      'avatar',
      'avatar_url',
      'photo',
      'photo_path',
      'image',
      'image_url',
      'student_photo',
    ]);

    className = _readClassName(json);
    section = _readString(json, const <String>['section', 'section_name']);
    feeCategory = _readString(json, const <String>['fee_category']);
    dob = _readString(json, const <String>[
      'dob',
      'date_of_birth',
      'birth_date',
    ]);
    pob = _readString(json, const <String>[
      'pob',
      'pod',
      'place_of_birth',
      'birth_place',
    ]);
    sex = _readString(json, const <String>['sex', 'gender']);
    profession = _readString(json, const <String>[
      'profession',
      'occupation',
      'job',
      'parent_occupation',
    ]);
    parentName = _readString(json, const <String>[
      'parent_name',
      'guardian_name',
      'father_name',
      'mother_name',
      'teacher',
    ]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['class_id'] = classId;
    data['admission_no'] = admissionNo;
    data['name'] = name;
    data['name_kh'] = nameKh;
    data['phone'] = phone;
    data['profile'] = profile;
    data['class'] = className;
    data['section'] = section;
    data['fee_category'] = feeCategory;
    data['dob'] = dob;
    data['pob'] = pob;
    data['sex'] = sex;
    data['profession'] = profession;
    data['parent_name'] = parentName;
    return data;
  }
}

int? _toInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value.trim());
  }
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

String? _readClassName(Map<String, dynamic> json) {
  final direct = _readString(json, const <String>[
    'class_name',
    'class',
    'grade',
    'grade_name',
  ]);
  if (direct != null && direct.isNotEmpty) {
    return direct;
  }

  final rawClass = json['class'];
  if (rawClass is Map<String, dynamic>) {
    return _readString(rawClass, const <String>[
      'name',
      'class_name',
      'title',
      'label',
    ]);
  }
  if (rawClass is Map) {
    final map = Map<String, dynamic>.from(rawClass);
    return _readString(map, const <String>[
      'name',
      'class_name',
      'title',
      'label',
    ]);
  }

  return null;
}

String? _readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    final text = _stringFromDynamic(value);
    if (text != null && text.isNotEmpty) {
      return text;
    }
  }
  return null;
}

String? _stringFromDynamic(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is String) {
    final v = value.trim();
    if (v.isEmpty || v.toLowerCase() == 'null' || v.toLowerCase() == 'false') {
      return null;
    }
    return v;
  }
  if (value is num || value is bool) {
    return value.toString();
  }
  if (value is Map) {
    final map = Map<String, dynamic>.from(value);
    return _readString(map, const <String>[
      'url',
      'path',
      'src',
      'original_url',
      'full_path',
    ]);
  }
  return null;
}
