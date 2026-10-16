import 'package:flutter/material.dart';
import '../theme/lummings_theme.dart';

/// Premium section title used across Nest screens.
class NestSectionHeader extends StatelessWidget {
  final String title;
  final String? trailing;
  final Color? accent;

  const NestSectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final a = accent ?? LummingsColors.starYellow;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [a, a.withOpacity(0.25)],
            ),
            boxShadow: [
              BoxShadow(color: a.withOpacity(0.45), blurRadius: 8),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
          ),
        ),
        if (trailing != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: a.withOpacity(0.15),
              border: Border.all(color: a.withOpacity(0.35)),
            ),
            child: Text(
              trailing!,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12,
                color: a,
              ),
            ),
          ),
      ],
    );
  }
}
