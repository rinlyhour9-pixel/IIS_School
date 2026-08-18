import 'package:flutter/material.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/flavor/app_config.dart';

class InlineLanguageDropdown extends StatelessWidget {
  const InlineLanguageDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final isEnglish = AppConfig.shared.language == Language.en.key;
    final flagPath =
        isEnglish ? AssetPath.englishFlag.path : AssetPath.cambodiaFlag.path;
    final label = isEnglish ? 'EN' : 'KH';

    return PopupMenuButton<String>(
      tooltip: '',
      color: Colors.white,
      surfaceTintColor: Colors.white,
      onSelected: (value) {
        if (value == Language.en.key) {
          AppConfig.shared.updateLanguage(Language.en.key);
        } else {
          AppConfig.shared.updateLanguage(Language.kh.key);
        }
      },
      itemBuilder:
          (context) => [
            _languageItem(
              value: Language.en.key,
              flagPath: AssetPath.englishFlag.path,
              label: 'EN',
            ),

            _languageItem(
              value: Language.kh.key,
              flagPath: AssetPath.cambodiaFlag.path,
              label: 'KH',
            ),
          ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(color: const Color(0xFFEAEAEA)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Image.asset(
                flagPath,
                width: 24,
                height: 16,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 18),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _languageItem({
    required String value,
    required String flagPath,
    required String label,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Image.asset(
              flagPath,
              width: 24,
              height: 16,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
