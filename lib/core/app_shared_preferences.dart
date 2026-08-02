import 'package:shared_preferences/shared_preferences.dart';

const appFolderName = 'Keymage';
const keyUserPrefPath = 'path';
const keyUserPrefFileName = 'fileName';
const keyImageHash = 'ImageHash';
const keyPwdImageHash = 'PwdImageHash';
const keyPwdHash = 'PwdHash';
const keyImageHashEnterApp = 'ImageHashEnterApp';
const keyBoolFirstRun = 'firstRun';
const keyBoolSecurityDone = 'securityDone';
const keyUserEntryMode = 'entryMode';
const keyLanguageOverride = 'languageOverride';

enum UserEntryMode {
  customPwd,
  androidSecurity,
  unknown;

  static UserEntryMode entriModeFromString(String? input) {
    if (input == "customPwd") {
      return customPwd;
    } else if (input == "androidSecurity") {
      return androidSecurity;
    } else {
      return unknown;
    }
  }
}

class AppSharedPreferences {
  static Future<String?> loadSavedDirectory() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(keyUserPrefPath);
  }

  static Future<String?> loadSavedFileName() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(keyUserPrefFileName);
  }

  static Future<bool> savedImageHash(String hash) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(keyImageHash, hash);
  }

  //----------------
  //----------------
  // app starting
  static Future<bool> saveEntryMode(UserEntryMode input) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(keyUserEntryMode, input.name);
  }

  static Future<UserEntryMode> loadEntryMode() async {
    String? res;
    final prefs = await SharedPreferences.getInstance();
    res = prefs.getString(
      keyUserEntryMode,
    );
    return UserEntryMode.entriModeFromString(res);
  }

  static Future<bool> savedPwdHash(String hash) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(keyPwdHash, hash);
  }

  static Future<bool> savedPwdImageHash(String hash) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(keyPwdImageHash, hash);
  }

  static Future<String?> loadPwdHash() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(keyPwdHash);
  }

  static Future<String?> loadPwdImageHash() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(keyPwdImageHash);
  }

  // ---------------
  // ---------------
  static Future<bool> saveImageHashEnterApp(String hash) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(keyImageHashEnterApp, hash);
  }

  static Future<String?> loadImageHashEnterApp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyImageHashEnterApp);
  }
  // ---------------
  // ---------------

  static Future<String?> loadImageHash() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyImageHash);
  }

  static Future<bool?> loadBoolFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyBoolFirstRun);
  }

  static Future<bool?> saveBoolFirstRun(bool input) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setBool(keyBoolFirstRun, input);
  }

  static Future<bool?> loadBoolSecurityDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyBoolSecurityDone);
  }

  static Future<bool?> saveBoolSecurityDone(bool input) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setBool(keyBoolSecurityDone, input);
  }

  /// Null means "follow the device language".
  static Future<String?> loadLanguageOverride() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyLanguageOverride);
  }

  /// Pass null to go back to following the device language.
  static Future<void> saveLanguageOverride(String? languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    if (languageCode == null) {
      await prefs.remove(keyLanguageOverride);
    } else {
      await prefs.setString(keyLanguageOverride, languageCode);
    }
  }
}
