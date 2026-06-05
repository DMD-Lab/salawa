import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/widgets/app_tappable.dart';
import 'prayer_clock.dart';

class PrayerTile extends StatefulWidget {
  const PrayerTile({
    super.key,
    required this.name,
    required this.time,
    required this.isNext,
    required this.isActive,
    this.isPast = false,
  });

  final String name;
  final String time;
  final bool isNext;
  final bool isActive;
  final bool isPast;

  @override
  State<PrayerTile> createState() => _PrayerTileState();
}

class _PrayerTileState extends State<PrayerTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _blink;

  @override
  void initState() {
    super.initState();
    _blink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    if (widget.isActive) _blink.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(PrayerTile old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !_blink.isAnimating) {
      _blink.repeat(reverse: true);
    } else if (!widget.isActive && _blink.isAnimating) {
      _blink.stop();
      _blink.value = 1.0;
    }
  }

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  void _showClock(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
          child: PrayerClock(time: widget.time, prayerName: widget.name),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final highlighted = widget.isNext || widget.isActive;
    final bgColor = highlighted ? AppColors.primary : AppColors.card;
    final textColor = highlighted ? Colors.black : Colors.white;
    final timeColor = highlighted ? Colors.black : AppColors.primary;

    return Opacity(
      opacity: widget.isPast ? 0.4 : 1.0,
      child: AppTappable(
      onTap: () => _showClock(context),
      child: AnimatedContainer(
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
            Text(
              widget.name,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            Row(
              children: [
                if (widget.isActive) ...[
                  FadeTransition(
                    opacity: _blink,
                    child: Icon(
                      Icons.notifications_active_rounded,
                      color: textColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Text(
                  widget.time,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: timeColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}
