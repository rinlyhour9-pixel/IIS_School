import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/core/services/setting_repository.dart';
import 'package:schoolapp/models/models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetailedAttendanceController extends GetxController {
  final TextEditingController searchCtl = TextEditingController();
  final SettingRepository _settingRepository = SettingRepository();

  final RxList<ClassModel> classes = <ClassModel>[].obs;
  final RxList<SectionModel> sections = <SectionModel>[].obs;
  final RxList<SubjectModel> subjects = <SubjectModel>[].obs;

  final Rx<ClassModel?> selectedClass = Rx<ClassModel?>(null);
  final Rx<SectionModel?> selectedSection = Rx<SectionModel?>(null);
  final Rx<SubjectModel?> selectedSubject = Rx<SubjectModel?>(null);
  final RxString selectedDate = ''.obs; // '' = all dates

  final RxList<DetailedAttendanceItem> studentList =
      <DetailedAttendanceItem>[].obs;
  final RxBool isLoading = false.obs;

  final List<DetailedAttendanceItem> _allStudents = <DetailedAttendanceItem>[];

  @override
  void onInit() {
    super.onInit();
    _prefillDateFromArguments();
    searchCtl.addListener(_applySearch);
    loadDropdownOptions();
  }

  @override
  void onClose() {
    searchCtl.dispose();
    super.onClose();
  }

  bool get canLoadStudents => selectedClass.value != null;

  void _prefillDateFromArguments() {
    final args = Get.arguments;
    if (args is Map && args['attendance_date'] != null) {
      selectedDate.value = args['attendance_date'].toString();
    }
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
      _prefillSelectionsFromArguments();
    } catch (e) {
      ExceptionHandler.handleException(e, alert: false);
    }
  }

  // If navigated from "view detail" on the history screen, arguments carry
  // class_id/section_id/subject_id so filters open pre-selected.
  void _prefillSelectionsFromArguments() {
    final args = Get.arguments;
    if (args is! Map) return;

    selectedClass.value = _findById(classes, args['class_id']);
    selectedSection.value = _findById(sections, args['section_id']);
    selectedSubject.value = _findById(subjects, args['subject_id']);

    if (canLoadStudents) loadDetails();
  }

  T? _findById<T>(List<T> list, dynamic id) {
    if (id == null) return null;
    for (final item in list) {
      final dynamic candidate = item;
      if (candidate.id == id) return item;
    }
    return null;
  }

  void selectClass(ClassModel? value) {
    selectedClass.value = value;
    loadDetails();
  }

  void selectSection(SectionModel? value) {
    selectedSection.value = value;
    loadDetails();
  }

  void selectSubject(SubjectModel? value) {
    selectedSubject.value = value;
    loadDetails();
  }

  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
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
      loadDetails();
    }
  }

  void clearDate() {
    if (selectedDate.value.isEmpty) return;
    selectedDate.value = '';
    loadDetails();
  }

  Future<void> loadDetails() async {
    if (!canLoadStudents) {
      _clearAll();
      return;
    }

    try {
      isLoading.value = true;
      final params = <String, dynamic>{'class_id': selectedClass.value!.id};
      if (selectedDate.value.trim().isNotEmpty) {
        params['attendance_date'] = selectedDate.value;
      }
      if (selectedSection.value != null) {
        params['section_id'] = selectedSection.value!.id;
      }
      if (selectedSubject.value != null) {
        params['subject_id'] = selectedSubject.value!.id;
      }

      final res = await Get.find<ApiService>().get(
        EndPoints.studentAttendanceDetails,
        queryParameters: params,
        isShowLoading: false,
      );
      final payload = res.data;
      if (payload is! Map) {
        _clearAll();
        return;
      }

      final dataSection = payload['data'];
      if (dataSection is! Map) {
        _clearAll();
        return;
      }

      final model = DetailedAttendanceModel.fromJson(
        Map<String, dynamic>.from(dataSection),
      );

      final deduped = <int, DetailedAttendanceItem>{};
      for (final item in model.items) {
        deduped[item.id] = item;
      }

      _allStudents
        ..clear()
        ..addAll(deduped.values);
      _applySearch();
    } catch (e) {
      _clearAll();
      ExceptionHandler.handleException(e, alert: false);
    } finally {
      isLoading.value = false;
    }
  }

  void _applySearch() {
    final query = searchCtl.text.trim().toLowerCase();
    if (query.isEmpty) {
      studentList.assignAll(_allStudents);
      return;
    }
    studentList.assignAll(
      _allStudents.where((row) {
        return row.studentName.toLowerCase().contains(query) ||
            row.studentNameKh.toLowerCase().contains(query) ||
            row.admissionNo.toLowerCase().contains(query);
      }),
    );
  }

  void _clearAll() {
    _allStudents.clear();
    studentList.clear();
  }
}
