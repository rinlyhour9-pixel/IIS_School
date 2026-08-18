import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/models/models.dart';
import 'package:intl/intl.dart';

class DashboardController extends GetxController {
  final TextEditingController dateCtl = TextEditingController();

  final Rxn<DashboardModel> dashboardModel = Rxn<DashboardModel>();
  final RxBool isLoading = false.obs;
  final RxBool isSliderLoading = false.obs;

  final RxList<BookingModel> bookings = <BookingModel>[].obs;
  final RxList<String> sliderImages = <String>[].obs;
  int _sliderRetryCount = 0;
  static const int _maxSliderRetries = 3;

  final PageController pageController = PageController();

  var userName = "".obs;
  bool isFirst = true;
  //get name user profile when they loggin
  String get displayName {
    if (userName.value.isEmpty) return "";
    return userName.value[0].toUpperCase() + userName.value.substring(1);
  }

  void togglePage() {
    isFirst = !isFirst;
    pageController.animateToPage(
      isFirst ? 0 : 1, // Index of the second page
      duration: Duration(milliseconds: 200),
      curve: Curves.bounceIn,
    );
    update();
  }

  DatePicker getDatePicker() {
    final DatePicker startPicker = DatePicker(
      controller: dateCtl,
      initialDate:
          dateCtl.text.isEmpty
              ? DateTime.parse(
                '${DateFormat("yyyy-MM-dd").format(DateTime.now())} 00:00:00',
              )
              : DateTime.parse(dateCtl.text),
      minDate: DateTime(DateTime.now().year - 200),
      maxDate: DateTime(DateTime.now().year + 200),
      minYear: DateTime.now().year - 200,
      maxYear: DateTime.now().year + 200,
    );
    return startPicker;
  }

  @override
  void onInit() {
    // reasonCtl.fetchReason();
    // fetchDashboard();
    super.onInit();
    loadUserName();
    fetchSliders();
  }

  @override
  void onClose() {
    dateCtl.dispose();
    super.onClose();
  }

  Future<void> loadUserName() async {
    final name = await SharedPreferencesManager.get('name') ?? '';
    userName.value = name;
  }

  Future<void> fetchDashboard({String? date, bool isRefresh = false}) async {
    try {
      if (!isRefresh) {
        isLoading.value = true;
      } else {
        clearDateFilter();
      }

      final String now = DateFormat('yyyy-MM-dd').format(DateTime.now());
      date = date ?? now;

      String endPoint = '${EndPoints.dashboard}?date=$date';
      if (!UserRepository.shared.isParent) {
        endPoint = 'customer/$endPoint';
      }

      final res = await Get.find<ApiService>().get(
        endPoint,
        isShowLoading: false,
      );

      final data = getPropertyFromJson(res.data, 'data');

      if (!UserRepository.shared.isParent) {
        final bookingData = getPropertyFromJson(res.data, 'booking_list');
        bookings.value = List.from(
          (bookingData as List).map((e) => BookingModel.fromJson(e)).toList(),
        );

        if (data == null || data is! List) {
          throw Exception();
        }
      }

      final DashboardModel dashboard = DashboardModel.fromJson(data[0]);
      dashboardModel.value = dashboard;
    } catch (e) {
      if (isClosed) {
        return;
      }
      ExceptionHandler.handleException(e);
    } finally {
      isLoading.value = false;
    }
  }

  void clearDateFilter() {
    dateCtl.text = '';
  }

  Future<void> fetchSliders() async {
    if (isSliderLoading.value) return;
    isSliderLoading.value = true;
    try {
      final res = await Get.find<ApiService>()
          .get(EndPoints.sliders, isShowLoading: false)
          .timeout(const Duration(seconds: 12));
      debugPrint('fetchSliders endpoint: ${EndPoints.sliders}');
      debugPrint('fetchSliders response: ${res.data}');

      if (res.data is! Map) return;
      final map = Map<String, dynamic>.from(res.data as Map);
      final rawData = map['data'];
      if (rawData is! List) return;

      final urls = rawData
          .whereType<dynamic>()
          .map((e) {
            if (e is Map<String, dynamic>) {
              return (e['banner'] ?? '').toString().trim();
            }
            if (e is Map) {
              final map = Map<String, dynamic>.from(e);
              return (map['banner'] ?? '').toString().trim();
            }
            return '';
          })
          .where((url) => url.isNotEmpty)
          .toList(growable: false);

      debugPrint('fetchSliders urls: $urls');
      sliderImages.assignAll(urls);
      if (urls.isNotEmpty) {
        _sliderRetryCount = 0;
      } else {
        _scheduleSliderRetry();
      }
    } catch (e, s) {
      debugPrint('fetchSliders error: $e');
      debugPrintStack(stackTrace: s);
      _scheduleSliderRetry();
    } finally {
      isSliderLoading.value = false;
    }
  }

  void _scheduleSliderRetry() {
    if (_sliderRetryCount >= _maxSliderRetries) return;
    _sliderRetryCount++;
    Future.delayed(const Duration(milliseconds: 100), () {
      if (isClosed) return;
      fetchSliders();
    });
  }
}
