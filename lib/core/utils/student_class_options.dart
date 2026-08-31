import 'package:get/get.dart';
import 'package:schoolapp/core/services/api_service.dart';
import 'package:schoolapp/core/services/end_points.dart';

/// One class a student is enrolled in.
class StudentClassOption {
  const StudentClassOption({required this.id, required this.name});

  final int id;
  final String name;
}

/// Fetches every class a student is enrolled in.
///
/// A student can be in more than one class (e.g. KGE-K2 *and* KGE-K3), but
/// the rest of the app models a child with a single scalar `classId`
/// (`ChildProfile.classId`, `Student.classId`, the `selected_child_class_id`
/// pref), so the second class is otherwise invisible.
///
/// `/parent/student-class-section/{studentId}` is the only endpoint that
/// exposes the full list — it returns one row per class, each with a nested
/// `class: {id, name}` object. See `EndPoints.parentStudentClassSection` and
/// `RequestLeaveController._extractStudentClassSectionOptions`, which parses
/// the same shape for the Request Leave class dropdown.
///
/// Returns an empty list on any failure, so callers can fall back to the
/// existing single-class behaviour rather than breaking.
class StudentClassOptionsResolver {
  StudentClassOptionsResolver._();

  static Future<List<StudentClassOption>> fetch(String studentId) async {
    final trimmedId = studentId.trim();
    if (trimmedId.isEmpty) return const <StudentClassOption>[];

    try {
      final res = await Get.find<ApiService>().get(
        EndPoints.parentStudentClassSection(trimmedId),
        isShowLoading: false,
      );

      return parse(res.data);
    } catch (_) {
      return const <StudentClassOption>[];
    }
  }

  /// Pure parsing step, separated from the request so the shape handling can
  /// be exercised directly.
  static List<StudentClassOption> parse(dynamic raw) {
    final options = <StudentClassOption>[];
    final seenIds = <int>{};
    for (final row in _extractRows(raw)) {
      final option = _optionFromRow(row);
      if (option == null) continue;
      if (seenIds.add(option.id)) {
        options.add(option);
      }
    }

    options.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return options;
  }

  static StudentClassOption? _optionFromRow(Map<String, dynamic> row) {
    // Preferred shape: a nested `class` object. The flat shape below is only
    // a fallback — a row's own `id` there can be the pivot row's id rather
    // than the class id, so it is tried last.
    final rawClass = row['class'];
    if (rawClass is Map) {
      final classMap = Map<String, dynamic>.from(rawClass);
      final id = _readInt(classMap, const <String>['id', 'class_id', 'classId']);
      final name = _readText(classMap, const <String>[
        'name',
        'class_name',
        'className',
        'title',
        'label',
      ]);
      if (id != null && id > 0 && name.isNotEmpty) {
        return StudentClassOption(id: id, name: name);
      }
    }

    final flatId = _readInt(row, const <String>['class_id', 'classId', 'id']);
    final flatName = _readText(row, const <String>[
      'class_name',
      'className',
      'class',
      'grade',
      'name',
    ]);
    if (flatId != null && flatId > 0 && flatName.isNotEmpty) {
      return StudentClassOption(id: flatId, name: flatName);
    }
    return null;
  }

  static List<Map<String, dynamic>> _extractRows(dynamic raw, [int depth = 0]) {
    if (raw == null || depth > 4) return const <Map<String, dynamic>>[];

    if (raw is List) {
      return raw
          .expand((item) => _extractRows(item, depth + 1))
          .toList(growable: false);
    }
    if (raw is! Map) return const <Map<String, dynamic>>[];

    final map = Map<String, dynamic>.from(raw);
    for (final key in const <String>[
      'data',
      'classes',
      'student_classes',
      'studentClasses',
      'items',
      'rows',
      'list',
    ]) {
      if (!map.containsKey(key)) continue;
      final rows = _extractRows(map[key], depth + 1);
      if (rows.isNotEmpty) return rows;
    }

    return <Map<String, dynamic>>[map];
  }

  static int? _readInt(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      final parsed = int.tryParse((value ?? '').toString().trim());
      if (parsed != null) return parsed;
    }
    return null;
  }

  static String _readText(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final text = (map[key] ?? '').toString().trim();
      final lower = text.toLowerCase();
      if (text.isNotEmpty &&
          lower != 'null' &&
          lower != 'n/a' &&
          !text.startsWith('{')) {
        return text;
      }
    }
    return '';
  }
}
