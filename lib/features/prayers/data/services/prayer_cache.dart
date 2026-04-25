import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'gemini_prayer_parser.dart';

class PrayerCache {
  static const _keyPrefix = 'prayer_month_';
  static const _urlPrefix = 'prayer_image_url_';

  String _key(int year, int month) => '$_keyPrefix${year}_$month';
  String _urlKey(int year, int month) => '$_urlPrefix${year}_$month';

  Future<List<PrayerDay>?> load(int year, int month) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(year, month));
    if (raw == null) return null;
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => PrayerDay.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> save(int year, int month, List<PrayerDay> days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(year, month), jsonEncode(days.map((d) => d.toJson()).toList()));
    await _deletePreviousMonths(prefs, year, month);
  }

  Future<String?> loadImageUrl(int year, int month) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_urlKey(year, month));
  }

  Future<void> saveImageUrl(int year, int month, String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_urlKey(year, month), url);
  }

  Future<void> _deletePreviousMonths(SharedPreferences prefs, int year, int month) async {
    final currentDataKey = _key(year, month);
    final currentUrlKey = _urlKey(year, month);
    for (final key in prefs.getKeys().toList()) {
      if ((key.startsWith(_keyPrefix) || key.startsWith(_urlPrefix)) &&
          key != currentDataKey &&
          key != currentUrlKey) {
        await prefs.remove(key);
      }
    }
  }
}
