import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppConfig {
  AppConfig._() {
    _getVersion();
    _getToken();
  }

  static final _instance = AppConfig._();
  static AppConfig get shared => _instance;

  String get baseUrl => dotenv.env[EnvKey.baseUrl.value] ?? '';

  String _token = '';
  String get token => _token;
  String get authorizationToken => _token.isEmpty ? '' : 'Bearer $_token';
  set token(String value) => _token = value;

  Future<void> _getToken() async {
    _token = await SharedPreferencesManager.get(Credential.token.name) ?? '';
  }

  String _language = Language.kh.key;
  String get language => _language;

  Future<void> setLanguage(String value) async {
    dynamic localLng = await SharedPreferencesManager.get(
      LanguageKey.language.name,
    );
    _language = localLng ?? value;
  }

  // update later
  Future<void> updateLanguage(String value) async {
    _language = value;
    // Get.updateLocale awaits a full app reassemble so every already-mounted
    // screen actually re-renders with the new locale, not just newly built
    // ones. Without this await, callers moved on before that reassemble
    // finished, so a screen that was already in memory (e.g. reached via
    // bottom-nav/drawer, not freshly pushed) could still show the old
    // language on the very next visit and only self-correct afterward.
    await Get.updateLocale(AppConfig.shared.languageLocale);
    Get.changeTheme(
      AppStyle.themeData(fontFamily: AppFontFamily.forLanguage(_language)),
    );
    await SharedPreferencesManager.setValue(
      LanguageKey.language.name,
      _language,
    );
  }

  Locale get languageLocale {
    switch (language) {
      case 'EN':
        return const Locale('EN', 'US');
      default:
        return const Locale('KM', 'KH');
    }
  }

  String _version = '0.0.0';
  String get version => _version;

  Future<void> _getVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _version = packageInfo.version;
  }
}
