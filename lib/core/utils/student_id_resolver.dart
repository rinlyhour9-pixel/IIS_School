import 'package:get/get.dart';
import 'package:schoolapp/core/libraries/shared_preferences.dart';
import 'package:schoolapp/core/services/selected_student_service.dart';

class StudentIdResolver {
  StudentIdResolver._();

  static const List<String> _keys = <String>[
    'selected_child_id',
    'student_info_id',
    'last_leave_student_id',
  ];

  static Future<int?> resolve() async {
    if (Get.isRegistered<SelectedStudentService>()) {
      final selectedId =
          Get.find<SelectedStudentService>().current?.id.trim() ?? '';
      if (selectedId.isNotEmpty) {
        final parsed = int.tryParse(selectedId);
        if (parsed != null) {
          return parsed;
        }
      }
    }

    for (final key in _keys) {
      final raw =
          (await SharedPreferencesManager.get(key) ?? '').toString().trim();
      if (raw.isEmpty) continue;

      final parsed = int.tryParse(raw);
      if (parsed != null) {
        return parsed;
      }
    }
    return null;
  }

  static Future<int?> resolveClassId() async {
    if (Get.isRegistered<SelectedStudentService>()) {
      final selectedClassId =
          Get.find<SelectedStudentService>().current?.classId.trim() ?? '';
      if (selectedClassId.isNotEmpty) {
        final parsed = int.tryParse(selectedClassId);
        if (parsed != null) {
          return parsed;
        }
      }
    }

    for (final key in ['selected_child_class_id', 'student_info_class_id']) {
      final raw =
          (await SharedPreferencesManager.get(key) ?? '').toString().trim();
      if (raw.isEmpty) continue;

      final parsed = int.tryParse(raw);
      if (parsed != null) {
        return parsed;
      }
    }
    return null;
  }
}
