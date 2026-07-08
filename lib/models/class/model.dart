class ClassModel {
  final int id;
  final int teacherId;
  final String className;

  const ClassModel({
    required this.id,
    required this.teacherId,
    required this.className,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'] as int,
      teacherId: json['teacher_id'] as int? ?? 0,
      className: json['class_name'] as String? ?? '',
    );
  }

  static List<ClassModel> listFromJson(List<dynamic> data) {
    return data
        .map((e) => ClassModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}

class SectionModel {
  final int id;
  final String section;

  const SectionModel({required this.id, required this.section});

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    return SectionModel(
      id: json['id'] as int,
      section: json['section'] as String? ?? '',
    );
  }

  static List<SectionModel> listFromJson(List<dynamic> data) {
    return data
        .map((e) => SectionModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}

class SubjectModel {
  final int id;
  final String name;
  final String code;

  const SubjectModel({
    required this.id,
    required this.name,
    required this.code,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
    );
  }

  static List<SubjectModel> listFromJson(List<dynamic> data) {
    return data
        .map((e) => SubjectModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
