class TeacherDashboardModel {
  const TeacherDashboardModel({
    required this.totalClasses,
    required this.totalStudents,
  });

  final int totalClasses;
  final int totalStudents;

  factory TeacherDashboardModel.fromJson(Map<String, dynamic> json) {
    final source =
        json['data'] is Map
            ? Map<String, dynamic>.from(json['data'] as Map)
            : json;
    return TeacherDashboardModel(
      totalClasses: _asInt(source['total_classes'] ?? source['totalClasses']),
      totalStudents:
          _asInt(source['total_students'] ?? source['totalStudents']),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse((value ?? '').toString()) ?? 0;
  }
}
