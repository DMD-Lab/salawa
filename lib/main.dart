import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR');
  await JustAudioBackground.init(
    androidNotificationChannelId: 'net.dmdlab.salawa.audio',
    androidNotificationChannelName: 'Salawa Radio',
    androidNotificationOngoing: true,
  );
  runApp(const ProviderScope(child: App()));
}
