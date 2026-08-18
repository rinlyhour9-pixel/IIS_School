import 'package:get/get.dart';
import 'package:schoolapp/core/libraries/shared_preferences.dart';
import 'package:schoolapp/models/child_profile/model.dart';

class SelectedStudentService extends GetxService {
  final RxList<ChildProfile> children = <ChildProfile>[].obs;
  final Rxn<ChildProfile> selected = Rxn<ChildProfile>();

  Future<SelectedStudentService> initialize() async {
    await _loadSelectedFromStorage();
    return this;
  }

  ChildProfile? get current => selected.value;

  Future<void> setChildren(
    List<ChildProfile> nextChildren, {
    String preferredId = '',
  }) async {
    children.assignAll(nextChildren);

    if (nextChildren.isEmpty) {
      selected.value = null;
      return;
    }

    final targetId = preferredId.trim().isNotEmpty
        ? preferredId.trim()
        : selected.value?.id.trim() ?? '';

    ChildProfile resolved = nextChildren.first;
    for (final child in nextChildren) {
      if (child.id == targetId) {
        resolved = child;
        break;
      }
    }

    await selectChild(resolved);
  }

  Future<void> selectChild(ChildProfile child) async {
    selected.value = child;
    await _persistChild(child);
  }

  Future<void> refreshFromStorage() async {
    await _loadSelectedFromStorage();
  }

  Future<void> clear() async {
    children.clear();
    selected.value = null;
    await Future.wait([
      SharedPreferencesManager.remove('selected_child_id'),
      SharedPreferencesManager.remove('selected_child_name'),
      SharedPreferencesManager.remove('selected_child_avatar'),
      SharedPreferencesManager.remove('selected_child_class_id'),
      SharedPreferencesManager.remove('selected_child_class_name'),
      SharedPreferencesManager.remove('student_info_class_id'),
      SharedPreferencesManager.remove('student_info_class_name'),
    ]);
  }

  Future<void> _loadSelectedFromStorage() async {
    final child = ChildProfile(
      id: (await SharedPreferencesManager.get('selected_child_id') ?? '')
          .toString()
          .trim(),
      name: (await SharedPreferencesManager.get('selected_child_name') ?? '')
          .toString()
          .trim(),
      avatar: (await SharedPreferencesManager.get('selected_child_avatar') ?? '')
          .toString()
          .trim(),
      classId:
          (await SharedPreferencesManager.get('selected_child_class_id') ?? '')
              .toString()
              .trim(),
      className:
          (await SharedPreferencesManager.get('selected_child_class_name') ?? '')
              .toString()
              .trim(),
    );

    if (child.id.isEmpty &&
        child.name.isEmpty &&
        child.avatar.isEmpty &&
        child.classId.isEmpty &&
        child.className.isEmpty) {
      selected.value = null;
      return;
    }

    selected.value = child;
  }

  Future<void> _persistChild(ChildProfile child) async {
    await Future.wait([
      SharedPreferencesManager.setValue('selected_child_id', child.id),
      SharedPreferencesManager.setValue('selected_child_name', child.name),
      SharedPreferencesManager.setValue('selected_child_avatar', child.avatar),
      SharedPreferencesManager.setValue(
        'selected_child_class_id',
        child.classId,
      ),
      SharedPreferencesManager.setValue(
        'student_info_class_id',
        child.classId,
      ),
      SharedPreferencesManager.setValue(
        'selected_child_class_name',
        child.className,
      ),
      SharedPreferencesManager.setValue(
        'student_info_class_name',
        child.className,
      ),
    ]);
  }
}
