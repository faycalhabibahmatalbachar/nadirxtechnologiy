import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class LocalStorage {
  const LocalStorage._();

  static Future<SharedPreferences> get _prefs async {
    return await SharedPreferences.getInstance();
  }

  // Inscription ID
  static Future<bool> saveInscriptionId(String id) async {
    final prefs = await _prefs;
    return await prefs.setString(AppConfig.keyInscriptionId, id);
  }

  static Future<String?> getInscriptionId() async {
    final prefs = await _prefs;
    return prefs.getString(AppConfig.keyInscriptionId);
  }

  static Future<bool> hasInscriptionId() async {
    final id = await getInscriptionId();
    return id != null && id.isNotEmpty;
  }

  static Future<bool> removeInscriptionId() async {
    final prefs = await _prefs;
    return await prefs.remove(AppConfig.keyInscriptionId);
  }

  // Onboarding
  static Future<bool> setOnboardingSeen() async {
    final prefs = await _prefs;
    return await prefs.setBool(AppConfig.keyOnboardingSeen, true);
  }

  static Future<bool> hasSeenOnboarding() async {
    final prefs = await _prefs;
    return prefs.getBool(AppConfig.keyOnboardingSeen) ?? false;
  }

  // Clear all
  static Future<bool> clearAll() async {
    final prefs = await _prefs;
    return await prefs.clear();
  }
}
