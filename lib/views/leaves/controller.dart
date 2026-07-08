import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/models/models.dart';

class LeavesController extends GetxController {
  final RxString selectedStatus = ''.obs; // '' = All
  final RxString selectedDate = ''.obs; // '' = All dates
  final RxList<LeaveItem> leaveList = <LeaveItem>[].obs;
  final RxBool isLoading = false.obs;

  final RxBool isDetailLoading = false.obs;
  final Rxn<LeaveItem> selectedLeave = Rxn<LeaveItem>();

  final RxInt currentPage = 1.obs;
  final RxInt lastPage = 1.obs;
  final RxInt total = 0.obs;

  final List<LeaveItem> _allLeaves = <LeaveItem>[];

  @override
  void onInit() {
    super.onInit();
    loadLeaves();
  }

  Future<void> loadLeaves() async {
    try {
      isLoading.value = true;
      final params = <String, dynamic>{};
      if (selectedDate.value.trim().isNotEmpty) {
        params['attendance_date'] = selectedDate.value;
      }

      final res = await Get.find<ApiService>().get(
        EndPoints.leaveList,
        queryParameters: params.isEmpty ? null : params,
        isShowLoading: false,
      );
      final payload = res.data;
      if (payload is! Map) {
        _clearAll();
        return;
      }

      final model = LeaveListResponse.fromJson(
        Map<String, dynamic>.from(payload),
      );

      currentPage.value = model.data?.currentPage ?? 1;
      lastPage.value = model.data?.lastPage ?? 1;
      total.value = model.data?.total ?? 0;

      _allLeaves
        ..clear()
        ..addAll(model.data?.items ?? const <LeaveItem>[]);
      _applyFilters();
    } catch (e) {
      _clearAll();
      ExceptionHandler.handleException(e, alert: false);
    } finally {
      isLoading.value = false;
    }
  }

  void setStatusFilter(String status) {
    if (selectedStatus.value == status) return;
    selectedStatus.value = status;
    _applyFilters();
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
      loadLeaves();
    }
  }

  void clearDate() {
    if (selectedDate.value.isEmpty) return;
    selectedDate.value = '';
    loadLeaves();
  }

  void _applyFilters() {
    final status = selectedStatus.value.trim();
    final filtered =
        status.isEmpty
            ? List<LeaveItem>.from(_allLeaves)
            : _allLeaves
                .where((e) => e.status.toLowerCase() == status.toLowerCase())
                .toList();
    leaveList.assignAll(filtered);
  }

  Future<void> viewLeaveDetail(int id) async {
    try {
      isDetailLoading.value = true;
      selectedLeave.value = null;
      final res = await Get.find<ApiService>().get(
        EndPoints.leaveDetail(id),
        isShowLoading: false,
      );
      final payload = res.data;
      if (payload is! Map) {
        return;
      }
      final model = LeaveDetailResponse.fromJson(
        Map<String, dynamic>.from(payload),
      );
      selectedLeave.value = model.data;
    } catch (e) {
      ExceptionHandler.handleException(e, alert: false);
    } finally {
      isDetailLoading.value = false;
    }
  }

  void _clearAll() {
    _allLeaves.clear();
    leaveList.clear();
    currentPage.value = 1;
    lastPage.value = 1;
    total.value = 0;
  }
}
