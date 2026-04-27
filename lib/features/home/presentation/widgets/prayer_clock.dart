import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';

class PrayerClock extends StatelessWidget {
  const PrayerClock({super.key, required this.time, required this.prayerName});

  final String time;
  final String prayerName;

  @override
  Widget build(BuildContext context) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]) % 12;
    final minute = int.parse(parts[1]);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          prayerName,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 32),
        CustomPaint(
          size: const Size(220, 220),
          painter: _ClockPainter(hour: hour, minute: minute),
        ),
      ],
    );
  }
}

class _ClockPainter extends CustomPainter {
  const _ClockPainter({required this.hour, required this.minute});

  final int hour;
  final int minute;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Face
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = const Color(0xFF1A2E1C),
    );

    // Border
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.primary.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Hour numbers
    for (var i = 1; i <= 12; i++) {
      final angle = (i * 2 * pi / 12) - pi / 2;
      final numRadius = radius * 0.78;
      final x = center.dx + numRadius * cos(angle);
      final y = center.dy + numRadius * sin(angle);

      final tp = TextPainter(
        text: TextSpan(
          text: '$i',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
    }

    // Minute ticks
    for (var i = 0; i < 60; i++) {
      final angle = i * 2 * pi / 60 - pi / 2;
      final isHour = i % 5 == 0;
      final outer = radius * 0.92;
      final inner = isHour ? radius * 0.84 : radius * 0.88;
      canvas.drawLine(
        Offset(center.dx + inner * cos(angle), center.dy + inner * sin(angle)),
        Offset(center.dx + outer * cos(angle), center.dy + outer * sin(angle)),
        Paint()
          ..color = isHour
              ? Colors.white54
              : Colors.white24
          ..strokeWidth = isHour ? 1.5 : 0.8
          ..strokeCap = StrokeCap.round,
      );
    }

    // Hour hand
    final hourAngle =
        (hour + minute / 60) * 2 * pi / 12 - pi / 2;
    _drawHand(
      canvas,
      center,
      angle: hourAngle,
      length: radius * 0.5,
      width: 5,
      color: AppColors.primary,
    );

    // Minute hand
    final minuteAngle = minute * 2 * pi / 60 - pi / 2;
    _drawHand(
      canvas,
      center,
      angle: minuteAngle,
      length: radius * 0.7,
      width: 3,
      color: Colors.white,
    );

    // Center dot
    canvas.drawCircle(center, 6, Paint()..color = AppColors.primary);
    canvas.drawCircle(center, 3, Paint()..color = Colors.black);
  }

  void _drawHand(
    Canvas canvas,
    Offset center, {
    required double angle,
    required double length,
    required double width,
    required Color color,
  }) {
    canvas.drawLine(
      center,
      Offset(center.dx + length * cos(angle), center.dy + length * sin(angle)),
      Paint()
        ..color = color
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ClockPainter old) =>
      old.hour != hour || old.minute != minute;
}
