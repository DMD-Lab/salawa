import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class MosqueScraper {
  static const _pageUrl =
      'https://www.grandemosqueedeparis.fr/horaire-des-prieres-paris';

  static final _wixImageRegex = RegExp(
    r'https://static\.wixstatic\.com/media/[a-zA-Z0-9_]+~mv2\.jpg',
  );

  // Keywords that indicate a prayer calendar image
  static const _calendarKeywords = [
    'horaire', 'prière', 'priere', 'calendrier', 'salat',
    'fajr', 'dohr', 'asr', 'maghrib', 'icha',
    'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
    'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
  ];

  Future<String?> fetchCurrentMonthImageUrl() async {
    try {
      debugPrint('[MosqueScraper] Fetching page...');
      final response = await http.get(
        Uri.parse(_pageUrl),
        headers: {'User-Agent': 'Mozilla/5.0 (compatible; SalawaApp/1.0)'},
      );
      debugPrint('[MosqueScraper] Status: ${response.statusCode}');
      if (response.statusCode != 200) return null;

      final body = response.body;
      final urls = _wixImageRegex
          .allMatches(body)
          .map((m) => m.group(0)!)
          .toSet()
          .toList();

      debugPrint('[MosqueScraper] Found ${urls.length} image URLs');
      if (urls.isEmpty) return null;
      if (urls.length == 1) return urls.first;

      return _pickCalendarImage(urls, body);
    } catch (e) {
      debugPrint('[MosqueScraper] Error: $e');
      return null;
    }
  }

  String? _pickCalendarImage(List<String> urls, String body) {
    String? best;
    int bestScore = -1;

    for (final url in urls) {
      final idx = body.indexOf(url);
      if (idx == -1) continue;

      // Extract 600 chars of HTML context around the image URL
      final start = (idx - 300).clamp(0, body.length);
      final end = (idx + 300).clamp(0, body.length);
      final context = body.substring(start, end).toLowerCase();

      final score = _calendarKeywords
          .where((kw) => context.contains(kw))
          .length;

      debugPrint('[MosqueScraper] Score $score for: $url');
      debugPrint('[MosqueScraper]   Context: ${context.replaceAll('\n', ' ').substring(0, context.length.clamp(0, 150))}');

      if (score > bestScore) {
        bestScore = score;
        best = url;
      }
    }

    // If no keyword match, fall back to the first URL (manual review needed)
    debugPrint('[MosqueScraper] Selected (score $bestScore): $best');
    return best ?? urls.first;
  }

  Future<List<int>?> downloadImage(String url) async {
    try {
      debugPrint('[MosqueScraper] Downloading: $url');
      final response = await http.get(Uri.parse(url));
      debugPrint('[MosqueScraper] Downloaded: ${response.bodyBytes.length} bytes');
      if (response.statusCode != 200) return null;
      return response.bodyBytes;
    } catch (e) {
      debugPrint('[MosqueScraper] Download error: $e');
      return null;
    }
  }
}
