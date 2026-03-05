import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(24),
      decoration: AppTheme.glassMorphism(borderRadius: borderRadius),
      child: child,
    );
  }
}
