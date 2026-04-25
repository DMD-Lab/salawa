import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';

class PrayerTile extends StatelessWidget {
  const PrayerTile({
    super.key,
    required this.name,
    required this.time,
    required this.isNext,
    required this.isActive,
  });

  final String name;
  final String time;
  final bool isNext;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final highlighted = isNext || isActive;
    final bgColor = highlighted ? AppColors.primary : AppColors.card;
    final textColor = highlighted ? Colors.black : Colors.white;
    final timeColor = highlighted ? Colors.black : AppColors.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              if (isActive) ...[
                const SizedBox(width: 8),
                Icon(Icons.notifications_active_rounded, color: textColor, size: 18),
              ],
            ],
          ),
          Text(
            time,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: timeColor,
            ),
          ),
        ],
      ),
    );
  }
}
