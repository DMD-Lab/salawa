import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../../app/config/app_config.dart';

class PrayerDay {
  final int day;
  final String fajr;
  final String dohr;
  final String asr;
  final String maghrib;
  final String icha;

  const PrayerDay({
    required this.day,
    required this.fajr,
    required this.dohr,
    required this.asr,
    required this.maghrib,
    required this.icha,
  });

  factory PrayerDay.fromJson(Map<String, dynamic> json) => PrayerDay(
        day: json['jour'] as int,
        fajr: json['fajr'] as String,
        dohr: json['dohr'] as String,
        asr: json['asr'] as String,
        maghrib: json['maghrib'] as String,
        icha: json['icha'] as String,
      );

  Map<String, dynamic> toJson() => {
        'jour': day,
        'fajr': fajr,
        'dohr': dohr,
        'asr': asr,
        'maghrib': maghrib,
        'icha': icha,
      };
}

class GeminiPrayerParser {
  static const _prompt = '''
Tu es un extracteur de données. Cette image est un tableau d'horaires de prière mensuel.
Extrais TOUTES les lignes du tableau et retourne un JSON valide avec exactement ce format :

{
  "mois": <numéro du mois 1-12>,
  "annee": <année sur 4 chiffres>,
  "jours": [
    { "jour": 1, "fajr": "05:30", "dohr": "13:15", "asr": "17:00", "maghrib": "20:45", "icha": "22:30" },
    ...
  ]
}

Règles :
- Les horaires sont au format HH:mm (24h)
- "jour" est un entier (1 à 31)
- Inclus tous les jours présents dans le tableau
- Retourne UNIQUEMENT le JSON, sans texte avant ou après
- Si une valeur est illisible, met "00:00"
''';

  final GenerativeModel _model;

  GeminiPrayerParser()
      : _model = GenerativeModel(
          model: 'gemini-2.5-flash',
          apiKey: AppConfig.geminiApiKey,
        );

  Future<List<PrayerDay>?> parseFromImageBytes(List<int> imageBytes) async {
    final compressed = await FlutterImageCompress.compressWithList(
      Uint8List.fromList(imageBytes),
      quality: 75,
      minWidth: 1200,
      minHeight: 800,
    );
    debugPrint('[GeminiParser] Compressed: ${imageBytes.length} → ${compressed.length} bytes');

    // Retry up to 3 times on rate-limit (429)
    for (var attempt = 1; attempt <= 3; attempt++) {
      try {
        debugPrint('[GeminiParser] Attempt $attempt — sending to Gemini...');
        final response = await _model.generateContent([
          Content.multi([
            TextPart(_prompt),
            DataPart('image/jpeg', compressed),
          ]),
        ]);

        final text = response.text;
        debugPrint('[GeminiParser] Response: ${text?.substring(0, (text.length).clamp(0, 200))}');
        if (text == null || text.isEmpty) return null;

        final jsonStr = _extractJson(text);
        final data = jsonDecode(jsonStr) as Map<String, dynamic>;
        final jours = data['jours'] as List<dynamic>;
        debugPrint('[GeminiParser] Parsed ${jours.length} days');
        return jours.map((j) => PrayerDay.fromJson(j as Map<String, dynamic>)).toList();
      } catch (e) {
        final isRateLimit = e.toString().contains('429') || e.toString().contains('quota') || e.toString().contains('retry');
        debugPrint('[GeminiParser] Attempt $attempt error (rateLimit=$isRateLimit): $e');
        if (isRateLimit && attempt < 3) {
          final waitSeconds = attempt * 60;
          debugPrint('[GeminiParser] Waiting ${waitSeconds}s before retry...');
          await Future.delayed(Duration(seconds: waitSeconds));
        } else {
          return null;
        }
      }
    }
    return null;
  }

  String _extractJson(String text) {
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start == -1 || end == -1) return text;
    return text.substring(start, end + 1);
  }
}
