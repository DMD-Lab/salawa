import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import 'app_tappable.dart';

enum AppButtonVariant { primary, secondary, outline, destructive }

class AppButton extends StatelessWidget {
  const AppButton._({
    super.key,
    required this.label,
    required this.onTap,
    required this.variant,
  });

  factory AppButton.primary({
    Key? key,
    required String label,
    required VoidCallback onTap,
  }) =>
      AppButton._(key: key, label: label, onTap: onTap, variant: AppButtonVariant.primary);

  factory AppButton.secondary({
    Key? key,
    required String label,
    required VoidCallback onTap,
  }) =>
      AppButton._(key: key, label: label, onTap: onTap, variant: AppButtonVariant.secondary);

  factory AppButton.outline({
    Key? key,
    required String label,
    required VoidCallback onTap,
  }) =>
      AppButton._(key: key, label: label, onTap: onTap, variant: AppButtonVariant.outline);

  factory AppButton.destructive({
    Key? key,
    required String label,
    required VoidCallback onTap,
  }) =>
      AppButton._(key: key, label: label, onTap: onTap, variant: AppButtonVariant.destructive);

  final String label;
  final VoidCallback onTap;
  final AppButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final bg = switch (variant) {
      AppButtonVariant.primary => AppColors.primary,
      AppButtonVariant.secondary => AppColors.card,
      AppButtonVariant.outline => Colors.transparent,
      AppButtonVariant.destructive => Colors.red.shade700,
    };
    final textColor = switch (variant) {
      AppButtonVariant.primary => Colors.black,
      _ => AppColors.textPrimary,
    };
    final border = variant == AppButtonVariant.outline
        ? Border.all(color: AppColors.primary)
        : null;

    return AppTappable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: border,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
