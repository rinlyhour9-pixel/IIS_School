class ChildProfile {
  const ChildProfile({
    required this.id,
    required this.name,
    required this.avatar,
    this.classId = '',
    this.className = '',
  });
  final String id;
  final String name;
  final String avatar;
  final String classId;
  final String className;

  factory ChildProfile.fromDynamic(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final id =
          (raw['id'] ?? raw['student_id'] ?? raw['code'] ?? '')
              .toString()
              .trim();
      final name =
          (raw['name'] ??
                  raw['fullname_kh'] ??
                  raw['fullname_en'] ??
                  raw['full_name'] ??
                  raw['student_name'] ??
                  '')
              .toString()
              .trim();
      final avatar =
          (raw['profile_path'] ??
                  raw['profile'] ??
                  raw['avatar'] ??
                  raw['photo'] ??
                  raw['image'] ??
                  '')
              .toString()
              .trim();
      final classId =
          (raw['class_id'] ?? raw['classId'] ?? '').toString().trim();
      final className =
          (raw['class_name'] ?? raw['class'] ?? raw['grade'] ?? '')
              .toString()
              .trim();
      return ChildProfile(
        id: id,
        name: name,
        avatar: avatar,
        classId: classId,
        className: className,
      );
    }
    if (raw is Map) {
      return ChildProfile.fromDynamic(Map<String, dynamic>.from(raw));
    }
    return const ChildProfile(id: '', name: '', avatar: '');
  }
}
