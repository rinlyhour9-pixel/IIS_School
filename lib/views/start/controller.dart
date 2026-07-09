import 'dart:async';

import 'package:schoolapp/views/scan/scan_log.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/flavor/flavor.dart';
import 'package:schoolapp/models/models.dart';
import 'package:schoolapp/models/parent/parent.dart' as parent_model;
import 'package:schoolapp/views/views.dart';

class StartController extends GetxController {
  final RxInt selectedIndex = 0.obs;
  final RxString profileUrl = ''.obs;
  final RxString userName = ''.obs;
  final RxBool isParentUser = false.obs;
  late Rx<Widget> selectedScreen = _buildScreen(0).obs;
  SelectedStudentService get _selectedStudentService =>
      Get.find<SelectedStudentService>();
  Worker? _selectedStudentWorker;

  @override
  void onInit() {
    UserRepository.shared;
    isParentUser.value = UserRepository.shared.isParent;
    _selectedStudentWorker = ever<ChildProfile?>(
      _selectedStudentService.selected,
      (child) {
        if (!isParentUser.value) {
          return;
        }
        profileUrl.value = _normalizeProfileUrl(child?.avatar ?? '');
      },
    );
    _syncRoleFromStorage();
    _setLocalProfileFallback();
    _loadLocalProfileFromStorage();
    fetchUserProfileFromApi();

    super.onInit();
  }

  @override
  void onClose() {
    _selectedStudentWorker?.dispose();
    super.onClose();
  }

  void handleClickBack() {
    if (selectedIndex.value != 0) {
      changeMenu(0);
    }
  }

  //add new
  var currentIndex = 0.obs;

  void changeIndex(int index) {
    currentIndex.value = index;
  }

  void changeMenuIndex(int index) {
    if (isParentUser.value) {
      if (index == 2) {
        selectedIndex.value = index;
        selectedScreen.value = _buildScreen(3);
        _refreshPaymentHistoryIfNeeded(3);
        return;
      }
      if (index == 3) {
        selectedIndex.value = index;
        selectedScreen.value = _buildScreen(4);
        return;
      }
    }
    if (index == 3) {
      selectedIndex.value = index;
      selectedScreen.value = _buildScreen(4);
      return;
    }
    selectedIndex.value = index;
    selectedScreen.value = _buildScreen(index);
    _refreshDashboardSliderIfNeeded(index);
  }

  void changeMenu(
    int index, {
    bool isFromGrid = false,
    String dateFilter = '',
  }) {
    if (isParentUser.value) {
      if (index == 2) {
        selectedIndex.value = 0;
        selectedScreen.value = _buildScreen(0);
        return;
      }
      if (index == 3) {
        selectedIndex.value = 2;
        selectedScreen.value = _buildScreen(3);
        _refreshPaymentHistoryIfNeeded(3);
        return;
      }
      if (index == 4) {
        selectedIndex.value = 3;
        selectedScreen.value = _buildScreen(4);
        return;
      }
    }
    if (!isParentUser.value && index == 4) {
      selectedIndex.value = 3;
      selectedScreen.value = _buildScreen(4);
      return;
    }
    selectedIndex.value = index;
    selectedScreen.value = _buildScreen(selectedIndex.value);
    _refreshDashboardSliderIfNeeded(selectedIndex.value);
    _refreshPaymentHistoryIfNeeded(selectedIndex.value);
  }

  void _refreshDashboardSliderIfNeeded(int index) {
    if (index != 0) return;
    if (!Get.isRegistered<DashboardController>()) return;
    final controller = Get.find<DashboardController>();
    if (controller.sliderImages.isNotEmpty ||
        controller.isSliderLoading.value) {
      return;
    }
    controller.fetchSliders();
  }

  void _refreshPaymentHistoryIfNeeded(int index) {
    if (index != 3) return;
    if (!Get.isRegistered<PaymentHistoryController>()) return;
    Get.find<PaymentHistoryController>().fetchPaymentHistory(
      resetBeforeLoad: true,
    );
  }

  void _normalizeSelectionForRole() {
    if (!isParentUser.value) {
      if (selectedIndex.value >= 4) {
        selectedIndex.value = 3;
        selectedScreen.value = _buildScreen(4);
      }
      return;
    }
    if (selectedIndex.value == 2) {
      selectedIndex.value = 0;
      selectedScreen.value = _buildScreen(0);
      return;
    }
    if (selectedIndex.value >= 4) {
      selectedIndex.value = 3;
      selectedScreen.value = _buildScreen(4);
    }
  }

  Future<void> _syncRoleFromStorage() async {
    final savedRole =
        (await SharedPreferencesManager.get('user_role') ?? '')
            .toString()
            .trim()
            .toLowerCase();
    if (savedRole.isEmpty) {
      return;
    }
    UserRepository.shared.setUserType(savedRole);
    isParentUser.value = UserRepository.shared.isParent;
    _normalizeSelectionForRole();
    await _refreshParentAppBarChild();
  }

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return const DashboardView();
      case 1:
        return const NotificationView();
      case 2:
        return CardScanView();
      case 3:
        return const PaymentHistoryView();
      case 4:
        return const ContactUsView();
      default:
        return const DashboardView();
    }
  }

  void _setLocalProfileFallback() {
    try {
      profileUrl.value = _normalizeProfileUrl(
        UserRepository.shared.profile.profile,
      );
      userName.value = UserRepository.shared.profile.name;
    } catch (_) {
      // Keep values empty until storage/API fallback fills them.
    }
  }

  Future<void> _loadLocalProfileFromStorage() async {
    final storedName =
        (await SharedPreferencesManager.get('name') ?? '').toString().trim();
    final storedProfile =
        (await SharedPreferencesManager.get('profile') ?? '').toString().trim();

    if (userName.value.trim().isEmpty && storedName.isNotEmpty) {
      userName.value = storedName;
    }
    if (profileUrl.value.trim().isEmpty && storedProfile.isNotEmpty) {
      profileUrl.value = _normalizeProfileUrl(storedProfile);
    }
  }

  Future<void> fetchUserProfileFromApi() async {
    try {
      final res = await Get.find<ApiService>().get(
        isParentUser.value ? EndPoints.parentProfile : EndPoints.profile,
        isShowLoading: false,
      );
      final data = getPropertyFromJson(res.data, 'data');
      if (data is! Map<String, dynamic>) {
        return;
      }

      final profile = ProfileModel.fromJson(data);

      UserRepository.shared.setProfile(profile);
      isParentUser.value = UserRepository.shared.isParent;

      await SharedPreferencesManager.setValue(
        'user_role',
        profile.type.toLowerCase(),
      );
      _normalizeSelectionForRole();

      final rawProfileUrl = _firstNonEmpty([
        data['profile_path'],
        data['profile'],
        data['avatar'],
        data['photo'],
        data['image'],
        data['profile_url'],
        (data['user'] is Map<String, dynamic>)
            ? (data['user'] as Map<String, dynamic>)['profile_path']
            : null,
        (data['user'] is Map<String, dynamic>)
            ? (data['user'] as Map<String, dynamic>)['profile']
            : null,
      ]);
      final resolvedProfile = _normalizeProfileUrl(
        rawProfileUrl.isNotEmpty ? rawProfileUrl : profile.profile,
      );
      final resolvedName = _firstNonEmpty([data['name'], profile.name]);

      if (resolvedProfile.isNotEmpty) {
        profileUrl.value = resolvedProfile;
      }
      if (resolvedName.isNotEmpty) {
        userName.value = resolvedName;
      }
      await _refreshParentAppBarChild();

      if (userName.value.trim().isNotEmpty) {
        await SharedPreferencesManager.setValue('name', userName.value);
      }
      if (profileUrl.value.trim().isNotEmpty) {
        await SharedPreferencesManager.setValue('profile', profileUrl.value);
      }
    } catch (_) {}
  }

  Future<void> refreshParentAppBarChild() async {
    await _refreshParentAppBarChild();
  }

  Future<void> _refreshParentAppBarChild() async {
    if (!isParentUser.value) {
      return;
    }

    final selectedChild = _selectedStudentService.current;
    if (selectedChild != null) {
      profileUrl.value = _normalizeProfileUrl(selectedChild.avatar);
      unawaited(
        ClassTopicSubscriptionService.instance.syncSelectedClassTopic(),
      );
      return;
    }

    try {
      final res = await Get.find<ApiService>().get(
        EndPoints.parentStudentInfo,
        isShowLoading: false,
      );
      if (res.data is! Map) {
        return;
      }

      final model = parent_model.ParentWithChild.fromJson(
        Map<String, dynamic>.from(res.data),
      );
      final students = model.data?.student ?? const <parent_model.Student>[];
      if (students.isEmpty) {
        return;
      }

      final children = students
          .map(
            (student) => ChildProfile(
              id: (student.id?.toString() ?? student.admissionNo ?? '').trim(),
              name: _firstNonEmpty([
                student.nameKh,
                student.name,
                student.admissionNo,
              ]),
              avatar: (student.profile ?? '').trim(),
              classId: (student.classId?.toString() ?? '').trim(),
              className: (student.className ?? '').trim(),
            ),
          )
          .where((child) => child.id.isNotEmpty || child.name.isNotEmpty)
          .toList(growable: false);

      await _selectedStudentService.setChildren(children);
      profileUrl.value = _normalizeProfileUrl(
        _selectedStudentService.current?.avatar ?? '',
      );
      await ClassTopicSubscriptionService.instance.syncSelectedClassTopic();
    } catch (_) {}
  }

  String get appBarProfileUrl {
    final current = profileUrl.value.trim();
    if (current.isNotEmpty) {
      return current;
    }
    if (isParentUser.value) {
      return '';
    }
    try {
      return _normalizeProfileUrl(UserRepository.shared.profile.profile);
    } catch (_) {
      return '';
    }
  }

  String _firstNonEmpty(List<dynamic> values) {
    for (final value in values) {
      final text = (value ?? '').toString().trim();
      final lower = text.toLowerCase();
      if (text.isNotEmpty &&
          lower != 'n/a' &&
          lower != 'null' &&
          lower != 'undefined' &&
          lower != 'false') {
        return text;
      }
    }
    return '';
  }

  String _normalizeProfileUrl(String? rawUrl) {
    final url = (rawUrl ?? '').trim().replaceAll('\\', '/');
    if (url.isEmpty || url.toLowerCase() == 'n/a') {
      return '';
    }
    if (url.startsWith('//')) {
      return 'https:$url';
    }
    if (url.startsWith('http://') || url.startsWith('https://')) {
      final uri = Uri.tryParse(url);
      if (uri == null) {
        return url;
      }
      final normalizedPath = uri.path
          .replaceAll('/uploads/uploads/', '/uploads/')
          .replaceAll('/public/public/', '/public/')
          .replaceAll('/storage/storage/', '/storage/');
      return uri.replace(path: normalizedPath).toString();
    }

    final base = AppConfig.shared.baseUrl.trim();
    if (base.isEmpty) {
      return '';
    }

    final baseUri = Uri.parse(base.endsWith('/') ? base : '$base/');
    final normalized = url
        .replaceAll('/uploads/uploads/', '/uploads/')
        .replaceAll('/public/public/', '/public/')
        .replaceAll('/storage/storage/', '/storage/');
    return baseUri
        .resolve(
          normalized.startsWith('/') ? normalized.substring(1) : normalized,
        )
        .toString();
  }

  List<Widget> getItems() {
    final List<Widget> items = [
      BottomBarWidget(
        label: LocaleKeys.dashboard.tr,
        isSelected: selectedIndex.value == 0,
        icon: Icons.dashboard,
        onTap: () => changeMenu(0),
      ),
      BottomBarWidget(
        label: LocaleKeys.notification.tr,
        isSelected: selectedIndex.value == 1,
        icon: Icons.payment,
        onTap: () => changeMenu(1),
      ),
      if (UserRepository.shared.isParent)
        const Spacer()
      else
        BottomBarWidget(
          label: LocaleKeys.scanner.tr,
          isSelected: selectedIndex.value == 2,
          icon: Icons.timelapse_outlined,
          onTap: () => changeMenu(2),
        ),
      if (UserRepository.shared.isParent)
        BottomBarWidget(
          label: LocaleKeys.payment.tr,
          isSelected: selectedIndex.value == 3,
          icon: Icons.send,
          onTap: () => changeMenu(3),
        ),
      BottomBarWidget(
        label: LocaleKeys.contactUs.tr,
        isSelected:
            UserRepository.shared.isParent
                ? selectedIndex.value == 4
                : selectedIndex.value == 3,
        icon: Icons.more,
        onTap: () => changeMenu(4),
      ),
    ];
    return items;
  }

  String getTitle() {
    switch (selectedIndex.value) {
      case 0:
        return LocaleKeys.dashboard.tr;
      case 1:
        return LocaleKeys.notification.tr;
      case 2:
        return LocaleKeys.scanner.tr;
      case 3:
        return isParentUser.value
            ? LocaleKeys.payment.tr
            : LocaleKeys.contactUs.tr;
      case 4:
        return LocaleKeys.contactUs.tr;
      default:
        return "App";
    }
  }
}
