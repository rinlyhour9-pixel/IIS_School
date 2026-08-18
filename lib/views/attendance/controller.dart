import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/models/models.dart';

class AttendanceController extends GetxController {
  final TextEditingController searchCtl = TextEditingController();
  final ScrollController attendanceScrollCtl = ScrollController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final RxList<TrackingModel> trackings = <TrackingModel>[].obs;

  final RxList<AttendanceDetailRecord> records = <AttendanceDetailRecord>[].obs;
  final RxList<AttendanceMonthSummary> monthSummaries =
      <AttendanceMonthSummary>[].obs;
  final RxBool isLoadingSummary = true.obs;
  final RxString summaryError = ''.obs;
  final RxnString selectedStatusFilter = RxnString();
  final RxInt selectedMonth = DateTime.now().month.obs;
  final RxInt selectedYear = DateTime.now().year.obs;

  SelectedStudentService get _selectedStudentService =>
      Get.find<SelectedStudentService>();
  bool get isParentMode => UserRepository.shared.isParent;

  bool isDone = false;

  @override
  void onInit() {
    super.onInit();
    fetchAttendanceSummary();
  }

  @override
  void onClose() {
    attendanceScrollCtl.dispose();
    searchCtl.dispose();
    super.onClose();
  }

  Future<void> fetchTracking() async {
    try {
      final Map<String, dynamic> param = {'invoice': searchCtl.text};
      final res = await Get.find<ApiService>().get(
        EndPoints.tracking,
        queryParameters: param,
        isShowLoading: true,
      );
      final data = getPropertyFromJson(res.data, 'data');
      trackings.value = List.from(
        (data as List).map((e) => TrackingModel.fromJson(e)).toList(),
      );
      isDone = true;
      DialogManager.hideLoading();
    } catch (e) {
      ExceptionHandler.handleException(e);
    }
  }

  Future<void> filter() async {
    selectedStatusFilter.value = null;
    await fetchAttendanceSummary();
  }

  Future<void> selectMonth(MonthFilterItem item) async {
    selectedMonth.value = item.month;
    await filter();
  }

  void toggleStatusFilter(String status) {
    if (selectedStatusFilter.value == status) {
      selectedStatusFilter.value = null;
      return;
    }
    selectedStatusFilter.value = status;
  }

  Future<void> fetchAttendanceSummary() async {
    isLoadingSummary.value = true;
    summaryError.value = '';
    try {
      final studentId = await _resolveStudentId();
      if (studentId == null) {
        records.clear();
        monthSummaries.clear();
        summaryError.value = 'No student selected';
        return;
      }

      final res = await Get.find<ApiService>().get(
        EndPoints.parentAttendanceDetails(studentId.toString()),
        isShowLoading: false,
      );

      if (res.data is! Map) {
        records.clear();
        monthSummaries.clear();
        return;
      }

      final model = AttendanceDetailResponse.fromJson(
        Map<String, dynamic>.from(res.data as Map),
      );
      monthSummaries.assignAll(model.summary);
      records.assignAll(_filterBySelectedMonth(model.data));
    } catch (e) {
      records.clear();
      monthSummaries.clear();
      summaryError.value = 'Failed to load attendance summary';
      ExceptionHandler.handleException(e, alert: false);
    } finally {
      isLoadingSummary.value = false;
    }
  }

  List<AttendanceDetailRecord> _filterBySelectedMonth(
    List<AttendanceDetailRecord> items,
  ) {
    return items
        .where((item) {
          final date = DateTime.tryParse(item.date);
          if (date == null) return true;
          return date.month == selectedMonth.value &&
              date.year == selectedYear.value;
        })
        .toList(growable: false);
  }

  AttendanceMonthSummary? get _currentMonthSummary {
    final key =
        '${selectedYear.value.toString().padLeft(4, '0')}-${selectedMonth.value.toString().padLeft(2, '0')}';
    for (final s in monthSummaries) {
      if (s.month == key) return s;
    }
    return null;
  }

  int get totalPresent =>
      _currentMonthSummary?.totalPresence ?? _countByStatus('present');
  int get totalLate =>
      _currentMonthSummary?.totalLate ?? _countByStatus('late');
  int get totalAbsent =>
      _currentMonthSummary?.totalAbsent ?? _countByStatus('absent');
  int get totalPermission =>
      _currentMonthSummary?.totalPermission ?? _countByStatus('permission');

  int _countByStatus(String status) =>
      records.where((r) => r.status.toLowerCase() == status).length;

  Future<int?> _resolveStudentId() async {
    final selectedId = _selectedStudentService.current?.id.trim() ?? '';
    if (selectedId.isNotEmpty) {
      final parsed = int.tryParse(selectedId);
      if (parsed != null) return parsed;
    }

    final keys = <String>[
      'selected_child_id',
      'student_info_id',
      'last_leave_student_id',
    ];
    for (final key in keys) {
      final value =
          (await SharedPreferencesManager.get(key) ?? '').toString().trim();
      if (value.isEmpty) continue;
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
    return null;
  }
}
