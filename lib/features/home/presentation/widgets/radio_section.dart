import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/widgets/app_tappable.dart';
import '../../../radio/presentation/providers/radio_provider.dart';

class RadioSection extends ConsumerWidget {
  const RadioSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final radio = ref.watch(radioProvider);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Radio Orient',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  radio.isPlaying
                      ? 'En cours de lecture'
                      : radio.isLoading
                          ? 'Connexion...'
                          : radio.hasError
                              ? 'Erreur de connexion'
                              : 'Appuyer pour écouter',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: radio.hasError ? Colors.redAccent : Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          AppTappable(
            onTap: radio.isLoading
                ? () {}
                : () => ref.read(radioProvider.notifier).toggle(),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: radio.hasError
                    ? Colors.red.shade700
                    : AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: radio.isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(18),
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Icon(
                      radio.hasError
                          ? Icons.refresh_rounded
                          : radio.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                      color: Colors.black,
                      size: 36,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
