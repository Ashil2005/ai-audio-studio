import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/router/app_router.dart';

class ShellScaffold extends StatelessWidget {
  final Widget child;
  const ShellScaffold({super.key, required this.child});

  static const _tabs = [
    (icon: Icons.auto_awesome_rounded, label: 'Studio', route: AppRoutes.studio),
    (icon: Icons.library_music_rounded, label: 'Library', route: AppRoutes.library),
    (icon: Icons.record_voice_over_rounded, label: 'Debate', route: AppRoutes.debate),
    (icon: Icons.manage_accounts_rounded, label: 'Account', route: AppRoutes.settings),
  ];

  int _activeIndex(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < _tabs.length; i++) {
      if (loc.startsWith(_tabs[i].route)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final idx = _activeIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border(
            top: BorderSide(color: AppTheme.glassBorder, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_tabs.length, (i) {
                final tab = _tabs[i];
                final isActive = i == idx;
                return GestureDetector(
                  onTap: () => context.go(tab.route),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppTheme.primary.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tab.icon,
                          color: isActive
                              ? AppTheme.primary
                              : AppTheme.textSecondary,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tab.label,
                          style: TextStyle(
                            color: isActive
                                ? AppTheme.primary
                                : AppTheme.textSecondary,
                            fontSize: 11,
                            fontWeight: isActive
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
