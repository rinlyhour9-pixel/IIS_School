import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/models/models.dart';

class LeavesController extends GetxController with WidgetsBindingObserver {
  final RxString selectedStatus = ''.obs;
  final RxString fromDate = ''.obs;
  final RxString toDate = ''.obs;
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
    WidgetsBinding.instance.addObserver(this);
    loadLeaves();
  }

  @override
  void onReady() {
    super.onReady();
    loadLeaves();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      loadLeaves();
    }
  }

  Future<void> loadLeaves() async {
    try {
      isLoading.value = true;
      final params = <String, dynamic>{};
      if (fromDate.value.trim().isNotEmpty) {
        params['from_date'] = fromDate.value;
      }
      if (toDate.value.trim().isNotEmpty) {
        params['to_date'] = toDate.value;
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

  Future<void> pickFromDate(BuildContext context) async {
    final picked = await _showDatePicker(
      context,
      initialDate: DateTime.tryParse(fromDate.value) ?? DateTime.now(),
    );
    if (picked != null) {
      fromDate.value = _formatDate(picked);
    }
  }

  Future<void> pickToDate(BuildContext context) async {
    final picked = await _showDatePicker(
      context,
      initialDate:
          DateTime.tryParse(toDate.value) ??
          DateTime.tryParse(fromDate.value) ??
          DateTime.now(),
    );
    if (picked != null) {
      toDate.value = _formatDate(picked);
    }
  }

  Future<DateTime?> _showDatePicker(
    BuildContext context, {
    required DateTime initialDate,
  }) {
    return showDatePicker(
      context: context,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void applyDateFilter() {
    loadLeaves();
  }

  void clearDateFilter() {
    if (fromDate.value.isEmpty && toDate.value.isEmpty) return;
    fromDate.value = '';
    toDate.value = '';
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
