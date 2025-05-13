import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tech_app/services/translation-service.dart';



class LanguageManager {
  static const _langKey = 'lang';

  static Future<void> saveLang(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, langCode);
  }

  static Future<String> getSavedLang() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_langKey) ?? 'en'; // Default to English
  }

  static Future<void> changeLanguage(BuildContext context, String langCode) async {
    // Set in Flutter UI
    await context.setLocale(Locale(langCode));
    await saveLang(langCode);

    // Update server
    await TranslationApiService().updateLocale(langCode);
  }
}
