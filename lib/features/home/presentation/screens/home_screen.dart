import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../prayers/presentation/providers/prayers_provider.dart';
import '../widgets/prayer_tile.dart';
import '../widgets/radio_section.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPrayers = ref.watch(monthlyPrayersProvider);
    final nextPrayer = ref.watch(nextPrayerProvider);
    final activePrayer = ref.watch(activePrayerProvider);
    final pastPrayers = ref.watch(pastPrayersProvider);
    final loadingStep = ref.watch(loadingStepProvider);
    final now = DateTime.now();
    final raw = DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(now);
    final dateStr = raw[0].toUpperCase() + raw.substring(1);

    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Text(
                dateStr,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Expanded(
              child: asyncPrayers.when(
                loading: () => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      if (loadingStep.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          loadingStep,
                          style: GoogleFonts.inter(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
                error: (_, _) => _ErrorView(
                  onRetry: () => ref.read(monthlyPrayersProvider.notifier).refresh(),
                ),
                data: (prayers) {
                  final today = DateTime.now().day;
                  final todayPrayers = prayers.firstWhere(
                    (p) => p.day == today,
                    orElse: () => prayers.first,
                  );
                  return ListView(
                    padding: EdgeInsets.zero,
                    children: todayPrayers.entries.map((e) {
                      return PrayerTile(
                        name: e.key,
                        time: e.value,
                        isNext: e.key == nextPrayer,
                        isActive: e.key == activePrayer,
                        isPast: pastPrayers.contains(e.key),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            const RadioSection(),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, color: Colors.white38, size: 48),
            const SizedBox(height: 16),
            Text(
              'Impossible de charger les horaires',
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Vérifiez votre connexion internet',
              style: GoogleFonts.inter(color: Colors.white38, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
              label: Text(
                'Réessayer',
                style: GoogleFonts.inter(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
