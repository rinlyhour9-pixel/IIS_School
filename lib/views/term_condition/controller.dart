import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/models/models.dart';

class TermConditionController extends GetxController {
  final Rxn<TermsConditionsModel> data = Rxn<TermsConditionsModel>();
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onReady() {
    super.onReady();
    fetchTermsAndConditions();
  }

  Future<void> fetchTermsAndConditions() async {
    isLoading.value = true;
    error.value = '';

    try {
      final res = await Get.find<ApiService>().get(
        EndPoints.termsAndConditions,
        isShowLoading: false,
      );

      if (res.data is! Map) {
        error.value = LocaleKeys.invalidResponseData.tr;
        return;
      }

      data.value = TermsConditionsModel.fromJson(
        Map<String, dynamic>.from(res.data as Map),
      );
    } catch (e) {
      error.value = LocaleKeys.somethingWentWrong.tr;
      ExceptionHandler.handleException(e, alert: false);
    } finally {
      isLoading.value = false;
    }
  }
}
