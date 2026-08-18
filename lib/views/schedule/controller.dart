import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/models/models.dart';

class ScheduleController extends GetxController {
  final TextEditingController searchCtl = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final RxList<ScheduleTimetable> timetables = <ScheduleTimetable>[].obs;
  final Rxn<ScheduleTimetable> timetable = Rxn<ScheduleTimetable>();
  final RxInt selectedIndex = 0.obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onReady() {
    super.onReady();
    fetchStudentTimeSheet();
  }

  @override
  void onClose() {
    searchCtl.dispose();
    super.onClose();
  }

  void selectTimetable(int index) {
    if (index < 0 || index >= timetables.length) return;

    selectedIndex.value = index;
    timetable.value = timetables[index];
  }

  Future<void> fetchStudentTimeSheet() async {
    isLoading.value = true;
    error.value = '';

    try {
      final isParent = UserRepository.shared.isParent;
      final studentId = isParent ? await StudentIdResolver.resolve() : null;
      final classId =
          isParent
              ? await StudentIdResolver.resolveClassId()
              : null; // TODO see note below

      if (isParent && (studentId == null || classId == null)) {
        timetables.clear();
        timetable.value = null;
        selectedIndex.value = 0;
        error.value = LocaleKeys.scheduleStudentRequired.tr;
        return;
      }

      final res = await Get.find<ApiService>().get(
        isParent ? EndPoints.studentTimeSheet : EndPoints.teacherTimeSheet,
        queryParameters:
            isParent ? {'student_id': studentId, 'class_id': classId} : null,
        isShowLoading: false,
      );

      if (res.data is! Map) {
        timetables.clear();
        timetable.value = null;
        selectedIndex.value = 0;
        error.value = LocaleKeys.invalidResponseData.tr;
        return;
      }

      final parsed = ScheduleResponse.fromJson(
        Map<String, dynamic>.from(res.data as Map),
      );
      timetables.assignAll(parsed.timetables);
      final nextIndex =
          selectedIndex.value < timetables.length ? selectedIndex.value : 0;
      selectedIndex.value = nextIndex;
      timetable.value = timetables.isNotEmpty ? timetables[nextIndex] : null;
      if (timetable.value == null) {
        error.value = LocaleKeys.invalidResponseData.tr;
      }
    } catch (e) {
      debugPrint('Failed to load schedule: $e');
      timetables.clear();
      timetable.value = null;
      selectedIndex.value = 0;
      error.value = LocaleKeys.failedToLoadSchedule.tr;
      ExceptionHandler.handleException(e, alert: false);
    } finally {
      isLoading.value = false;
    }
  }
}
