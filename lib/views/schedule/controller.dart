import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/models/models.dart';

class ScheduleController extends GetxController {
  final TextEditingController searchCtl = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final Rxn<ScheduleTimetable> timetable = Rxn<ScheduleTimetable>();
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
        timetable.value = null;
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
        timetable.value = null;
        error.value = LocaleKeys.invalidResponseData.tr;
        return;
      }

      final parsed = ScheduleResponse.fromJson(
        Map<String, dynamic>.from(res.data as Map),
      );
      timetable.value =
          parsed.timetables.isNotEmpty ? parsed.timetables.first : null;
      if (timetable.value == null) {
        error.value = LocaleKeys.invalidResponseData.tr;
      }
    } catch (e) {
      debugPrint('Failed to load schedule: $e');
      timetable.value = null;
      error.value = LocaleKeys.failedToLoadSchedule.tr;
      ExceptionHandler.handleException(e, alert: false);
    } finally {
      isLoading.value = false;
    }
  }
}
