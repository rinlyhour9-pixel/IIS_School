import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
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

  late ProfileModel _profile;
  ProfileModel get profile => _profile;

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
    SharedPreferencesManager.remove(Credential.token.name);
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

    if (resolvedRole != UserType.parent.key && await _hasParentStorage()) {
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
