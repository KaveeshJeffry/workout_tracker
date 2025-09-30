import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  // Bump the plan key because model changed
  static const _keyPlanV2 = 'plan_v2';
  static const _keyPlanV1 = 'plan_v1';
  static const _keyNextDay = 'next_day_v1';
  static const _keyLogs = 'logs_v1';

  Future<void> savePlan(Map<String, dynamic> plan) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPlanV2, jsonEncode(plan));
  }

  /// Try new first, then old (so we can migrate).
  Future<Map<String, dynamic>?> loadPlanAny() async {
    final prefs = await SharedPreferences.getInstance();
    final s2 = prefs.getString(_keyPlanV2);
    if (s2 != null) return jsonDecode(s2) as Map<String, dynamic>;
    final s1 = prefs.getString(_keyPlanV1);
    if (s1 != null) return jsonDecode(s1) as Map<String, dynamic>;
    return null;
  }

  Future<void> removeOldPlanV1() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPlanV1);
  }

  Future<void> saveNextDay(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyNextDay, id);
  }

  Future<String?> loadNextDay() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyNextDay);
  }

  Future<void> addLog(Map<String, dynamic> entry) async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_keyLogs);
    final list = s == null
        ? <Map<String, dynamic>>[]
        : List<Map<String, dynamic>>.from(jsonDecode(s));
    list.add(entry);
    await prefs.setString(_keyLogs, jsonEncode(list));
  }

  Future<List<Map<String, dynamic>>> loadLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_keyLogs);
    if (s == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(s));
  }
}
