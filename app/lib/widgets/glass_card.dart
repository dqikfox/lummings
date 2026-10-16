import 'package:flutter/material.dart';
import '../theme/lummings_theme.dart';

/// Frosted nest surface — the core visual language of Lummings.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? accent;
  final double radius;
  final VoidCallback? onTap;
  final bool elevated;
  final Gradient? gradient;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.accent,
    this.radius = 22,
    this.onTap,
    this.elevated = true,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final border = accent ?? Colors.white.withOpacity(0.12);
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: gradient ??
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                LummingsColors.surfaceHi.withOpacity(0.95),
                LummingsColors.surface.withOpacity(0.82),
                const Color(0xFF0E1424).withOpacity(0.9),
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
        border: Border.all(
          color: border.withOpacity(accent != null ? 0.45 : 0.14),
          width: accent != null ? 1.4 : 1.0,
        ),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: (accent ?? LummingsColors.futurePurple)
                      .withOpacity(0.14),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: child,
    );
    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        splashColor: (accent ?? LummingsColors.starYellow).withOpacity(0.12),
        highlightColor: (accent ?? LummingsColors.starYellow).withOpacity(0.06),
        child: card,
      ),
    );
  }
}
