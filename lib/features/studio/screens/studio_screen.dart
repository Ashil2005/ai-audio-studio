import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/config/app_config.dart';
import '../widgets/action_card.dart';
import '../../../models/persona_model.dart';
import '../../../services/ai_service.dart';
import '../../../providers/service_providers.dart';

class StudioScreen extends ConsumerWidget {
  const StudioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider).valueOrNull;
    final isPremium = ref.watch(isPremiumProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: false,
            backgroundColor: AppTheme.background,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Good ${_greeting()},',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium,
                            ),
                            Text(
                              userProfile?.displayName.isNotEmpty == true
                                  ? userProfile!.displayName
                                  : 'Creator',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        // Plan badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: isPremium
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFFF59E0B),
                                      Color(0xFFEC4899)
                                    ],
                                  )
                                : null,
                            color: isPremium ? null : AppTheme.cardColor,
                            border: Border.all(color: AppTheme.glassBorder),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isPremium
                                    ? Icons.star_rounded
                                    : Icons.person_outline,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isPremium ? 'Premium' : 'Free',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Section title
                Text(
                  'AI Studio',
                  style: Theme.of(context).textTheme.titleLarge,
                ).animate().fadeIn(duration: 400.ms),

                const SizedBox(height: 4),
                Text(
                  'What would you like to create today?',
                  style: Theme.of(context).textTheme.bodyMedium,
                ).animate().fadeIn(delay: 100.ms),

                const SizedBox(height: 24),

                // Action cards grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                  children: [
                    ActionCard(
                      icon: Icons.picture_as_pdf_rounded,
                      title: 'Convert PDF',
                      subtitle: 'Turn any PDF into an audiobook',
                      gradientColors: const [
                        Color(0xFF7C3AED),
                        Color(0xFF06B6D4),
                      ],
                      onTap: () => context.push(AppRoutes.pdfUpload),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),

                    ActionCard(
                      icon: Icons.podcasts_rounded,
                      title: 'Generate Podcast',
                      subtitle: 'Create AI-hosted podcast from text',
                      gradientColors: const [
                        Color(0xFF06B6D4),
                        Color(0xFF10B981),
                      ],
                      onTap: () => context.go(AppRoutes.podcast),
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),

                    ActionCard(
                      icon: Icons.record_voice_over_rounded,
                      title: 'Start Debate',
                      subtitle: 'AI personas debate any topic',
                      gradientColors: const [
                        Color(0xFFEC4899),
                        Color(0xFFF59E0B),
                      ],
                      onTap: () => context.go(AppRoutes.debate),
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),

                    ActionCard(
                      icon: Icons.smart_toy_rounded,
                      title: 'Talk to AI',
                      subtitle: 'Voice chat with AI personas',
                      gradientColors: const [
                        Color(0xFFF59E0B),
                        Color(0xFF7C3AED),
                      ],
                      onTap: () {
                        // For now, default to Socrates for voice chat demo
                        final socrates = ref.read(aiServiceProvider).generatePersonaResponse(
                          persona: PersonaModel.fromJson({
                            'id': 'socrates',
                            'name': 'Socrates',
                            'description': 'Classical Greek philosopher',
                            'tone': 'philosophical',
                            'speakingStyle': 'balanced',
                            'prefixStyle': '🧘 Socrates:',
                          }),
                          userInput: "Hello",
                        );
                        // Actually we need the model directly. I'll use a hardcoded one for the link.
                        context.push(AppRoutes.voiceChat, extra: const PersonaModel(
                          id: 'socrates',
                          name: 'Socrates',
                          description: 'Classical Greek philosopher',
                          tone: PersonaTone.philosophical,
                          speakingStyle: SpeakingStyle.balanced,
                          prefixStyle: '🧘 Socrates:',
                        ));
                      },
                    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
                  ],
                ),

                const SizedBox(height: 32),

                // Usage bar (free plan only)
                if (!isPremium) _buildUsageBar(context, userProfile),

                const SizedBox(height: 24),

                // Quick tips
                _buildQuickTip(context),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageBar(BuildContext context, userProfile) {
    final used = userProfile?.monthlyAudioMinutesUsed ?? 0;
    final total = AppConfig.freeMonthlyAudioMinutes;
    final progress = (used / total).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassMorphism(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monthly Usage',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              TextButton(
                onPressed: () {},
                style:
                    TextButton.styleFrom(padding: EdgeInsets.zero),
                child: const Text(
                  'Upgrade →',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$used / $total minutes',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: progress > 0.8
                          ? AppTheme.error
                          : AppTheme.textSecondary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.glassBorder,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 0.8 ? AppTheme.error : AppTheme.primary,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _buildQuickTip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassMorphism(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary.withOpacity(0.1),
            AppTheme.secondary.withOpacity(0.05),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primary.withOpacity(0.2),
            ),
            child: const Icon(Icons.tips_and_updates_rounded,
                color: AppTheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tip: Start with a Debate',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  'Select two AI personas and pick any topic to watch them debate!',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 700.ms);
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }

  void _showComingSoon(BuildContext context, String feature, String stage) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withOpacity(0.2),
              ),
              child: const Icon(Icons.rocket_launch_rounded,
                  color: AppTheme.primary, size: 30),
            ),
            const SizedBox(height: 16),
            Text(
              feature,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Coming in $stage. We\'re building this feature next!',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Got it'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
