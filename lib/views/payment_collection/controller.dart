import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/models/models.dart';

class PaymentCollectionController extends GetxController {
  final TextEditingController searchCtl = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final RxList<TrackingModel> trackings = <TrackingModel>[].obs;
  bool isDone = false;

  @override
  void onClose() {
    searchCtl.dispose();
    super.onClose();
  }

  Future<void> fetchTracking() async {
    try {
      final studentId = await StudentIdResolver.resolve();
      if (studentId == null) {
        trackings.clear();
        throw 'Student ID is required.';
      }

      final Map<String, dynamic> param = {'student_id': studentId};
      final invoice = searchCtl.text.trim();
      if (invoice.isNotEmpty) {
        param['invoice'] = invoice;
      }

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
}
