import 'dart:convert';

import 'package:flutter/material.dart';

import '/core/app_pallet.dart';
import '/core/app_restart.dart';
import '/core/app_shared_preferences.dart';
import '/core/dictionary/app_strings.dart';
import '/core/dictionary/language_helper.dart';

/// code -> native display name. Keep in sync with LanguageHelper's
/// _supportedLanguages and the assets/*.json files.
const Map<String, String> kSupportedLanguages = {
  'en': 'English',
  'ar': 'العربية',
  'es': 'Español',
  'fa': 'فارسی',
  'fr': 'Français',
  'it': 'Italiano',
  'pt': 'Português',
  'ru': 'Русский',
};

Future<void> showLanguagePicker(BuildContext context) async {
  final current = await AppSharedPreferences.loadLanguageOverride();
  if (!context.mounted) return;
  var changed = false;
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              AppStrings.changeLanguage,
              style: Theme.of(sheetContext).textTheme.titleLarge,
            ),
          ),
          RadioListTile<String?>(
            title: Text(AppStrings.systemDefault),
            value: null,
            groupValue: current,
            activeColor: AppPallet.bottomSheetTitleIcon,
            onChanged: (code) async {
              changed = await _applyLanguage(sheetContext, code);
            },
          ),
          for (final entry in kSupportedLanguages.entries)
            RadioListTile<String?>(
              title: Text(entry.value),
              value: entry.key,
              groupValue: current,
              activeColor: AppPallet.bottomSheetTitleIcon,
              onChanged: (code) async {
                changed = await _applyLanguage(sheetContext, code);
              },
            ),
        ],
      ),
    ),
  );
  if (changed && context.mounted) {
    AppRestartWidget.restartApp(context);
  }
}

/// Returns true once the new language is persisted and loaded.
Future<bool> _applyLanguage(BuildContext context, String? languageCode) async {
  await AppSharedPreferences.saveLanguageOverride(languageCode);
  final code = languageCode ?? LanguageHelper.getDeviceLanguageCode();
  final json = await getLanguageJson(code);
  AppStrings.fromJson(jsonDecode(json));
  if (context.mounted) Navigator.of(context).pop();
  return true;
}
