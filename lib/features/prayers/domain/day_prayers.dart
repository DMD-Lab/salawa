class DayPrayers {
  const DayPrayers({
    required this.day,
    required this.fajr,
    required this.dhouhr,
    required this.asr,
    required this.maghrib,
    required this.icha,
  });

  final int day;
  final String fajr;
  final String dhouhr;
  final String asr;
  final String maghrib;
  final String icha;

  List<MapEntry<String, String>> get entries => [
        MapEntry('Fajr', fajr),
        MapEntry('Dhouhr', dhouhr),
        MapEntry('Asr', asr),
        MapEntry('Maghrib', maghrib),
        MapEntry('Icha', icha),
      ];
}
