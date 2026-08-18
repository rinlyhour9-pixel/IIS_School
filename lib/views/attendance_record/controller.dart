import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/models/staff/model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AttendanceRecordController extends GetxController {
  final TextEditingController searchCtl = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final RxString selectedDate = ''.obs;
  final RxString selectedStatus = ''.obs;
  final RxList<StaffAttendanceItem> attendanceList =
      <StaffAttendanceItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxString presentSummary = '0'.obs;
  final RxString lateSummary = '0'.obs;
  final RxString absentSummary = '0'.obs;
  final RxString permissionSummary = '0'.obs;

  final RxInt currentPage = 1.obs;
  final RxInt lastPage = 1.obs;
  final RxInt total = 0.obs;
  final RxInt perPage = 0.obs;

  final List<StaffAttendanceItem> _allLogs = <StaffAttendanceItem>[];
  bool get isParentMode => UserRepository.shared.isParent;
  SelectedStudentService get _selectedStudentService =>
      Get.find<SelectedStudentService>();

  @override
  void onInit() {
    super.onInit();
    selectedDate.value = '';
    loadAttendanceLogs();
  }

  @override
  void onClose() {
    searchCtl.dispose();
    super.onClose();
  }

  void reset() {
    searchCtl.clear();
    selectedDate.value = '';
    loadAttendanceLogs();
  }

  Future<void> loadAttendanceLogs() async {
    try {
      isLoading.value = true;
      final selectedStudentId = await _selectedStudentId();
      final params = <String, dynamic>{};
      if (selectedDate.value.trim().isNotEmpty) {
        params['date'] = selectedDate.value;
      }
      if (isParentMode) {
        if (selectedStudentId.isEmpty) {
          _clearAll();
          return;
        }
        params['student_id'] = selectedStudentId;
      } else if (selectedStudentId.isNotEmpty) {
        params['student_id'] = selectedStudentId;
      }

      final endpoint =
          isParentMode
              ? EndPoints.parentChildrenAttendanceLog
              : EndPoints.attendanceRecord;

      final res = await Get.find<ApiService>().get(
        endpoint,
        queryParameters: params.isEmpty ? null : params,
        isShowLoading: false,
      );
      final payload = res.data;
      if (payload is! Map) {
        _clearAll();
        return;
      }

      final model = StaffModel.fromJson(Map<String, dynamic>.from(payload));

      presentSummary.value = model.summary?.present ?? '0';
      lateSummary.value = model.summary?.late ?? '0';
      absentSummary.value = model.summary?.absent ?? '0';
      permissionSummary.value = model.summary?.permission ?? '0';

      currentPage.value = model.data?.currentPage ?? 1;
      lastPage.value = model.data?.lastPage ?? 1;
      perPage.value = model.data?.perPage ?? 0;
      total.value = model.data?.total ?? 0;

      final logs =
          (model.data?.items ?? const <StaffAttendanceItem>[])
              .map(_normalizeAttendanceItemFromModel)
              .toList();

      _allLogs
        ..clear()
        ..addAll(logs);
      _applyFilters();
    } catch (e) {
      _clearAll();
      ExceptionHandler.handleException(e, alert: false);
    } finally {
      isLoading.value = false;
    }
  }

  void clearDateFilter() {
    if (selectedDate.value.trim().isEmpty) {
      return;
    }
    selectedDate.value = '';
    loadAttendanceLogs();
  }

  void toggleStatusFilter(String rawStatus) {
    final normalized = _normalizeStatus(rawStatus);
    if (selectedStatus.value == normalized) {
      selectedStatus.value = '';
    } else {
      selectedStatus.value = normalized;
    }
    _applyFilters();
  }

  void clearStatusFilter() {
    if (selectedStatus.value.isEmpty) {
      return;
    }
    selectedStatus.value = '';
    _applyFilters();
  }

  bool isStatusSelected(String rawStatus) {
    return selectedStatus.value == _normalizeStatus(rawStatus);
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
      loadAttendanceLogs();
    }
  }

  void _applyFilters() {
    final date = selectedDate.value.trim();
    final status = selectedStatus.value.trim();
    final filtered =
        _allLogs.where((e) {
          if (date.isEmpty) {
            if (status.isEmpty) {
              return true;
            }
            return _matchesStatusFilter(_normalizeStatus(e.status), status);
          }
          final matchesDate = _normalizeDate(e.attendanceDate) == date;
          if (!matchesDate) {
            return false;
          }
          if (status.isEmpty) {
            return true;
          }
          return _matchesStatusFilter(_normalizeStatus(e.status), status);
        }).toList();

    filtered.sort((a, b) {
      final aCreated = DateTime.tryParse(a.createdAt);
      final bCreated = DateTime.tryParse(b.createdAt);
      if (aCreated == null && bCreated == null) {
        return 0;
      }
      if (aCreated == null) {
        return 1;
      }
      if (bCreated == null) {
        return -1;
      }
      return bCreated.compareTo(aCreated);
    });

    attendanceList.assignAll(filtered);
  }

  String _normalizeDate(String value) {
    final text = value.trim();
    if (text.isEmpty) {
      return text;
    }

    final parsed = DateTime.tryParse(text);
    if (parsed != null) {
      return '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
    }

    final parts = text.split('-');
    if (parts.length == 3 &&
        parts[0].length == 2 &&
        parts[1].length == 2 &&
        parts[2].length == 4) {
      return '${parts[2]}-${parts[1]}-${parts[0]}';
    }
    return text;
  }

  String _normalizeStatus(String rawStatus) {
    final status = rawStatus.toLowerCase().trim();
    if (status.contains('permission')) {
      return 'permission';
    }
    if (status.contains('late')) {
      return 'late';
    }
    if (status.contains('absent')) {
      return 'absent';
    }
    return 'present';
  }

  bool _matchesStatusFilter(String itemStatus, String selected) {
    if (selected == 'present') {
      // Business rule: Present tab should include late arrivals too.
      return itemStatus == 'present' || itemStatus == 'late';
    }
    return itemStatus == selected;
  }

  String _normalizeTime(String rawTime, String createdAt) {
    final time = rawTime.trim();
    if (time.isNotEmpty && time != '-') {
      return time;
    }

    final parsed = DateTime.tryParse(createdAt.trim());
    if (parsed == null) {
      return '-';
    }

    final h = parsed.hour % 12 == 0 ? 12 : parsed.hour % 12;
    final m = parsed.minute.toString().padLeft(2, '0');
    final period = parsed.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  StaffAttendanceItem _normalizeAttendanceItemFromModel(
    StaffAttendanceItem item,
  ) {
    final date = _normalizeDate(
      item.attendanceDate.isEmpty ? item.createdAt : item.attendanceDate,
    );

    return StaffAttendanceItem(
      id: item.id,
      staffCode: item.staffCode,
      fullnameEn: item.fullnameEn,
      fullnameKh: item.fullnameKh,
      profile: item.profile,
      attendanceDate: date,
      timeIn1: _normalizeTime(
        item.timeIn1.isEmpty ? '-' : item.timeIn1,
        item.createdAt,
      ),
      timeOut1: item.timeOut1.isEmpty ? '-' : item.timeOut1,
      timeIn2: item.timeIn2.isEmpty ? '-' : item.timeIn2,
      timeOut2: item.timeOut2.isEmpty ? '-' : item.timeOut2,
      status: item.status.isEmpty ? 'present' : item.status,
      createdAt: item.createdAt,
    );
  }

  void _clearAll() {
    _allLogs.clear();
    attendanceList.clear();
    selectedStatus.value = '';
    presentSummary.value = '0';
    lateSummary.value = '0';
    absentSummary.value = '0';
    permissionSummary.value = '0';
    currentPage.value = 1;
    lastPage.value = 1;
    perPage.value = 0;
    total.value = 0;
  }

  Future<String> _selectedStudentId() async {
    final selectedId = _selectedStudentService.current?.id.trim() ?? '';
    if (selectedId.isNotEmpty) {
      return selectedId;
    }

    final selected =
        (await SharedPreferencesManager.get('selected_child_id') ?? '')
            .toString()
            .trim();
    if (selected.isNotEmpty) {
      return selected;
    }
    return (await SharedPreferencesManager.get('student_info_id') ?? '')
        .toString()
        .trim();
  }
}
