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

  // Value equality by id — several screens rebuild dropdown `items` lists
  // from a fresh getter on every reactive rebuild (e.g. deriving Level from
  // live assignment data), which would otherwise create a new object each
  // time. AppIconDropdown matches its `value` against `items` via `==`
  // (identity by default), so without this a just-picked selection with the
  // same id but a different object instance would stop matching on the very
  // next rebuild and silently revert to the placeholder.
  @override
  bool operator ==(Object other) => other is ClassModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
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

  // See ClassModel's equality override for why this exists.
  @override
  bool operator ==(Object other) => other is SectionModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
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

  // See ClassModel's equality override for why this exists — this is the
  // one that was actually observed broken: Assessment Management's Subject
  // dropdown rebuilds its `items` from a getter over live assignment data,
  // and picking a subject stopped showing as selected until this was added.
  @override
  bool operator ==(Object other) => other is SubjectModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
