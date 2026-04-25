import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../prayers/domain/day_prayers.dart';
import '../../../prayers/presentation/providers/prayers_provider.dart';

class MonthlyScreen extends ConsumerWidget {
  const MonthlyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPrayers = ref.watch(monthlyPrayersProvider);
    final today = DateTime.now().day;
    final raw = DateFormat('MMMM yyyy', 'fr_FR').format(DateTime.now());
    final monthStr = raw[0].toUpperCase() + raw.substring(1);

    const headers = ['J', 'Fajr', 'Dhouhr', 'Asr', 'Maghrib', 'Icha'];
    const flexes = [8, 18, 19, 18, 19, 18];

    Widget headerCell(String text) => Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
          textAlign: TextAlign.center,
        );

    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Text(
                monthStr,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Container(
              color: AppColors.card,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: Row(
                children: List.generate(
                  headers.length,
                  (i) => Expanded(flex: flexes[i], child: headerCell(headers[i])),
                ),
              ),
            ),
            Expanded(
              child: asyncPrayers.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => Center(
                  child: Text(
                    'Impossible de charger les horaires',
                    style: GoogleFonts.inter(color: Colors.white54),
                  ),
                ),
                data: (prayers) => _Table(prayers: prayers, today: today, flexes: flexes),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Table extends StatelessWidget {
  const _Table({required this.prayers, required this.today, required this.flexes});

  final List<DayPrayers> prayers;
  final int today;
  final List<int> flexes;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: prayers.map((p) {
          final isToday = p.day == today;
          final bg = isToday
              ? AppColors.primary
              : (p.day.isOdd ? AppColors.card : AppColors.bgSecondary);
          final textColor = isToday ? Colors.black : Colors.white;
          final timeColor = isToday ? Colors.black87 : AppColors.primary;
          final times = [p.fajr, p.dhouhr, p.asr, p.maghrib, p.icha];

          return Container(
            padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
            decoration: BoxDecoration(
              color: bg,
              border: Border(
                bottom: BorderSide(
                  color: isToday
                      ? Colors.transparent
                      : Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: flexes[0],
                  child: Text(
                    '${p.day}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                ...List.generate(
                  times.length,
                  (i) => Expanded(
                    flex: flexes[i + 1],
                    child: Text(
                      times[i],
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: timeColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
