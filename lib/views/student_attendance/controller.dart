import 'package:flutter/material.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/core/services/setting_repository.dart';
import 'package:schoolapp/models/models.dart';
import 'package:get/get.dart';
import 'package:schoolapp/routes.dart';

class StudentAttendanceController extends GetxController {
  final SettingRepository _settingRepository = SettingRepository();

  final RxList<ClassModel> classes = <ClassModel>[].obs;
  final RxList<SectionModel> sections = <SectionModel>[].obs;
  final RxList<SubjectModel> subjects = <SubjectModel>[].obs;

  final Rx<ClassModel?> selectedClass = Rx<ClassModel?>(null);
  final Rx<SectionModel?> selectedSection = Rx<SectionModel?>(null);
  final Rx<SubjectModel?> selectedSubject = Rx<SubjectModel?>(null);
  final RxString selectedDate = ''.obs; // '' = all dates

  final RxList<StudentAttendanceSummaryItem> historyList =
      <StudentAttendanceSummaryItem>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDropdownOptions();
    loadHistory();
  }

  Future<void> loadDropdownOptions() async {
    try {
      final results = await Future.wait([
        _settingRepository.getClasses(),
        _settingRepository.getSections(),
        _settingRepository.getSubjects(),
      ]);
      classes.assignAll(results[0] as List<ClassModel>);
      sections.assignAll(results[1] as List<SectionModel>);
      subjects.assignAll(results[2] as List<SubjectModel>);
    } catch (e) {
      ExceptionHandler.handleException(e, alert: false);
    }
  }

  void selectClass(ClassModel? value) {
    selectedClass.value = value;
    loadHistory();
  }

  void selectSection(SectionModel? value) {
    selectedSection.value = value;
    loadHistory();
  }

  void selectSubject(SubjectModel? value) {
    selectedSubject.value = value;
    loadHistory();
  }

  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
          child: child!,
        );
      },
      initialDate: DateTime.tryParse(selectedDate.value) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      selectedDate.value =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      loadHistory();
    }
  }

  void clearDate() {
    if (selectedDate.value.isEmpty) return;
    selectedDate.value = '';
    loadHistory();
  }

  Future<void> loadHistory() async {
    try {
      isLoading.value = true;
      final params = <String, dynamic>{};
      if (selectedDate.value.trim().isNotEmpty) {
        params['attendance_date'] = selectedDate.value;
      }
      if (selectedClass.value != null) {
        params['class_id'] = selectedClass.value!.id;
      }
      if (selectedSection.value != null) {
        params['section_id'] = selectedSection.value!.id;
      }
      if (selectedSubject.value != null) {
        params['subject_id'] = selectedSubject.value!.id;
      }

      final res = await Get.find<ApiService>().get(
        EndPoints.studentAttendanceHistory,
        queryParameters: params.isEmpty ? null : params,
        isShowLoading: false,
      );
      // ignore: avoid_print
      print('Student attendance history debug -> params: $params');
      // ignore: avoid_print
      print('Student attendance history debug -> raw response: ${res.data}');
      final payload = res.data;
      if (payload is! Map) {
        historyList.clear();
        return;
      }

      final model = StudentAttendanceSummaryModel.fromJson(
        Map<String, dynamic>.from(payload),
      );
      historyList.assignAll(model.items);
    } catch (e) {
      historyList.clear();
      ExceptionHandler.handleException(e, alert: false);
    } finally {
      isLoading.value = false;
    }
  }

  void openDetail(StudentAttendanceSummaryItem item) {
    Get.toNamed(
      Routes.detailedAttendance,
      arguments: {
        'class_id': item.classId,
        'section_id': item.sectionId,
        'subject_id': item.subjectId,
        'attendance_date': item.attendanceDate,
      },
    );
  }

  void goToRecordAttendance() {
    Get.toNamed(Routes.recordAttendance);
  }
}
