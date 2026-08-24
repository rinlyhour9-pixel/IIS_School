import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/flavor/app_config.dart';
import 'package:schoolapp/models/models.dart';
import 'package:schoolapp/routes.dart';

class UserRepository {
  UserRepository._() {
    _context = Get.context;
    _checkDeviceType();
  }

  static final UserRepository _instance = UserRepository._();
  static UserRepository get shared => _instance;

  final String _telegram = 'toroexpress';
  String get telegram => _telegram.replaceAll('@', '');

  final String _phoneNumber = '098 970 960';
  String get phoneNumber => _phoneNumber.replaceAll('@', '');

  // Nullable (not `late`) specifically so logout() can clear it. Left as
  // `late` before, this held the PREVIOUS account's profile in memory
  // across an entire logout→login cycle (nothing ever reset it) — if the
  // next account's own `/your-profile` call then failed or threw for any
  // reason, `_safeCachedProfile()`-style fallbacks silently returned the
  // stale profile object instead of an error, showing one account's name/
  // photo/phone under another account's session with no visible cause.
  ProfileModel? _profile;
  ProfileModel get profile {
    final profile = _profile;
    if (profile == null) {
      throw StateError('No profile has been set for the current session.');
    }
    return profile;
  }

  /// Permanently deletes the signed in account, then clears the session.
  Future<void> deleteAccount() async {
    await Get.find<ApiService>().get(
      EndPoints.deleteAccount,
      isShowLoading: true,
    );
    await logout();
  }

  Future<void> logout() async {
    if (Get.isRegistered<SelectedStudentService>()) {
      await Get.find<SelectedStudentService>().clear();
    }

    // Clear every session-scoped key, not just the token — a leftover
    // student_info_id/last_leave_student_id from a parent session used to
    // survive logout and (via _hasParentStorage below) flip the NEXT
    // account's role back to 'parent' even after a valid teacher login.
    await Future.wait([
      SharedPreferencesManager.remove(Credential.token.name),
      SharedPreferencesManager.remove('username'),
      SharedPreferencesManager.remove('password'),
      SharedPreferencesManager.remove('name'),
      SharedPreferencesManager.remove('profile'),
      SharedPreferencesManager.remove('user_id'),
      SharedPreferencesManager.remove('staff_code'),
      SharedPreferencesManager.remove('user_role'),
      SharedPreferencesManager.remove('scanner_owner_id'),
      SharedPreferencesManager.remove('branch_id'),
      SharedPreferencesManager.remove('student_info_id'),
      SharedPreferencesManager.remove('student_info_mode'),
      SharedPreferencesManager.remove('student_info_name'),
      SharedPreferencesManager.remove('student_info_profile'),
      SharedPreferencesManager.remove('student_info_profession'),
      SharedPreferencesManager.remove('last_leave_student_id'),
    ]);

    AppConfig.shared.token = '';
    _isParent = false;
    _profile = null;

    Get.offAllNamed(Routes.login);
  }

  void setProfile(ProfileModel profile) {
    final userType = UserType.fromKey(profile.type);
    if (userType != null) {
      setUserType(profile.type);
    }
    _profile = profile;
  }

  bool _isParent = false;
  bool get isParent => _isParent;
  void setUserType(String value) {
    final userType = UserType.fromKey(value);
    _isParent = userType == UserType.parent;
  }

  Future<String> restoreUserTypeFromStorage() async {
    final savedRole =
        (await SharedPreferencesManager.get('user_role') ?? '')
            .toString()
            .trim()
            .toLowerCase();
    var resolvedRole = UserType.fromKey(savedRole)?.key ?? '';

    // Only guess the role from leftover parent-scoped keys when we don't
    // already have an explicit, valid role in storage. Previously this ran
    // whenever resolvedRole wasn't already 'parent' — so a correctly
    // stored 'teacher' role from a fresh login got silently overwritten
    // back to 'parent' by a PREVIOUS account's still-cached
    // student_info_id/last_leave_student_id, and that wrong value was then
    // re-persisted to storage.
    if (resolvedRole.isEmpty && await _hasParentStorage()) {
      resolvedRole = UserType.parent.key;
      await SharedPreferencesManager.setValue('user_role', resolvedRole);
    }

    if (resolvedRole.isNotEmpty) {
      setUserType(resolvedRole);
    }
    return resolvedRole;
  }

  Future<bool> _hasParentStorage() async {
    const parentKeys = <String>[
      'selected_child_id',
      'selected_child_name',
      'selected_child_class_id',
      'student_info_id',
      'student_info_class_id',
      'last_leave_student_id',
    ];

    for (final key in parentKeys) {
      final value =
          (await SharedPreferencesManager.get(key) ?? '').toString().trim();
      final lower = value.toLowerCase();
      if (value.isNotEmpty &&
          lower != 'null' &&
          lower != 'undefined' &&
          lower != 'false') {
        return true;
      }
    }
    return false;
  }

  bool _isTablet = false;
  bool get isTablet => _isTablet;

  BuildContext? _context;
  BuildContext? get context => _context;

  void _checkDeviceType() {
    final currentContext = context;
    if (currentContext == null) {
      _isTablet = false;
      return;
    }
    _isTablet = currentContext.isTablet;
  }
}
