import 'package:get/get.dart';
import 'package:schoolapp/core/constants/storage_key.dart';

class AppFontFamily {
  AppFontFamily._();

  static const roboto = 'Roboto';
  static const battambang = 'Battambang';

  static String forLanguage(String language) {
    return language.toUpperCase() == Language.en.key ? roboto : battambang;
  }

  static String get localized {
    final languageCode = Get.locale?.languageCode.toUpperCase();
    return languageCode == Language.en.key ? roboto : battambang;
  }

  static String forText(String? text) {
    final value = (text ?? '').trim();
    if (value.isEmpty) {
      return localized;
    }

    final languageCode = Get.locale?.languageCode.toUpperCase();
    if (languageCode == Language.en.key) {
      return roboto;
    }

    return _containsKhmer(value) ? battambang : roboto;
  }

  static bool _containsKhmer(String text) {
    for (final rune in text.runes) {
      if (rune >= 0x1780 && rune <= 0x17FF) {
        return true;
      }
    }
    return false;
  }
}
