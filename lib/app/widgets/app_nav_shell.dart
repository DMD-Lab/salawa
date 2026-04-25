import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../../features/prayers/presentation/providers/prayers_provider.dart';

class AppNavShell extends ConsumerWidget {
  const AppNavShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final index = location.startsWith('/monthly') ? 1 : 0;
    final hasData = ref.watch(monthlyPrayersProvider).hasValue;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          if (i == 0) context.go('/home');
          if (i == 1 && hasData) context.go('/monthly');
        },
        backgroundColor: AppColors.card,
        indicatorColor: AppColors.primary.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) =>
          GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : Colors.white54,
          ),
        ),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined, color: Colors.white54),
            selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.calendar_month_outlined,
              color: hasData ? Colors.white54 : Colors.white24,
            ),
            selectedIcon: Icon(
              Icons.calendar_month_rounded,
              color: hasData ? AppColors.primary : Colors.white24,
            ),
            label: 'Calendrier',
          ),
        ],
      ),
    );
  }
}
