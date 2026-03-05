import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

class ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final VoidCallback onTap;
  final bool isPremium;

  const ActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.onTap,
    this.isPremium = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              gradientColors[0].withOpacity(0.15),
              gradientColors[1].withOpacity(0.08),
            ],
          ),
          border: Border.all(
            color: gradientColors[0].withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradientColors,
                    ),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                if (isPremium)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFEC4899)],
                      ),
                    ),
                    child: const Text(
                      'PRO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            Text(
              title,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              subtitle,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Text(
                  'Get started',
                  style: TextStyle(
                    color: gradientColors[0],
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded,
                    color: gradientColors[0], size: 16),
              ],
            ),
          ],
        ),
      ).animate(onPlay: (c) => c.repeat(reverse: true)).custom(
            duration: 3000.ms,
            builder: (context, value, child) => child!,
          ),
    );
  }
}
