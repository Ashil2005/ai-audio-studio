import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _hasNavigated = false;

  void _navigateAfterDelay(String route) {
    if (_hasNavigated) return;
    _hasNavigated = true;
    
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        context.go(route);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    // Handle navigation when auth state is resolved
    authState.when(
      data: (user) {
        final route = user != null ? AppRoutes.studio : AppRoutes.login;
        _navigateAfterDelay(route);
      },
      loading: () {
        // Show loading state
      },
      error: (error, stack) {
        _navigateAfterDelay(AppRoutes.login);
      },
    );

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App icon / logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.primary, AppTheme.secondary],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.mic_rounded,
                color: Colors.white,
                size: 52,
              ),
            )
                .animate()
                .scale(
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                )
                .then()
                .shimmer(duration: 1200.ms),

            const SizedBox(height: 28),

            Text(
              'PocketAudio Studio',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
            )
                .animate()
                .fadeIn(delay: 400.ms, duration: 600.ms)
                .slideY(begin: 0.2, end: 0),

            const SizedBox(height: 8),

            Text(
              'AI Knowledge Creation Platform',
              style: Theme.of(context).textTheme.bodyMedium,
            )
                .animate()
                .fadeIn(delay: 600.ms, duration: 600.ms)
                .slideY(begin: 0.2, end: 0),

            const SizedBox(height: 64),

            // Loading indicator
            SizedBox(
              width: 120,
              child: LinearProgressIndicator(
                backgroundColor: AppTheme.glassBorder,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                borderRadius: BorderRadius.circular(4),
              ),
            )
                .animate()
                .fadeIn(delay: 800.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }
}
