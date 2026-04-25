import '../services/mosque_scraper.dart';
import '../services/gemini_prayer_parser.dart';
import '../services/prayer_cache.dart';

class PrayerRepository {
  final _scraper = MosqueScraper();
  final _parser = GeminiPrayerParser();
  final _cache = PrayerCache();

  Future<List<PrayerDay>?> getPrayerDays(
    int year,
    int month, {
    void Function(String)? onStep,
  }) async {
    final cached = await _cache.load(year, month);
    if (cached != null) return cached;
    return _fetchAndCache(year, month, onStep: onStep);
  }

  Future<List<PrayerDay>?> refresh(
    int year,
    int month, {
    void Function(String)? onStep,
  }) =>
      _fetchAndCache(year, month, onStep: onStep);

  Future<List<PrayerDay>?> _fetchAndCache(
    int year,
    int month, {
    void Function(String)? onStep,
  }) async {
    onStep?.call('Récupération des horaires du mois...');

    // Use cached URL if available to skip the page fetch
    var imageUrl = await _cache.loadImageUrl(year, month);
    if (imageUrl == null) {
      imageUrl = await _scraper.fetchCurrentMonthImageUrl();
      if (imageUrl == null) return null;
      await _cache.saveImageUrl(year, month, imageUrl);
    }

    onStep?.call('Téléchargement de l\'image...');
    final imageBytes = await _scraper.downloadImage(imageUrl);
    if (imageBytes == null) return null;

    onStep?.call('Analyse de l\'image...');
    final days = await _parser.parseFromImageBytes(imageBytes);
    if (days == null || days.isEmpty) return null;

    onStep?.call('Mise en cache...');
    await _cache.save(year, month, days);
    return days;
  }
}
