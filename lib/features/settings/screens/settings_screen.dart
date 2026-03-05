import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../services/auth_service.dart';
import '../../../repositories/auth_repository.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider).valueOrNull;
    final isPremium = ref.watch(isPremiumProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.glassMorphism(),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppTheme.primary.withOpacity(0.2),
                    backgroundImage: userProfile?.photoUrl.isNotEmpty == true
                        ? NetworkImage(userProfile!.photoUrl)
                        : null,
                    child: userProfile?.photoUrl.isNotEmpty != true
                        ? const Icon(Icons.person_rounded,
                            color: AppTheme.primary, size: 30)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userProfile?.displayName.isNotEmpty == true
                              ? userProfile!.displayName
                              : 'Creator',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userProfile?.email ?? '',
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: isPremium
                          ? const LinearGradient(colors: [
                              Color(0xFFF59E0B),
                              Color(0xFFEC4899),
                            ])
                          : null,
                      color: isPremium ? null : AppTheme.cardColor,
                      border: Border.all(color: AppTheme.glassBorder),
                    ),
                    child: Text(
                      isPremium ? '⭐ Premium' : 'Free',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 32),

            _SectionLabel('Usage'),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.glassMorphism(),
              child: Column(
                children: [
                  _UsageRow(
                    icon: Icons.headphones_rounded,
                    label: 'Audio Minutes',
                    used: userProfile?.monthlyAudioMinutesUsed ?? 0,
                    total: isPremium ? null : 30,
                    color: AppTheme.primary,
                  ),
                  const SizedBox(height: 16),
                  _UsageRow(
                    icon: Icons.record_voice_over_rounded,
                    label: 'Debates',
                    used: userProfile?.monthlyDebatesUsed ?? 0,
                    total: isPremium ? null : 5,
                    color: AppTheme.accent,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 24),

            _SectionLabel('Settings'),

            _SettingsTile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Manage alerts',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.help_outline_rounded,
              title: 'Help & Support',
              subtitle: 'FAQs and contact',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () {},
            ),

            const SizedBox(height: 24),

            // Sign out
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await AuthRepository(AuthService()).signOut();
                  if (context.mounted) context.go(AppRoutes.login);
                },
                icon: const Icon(Icons.logout_rounded, color: AppTheme.error),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(color: AppTheme.error),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.error),
                ),
              ),
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 16),

            Center(
              child: Text(
                'PocketAudio Studio v1.0.0',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text,
          style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1)),
    );
  }
}

class _UsageRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int used;
  final int? total;
  final Color color;

  const _UsageRow({
    required this.icon,
    required this.label,
    required this.used,
    this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total != null ? (used / total!).clamp(0.0, 1.0) : 1.0;
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(label)),
            Text(total != null ? '$used / $total' : '$used / ∞',
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13)),
          ],
        ),
        if (total != null) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.glassBorder,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
          ),
        ],
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: AppTheme.glassMorphism(borderRadius: 14),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.textSecondary, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w500)),
                  if (subtitle != null)
                    Text(subtitle!,
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppTheme.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}
