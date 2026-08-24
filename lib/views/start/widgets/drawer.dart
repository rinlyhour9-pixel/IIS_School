import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/flavor/app_config.dart';
import 'package:schoolapp/models/child_profile/child_profile.dart';
import 'package:schoolapp/models/parent/parent.dart';
import 'package:schoolapp/routes.dart';
import 'package:schoolapp/views/homework/controller.dart';
import 'package:schoolapp/views/event_gallery/controller.dart';
import 'package:schoolapp/views/payment_collection/controller.dart';
import 'package:schoolapp/views/payment_history/controller.dart';
import 'package:schoolapp/views/schedule/controller.dart';
import 'package:schoolapp/views/start/widgets/child_card.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  bool _isLoadingChildren = false;
  bool _notificationsEnabled = true;
  List<ChildProfile> _children = const <ChildProfile>[];
  String _selectedChildId = '';

  bool get _isParentRole => UserRepository.shared.isParent;
  SelectedStudentService get _selectedStudentService =>
      Get.find<SelectedStudentService>();

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
    _loadSelectedChild();
    if (_isParentRole) {
      if (_selectedStudentService.children.isNotEmpty) {
        _children = _selectedStudentService.children.toList(growable: false);
        _selectedChildId = _selectedStudentService.current?.id ?? '';
      } else {
        _fetchParentChildren();
      }
    }
  }

  Future<void> _loadNotificationPreference() async {
    final enabled = await HomeworkNotificationService.instance.isEnabled();
    if (!mounted) {
      return;
    }
    setState(() {
      _notificationsEnabled = enabled;
    });
  }

  Future<void> _toggleNotifications(bool enabled) async {
    setState(() {
      _notificationsEnabled = enabled;
    });
    await HomeworkNotificationService.instance.setEnabled(enabled);
  }

  Future<void> _loadSelectedChild() async {
    await _selectedStudentService.refreshFromStorage();
    final value = _selectedStudentService.current?.id ?? '';
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedChildId = value;
    });
  }

  Future<void> _fetchParentChildren() async {
    setState(() {
      _isLoadingChildren = true;
    });

    try {
      final res = await Get.find<ApiService>().get(
        EndPoints.parentStudentInfo,
        isShowLoading: false,
      );

      final list = _extractChildren(res.data);

      if (!mounted) {
        return;
      }

      var selected = _selectedChildId;
      if (list.isNotEmpty) {
        var exists = false;
        for (final child in list) {
          if (child.id == selected) {
            exists = true;
            break;
          }
        }
        if (selected.isEmpty || !exists) {
          selected = list.first.id;
        }
      }

      await _selectedStudentService.setChildren(list, preferredId: selected);
      if (!mounted) {
        return;
      }
      setState(() {
        _children = _selectedStudentService.children.toList(growable: false);
        _selectedChildId = _selectedStudentService.current?.id ?? '';
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _children = const <ChildProfile>[];
      });
    } finally {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoadingChildren = false;
      });
    }
  }

  List<ChildProfile> _extractChildren(dynamic raw) {
    if (raw is Map) {
      final model = ParentWithChild.fromJson(Map<String, dynamic>.from(raw));
      final students = model.data?.student ?? const <Student>[];
      if (students.isNotEmpty) {
        return students
            .map(
              (student) => ChildProfile(
                id:
                    (student.id?.toString() ?? student.admissionNo ?? '')
                        .trim(),
                name:
                    (student.nameKh ??
                            student.name ??
                            student.admissionNo ??
                            '')
                        .trim(),
                avatar: (student.profile ?? '').trim(),
                classId: (student.classId?.toString() ?? '').trim(),
                className: (student.className ?? '').trim(),
              ),
            )
            .where((child) => child.id.isNotEmpty || child.name.isNotEmpty)
            .toList();
      }
    }

    if (raw is! Map) {
      return const <ChildProfile>[];
    }

    final candidates = <dynamic>[
      raw['data'],
      raw['children'],
      raw['data'] is Map ? raw['data']['children'] : null,
      raw['data'] is Map ? raw['data']['data'] : null,
    ];

    for (final candidate in candidates) {
      if (candidate is List) {
        return candidate
            .whereType<dynamic>()
            .map(ChildProfile.fromDynamic)
            .where((child) => child.id.isNotEmpty || child.name.isNotEmpty)
            .toList();
      }
    }

    return const <ChildProfile>[];
  }

  void _selectChild(ChildProfile child) async {
    setState(() {
      _selectedChildId = child.id;
    });
    Get.back();
    try {
      await _selectedStudentService.selectChild(child);
      unawaited(
        ClassTopicSubscriptionService.instance.syncSelectedClassTopic(),
      );
      unawaited(_refreshSelectedChildData());
      Get.snackbar(
        LocaleKeys.student.tr,
        child.name.isEmpty ? LocaleKeys.student.tr : child.name,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        borderRadius: 14,
        backgroundColor: const Color(0xFFF8F8F8),
        colorText: const Color(0xFF333333),
        duration: const Duration(milliseconds: 500),
        boxShadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        icon: Container(
          width: 30,
          height: 30,
          margin: const EdgeInsets.only(left: 8),
          decoration: const BoxDecoration(
            color: Color(0xFFF1F1F1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: Color(0xFF666666),
            size: 18,
          ),
        ),
      );
    } finally {}
  }

  Future<void> _refreshSelectedChildData() async {
    final tasks = <Future<void>>[];
    if (Get.isRegistered<ScheduleController>()) {
      tasks.add(Get.find<ScheduleController>().fetchStudentTimeSheet());
    }
    if (Get.isRegistered<HomeworkController>()) {
      tasks.add(
        Get.find<HomeworkController>().fetchStudentHomeworks(
          resetBeforeLoad: true,
        ),
      );
    }
    if (Get.isRegistered<ActivityController>()) {
      tasks.add(Get.find<ActivityController>().fetchClassActivities());
    }
    if (Get.isRegistered<PaymentHistoryController>()) {
      tasks.add(
        Get.find<PaymentHistoryController>().fetchPaymentHistory(
          resetBeforeLoad: true,
        ),
      );
    }
    if (Get.isRegistered<PaymentCollectionController>()) {
      tasks.add(Get.find<PaymentCollectionController>().fetchTracking());
    }

    if (tasks.isEmpty) {
      return;
    }

    await Future.wait(tasks);
  }

  void languageHandleTap() {
    Get.back();
    Get.toNamed(Routes.language);
  }

  void termConditionHandleTap() {
    Get.back();
    Get.toNamed(Routes.termCondition);
  }

  void contactUsHandleTap() {
    Get.back();
    Get.toNamed(Routes.contactUs);
  }

  void logOutHandleTap() {
    Get.back();
    DialogManager.showCustom(
      PrimaryDialog(
        title: LocaleKeys.logout.tr,
        subTitle: LocaleKeys.areYouSureYourWantToLogout.tr,
        btnText: LocaleKeys.yes.tr.toUpperCase(),
        onPressed: () async {
          Get.back();
          await UserRepository.shared.logout();
        },
      ),
    );
  }

<<<<<<< HEAD
  // void deleteAccountHandleTap() {
  //   Get.back();
  //   DialogManager.showCustom(
  //     PrimaryDialog(
  //       title: LocaleKeys.deleteAccount.tr,
  //       subTitle: LocaleKeys.deleteAccountMessage.tr,
  //       btnText: LocaleKeys.yes.tr.toUpperCase(),
  //       onPressed: () async {
  //         Get.back();
  //         try {
  //           await UserRepository.shared.deleteAccount();
  //         } catch (e) {
  //           ExceptionHandler.handleException(e);
  //         }
  //       },
  //     ),
  //   );
  // }
=======
  void deleteAccountHandleTap() {
    Get.back();
    DialogManager.showCustom(
      PrimaryDialog(
        title: LocaleKeys.deleteAccount.tr,
        subTitle: LocaleKeys.deleteAccountMessage.tr,
        btnText: LocaleKeys.yes.tr.toUpperCase(),
        onPressed: () async {
          Get.back();
          try {
            await UserRepository.shared.deleteAccount();
          } catch (e) {
            ExceptionHandler.handleException(e);
          }
        },
      ),
    );
  }
>>>>>>> 74bda71b0166ce92efa14e7395518c52665ecb87

  @override
  Widget build(BuildContext context) {
    if (_isParentRole) {
      return _buildParentDrawer(context);
    }
    return _buildTeacherDrawer();
  }

  Widget _buildTeacherDrawer() {
    String profileName = '';
    try {
      profileName = UserRepository.shared.profile.name.trim();
    } catch (_) {
      profileName = '';
    }

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Column(
          children: [
            ClipOval(
              child: Image.asset(
                AssetPath.appIcon.path,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 7),
            Image.asset(
              'assets/images/text_logo.png',
              height: 65,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 12),
            _parentMenuItem(
              icon: Icons.settings,
              label: LocaleKeys.termAndCondition.tr,
              onTap: termConditionHandleTap,
            ),
            _divider(),
            _parentMenuItem(
              icon: Icons.language,
              label: LocaleKeys.language.tr,
              trailingText: AppConfig.shared.language,
              onTap: languageHandleTap,
            ),
            _divider(),
            _parentMenuItem(
              icon: Icons.notifications_active_outlined,
              label: LocaleKeys.notification.tr,
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: _toggleNotifications,
                activeColor: AppColor.primary,
              ),
            ),
            _divider(),
            _parentMenuItem(
              icon: Icons.contact_support,
              label: LocaleKeys.contactUs.tr,
              onTap: contactUsHandleTap,
            ),
            _divider(),
            _parentMenuItem(
              icon: Icons.logout,
              label: LocaleKeys.logout.tr,
              onTap: logOutHandleTap,
            ),
<<<<<<< HEAD
        
=======
            _divider(),
            _parentMenuItem(
              icon: Icons.delete_forever,
              label: LocaleKeys.deleteAccount.tr,
              onTap: deleteAccountHandleTap,
            ),
>>>>>>> 74bda71b0166ce92efa14e7395518c52665ecb87
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        height: 50,
                        width: 130,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'App Version: V${AppConfig.shared.version}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParentDrawer(BuildContext context) {
    String profileName = '';
    try {
      profileName = UserRepository.shared.profile.name.trim();
    } catch (_) {
      profileName = '';
    }

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(14, 8, 14, 6),
              child: Row(
                children: [
                 
                ],
              ),
            ),
            ClipOval(
              child: Image.asset(
                AssetPath.appIcon.path,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'IIS School',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 12),
            if (_isLoadingChildren)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            if (!_isLoadingChildren && _children.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children:
                      _children.map((child) {
                        final active = child.id == _selectedChildId;
                        return ChildCard(
                          child: child,
                          active: active,
                          avatar: _childAvatar(child.avatar),
                          onTap: () => _selectChild(child),
                        );
                      }).toList(),
                ),
              ),
            if (!_isLoadingChildren &&
                _children.isEmpty &&
                profileName.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ChildCard(
                  child: ChildProfile(
                    id: 'self',
                    name: profileName,
                    avatar: '',
                  ),
                  active: true,
                  avatar: _childAvatar(''),
                  onTap: null,
                ),
              ),
            const SizedBox(height: 8),
            _parentMenuItem(
              icon: Icons.settings,
              label: LocaleKeys.termAndCondition.tr,
              onTap: termConditionHandleTap,
            ),
            _divider(),
            _parentMenuItem(
              icon: Icons.language,
              label: LocaleKeys.language.tr,
              trailingText: AppConfig.shared.language,
              onTap: languageHandleTap,
            ),
            _divider(),
            _parentMenuItem(
              icon: Icons.notifications_active_outlined,
              label: LocaleKeys.notification.tr,
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: _toggleNotifications,
                activeColor: AppColor.primary,
              ),
            ),
            _divider(),
            _parentMenuItem(
              icon: Icons.contact_support,
              label: LocaleKeys.contactUs.tr,
              onTap: contactUsHandleTap,
            ),
            _divider(),
            _parentMenuItem(
              icon: Icons.logout,
              label: LocaleKeys.logout.tr,
              onTap: logOutHandleTap,
            ),
<<<<<<< HEAD
            // _divider(),
            // _parentMenuItem(
            //   icon: Icons.delete_forever,
            //   label: LocaleKeys.deleteAccount.tr,
            //   onTap: deleteAccountHandleTap,
            // ),
=======
            _divider(),
            _parentMenuItem(
              icon: Icons.delete_forever,
              label: LocaleKeys.deleteAccount.tr,
              onTap: deleteAccountHandleTap,
            ),
>>>>>>> 74bda71b0166ce92efa14e7395518c52665ecb87
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        height: 50,
                        width: 130,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'App Version: V${AppConfig.shared.version}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 18),
      child: Divider(height: 1),
    );
  }

  Widget _parentMenuItem({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    String? trailingText,
    Widget? trailing,
  }) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      onTap: onTap,
      leading: Icon(icon, color: AppColor.primary),
      title: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing:
          trailing ??
          (trailingText == null
              ? null
              : Text(
                trailingText,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              )),
    );
  }

  Widget _childAvatar(String avatar) {
    final candidates = _resolveProfileUrlCandidates(avatar);
    if (candidates.isNotEmpty) {
      final first = candidates.first;
      if (_isNetworkUrl(first)) {
        return _networkAvatar(candidates, 0);
      }
      return CircleAvatar(
        radius: 18,
        backgroundImage: AssetImage(first),
        backgroundColor: const Color(0xFFE8EEF2),
      );
    }
    return const CircleAvatar(
      radius: 18,
      backgroundColor: Color(0xFFE8EEF2),
      child: Icon(Icons.person, color: Color(0xFF6C7A86)),
    );
  }

  Widget _networkAvatar(List<String> urls, int index) {
    if (index >= urls.length) {
      return const CircleAvatar(
        radius: 18,
        backgroundColor: Color(0xFFE8EEF2),
        child: Icon(Icons.person, color: Color(0xFF6C7A86)),
      );
    }

    return CircleAvatar(
      radius: 18,
      backgroundColor: const Color(0xFFE8EEF2),
      child: ClipOval(child: _networkAvatarImage(urls, index)),
    );
  }

  Widget _networkAvatarImage(List<String> urls, int index) {
    if (index >= urls.length) {
      return const Icon(Icons.person, color: Color(0xFF6C7A86));
    }
    return CachedNetworkImage(
      imageUrl: urls[index],
      fit: BoxFit.cover,
      width: 36,
      height: 36,
      memCacheWidth: 72,
      memCacheHeight: 72,
      maxWidthDiskCache: 72,
      maxHeightDiskCache: 72,
      httpHeaders: _imageHeaders() ?? const <String, String>{},
      useOldImageOnUrlChange: true,
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      placeholderFadeInDuration: Duration.zero,
      placeholder:
          (_, __) => Container(
            width: 36,
            height: 36,
            color: const Color(0xFFE8EEF2),
            alignment: Alignment.center,
            child: const Icon(Icons.person, color: Color(0xFF6C7A86)),
          ),
      errorWidget: (_, __, ___) => _networkAvatarImage(urls, index + 1),
    );
  }

  Map<String, String>? _imageHeaders() {
    final token = AppConfig.shared.authorizationToken.trim();
    if (token.isEmpty) {
      return null;
    }
    return <String, String>{'Authorization': token, 'Accept': 'image/*'};
  }

  Widget _profileCircle({double size = 40}) {
    String rawProfile = '';
    try {
      rawProfile = UserRepository.shared.profile.profile;
    } catch (_) {
      rawProfile = '';
    }
    final profile = _resolveProfileUrl(rawProfile);
    final border = Border.all(color: AppColor.primaryColor, width: 2);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, border: border),
      child: ClipOval(
        child:
            profile.isNotEmpty
                ? Image(
                  image:
                      _isNetworkUrl(profile)
                          ? NetworkImage(profile) as ImageProvider
                          : AssetImage(profile),
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) =>
                          const Icon(Icons.person, color: Colors.grey),
                )
                : const Icon(Icons.person, color: Colors.grey),
      ),
    );
  }

  String _resolveProfileUrl(String rawValue) {
    final value = rawValue.trim().replaceAll('\\', '/');
    final lower = value.toLowerCase();
    if (value.isEmpty ||
        lower == 'n/a' ||
        lower == 'null' ||
        lower == 'undefined' ||
        lower == 'false' ||
        value == '{}') {
      return '';
    }
    final unquoted = value.replaceAll('"', '').replaceAll("'", '');
    if (_isNetworkUrl(unquoted) || unquoted.startsWith('assets/')) {
      return unquoted;
    }
    if (unquoted.startsWith('//')) {
      return 'https:$unquoted';
    }

    if (unquoted.startsWith('/')) {
      final base = AppConfig.shared.baseUrl.trim();
      if (base.isEmpty) {
        return '';
      }

      final baseUri = Uri.parse(base.endsWith('/') ? base : '$base/');
      return baseUri.resolve(unquoted.substring(1)).toString();
    }
    if (unquoted.startsWith('storage/') ||
        unquoted.startsWith('uploads/') ||
        unquoted.startsWith('images/')) {
      final base = AppConfig.shared.baseUrl.trim();
      if (base.isEmpty) {
        return '';
      }
      final baseUri = Uri.parse(base.endsWith('/') ? base : '$base/');
      return baseUri.resolve(unquoted).toString();
    }
    if (RegExp(
      r'^[A-Za-z0-9_.-]+\.(png|jpg|jpeg|webp|gif)$',
    ).hasMatch(unquoted)) {
      final base = AppConfig.shared.baseUrl.trim();
      if (base.isEmpty) {
        return '';
      }
      final baseUri = Uri.parse(base.endsWith('/') ? base : '$base/');
      return baseUri.resolve('uploads/$unquoted').toString();
    }
    if (unquoted.startsWith('data:image/')) {
      return value;
    }
    final base = AppConfig.shared.baseUrl.trim();
    if (base.isEmpty) {
      return '';
    }
    final baseUri = Uri.parse(base.endsWith('/') ? base : '$base/');
    return baseUri.resolve(unquoted).toString();
  }

  List<String> _resolveProfileUrlCandidates(String rawValue) {
    final value = rawValue.trim().replaceAll('\\', '/');
    final lower = value.toLowerCase();
    if (value.isEmpty ||
        lower == 'n/a' ||
        lower == 'null' ||
        lower == 'undefined' ||
        lower == 'false' ||
        value == '{}') {
      return const <String>[];
    }

    final unquoted = value.replaceAll('"', '').replaceAll("'", '');
    if (unquoted.startsWith('assets/')) {
      return <String>[unquoted];
    }
    if (_isNetworkUrl(unquoted)) {
      return _networkUrlVariants(unquoted);
    }
    if (unquoted.startsWith('//')) {
      return <String>['https:$unquoted'];
    }

    final base = AppConfig.shared.baseUrl.trim();
    if (base.isEmpty) {
      return const <String>[];
    }
    final baseUri = Uri.parse(base.endsWith('/') ? base : '$base/');
    final path = unquoted.startsWith('/') ? unquoted.substring(1) : unquoted;

    final rawCandidates = <String>[
      path,
      if (path.startsWith('storage/')) 'public/$path',
      if (path.startsWith('uploads/')) 'public/$path',
      if (path.startsWith('images/')) 'public/$path',
      if (!path.startsWith('storage/')) 'storage/$path',
      if (!path.startsWith('uploads/')) 'uploads/$path',
      if (!path.startsWith('public/')) 'public/$path',
    ];

    final seen = <String>{};
    final resolved = <String>[];
    for (final candidate in rawCandidates) {
      final normalized = candidate.replaceAll('//', '/');
      final url = baseUri.resolve(normalized).toString();
      if (seen.add(url)) {
        resolved.add(url);
      }
    }
    return resolved;
  }

  List<String> _networkUrlVariants(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return <String>[url];
    }

    final normalizedPath = uri.path.replaceAll('\\', '/');
    final fixedUploads = _dedupeAdjacentPath(
      normalizedPath.replaceFirst('/uploads/uploads/', '/uploads/'),
    );
    final fixedPublic = _dedupeAdjacentPath(
      normalizedPath.replaceFirst('/public/public/', '/public/'),
    );
    final fixedStorage = _dedupeAdjacentPath(
      normalizedPath.replaceFirst('/storage/storage/', '/storage/'),
    );
    final deduped = _dedupeAdjacentPath(normalizedPath);
    final variants = <String>[
      uri.replace(path: fixedUploads).toString(),
      uri.replace(path: fixedPublic).toString(),
      uri.replace(path: fixedStorage).toString(),
      uri.replace(path: deduped).toString(),
      url,
    ];

    final seen = <String>{};
    return variants.where((v) => seen.add(v)).toList();
  }

  String _dedupeAdjacentPath(String path) {
    final parts = path.split('/').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) {
      return path;
    }
    final compact = <String>[];
    for (final part in parts) {
      if (compact.isEmpty || compact.last.toLowerCase() != part.toLowerCase()) {
        compact.add(part);
      }
    }
    return '/${compact.join('/')}';
  }

  bool _isNetworkUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }
}
