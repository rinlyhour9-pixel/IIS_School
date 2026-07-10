import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/models/models.dart';

class ContactUsController extends GetxController {
  static const String _cacheKey = 'contact_us_cache_v1';
  final Rxn<ContactUsModel> contactUs = Rxn<ContactUsModel>();
  final RxBool isLoading = false.obs;
  bool _didFetch = false;

  @override
  void onInit() {
    _loadCachedContact();
    fetchContactUs();
    super.onInit();
  }

  Future<void> fetchContactUs() async {
    if (_didFetch || isLoading.value) return;
    try {
      _didFetch = true;
      isLoading.value = true;

      final branchId =
          (await SharedPreferencesManager.get('branch_id') ?? '')
              .toString()
              .trim();
      if (branchId.isEmpty) {
        _didFetch = false;
        return;
      }

      final res = await Get.find<ApiService>()
          .get(
            EndPoints.currentBranches(branchId),
            customBaseUrl: EndPoints.iisBaseUrl,
          )
          .timeout(const Duration(seconds: 4));
      final data = getPropertyFromJson(res.data, 'data');

      if (data is Map<String, dynamic>) {
        contactUs.value = ContactUsModel.fromJson(data);
        await SharedPreferencesManager.setValue(_cacheKey, jsonEncode(data));
      } else if (data is Map) {
        final normalized = Map<String, dynamic>.from(data);
        contactUs.value = ContactUsModel.fromJson(normalized);
        await SharedPreferencesManager.setValue(
          _cacheKey,
          jsonEncode(normalized),
        );
      }
    } on TimeoutException {
      // Keep cached UI visible when network is slow.
    } catch (e) {
      _didFetch = false;
      if (isClosed) {
        return;
      }
      ExceptionHandler.handleException(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadCachedContact() async {
    try {
      final raw = await SharedPreferencesManager.get(_cacheKey);
      if (raw is! String || raw.trim().isEmpty) return;
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        contactUs.value = ContactUsModel.fromJson(decoded);
      } else if (decoded is Map) {
        contactUs.value = ContactUsModel.fromJson(
          Map<String, dynamic>.from(decoded),
        );
      }
    } catch (_) {
      // Ignore cache parse failure.
    }
  }
}
