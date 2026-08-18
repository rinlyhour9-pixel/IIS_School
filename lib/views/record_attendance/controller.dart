import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/core/services/setting_repository.dart';
import 'package:schoolapp/models/models.dart';
import 'package:schoolapp/views/record_attendance/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RecordAttendanceController extends GetxController {
  final TextEditingController searchCtl = TextEditingController();
  final SettingRepository _settingRepository = SettingRepository();

  final RxList<ClassModel> classes = <ClassModel>[].obs;
  final RxList<SectionModel> sections = <SectionModel>[].obs;
  final RxList<SubjectModel> subjects = <SubjectModel>[].obs;

  final Rx<ClassModel?> selectedClass = Rx<ClassModel?>(null);
  final Rx<SectionModel?> selectedSection = Rx<SectionModel?>(null);
  final Rx<SubjectModel?> selectedSubject = Rx<SubjectModel?>(null);
  final RxString selectedDate = ''.obs;

  final RxList<StudentAttendanceRow> studentList = <StudentAttendanceRow>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;

  final List<StudentAttendanceRow> _allStudents = <StudentAttendanceRow>[];

  @override
  void onInit() {
    super.onInit();
    selectedDate.value = _today();
    searchCtl.addListener(_applySearch);
    loadDropdownOptions();
  }

  bool get canLoadStudents =>
      selectedClass.value != null &&
      selectedSection.value != null &&
      selectedSubject.value != null;

  @override
  void onClose() {
    searchCtl.dispose();
    super.onClose();
  }

  String _today() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
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
    loadStudentAttendance();
  }

  void selectSection(SectionModel? value) {
    selectedSection.value = value;
    loadStudentAttendance();
  }

  void selectSubject(SubjectModel? value) {
    selectedSubject.value = value;
    loadStudentAttendance();
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
      loadStudentAttendance();
    }
  }

  Future<void> loadStudentAttendance() async {
    if (!canLoadStudents) {
      _clearAll();
      return;
    }

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
        EndPoints.studentAttendanceList,
        queryParameters: params.isEmpty ? null : params,
        isShowLoading: false,
      );
      final payload = res.data;
      if (payload is! Map) {
        _clearAll();
        return;
      }

      final model = StudentAttendanceModel.fromJson(
        Map<String, dynamic>.from(payload),
      );

      // API can return duplicate rows per student_id; last occurrence wins.
      final deduped = <int, StudentAttendanceItem>{};
      for (final item in model.items) {
        deduped[item.id] = item;
      }

      _allStudents
        ..clear()
        ..addAll(deduped.values.map(StudentAttendanceRow.fromItem));
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

  void togglePresence(StudentAttendanceRow row) {
    if (row.presence.value) return;
    row.presence.value = true;
    row.late.value = false;
    row.absent.value = false;
    row.permission.value = false;
  }

  void toggleLate(StudentAttendanceRow row) {
    if (row.late.value) return;
    row.presence.value = false;
    row.late.value = true;
    row.absent.value = false;
    row.permission.value = false;
  }

  void toggleAbsent(StudentAttendanceRow row) {
    if (row.absent.value) return;
    row.presence.value = false;
    row.late.value = false;
    row.absent.value = true;
    row.permission.value = false;
  }

  void togglePermission(StudentAttendanceRow row) {
    if (row.permission.value) return;
    row.presence.value = false;
    row.late.value = false;
    row.absent.value = false;
    row.permission.value = true;
  }

  void updateNote(StudentAttendanceRow row, String note) {
    row.note.value = note;
  }

  void selectAllPresent() {
    for (final row in _allStudents) {
      row.presence.value = true;
      row.late.value = false;
      row.absent.value = false;
      row.permission.value = false;
    }
  }

  Future<void> submitAttendance() async {
    if (selectedClass.value == null ||
        selectedSection.value == null ||
        selectedSubject.value == null) {
      Get.snackbar(
        'Missing selection',
        'Select class, section and subject first',
      );
      return;
    }

    try {
      isSubmitting.value = true;
      final studentPayload = <String, dynamic>{};
      for (final row in _allStudents) {
        studentPayload[row.id.toString()] = {
          'presence': row.presence.value,
          'late': row.late.value,
          'absent': row.absent.value,
          'permission': row.permission.value,
          'note': row.note.value,
        };
      }

      final body = {
        'class_id': selectedClass.value!.id,
        'section_id': selectedSection.value!.id,
        'subject_id': selectedSubject.value!.id,
        'attendance_date': selectedDate.value,
        'student_id': studentPayload,
      };

      await Get.find<ApiService>().post(
        EndPoints.studentAttendanceRecord,
        body,
        isShowLoading: false,
      );

      Get.snackbar(
        'Success',
        'Attendance submitted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF14925A),
        titleText: const Text(
          'Success',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        messageText: const Text(
          'Attendance submitted successfully',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit attendance',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFD32F2F),
        titleText: const Text(
          'Error',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        messageText: const Text(
          'Failed to submit attendance',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
      ExceptionHandler.handleException(e, alert: true);
    } finally {
      isSubmitting.value = false;
    }
  }

  void _clearAll() {
    _allStudents.clear();
    studentList.clear();
  }
}
