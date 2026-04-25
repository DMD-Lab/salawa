import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/prayer_repository.dart';
import '../../data/services/gemini_prayer_parser.dart';
import '../../domain/day_prayers.dart';

final _repository = PrayerRepository();

final loadingStepProvider = StateProvider<String>((ref) => '');

// Ticks at the start of each new minute, aligning to the clock
Stream<DateTime> _minuteStream() async* {
  yield DateTime.now();
  final now = DateTime.now();
  await Future.delayed(Duration(seconds: 60 - now.second));
  yield DateTime.now();
  yield* Stream.periodic(const Duration(minutes: 1), (_) => DateTime.now());
}

final currentTimeProvider = StreamProvider<DateTime>((ref) => _minuteStream());

DayPrayers _fromPrayerDay(PrayerDay d) => DayPrayers(
      day: d.day,
      fajr: d.fajr,
      dhouhr: d.dohr,
      asr: d.asr,
      maghrib: d.maghrib,
      icha: d.icha,
    );

class MonthlyPrayersNotifier extends AsyncNotifier<List<DayPrayers>> {
  @override
  Future<List<DayPrayers>> build() => _load();

  Future<List<DayPrayers>> _load() async {
    final now = DateTime.now();
    final days = await _repository.getPrayerDays(
      now.year,
      now.month,
      onStep: (msg) => ref.read(loadingStepProvider.notifier).state = msg,
    );
    ref.read(loadingStepProvider.notifier).state = '';
    if (days != null && days.isNotEmpty) {
      return days.map(_fromPrayerDay).toList();
    }
    throw Exception('Impossible de récupérer les horaires de prière.');
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final now = DateTime.now();
    final days = await _repository.refresh(
      now.year,
      now.month,
      onStep: (msg) => ref.read(loadingStepProvider.notifier).state = msg,
    );
    ref.read(loadingStepProvider.notifier).state = '';
    if (days != null && days.isNotEmpty) {
      state = AsyncData(days.map(_fromPrayerDay).toList());
    } else {
      state = AsyncError(
        Exception('Impossible de récupérer les horaires de prière.'),
        StackTrace.current,
      );
    }
  }
}

final monthlyPrayersProvider =
    AsyncNotifierProvider<MonthlyPrayersNotifier, List<DayPrayers>>(
  MonthlyPrayersNotifier.new,
);

final todayPrayersProvider = Provider<DayPrayers?>((ref) {
  return ref.watch(monthlyPrayersProvider).whenOrNull(data: (prayers) {
    final today = DateTime.now().day;
    return prayers.firstWhere((p) => p.day == today, orElse: () => prayers.first);
  });
});

// Prayer whose time == current minute → bell icon
final activePrayerProvider = Provider<String?>((ref) {
  final today = ref.watch(todayPrayersProvider);
  if (today == null) return null;
  final now = ref.watch(currentTimeProvider).valueOrNull ?? DateTime.now();
  final currentMinutes = now.hour * 60 + now.minute;
  for (final entry in today.entries) {
    final parts = entry.value.split(':');
    final prayerMinutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);
    if (currentMinutes == prayerMinutes) return entry.key;
  }
  return null;
});

// First prayer whose time is strictly in the future
final nextPrayerProvider = Provider<String?>((ref) {
  final today = ref.watch(todayPrayersProvider);
  if (today == null) return null;
  final now = ref.watch(currentTimeProvider).valueOrNull ?? DateTime.now();
  final currentMinutes = now.hour * 60 + now.minute;
  for (final entry in today.entries) {
    final parts = entry.value.split(':');
    final prayerMinutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);
    if (currentMinutes < prayerMinutes) return entry.key;
  }
  return null;
});
