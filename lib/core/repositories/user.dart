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

  bool _isTablet = false;
  bool get isTablet => _isTablet;

  BuildContext? _context;
  BuildContext? get context => _context;

  void _checkDeviceType() {
    _isTablet = context!.isTablet;
  }
}
